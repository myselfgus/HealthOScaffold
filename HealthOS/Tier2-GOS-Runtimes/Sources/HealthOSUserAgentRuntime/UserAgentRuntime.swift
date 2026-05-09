// User-Agent Runtime — patient/user-side session lifecycle and sovereignty enforcement.
// Subordinate to Core law. Not constitutional authority. Not consent law.
// See: HealthOSCore/UserSovereigntyContracts.swift, HealthOS/Shared/docs/architecture/41-user-agent-runtime.md (planned)
//
// SCAFFOLD: implement user-sovereign session surface, consent execution, and audit trail.
import Foundation
import HealthOSCore
import HealthOSProviders

public enum UserAgentRuntime {
    public static let runtimeKind = RuntimeKind.userAgent
}

public enum PersonalAgentRuntimeLifecycleState: String, Codable, Sendable {
    case active
    case suspended
    case terminated
    case failed
}

public enum PersonalAgentRuntimeFailure: Error, LocalizedError, Sendable, Equatable {
    case nonPersonalAgent(GovernedAIAgentKind)
    case sessionNotFound(UUID)
    case sessionTerminated(UUID)
    case agentMismatch(expected: AgentID, actualFrom: AgentID, actualTo: AgentID)
    case offlineResponseNotAllowed(AgentID)

    public var errorDescription: String? {
        switch self {
        case .nonPersonalAgent(let kind):
            return "PersonalAgentRuntime only starts personal agents; got \(kind.rawValue)."
        case .sessionNotFound(let sessionId):
            return "Personal agent session \(sessionId.uuidString) was not found."
        case .sessionTerminated(let sessionId):
            return "Personal agent session \(sessionId.uuidString) is terminated."
        case .agentMismatch(let expected, let actualFrom, let actualTo):
            return "Envelope does not involve expected agent \(expected.rawValue); from=\(actualFrom.rawValue), to=\(actualTo.rawValue)."
        case .offlineResponseNotAllowed(let agentId):
            return "Agent \(agentId.rawValue) is not allowed to queue offline responses."
        }
    }
}

public struct PersonalAgentSessionRecord: Codable, Sendable, Equatable {
    public let sessionId: UUID
    public let agentId: AgentID
    public let agentKind: GovernedAIAgentKind
    public let representedPrincipal: AgentPrincipalRef
    public let mandateId: UUID
    public let memoryScopeId: UUID
    public let lifecycleState: PersonalAgentRuntimeLifecycleState
    public let offlineResponseAllowed: Bool
    public let createdAt: Date
    public let updatedAt: Date
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        sessionId: UUID = UUID(),
        agentId: AgentID,
        agentKind: GovernedAIAgentKind,
        representedPrincipal: AgentPrincipalRef,
        mandateId: UUID,
        memoryScopeId: UUID,
        lifecycleState: PersonalAgentRuntimeLifecycleState,
        offlineResponseAllowed: Bool,
        createdAt: Date = .now,
        updatedAt: Date = .now,
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = []
    ) {
        self.sessionId = sessionId
        self.agentId = agentId
        self.agentKind = agentKind
        self.representedPrincipal = representedPrincipal
        self.mandateId = mandateId
        self.memoryScopeId = memoryScopeId
        self.lifecycleState = lifecycleState
        self.offlineResponseAllowed = offlineResponseAllowed
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public struct PersonalAgentQueuedTask: Codable, Sendable, Equatable {
    public let taskId: UUID
    public let sessionId: UUID
    public let envelopeId: UUID
    public let agentId: AgentID
    public let status: String
    public let safeSubjectRefs: [String]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        taskId: UUID = UUID(),
        sessionId: UUID,
        envelopeId: UUID,
        agentId: AgentID,
        status: String,
        safeSubjectRefs: [String],
        provenanceRefs: [UUID],
        auditRefs: [UUID]
    ) {
        self.taskId = taskId
        self.sessionId = sessionId
        self.envelopeId = envelopeId
        self.agentId = agentId
        self.status = status
        self.safeSubjectRefs = safeSubjectRefs
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public struct PersonalAgentRuntimeResponse: Codable, Sendable, Equatable {
    public let envelopeId: UUID
    public let sessionId: UUID
    public let responderAgentId: AgentID
    public let disposition: UserAgentDataDisposition
    public let message: String
    public let providerDecision: String
    public let degradedState: String?
    public let legalAuthorizing: Bool
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        envelopeId: UUID,
        sessionId: UUID,
        responderAgentId: AgentID,
        disposition: UserAgentDataDisposition,
        message: String,
        providerDecision: String,
        degradedState: String?,
        legalAuthorizing: Bool = false,
        provenanceRefs: [UUID],
        auditRefs: [UUID]
    ) {
        self.envelopeId = envelopeId
        self.sessionId = sessionId
        self.responderAgentId = responderAgentId
        self.disposition = disposition
        self.message = message
        self.providerDecision = providerDecision
        self.degradedState = degradedState
        self.legalAuthorizing = legalAuthorizing
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public actor PersonalAgentRuntime {
    private var sessions: [UUID: PersonalAgentSessionRecord] = [:]
    private var descriptors: [AgentID: GovernedAIAgentDescriptor] = [:]
    private let providerRouter: ProviderRouter?

    public init(providerRouter: ProviderRouter? = nil) {
        self.providerRouter = providerRouter
    }

    @discardableResult
    public func start(descriptor: GovernedAIAgentDescriptor) throws -> PersonalAgentSessionRecord {
        try GovernedAIAgentValidator.validateDescriptor(descriptor)
        guard descriptor.kind.isPersonalAgent else {
            throw PersonalAgentRuntimeFailure.nonPersonalAgent(descriptor.kind)
        }

        let provenanceRef = UUID()
        let auditRef = UUID()
        let record = PersonalAgentSessionRecord(
            agentId: descriptor.agentId,
            agentKind: descriptor.kind,
            representedPrincipal: descriptor.representedPrincipal,
            mandateId: descriptor.mandate.mandateId,
            memoryScopeId: descriptor.memoryScope.scopeId,
            lifecycleState: .active,
            offlineResponseAllowed: descriptor.delegationPolicy.allowsAsyncOfflineResponse,
            provenanceRefs: [provenanceRef],
            auditRefs: [auditRef]
        )
        sessions[record.sessionId] = record
        descriptors[descriptor.agentId] = descriptor
        return record
    }

    public func session(_ sessionId: UUID) -> PersonalAgentSessionRecord? {
        sessions[sessionId]
    }

    public func handle(
        _ envelope: AgentNegotiationEnvelope,
        sessionId: UUID
    ) async throws -> PersonalAgentRuntimeResponse {
        let record = try activeSession(sessionId)
        let descriptor = descriptors[record.agentId]
        try ensureEnvelopeInvolvesRuntimeAgent(envelope, agentId: record.agentId)
        _ = try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope, mandate: descriptor?.mandate)

        let providerDecision = await routeProviderIfConfigured(envelope)
        let provenanceRefs = envelope.provenanceRefs.isEmpty ? [UUID()] : envelope.provenanceRefs
        let auditRefs = envelope.auditRefs.isEmpty ? [UUID()] : envelope.auditRefs

        let response = PersonalAgentRuntimeResponse(
            envelopeId: envelope.envelopeId,
            sessionId: sessionId,
            responderAgentId: record.agentId,
            disposition: .informationalUserFacing,
            message: "personal-agent-policy-mediated",
            providerDecision: providerDecision.description,
            degradedState: providerDecision.degradedState,
            provenanceRefs: provenanceRefs,
            auditRefs: auditRefs
        )
        try UserAgentGovernanceValidator.validateResponse(
            UserAgentResponse(
                requestId: envelope.envelopeId,
                disposition: response.disposition,
                message: response.message,
                provenanceRefs: response.provenanceRefs,
                auditRefs: response.auditRefs
            )
        )
        return response
    }

    public func enqueueOfflineResponse(
        _ envelope: AgentNegotiationEnvelope,
        sessionId: UUID
    ) throws -> PersonalAgentQueuedTask {
        let record = try activeSession(sessionId)
        let descriptor = descriptors[record.agentId]
        guard record.offlineResponseAllowed else {
            throw PersonalAgentRuntimeFailure.offlineResponseNotAllowed(record.agentId)
        }
        try ensureEnvelopeInvolvesRuntimeAgent(envelope, agentId: record.agentId)
        _ = try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope, mandate: descriptor?.mandate)
        return PersonalAgentQueuedTask(
            sessionId: sessionId,
            envelopeId: envelope.envelopeId,
            agentId: record.agentId,
            status: "queued-for-policy-mediated-dispatch",
            safeSubjectRefs: envelope.safeSubjectRefs,
            provenanceRefs: envelope.provenanceRefs.isEmpty ? [UUID()] : envelope.provenanceRefs,
            auditRefs: envelope.auditRefs.isEmpty ? [UUID()] : envelope.auditRefs
        )
    }

    public func terminate(sessionId: UUID) throws {
        let record = try activeSession(sessionId)
        sessions[sessionId] = PersonalAgentSessionRecord(
            sessionId: record.sessionId,
            agentId: record.agentId,
            agentKind: record.agentKind,
            representedPrincipal: record.representedPrincipal,
            mandateId: record.mandateId,
            memoryScopeId: record.memoryScopeId,
            lifecycleState: .terminated,
            offlineResponseAllowed: record.offlineResponseAllowed,
            createdAt: record.createdAt,
            updatedAt: .now,
            provenanceRefs: record.provenanceRefs + [UUID()],
            auditRefs: record.auditRefs + [UUID()]
        )
    }

    private func activeSession(_ sessionId: UUID) throws -> PersonalAgentSessionRecord {
        guard let record = sessions[sessionId] else {
            throw PersonalAgentRuntimeFailure.sessionNotFound(sessionId)
        }
        guard record.lifecycleState != .terminated else {
            throw PersonalAgentRuntimeFailure.sessionTerminated(sessionId)
        }
        return record
    }

    private func ensureEnvelopeInvolvesRuntimeAgent(
        _ envelope: AgentNegotiationEnvelope,
        agentId: AgentID
    ) throws {
        if envelope.fromAgentId != agentId && envelope.toAgentId != agentId {
            throw PersonalAgentRuntimeFailure.agentMismatch(
                expected: agentId,
                actualFrom: envelope.fromAgentId,
                actualTo: envelope.toAgentId
            )
        }
    }

    private func routeProviderIfConfigured(_ envelope: AgentNegotiationEnvelope) async -> ProviderDecisionSummary {
        guard let providerRouter else {
            return ProviderDecisionSummary(description: "provider-routing-not-configured", degradedState: "provider-routing-unavailable")
        }
        let routeLayer = envelope.requestedDataLayers.first(where: {
            $0 != .directIdentifiers && $0 != .reidentificationMapping
        }) ?? .derivedArtifacts
        let request = ProviderRoutingRequest(
            taskClass: .languageModel,
            dataLayer: routeLayer,
            lawfulContext: envelope.lawfulContext,
            finalidade: envelope.lawfulContext["finalidade"] ?? envelope.intent.rawValue,
            allowsRemoteFallback: envelope.providerPolicy.allowsExternalProvider,
            allowsRemoteForOperationalSensitiveContent: envelope.providerPolicy.allowsOperationalSensitiveExternal,
            fallbackAllowed: true,
            preferLocal: envelope.providerPolicy.preferLocal
        )
        return ProviderDecisionSummary(await providerRouter.routeLanguage(request: request))
    }
}

private struct ProviderDecisionSummary: Sendable {
    let description: String
    let degradedState: String?

    init(description: String, degradedState: String?) {
        self.description = description
        self.degradedState = degradedState
    }

    init(_ decision: ProviderRoutingDecision) {
        switch decision {
        case .selected(let selection):
            self.description = "selected:\(selection.providerId)"
            self.degradedState = nil
        case .degradedFallback(let selection, let reason):
            self.description = "degraded-fallback:\(selection.providerId):\(reason.rawValue)"
            self.degradedState = reason.rawValue
        case .deniedByPolicy(let reason):
            self.description = "denied-by-policy:\(reason.rawValue)"
            self.degradedState = reason.rawValue
        case .unavailable(let reason):
            self.description = "unavailable:\(reason.rawValue)"
            self.degradedState = reason.rawValue
        case .stubOnly(let selection, let reason):
            self.description = "stub-only:\(selection.providerId):\(reason.rawValue)"
            self.degradedState = reason.rawValue
        }
    }
}
