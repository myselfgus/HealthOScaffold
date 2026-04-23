import Foundation
import HealthOSCore

actor ScribeFirstSliceAdapter: ScribeFirstSliceFacade {
    private struct SessionWorkspace {
        let professional: Usuario
        let service: Servico
        var patient: Usuario?
        var capture: SessionCaptureInput?
        var runResult: FirstSliceRunResult?
    }

    private let runner: FirstSliceRunner
    private var workspaces: [UUID: SessionWorkspace] = [:]

    init(runner: FirstSliceRunner) {
        self.runner = runner
    }

    func startProfessionalSession(_ command: StartProfessionalSessionCommand) async -> SessionStartResult {
        guard command.professional.active else {
            return SessionStartResult(
                disposition: .governedDeny,
                state: nil,
                issues: [.init(code: "habilitation.inactive_professional", message: "Professional user is inactive and cannot open a session.")]
            )
        }
        guard !command.service.nome.isEmpty else {
            return SessionStartResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [.init(code: "service.invalid", message: "Service name is required to open a session.")]
            )
        }

        let sessionId = UUID()
        workspaces[sessionId] = SessionWorkspace(professional: command.professional, service: command.service)
        return SessionStartResult(disposition: .completeSuccess, state: makePendingState(sessionId: sessionId))
    }

    func selectPatient(_ command: SelectPatientCommand) async -> PatientSelectionResult {
        guard var workspace = workspaces[command.sessionId] else {
            return PatientSelectionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [.init(code: "session.not_found", message: "Session was not started before patient selection.")]
            )
        }
        guard command.patient.active else {
            return PatientSelectionResult(
                disposition: .governedDeny,
                state: makePendingState(sessionId: command.sessionId),
                issues: [.init(code: "consent.inactive_patient", message: "Patient is inactive and cannot be selected.")]
            )
        }

        workspace.patient = command.patient
        workspaces[command.sessionId] = workspace
        return PatientSelectionResult(disposition: .completeSuccess, state: makePendingState(sessionId: command.sessionId, workspace: workspace))
    }

    func submitSessionCapture(_ command: SubmitSessionCaptureCommand) async -> CaptureSubmissionResult {
        guard var workspace = workspaces[command.sessionId] else {
            return CaptureSubmissionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [.init(code: "session.not_found", message: "Session was not started before capture submission.")]
            )
        }

        workspace.capture = command.capture
        workspaces[command.sessionId] = workspace
        let baseState = makePendingState(sessionId: command.sessionId, workspace: workspace)
        return CaptureSubmissionResult(disposition: .completeSuccess, state: baseState)
    }

    func requestDraftRefresh(_ command: RequestDraftRefreshCommand) async -> DraftStateResult {
        guard let workspace = workspaces[command.sessionId] else {
            return DraftStateResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [.init(code: "session.not_found", message: "Session was not started before draft refresh.")]
            )
        }
        guard workspace.patient != nil, workspace.capture != nil else {
            return DraftStateResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [.init(code: "capture.incomplete", message: "Patient selection and capture are required before draft refresh.")]
            )
        }

        var draftReadyState = makePendingState(sessionId: command.sessionId, workspace: workspace)
        draftReadyState = ScribeSessionBridgeState(
            sessionId: draftReadyState.sessionId,
            draftState: .awaitingGate,
            gateState: .pending,
            transcriptPreview: draftReadyState.transcriptPreview,
            draftPreview: draftReadyState.draftPreview,
            retrieval: ScribeRetrievalBridgeState(status: .degraded, source: "pending-run", matchCount: 0, previewItems: []),
            runSummary: nil
        )

        return DraftStateResult(
            disposition: .degraded,
            state: draftReadyState,
            issues: [
                .init(
                    code: "draft.refresh.degraded",
                    message: "Current executable slice computes retrieval/draft finalization together with gate resolution; draft refresh remains a degraded preview state until gate resolution command runs."
                )
            ]
        )
    }

    func resolveGate(_ command: ResolveGateCommand) async -> GateResolutionResult {
        guard var workspace = workspaces[command.sessionId] else {
            return GateResolutionResult(
                disposition: .operationalFailure,
                state: nil,
                issues: [.init(code: "session.not_found", message: "Session was not started before gate resolution.")]
            )
        }
        guard let patient = workspace.patient else {
            return GateResolutionResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [.init(code: "patient.missing", message: "Patient selection is required before gate resolution.")]
            )
        }
        guard let capture = workspace.capture else {
            return GateResolutionResult(
                disposition: .partialSuccess,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [.init(code: "capture.missing", message: "Capture submission is required before gate resolution.")]
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
            workspace.runResult = runResult
            workspaces[command.sessionId] = workspace

            let bridgeState = makeCompletedState(from: runResult, sessionId: command.sessionId)
            let disposition: FirstSliceCommandDisposition = runResult.gate.approved ? .completeSuccess : .governedDeny
            return GateResolutionResult(disposition: disposition, state: bridgeState)
        } catch {
            return GateResolutionResult(
                disposition: .operationalFailure,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [.init(code: "spine.execution_failed", message: "First slice execution failed: \(error.localizedDescription)")]
            )
        }
    }

    private func makePendingState(sessionId: UUID, workspace: SessionWorkspace? = nil) -> ScribeSessionBridgeState {
        let transcriptPreview = workspace?.capture.map { String($0.rawText.prefix(120)) } ?? ""
        return ScribeSessionBridgeState(
            sessionId: sessionId,
            draftState: workspace?.capture == nil ? .empty : .ready,
            gateState: .none,
            transcriptPreview: transcriptPreview,
            draftPreview: "",
            retrieval: ScribeRetrievalBridgeState(status: .degraded, source: "pending-run", matchCount: 0, previewItems: []),
            runSummary: nil
        )
    }

    private func makeCompletedState(from result: FirstSliceRunResult, sessionId: UUID) -> ScribeSessionBridgeState {
        let gateState: ScribeGateState = result.gate.approved ? .approved : .rejected
        let draftState: ScribeDraftState = result.gate.approved ? .approved : .rejected
        let transcriptPreview = String(result.transcription.transcriptText.prefix(160))
        let draftPreview = [
            result.draft.draft.payload["subjective"] ?? "",
            result.draft.draft.payload["assessment"] ?? ""
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " | ")

        let retrievalStatus: ScribeRetrievalStatus = result.retrieval.boundedResult.isFallbackEmpty ? .empty : .ready
        let retrievalPreview = Array(result.retrieval.contextItems.prefix(3))

        return ScribeSessionBridgeState(
            sessionId: sessionId,
            draftState: draftState,
            gateState: gateState,
            transcriptPreview: transcriptPreview,
            draftPreview: draftPreview,
            retrieval: ScribeRetrievalBridgeState(
                status: retrievalStatus,
                source: result.retrieval.boundedResult.source,
                matchCount: result.retrieval.boundedResult.matches.count,
                previewItems: retrievalPreview
            ),
            runSummary: result.summary
        )
    }
}
