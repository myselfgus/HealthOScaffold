import Foundation
import XCTest
@testable import HealthOSCore

final class ServiceOperationsGovernanceTests: XCTestCase {
    func testServiceAccessWithoutLawfulContextFails() {
        var context = makeContext()
        context = ServiceOperationalContext(
            serviceId: context.serviceId,
            actorId: context.actorId,
            actorRole: context.actorRole,
            memberId: context.memberId,
            professionalUserId: context.professionalUserId,
            patientUserId: context.patientUserId,
            lawfulContext: [:],
            finalidade: context.finalidade,
            scope: context.scope,
            allowedOperations: context.allowedOperations,
            deniedOperations: context.deniedOperations,
            provenanceRefs: context.provenanceRefs,
            auditRefs: context.auditRefs,
            viaCoreMediation: context.viaCoreMediation
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateContext(context, sensitive: true))
    }

    func testServiceAccessWithoutFinalidadeFailsWhenSensitive() {
        var context = makeContext()
        context = ServiceOperationalContext(
            serviceId: context.serviceId,
            actorId: context.actorId,
            actorRole: context.actorRole,
            memberId: context.memberId,
            professionalUserId: context.professionalUserId,
            patientUserId: context.patientUserId,
            lawfulContext: context.lawfulContext,
            finalidade: nil,
            scope: context.scope,
            allowedOperations: context.allowedOperations,
            deniedOperations: context.deniedOperations,
            provenanceRefs: context.provenanceRefs,
            auditRefs: context.auditRefs,
            viaCoreMediation: context.viaCoreMediation
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateContext(context, sensitive: true)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .missingFinalidade)
        }
    }

    func testValidServiceContextPasses() throws {
        XCTAssertNoThrow(try ServiceOperationsValidator.validateContext(makeContext(), sensitive: true))
    }

    func testServiceRelationDoesNotReplaceConsent() {
        let relationship = PatientServiceRelationshipSurface(
            serviceId: UUID(),
            patientUserId: UUID(),
            relationshipStatus: .active,
            consentSummary: [],
            visibilityStatus: .visible,
            retentionCustodyMarkers: ["service_retention_obligation"],
            accessRestrictions: ["consent-and-finalidade-required"],
            appSafePatientRef: "patient-token",
            directIdentifiersExposed: false
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validatePatientServiceRelationship(relationship)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .relationshipDoesNotReplaceConsent)
        }
    }

    func testInactiveMemberFails() {
        let membership = makeMembership(status: .inactive)
        XCTAssertThrowsError(try ServiceOperationsValidator.validateMembership(membership)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .inactiveMembership)
        }
    }

    func testSuspendedOrRevokedMemberFails() {
        XCTAssertThrowsError(try ServiceOperationsValidator.validateMembership(makeMembership(status: .suspended)))
        XCTAssertThrowsError(try ServiceOperationsValidator.validateMembership(makeMembership(status: .revoked)))
    }

    func testAdminRoleCannotExecuteProfessionalAction() {
        let context = ServiceOperationalContext(
            serviceId: UUID(),
            actorId: "cloudclinic.admin",
            actorRole: .serviceAdmin,
            lawfulContext: lawfulContext(),
            finalidade: "service-ops",
            scope: "service-operations",
            allowedOperations: [.professionalDocumentFinalize],
            viaCoreMediation: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateContext(context, sensitive: true)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .administrativeRoleCannotPerformProfessionalAction)
        }
    }

    func testProfessionalRoleRequiresActiveHabilitation() {
        let membership = ServiceMembershipContract(
            memberId: UUID(),
            serviceId: UUID(),
            role: .professional,
            status: .active,
            professionalUserId: UUID(),
            professionalRecordId: UUID(),
            habilitationId: nil
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateMembership(membership)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .professionalRequiresRecordAndHabilitation)
        }
    }

    func testActiveHabilitationAllowsProfessionalOperation() throws {
        let surface = ProfessionalHabilitationSurface(
            professionalUserId: UUID(),
            professionalRecordId: UUID(),
            serviceId: UUID(),
            habilitationId: UUID(),
            status: .active,
            allowedScope: ["professional:document:draft"],
            validFrom: .now.addingTimeInterval(-3600),
            validUntil: .now.addingTimeInterval(3600),
            appSafeInformational: true,
            decidedByCore: true
        )
        XCTAssertNoThrow(try ServiceOperationsValidator.validateProfessionalHabilitation(surface))
    }

    func testExpiredHabilitationFails() {
        let surface = ProfessionalHabilitationSurface(
            professionalUserId: UUID(),
            professionalRecordId: UUID(),
            serviceId: UUID(),
            habilitationId: UUID(),
            status: .active,
            allowedScope: ["professional:document:draft"],
            validFrom: .now.addingTimeInterval(-7200),
            validUntil: .now.addingTimeInterval(-1800),
            appSafeInformational: true,
            decidedByCore: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateProfessionalHabilitation(surface)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .professionalHabilitationExpired)
        }
    }

    func testCloudClinicSurfaceDoesNotDecideHabilitation() {
        let surface = ProfessionalHabilitationSurface(
            professionalUserId: UUID(),
            professionalRecordId: UUID(),
            serviceId: UUID(),
            habilitationId: UUID(),
            status: .active,
            allowedScope: ["professional:document:draft"],
            validFrom: .now,
            appSafeInformational: true,
            decidedByCore: false
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateProfessionalHabilitation(surface)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .cloudClinicMustBeMediated)
        }
    }

    func testPatientServiceSurfaceCannotExposeRawCPFAndRetentionDoesNotGrantAccess() {
        let relationship = PatientServiceRelationshipSurface(
            serviceId: UUID(),
            patientUserId: UUID(),
            relationshipStatus: .active,
            consentSummary: [ConsentSummarySurface(finalidade: "care-context-retrieval", granted: true)],
            visibilityStatus: .visible,
            retentionCustodyMarkers: ["service_retention_obligation"],
            accessRestrictions: [],
            appSafePatientRef: "cpf:123",
            directIdentifiersExposed: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validatePatientServiceRelationship(relationship))
    }

    func testQueueItemDoesNotGrantAccessAndNeedsLawfulScope() {
        let queue = ServiceQueueItem(
            serviceId: UUID(),
            kind: .draftAwaitingGate,
            status: "pending",
            lawfulScopeSummary: "",
            coreMediatedActionRef: "",
            appSafeSummary: "summary",
            containsSensitivePayload: false,
            grantsAccessByItself: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateQueueItem(queue))
    }

    func testQueueAppSafeSummaryCannotExposeRawSensitivePayload() {
        let queue = ServiceQueueItem(
            serviceId: UUID(),
            kind: .documentPendingReview,
            status: "pending",
            lawfulScopeSummary: "service-ops read-only",
            coreMediatedActionRef: "core://document/summary",
            appSafeSummary: "raw clinical payload",
            containsSensitivePayload: true,
            grantsAccessByItself: false
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateQueueItem(queue)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .queueRawPayloadExposureDenied)
        }
    }

    func testDraftDoesNotAppearAsFinalAndFinalRequiresApprovedGate() {
        let draftLike = ServiceDocumentSurface(
            artifactOrDraftId: UUID(),
            kind: .soap,
            status: .draft,
            patientRef: "patient-token",
            professionalRef: "professional-token",
            gateStatus: .pending,
            finalizationStatus: "finalized",
            provenanceRefs: [UUID()],
            createdAt: .now,
            updatedAt: .now,
            accessScopeSummary: "service-ops",
            contentExposedRaw: false,
            coreTransitionOnly: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateDocumentSurface(draftLike)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .draftCannotBeFinal)
        }

        let finalWithoutGate = ServiceDocumentSurface(
            artifactOrDraftId: UUID(),
            kind: .soap,
            status: .final,
            patientRef: "patient-token",
            professionalRef: "professional-token",
            gateStatus: .pending,
            finalizationStatus: "finalized",
            provenanceRefs: [UUID()],
            createdAt: .now,
            updatedAt: .now,
            accessScopeSummary: "service-ops",
            contentExposedRaw: false,
            coreTransitionOnly: true
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateDocumentSurface(finalWithoutGate))
    }

    func testAdminCannotApproveProfessionalGate() {
        let item = GateWorklistItem(
            gateRequestId: UUID(),
            targetArtifactOrDraftRef: "draft-ref",
            requiredRole: .professional,
            status: .pending,
            createdAt: .now,
            rationaleSummarySafe: "pending professional review"
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateGateWorklistItem(item, resolverRole: .serviceAdmin)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .adminCannotResolveProfessionalGate)
        }
    }

    func testCloudClinicCannotFinalizeDocumentDirectly() {
        let surface = ServiceDocumentSurface(
            artifactOrDraftId: UUID(),
            kind: .soap,
            status: .approved,
            patientRef: "patient-token",
            professionalRef: "professional-token",
            gateStatus: .approved,
            finalizationStatus: "ready_for_core",
            provenanceRefs: [UUID()],
            createdAt: .now,
            updatedAt: .now,
            accessScopeSummary: "service-ops",
            contentExposedRaw: false,
            coreTransitionOnly: false
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateDocumentSurface(surface)) { error in
            XCTAssertEqual(error as? ServiceOperationsFailure, .cloudClinicCannotFinalizeDirectly)
        }
    }

    func testAdministrativeTaskAllowedPassesAndForbiddenFails() {
        let allowed = ServiceAdministrativeTask(
            serviceId: UUID(),
            requestedByActorId: "cloudclinic.ops",
            requestedByRole: .operationalCoordinator,
            kind: .requestMissingDocument,
            lawfulContext: lawfulContext(),
            finalidade: "service-ops",
            consentValidated: true,
            habilitationValidated: true,
            generatedAuditRef: UUID(),
            generatedProvenanceRef: UUID()
        )
        XCTAssertNoThrow(try ServiceOperationsValidator.validateAdministrativeTask(allowed, sensitive: true))

        let forbidden = ServiceAdministrativeTask(
            serviceId: UUID(),
            requestedByActorId: "cloudclinic.ops",
            requestedByRole: .operationalCoordinator,
            kind: .diagnose,
            lawfulContext: lawfulContext(),
            finalidade: "service-ops",
            consentValidated: true,
            habilitationValidated: true,
            generatedAuditRef: UUID(),
            generatedProvenanceRef: UUID()
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateAdministrativeTask(forbidden, sensitive: true))
    }

    func testAdministrativeTaskCannotBypassConsentHabilitationFinalityAndRequiresAuditProvenance() {
        let bypass = ServiceAdministrativeTask(
            serviceId: UUID(),
            requestedByActorId: "cloudclinic.ops",
            requestedByRole: .operationalCoordinator,
            kind: .notifyPendingGate,
            lawfulContext: lawfulContext(),
            finalidade: "",
            consentValidated: false,
            habilitationValidated: false,
            generatedAuditRef: nil,
            generatedProvenanceRef: nil
        )
        XCTAssertThrowsError(try ServiceOperationsValidator.validateAdministrativeTask(bypass, sensitive: true))
    }

    private func makeContext() -> ServiceOperationalContext {
        ServiceOperationalContext(
            serviceId: UUID(),
            actorId: "cloudclinic.professional",
            actorRole: .professional,
            memberId: UUID(),
            professionalUserId: UUID(),
            patientUserId: UUID(),
            lawfulContext: lawfulContext(),
            finalidade: "care-context-retrieval",
            scope: "service-ops-professional",
            allowedOperations: [.professionalSessionStart, .professionalDocumentDraft],
            deniedOperations: [.professionalDocumentFinalize],
            provenanceRefs: [UUID()],
            auditRefs: [UUID()],
            viaCoreMediation: true
        )
    }

    private func makeMembership(status: ServiceMembershipStatus) -> ServiceMembershipContract {
        ServiceMembershipContract(
            memberId: UUID(),
            serviceId: UUID(),
            role: .operationalCoordinator,
            status: status,
            professionalUserId: nil,
            professionalRecordId: nil,
            habilitationId: nil
        )
    }

    private func lawfulContext() -> [String: String] {
        [
            "actorRole": "service-operator",
            "scope": "service-operations",
            "serviceId": UUID().uuidString,
            "patientUserId": UUID().uuidString,
            "finalidade": "care-context-retrieval"
        ]
    }
}
