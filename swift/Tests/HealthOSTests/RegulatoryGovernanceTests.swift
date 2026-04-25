import Foundation
import XCTest
@testable import HealthOSCore

final class RegulatoryGovernanceTests: XCTestCase {
    func testRegulatoryAuditRequestWithoutLegalBasisFails() {
        let request = makeAuditRequest(legalBasis: "")
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRegulatoryAuditRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .legalBasisRequired)
        }
    }

    func testRegulatoryAuditRequestWithoutScopeFails() {
        let request = makeAuditRequest(scope: RegulatoryAuditScope(operations: [], includeProvenance: true, includeAuditTrail: true))
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRegulatoryAuditRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .scopeRequired)
        }
    }

    func testRegulatoryAuditRequestValidatesLawfulContext() throws {
        let request = makeAuditRequest()
        XCTAssertNoThrow(try RegulatoryGovernanceValidator.validateRegulatoryAuditRequest(request))
    }

    func testRegulatoryAuditPackageDeniesLayerOutsideScope() {
        let request = makeAuditRequest(layers: [.governanceMetadata])
        let package = RegulatoryAuditPackage(
            requestId: request.id,
            includedObjectRefs: [sampleRef(layer: .directIdentifiers)],
            includedHashes: ["/tmp/reg-1": "hash-1"],
            includedDataLayers: [.directIdentifiers],
            externalDelivery: false,
            externalDeliveryMode: InteroperabilityDeliveryStatus.packagePrepared.rawValue,
            notes: "Scoped package"
        )

        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRegulatoryAuditPackage(request: request, package: package)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .packageLayerOutsideScope)
        }
    }

    func testRegulatoryAuditExternalDeliveryIsPlaceholderOnly() {
        let request = makeAuditRequest()
        let package = RegulatoryAuditPackage(
            requestId: request.id,
            includedObjectRefs: [sampleRef(layer: .governanceMetadata)],
            includedHashes: ["/tmp/reg-1": "hash-1"],
            includedDataLayers: [.governanceMetadata],
            externalDelivery: true,
            externalDeliveryMode: "real-endpoint",
            notes: "No real endpoint allowed"
        )

        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRegulatoryAuditPackage(request: request, package: package)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .externalDeliveryIsPlaceholderOnly)
        }
    }

    func testEmergencyAccessWithoutRationaleFails() {
        let request = makeEmergencyRequest(rationale: "")
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateEmergencyAccessRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .rationaleRequired)
        }
    }

    func testEmergencyAccessWithoutDurationFails() {
        let request = makeEmergencyRequest(duration: 0)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateEmergencyAccessRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .durationRequired)
        }
    }

    func testBreakGlassGrantMustExpire() {
        let grant = BreakGlassAccessGrant(
            requestId: UUID(),
            grantedDurationMinutes: 20,
            approvedByActor: "operator-1",
            postAccessReviewRequired: true,
            patientNotificationRequired: true,
            expiresAt: Date(timeIntervalSinceNow: -60),
            status: .granted
        )
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateBreakGlassGrant(grant))
    }

    func testAACIAndGOSCannotAuthorizeEmergencyOrAudit() {
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateEmergencyAccessRequest(makeEmergencyRequest(source: "aaci")))
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRegulatoryAuditRequest(makeAuditRequest(requestedByActor: "gos")))
    }

    func testRetentionLegalDoesNotGrantDeletion() {
        let decision = makeRetentionDecision(serviceCustodyRequired: true, deletionEligible: true)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRetentionVisibilityDecision(decision)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .deletionDeniedByRetention)
        }
    }

    func testDeletionWithoutRetentionDecisionFails() {
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateDeletionEligibility(decision: nil)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .retentionDecisionRequired)
        }
    }

    func testAnonymizationWithoutRationaleFails() {
        let decision = makeRetentionDecision(rationale: "short", anonymizationEligible: true)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateRetentionVisibilityDecision(decision)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .anonymizationRationaleRequired)
        }
    }

    func testPatientExportEligibilityCanDifferFromDeletionEligibility() throws {
        let decision = makeRetentionDecision(patientExportEligible: true, deletionEligible: false)
        XCTAssertNoThrow(try RegulatoryGovernanceValidator.validateRetentionVisibilityDecision(decision))
    }

    func testSignatureWithoutApprovedGateFails() {
        let request = makeSignatureRequest(gateApproved: false)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateDigitalSignatureRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .signatureRequiresApprovedGate)
        }
    }

    func testSignatureWithoutDocumentHashFails() {
        let request = makeSignatureRequest(hash: "")
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateDigitalSignatureRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .signatureRequiresDocumentHash)
        }
    }

    func testSignatureWithoutProviderRemainsUnsigned() {
        let request = makeSignatureRequest(provider: .none, legalStatus: .verifiedQualifiedPlaceholder)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateDigitalSignatureRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .providerUnavailableRemainsUnsigned)
        }
    }

    func testQualifiedPlaceholderRequiresProfessionalSigner() {
        let request = makeSignatureRequest(provider: .qualifiedProviderPlaceholder, legalStatus: .verifiedQualifiedPlaceholder, signerProfessionalRecordId: nil)
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateDigitalSignatureRequest(request)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .qualifiedPlaceholderRequiresProfessionalSigner)
        }
    }

    func testInteroperabilityPackageRequiresSourceLineage() {
        let package = InteroperabilityPackage(
            id: UUID(),
            profile: .fhirR4,
            sourceRefs: [sampleRef(layer: .operationalContent)],
            sourceHashes: [:],
            provenanceRefs: [],
            validationReport: "scaffold-only",
            externalDeliveryPerformed: false,
            deliveryStatus: .packagePrepared
        )
        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateInteroperabilityPackage(package)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .interoperabilityMustPreserveSourceLineage)
        }
    }

    func testInteroperabilityExternalDeliveryStaysPlaceholder() {
        let package = InteroperabilityPackage(
            id: UUID(),
            profile: .rndsScaffold,
            sourceRefs: [sampleRef(layer: .operationalContent)],
            sourceHashes: ["/tmp/ref": "hash"],
            provenanceRefs: [UUID()],
            validationReport: "placeholder",
            externalDeliveryPerformed: true,
            deliveryStatus: .validatedScaffold
        )

        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateInteroperabilityPackage(package)) { error in
            XCTAssertEqual(error as? RegulatoryGovernanceFailure, .interoperabilityExternalDeliveryPlaceholderOnly)
        }
    }

    func testProbativeLineageRequiresHashAndProvenance() {
        let lineage = ProbativeDocumentLineage(
            sourceDraftId: UUID(),
            gateRequestId: UUID(),
            gateResolutionId: UUID(),
            finalDocumentRef: sampleRef(layer: .governanceMetadata),
            documentHash: "",
            signerUserId: UUID(),
            signerProfessionalRecordId: UUID(),
            signatureEnvelopeRef: "envelope-ref",
            provenanceChain: [],
            retentionClass: .legal,
            exportPackageRefs: [],
            auditPackageRefs: []
        )

        XCTAssertThrowsError(try RegulatoryGovernanceValidator.validateProbativeLineage(lineage))
    }

    private func makeAuditRequest(
        legalBasis: String = "art-1",
        scope: RegulatoryAuditScope = .init(operations: ["access-review"], includeProvenance: true, includeAuditTrail: true),
        layers: [StorageLayer] = [.governanceMetadata],
        requestedByActor: String = "operator"
    ) -> RegulatoryAuditRequest {
        RegulatoryAuditRequest(
            authorityKind: .regulator,
            legalBasis: legalBasis,
            rationale: "governed audit",
            requestedScope: scope,
            requestedDataLayers: layers,
            serviceId: UUID(),
            patientUserId: UUID(),
            requestedByActor: requestedByActor,
            timeWindowStart: Date(timeIntervalSinceNow: -3600),
            timeWindowEnd: Date(),
            lawfulContext: lawfulContext(),
            viaCoreMediation: true,
            status: .requested
        )
    }

    private func makeEmergencyRequest(
        rationale: String = "Break-glass required by emergency triage",
        duration: Int = 30,
        source: String = "operator"
    ) -> EmergencyAccessRequest {
        EmergencyAccessRequest(
            actorId: "actor-1",
            actorRole: "professional",
            patientUserId: UUID(),
            serviceId: UUID(),
            emergencyRationale: rationale,
            requestedScope: ["patient:context:read"],
            requestedDurationMinutes: duration,
            requestedBySource: source,
            lawfulContext: lawfulContext(),
            status: .requested
        )
    }

    private func makeRetentionDecision(
        rationale: String = "Retention obligation and visibility governance separated.",
        serviceCustodyRequired: Bool = true,
        patientExportEligible: Bool = false,
        deletionEligible: Bool = false,
        anonymizationEligible: Bool = false
    ) -> RetentionVisibilityDecision {
        RetentionVisibilityDecision(
            patientUserId: UUID(),
            serviceId: UUID(),
            requestedByActor: "operator",
            rationale: rationale,
            legalRetention: LegalRetentionObligation(
                retentionClass: .legal,
                minimumRetentionDays: 365,
                serviceCustodyRequired: serviceCustodyRequired,
                legalBasis: "art-2"
            ),
            visibilityPolicy: VisibilityPolicy(patientVisible: false, patientExportEligible: patientExportEligible, accessRestricted: true),
            custodyPolicy: CustodyPolicy(serviceCustodyObligation: serviceCustodyRequired, deletionEligible: deletionEligible, anonymizationEligible: anonymizationEligible)
        )
    }

    private func makeSignatureRequest(
        gateApproved: Bool = true,
        hash: String = "hash-final-1",
        provider: SignatureProviderKind = .none,
        legalStatus: DocumentLegalSignatureStatus = .signatureRequested,
        signerProfessionalRecordId: UUID? = UUID()
    ) -> DigitalSignatureRequest {
        DigitalSignatureRequest(
            documentRef: sampleRef(layer: .governanceMetadata),
            documentHash: hash,
            sourceDraftId: UUID(),
            gateRequestId: UUID(),
            gateResolutionId: UUID(),
            gateApproved: gateApproved,
            signerUserId: UUID(),
            signerProfessionalRecordId: signerProfessionalRecordId,
            signatureProviderKind: provider,
            certificateRefPlaceholder: "placeholder-cert",
            requestedAt: .now,
            signedAt: nil,
            verificationStatus: "pending",
            legalStatus: legalStatus,
            provenanceRefs: [UUID()]
        )
    }

    private func lawfulContext() -> [String: String] {
        [
            "actorRole": "operator",
            "scope": "service",
            "serviceId": UUID().uuidString,
            "patientUserId": UUID().uuidString,
            "finalidade": "regulatory-governance"
        ]
    }

    private func sampleRef(layer: StorageLayer) -> StorageObjectRef {
        StorageObjectRef(objectPath: "/tmp/reg-1", contentHash: "hash-1", layer: layer, kind: "regulatory")
    }
}
