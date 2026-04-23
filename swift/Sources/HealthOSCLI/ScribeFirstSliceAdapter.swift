import Foundation
import HealthOSCore

actor ScribeFirstSliceAdapter: ScribeFirstSliceFacade {
    private let runner: FirstSliceRunner

    init(runner: FirstSliceRunner) {
        self.runner = runner
    }

    func startSession(input: FirstSliceSessionInput) async throws -> ScribeSessionBridgeState {
        let result = try await runner.run(input: input)
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
            sessionId: result.session.id,
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
