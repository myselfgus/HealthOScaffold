import Foundation
import HealthOSCore
import HealthOSProviders

public actor AACIOrchestrator {
    private let router: ProviderRouter

    public init(router: ProviderRouter) {
        self.router = router
    }

    public func startSession(_ session: SessaoTrabalho) async -> String {
        let decision = await router.route(taskKind: "session-start")
        return "AACI session \(session.id.uuidString) started via \(decision.providerName)"
    }

    public func composeSOAPDraft(session: SessaoTrabalho, transcript: String, context: [String]) async -> ArtifactDraft {
        let payload = [
            "subjective": transcript,
            "objective": context.joined(separator: "\n"),
            "assessment": "TODO",
            "plan": "TODO"
        ]
        return ArtifactDraft(sessionId: session.id, kind: "soap", payload: payload)
    }
}

public struct CaptureAgent: HealthAgent {
    public let actorId = "aaci.capture"
    public let runtimeKind: RuntimeKind = .aaci
    public let permissions = ["session:read", "capture:write"]
    public let boundaryDescription = "Receives session input and emits capture events"

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct TranscriptionAgent: HealthAgent {
    public let actorId = "aaci.transcription"
    public let runtimeKind: RuntimeKind = .aaci
    public let permissions = ["capture:read", "transcript:write"]
    public let boundaryDescription = "Receives audio refs and emits transcript events"

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct ContextRetrievalAgent: HealthAgent {
    public let actorId = "aaci.context"
    public let runtimeKind: RuntimeKind = .aaci
    public let permissions = ["patient:context:read", "consent:check"]
    public let boundaryDescription = "Retrieves bounded patient/service context"

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}
