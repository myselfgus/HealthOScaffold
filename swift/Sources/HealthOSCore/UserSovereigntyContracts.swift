import Foundation

public enum UserAgentCapability: String, Codable, Sendable, CaseIterable {
    case explainOwnData = "explain-own-data"
    case summarizeOwnData = "summarize-own-data"
    case retrieveOwnContext = "retrieve-own-context"
    case listConsents = "list-consents"
    case inspectAccessAudit = "inspect-access-audit"
    case prepareExportRequest = "prepare-export-request"
    case organizeOwnArtifacts = "organize-own-artifacts"
    case askAdministrativeClarification = "ask-administrative-clarification"

    case diagnose
    case prescribe
    case issueReferral = "issue-referral"
    case finalizeRecord = "finalize-record"
    case signDocument = "sign-document"
    case grantProfessionalHabilitation = "grant-professional-habilitation"
    case alterLegalRetention = "alter-legal-retention"
    case accessReidentificationMap = "access-reidentification-map"
    case bypassConsentAudit = "bypass-consent-audit"

    public var isProhibitedForUserAgent: Bool {
        switch self {
        case .diagnose, .prescribe, .issueReferral, .finalizeRecord, .signDocument,
             .grantProfessionalHabilitation, .alterLegalRetention, .accessReidentificationMap,
             .bypassConsentAudit:
            return true
        default:
            return false
        }
    }
}

public enum UserAgentDataDisposition: String, Codable, Sendable {
    case informationalUserFacing = "informational-user-facing"
    case clinicalAct = "clinical-act"
}

public struct UserAgentScope: Codable, Sendable {
    public let userId: UUID
    public let cpfHashRef: String
    public let actorId: String
    public let runtimeId: String
    public let dataLayersAllowed: [StorageLayer]
    public let dataLayersDenied: [StorageLayer]
    public let allowDirectIdentifiersFlowExplicit: Bool
    public let allowReidentificationFlowExplicit: Bool

    public init(
        userId: UUID,
        cpfHashRef: String,
        actorId: String,
        runtimeId: String,
        dataLayersAllowed: [StorageLayer],
        dataLayersDenied: [StorageLayer],
        allowDirectIdentifiersFlowExplicit: Bool = false,
        allowReidentificationFlowExplicit: Bool = false
    ) {
        self.userId = userId
        self.cpfHashRef = cpfHashRef
        self.actorId = actorId
        self.runtimeId = runtimeId
        self.dataLayersAllowed = dataLayersAllowed
        self.dataLayersDenied = dataLayersDenied
        self.allowDirectIdentifiersFlowExplicit = allowDirectIdentifiersFlowExplicit
        self.allowReidentificationFlowExplicit = allowReidentificationFlowExplicit
    }
}

public struct UserAgentRequest: Codable, Sendable {
    public let requestId: UUID
    public let scope: UserAgentScope
    public let requestedCapability: UserAgentCapability
    public let lawfulContext: [String: String]
    public let sessionRef: UUID?
    public let contextRef: String?
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        requestId: UUID = UUID(),
        scope: UserAgentScope,
        requestedCapability: UserAgentCapability,
        lawfulContext: [String: String],
        sessionRef: UUID? = nil,
        contextRef: String? = nil,
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = []
    ) {
        self.requestId = requestId
        self.scope = scope
        self.requestedCapability = requestedCapability
        self.lawfulContext = lawfulContext
        self.sessionRef = sessionRef
        self.contextRef = contextRef
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public struct UserAgentResponse: Codable, Sendable {
    public let requestId: UUID
    public let disposition: UserAgentDataDisposition
    public let message: String
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(requestId: UUID, disposition: UserAgentDataDisposition, message: String, provenanceRefs: [UUID], auditRefs: [UUID]) {
        self.requestId = requestId
        self.disposition = disposition
        self.message = message
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public enum UserAgentFailure: Error, LocalizedError, Sendable, Equatable {
    case prohibitedCapability(UserAgentCapability)
    case missingLawfulContext
    case deniedDataLayer(StorageLayer)
    case reidentificationDeniedByDefault
    case directIdentifierFlowRequiresExplicitPolicy
    case outputMustBeInformational
    case invalidAuditVisibilityScope

    public var errorDescription: String? {
        switch self {
        case .prohibitedCapability(let capability):
            return "Capability \(capability.rawValue) is prohibited for User Agent."
        case .missingLawfulContext:
            return "User Agent request requires lawfulContext."
        case .deniedDataLayer(let layer):
            return "User Agent request denied for data layer \(layer.rawValue)."
        case .reidentificationDeniedByDefault:
            return "Reidentification mapping access is denied by default for User Agent."
        case .directIdentifierFlowRequiresExplicitPolicy:
            return "Direct identifier access requires explicit governed flow."
        case .outputMustBeInformational:
            return "User Agent output must remain informational and non-clinical."
        case .invalidAuditVisibilityScope:
            return "Patient audit view can only include events for the requestor user."
        }
    }
}

public enum UserAgentGovernanceValidator {
    public static func validateRequest(_ request: UserAgentRequest) throws -> CoreLawfulContext {
        guard request.lawfulContext.isEmpty == false else {
            throw UserAgentFailure.missingLawfulContext
        }
        guard request.requestedCapability.isProhibitedForUserAgent == false else {
            throw UserAgentFailure.prohibitedCapability(request.requestedCapability)
        }

        let validated = try LawfulContextValidator.validate(
            request.lawfulContext,
            requirements: .init(requirePatientUserId: true, requireFinalidade: true)
        )

        let denied = Set(request.scope.dataLayersDenied)
        for layer in request.scope.dataLayersAllowed where denied.contains(layer) {
            throw UserAgentFailure.deniedDataLayer(layer)
        }

        if request.scope.dataLayersAllowed.contains(.reidentificationMapping),
           request.scope.allowReidentificationFlowExplicit == false {
            throw UserAgentFailure.reidentificationDeniedByDefault
        }

        if request.scope.dataLayersAllowed.contains(.directIdentifiers),
           request.scope.allowDirectIdentifiersFlowExplicit == false {
            throw UserAgentFailure.directIdentifierFlowRequiresExplicitPolicy
        }

        if validated.patientUserId != request.scope.userId {
            throw CoreLawError.invalidLawfulContext("lawfulContext patientUserId must match User Agent scope userId")
        }

        return validated
    }

    public static func validateResponse(_ response: UserAgentResponse) throws {
        guard response.disposition == .informationalUserFacing else {
            throw UserAgentFailure.outputMustBeInformational
        }
    }
}

public struct PatientConsentView: Codable, Sendable {
    public let consentId: UUID
    public let finalidade: String
    public let scopeSummary: [String]
    public let validityStart: Date
    public let validityEnd: Date?
    public let revoked: Bool
    public let revokedAt: Date?
    public let retentionObligationApplies: Bool
}

public struct ConsentRevocationRequest: Codable, Sendable {
    public let requestId: UUID
    public let patientUserId: UUID
    public let consentId: UUID
    public let finalidade: String
    public let scopeSummary: [String]
    public let rationale: String
    public let lawfulContext: [String: String]
    public let retentionAcknowledged: Bool
    public let finalDocumentImmutabilityAcknowledged: Bool
    public let provenanceRef: UUID?
    public let auditRef: UUID?
}

public enum ConsentDecisionFailure: Error, LocalizedError, Sendable, Equatable {
    case missingScopeOrFinality
    case lawfulContextRequired
    case retentionOverrideDenied
    case finalDocumentMutationDenied

    public var errorDescription: String? {
        switch self {
        case .missingScopeOrFinality:
            return "Consent revocation requires finalidade and scope summary."
        case .lawfulContextRequired:
            return "Consent management requires lawfulContext."
        case .retentionOverrideDenied:
            return "Consent revocation cannot bypass service legal retention."
        case .finalDocumentMutationDenied:
            return "Consent revocation cannot mutate final issued documents."
        }
    }
}

public enum ConsentGovernanceValidator {
    public static func validateRevocation(_ request: ConsentRevocationRequest) throws {
        guard request.finalidade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false,
              request.scopeSummary.isEmpty == false else {
            throw ConsentDecisionFailure.missingScopeOrFinality
        }
        guard request.lawfulContext.isEmpty == false else {
            throw ConsentDecisionFailure.lawfulContextRequired
        }
        _ = try LawfulContextValidator.validate(request.lawfulContext, requirements: .init(requirePatientUserId: true, requireFinalidade: true))
        guard request.retentionAcknowledged else {
            throw ConsentDecisionFailure.retentionOverrideDenied
        }
        guard request.finalDocumentImmutabilityAcknowledged else {
            throw ConsentDecisionFailure.finalDocumentMutationDenied
        }
    }
}

public struct PatientAuditQuery: Codable, Sendable {
    public let patientUserId: UUID
    public let lawfulContext: [String: String]
    public let includeEmergencyMarker: Bool
    public let includeRegulatoryMarker: Bool

    public init(patientUserId: UUID, lawfulContext: [String: String], includeEmergencyMarker: Bool = true, includeRegulatoryMarker: Bool = true) {
        self.patientUserId = patientUserId
        self.lawfulContext = lawfulContext
        self.includeEmergencyMarker = includeEmergencyMarker
        self.includeRegulatoryMarker = includeRegulatoryMarker
    }
}

public struct AccessAuditEventView: Codable, Sendable {
    public let id: UUID
    public let patientUserId: UUID
    public let actorRole: String
    public let actorDisplay: String
    public let timestamp: Date
    public let finalidade: String
    public let serviceRef: String?
    public let dataLayer: StorageLayer
    public let operation: String
    public let provenanceRef: UUID?
    public let auditRef: UUID?
    public let emergencyAccess: Bool
    public let regulatoryAccess: Bool
    public let redactionStatus: String
    public let secretsRedacted: Bool

    public init(
        id: UUID = UUID(),
        patientUserId: UUID,
        actorRole: String,
        actorDisplay: String,
        timestamp: Date,
        finalidade: String,
        serviceRef: String? = nil,
        dataLayer: StorageLayer,
        operation: String,
        provenanceRef: UUID? = nil,
        auditRef: UUID? = nil,
        emergencyAccess: Bool,
        regulatoryAccess: Bool,
        redactionStatus: String,
        secretsRedacted: Bool
    ) {
        self.id = id
        self.patientUserId = patientUserId
        self.actorRole = actorRole
        self.actorDisplay = actorDisplay
        self.timestamp = timestamp
        self.finalidade = finalidade
        self.serviceRef = serviceRef
        self.dataLayer = dataLayer
        self.operation = operation
        self.provenanceRef = provenanceRef
        self.auditRef = auditRef
        self.emergencyAccess = emergencyAccess
        self.regulatoryAccess = regulatoryAccess
        self.redactionStatus = redactionStatus
        self.secretsRedacted = secretsRedacted
    }
}

public struct PatientAccessAuditView: Codable, Sendable {
    public let query: PatientAuditQuery
    public let events: [AccessAuditEventView]
}

public enum PatientAuditFailure: Error, LocalizedError, Sendable, Equatable {
    case lawfulContextRequired
    case crossPatientAccessDenied
    case forbiddenSensitiveLeak

    public var errorDescription: String? {
        switch self {
        case .lawfulContextRequired:
            return "Patient audit query requires lawfulContext."
        case .crossPatientAccessDenied:
            return "Patient audit query cannot return events from other users."
        case .forbiddenSensitiveLeak:
            return "Patient audit event leaks forbidden sensitive content."
        }
    }
}

public enum PatientAuditGovernanceValidator {
    public static func validateView(_ view: PatientAccessAuditView) throws {
        _ = try LawfulContextValidator.validate(view.query.lawfulContext, requirements: .init(requirePatientUserId: true, requireFinalidade: true))

        for event in view.events {
            if event.patientUserId != view.query.patientUserId {
                throw PatientAuditFailure.crossPatientAccessDenied
            }
            if event.dataLayer == .reidentificationMapping {
                throw PatientAuditFailure.forbiddenSensitiveLeak
            }
            if event.secretsRedacted == false {
                throw PatientAuditFailure.forbiddenSensitiveLeak
            }
        }
    }
}

public struct PatientExportRequestSurface: Codable, Sendable {
    public let requestId: UUID
    public let ownerUserId: UUID
    public let lawfulContext: [String: String]
    public let scope: [StorageLayer]
    public let redactionPolicy: String
    public let includeDirectIdentifiers: Bool
    public let directIdentifierPolicyElevated: Bool
    public let includeReidentificationMapping: Bool

    public init(
        requestId: UUID = UUID(),
        ownerUserId: UUID,
        lawfulContext: [String: String],
        scope: [StorageLayer],
        redactionPolicy: String,
        includeDirectIdentifiers: Bool,
        directIdentifierPolicyElevated: Bool,
        includeReidentificationMapping: Bool = false
    ) {
        self.requestId = requestId
        self.ownerUserId = ownerUserId
        self.lawfulContext = lawfulContext
        self.scope = scope
        self.redactionPolicy = redactionPolicy
        self.includeDirectIdentifiers = includeDirectIdentifiers
        self.directIdentifierPolicyElevated = directIdentifierPolicyElevated
        self.includeReidentificationMapping = includeReidentificationMapping
    }
}

public struct PatientExportStatusView: Codable, Sendable {
    public let requestId: UUID
    public let status: String
    public let packageManifest: ExportPackageManifest?
    public let appSafeStatusDetail: String
    public let storagePathExposed: Bool
}

public enum PatientExportFailure: Error, LocalizedError, Sendable, Equatable {
    case lawfulContextRequired
    case reidentificationExportDenied
    case directIdentifiersRequirePolicy
    case rawStorageExposureDenied

    public var errorDescription: String? {
        switch self {
        case .lawfulContextRequired:
            return "Patient export request requires lawfulContext."
        case .reidentificationExportDenied:
            return "Patient export of reidentification mapping is denied by default."
        case .directIdentifiersRequirePolicy:
            return "Patient export of direct identifiers requires explicit policy elevation."
        case .rawStorageExposureDenied:
            return "Patient export status cannot expose raw storage internals to app surfaces."
        }
    }
}

public enum PatientExportGovernanceValidator {
    public static func validateRequest(_ request: PatientExportRequestSurface) throws {
        guard request.lawfulContext.isEmpty == false else {
            throw PatientExportFailure.lawfulContextRequired
        }
        _ = try LawfulContextValidator.validate(request.lawfulContext, requirements: .init(requirePatientUserId: true, requireFinalidade: true))
        if request.includeReidentificationMapping {
            throw PatientExportFailure.reidentificationExportDenied
        }
        if request.includeDirectIdentifiers && request.directIdentifierPolicyElevated == false {
            throw PatientExportFailure.directIdentifiersRequirePolicy
        }
    }

    public static func validateStatus(_ view: PatientExportStatusView) throws {
        if view.storagePathExposed {
            throw PatientExportFailure.rawStorageExposureDenied
        }
    }
}

public struct DataVisibilityRetentionItem: Codable, Sendable {
    public let id: UUID
    public let patientUserId: UUID
    public let dataLayer: StorageLayer
    public let visibleToPatient: Bool
    public let hiddenByPolicy: Bool
    public let retainedByServiceObligation: Bool
    public let exportEligible: Bool
    public let deletionEligible: Bool
    public let anonymizationEligible: Bool
    public let legalHold: Bool
    public let patientRequestedRestriction: Bool
}

public enum VisibilityRetentionFailure: Error, LocalizedError, Sendable, Equatable {
    case legalHoldBlocksDeletion
    case retainedDoesNotMeanVisible

    public var errorDescription: String? {
        switch self {
        case .legalHoldBlocksDeletion:
            return "Legal hold blocks deletion eligibility."
        case .retainedDoesNotMeanVisible:
            return "Retention obligation and visibility must stay independently governed."
        }
    }
}

public enum VisibilityRetentionGovernanceValidator {
    public static func validate(_ item: DataVisibilityRetentionItem) throws {
        if item.legalHold && item.deletionEligible {
            throw VisibilityRetentionFailure.legalHoldBlocksDeletion
        }
        if item.retainedByServiceObligation && item.visibleToPatient && item.hiddenByPolicy {
            throw VisibilityRetentionFailure.retainedDoesNotMeanVisible
        }
    }
}

public struct SortioDashboardSummary: Codable, Sendable {
    public let userId: UUID
    public let consentSummaryCount: Int
    public let auditSummaryCount: Int
    public let exportPendingCount: Int
    public let userAgentState: String
}

public struct SortioConsentSummary: Codable, Sendable {
    public let active: Int
    public let revoked: Int
    public let expiringSoon: Int
}

public struct SortioAccessAuditSummary: Codable, Sendable {
    public let totalEvents: Int
    public let emergencyEvents: Int
    public let regulatoryEvents: Int
}

public struct SortioExportSummary: Codable, Sendable {
    public let pending: Int
    public let completed: Int
    public let denied: Int
}

public struct SortioUserAgentInteractionEnvelope: Codable, Sendable {
    public let request: UserAgentRequest
    public let response: UserAgentResponse
}

public struct SortioDataVisibilitySummary: Codable, Sendable {
    public let visibleItems: Int
    public let retainedButHiddenItems: Int
    public let legalHoldItems: Int
}

public struct SortioNotificationObligationsSummary: Codable, Sendable {
    public let pendingPatientNotifications: Int
    public let pendingPostEmergencyReview: Int
    public let pendingExportNotifications: Int
}

public enum SortioBoundaryFailure: Error, LocalizedError, Sendable, Equatable {
    case forbiddenDirectIdentifierExposure
    case forbiddenStoragePathExposure
    case forbiddenClinicalCapabilitySurface

    public var errorDescription: String? {
        switch self {
        case .forbiddenDirectIdentifierExposure:
            return "Sortio app-safe surfaces must not expose direct identifiers by default."
        case .forbiddenStoragePathExposure:
            return "Sortio app-safe surfaces must not expose raw storage internals."
        case .forbiddenClinicalCapabilitySurface:
            return "Sortio/User-Agent envelope cannot include prohibited clinical capabilities."
        }
    }
}

public enum SortioBoundaryValidator {
    public static func validateUserAgentEnvelope(_ envelope: SortioUserAgentInteractionEnvelope) throws {
        _ = try UserAgentGovernanceValidator.validateRequest(envelope.request)
        try UserAgentGovernanceValidator.validateResponse(envelope.response)
    }

    public static func validateAppSafePayload(rawCPF: String?, rawStoragePath: String?, capability: UserAgentCapability) throws {
        if let rawCPF, rawCPF.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            throw SortioBoundaryFailure.forbiddenDirectIdentifierExposure
        }
        if let rawStoragePath, rawStoragePath.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false {
            throw SortioBoundaryFailure.forbiddenStoragePathExposure
        }
        if capability.isProhibitedForUserAgent {
            throw SortioBoundaryFailure.forbiddenClinicalCapabilitySurface
        }
    }
}
