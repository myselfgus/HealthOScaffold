import Foundation
import HealthOSCore

public enum AgentProtocolBoundaryFailure: Error, LocalizedError, Sendable, Equatable {
    case unsupportedLegalAuthorization
    case unsafeProtocolProjection(String)

    public var errorDescription: String? {
        switch self {
        case .unsupportedLegalAuthorization:
            return "Agent protocol boundary cannot expose legal-authorizing projections."
        case .unsafeProtocolProjection(let detail):
            return "Agent protocol boundary projection is unsafe: \(detail)."
        }
    }
}

public enum AgentProtocolBoundary {
    public static func project(
        _ envelope: AgentNegotiationEnvelope,
        to protocolKind: AgentProtocolKind
    ) throws -> AgentProtocolProjection {
        _ = try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope)

        let degradedState: String?
        switch protocolKind {
        case .healthosAACP:
            degradedState = nil
        case .a2a:
            degradedState = envelope.protocolHints.contains(.a2a) ? nil : "a2a-adapter-requested-without-source-hint"
        case .acp:
            degradedState = "acp-ui-adapter-future"
        }

        let projection = AgentProtocolProjection(
            protocolKind: protocolKind,
            taskId: envelope.taskRef ?? envelope.envelopeId.uuidString,
            fromAgentId: envelope.fromAgentId,
            toAgentId: envelope.toAgentId,
            intent: envelope.intent,
            safeSubjectRefs: envelope.safeSubjectRefs,
            artifactRefs: envelope.ephemeralGrantRef.map { [$0.grantSafeRef] } ?? [],
            streamAllowed: protocolKind == .a2a || protocolKind == .healthosAACP,
            degradedState: degradedState
        )
        try validateAppSafeProjection(projection)
        return projection
    }

    public static func validateAppSafeProjection(_ projection: AgentProtocolProjection) throws {
        if projection.legalAuthorizing {
            throw AgentProtocolBoundaryFailure.unsupportedLegalAuthorization
        }
        if projection.exposesInternalMemory {
            throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("internal-memory")
        }
        if projection.exposesToolImplementation {
            throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("tool-implementation")
        }
        if projection.exposesRawDirectIdentifiers {
            throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("direct-identifiers")
        }
        if projection.exposesRawStorage {
            throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("raw-storage")
        }
        if projection.exposesKeyMaterial {
            throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("key-material")
        }
        for ref in projection.safeSubjectRefs {
            let normalized = ref.lowercased()
            if normalized.contains("cpf") || normalized.contains("storage-path") || normalized.contains("reidentification") {
                throw AgentProtocolBoundaryFailure.unsafeProtocolProjection("unsafe-safe-ref")
            }
        }
    }
}
