import Foundation

public enum BackupScope: String, Codable, Sendable {
    case system
    case service
    case userExport = "user-export"
    case auditProvenance = "audit-provenance"
    case modelProviderRegistry = "model-provider-registry"
    case gosBundleRegistry = "gos-bundle-registry"
}

public enum IntegrityStatus: String, Codable, Sendable {
    case pending
    case verified
    case failed
}

public enum EncryptionScaffoldStatus: String, Codable, Sendable {
    case scaffolded
    case required
    case notImplemented
}

public enum RetentionClass: String, Codable, Sendable {
    case operational
    case legal
    case regulatory
    case userPortable = "user-portable"
}

public enum RestoreEligibility: String, Codable, Sendable {
    case allowed
    case policyRestricted = "policy-restricted"
    case denied
}

public struct BackupObjectEntry: Codable, Sendable {
    public let objectRef: StorageObjectRef
    public let expectedHash: String
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(objectRef: StorageObjectRef, expectedHash: String, provenanceRefs: [UUID] = [], auditRefs: [UUID] = []) {
        self.objectRef = objectRef
        self.expectedHash = expectedHash
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public struct BackupManifest: Codable, Sendable {
    public let backupId: UUID
    public let createdAt: Date
    public let createdBy: String
    public let nodeId: String?
    public let serviceId: UUID?
    public let userId: UUID?
    public let scope: BackupScope
    public let includedLayers: [StorageLayer]
    public let excludedLayers: [StorageLayer]
    public let objectEntries: [BackupObjectEntry]
    public let schemaVersion: String
    public let storageVersion: String
    public let encryptionStatus: EncryptionScaffoldStatus
    public let integrityStatus: IntegrityStatus
    public let retentionClass: RetentionClass
    public let restoreEligibility: RestoreEligibility
    public let includesDirectIdentifiers: Bool
    public let includesReidentificationMapping: Bool

    public init(
        backupId: UUID = UUID(),
        createdAt: Date = .now,
        createdBy: String,
        nodeId: String? = nil,
        serviceId: UUID? = nil,
        userId: UUID? = nil,
        scope: BackupScope,
        includedLayers: [StorageLayer],
        excludedLayers: [StorageLayer],
        objectEntries: [BackupObjectEntry],
        schemaVersion: String,
        storageVersion: String,
        encryptionStatus: EncryptionScaffoldStatus,
        integrityStatus: IntegrityStatus,
        retentionClass: RetentionClass,
        restoreEligibility: RestoreEligibility,
        includesDirectIdentifiers: Bool,
        includesReidentificationMapping: Bool
    ) {
        self.backupId = backupId
        self.createdAt = createdAt
        self.createdBy = createdBy
        self.nodeId = nodeId
        self.serviceId = serviceId
        self.userId = userId
        self.scope = scope
        self.includedLayers = includedLayers
        self.excludedLayers = excludedLayers
        self.objectEntries = objectEntries
        self.schemaVersion = schemaVersion
        self.storageVersion = storageVersion
        self.encryptionStatus = encryptionStatus
        self.integrityStatus = integrityStatus
        self.retentionClass = retentionClass
        self.restoreEligibility = restoreEligibility
        self.includesDirectIdentifiers = includesDirectIdentifiers
        self.includesReidentificationMapping = includesReidentificationMapping
    }
}

public enum RestoreConflictPolicy: String, Codable, Sendable {
    case failIfExists = "fail-if-exists"
    case overwrite
    case skipExisting = "skip-existing"
}

public enum RestoreProvenanceMode: String, Codable, Sendable {
    case preserve
    case preserveOrGapRecord = "preserve-or-gap-record"
}

public enum LifecycleRestoreHandling: String, Codable, Sendable {
    case preserve
    case doNotReactivateRevoked = "do-not-reactivate-revoked"
}

public struct RestorePlan: Codable, Sendable {
    public let restoreId: UUID
    public let sourceBackupId: UUID
    public let requestedBy: String
    public let lawfulContextRequired: Bool
    public let lawfulContext: [String: String]?
    public let targetRoot: String
    public let targetNodeId: String?
    public let targetServiceId: UUID?
    public let targetUserId: UUID?
    public let dryRun: Bool
    public let conflictPolicy: RestoreConflictPolicy?
    public let expectedObjectHashes: [String: String]
    public let validatedObjectHashes: [String: String]
    public let restoredLayers: [StorageLayer]
    public let excludedLayers: [StorageLayer]
    public let provenanceMode: RestoreProvenanceMode
    public let auditMode: RestoreProvenanceMode
    public let reidentificationHandlingExplicit: Bool
    public let directIdentifierPolicyElevated: Bool
    public let lifecycleHandling: LifecycleRestoreHandling
    public let includesFinalDocuments: Bool
    public let preservesGateLineage: Bool

    public init(
        restoreId: UUID = UUID(),
        sourceBackupId: UUID,
        requestedBy: String,
        lawfulContextRequired: Bool,
        lawfulContext: [String: String]? = nil,
        targetRoot: String,
        targetNodeId: String? = nil,
        targetServiceId: UUID? = nil,
        targetUserId: UUID? = nil,
        dryRun: Bool,
        conflictPolicy: RestoreConflictPolicy? = nil,
        expectedObjectHashes: [String: String],
        validatedObjectHashes: [String: String],
        restoredLayers: [StorageLayer],
        excludedLayers: [StorageLayer],
        provenanceMode: RestoreProvenanceMode,
        auditMode: RestoreProvenanceMode,
        reidentificationHandlingExplicit: Bool,
        directIdentifierPolicyElevated: Bool,
        lifecycleHandling: LifecycleRestoreHandling,
        includesFinalDocuments: Bool,
        preservesGateLineage: Bool
    ) {
        self.restoreId = restoreId
        self.sourceBackupId = sourceBackupId
        self.requestedBy = requestedBy
        self.lawfulContextRequired = lawfulContextRequired
        self.lawfulContext = lawfulContext
        self.targetRoot = targetRoot
        self.targetNodeId = targetNodeId
        self.targetServiceId = targetServiceId
        self.targetUserId = targetUserId
        self.dryRun = dryRun
        self.conflictPolicy = conflictPolicy
        self.expectedObjectHashes = expectedObjectHashes
        self.validatedObjectHashes = validatedObjectHashes
        self.restoredLayers = restoredLayers
        self.excludedLayers = excludedLayers
        self.provenanceMode = provenanceMode
        self.auditMode = auditMode
        self.reidentificationHandlingExplicit = reidentificationHandlingExplicit
        self.directIdentifierPolicyElevated = directIdentifierPolicyElevated
        self.lifecycleHandling = lifecycleHandling
        self.includesFinalDocuments = includesFinalDocuments
        self.preservesGateLineage = preservesGateLineage
    }
}

public struct RetentionPolicy: Codable, Sendable {
    public let retentionClass: RetentionClass
    public let minimumRetentionDays: Int
    public let legalHold: Bool
    public let serviceRetentionObligation: Bool
    public let userVisibilityEligible: Bool
    public let userExportEligible: Bool
    public let deletionEligible: Bool
    public let anonymizationEligible: Bool
    public let archivalEligible: Bool
}

public struct RetentionDecision: Codable, Sendable {
    public let id: UUID
    public let requestedBy: String
    public let rationale: String
    public let policy: RetentionPolicy
    public let provenanceRef: UUID?
    public let auditRef: UUID?

    public init(id: UUID = UUID(), requestedBy: String, rationale: String, policy: RetentionPolicy, provenanceRef: UUID? = nil, auditRef: UUID? = nil) {
        self.id = id
        self.requestedBy = requestedBy
        self.rationale = rationale
        self.policy = policy
        self.provenanceRef = provenanceRef
        self.auditRef = auditRef
    }
}

public enum ExportKind: String, Codable, Sendable {
    case patientUser = "patient-user"
    case serviceOperational = "service-operational"
    case audit
    case provenance
    case regulatoryScaffold = "regulatory-scaffold"
}

public struct ExportRequest: Codable, Sendable {
    public let id: UUID
    public let kind: ExportKind
    public let requestedBy: String
    public let viaCoreMediation: Bool
    public let ownerUserId: UUID?
    public let ownerServiceId: UUID?
    public let lawfulContext: [String: String]?
    public let includeDirectIdentifiers: Bool
    public let includeReidentificationMapping: Bool
    public let directIdentifierPolicyElevated: Bool
    public let redactionStatus: String

    public init(
        id: UUID = UUID(),
        kind: ExportKind,
        requestedBy: String,
        viaCoreMediation: Bool,
        ownerUserId: UUID? = nil,
        ownerServiceId: UUID? = nil,
        lawfulContext: [String: String]? = nil,
        includeDirectIdentifiers: Bool,
        includeReidentificationMapping: Bool,
        directIdentifierPolicyElevated: Bool,
        redactionStatus: String
    ) {
        self.id = id
        self.kind = kind
        self.requestedBy = requestedBy
        self.viaCoreMediation = viaCoreMediation
        self.ownerUserId = ownerUserId
        self.ownerServiceId = ownerServiceId
        self.lawfulContext = lawfulContext
        self.includeDirectIdentifiers = includeDirectIdentifiers
        self.includeReidentificationMapping = includeReidentificationMapping
        self.directIdentifierPolicyElevated = directIdentifierPolicyElevated
        self.redactionStatus = redactionStatus
    }
}

public struct ExportPackageManifest: Codable, Sendable {
    public let exportId: UUID
    public let requestId: UUID
    public let objectRefs: [StorageObjectRef]
    public let objectHashes: [String: String]
    public let redactionStatus: String
    public let lawfulContextSnapshot: [String: String]
}

public struct DisasterRecoveryPlan: Codable, Sendable {
    public let id: UUID
    public let name: String
    public let rpoMinutes: Int
    public let rtoMinutes: Int
}

public struct DRReadinessReport: Codable, Sendable {
    public let id: UUID
    public let planId: UUID
    public let backupPresent: Bool
    public let restoreDryRunPassed: Bool
    public let integrityPassed: Bool
    public let schemaCompatible: Bool
    public let nodeFabricCompatible: Bool
    public let auditProvenanceContinuous: Bool
    public let sensitiveLayerHandlingPassed: Bool
}

public enum BackupGovernanceFailure: Error, LocalizedError, Sendable, Equatable {
    case missingSchemaVersion
    case directIdentifiersPolicyRequired
    case reidentificationPolicyRequired
    case missingManifest
    case hashMismatch(String)
    case restoreConflictPolicyRequired
    case revokedLifecycleReactivationDenied
    case finalDocumentGateLineageMissing
    case legalHoldBlocksDeletion
    case retentionDoesNotGrantAccess
    case exportLawfulContextRequired
    case exportReidentificationDenied
    case exportDirectIdentifiersPolicyRequired
    case appMustUseCoreMediation
    case deniedControlPlaneRequester
    case disasterRecoveryPrereqFailed(String)
    case rationaleRequired

    public var errorDescription: String? {
        switch self {
        case .missingSchemaVersion: return "Backup manifest requires schemaVersion."
        case .directIdentifiersPolicyRequired: return "Direct identifier operation requires elevated policy."
        case .reidentificationPolicyRequired: return "Reidentification mapping operation requires explicit policy."
        case .missingManifest: return "Restore requires a valid backup manifest."
        case .hashMismatch(let ref): return "Hash mismatch for object ref: \(ref)."
        case .restoreConflictPolicyRequired: return "Restore conflict policy is required when existing objects are present."
        case .revokedLifecycleReactivationDenied: return "Restore cannot reactivate revoked lifecycle states by default."
        case .finalDocumentGateLineageMissing: return "Restore of final documents requires preserved gate lineage."
        case .legalHoldBlocksDeletion: return "Legal hold blocks deletion eligibility."
        case .retentionDoesNotGrantAccess: return "Retention obligation does not grant unrestricted data access."
        case .exportLawfulContextRequired: return "Export requires lawfulContext."
        case .exportReidentificationDenied: return "Reidentification mapping export is denied by default."
        case .exportDirectIdentifiersPolicyRequired: return "Direct identifier export requires elevated policy."
        case .appMustUseCoreMediation: return "App-facing requests must go through Core mediation."
        case .deniedControlPlaneRequester: return "Requester is not allowed to decide backup/restore/export governance."
        case .disasterRecoveryPrereqFailed(let check): return "DR readiness failed: \(check)."
        case .rationaleRequired: return "Governed decision requires rationale."
        }
    }
}

public enum BackupGovernanceEventKind: String, Codable, Sendable {
    case backupCreated = "backup.created"
    case backupFailed = "backup.failed"
    case backupIntegrityVerified = "backup.integrity_verified"
    case restoreRequested = "restore.requested"
    case restoreValidated = "restore.validated"
    case restoreExecuted = "restore.executed"
    case restoreFailed = "restore.failed"
    case exportRequested = "export.requested"
    case exportCreated = "export.created"
    case exportDenied = "export.denied"
    case retentionDecision = "retention.decision"
    case retentionHoldApplied = "retention.hold.applied"
    case drDryRunCompleted = "dr.dry_run.completed"
    case drReadinessFailed = "dr.readiness.failed"
}

public struct BackupGovernanceEvent: Codable, Sendable {
    public let id: UUID
    public let kind: BackupGovernanceEventKind
    public let actor: String
    public let timestamp: Date
    public let attributes: [String: String]

    public init(id: UUID = UUID(), kind: BackupGovernanceEventKind, actor: String, timestamp: Date = .now, attributes: [String: String] = [:]) {
        self.id = id
        self.kind = kind
        self.actor = actor
        self.timestamp = timestamp
        self.attributes = attributes
    }
}

public enum BackupGovernanceValidator {
    public static func validateManifest(
        _ manifest: BackupManifest,
        directIdentifierPolicyElevated: Bool,
        reidentificationPolicyExplicit: Bool
    ) throws {
        guard manifest.schemaVersion.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw BackupGovernanceFailure.missingSchemaVersion
        }
        if manifest.includesDirectIdentifiers || manifest.includedLayers.contains(.directIdentifiers) {
            guard directIdentifierPolicyElevated else {
                throw BackupGovernanceFailure.directIdentifiersPolicyRequired
            }
        }
        if manifest.includesReidentificationMapping || manifest.includedLayers.contains(.reidentificationMapping) {
            guard reidentificationPolicyExplicit else {
                throw BackupGovernanceFailure.reidentificationPolicyRequired
            }
        }
    }

    public static func validateRestore(
        plan: RestorePlan,
        manifest: BackupManifest?,
        existingObjectRefs: Set<String>
    ) throws {
        guard let manifest else { throw BackupGovernanceFailure.missingManifest }
        if plan.restoredLayers.contains(.directIdentifiers) {
            guard plan.directIdentifierPolicyElevated else {
                throw BackupGovernanceFailure.directIdentifiersPolicyRequired
            }
        }
        if plan.restoredLayers.contains(.reidentificationMapping) {
            guard plan.reidentificationHandlingExplicit else {
                throw BackupGovernanceFailure.reidentificationPolicyRequired
            }
        }
        if !existingObjectRefs.isEmpty && plan.conflictPolicy == nil {
            throw BackupGovernanceFailure.restoreConflictPolicyRequired
        }
        if plan.lifecycleHandling != .doNotReactivateRevoked {
            throw BackupGovernanceFailure.revokedLifecycleReactivationDenied
        }
        if plan.includesFinalDocuments && !plan.preservesGateLineage {
            throw BackupGovernanceFailure.finalDocumentGateLineageMissing
        }

        let expectedRefs = Set(manifest.objectEntries.map { $0.objectRef.objectPath })
        for (objectRef, expectedHash) in plan.expectedObjectHashes where expectedRefs.contains(objectRef) {
            let validated = plan.validatedObjectHashes[objectRef]
            guard validated == expectedHash else {
                throw BackupGovernanceFailure.hashMismatch(objectRef)
            }
        }
    }

    public static func validateRetentionDecision(_ decision: RetentionDecision) throws {
        guard decision.rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty == false else {
            throw BackupGovernanceFailure.rationaleRequired
        }
        if decision.policy.legalHold && decision.policy.deletionEligible {
            throw BackupGovernanceFailure.legalHoldBlocksDeletion
        }
        if decision.policy.serviceRetentionObligation && decision.policy.userVisibilityEligible && decision.policy.userExportEligible == false {
            throw BackupGovernanceFailure.retentionDoesNotGrantAccess
        }
        if decision.policy.anonymizationEligible {
            guard decision.rationale.count >= 10 else {
                throw BackupGovernanceFailure.rationaleRequired
            }
        }
    }

    public static func validateExportRequest(_ request: ExportRequest) throws {
        guard request.viaCoreMediation else {
            throw BackupGovernanceFailure.appMustUseCoreMediation
        }
        guard let lawful = request.lawfulContext, lawful.isEmpty == false else {
            throw BackupGovernanceFailure.exportLawfulContextRequired
        }
        _ = try LawfulContextValidator.validate(lawful, requirements: .init(requireFinalidade: true))

        if request.includeReidentificationMapping {
            throw BackupGovernanceFailure.exportReidentificationDenied
        }
        if request.includeDirectIdentifiers && !request.directIdentifierPolicyElevated {
            throw BackupGovernanceFailure.exportDirectIdentifiersPolicyRequired
        }
    }

    public static func validateDRReadiness(_ report: DRReadinessReport) throws {
        guard report.backupPresent else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("backup-present") }
        guard report.restoreDryRunPassed else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("restore-dry-run") }
        guard report.integrityPassed else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("object-integrity") }
        guard report.schemaCompatible else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("schema-compatibility") }
        guard report.nodeFabricCompatible else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("node-fabric-compatibility") }
        guard report.auditProvenanceContinuous else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("audit-provenance-continuity") }
        guard report.sensitiveLayerHandlingPassed else { throw BackupGovernanceFailure.disasterRecoveryPrereqFailed("sensitive-layer-handling") }
    }

    public static func validateControlPlaneRequester(_ requester: String) throws {
        let denied = ["aaci", "gos"]
        if denied.contains(requester.lowercased()) {
            throw BackupGovernanceFailure.deniedControlPlaneRequester
        }
    }
}
