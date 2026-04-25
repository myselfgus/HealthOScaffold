import Foundation
import XCTest
@testable import HealthOSCore

final class BackupGovernanceTests: XCTestCase {
    func testManifestIncludesObjectHashes() throws {
        let manifest = makeManifest()
        XCTAssertEqual(manifest.objectEntries.first?.expectedHash, "hash-1")
    }

    func testManifestWithoutSchemaVersionFails() {
        var manifest = makeManifest()
        manifest = BackupManifest(
            backupId: manifest.backupId,
            createdAt: manifest.createdAt,
            createdBy: manifest.createdBy,
            nodeId: manifest.nodeId,
            serviceId: manifest.serviceId,
            userId: manifest.userId,
            scope: manifest.scope,
            includedLayers: manifest.includedLayers,
            excludedLayers: manifest.excludedLayers,
            objectEntries: manifest.objectEntries,
            schemaVersion: "",
            storageVersion: manifest.storageVersion,
            encryptionStatus: manifest.encryptionStatus,
            integrityStatus: manifest.integrityStatus,
            retentionClass: manifest.retentionClass,
            restoreEligibility: manifest.restoreEligibility,
            includesDirectIdentifiers: manifest.includesDirectIdentifiers,
            includesReidentificationMapping: manifest.includesReidentificationMapping
        )

        XCTAssertThrowsError(try BackupGovernanceValidator.validateManifest(manifest, directIdentifierPolicyElevated: true, reidentificationPolicyExplicit: true)) { error in
            XCTAssertEqual(error as? BackupGovernanceFailure, .missingSchemaVersion)
        }
    }

    func testDirectIdentifiersBackupWithoutPolicyFails() {
        let manifest = makeManifest(includedLayers: [.directIdentifiers], includesDirectIdentifiers: true)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateManifest(manifest, directIdentifierPolicyElevated: false, reidentificationPolicyExplicit: true))
    }

    func testReidentificationBackupWithoutExplicitPolicyFails() {
        let manifest = makeManifest(includedLayers: [.reidentificationMapping], includesReidentification: true)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateManifest(manifest, directIdentifierPolicyElevated: true, reidentificationPolicyExplicit: false))
    }

    func testManifestPreservesDataLayerClassification() {
        let manifest = makeManifest(includedLayers: [.operationalContent, .governanceMetadata])
        XCTAssertEqual(manifest.includedLayers, [.operationalContent, .governanceMetadata])
    }

    func testRestoreDryRunWithValidHashesPasses() throws {
        let manifest = makeManifest()
        let plan = makeRestorePlan(expectedHashes: ["/tmp/object-1": "hash-1"], validatedHashes: ["/tmp/object-1": "hash-1"], dryRun: true)

        XCTAssertNoThrow(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: manifest, existingObjectRefs: []))
    }

    func testRestoreWithHashMismatchFails() {
        let manifest = makeManifest()
        let plan = makeRestorePlan(expectedHashes: ["/tmp/object-1": "hash-1"], validatedHashes: ["/tmp/object-1": "different-hash"], dryRun: true)

        XCTAssertThrowsError(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: manifest, existingObjectRefs: []))
    }

    func testRestoreWithoutManifestFails() {
        let plan = makeRestorePlan(expectedHashes: [:], validatedHashes: [:], dryRun: true)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: nil, existingObjectRefs: []))
    }

    func testRestoreRevokedLifecycleDoesNotReactivateAutomatically() {
        var plan = makeRestorePlan(expectedHashes: [:], validatedHashes: [:], dryRun: true)
        plan = RestorePlan(
            restoreId: plan.restoreId,
            sourceBackupId: plan.sourceBackupId,
            requestedBy: plan.requestedBy,
            lawfulContextRequired: plan.lawfulContextRequired,
            lawfulContext: plan.lawfulContext,
            targetRoot: plan.targetRoot,
            targetNodeId: plan.targetNodeId,
            targetServiceId: plan.targetServiceId,
            targetUserId: plan.targetUserId,
            dryRun: plan.dryRun,
            conflictPolicy: plan.conflictPolicy,
            expectedObjectHashes: plan.expectedObjectHashes,
            validatedObjectHashes: plan.validatedObjectHashes,
            restoredLayers: plan.restoredLayers,
            excludedLayers: plan.excludedLayers,
            provenanceMode: plan.provenanceMode,
            auditMode: plan.auditMode,
            reidentificationHandlingExplicit: plan.reidentificationHandlingExplicit,
            directIdentifierPolicyElevated: plan.directIdentifierPolicyElevated,
            lifecycleHandling: .preserve,
            includesFinalDocuments: plan.includesFinalDocuments,
            preservesGateLineage: plan.preservesGateLineage
        )

        XCTAssertThrowsError(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: makeManifest(), existingObjectRefs: []))
    }

    func testRestoreFinalDocumentRequiresGateLineage() {
        let plan = makeRestorePlan(expectedHashes: [:], validatedHashes: [:], dryRun: true, includesFinalDocuments: true, preservesGateLineage: false)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: makeManifest(), existingObjectRefs: []))
    }

    func testRestoreWithoutConflictPolicyDoesNotOverwriteExistingObject() {
        let plan = makeRestorePlan(expectedHashes: [:], validatedHashes: [:], dryRun: false, conflictPolicy: nil)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRestore(plan: plan, manifest: makeManifest(), existingObjectRefs: ["/tmp/object-1"]))
    }

    func testLegalHoldBlocksDeletionEligibility() {
        let policy = RetentionPolicy(
            retentionClass: .legal,
            minimumRetentionDays: 365,
            legalHold: true,
            serviceRetentionObligation: true,
            userVisibilityEligible: true,
            userExportEligible: true,
            deletionEligible: true,
            anonymizationEligible: false,
            archivalEligible: true
        )
        let decision = RetentionDecision(requestedBy: "operator", rationale: "Legal hold required by service obligation.", policy: policy)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRetentionDecision(decision))
    }

    func testRetentionLegalDoesNotImplyFreeAccess() {
        let policy = RetentionPolicy(
            retentionClass: .legal,
            minimumRetentionDays: 365,
            legalHold: false,
            serviceRetentionObligation: true,
            userVisibilityEligible: true,
            userExportEligible: false,
            deletionEligible: false,
            anonymizationEligible: false,
            archivalEligible: true
        )
        let decision = RetentionDecision(requestedBy: "operator", rationale: "Service legal retention with governed access boundaries.", policy: policy)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRetentionDecision(decision))
    }

    func testUserExportEligibilityDoesNotImplyDeletionEligibility() throws {
        let policy = RetentionPolicy(
            retentionClass: .operational,
            minimumRetentionDays: 90,
            legalHold: false,
            serviceRetentionObligation: true,
            userVisibilityEligible: true,
            userExportEligible: true,
            deletionEligible: false,
            anonymizationEligible: false,
            archivalEligible: true
        )
        let decision = RetentionDecision(requestedBy: "operator", rationale: "Export visibility allowed while retention obligation remains.", policy: policy)
        XCTAssertNoThrow(try BackupGovernanceValidator.validateRetentionDecision(decision))
    }

    func testAnonymizationDecisionRequiresRationale() {
        let policy = RetentionPolicy(
            retentionClass: .regulatory,
            minimumRetentionDays: 30,
            legalHold: false,
            serviceRetentionObligation: false,
            userVisibilityEligible: true,
            userExportEligible: true,
            deletionEligible: false,
            anonymizationEligible: true,
            archivalEligible: true
        )
        let decision = RetentionDecision(requestedBy: "operator", rationale: "short", policy: policy)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateRetentionDecision(decision))
    }

    func testServiceRetentionDistinguishedFromPatientVisibilityGovernance() throws {
        let policy = RetentionPolicy(
            retentionClass: .legal,
            minimumRetentionDays: 730,
            legalHold: false,
            serviceRetentionObligation: true,
            userVisibilityEligible: false,
            userExportEligible: false,
            deletionEligible: false,
            anonymizationEligible: false,
            archivalEligible: true
        )
        let decision = RetentionDecision(requestedBy: "operator", rationale: "Service legal retention remains while patient visibility is policy-governed.", policy: policy)
        XCTAssertNoThrow(try BackupGovernanceValidator.validateRetentionDecision(decision))
    }

    func testExportWithoutLawfulContextFails() {
        let request = makeExportRequest(lawfulContext: nil)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateExportRequest(request))
    }

    func testPatientExportDoesNotIncludeReidentificationByDefault() throws {
        let request = makeExportRequest(includeReidentification: false)
        XCTAssertNoThrow(try BackupGovernanceValidator.validateExportRequest(request))
    }

    func testExportDirectIdentifiersRequiresExplicitPolicy() {
        let request = makeExportRequest(includeDirectIdentifiers: true, directPolicy: false)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateExportRequest(request))
    }

    func testExportPackageContainsManifestHashAndRedactionStatus() {
        let object = StorageObjectRef(objectPath: "/tmp/object-1", contentHash: "hash-1", layer: .operationalContent, kind: "draft")
        let manifest = ExportPackageManifest(
            exportId: UUID(),
            requestId: UUID(),
            objectRefs: [object],
            objectHashes: [object.objectPath: object.contentHash],
            redactionStatus: "deidentified",
            lawfulContextSnapshot: ["scope": "service", "finalidade": "care"]
        )

        XCTAssertEqual(manifest.objectHashes[object.objectPath], "hash-1")
        XCTAssertEqual(manifest.redactionStatus, "deidentified")
    }

    func testAppFacingExportRequestMustUseCoreMediation() {
        let request = makeExportRequest(viaCore: false)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateExportRequest(request))
    }

    func testDRReadinessFailsWithoutValidBackup() {
        let report = DRReadinessReport(
            id: UUID(),
            planId: UUID(),
            backupPresent: false,
            restoreDryRunPassed: true,
            integrityPassed: true,
            schemaCompatible: true,
            nodeFabricCompatible: true,
            auditProvenanceContinuous: true,
            sensitiveLayerHandlingPassed: true
        )
        XCTAssertThrowsError(try BackupGovernanceValidator.validateDRReadiness(report))
    }

    func testDRReadinessFailsWithSchemaIncompatibility() {
        let report = DRReadinessReport(
            id: UUID(),
            planId: UUID(),
            backupPresent: true,
            restoreDryRunPassed: true,
            integrityPassed: true,
            schemaCompatible: false,
            nodeFabricCompatible: true,
            auditProvenanceContinuous: true,
            sensitiveLayerHandlingPassed: true
        )
        XCTAssertThrowsError(try BackupGovernanceValidator.validateDRReadiness(report))
    }

    func testDRDryRunDoesNotAlterStorage() throws {
        let report = DRReadinessReport(
            id: UUID(),
            planId: UUID(),
            backupPresent: true,
            restoreDryRunPassed: true,
            integrityPassed: true,
            schemaCompatible: true,
            nodeFabricCompatible: true,
            auditProvenanceContinuous: true,
            sensitiveLayerHandlingPassed: true
        )
        XCTAssertNoThrow(try BackupGovernanceValidator.validateDRReadiness(report))
    }

    func testDRReportDoesNotLeakSensitivePayloads() {
        let event = BackupGovernanceEvent(kind: .drReadinessFailed, actor: "operator", attributes: ["status": "failed", "reason": "schema-compatibility"])
        XCTAssertNil(event.attributes["cpf"])
        XCTAssertNil(event.attributes["cpf_hash"])
    }

    func testAACIAndGOSCannotDecideControlPlaneOperations() {
        XCTAssertThrowsError(try BackupGovernanceValidator.validateControlPlaneRequester("aaci"))
        XCTAssertThrowsError(try BackupGovernanceValidator.validateControlPlaneRequester("gos"))
    }

    func testOperatorCommandWithoutPolicyFails() {
        let manifest = makeManifest(includedLayers: [.directIdentifiers], includesDirectIdentifiers: true)
        XCTAssertThrowsError(try BackupGovernanceValidator.validateManifest(manifest, directIdentifierPolicyElevated: false, reidentificationPolicyExplicit: true))
    }

    private func makeManifest(
        includedLayers: [StorageLayer] = [.operationalContent],
        includesDirectIdentifiers: Bool = false,
        includesReidentification: Bool = false
    ) -> BackupManifest {
        let object = StorageObjectRef(objectPath: "/tmp/object-1", contentHash: "hash-1", layer: .operationalContent, kind: "draft")
        return BackupManifest(
            createdBy: "operator",
            nodeId: "node-1",
            serviceId: UUID(),
            userId: UUID(),
            scope: .service,
            includedLayers: includedLayers,
            excludedLayers: [],
            objectEntries: [BackupObjectEntry(objectRef: object, expectedHash: "hash-1")],
            schemaVersion: "v1",
            storageVersion: "v1",
            encryptionStatus: .scaffolded,
            integrityStatus: .verified,
            retentionClass: .operational,
            restoreEligibility: .allowed,
            includesDirectIdentifiers: includesDirectIdentifiers,
            includesReidentificationMapping: includesReidentification
        )
    }

    private func makeRestorePlan(
        expectedHashes: [String: String],
        validatedHashes: [String: String],
        dryRun: Bool,
        conflictPolicy: RestoreConflictPolicy? = .failIfExists,
        includesFinalDocuments: Bool = false,
        preservesGateLineage: Bool = true
    ) -> RestorePlan {
        RestorePlan(
            sourceBackupId: UUID(),
            requestedBy: "operator",
            lawfulContextRequired: true,
            lawfulContext: [
                "scope": "service",
                "actorRole": "operator",
                "finalidade": "restore-validation",
                "serviceId": UUID().uuidString.lowercased()
            ],
            targetRoot: "/tmp/healthos",
            targetNodeId: "node-1",
            targetServiceId: UUID(),
            targetUserId: UUID(),
            dryRun: dryRun,
            conflictPolicy: conflictPolicy,
            expectedObjectHashes: expectedHashes,
            validatedObjectHashes: validatedHashes,
            restoredLayers: [.operationalContent],
            excludedLayers: [],
            provenanceMode: .preserveOrGapRecord,
            auditMode: .preserveOrGapRecord,
            reidentificationHandlingExplicit: true,
            directIdentifierPolicyElevated: true,
            lifecycleHandling: .doNotReactivateRevoked,
            includesFinalDocuments: includesFinalDocuments,
            preservesGateLineage: preservesGateLineage
        )
    }

    private func makeExportRequest(
        lawfulContext: [String: String]? = [
            "scope": "service",
            "actorRole": "professional-agent",
            "finalidade": "patient-export",
            "serviceId": UUID().uuidString.lowercased()
        ],
        includeDirectIdentifiers: Bool = false,
        includeReidentification: Bool = false,
        directPolicy: Bool = false,
        viaCore: Bool = true
    ) -> ExportRequest {
        ExportRequest(
            kind: .patientUser,
            requestedBy: "app",
            viaCoreMediation: viaCore,
            ownerUserId: UUID(),
            ownerServiceId: nil,
            lawfulContext: lawfulContext,
            includeDirectIdentifiers: includeDirectIdentifiers,
            includeReidentificationMapping: includeReidentification,
            directIdentifierPolicyElevated: directPolicy,
            redactionStatus: "deidentified"
        )
    }
}
