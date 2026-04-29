import Foundation
import XCTest
@testable import HealthOSCore

final class UserSovereigntyGovernanceTests: XCTestCase {
    func testUserAgentAllowedCapabilityPassesWithValidLawfulContext() throws {
        let request = makeUserAgentRequest(capability: .retrieveOwnContext)
        XCTAssertNoThrow(try UserAgentGovernanceValidator.validateRequest(request))
    }

    func testUserAgentForbiddenCapabilityFails() {
        let request = makeUserAgentRequest(capability: .diagnose)
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .prohibitedCapability(.diagnose))
        }
    }

    func testUserAgentDiagnosePrescribeFinalizeSignAlwaysFail() {
        for capability in [UserAgentCapability.diagnose, .prescribe, .finalizeRecord, .signDocument] {
            let request = makeUserAgentRequest(capability: capability)
            XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request))
        }
    }

    func testUserAgentAccessWithoutLawfulContextFails() {
        let request = makeUserAgentRequest(capability: .listConsents, lawfulContext: [:])
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .missingLawfulContext)
        }
    }

    func testUserAgentReidentificationAccessDeniedByDefault() {
        let request = makeUserAgentRequest(capability: .retrieveOwnContext, allowedLayers: [.operationalContent, .reidentificationMapping], deniedLayers: [])
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .reidentificationDeniedByDefault)
        }
    }

    func testUserAgentOutputMustBeInformational() {
        let response = UserAgentResponse(requestId: UUID(), disposition: .clinicalAct, message: "not-allowed", provenanceRefs: [], auditRefs: [])
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateResponse(response)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .outputMustBeInformational)
        }
    }

    func testConsentListSurfaceAppSafeContract() {
        let view = PatientConsentView(
            consentId: UUID(),
            finalidade: "patient-self-audit",
            scopeSummary: ["patient:context:read"],
            validityStart: .now,
            validityEnd: nil,
            revoked: false,
            revokedAt: nil,
            retentionObligationApplies: true
        )
        XCTAssertEqual(view.scopeSummary.first, "patient:context:read")
    }

    func testConsentRevocationWithoutScopeOrFinalityFails() {
        let request = makeRevocationRequest(finalidade: "", scopeSummary: [])
        XCTAssertThrowsError(try ConsentGovernanceValidator.validateRevocation(request)) { error in
            XCTAssertEqual(error as? ConsentDecisionFailure, .missingScopeOrFinality)
        }
    }

    func testValidConsentRevocationCarriesAuditAndProvenance() throws {
        let request = makeRevocationRequest()
        XCTAssertNotNil(request.provenanceRef)
        XCTAssertNotNil(request.auditRef)
        XCTAssertNoThrow(try ConsentGovernanceValidator.validateRevocation(request))
    }

    func testConsentRevocationCannotDeleteRetentionAutomatically() {
        let request = makeRevocationRequest(retentionAcknowledged: false)
        XCTAssertThrowsError(try ConsentGovernanceValidator.validateRevocation(request)) { error in
            XCTAssertEqual(error as? ConsentDecisionFailure, .retentionOverrideDenied)
        }
    }

    func testConsentRevocationCannotAlterFinalDocument() {
        let request = makeRevocationRequest(finalDocumentAcknowledged: false)
        XCTAssertThrowsError(try ConsentGovernanceValidator.validateRevocation(request)) { error in
            XCTAssertEqual(error as? ConsentDecisionFailure, .finalDocumentMutationDenied)
        }
    }

    func testPatientAuditViewOnlyIncludesOwnEvents() {
        let patientId = UUID()
        let query = PatientAuditQuery(patientUserId: patientId, lawfulContext: lawfulContext(patientId: patientId))
        let crossEvent = AccessAuditEventView(
            patientUserId: UUID(),
            actorRole: "professional",
            actorDisplay: "svc-actor",
            timestamp: .now,
            finalidade: "care",
            dataLayer: .operationalContent,
            operation: "read",
            emergencyAccess: false,
            regulatoryAccess: false,
            redactionStatus: "redacted",
            secretsRedacted: true
        )
        let view = PatientAccessAuditView(query: query, events: [crossEvent])
        XCTAssertThrowsError(try PatientAuditGovernanceValidator.validateView(view)) { error in
            XCTAssertEqual(error as? PatientAuditFailure, .crossPatientAccessDenied)
        }
    }

    func testPatientAuditViewDoesNotExposeSensitiveLayersOrSecrets() {
        let patientId = UUID()
        let query = PatientAuditQuery(patientUserId: patientId, lawfulContext: lawfulContext(patientId: patientId))
        let unsafeEvent = AccessAuditEventView(
            patientUserId: patientId,
            actorRole: "operator",
            actorDisplay: "ops",
            timestamp: .now,
            finalidade: "audit",
            dataLayer: .reidentificationMapping,
            operation: "read",
            emergencyAccess: false,
            regulatoryAccess: true,
            redactionStatus: "raw",
            secretsRedacted: false
        )
        let view = PatientAccessAuditView(query: query, events: [unsafeEvent])
        XCTAssertThrowsError(try PatientAuditGovernanceValidator.validateView(view)) { error in
            XCTAssertEqual(error as? PatientAuditFailure, .forbiddenSensitiveLeak)
        }
    }

    func testPatientAuditEmergencyAndRegulatoryMarkersAreSupported() throws {
        let patientId = UUID()
        let query = PatientAuditQuery(patientUserId: patientId, lawfulContext: lawfulContext(patientId: patientId))
        let safeEvent = AccessAuditEventView(
            patientUserId: patientId,
            actorRole: "professional",
            actorDisplay: "care-team",
            timestamp: .now,
            finalidade: "care",
            serviceRef: "service-1",
            dataLayer: .operationalContent,
            operation: "read",
            provenanceRef: UUID(),
            auditRef: UUID(),
            emergencyAccess: true,
            regulatoryAccess: true,
            redactionStatus: "redacted",
            secretsRedacted: true
        )
        XCTAssertTrue(safeEvent.emergencyAccess)
        XCTAssertTrue(safeEvent.regulatoryAccess)
        XCTAssertNoThrow(try PatientAuditGovernanceValidator.validateView(PatientAccessAuditView(query: query, events: [safeEvent])))
    }

    func testExportWithoutLawfulContextFails() {
        let request = PatientExportRequestSurface(
            ownerUserId: UUID(),
            lawfulContext: [:],
            scope: [.operationalContent],
            redactionPolicy: "deidentify-default",
            includeDirectIdentifiers: false,
            directIdentifierPolicyElevated: false
        )
        XCTAssertThrowsError(try PatientExportGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? PatientExportFailure, .lawfulContextRequired)
        }
    }

    func testExportReidentificationDeniedByDefault() {
        let userId = UUID()
        let request = PatientExportRequestSurface(
            ownerUserId: userId,
            lawfulContext: lawfulContext(patientId: userId),
            scope: [.operationalContent, .reidentificationMapping],
            redactionPolicy: "deidentify-default",
            includeDirectIdentifiers: false,
            directIdentifierPolicyElevated: false,
            includeReidentificationMapping: true
        )
        XCTAssertThrowsError(try PatientExportGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? PatientExportFailure, .reidentificationExportDenied)
        }
    }

    func testExportStatusIsAppSafeAndDoesNotExposeRawStorage() {
        let view = PatientExportStatusView(
            requestId: UUID(),
            status: "ready",
            packageManifest: nil,
            appSafeStatusDetail: "package-ready",
            storagePathExposed: true
        )
        XCTAssertThrowsError(try PatientExportGovernanceValidator.validateStatus(view)) { error in
            XCTAssertEqual(error as? PatientExportFailure, .rawStorageExposureDenied)
        }
    }

    func testExportDirectIdentifiersRequiresExplicitPolicy() {
        let userId = UUID()
        let request = PatientExportRequestSurface(
            ownerUserId: userId,
            lawfulContext: lawfulContext(patientId: userId),
            scope: [.operationalContent, .directIdentifiers],
            redactionPolicy: "deidentify-default",
            includeDirectIdentifiers: true,
            directIdentifierPolicyElevated: false
        )
        XCTAssertThrowsError(try PatientExportGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? PatientExportFailure, .directIdentifiersRequirePolicy)
        }
    }

    func testRetainedDoesNotMeanVisibleAndLegalHoldBlocksDeletion() {
        let visibility = DataVisibilityRetentionItem(
            id: UUID(),
            patientUserId: UUID(),
            dataLayer: .governanceMetadata,
            visibleToPatient: true,
            hiddenByPolicy: true,
            retainedByServiceObligation: true,
            exportEligible: false,
            deletionEligible: true,
            anonymizationEligible: false,
            legalHold: true,
            patientRequestedRestriction: true
        )
        XCTAssertThrowsError(try VisibilityRetentionGovernanceValidator.validate(visibility))
    }

    func testLegalHoldIndependentlyBlocksDeletionEligibility() {
        let visibility = DataVisibilityRetentionItem(
            id: UUID(),
            patientUserId: UUID(),
            dataLayer: .operationalContent,
            visibleToPatient: false,
            hiddenByPolicy: true,
            retainedByServiceObligation: true,
            exportEligible: false,
            deletionEligible: true,
            anonymizationEligible: false,
            legalHold: true,
            patientRequestedRestriction: false
        )
        XCTAssertThrowsError(try VisibilityRetentionGovernanceValidator.validate(visibility)) { error in
            XCTAssertEqual(error as? VisibilityRetentionFailure, .legalHoldBlocksDeletion)
        }
    }

    func testSortioBoundaryCannotExposeLawDecisionPowerRawStorageOrCPF() {
        XCTAssertThrowsError(
            try SortioBoundaryValidator.validateAppSafePayload(
                rawCPF: "123.456.789-00",
                rawStoragePath: nil,
                capability: .retrieveOwnContext
            )
        ) { error in
            XCTAssertEqual(error as? SortioBoundaryFailure, .forbiddenDirectIdentifierExposure)
        }

        XCTAssertThrowsError(
            try SortioBoundaryValidator.validateAppSafePayload(
                rawCPF: nil,
                rawStoragePath: "/runtime-data/private",
                capability: .retrieveOwnContext
            )
        ) { error in
            XCTAssertEqual(error as? SortioBoundaryFailure, .forbiddenStoragePathExposure)
        }

        XCTAssertThrowsError(
            try SortioBoundaryValidator.validateAppSafePayload(
                rawCPF: nil,
                rawStoragePath: nil,
                capability: .prescribe
            )
        ) { error in
            XCTAssertEqual(error as? SortioBoundaryFailure, .forbiddenClinicalCapabilitySurface)
        }
    }

    private func makeUserAgentRequest(
        capability: UserAgentCapability,
        lawfulContext: [String: String]? = nil,
        allowedLayers: [StorageLayer] = [.operationalContent, .governanceMetadata],
        deniedLayers: [StorageLayer] = [.reidentificationMapping]
    ) -> UserAgentRequest {
        let userId = UUID()
        return UserAgentRequest(
            scope: UserAgentScope(
                userId: userId,
                cpfHashRef: "cpf-hash-anchor",
                actorId: "user-agent-actor",
                runtimeId: "runtime-user-agent",
                dataLayersAllowed: allowedLayers,
                dataLayersDenied: deniedLayers
            ),
            requestedCapability: capability,
            lawfulContext: lawfulContext ?? self.lawfulContext(patientId: userId),
            sessionRef: UUID(),
            contextRef: "context-ref",
            provenanceRefs: [UUID()],
            auditRefs: [UUID()]
        )
    }

    private func makeRevocationRequest(
        finalidade: String = "patient-self-governance",
        scopeSummary: [String] = ["patient:context:read"],
        retentionAcknowledged: Bool = true,
        finalDocumentAcknowledged: Bool = true
    ) -> ConsentRevocationRequest {
        let userId = UUID()
        return ConsentRevocationRequest(
            requestId: UUID(),
            patientUserId: userId,
            consentId: UUID(),
            finalidade: finalidade,
            scopeSummary: scopeSummary,
            rationale: "patient request",
            lawfulContext: lawfulContext(patientId: userId),
            retentionAcknowledged: retentionAcknowledged,
            finalDocumentImmutabilityAcknowledged: finalDocumentAcknowledged,
            provenanceRef: UUID(),
            auditRef: UUID()
        )
    }

    private func lawfulContext(patientId: UUID) -> [String: String] {
        [
            "actorRole": "user-agent",
            "scope": "patient-self-service",
            "serviceId": UUID().uuidString,
            "patientUserId": patientId.uuidString,
            "finalidade": "patient-self-governance",
            "sessionId": UUID().uuidString
        ]
    }

    func testUserAgentProhibitedCapabilityDenied() {
        let scope = UserAgentScope(userId: UUID(), cpfHashRef: "hash", actorId: "actor", runtimeId: "runtime", dataLayersAllowed: [], dataLayersDenied: [])
        let request = UserAgentRequest(scope: scope, requestedCapability: .diagnose, lawfulContext: ["patientUserId": UUID().uuidString, "finalidade": "treatment"])
        
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .prohibitedCapability(.diagnose))
        }
    }

    func testUserAgentMissingLawfulContextDenied() {
        let scope = UserAgentScope(userId: UUID(), cpfHashRef: "hash", actorId: "actor", runtimeId: "runtime", dataLayersAllowed: [], dataLayersDenied: [])
        let request = UserAgentRequest(scope: scope, requestedCapability: .explainOwnData, lawfulContext: [:])
        
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .missingLawfulContext)
        }
    }

    func testUserAgentRawCPFLeakDenied() {
        let userId = UUID()
        let scope = UserAgentScope(userId: userId, cpfHashRef: "hash", actorId: "actor", runtimeId: "runtime", dataLayersAllowed: [.directIdentifiers], dataLayersDenied: [], allowDirectIdentifiersFlowExplicit: false)
        let request = UserAgentRequest(scope: scope, requestedCapability: .explainOwnData, lawfulContext: lawfulContext(patientId: userId))
        
        XCTAssertThrowsError(try UserAgentGovernanceValidator.validateRequest(request)) { error in
            XCTAssertEqual(error as? UserAgentFailure, .directIdentifierFlowRequiresExplicitPolicy)
        }
    }
}
