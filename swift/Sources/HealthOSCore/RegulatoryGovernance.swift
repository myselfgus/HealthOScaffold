import Foundation

public enum RegulatoryAuthorityKind: String, Codable, Sendable {
    case internalCompliance = "internal-compliance"
    case judicialOrder = "judicial-order"
    case publicHealthAuthority = "public-health-authority"
    case regulator = "regulator"
    case otherLawfulAuthority = "other-lawful-authority"
}

public enum RegulatoryAuditStatus: String, Codable, Sendable {
    case requested
    case validated
    case denied
    case approved
    case packagePrepared = "package_prepared"
    case deliveredExternallyPlaceholder = "delivered_externally_placeholder"
    case closed
}

public struct RegulatoryAuditScope: Codable, Sendable {
    public let operations: [String]
    public let includeProvenance: Bool
    public let includeAuditTrail: Bool

    public init(operations: [String], includeProvenance: Bool, includeAuditTrail: Bool) {
        self.operations = operations
        self.includeProvenance = includeProvenance
        self.includeAuditTrail = includeAuditTrail
    }
}

public struct RegulatoryAuditRequest: Codable, Sendable {
    public let id: UUID
    public let authorityKind: RegulatoryAuthorityKind
    public let legalBasis: String
    public let rationale: String
    public let requestedScope: RegulatoryAuditScope
    public let requestedDataLayers: [StorageLayer]
    public let serviceId: UUID
    public let patientUserId: UUID?
    public let requestedByActor: String
    public let approvedByActor: String?
    public let timeWindowStart: Date
    public let timeWindowEnd: Date
    public let lawfulContext: [String: String]
    public let exportPackageRefs: [String]
    public let auditRefs: [UUID]
    public let provenanceRefs: [UUID]
    public let viaCoreMediation: Bool
    public let status: RegulatoryAuditStatus

    public init(
        id: UUID = UUID(),
        authorityKind: RegulatoryAuthorityKind,
        legalBasis: String,
        rationale: String,
        requestedScope: RegulatoryAuditScope,
        requestedDataLayers: [StorageLayer],
        serviceId: UUID,
        patientUserId: UUID? = nil,
        requestedByActor: String,
        approvedByActor: String? = nil,
        timeWindowStart: Date,
        timeWindowEnd: Date,
        lawfulContext: [String: String],
        exportPackageRefs: [String] = [],
        auditRefs: [UUID] = [],
        provenanceRefs: [UUID] = [],
        viaCoreMediation: Bool,
        status: RegulatoryAuditStatus
    ) {
        self.id = id
        self.authorityKind = authorityKind
        self.legalBasis = legalBasis
        self.rationale = rationale
        self.requestedScope = requestedScope
        self.requestedDataLayers = requestedDataLayers
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.requestedByActor = requestedByActor
        self.approvedByActor = approvedByActor
        self.timeWindowStart = timeWindowStart
        self.timeWindowEnd = timeWindowEnd
        self.lawfulContext = lawfulContext
        self.exportPackageRefs = exportPackageRefs
        self.auditRefs = auditRefs
        self.provenanceRefs = provenanceRefs
        self.viaCoreMediation = viaCoreMediation
        self.status = status
    }
}

public struct RegulatoryAuditPackage: Codable, Sendable {
    public let id: UUID
    public let requestId: UUID
    public let includedObjectRefs: [StorageObjectRef]
    public let includedHashes: [String: String]
    public let includedDataLayers: [StorageLayer]
    public let externalDelivery: Bool
    public let externalDeliveryMode: String
    public let notes: String

    public init(
        id: UUID = UUID(),
        requestId: UUID,
        includedObjectRefs: [StorageObjectRef],
        includedHashes: [String: String],
        includedDataLayers: [StorageLayer],
        externalDelivery: Bool,
        externalDeliveryMode: String,
        notes: String
    ) {
        self.id = id
        self.requestId = requestId
        self.includedObjectRefs = includedObjectRefs
        self.includedHashes = includedHashes
        self.includedDataLayers = includedDataLayers
        self.externalDelivery = externalDelivery
        self.externalDeliveryMode = externalDeliveryMode
        self.notes = notes
    }
}

public enum EmergencyAccessStatus: String, Codable, Sendable {
    case requested
    case granted
    case denied
    case expired
    case revoked
    case postReviewRequired = "post_review_required"
    case postReviewCompleted = "post_review_completed"
}

public struct EmergencyAccessRequest: Codable, Sendable {
    public let id: UUID
    public let actorId: String
    public let actorRole: String
    public let patientUserId: UUID
    public let serviceId: UUID
    public let emergencyRationale: String
    public let requestedScope: [String]
    public let requestedDurationMinutes: Int
    public let requestedBySource: String
    public let lawfulContext: [String: String]
    public let status: EmergencyAccessStatus

    public init(
        id: UUID = UUID(),
        actorId: String,
        actorRole: String,
        patientUserId: UUID,
        serviceId: UUID,
        emergencyRationale: String,
        requestedScope: [String],
        requestedDurationMinutes: Int,
        requestedBySource: String,
        lawfulContext: [String: String],
        status: EmergencyAccessStatus
    ) {
        self.id = id
        self.actorId = actorId
        self.actorRole = actorRole
        self.patientUserId = patientUserId
        self.serviceId = serviceId
        self.emergencyRationale = emergencyRationale
        self.requestedScope = requestedScope
        self.requestedDurationMinutes = requestedDurationMinutes
        self.requestedBySource = requestedBySource
        self.lawfulContext = lawfulContext
        self.status = status
    }
}

public struct BreakGlassAccessGrant: Codable, Sendable {
    public let requestId: UUID
    public let grantedDurationMinutes: Int
    public let approvedByActor: String?
    public let postAccessReviewRequired: Bool
    public let patientNotificationRequired: Bool
    public let auditRefs: [UUID]
    public let provenanceRefs: [UUID]
    public let expiresAt: Date
    public let status: EmergencyAccessStatus

    public init(
        requestId: UUID,
        grantedDurationMinutes: Int,
        approvedByActor: String? = nil,
        postAccessReviewRequired: Bool,
        patientNotificationRequired: Bool,
        auditRefs: [UUID] = [],
        provenanceRefs: [UUID] = [],
        expiresAt: Date,
        status: EmergencyAccessStatus
    ) {
        self.requestId = requestId
        self.grantedDurationMinutes = grantedDurationMinutes
        self.approvedByActor = approvedByActor
        self.postAccessReviewRequired = postAccessReviewRequired
        self.patientNotificationRequired = patientNotificationRequired
        self.auditRefs = auditRefs
        self.provenanceRefs = provenanceRefs
        self.expiresAt = expiresAt
        self.status = status
    }
}

public struct LegalRetentionObligation: Codable, Sendable {
    public let retentionClass: RetentionClass
    public let minimumRetentionDays: Int
    public let serviceCustodyRequired: Bool
    public let legalBasis: String
}

public struct VisibilityPolicy: Codable, Sendable {
    public let patientVisible: Bool
    public let patientExportEligible: Bool
    public let accessRestricted: Bool
}

public struct CustodyPolicy: Codable, Sendable {
    public let serviceCustodyObligation: Bool
    public let deletionEligible: Bool
    public let anonymizationEligible: Bool
}

public struct RetentionVisibilityDecision: Codable, Sendable {
    public let id: UUID
    public let patientUserId: UUID?
    public let serviceId: UUID
    public let requestedByActor: String
    public let rationale: String
    public let legalRetention: LegalRetentionObligation
    public let visibilityPolicy: VisibilityPolicy
    public let custodyPolicy: CustodyPolicy

    public init(
        id: UUID = UUID(),
        patientUserId: UUID? = nil,
        serviceId: UUID,
        requestedByActor: String,
        rationale: String,
        legalRetention: LegalRetentionObligation,
        visibilityPolicy: VisibilityPolicy,
        custodyPolicy: CustodyPolicy
    ) {
        self.id = id
        self.patientUserId = patientUserId
        self.serviceId = serviceId
        self.requestedByActor = requestedByActor
        self.rationale = rationale
        self.legalRetention = legalRetention
        self.visibilityPolicy = visibilityPolicy
        self.custodyPolicy = custodyPolicy
    }
}

public enum SignatureProviderKind: String, Codable, Sendable {
    case none
    case localScaffold = "local-scaffold"
    case qualifiedProviderPlaceholder = "qualified-provider-placeholder"
}

public enum DocumentLegalSignatureStatus: String, Codable, Sendable {
    case unsigned
    case signatureRequested = "signature_requested"
    case signedUnverified = "signed_unverified"
    case verifiedQualifiedPlaceholder = "verified_qualified_placeholder"
    case invalid
    case unsupported
}

public struct DigitalSignatureRequest: Codable, Sendable {
    public let id: UUID
    public let documentRef: StorageObjectRef
    public let documentHash: String
    public let sourceDraftId: UUID
    public let gateRequestId: UUID
    public let gateResolutionId: UUID
    public let gateApproved: Bool
    public let signerUserId: UUID
    public let signerProfessionalRecordId: UUID?
    public let signatureProviderKind: SignatureProviderKind
    public let certificateRefPlaceholder: String?
    public let requestedAt: Date
    public let signedAt: Date?
    public let verificationStatus: String
    public let legalStatus: DocumentLegalSignatureStatus
    public let provenanceRefs: [UUID]

    public init(
        id: UUID = UUID(),
        documentRef: StorageObjectRef,
        documentHash: String,
        sourceDraftId: UUID,
        gateRequestId: UUID,
        gateResolutionId: UUID,
        gateApproved: Bool,
        signerUserId: UUID,
        signerProfessionalRecordId: UUID? = nil,
        signatureProviderKind: SignatureProviderKind,
        certificateRefPlaceholder: String? = nil,
        requestedAt: Date = .now,
        signedAt: Date? = nil,
        verificationStatus: String,
        legalStatus: DocumentLegalSignatureStatus,
        provenanceRefs: [UUID] = []
    ) {
        self.id = id
        self.documentRef = documentRef
        self.documentHash = documentHash
        self.sourceDraftId = sourceDraftId
        self.gateRequestId = gateRequestId
        self.gateResolutionId = gateResolutionId
        self.gateApproved = gateApproved
        self.signerUserId = signerUserId
        self.signerProfessionalRecordId = signerProfessionalRecordId
        self.signatureProviderKind = signatureProviderKind
        self.certificateRefPlaceholder = certificateRefPlaceholder
        self.requestedAt = requestedAt
        self.signedAt = signedAt
        self.verificationStatus = verificationStatus
        self.legalStatus = legalStatus
        self.provenanceRefs = provenanceRefs
    }
}

public struct SignatureEnvelope: Codable, Sendable {
    public let requestId: UUID
    public let envelopeHash: String
    public let detachedPayloadRef: String
    public let legalStatus: DocumentLegalSignatureStatus
}

public enum InteroperabilityProfile: String, Codable, Sendable {
    case fhirR4 = "fhir-r4"
    case rndsScaffold = "rnds-scaffold"
    case tissScaffold = "tiss-scaffold"
}

public enum InteroperabilityDeliveryStatus: String, Codable, Sendable {
    case packagePrepared = "package_prepared"
    case validatedScaffold = "validated_scaffold"
    case deliveryPlaceholder = "delivery_placeholder"
}

public struct InteroperabilityPackage: Codable, Sendable {
    public let id: UUID
    public let profile: InteroperabilityProfile
    public let sourceRefs: [StorageObjectRef]
    public let sourceHashes: [String: String]
    public let provenanceRefs: [UUID]
    public let validationReport: String
    public let externalDeliveryPerformed: Bool
    public let deliveryStatus: InteroperabilityDeliveryStatus
}

public struct ProbativeDocumentLineage: Codable, Sendable {
    public let sourceDraftId: UUID
    public let gateRequestId: UUID
    public let gateResolutionId: UUID
    public let finalDocumentRef: StorageObjectRef
    public let documentHash: String
    public let signerUserId: UUID?
    public let signerProfessionalRecordId: UUID?
    public let signatureEnvelopeRef: String?
    public let provenanceChain: [UUID]
    public let retentionClass: RetentionClass
    public let exportPackageRefs: [String]
    public let auditPackageRefs: [String]
}

public enum RegulatoryGovernanceFailure: Error, LocalizedError, Sendable {
    case legalBasisRequired
    case rationaleRequired
    case scopeRequired
    case durationRequired
    case coreMediationRequired
    case packageLayerOutsideScope
    case externalDeliveryIsPlaceholderOnly
    case emergencyAuthorityDenied
    case retentionDecisionRequired
    case deletionDeniedByRetention
    case anonymizationRationaleRequired
    case signatureRequiresFinalDocument
    case signatureRequiresApprovedGate
    case signatureRequiresDocumentHash
    case providerUnavailableRemainsUnsigned
    case qualifiedPlaceholderRequiresProfessionalSigner
    case interoperabilityProfileRequired
    case interoperabilityMustPreserveSourceLineage
    case interoperabilityExternalDeliveryPlaceholderOnly

    public var errorDescription: String? {
        switch self {
        case .legalBasisRequired: return "Regulatory audit request requires legal basis."
        case .rationaleRequired: return "Governed request requires rationale."
        case .scopeRequired: return "Governed request requires explicit scope."
        case .durationRequired: return "Emergency access requires explicit duration."
        case .coreMediationRequired: return "Request must run through Core-mediated contract."
        case .packageLayerOutsideScope: return "Package includes data layer outside approved scope."
        case .externalDeliveryIsPlaceholderOnly: return "External delivery remains placeholder in current scaffold."
        case .emergencyAuthorityDenied: return "AACI/GOS cannot act as emergency/regulatory authority."
        case .retentionDecisionRequired: return "Retention governance decision is required before destructive action."
        case .deletionDeniedByRetention: return "Deletion eligibility cannot override legal retention obligation."
        case .anonymizationRationaleRequired: return "Anonymization decision requires explicit rationale."
        case .signatureRequiresFinalDocument: return "Digital signature requires finalized document lineage."
        case .signatureRequiresApprovedGate: return "Digital signature requires approved gate resolution."
        case .signatureRequiresDocumentHash: return "Digital signature requires document hash."
        case .providerUnavailableRemainsUnsigned: return "Without real provider/certificate, legal status must remain unsigned or signature_requested."
        case .qualifiedPlaceholderRequiresProfessionalSigner: return "Qualified placeholder status requires signer professional record reference."
        case .interoperabilityProfileRequired: return "Interoperability export requires profile."
        case .interoperabilityMustPreserveSourceLineage: return "Interoperability package must preserve source refs, hashes, and provenance."
        case .interoperabilityExternalDeliveryPlaceholderOnly: return "External interoperability delivery remains placeholder in this scaffold."
        }
    }
}

public enum RegulatoryGovernanceEventKind: String, Codable, Sendable {
    case regulatoryAuditRequested = "regulatory.audit.requested"
    case regulatoryAuditDenied = "regulatory.audit.denied"
    case regulatoryAuditPackagePrepared = "regulatory.audit.package_prepared"
    case emergencyAccessRequested = "emergency_access.requested"
    case emergencyAccessGranted = "emergency_access.granted"
    case emergencyAccessExpired = "emergency_access.expired"
    case emergencyAccessRevoked = "emergency_access.revoked"
    case emergencyAccessPostReviewRequired = "emergency_access.post_review_required"
    case retentionVisibilityDecision = "retention.visibility_decision"
    case signatureRequested = "signature.requested"
    case signatureCompletedPlaceholder = "signature.completed_placeholder"
    case signatureVerificationFailed = "signature.verification_failed"
    case interoperabilityPackagePrepared = "interoperability.package_prepared"
    case interoperabilityValidationFailed = "interoperability.validation_failed"
}

public struct RegulatoryGovernanceEvent: Codable, Sendable {
    public let id: UUID
    public let kind: RegulatoryGovernanceEventKind
    public let actor: String
    public let timestamp: Date
    public let attributes: [String: String]

    public init(id: UUID = UUID(), kind: RegulatoryGovernanceEventKind, actor: String, timestamp: Date = .now, attributes: [String: String]) {
        self.id = id
        self.kind = kind
        self.actor = actor
        self.timestamp = timestamp
        self.attributes = attributes
    }
}

public enum RegulatoryGovernanceValidator {
    public static func validateRegulatoryAuditRequest(_ request: RegulatoryAuditRequest) throws {
        guard request.viaCoreMediation else { throw RegulatoryGovernanceFailure.coreMediationRequired }
        guard request.legalBasis.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.legalBasisRequired
        }
        guard request.rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.rationaleRequired
        }
        guard request.requestedScope.operations.isEmpty == false else {
            throw RegulatoryGovernanceFailure.scopeRequired
        }
        guard request.requestedDataLayers.isEmpty == false else {
            throw RegulatoryGovernanceFailure.scopeRequired
        }
        _ = try LawfulContextValidator.validate(
            request.lawfulContext,
            requirements: .init(requireServiceId: true, requireFinalidade: true)
        )
        try validateAuthoritySource(request.requestedByActor)
    }

    public static func validateRegulatoryAuditPackage(
        request: RegulatoryAuditRequest,
        package: RegulatoryAuditPackage
    ) throws {
        for layer in package.includedDataLayers where request.requestedDataLayers.contains(layer) == false {
            throw RegulatoryGovernanceFailure.packageLayerOutsideScope
        }
        if package.externalDelivery {
            guard package.externalDeliveryMode == InteroperabilityDeliveryStatus.deliveryPlaceholder.rawValue else {
                throw RegulatoryGovernanceFailure.externalDeliveryIsPlaceholderOnly
            }
        }
    }

    public static func validateEmergencyAccessRequest(_ request: EmergencyAccessRequest) throws {
        guard request.emergencyRationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.rationaleRequired
        }
        guard request.requestedScope.isEmpty == false else {
            throw RegulatoryGovernanceFailure.scopeRequired
        }
        guard request.requestedDurationMinutes > 0 else {
            throw RegulatoryGovernanceFailure.durationRequired
        }
        _ = try LawfulContextValidator.validate(
            request.lawfulContext,
            requirements: .init(requireServiceId: true, requirePatientUserId: true, requireFinalidade: true)
        )
        try validateAuthoritySource(request.requestedBySource)
    }

    public static func validateBreakGlassGrant(_ grant: BreakGlassAccessGrant, now: Date = .now) throws {
        guard grant.grantedDurationMinutes > 0 else {
            throw RegulatoryGovernanceFailure.durationRequired
        }
        guard grant.expiresAt > now else {
            throw RegulatoryGovernanceFailure.durationRequired
        }
    }

    public static func validateRetentionVisibilityDecision(_ decision: RetentionVisibilityDecision) throws {
        guard decision.rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.rationaleRequired
        }
        guard decision.legalRetention.minimumRetentionDays >= 0 else {
            throw RegulatoryGovernanceFailure.retentionDecisionRequired
        }
        if decision.legalRetention.serviceCustodyRequired && decision.custodyPolicy.deletionEligible {
            throw RegulatoryGovernanceFailure.deletionDeniedByRetention
        }
        if decision.custodyPolicy.anonymizationEligible && decision.rationale.count < 10 {
            throw RegulatoryGovernanceFailure.anonymizationRationaleRequired
        }
    }

    public static func validateDeletionEligibility(decision: RetentionVisibilityDecision?) throws {
        guard let decision else { throw RegulatoryGovernanceFailure.retentionDecisionRequired }
        guard decision.custodyPolicy.deletionEligible else {
            throw RegulatoryGovernanceFailure.deletionDeniedByRetention
        }
    }

    public static func validateDigitalSignatureRequest(_ request: DigitalSignatureRequest) throws {
        guard request.sourceDraftId != UUID() else { throw RegulatoryGovernanceFailure.signatureRequiresFinalDocument }
        guard request.gateRequestId != UUID(), request.gateResolutionId != UUID(), request.gateApproved else {
            throw RegulatoryGovernanceFailure.signatureRequiresApprovedGate
        }
        guard request.documentHash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.signatureRequiresDocumentHash
        }
        if request.signatureProviderKind == .none {
            guard request.legalStatus == .unsigned || request.legalStatus == .signatureRequested else {
                throw RegulatoryGovernanceFailure.providerUnavailableRemainsUnsigned
            }
        }
        if request.legalStatus == .verifiedQualifiedPlaceholder {
            guard request.signerProfessionalRecordId != nil else {
                throw RegulatoryGovernanceFailure.qualifiedPlaceholderRequiresProfessionalSigner
            }
        }
    }

    public static func validateInteroperabilityPackage(_ package: InteroperabilityPackage) throws {
        guard package.sourceRefs.isEmpty == false else {
            throw RegulatoryGovernanceFailure.interoperabilityProfileRequired
        }
        guard package.sourceHashes.isEmpty == false, package.provenanceRefs.isEmpty == false else {
            throw RegulatoryGovernanceFailure.interoperabilityMustPreserveSourceLineage
        }
        if package.externalDeliveryPerformed {
            guard package.deliveryStatus == .deliveryPlaceholder else {
                throw RegulatoryGovernanceFailure.interoperabilityExternalDeliveryPlaceholderOnly
            }
        }
    }

    public static func validateProbativeLineage(_ lineage: ProbativeDocumentLineage) throws {
        guard lineage.documentHash.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw RegulatoryGovernanceFailure.signatureRequiresDocumentHash
        }
        guard lineage.provenanceChain.isEmpty == false else {
            throw RegulatoryGovernanceFailure.signatureRequiresFinalDocument
        }
        if lineage.signatureEnvelopeRef != nil {
            guard lineage.signerProfessionalRecordId != nil else {
                throw RegulatoryGovernanceFailure.qualifiedPlaceholderRequiresProfessionalSigner
            }
        }
    }

    private static func validateAuthoritySource(_ source: String) throws {
        let lowercased = source.lowercased()
        if lowercased == "aaci" || lowercased == "gos" {
            throw RegulatoryGovernanceFailure.emergencyAuthorityDenied
        }
    }
}
