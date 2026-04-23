import Foundation

public enum ScribeDraftState: String, Codable, Sendable {
    case empty
    case ready
    case awaitingGate = "awaiting_gate"
    case approved
    case rejected
}

public enum ScribeGateState: String, Codable, Sendable {
    case none
    case pending
    case approved
    case rejected
}

public struct ScribeSessionBridgeState: Codable, Sendable {
    public let sessionId: UUID
    public let draftState: ScribeDraftState
    public let gateState: ScribeGateState
    public let transcriptPreview: String
    public let draftPreview: String
    public let runSummary: SliceRunSummary

    public init(
        sessionId: UUID,
        draftState: ScribeDraftState,
        gateState: ScribeGateState,
        transcriptPreview: String,
        draftPreview: String,
        runSummary: SliceRunSummary
    ) {
        self.sessionId = sessionId
        self.draftState = draftState
        self.gateState = gateState
        self.transcriptPreview = transcriptPreview
        self.draftPreview = draftPreview
        self.runSummary = runSummary
    }
}

public protocol ScribeFirstSliceFacade: Sendable {
    func startSession(input: FirstSliceSessionInput) async throws -> ScribeSessionBridgeState
}
