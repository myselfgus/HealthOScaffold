import Foundation

public struct AgentID: RawRepresentable, Codable, Hashable, Sendable, ExpressibleByStringLiteral {
    public let rawValue: String

    public init(rawValue: String) {
        self.rawValue = rawValue
    }

    public init(_ rawValue: String) {
        self.rawValue = rawValue
    }

    public init(stringLiteral value: String) {
        self.rawValue = value
    }
}

public enum GovernedAIAgentKind: String, Codable, Sendable, CaseIterable {
    case patientPersonal = "patient-personal-agent"
    case professionalPersonal = "professional-personal-agent"
    case userPersonal = "user-personal-agent"

    case consentGovernance = "consent-governance-agent"
    case habilitationGovernance = "habilitation-governance-agent"
    case gateFinality = "gate-finality-agent"
    case custodyAccess = "custody-access-agent"
    case auditProvenance = "audit-provenance-agent"

    case session = "session-agent"
    case aaci = "aaci-agent"
    case msr = "msr-agent"
    case asyncJob = "async-job-agent"
    case serviceRuntime = "service-runtime-agent"
    case userAgentRuntime = "user-agent-runtime-agent"

    case providerRouter = "provider-router-agent"
    case modelGovernance = "model-governance-agent"

    case agentProtocolBoundary = "agent-protocol-boundary"
    case appSurfaceBoundary = "app-surface-boundary-agent"

    public var isPersonalAgent: Bool {
        switch self {
        case .patientPersonal, .professionalPersonal, .userPersonal:
            return true
        default:
            return false
        }
    }

    public var runtimeKind: RuntimeKind {
        switch self {
        case .consentGovernance, .habilitationGovernance, .gateFinality, .custodyAccess, .auditProvenance:
            return .core
        case .session:
            return .session
        case .aaci:
            return .aaci
        case .msr:
            return .msr
        case .asyncJob:
            return .async
        case .serviceRuntime:
            return .service
        case .userAgentRuntime, .patientPersonal, .professionalPersonal, .userPersonal:
            return .userAgent
        case .providerRouter, .modelGovernance:
            return .provider
        case .agentProtocolBoundary, .appSurfaceBoundary:
            return .boundary
        }
    }
}

public enum AgentPrincipalKind: String, Codable, Sendable, CaseIterable {
    case patient
    case professional
    case user
    case service
    case coreGovernance = "core-governance"
    case runtime
    case providerGovernance = "provider-governance"
    case boundary
}

public struct AgentPrincipalRef: Codable, Sendable, Equatable {
    public let principalKind: AgentPrincipalKind
    public let safeRef: String
    public let displayLabel: String?
    public let rawDirectIdentifierExposed: Bool

    public init(
        principalKind: AgentPrincipalKind,
        safeRef: String,
        displayLabel: String? = nil,
        rawDirectIdentifierExposed: Bool = false
    ) {
        self.principalKind = principalKind
        self.safeRef = safeRef
        self.displayLabel = displayLabel
        self.rawDirectIdentifierExposed = rawDirectIdentifierExposed
    }
}

public enum AgentNegotiationIntent: String, Codable, Sendable, CaseIterable {
    case educate
    case summarizeOwnData = "summarize-own-data"
    case requestConsent = "request-consent"
    case respondConsent = "respond-consent"
    case requestAccess = "request-access"
    case grantEphemeralAccess = "grant-ephemeral-access"
    case prepareProfessionalContext = "prepare-professional-context"
    case scheduleCoordination = "schedule-coordination"
    case providerRoute = "provider-route"
    case auditRecord = "audit-record"
    case emergencyAccessRequest = "emergency-access-request"

    case diagnose
    case prescribe
    case issueReferral = "issue-referral"
    case finalizeRecord = "finalize-record"
    case signDocument = "sign-document"
    case grantProfessionalHabilitation = "grant-professional-habilitation"
    case alterLegalRetention = "alter-legal-retention"

    public var isAutonomousClinicalOrRegulatoryEffect: Bool {
        switch self {
        case .diagnose, .prescribe, .issueReferral, .finalizeRecord, .signDocument,
             .grantProfessionalHabilitation, .alterLegalRetention:
            return true
        default:
            return false
        }
    }
}

public struct AgentLawfulContextRequirements: Codable, Sendable, Equatable {
    public let requireServiceId: Bool
    public let requirePatientUserId: Bool
    public let requireProfessionalUserId: Bool
    public let requireHabilitationId: Bool
    public let requireFinalidade: Bool
    public let requireSessionId: Bool

    public init(
        requireServiceId: Bool = false,
        requirePatientUserId: Bool = false,
        requireProfessionalUserId: Bool = false,
        requireHabilitationId: Bool = false,
        requireFinalidade: Bool = true,
        requireSessionId: Bool = false
    ) {
        self.requireServiceId = requireServiceId
        self.requirePatientUserId = requirePatientUserId
        self.requireProfessionalUserId = requireProfessionalUserId
        self.requireHabilitationId = requireHabilitationId
        self.requireFinalidade = requireFinalidade
        self.requireSessionId = requireSessionId
    }

    public var coreRequirement: LawfulContextRequirement {
        LawfulContextRequirement(
            requireServiceId: requireServiceId,
            requirePatientUserId: requirePatientUserId,
            requireProfessionalUserId: requireProfessionalUserId,
            requireHabilitationId: requireHabilitationId,
            requireFinalidade: requireFinalidade,
            requireSessionId: requireSessionId
        )
    }
}

public struct AgentMandate: Codable, Sendable, Equatable {
    public let mandateId: UUID
    public let title: String
    public let principal: AgentPrincipalRef
    public let allowedIntents: [AgentNegotiationIntent]
    public let allowedDataLayers: [StorageLayer]
    public let deniedDataLayers: [StorageLayer]
    public let lawfulContextRequirements: AgentLawfulContextRequirements
    public let legalAuthorizingAllowed: Bool
    public let expiresAt: Date?

    public init(
        mandateId: UUID = UUID(),
        title: String,
        principal: AgentPrincipalRef,
        allowedIntents: [AgentNegotiationIntent],
        allowedDataLayers: [StorageLayer],
        deniedDataLayers: [StorageLayer] = [.directIdentifiers, .reidentificationMapping],
        lawfulContextRequirements: AgentLawfulContextRequirements = .init(),
        legalAuthorizingAllowed: Bool = false,
        expiresAt: Date? = nil
    ) {
        self.mandateId = mandateId
        self.title = title
        self.principal = principal
        self.allowedIntents = allowedIntents
        self.allowedDataLayers = allowedDataLayers
        self.deniedDataLayers = deniedDataLayers
        self.lawfulContextRequirements = lawfulContextRequirements
        self.legalAuthorizingAllowed = legalAuthorizingAllowed
        self.expiresAt = expiresAt
    }
}

public enum AgentMemoryStoreKind: String, Codable, Sendable, CaseIterable {
    case preferenceProfile = "preference-profile"
    case consentHistory = "consent-history"
    case educationalState = "educational-state"
    case professionalContext = "professional-context"
    case runtimeWorkingSet = "runtime-working-set"
    case auditIndex = "audit-index"
}

public struct AgentMemoryScope: Codable, Sendable, Equatable {
    public let scopeId: UUID
    public let ownerAgentId: AgentID
    public let allowedStores: [AgentMemoryStoreKind]
    public let allowedDataLayers: [StorageLayer]
    public let retentionPolicyRef: String
    public let mayPersistDerivedPreference: Bool
    public let mayPersistRawPHI: Bool
    public let mayExposeInternalMemoryToProtocol: Bool

    public init(
        scopeId: UUID = UUID(),
        ownerAgentId: AgentID,
        allowedStores: [AgentMemoryStoreKind],
        allowedDataLayers: [StorageLayer],
        retentionPolicyRef: String,
        mayPersistDerivedPreference: Bool,
        mayPersistRawPHI: Bool = false,
        mayExposeInternalMemoryToProtocol: Bool = false
    ) {
        self.scopeId = scopeId
        self.ownerAgentId = ownerAgentId
        self.allowedStores = allowedStores
        self.allowedDataLayers = allowedDataLayers
        self.retentionPolicyRef = retentionPolicyRef
        self.mayPersistDerivedPreference = mayPersistDerivedPreference
        self.mayPersistRawPHI = mayPersistRawPHI
        self.mayExposeInternalMemoryToProtocol = mayExposeInternalMemoryToProtocol
    }
}

public struct AgentToolGrant: Codable, Sendable, Equatable {
    public let toolId: String
    public let grantedCapabilities: [String]
    public let allowedDataLayers: [StorageLayer]
    public let requiresCoreValidation: Bool
    public let expiresAt: Date?
    public let canExposeRawStorage: Bool
    public let canUseKeyMaterial: Bool
    public let legalAuthorizing: Bool

    public init(
        toolId: String,
        grantedCapabilities: [String],
        allowedDataLayers: [StorageLayer],
        requiresCoreValidation: Bool = true,
        expiresAt: Date? = nil,
        canExposeRawStorage: Bool = false,
        canUseKeyMaterial: Bool = false,
        legalAuthorizing: Bool = false
    ) {
        self.toolId = toolId
        self.grantedCapabilities = grantedCapabilities
        self.allowedDataLayers = allowedDataLayers
        self.requiresCoreValidation = requiresCoreValidation
        self.expiresAt = expiresAt
        self.canExposeRawStorage = canExposeRawStorage
        self.canUseKeyMaterial = canUseKeyMaterial
        self.legalAuthorizing = legalAuthorizing
    }
}

public enum AgentProviderKind: String, Codable, Sendable, CaseIterable {
    case local
    case remote
    case appleNative = "apple-native"
    case httpLocal = "http-local"
    case trainingOffline = "training-offline"
}

public struct AgentProviderRoutingPolicy: Codable, Sendable, Equatable {
    public let preferAppleSiliconLocal: Bool
    public let preferLocal: Bool
    public let allowedProviderKinds: [AgentProviderKind]
    public let allowsExternalProvider: Bool
    public let explicitExternalProviderPolicyRef: String?
    public let allowsOperationalSensitiveExternal: Bool
    public let degradedSovereigntyWhenExternal: Bool
    public let allowedDataLayers: [StorageLayer]
    public let deniedDataLayers: [StorageLayer]
    public let modelProvenanceRequired: Bool

    public init(
        preferAppleSiliconLocal: Bool = true,
        preferLocal: Bool = true,
        allowedProviderKinds: [AgentProviderKind] = [.appleNative, .local, .httpLocal],
        allowsExternalProvider: Bool = false,
        explicitExternalProviderPolicyRef: String? = nil,
        allowsOperationalSensitiveExternal: Bool = false,
        degradedSovereigntyWhenExternal: Bool = true,
        allowedDataLayers: [StorageLayer] = [.governanceMetadata, .derivedArtifacts],
        deniedDataLayers: [StorageLayer] = [.directIdentifiers, .reidentificationMapping],
        modelProvenanceRequired: Bool = true
    ) {
        self.preferAppleSiliconLocal = preferAppleSiliconLocal
        self.preferLocal = preferLocal
        self.allowedProviderKinds = allowedProviderKinds
        self.allowsExternalProvider = allowsExternalProvider
        self.explicitExternalProviderPolicyRef = explicitExternalProviderPolicyRef
        self.allowsOperationalSensitiveExternal = allowsOperationalSensitiveExternal
        self.degradedSovereigntyWhenExternal = degradedSovereigntyWhenExternal
        self.allowedDataLayers = allowedDataLayers
        self.deniedDataLayers = deniedDataLayers
        self.modelProvenanceRequired = modelProvenanceRequired
    }

    public var remoteProviderMayBeUsed: Bool {
        allowsExternalProvider || allowedProviderKinds.contains(.remote)
    }
}

public struct DelegationPolicy: Codable, Sendable, Equatable {
    public let allowsAsyncOfflineResponse: Bool
    public let allowDirectIdentifierFlowExplicit: Bool
    public let allowReidentificationFlowExplicit: Bool
    public let allowKeyMaterialExposure: Bool
    public let allowAutonomousClinicalOrRegulatoryFinality: Bool
    public let requiresHumanGateForFinality: Bool
    public let maxOfflineResponseSeconds: Int?

    public init(
        allowsAsyncOfflineResponse: Bool,
        allowDirectIdentifierFlowExplicit: Bool = false,
        allowReidentificationFlowExplicit: Bool = false,
        allowKeyMaterialExposure: Bool = false,
        allowAutonomousClinicalOrRegulatoryFinality: Bool = false,
        requiresHumanGateForFinality: Bool = true,
        maxOfflineResponseSeconds: Int? = nil
    ) {
        self.allowsAsyncOfflineResponse = allowsAsyncOfflineResponse
        self.allowDirectIdentifierFlowExplicit = allowDirectIdentifierFlowExplicit
        self.allowReidentificationFlowExplicit = allowReidentificationFlowExplicit
        self.allowKeyMaterialExposure = allowKeyMaterialExposure
        self.allowAutonomousClinicalOrRegulatoryFinality = allowAutonomousClinicalOrRegulatoryFinality
        self.requiresHumanGateForFinality = requiresHumanGateForFinality
        self.maxOfflineResponseSeconds = maxOfflineResponseSeconds
    }
}

public struct EphemeralAccessGrantRef: Codable, Sendable, Equatable {
    public let grantId: UUID
    public let grantSafeRef: String
    public let authorizedDataLayers: [StorageLayer]
    public let expiresAt: Date
    public let exposesKeyMaterial: Bool
    public let auditRef: UUID?

    public init(
        grantId: UUID = UUID(),
        grantSafeRef: String,
        authorizedDataLayers: [StorageLayer],
        expiresAt: Date,
        exposesKeyMaterial: Bool = false,
        auditRef: UUID? = nil
    ) {
        self.grantId = grantId
        self.grantSafeRef = grantSafeRef
        self.authorizedDataLayers = authorizedDataLayers
        self.expiresAt = expiresAt
        self.exposesKeyMaterial = exposesKeyMaterial
        self.auditRef = auditRef
    }
}

public struct CustodyControlRef: Codable, Sendable, Equatable {
    public let custodyHandleRef: String
    public let custodyPolicyRef: String
    public let reidentificationRequiresCoreMediation: Bool
    public let mayExposeKeyMaterial: Bool

    public init(
        custodyHandleRef: String,
        custodyPolicyRef: String,
        reidentificationRequiresCoreMediation: Bool = true,
        mayExposeKeyMaterial: Bool = false
    ) {
        self.custodyHandleRef = custodyHandleRef
        self.custodyPolicyRef = custodyPolicyRef
        self.reidentificationRequiresCoreMediation = reidentificationRequiresCoreMediation
        self.mayExposeKeyMaterial = mayExposeKeyMaterial
    }
}

public enum AgentProtocolKind: String, Codable, Sendable, CaseIterable {
    case healthosAACP = "healthos-aacp"
    case a2a
    case acp
}

public struct AgentNegotiationEnvelope: Codable, Sendable, Equatable {
    public let envelopeId: UUID
    public let taskRef: String?
    public let fromAgentId: AgentID
    public let toAgentId: AgentID
    public let intent: AgentNegotiationIntent
    public let lawfulContext: [String: String]
    public let requestedDataLayers: [StorageLayer]
    public let safeSubjectRefs: [String]
    public let requestedToolIds: [String]
    public let providerPolicy: AgentProviderRoutingPolicy
    public let delegationPolicy: DelegationPolicy
    public let memoryScope: AgentMemoryScope?
    public let toolGrants: [AgentToolGrant]
    public let custodyControlRef: CustodyControlRef?
    public let ephemeralGrantRef: EphemeralAccessGrantRef?
    public let protocolHints: [AgentProtocolKind]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]
    public let containsRawDirectIdentifier: Bool
    public let containsReidentificationMapping: Bool
    public let containsRawStoragePath: Bool
    public let containsKeyMaterial: Bool
    public let legalAuthorizing: Bool
    public let rawPayloadMarkers: [String]

    public init(
        envelopeId: UUID = UUID(),
        taskRef: String? = nil,
        fromAgentId: AgentID,
        toAgentId: AgentID,
        intent: AgentNegotiationIntent,
        lawfulContext: [String: String],
        requestedDataLayers: [StorageLayer],
        safeSubjectRefs: [String],
        requestedToolIds: [String] = [],
        providerPolicy: AgentProviderRoutingPolicy = .init(),
        delegationPolicy: DelegationPolicy,
        memoryScope: AgentMemoryScope? = nil,
        toolGrants: [AgentToolGrant] = [],
        custodyControlRef: CustodyControlRef? = nil,
        ephemeralGrantRef: EphemeralAccessGrantRef? = nil,
        protocolHints: [AgentProtocolKind] = [.healthosAACP],
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = [],
        containsRawDirectIdentifier: Bool = false,
        containsReidentificationMapping: Bool = false,
        containsRawStoragePath: Bool = false,
        containsKeyMaterial: Bool = false,
        legalAuthorizing: Bool = false,
        rawPayloadMarkers: [String] = []
    ) {
        self.envelopeId = envelopeId
        self.taskRef = taskRef
        self.fromAgentId = fromAgentId
        self.toAgentId = toAgentId
        self.intent = intent
        self.lawfulContext = lawfulContext
        self.requestedDataLayers = requestedDataLayers
        self.safeSubjectRefs = safeSubjectRefs
        self.requestedToolIds = requestedToolIds
        self.providerPolicy = providerPolicy
        self.delegationPolicy = delegationPolicy
        self.memoryScope = memoryScope
        self.toolGrants = toolGrants
        self.custodyControlRef = custodyControlRef
        self.ephemeralGrantRef = ephemeralGrantRef
        self.protocolHints = protocolHints
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.containsRawDirectIdentifier = containsRawDirectIdentifier
        self.containsReidentificationMapping = containsReidentificationMapping
        self.containsRawStoragePath = containsRawStoragePath
        self.containsKeyMaterial = containsKeyMaterial
        self.legalAuthorizing = legalAuthorizing
        self.rawPayloadMarkers = rawPayloadMarkers
    }
}

public struct GovernedAIAgentDescriptor: Codable, Sendable, Equatable {
    public let agentId: AgentID
    public let kind: GovernedAIAgentKind
    public let representedPrincipal: AgentPrincipalRef
    public let mandate: AgentMandate
    public let memoryScope: AgentMemoryScope
    public let toolGrants: [AgentToolGrant]
    public let providerPolicy: AgentProviderRoutingPolicy
    public let delegationPolicy: DelegationPolicy
    public let boundary: AgentBoundary
    public let protocolKinds: [AgentProtocolKind]
    public let lifecycleState: RuntimeLifecycleState

    public init(
        agentId: AgentID,
        kind: GovernedAIAgentKind,
        representedPrincipal: AgentPrincipalRef,
        mandate: AgentMandate,
        memoryScope: AgentMemoryScope,
        toolGrants: [AgentToolGrant],
        providerPolicy: AgentProviderRoutingPolicy = .init(),
        delegationPolicy: DelegationPolicy,
        boundary: AgentBoundary,
        protocolKinds: [AgentProtocolKind] = [.healthosAACP],
        lifecycleState: RuntimeLifecycleState = .ready
    ) {
        self.agentId = agentId
        self.kind = kind
        self.representedPrincipal = representedPrincipal
        self.mandate = mandate
        self.memoryScope = memoryScope
        self.toolGrants = toolGrants
        self.providerPolicy = providerPolicy
        self.delegationPolicy = delegationPolicy
        self.boundary = boundary
        self.protocolKinds = protocolKinds
        self.lifecycleState = lifecycleState
    }
}

public struct AgentProtocolProjection: Codable, Sendable, Equatable {
    public let protocolKind: AgentProtocolKind
    public let taskId: String
    public let fromAgentId: AgentID
    public let toAgentId: AgentID
    public let intent: AgentNegotiationIntent
    public let safeSubjectRefs: [String]
    public let artifactRefs: [String]
    public let streamAllowed: Bool
    public let degradedState: String?
    public let legalAuthorizing: Bool
    public let exposesInternalMemory: Bool
    public let exposesToolImplementation: Bool
    public let exposesRawDirectIdentifiers: Bool
    public let exposesRawStorage: Bool
    public let exposesKeyMaterial: Bool

    public init(
        protocolKind: AgentProtocolKind,
        taskId: String,
        fromAgentId: AgentID,
        toAgentId: AgentID,
        intent: AgentNegotiationIntent,
        safeSubjectRefs: [String],
        artifactRefs: [String] = [],
        streamAllowed: Bool,
        degradedState: String?,
        legalAuthorizing: Bool = false,
        exposesInternalMemory: Bool = false,
        exposesToolImplementation: Bool = false,
        exposesRawDirectIdentifiers: Bool = false,
        exposesRawStorage: Bool = false,
        exposesKeyMaterial: Bool = false
    ) {
        self.protocolKind = protocolKind
        self.taskId = taskId
        self.fromAgentId = fromAgentId
        self.toAgentId = toAgentId
        self.intent = intent
        self.safeSubjectRefs = safeSubjectRefs
        self.artifactRefs = artifactRefs
        self.streamAllowed = streamAllowed
        self.degradedState = degradedState
        self.legalAuthorizing = legalAuthorizing
        self.exposesInternalMemory = exposesInternalMemory
        self.exposesToolImplementation = exposesToolImplementation
        self.exposesRawDirectIdentifiers = exposesRawDirectIdentifiers
        self.exposesRawStorage = exposesRawStorage
        self.exposesKeyMaterial = exposesKeyMaterial
    }
}

public enum GovernedAIAgentFailure: Error, LocalizedError, Sendable, Equatable {
    case missingAgentId
    case missingMandate
    case missingSafePrincipalRef
    case principalKindMismatch(expected: AgentPrincipalKind, actual: AgentPrincipalKind)
    case missingLawfulContext
    case intentOutsideMandate(AgentNegotiationIntent)
    case deniedDataLayer(StorageLayer)
    case directIdentifierDenied
    case reidentificationDenied
    case rawStorageDenied
    case keyMaterialDenied
    case memoryScopeExposureDenied
    case toolGrantEscalatesAuthority(String)
    case legalAuthorizationDenied
    case autonomousClinicalOrRegulatoryActDenied(AgentNegotiationIntent)
    case externalProviderPolicyMissing
    case externalProviderSensitiveLayerDenied(StorageLayer)

    public var errorDescription: String? {
        switch self {
        case .missingAgentId:
            return "Governed AI agent requires a stable AgentID."
        case .missingMandate:
            return "Governed AI agent requires an explicit mandate."
        case .missingSafePrincipalRef:
            return "Governed AI agent requires a safe principal reference."
        case .principalKindMismatch(let expected, let actual):
            return "Agent principal kind mismatch: expected \(expected.rawValue), got \(actual.rawValue)."
        case .missingLawfulContext:
            return "Agent negotiation requires lawfulContext."
        case .intentOutsideMandate(let intent):
            return "Intent \(intent.rawValue) is outside the agent mandate."
        case .deniedDataLayer(let layer):
            return "Data layer \(layer.rawValue) is denied by agent policy."
        case .directIdentifierDenied:
            return "Direct identifiers are denied by default for governed AI agent envelopes."
        case .reidentificationDenied:
            return "Reidentification maps are denied by default for governed AI agent envelopes."
        case .rawStorageDenied:
            return "Raw storage paths or internals are denied for governed AI agent envelopes."
        case .keyMaterialDenied:
            return "Key material is never exposed through governed AI agent envelopes."
        case .memoryScopeExposureDenied:
            return "Internal agent memory cannot be exposed through protocol envelopes."
        case .toolGrantEscalatesAuthority(let toolId):
            return "Tool grant \(toolId) escalates beyond governed agent authority."
        case .legalAuthorizationDenied:
            return "Agent envelope cannot be a legal-authorizing act."
        case .autonomousClinicalOrRegulatoryActDenied(let intent):
            return "Intent \(intent.rawValue) is a clinical/regulatory effect and cannot be autonomous."
        case .externalProviderPolicyMissing:
            return "External provider use requires explicit governed provider policy."
        case .externalProviderSensitiveLayerDenied(let layer):
            return "External provider route is denied for sensitive data layer \(layer.rawValue)."
        }
    }
}

public enum GovernedAIAgentCatalog {
    public static let personalAgents: [GovernedAIAgentKind] = [.patientPersonal, .professionalPersonal, .userPersonal]
    public static let coreGovernanceAgents: [GovernedAIAgentKind] = [.consentGovernance, .habilitationGovernance, .gateFinality, .custodyAccess, .auditProvenance]
    public static let runtimeAgents: [GovernedAIAgentKind] = [.session, .aaci, .msr, .asyncJob, .serviceRuntime, .userAgentRuntime]
    public static let providerModelAgents: [GovernedAIAgentKind] = [.providerRouter, .modelGovernance]
    public static let boundaryProtocolAgents: [GovernedAIAgentKind] = [.agentProtocolBoundary, .appSurfaceBoundary]
    public static let allKnownAgents: [GovernedAIAgentKind] = GovernedAIAgentKind.allCases
}

public enum GovernedAIAgentValidator {
    public static func validateDescriptor(_ descriptor: GovernedAIAgentDescriptor) throws {
        guard descriptor.agentId.rawValue.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw GovernedAIAgentFailure.missingAgentId
        }
        guard descriptor.mandate.title.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              descriptor.mandate.allowedIntents.isEmpty == false else {
            throw GovernedAIAgentFailure.missingMandate
        }
        guard descriptor.representedPrincipal.safeRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              descriptor.representedPrincipal.rawDirectIdentifierExposed == false else {
            throw GovernedAIAgentFailure.missingSafePrincipalRef
        }
        try validatePrincipalKind(for: descriptor.kind, principal: descriptor.representedPrincipal)
        try validateToolGrants(descriptor.toolGrants)
        if descriptor.memoryScope.mayExposeInternalMemoryToProtocol {
            throw GovernedAIAgentFailure.memoryScopeExposureDenied
        }
    }

    public static func validateNegotiationEnvelope(
        _ envelope: AgentNegotiationEnvelope,
        mandate: AgentMandate? = nil
    ) throws -> CoreLawfulContext {
        guard envelope.lawfulContext.isEmpty == false else {
            throw GovernedAIAgentFailure.missingLawfulContext
        }

        let requirements = mandate?.lawfulContextRequirements.coreRequirement ?? LawfulContextRequirement(requireFinalidade: true)
        let lawfulContext = try LawfulContextValidator.validate(envelope.lawfulContext, requirements: requirements)

        if let mandate, mandate.allowedIntents.contains(envelope.intent) == false {
            throw GovernedAIAgentFailure.intentOutsideMandate(envelope.intent)
        }

        if envelope.intent.isAutonomousClinicalOrRegulatoryEffect {
            throw GovernedAIAgentFailure.autonomousClinicalOrRegulatoryActDenied(envelope.intent)
        }
        if envelope.legalAuthorizing || envelope.delegationPolicy.allowAutonomousClinicalOrRegulatoryFinality {
            throw GovernedAIAgentFailure.legalAuthorizationDenied
        }

        let deniedLayers = Set((mandate?.deniedDataLayers ?? []) + envelope.providerPolicy.deniedDataLayers)
        for layer in envelope.requestedDataLayers where deniedLayers.contains(layer) {
            throw GovernedAIAgentFailure.deniedDataLayer(layer)
        }
        for layer in envelope.requestedDataLayers where layer == .directIdentifiers {
            guard envelope.delegationPolicy.allowDirectIdentifierFlowExplicit else {
                throw GovernedAIAgentFailure.directIdentifierDenied
            }
        }
        for layer in envelope.requestedDataLayers where layer == .reidentificationMapping {
            guard envelope.delegationPolicy.allowReidentificationFlowExplicit else {
                throw GovernedAIAgentFailure.reidentificationDenied
            }
        }

        if envelope.containsRawDirectIdentifier {
            throw GovernedAIAgentFailure.directIdentifierDenied
        }
        if envelope.containsReidentificationMapping {
            throw GovernedAIAgentFailure.reidentificationDenied
        }
        if envelope.containsRawStoragePath {
            throw GovernedAIAgentFailure.rawStorageDenied
        }
        if envelope.containsKeyMaterial || envelope.delegationPolicy.allowKeyMaterialExposure {
            throw GovernedAIAgentFailure.keyMaterialDenied
        }
        if envelope.memoryScope?.mayExposeInternalMemoryToProtocol == true {
            throw GovernedAIAgentFailure.memoryScopeExposureDenied
        }
        if envelope.custodyControlRef?.mayExposeKeyMaterial == true || envelope.ephemeralGrantRef?.exposesKeyMaterial == true {
            throw GovernedAIAgentFailure.keyMaterialDenied
        }

        try validateToolGrants(envelope.toolGrants)
        try validateProviderPolicy(envelope.providerPolicy, requestedLayers: envelope.requestedDataLayers)
        try validateRawPayloadMarkers(envelope.rawPayloadMarkers)

        return lawfulContext
    }

    private static func validatePrincipalKind(for kind: GovernedAIAgentKind, principal: AgentPrincipalRef) throws {
        switch kind {
        case .patientPersonal where principal.principalKind != .patient:
            throw GovernedAIAgentFailure.principalKindMismatch(expected: .patient, actual: principal.principalKind)
        case .professionalPersonal where principal.principalKind != .professional:
            throw GovernedAIAgentFailure.principalKindMismatch(expected: .professional, actual: principal.principalKind)
        case .userPersonal where principal.principalKind != .user:
            throw GovernedAIAgentFailure.principalKindMismatch(expected: .user, actual: principal.principalKind)
        default:
            return
        }
    }

    private static func validateToolGrants(_ grants: [AgentToolGrant]) throws {
        for grant in grants {
            if grant.canExposeRawStorage || grant.canUseKeyMaterial || grant.legalAuthorizing {
                throw GovernedAIAgentFailure.toolGrantEscalatesAuthority(grant.toolId)
            }
        }
    }

    private static func validateProviderPolicy(
        _ policy: AgentProviderRoutingPolicy,
        requestedLayers: [StorageLayer]
    ) throws {
        if policy.allowedProviderKinds.contains(.remote), policy.allowsExternalProvider == false {
            throw GovernedAIAgentFailure.externalProviderPolicyMissing
        }
        if policy.allowsExternalProvider {
            guard policy.explicitExternalProviderPolicyRef?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
                throw GovernedAIAgentFailure.externalProviderPolicyMissing
            }
        }
        guard policy.remoteProviderMayBeUsed else {
            return
        }
        for layer in requestedLayers {
            switch layer {
            case .directIdentifiers:
                throw GovernedAIAgentFailure.directIdentifierDenied
            case .reidentificationMapping:
                throw GovernedAIAgentFailure.reidentificationDenied
            case .operationalContent where policy.allowsOperationalSensitiveExternal == false:
                throw GovernedAIAgentFailure.externalProviderSensitiveLayerDenied(layer)
            default:
                break
            }
        }
    }

    private static func validateRawPayloadMarkers(_ markers: [String]) throws {
        for marker in markers {
            let normalized = marker.lowercased()
            if normalized.contains("cpf") || normalized.contains("direct-identifier") {
                throw GovernedAIAgentFailure.directIdentifierDenied
            }
            if normalized.contains("reidentification") || normalized.contains("re-identification") {
                throw GovernedAIAgentFailure.reidentificationDenied
            }
            if normalized.contains("raw-storage") || normalized.contains("storage-path") {
                throw GovernedAIAgentFailure.rawStorageDenied
            }
            if normalized.contains("key-material") || normalized.contains("private-key") || normalized.contains("secret") {
                throw GovernedAIAgentFailure.keyMaterialDenied
            }
        }
    }
}
