import Foundation

public enum ServiceActorRole: String, Codable, Sendable {
    case serviceAdmin = "service_admin"
    case operationalCoordinator = "operational_coordinator"
    case professional
    case billingAdmin = "billing_admin"
    case observerAuditor = "observer_auditor"
}

public enum ServiceMembershipStatus: String, Codable, Sendable {
    case active
    case inactive
    case suspended
    case revoked
}

public enum ServiceOperationAction: String, Codable, Sendable {
    case queueRead = "queue:read"
    case queueAssign = "queue:assign"
    case gateWorklistRead = "gate:worklist:read"
    case gateResolveClinical = "gate:resolve:clinical"
    case professionalSessionStart = "professional:session:start"
    case professionalDocumentDraft = "professional:document:draft"
    case professionalDocumentFinalize = "professional:document:finalize"
    case serviceDocumentRead = "service:document:read"
    case serviceDocumentDraftRead = "service:draft:read"
    case serviceTaskWrite = "service:task:write"
}

public enum ServiceRelationshipStatus: String, Codable, Sendable {
    case active
    case inactive
    case suspended
    case archived
}

public enum ServiceVisibilityStatus: String, Codable, Sendable {
    case visible
    case restricted
    case hidden
}

public enum QueueItemKind: String, Codable, Sendable {
    case sessionAwaitingDocumentation = "session_awaiting_documentation"
    case draftAwaitingGate = "draft_awaiting_gate"
    case documentPendingReview = "document_pending_review"
    case exportPendingPreparation = "export_pending_preparation"
    case auditRequestPendingResponse = "audit_request_pending_response"
    case administrativeTask = "administrative_task"
    case providerJobTaskStatus = "provider_job_task_status"
}

public enum ServiceDocumentStatus: String, Codable, Sendable {
    case draft
    case awaitingGate = "awaiting_gate"
    case approved
    case rejected
    case final
}

public enum GateWorklistStatus: String, Codable, Sendable {
    case pending
    case inReview = "in_review"
    case resolved
}

public enum AdministrativeTaskKind: String, Codable, Sendable {
    case requestMissingDocument = "request_missing_document"
    case notifyPendingGate = "notify_pending_gate"
    case prepareExportPackageRequest = "prepare_export_package_request"
    case scheduleOperationalFollowUp = "schedule_operational_follow_up"
    case assignAdministrativeOwner = "assign_administrative_owner"
    case reconcileIncompleteMetadata = "reconcile_incomplete_metadata"
    case reviewAuditResponseStatus = "review_audit_response_status"
    case diagnose
    case prescribe
    case issueReferral = "issue_referral"
    case finalizeClinicalDocument = "finalize_clinical_document"
    case signDocument = "sign_document"
    case alterProfessionalHabilitationDirectly = "alter_professional_habilitation_directly"
    case overridePatientConsent = "override_patient_consent"
    case overrideRetentionPolicy = "override_retention_policy"
}

public enum ProfessionalHabilitationStatus: String, Codable, Sendable {
    case active
    case inactive
    case expired
    case suspended
    case revoked
}

public struct ServiceOperationalContext: Codable, Sendable {
    public let serviceId: UUID
    public let actorId: String
    public let actorRole: ServiceActorRole
    public let memberId: UUID?
    public let professionalUserId: UUID?
    public let patientUserId: UUID?
    public let lawfulContext: [String: String]
    public let finalidade: String?
    public let scope: String
    public let allowedOperations: [ServiceOperationAction]
    public let deniedOperations: [ServiceOperationAction]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]
    public let viaCoreMediation: Bool

    public init(
        serviceId: UUID,
        actorId: String,
        actorRole: ServiceActorRole,
        memberId: UUID? = nil,
        professionalUserId: UUID? = nil,
        patientUserId: UUID? = nil,
        lawfulContext: [String: String],
        finalidade: String? = nil,
        scope: String,
        allowedOperations: [ServiceOperationAction],
        deniedOperations: [ServiceOperationAction] = [],
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = [],
        viaCoreMediation: Bool
    ) {
        self.serviceId = serviceId
        self.actorId = actorId
        self.actorRole = actorRole
        self.memberId = memberId
        self.professionalUserId = professionalUserId
        self.patientUserId = patientUserId
        self.lawfulContext = lawfulContext
        self.finalidade = finalidade
        self.scope = scope
        self.allowedOperations = allowedOperations
        self.deniedOperations = deniedOperations
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.viaCoreMediation = viaCoreMediation
    }
}

public struct ServiceMembershipContract: Codable, Sendable {
    public let memberId: UUID
    public let serviceId: UUID
    public let role: ServiceActorRole
    public let status: ServiceMembershipStatus
    public let professionalUserId: UUID?
    public let professionalRecordId: UUID?
    public let habilitationId: UUID?
    public let provenanceRef: UUID?
    public let auditRef: UUID?

    public init(
        memberId: UUID,
        serviceId: UUID,
        role: ServiceActorRole,
        status: ServiceMembershipStatus,
        professionalUserId: UUID? = nil,
        professionalRecordId: UUID? = nil,
        habilitationId: UUID? = nil,
        provenanceRef: UUID? = nil,
        auditRef: UUID? = nil
    ) {
        self.memberId = memberId
        self.serviceId = serviceId
        self.role = role
        self.status = status
        self.professionalUserId = professionalUserId
        self.professionalRecordId = professionalRecordId
        self.habilitationId = habilitationId
        self.provenanceRef = provenanceRef
        self.auditRef = auditRef
    }
}

public struct ProfessionalHabilitationSurface: Codable, Sendable {
    public let professionalUserId: UUID
    public let professionalRecordId: UUID
    public let serviceId: UUID
    public let habilitationId: UUID
    public let status: ProfessionalHabilitationStatus
    public let allowedScope: [String]
    public let validFrom: Date
    public let validUntil: Date?
    public let restrictions: [String]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]
    public let appSafeInformational: Bool
    public let decidedByCore: Bool

    public init(
        professionalUserId: UUID,
        professionalRecordId: UUID,
        serviceId: UUID,
        habilitationId: UUID,
        status: ProfessionalHabilitationStatus,
        allowedScope: [String],
        validFrom: Date,
        validUntil: Date? = nil,
        restrictions: [String] = [],
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = [],
        appSafeInformational: Bool,
        decidedByCore: Bool
    ) {
        self.professionalUserId = professionalUserId
        self.professionalRecordId = professionalRecordId
        self.serviceId = serviceId
        self.habilitationId = habilitationId
        self.status = status
        self.allowedScope = allowedScope
        self.validFrom = validFrom
        self.validUntil = validUntil
        self.restrictions = restrictions
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.appSafeInformational = appSafeInformational
        self.decidedByCore = decidedByCore
    }
}

public struct ConsentSummarySurface: Codable, Sendable {
    public let finalidade: String
    public let granted: Bool
    public let expiresAt: Date?

    public init(finalidade: String, granted: Bool, expiresAt: Date? = nil) {
        self.finalidade = finalidade
        self.granted = granted
        self.expiresAt = expiresAt
    }
}

public struct PatientServiceRelationshipSurface: Codable, Sendable {
    public let serviceId: UUID
    public let patientUserId: UUID
    public let relationshipStatus: ServiceRelationshipStatus
    public let consentSummary: [ConsentSummarySurface]
    public let visibilityStatus: ServiceVisibilityStatus
    public let retentionCustodyMarkers: [String]
    public let activeSessionRefs: [UUID]
    public let accessRestrictions: [String]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]
    public let appSafePatientRef: String
    public let directIdentifiersExposed: Bool

    public init(
        serviceId: UUID,
        patientUserId: UUID,
        relationshipStatus: ServiceRelationshipStatus,
        consentSummary: [ConsentSummarySurface],
        visibilityStatus: ServiceVisibilityStatus,
        retentionCustodyMarkers: [String],
        activeSessionRefs: [UUID] = [],
        accessRestrictions: [String],
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = [],
        appSafePatientRef: String,
        directIdentifiersExposed: Bool
    ) {
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.relationshipStatus = relationshipStatus
        self.consentSummary = consentSummary
        self.visibilityStatus = visibilityStatus
        self.retentionCustodyMarkers = retentionCustodyMarkers
        self.activeSessionRefs = activeSessionRefs
        self.accessRestrictions = accessRestrictions
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.appSafePatientRef = appSafePatientRef
        self.directIdentifiersExposed = directIdentifiersExposed
    }
}

public struct ServiceQueueItem: Codable, Sendable {
    public let id: UUID
    public let serviceId: UUID
    public let kind: QueueItemKind
    public let status: String
    public let lawfulScopeSummary: String
    public let coreMediatedActionRef: String
    public let appSafeSummary: String
    public let containsSensitivePayload: Bool
    public let grantsAccessByItself: Bool
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        id: UUID = UUID(),
        serviceId: UUID,
        kind: QueueItemKind,
        status: String,
        lawfulScopeSummary: String,
        coreMediatedActionRef: String,
        appSafeSummary: String,
        containsSensitivePayload: Bool,
        grantsAccessByItself: Bool,
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = []
    ) {
        self.id = id
        self.serviceId = serviceId
        self.kind = kind
        self.status = status
        self.lawfulScopeSummary = lawfulScopeSummary
        self.coreMediatedActionRef = coreMediatedActionRef
        self.appSafeSummary = appSafeSummary
        self.containsSensitivePayload = containsSensitivePayload
        self.grantsAccessByItself = grantsAccessByItself
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public struct ServiceDocumentSurface: Codable, Sendable {
    public let artifactOrDraftId: UUID
    public let kind: DraftKind
    public let status: ServiceDocumentStatus
    public let patientRef: String
    public let professionalRef: String
    public let gateStatus: GateRequestStatus
    public let finalizationStatus: String
    public let provenanceRefs: [UUID]
    public let createdAt: Date
    public let updatedAt: Date
    public let accessScopeSummary: String
    public let contentExposedRaw: Bool
    public let coreTransitionOnly: Bool

    public init(
        artifactOrDraftId: UUID,
        kind: DraftKind,
        status: ServiceDocumentStatus,
        patientRef: String,
        professionalRef: String,
        gateStatus: GateRequestStatus,
        finalizationStatus: String,
        provenanceRefs: [UUID],
        createdAt: Date,
        updatedAt: Date,
        accessScopeSummary: String,
        contentExposedRaw: Bool,
        coreTransitionOnly: Bool
    ) {
        self.artifactOrDraftId = artifactOrDraftId
        self.kind = kind
        self.status = status
        self.patientRef = patientRef
        self.professionalRef = professionalRef
        self.gateStatus = gateStatus
        self.finalizationStatus = finalizationStatus
        self.provenanceRefs = provenanceRefs
        self.createdAt = createdAt
        self.updatedAt = updatedAt
        self.accessScopeSummary = accessScopeSummary
        self.contentExposedRaw = contentExposedRaw
        self.coreTransitionOnly = coreTransitionOnly
    }
}

public struct GateWorklistItem: Codable, Sendable {
    public let gateRequestId: UUID
    public let targetArtifactOrDraftRef: String
    public let requiredRole: ServiceActorRole
    public let assignedProfessionalUserId: UUID?
    public let status: GateWorklistStatus
    public let createdAt: Date
    public let rationaleSummarySafe: String
    public let provenanceRefs: [UUID]

    public init(
        gateRequestId: UUID,
        targetArtifactOrDraftRef: String,
        requiredRole: ServiceActorRole,
        assignedProfessionalUserId: UUID? = nil,
        status: GateWorklistStatus,
        createdAt: Date,
        rationaleSummarySafe: String,
        provenanceRefs: [UUID] = []
    ) {
        self.gateRequestId = gateRequestId
        self.targetArtifactOrDraftRef = targetArtifactOrDraftRef
        self.requiredRole = requiredRole
        self.assignedProfessionalUserId = assignedProfessionalUserId
        self.status = status
        self.createdAt = createdAt
        self.rationaleSummarySafe = rationaleSummarySafe
        self.provenanceRefs = provenanceRefs
    }
}

public struct ServiceAdministrativeTask: Codable, Sendable {
    public let id: UUID
    public let serviceId: UUID
    public let requestedByActorId: String
    public let requestedByRole: ServiceActorRole
    public let kind: AdministrativeTaskKind
    public let lawfulContext: [String: String]
    public let finalidade: String
    public let consentValidated: Bool
    public let habilitationValidated: Bool
    public let generatedAuditRef: UUID?
    public let generatedProvenanceRef: UUID?

    public init(
        id: UUID = UUID(),
        serviceId: UUID,
        requestedByActorId: String,
        requestedByRole: ServiceActorRole,
        kind: AdministrativeTaskKind,
        lawfulContext: [String: String],
        finalidade: String,
        consentValidated: Bool,
        habilitationValidated: Bool,
        generatedAuditRef: UUID? = nil,
        generatedProvenanceRef: UUID? = nil
    ) {
        self.id = id
        self.serviceId = serviceId
        self.requestedByActorId = requestedByActorId
        self.requestedByRole = requestedByRole
        self.kind = kind
        self.lawfulContext = lawfulContext
        self.finalidade = finalidade
        self.consentValidated = consentValidated
        self.habilitationValidated = habilitationValidated
        self.generatedAuditRef = generatedAuditRef
        self.generatedProvenanceRef = generatedProvenanceRef
    }
}

public enum ServiceOperationsFailure: Error, LocalizedError, Equatable, Sendable {
    case missingLawfulContext
    case missingFinalidade
    case cloudClinicMustBeMediated
    case inactiveMembership
    case suspendedOrRevokedMembership
    case administrativeRoleCannotPerformProfessionalAction
    case professionalRequiresRecordAndHabilitation
    case professionalHabilitationInactive
    case professionalHabilitationExpired
    case relationshipDoesNotReplaceConsent
    case retentionDoesNotGrantUnrestrictedAccess
    case directIdentifierExposureDenied
    case queueDoesNotGrantAccess
    case queueMissingLawfulScopeSummary
    case queueRawPayloadExposureDenied
    case draftCannotBeFinal
    case finalRequiresApprovedGate
    case pendingGateIsNotApproval
    case adminCannotResolveProfessionalGate
    case cloudClinicCannotFinalizeDirectly
    case prohibitedAdministrativeTask
    case administrativeTaskCannotBypassGovernance
    case sensitiveTaskRequiresAuditAndProvenance

    public var errorDescription: String? {
        switch self {
        case .missingLawfulContext:
            return "Service operation requires lawfulContext."
        case .missingFinalidade:
            return "Sensitive service operation requires finalidade."
        case .cloudClinicMustBeMediated:
            return "CloudClinic must consume Core-mediated surfaces."
        case .inactiveMembership:
            return "Inactive member cannot operate."
        case .suspendedOrRevokedMembership:
            return "Suspended or revoked member cannot operate."
        case .administrativeRoleCannotPerformProfessionalAction:
            return "Administrative role cannot perform professional action."
        case .professionalRequiresRecordAndHabilitation:
            return "Professional role requires record and habilitation linkage."
        case .professionalHabilitationInactive:
            return "Professional habilitation is not active."
        case .professionalHabilitationExpired:
            return "Professional habilitation is expired."
        case .relationshipDoesNotReplaceConsent:
            return "Patient-service relationship does not replace consent/finalidade."
        case .retentionDoesNotGrantUnrestrictedAccess:
            return "Retention/custody does not imply unrestricted access."
        case .directIdentifierExposureDenied:
            return "Direct identifier exposure is denied for app-safe surfaces."
        case .queueDoesNotGrantAccess:
            return "Queue items cannot grant access by themselves."
        case .queueMissingLawfulScopeSummary:
            return "Queue item must carry lawful scope summary and mediated action ref."
        case .queueRawPayloadExposureDenied:
            return "Queue item summary cannot expose raw sensitive payload by default."
        case .draftCannotBeFinal:
            return "Draft surface cannot be labeled as final."
        case .finalRequiresApprovedGate:
            return "Final document requires approved gate."
        case .pendingGateIsNotApproval:
            return "Pending gate is not approval."
        case .adminCannotResolveProfessionalGate:
            return "Administrative role cannot resolve professional clinical gate."
        case .cloudClinicCannotFinalizeDirectly:
            return "CloudClinic cannot finalize documents directly."
        case .prohibitedAdministrativeTask:
            return "Administrative task kind is prohibited."
        case .administrativeTaskCannotBypassGovernance:
            return "Administrative task cannot bypass consent/habilitation/finality."
        case .sensitiveTaskRequiresAuditAndProvenance:
            return "Sensitive administrative tasks must emit audit and provenance refs."
        }
    }
}

public enum ServiceOperationsValidator {
    public static func validateContext(_ context: ServiceOperationalContext, sensitive: Bool) throws {
        _ = try LawfulContextValidator.validate(
            context.lawfulContext,
            requirements: .init(requireServiceId: true, requireFinalidade: sensitive)
        )
        guard context.viaCoreMediation else {
            throw ServiceOperationsFailure.cloudClinicMustBeMediated
        }
        if sensitive,
           context.finalidade?.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty != false {
            throw ServiceOperationsFailure.missingFinalidade
        }
        if context.actorRole != .professional {
            let forbidden: Set<ServiceOperationAction> = [.professionalSessionStart, .professionalDocumentDraft, .professionalDocumentFinalize, .gateResolveClinical]
            if !forbidden.isDisjoint(with: context.allowedOperations) {
                throw ServiceOperationsFailure.administrativeRoleCannotPerformProfessionalAction
            }
        }
    }

    public static func validateMembership(_ membership: ServiceMembershipContract) throws {
        switch membership.status {
        case .inactive:
            throw ServiceOperationsFailure.inactiveMembership
        case .suspended, .revoked:
            throw ServiceOperationsFailure.suspendedOrRevokedMembership
        case .active:
            break
        }

        if membership.role == .professional {
            guard membership.professionalRecordId != nil,
                  membership.habilitationId != nil,
                  membership.professionalUserId != nil else {
                throw ServiceOperationsFailure.professionalRequiresRecordAndHabilitation
            }
        } else if membership.habilitationId != nil {
            throw ServiceOperationsFailure.administrativeRoleCannotPerformProfessionalAction
        }
    }

    public static func validateProfessionalHabilitation(_ surface: ProfessionalHabilitationSurface, now: Date = .now) throws {
        guard surface.appSafeInformational, surface.decidedByCore else {
            throw ServiceOperationsFailure.cloudClinicMustBeMediated
        }
        guard surface.status == .active else {
            throw ServiceOperationsFailure.professionalHabilitationInactive
        }
        if let validUntil = surface.validUntil, validUntil < now {
            throw ServiceOperationsFailure.professionalHabilitationExpired
        }
    }

    public static func validatePatientServiceRelationship(_ surface: PatientServiceRelationshipSurface) throws {
        guard !surface.directIdentifiersExposed,
              !surface.appSafePatientRef.lowercased().contains("cpf") else {
            throw ServiceOperationsFailure.directIdentifierExposureDenied
        }
        guard !surface.consentSummary.isEmpty,
              surface.consentSummary.contains(where: { $0.granted }) else {
            throw ServiceOperationsFailure.relationshipDoesNotReplaceConsent
        }
        if surface.retentionCustodyMarkers.contains(where: { $0 == "service_retention_obligation" }) &&
            !surface.accessRestrictions.contains("consent-and-finalidade-required") {
            throw ServiceOperationsFailure.retentionDoesNotGrantUnrestrictedAccess
        }
    }

    public static func validateQueueItem(_ item: ServiceQueueItem) throws {
        guard !item.grantsAccessByItself else {
            throw ServiceOperationsFailure.queueDoesNotGrantAccess
        }
        guard !item.lawfulScopeSummary.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty,
              !item.coreMediatedActionRef.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ServiceOperationsFailure.queueMissingLawfulScopeSummary
        }
        if item.containsSensitivePayload,
           item.appSafeSummary.lowercased().contains("raw") {
            throw ServiceOperationsFailure.queueRawPayloadExposureDenied
        }
    }

    public static func validateDocumentSurface(_ document: ServiceDocumentSurface) throws {
        if document.status == .draft,
           document.finalizationStatus == "finalized" {
            throw ServiceOperationsFailure.draftCannotBeFinal
        }
        if document.status == .final,
           document.gateStatus != .approved {
            throw ServiceOperationsFailure.finalRequiresApprovedGate
        }
        if document.gateStatus == .pending,
           document.finalizationStatus == "finalized" {
            throw ServiceOperationsFailure.pendingGateIsNotApproval
        }
        guard !document.contentExposedRaw else {
            throw ServiceOperationsFailure.cloudClinicMustBeMediated
        }
        guard document.coreTransitionOnly else {
            throw ServiceOperationsFailure.cloudClinicCannotFinalizeDirectly
        }
    }

    public static func validateGateWorklistItem(_ item: GateWorklistItem, resolverRole: ServiceActorRole?) throws {
        if item.status == .pending,
           item.requiredRole == .professional,
           resolverRole == .serviceAdmin {
            throw ServiceOperationsFailure.adminCannotResolveProfessionalGate
        }
        if item.status == .pending,
           resolverRole == .operationalCoordinator,
           item.requiredRole == .professional {
            throw ServiceOperationsFailure.adminCannotResolveProfessionalGate
        }
    }

    public static func validateAdministrativeTask(_ task: ServiceAdministrativeTask, sensitive: Bool) throws {
        let allowed: Set<AdministrativeTaskKind> = [
            .requestMissingDocument,
            .notifyPendingGate,
            .prepareExportPackageRequest,
            .scheduleOperationalFollowUp,
            .assignAdministrativeOwner,
            .reconcileIncompleteMetadata,
            .reviewAuditResponseStatus
        ]
        guard allowed.contains(task.kind) else {
            throw ServiceOperationsFailure.prohibitedAdministrativeTask
        }

        if sensitive {
            _ = try LawfulContextValidator.validate(
                task.lawfulContext,
                requirements: .init(requireServiceId: true, requireFinalidade: true)
            )
            guard task.consentValidated,
                  task.habilitationValidated,
                  !task.finalidade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
                throw ServiceOperationsFailure.administrativeTaskCannotBypassGovernance
            }
            guard task.generatedAuditRef != nil,
                  task.generatedProvenanceRef != nil else {
                throw ServiceOperationsFailure.sensitiveTaskRequiresAuditAndProvenance
            }
        }
    }
}
