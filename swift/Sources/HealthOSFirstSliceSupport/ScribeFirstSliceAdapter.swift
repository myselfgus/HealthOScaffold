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
            draftState: .awaitingGate,
            gateState: .pending,
            transcriptPreview: baseState.transcriptPreview,
            draftPreview: baseState.draftPreview,
            retrieval: ScribeRetrievalBridgeState(
                status: .degraded,
                source: "pending-run",
                matchCount: 0,
                previewItems: []
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
            workspaces.removeValue(forKey: command.sessionId)
            let disposition: HealthOSCommandDisposition = runResult.gate.approved
                ? .completeSuccess
                : .governedDeny
            return GateResolutionResult(disposition: disposition, state: bridgeState)
        } catch {
            return GateResolutionResult(
                disposition: .operationalFailure,
                state: makePendingState(sessionId: command.sessionId, workspace: workspace),
                issues: [
                    .init(
                        code: .spineExecutionFailed,
                        message: "First slice execution failed: \(error.localizedDescription)",
                        failureKind: .internalFailure
                    )
                ]
            )
        }
    }

    private func makePendingState(
        sessionId: UUID,
        workspace: SessionWorkspace? = nil
    ) -> ScribeSessionBridgeState {
        let transcriptPreview = workspace?.capture.map { String($0.rawText.prefix(120)) } ?? ""
        return ScribeSessionBridgeState(
            sessionId: sessionId,
            draftState: workspace?.capture == nil ? .empty : .ready,
            gateState: .none,
            transcriptPreview: transcriptPreview,
            draftPreview: "",
            retrieval: ScribeRetrievalBridgeState(
                status: .degraded,
                source: "pending-run",
                matchCount: 0,
                previewItems: []
            ),
            runSummary: nil
        )
    }

    private func makeCompletedState(
        from result: FirstSliceRunResult,
        sessionId: UUID
    ) -> ScribeSessionBridgeState {
        let gateState: ScribeGateState = result.gate.approved ? .approved : .rejected
        let draftState: ScribeDraftState = result.gate.approved ? .approved : .rejected
        let transcriptPreview = String(result.transcription.transcriptText.prefix(160))
        let draftPreview = [
            result.draft.draft.payload["subjective"] ?? "",
            result.draft.draft.payload["assessment"] ?? ""
        ]
        .filter { !$0.isEmpty }
        .joined(separator: " | ")

        let retrievalStatus: ScribeRetrievalStatus = result.retrieval.boundedResult.isFallbackEmpty
            ? .empty
            : .ready
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
