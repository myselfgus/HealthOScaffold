import Foundation

public enum AppKind: String, Codable, Sendable {
    case scribe = "Scribe"
    case sortio = "Sortio"
    case cloudClinic = "CloudClinic"
}

public enum AppActorRole: String, Codable, Sendable {
    case professional
    case patient
    case serviceAdmin = "service_admin"
    case operationalCoordinator = "operational_coordinator"
    case observerAuditor = "observer_auditor"
}

public enum AppRefCapability: String, Codable, Sendable {
    case navigationOnly = "navigation_only"
    case dataAccessCapable = "data_access_capable"
}

public enum AppRedactionStatus: String, Codable, Sendable {
    case none
    case pseudonymized
    case redacted
    case deidentified
    case restricted
}

public struct SafeRefCore: Codable, Sendable {
    public let refId: String
    public let displayLabel: String?
    public let redactionStatus: AppRedactionStatus
    public let capability: AppRefCapability
    public let grantsDataAccess: Bool
    public let directIdentifierPresent: Bool

    public init(
        refId: String,
        displayLabel: String? = nil,
        redactionStatus: AppRedactionStatus,
        capability: AppRefCapability,
        grantsDataAccess: Bool = false,
        directIdentifierPresent: Bool = false
    ) {
        self.refId = refId
        self.displayLabel = displayLabel
        self.redactionStatus = redactionStatus
        self.capability = capability
        self.grantsDataAccess = grantsDataAccess
        self.directIdentifierPresent = directIdentifierPresent
    }
}

public struct SafeUserRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafePatientRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeProfessionalRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeServiceRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeSessionRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeDraftRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeGateRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeArtifactRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeExportRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeAuditRef: Codable, Sendable { public let core: SafeRefCore }
public struct SafeProvenanceRef: Codable, Sendable { public let core: SafeRefCore }

public struct AppSubjectRefs: Codable, Sendable {
    public let user: SafeUserRef?
    public let patient: SafePatientRef?
    public let professional: SafeProfessionalRef?
    public let service: SafeServiceRef?
    public let session: SafeSessionRef?
    public let draft: SafeDraftRef?
    public let gate: SafeGateRef?
    public let artifact: SafeArtifactRef?
    public let export: SafeExportRef?
    public let audit: SafeAuditRef?
    public let provenance: SafeProvenanceRef?
}

public enum AppActionId: String, Codable, Sendable, CaseIterable {
    case startProfessionalSession = "start_professional_session"
    case submitCapture = "submit_capture"
    case requestContextRetrieval = "request_context_retrieval"
    case requestDraftGeneration = "request_draft_generation"
    case submitGateReview = "submit_gate_review"
    case viewFinalizationStatus = "view_finalization_status"

    case inspectConsent = "inspect_consent"
    case requestConsentRevocation = "request_consent_revocation"
    case inspectAccessAudit = "inspect_access_audit"
    case requestExport = "request_export"
    case askUserAgent = "ask_user_agent"
    case inspectVisibilityStatus = "inspect_visibility_status"

    case inspectQueue = "inspect_queue"
    case inspectPendingGates = "inspect_pending_gates"
    case inspectServicePatients = "inspect_service_patients"
    case inspectOperationalDocuments = "inspect_operational_documents"
    case assignAdministrativeTask = "assign_administrative_task"
    case inspectServiceAuditStatus = "inspect_service_audit_status"
}

public enum AppDeniedActionReason: String, Codable, Sendable {
    case appMismatch = "app_mismatch"
    case roleMismatch = "role_mismatch"
    case missingHabilitation = "missing_habilitation"
    case consentNotAuthorized = "consent_not_authorized"
    case finalityNotAuthorized = "finality_not_authorized"
    case coreMediationRequired = "core_mediation_required"
    case prohibitedByPolicy = "prohibited_by_policy"
}

public struct AppAllowedAction: Codable, Sendable {
    public let action: AppActionId
    public let coreCommandRef: String
    public let requiresCoreMediation: Bool
    public let legalAuthorizing: Bool
}

public struct AppDeniedAction: Codable, Sendable {
    public let action: AppActionId
    public let reason: AppDeniedActionReason
}

public enum AppIssueKind: String, Codable, Sendable {
    case degraded
    case denied
    case warning
}

public struct AppSurfaceIssue: Codable, Sendable {
    public let kind: AppIssueKind
    public let code: String
    public let message: String
}

public struct RedactionSurfaceStatus: Codable, Sendable {
    public let status: AppRedactionStatus
    public let directIdentifierPresent: Bool
    public let reidentificationRequired: Bool
    public let reidentificationAllowed: Bool
    public let reason: String
    public let lawfulScopeSummary: String
}

public struct AppSurfaceEnvelope: Codable, Sendable {
    public let requestId: UUID
    public let appKind: AppKind
    public let actorRole: AppActorRole
    public let subjectRefs: AppSubjectRefs
    public let allowedActions: [AppAllowedAction]
    public let deniedActions: [AppDeniedAction]
    public let issues: [AppSurfaceIssue]
    public let provenanceRefs: [SafeProvenanceRef]
    public let auditRefs: [SafeAuditRef]
    public let redaction: RedactionSurfaceStatus
    public let generatedAt: Date
    public let legalAuthorizing: Bool

    public init(
        requestId: UUID = UUID(),
        appKind: AppKind,
        actorRole: AppActorRole,
        subjectRefs: AppSubjectRefs,
        allowedActions: [AppAllowedAction],
        deniedActions: [AppDeniedAction],
        issues: [AppSurfaceIssue] = [],
        provenanceRefs: [SafeProvenanceRef] = [],
        auditRefs: [SafeAuditRef] = [],
        redaction: RedactionSurfaceStatus,
        generatedAt: Date = Date(),
        legalAuthorizing: Bool = false
    ) {
        self.requestId = requestId
        self.appKind = appKind
        self.actorRole = actorRole
        self.subjectRefs = subjectRefs
        self.allowedActions = allowedActions
        self.deniedActions = deniedActions
        self.issues = issues
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.redaction = redaction
        self.generatedAt = generatedAt
        self.legalAuthorizing = legalAuthorizing
    }
}

public enum AppNotificationKind: String, Codable, Sendable {
    case gatePending = "gate_pending"
    case documentFinalized = "document_finalized"
    case consentChanged = "consent_changed"
    case exportReady = "export_ready"
    case emergencyAccessOccurred = "emergency_access_occurred"
    case regulatoryAuditOccurred = "regulatory_audit_occurred"
    case signatureRequested = "signature_requested"
    case signatureStatusChanged = "signature_status_changed"
    case backupExportFailed = "backup_export_failed"
    case providerDegraded = "provider_degraded"
    case asyncJobFailed = "async_job_failed"
}

public struct AppNotificationSurface: Codable, Sendable {
    public let id: UUID
    public let appKind: AppKind
    public let actorRole: AppActorRole
    public let kind: AppNotificationKind
    public let summary: String
    public let refs: AppSubjectRefs
    public let payloadContainsSensitiveData: Bool
    public let grantsAccess: Bool
}

public struct NotificationObligationRecord: Codable, Sendable {
    public let obligationId: UUID
    public let kind: AppNotificationKind
    public let patientUserRef: SafeUserRef?
    public let markedComplete: Bool
    public let completionRecordedAt: Date?
    public let completionRecordRef: SafeAuditRef?
}

public enum CrossAppSurfaceFailure: Error, Equatable {
    case legalAuthorizingMustBeFalse
    case actionNotMediated
    case appMismatch(AppActionId)
    case roleMismatch(AppActionId)
    case deniedReasonRequired(AppActionId)
    case degradedIssueMissing
    case rawSensitiveLeak
    case directIdentifierForbidden
    case navigationRefCannotGrantAccess
    case reidentificationNotAllowedByDefault
    case patientObligationRequiresRecordedCompletion
}

public enum CrossAppSurfaceValidator {
    public static func validateEnvelope(_ envelope: AppSurfaceEnvelope) throws {
        guard envelope.legalAuthorizing == false else {
            throw CrossAppSurfaceFailure.legalAuthorizingMustBeFalse
        }
        for action in envelope.allowedActions {
            guard action.requiresCoreMediation, action.legalAuthorizing == false,
                  action.coreCommandRef.hasPrefix("core://") else {
                throw CrossAppSurfaceFailure.actionNotMediated
            }
            guard allowedActions(for: envelope.appKind, role: envelope.actorRole).contains(action.action) else {
                if allowedActions(for: envelope.appKind, role: nil).contains(action.action) {
                    throw CrossAppSurfaceFailure.roleMismatch(action.action)
                }
                throw CrossAppSurfaceFailure.appMismatch(action.action)
            }
        }

        let deniedLookup = Dictionary(uniqueKeysWithValues: envelope.deniedActions.map { ($0.action, $0.reason) })
        for denied in envelope.deniedActions where denied.reason.rawValue.isEmpty {
            throw CrossAppSurfaceFailure.deniedReasonRequired(denied.action)
        }
        for action in envelope.allowedActions where deniedLookup[action.action] != nil {
            throw CrossAppSurfaceFailure.actionNotMediated
        }

        if envelope.issues.contains(where: { $0.kind == .degraded }) &&
            envelope.allowedActions.isEmpty &&
            envelope.deniedActions.isEmpty {
            throw CrossAppSurfaceFailure.degradedIssueMissing
        }

        if envelope.redaction.directIdentifierPresent {
            throw CrossAppSurfaceFailure.directIdentifierForbidden
        }
        if envelope.redaction.reidentificationAllowed {
            throw CrossAppSurfaceFailure.reidentificationNotAllowedByDefault
        }

        try validateRefs(envelope.subjectRefs)
        try envelope.auditRefs.forEach { try validateRefCore($0.core) }
        try envelope.provenanceRefs.forEach { try validateRefCore($0.core) }
    }

    public static func validateNotification(_ notification: AppNotificationSurface) throws {
        guard notification.payloadContainsSensitiveData == false,
              notification.grantsAccess == false else {
            throw CrossAppSurfaceFailure.rawSensitiveLeak
        }
        guard allowedNotificationApps(kind: notification.kind).contains(notification.appKind) else {
            throw CrossAppSurfaceFailure.appMismatch(.inspectAccessAudit)
        }
        try validateRefs(notification.refs)

        let lowercase = notification.summary.lowercased()
        let forbiddenMarkers = ["cpf", "storage/", "provider_secret", "api-key", "reidentification_map", "gos-spec"]
        if forbiddenMarkers.contains(where: { lowercase.contains($0) }) {
            throw CrossAppSurfaceFailure.rawSensitiveLeak
        }
    }

    public static func validateNotificationObligation(_ record: NotificationObligationRecord) throws {
        if record.markedComplete && (record.completionRecordRef == nil || record.completionRecordedAt == nil) {
            throw CrossAppSurfaceFailure.patientObligationRequiresRecordedCompletion
        }
    }

    public static func validateRefCore(_ ref: SafeRefCore) throws {
        if ref.directIdentifierPresent {
            throw CrossAppSurfaceFailure.directIdentifierForbidden
        }
        if ref.capability == .navigationOnly && ref.grantsDataAccess {
            throw CrossAppSurfaceFailure.navigationRefCannotGrantAccess
        }
        let marker = ref.displayLabel?.lowercased() ?? ""
        if marker.contains("cpf") || marker.contains("storage/") || marker.contains("reidentification") {
            throw CrossAppSurfaceFailure.rawSensitiveLeak
        }
    }

    private static func validateRefs(_ refs: AppSubjectRefs) throws {
        let all: [SafeRefCore?] = [
            refs.user?.core,
            refs.patient?.core,
            refs.professional?.core,
            refs.service?.core,
            refs.session?.core,
            refs.draft?.core,
            refs.gate?.core,
            refs.artifact?.core,
            refs.export?.core,
            refs.audit?.core,
            refs.provenance?.core
        ]
        try all.compactMap { $0 }.forEach(validateRefCore)
    }

    private static func allowedActions(for app: AppKind, role: AppActorRole?) -> Set<AppActionId> {
        switch app {
        case .scribe:
            guard role == .professional || role == nil else { return [] }
            return [.startProfessionalSession, .submitCapture, .requestContextRetrieval, .requestDraftGeneration, .submitGateReview, .viewFinalizationStatus]
        case .sortio:
            guard role == .patient || role == nil else { return [] }
            return [.inspectConsent, .requestConsentRevocation, .inspectAccessAudit, .requestExport, .askUserAgent, .inspectVisibilityStatus]
        case .cloudClinic:
            guard role == .serviceAdmin || role == .operationalCoordinator || role == .observerAuditor || role == nil else { return [] }
            return [.inspectQueue, .inspectPendingGates, .inspectServicePatients, .inspectOperationalDocuments, .assignAdministrativeTask, .inspectServiceAuditStatus]
        }
    }

    private static func allowedNotificationApps(kind: AppNotificationKind) -> Set<AppKind> {
        switch kind {
        case .gatePending, .documentFinalized, .signatureRequested, .signatureStatusChanged:
            return [.scribe, .cloudClinic]
        case .consentChanged, .exportReady, .emergencyAccessOccurred, .regulatoryAuditOccurred:
            return [.sortio, .cloudClinic]
        case .backupExportFailed, .providerDegraded, .asyncJobFailed:
            return [.cloudClinic, .scribe]
        }
    }
}
