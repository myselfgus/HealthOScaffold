import Foundation
import HealthOSCore

public actor ScribeFirstSliceAdapter: ScribeFirstSliceFacade {
    private struct SessionWorkspace {
        let professional: Usuario
        let service: Servico
        var patient: Usuario?
        var capture: SessionCaptureInput?
    }

    private let runner: FirstSliceRunner
    private var workspaces: [UUID: SessionWorkspace] = [:]

    public init(runner: FirstSliceRunner) {
        self.runner = runner
    }

    public func startProfessionalSession(
        _ command: StartProfessionalSessionCommand
    ) async -> SessionStartResult {
        guard command.professional.active else {
            return SessionStartResult(
                disposition: .governedDeny,
                state: nil,
                issues: [
                    .init(
                        code: .professionalInactive,
                        message: "Professional user is inactive and cannot open a session.",
                        failureKind: .authorization
                    )
                ]
            )
        }
        guard !command.service.nome.isEmpty else {
            return SessionStartResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [
                    .init(
                        code: .serviceInvalid,
                        message: "Service name is required to open a session.",
                        failureKind: .validation
                    )
                ]
            )
        }

        let sessionId = UUID()
        workspaces[sessionId] = SessionWorkspace(
            professional: command.professional,
            service: command.service
        )
        return SessionStartResult(
            disposition: .completeSuccess,
            state: makePendingState(sessionId: sessionId)
        )
    }

    public func selectPatient(_ command: SelectPatientCommand) async -> PatientSelectionResult {
        guard var workspace = workspaces[command.sessionId] else {
            return PatientSelectionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [
                    .init(
                        code: .sessionNotFound,
                        message: "Session was not started before patient selection.",
                        failureKind: .state
                    )
                ]
            )
        }
        guard command.patient.active else {
            return PatientSelectionResult(
                disposition: .governedDeny,
                state: makePendingState(sessionId: command.sessionId),
                issues: [
                    .init(
                        code: .patientInactive,
                        message: "Patient is inactive and cannot be selected.",
                        failureKind: .authorization
                    )
                ]
            )
        }

        workspace.patient = command.patient
        workspaces[command.sessionId] = workspace
        return PatientSelectionResult(
            disposition: .completeSuccess,
            state: makePendingState(sessionId: command.sessionId, workspace: workspace)
        )
    }

    public func submitSessionCapture(
        _ command: SubmitSessionCaptureCommand
    ) async -> CaptureSubmissionResult {
        guard var workspace = workspaces[command.sessionId] else {
            return CaptureSubmissionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [
                    .init(
                        code: .sessionNotFound,
                        message: "Session was not started before capture submission.",
                        failureKind: .state
                    )
                ]
            )
        }
        guard command.capture.isUsable else {
            return CaptureSubmissionResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [
                    .init(
                        code: .captureIncomplete,
                        message: "Capture input must include seeded text or a local audio file reference.",
                        failureKind: .validation
                    )
                ]
            )
        }
        if command.capture.mode == .localAudioFile,
           let audioReference = command.capture.audioReference {
            let fileManager = FileManager.default
            guard fileManager.fileExists(atPath: audioReference.filePath) else {
                return CaptureSubmissionResult(
                    disposition: .operationalFailure,
                    state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                    issues: [
                        .init(
                            code: .captureAudioFileMissing,
                            message: "Selected local audio file is no longer available at \(audioReference.filePath).",
                            failureKind: .dependency
                        )
                    ]
                )
            }
            guard fileManager.isReadableFile(atPath: audioReference.filePath) else {
                return CaptureSubmissionResult(
                    disposition: .operationalFailure,
                    state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                    issues: [
                        .init(
                            code: .captureAudioFileUnreadable,
                            message: "Selected local audio file is not readable from the current app session.",
                            failureKind: .dependency
                        )
                    ]
                )
            }
        }

        workspace.capture = command.capture
        workspaces[command.sessionId] = workspace
        return CaptureSubmissionResult(
            disposition: .completeSuccess,
            state: makePendingState(sessionId: command.sessionId, workspace: workspace)
        )
    }

    public func requestDraftRefresh(
        _ command: RequestDraftRefreshCommand
    ) async -> DraftStateResult {
        guard let workspace = workspaces[command.sessionId] else {
            return DraftStateResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [
                    .init(
                        code: .sessionNotFound,
                        message: "Session was not started before draft refresh.",
                        failureKind: .state
                    )
                ]
            )
        }
        guard workspace.patient != nil, workspace.capture != nil else {
            return DraftStateResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [
                    .init(
                        code: .captureIncomplete,
                        message: "Patient selection and capture are required before draft refresh.",
                        failureKind: .state
                    )
                ]
            )
        }

        let baseState = makePendingState(sessionId: command.sessionId, workspace: workspace)
        let draftReadyState = ScribeSessionBridgeState(
            sessionId: baseState.sessionId,
            captureMode: baseState.captureMode,
            draftState: .awaitingGate,
            gateState: .pending,
            transcriptPreview: baseState.transcriptPreview,
            draftPreview: previewDraftText(for: workspace.capture),
            transcription: baseState.transcription,
            retrieval: ScribeRetrievalBridgeState(
                status: .degraded,
                source: "pending-run",
                matchCount: 0,
                summary: "Pacote de contexto final ainda nao foi montado.",
                highlights: [],
                sourceItems: [],
                notice: "O first slice atual ainda produz retrieval e draft finais junto da execucao principal."
            ),
            gateReview: ScribeGateReviewBridgeState(
                state: .pending,
                requiredReviewType: .professionalDocumentReview,
                finalizationTarget: .soapNote,
                requestedAction: "finalize-soap-note",
                rationaleNote: "Revisao profissional ainda precisa confirmar o draft antes de qualquer efetivacao documental."
            ),
            finalDocument: ScribeFinalDocumentBridgeState(
                state: .awaitingGate,
                summary: "Documento final ainda nao existe; a efetivacao depende de gate humano explicito."
            ),
            runSummary: nil
        )

        return DraftStateResult(
            disposition: .degraded,
            state: draftReadyState,
            issues: [
                .init(
                    code: .draftRefreshDegraded,
                    message: "Current executable slice computes retrieval/draft finalization together with gate resolution; draft refresh remains a degraded preview state until gate resolution command runs."
                )
            ]
        )
    }

    public func resolveGate(_ command: ResolveGateCommand) async -> GateResolutionResult {
        guard let workspace = workspaces[command.sessionId] else {
            return GateResolutionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [
                    .init(
                        code: .sessionNotFound,
                        message: "Session was not started before gate resolution.",
                        failureKind: .state
                    )
                ]
            )
        }
        guard let patient = workspace.patient else {
            return GateResolutionResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [
                    .init(
                        code: .patientMissing,
                        message: "Patient selection is required before gate resolution.",
                        failureKind: .state
                    )
                ]
            )
        }
        guard let capture = workspace.capture else {
            return GateResolutionResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [
                    .init(
                        code: .captureMissing,
                        message: "Capture submission is required before gate resolution.",
                        failureKind: .state
                    )
                ]
            )
        }

        do {
            let runInput = FirstSliceSessionInput(
                professional: workspace.professional,
                patient: patient,
                service: workspace.service,
                capture: capture,
                gateApprove: command.approve
            )
            let runResult = try await runner.run(input: runInput)
            let bridgeState = makeCompletedState(from: runResult, sessionId: command.sessionId)
            let issues = completionIssues(from: runResult)
            workspaces.removeValue(forKey: command.sessionId)
            let disposition = completionDisposition(for: runResult)
            return GateResolutionResult(
                disposition: disposition,
                state: bridgeState,
                issues: issues
            )
        } catch {
            return GateResolutionResult(
                disposition: .operationalFailure,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: issues(for: error)
            )
        }
    }

    private func makePendingState(
        sessionId: UUID,
        workspace: SessionWorkspace? = nil
    ) -> ScribeSessionBridgeState {
        let transcriptPreview = workspace?.capture.map { String($0.previewText.prefix(160)) } ?? ""
        return ScribeSessionBridgeState(
            sessionId: sessionId,
            captureMode: workspace?.capture?.mode,
            draftState: .empty,
            gateState: .none,
            transcriptPreview: transcriptPreview,
            draftPreview: "",
            transcription: pendingTranscriptionState(for: workspace?.capture),
            retrieval: ScribeRetrievalBridgeState(
                status: .degraded,
                source: "pending-run",
                matchCount: 0,
                summary: "Contexto bounded ainda nao executado.",
                highlights: [],
                sourceItems: [],
                notice: "A montagem de contexto estruturado aparece quando o spine executa retrieval local."
            ),
            gateReview: ScribeGateReviewBridgeState(state: .none),
            finalDocument: ScribeFinalDocumentBridgeState(
                state: .none,
                summary: "Nenhum documento final foi efetivado nesta sessao."
            ),
            runSummary: nil
        )
    }

    private func makeCompletedState(
        from result: FirstSliceRunResult,
        sessionId: UUID
    ) -> ScribeSessionBridgeState {
        let gateState = gateState(for: result.gate.resolution.resolution)
        let draftState = draftState(for: result.gate.reviewedDraftStatus)
        let transcriptPreview = String(result.transcription.workflowText.prefix(200))
        let draftPreview = result.draft.soapDraft.sections.previewText

        let retrievalStatus: ScribeRetrievalStatus
        switch result.retrieval.status {
        case .ready:
            retrievalStatus = .ready
        case .partial:
            retrievalStatus = .partial
        case .empty:
            retrievalStatus = .empty
        case .degraded:
            retrievalStatus = .degraded
        }
        let retrievalHighlights = result.retrieval.highlights.map {
            "\($0.headline): \($0.summary)"
        }
        let retrievalSources = Array(Set(result.retrieval.highlights.map(\.sourceRef))).sorted()
        let finalDocument = makeFinalDocumentState(from: result)

        return ScribeSessionBridgeState(
            sessionId: sessionId,
            captureMode: result.summary.captureMode,
            draftState: draftState,
            gateState: gateState,
            transcriptPreview: transcriptPreview,
            draftPreview: draftPreview,
            transcription: completedTranscriptionState(from: result.transcription),
            retrieval: ScribeRetrievalBridgeState(
                status: retrievalStatus,
                source: result.retrieval.boundedResult.source,
                matchCount: result.retrieval.supportingMatches.count,
                summary: result.retrieval.summary,
                highlights: retrievalHighlights,
                sourceItems: retrievalSources,
                notice: result.retrieval.notice
            ),
            gateReview: ScribeGateReviewBridgeState(
                state: gateState,
                requiredReviewType: result.gate.request.requiredReviewType,
                finalizationTarget: result.gate.request.finalizationTarget,
                requestedAction: result.gate.request.requestedAction,
                rationaleNote: result.gate.resolution.rationaleNote ?? result.gate.request.rationaleNote,
                reviewedAt: result.gate.resolution.reviewedAt,
                resolverRole: result.gate.resolution.resolverRole
            ),
            finalDocument: finalDocument,
            runSummary: result.summary
        )
    }

    private func pendingTranscriptionState(
        for capture: SessionCaptureInput?
    ) -> ScribeTranscriptionBridgeState {
        guard let capture else {
            return ScribeTranscriptionBridgeState(status: .pending, source: "not-started")
        }

        switch capture.mode {
        case .seededText:
            return ScribeTranscriptionBridgeState(status: .ready, source: "seeded-text")
        case .localAudioFile:
            return ScribeTranscriptionBridgeState(
                status: .pending,
                source: "pending-run",
                audioDisplayName: capture.audioReference?.displayName
            )
        }
    }

    private func completedTranscriptionState(
        from output: TranscriptionOutput
    ) -> ScribeTranscriptionBridgeState {
        ScribeTranscriptionBridgeState(
            status: output.status,
            source: output.source,
            audioDisplayName: output.audioCapture?.reference.displayName,
            issueMessage: output.issueMessage
        )
    }

    private func completionDisposition(for result: FirstSliceRunResult) -> HealthOSCommandDisposition {
        if result.gate.approved, result.finalDocument == nil {
            return .operationalFailure
        }

        if !result.gate.approved {
            return .governedDeny
        }

        if result.transcription.status == .degraded || result.transcription.status == .unavailable || result.retrieval.status == .degraded {
            return .degraded
        }

        switch result.retrieval.status {
        case .ready:
            return .completeSuccess
        case .partial, .empty:
            return .partialSuccess
        case .degraded:
            return .degraded
        }
    }

    private func completionIssues(from result: FirstSliceRunResult) -> [HealthOSIssue] {
        var issues: [HealthOSIssue] = []

        if !result.gate.approved {
            issues.append(
                .init(
                    code: .gateRejected,
                    message: result.gate.resolution.rationaleNote
                        ?? "The professional gate rejected document finalization for the current draft."
                )
            )
        }

        switch result.transcription.status {
        case .degraded:
            issues.append(
                .init(
                    code: .transcriptionDegraded,
                    message: result.transcription.issueMessage
                        ?? "Transcription completed in degraded mode for the current capture."
                )
            )
        case .unavailable:
            issues.append(
                .init(
                    code: .transcriptionUnavailable,
                    message: result.transcription.issueMessage
                        ?? "Transcription was unavailable for the current capture."
                )
            )
        case .pending, .ready:
            break
        }

        switch result.retrieval.status {
        case .degraded:
            issues.append(
                .init(
                    code: .retrievalDegraded,
                    message: result.retrieval.notice
                        ?? "Bounded retrieval was degraded and did not yield a clinically reliable context package."
                )
            )
        case .partial:
            issues.append(
                .init(
                    code: .retrievalPartial,
                    message: result.retrieval.notice
                        ?? "Bounded retrieval returned only a partial local context package."
                )
            )
        case .empty:
            issues.append(
                .init(
                    code: .retrievalEmpty,
                    message: result.retrieval.notice
                        ?? "No bounded context matches were found for the current capture."
                )
            )
        case .ready:
            break
        }

        return issues
    }

    private func previewDraftText(for capture: SessionCaptureInput?) -> String {
        guard let capture else { return "" }

        switch capture.mode {
        case .seededText:
            let subjective = capture.normalizedText ?? ""
            return SOAPNoteSections(
                subjective: subjective,
                objective: "Contexto final ainda nao foi consolidado no spine executavel.",
                assessment: "Preview de draft aguardando revisao profissional e retrieval final.",
                plan: "Finalizacao documental ainda nao efetivada."
            )
            .previewText
        case .localAudioFile:
            let displayName = capture.audioReference?.displayName ?? "audio local"
            return SOAPNoteSections(
                subjective: "Captura local selecionada: \(displayName)",
                objective: "Transcript e contexto final ainda nao foram montados.",
                assessment: "Preview de draft aguarda transcription/local retrieval completos.",
                plan: "Gate humano continua necessario para qualquer documento efetivado."
            )
            .previewText
        }
    }

    private func gateState(for resolution: GateResolutionKind) -> ScribeGateState {
        switch resolution {
        case .approved:
            return .approved
        case .rejected:
            return .rejected
        case .cancelled:
            return .cancelled
        }
    }

    private func draftState(for status: DraftStatus) -> ScribeDraftState {
        switch status {
        case .approved:
            return .approved
        case .rejected, .superseded:
            return .rejected
        case .awaitingGate:
            return .awaitingGate
        case .draft:
            return .ready
        }
    }

    private func makeFinalDocumentState(from result: FirstSliceRunResult) -> ScribeFinalDocumentBridgeState {
        if let finalDocument = result.finalDocument {
            return ScribeFinalDocumentBridgeState(
                state: .finalized,
                status: finalDocument.document.status,
                summary: finalDocument.document.summary,
                objectPath: finalDocument.documentRef.objectPath,
                finalizedAt: finalDocument.document.finalization.finalizedAt,
                sourceDraftId: finalDocument.document.source.sourceDraftId,
                gateResolutionId: finalDocument.document.source.gateResolutionId
            )
        }

        return ScribeFinalDocumentBridgeState(
            state: .withheld,
            summary: "Documento final nao foi persistido porque o gate documental nao aprovou a efetivacao.",
            sourceDraftId: result.draft.draft.id,
            gateResolutionId: result.gate.resolution.id
        )
    }

    private func issues(for error: Error) -> [HealthOSIssue] {
        if let firstSliceError = error as? FirstSliceError {
            switch firstSliceError {
            case .audioCaptureFileMissing(let path):
                return [
                    .init(
                        code: .captureAudioFileMissing,
                        message: "Selected local audio file is missing at \(path).",
                        failureKind: .dependency
                    )
                ]
            case .audioCaptureFileUnreadable(let path):
                return [
                    .init(
                        code: .captureAudioFileUnreadable,
                        message: "Selected local audio file could not be read at \(path).",
                        failureKind: .dependency
                    )
                ]
            default:
                break
            }
        }

        return [
            .init(
                code: .spineExecutionFailed,
                message: "First slice execution failed: \(error.localizedDescription)",
                failureKind: .internalFailure
            )
        ]
    }
}
