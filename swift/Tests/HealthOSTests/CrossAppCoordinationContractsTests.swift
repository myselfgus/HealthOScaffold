import XCTest
@testable import HealthOSCore

final class CrossAppCoordinationContractsTests: XCTestCase {
    func testEnvelopeIsNeverLegalAuthorizing() {
        let envelope = makeEnvelope(legalAuthorizing: true)
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .legalAuthorizingMustBeFalse)
        }
    }

    func testAllowedActionRequiresCoreCommandMediation() {
        var envelope = makeEnvelope()
        envelope = AppSurfaceEnvelope(
            requestId: envelope.requestId,
            appKind: envelope.appKind,
            actorRole: envelope.actorRole,
            subjectRefs: envelope.subjectRefs,
            allowedActions: [AppAllowedAction(action: .submitCapture, coreCommandRef: "app://direct", requiresCoreMediation: false, legalAuthorizing: false)],
            deniedActions: envelope.deniedActions,
            redaction: envelope.redaction
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .actionNotMediated)
        }
    }

    func testDeniedActionRequiresTypedReason() {
        let denied = AppDeniedAction(action: .inspectQueue, reason: .appMismatch)
        XCTAssertEqual(denied.reason, .appMismatch)
    }

    func testAppMismatchDeniesAction() {
        var envelope = makeEnvelope(app: .scribe, role: .professional)
        envelope = AppSurfaceEnvelope(
            requestId: envelope.requestId,
            appKind: .scribe,
            actorRole: .professional,
            subjectRefs: envelope.subjectRefs,
            allowedActions: [AppAllowedAction(action: .inspectConsent, coreCommandRef: "core://sortio.inspect", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [],
            redaction: envelope.redaction
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .appMismatch(.inspectConsent))
        }
    }

    func testRoleMismatchDeniesAction() {
        var envelope = makeEnvelope(app: .cloudClinic, role: .observerAuditor)
        envelope = AppSurfaceEnvelope(
            requestId: envelope.requestId,
            appKind: .cloudClinic,
            actorRole: .observerAuditor,
            subjectRefs: envelope.subjectRefs,
            allowedActions: [AppAllowedAction(action: .submitGateReview, coreCommandRef: "core://scribe.gate", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [],
            redaction: envelope.redaction
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .appMismatch(.submitGateReview))
        }
    }

    func testSafePatientRefCannotContainCPFOrStoragePath() {
        let ref = SafePatientRef(core: .init(refId: "patient", displayLabel: "cpf 123", redactionStatus: .redacted, capability: .navigationOnly))
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateRefCore(ref.core)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .rawSensitiveLeak)
        }
    }

    func testNavigationOnlyRefCannotGrantDataAccess() {
        let ref = SafeSessionRef(core: .init(refId: "session", redactionStatus: .pseudonymized, capability: .navigationOnly, grantsDataAccess: true))
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateRefCore(ref.core)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .navigationRefCannotGrantAccess)
        }
    }

    func testRedactionDefaultsDenyReidentificationAndDirectIdentifierExposure() {
        var envelope = makeEnvelope()
        envelope = AppSurfaceEnvelope(
            requestId: envelope.requestId,
            appKind: envelope.appKind,
            actorRole: envelope.actorRole,
            subjectRefs: envelope.subjectRefs,
            allowedActions: envelope.allowedActions,
            deniedActions: envelope.deniedActions,
            redaction: .init(status: .restricted, directIdentifierPresent: true, reidentificationRequired: true, reidentificationAllowed: false, reason: "restricted", lawfulScopeSummary: "scope")
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .directIdentifierForbidden)
        }
    }

    func testSortioCannotReceiveCloudClinicAction() {
        let envelope = AppSurfaceEnvelope(
            appKind: .sortio,
            actorRole: .patient,
            subjectRefs: makeSubjectRefs(),
            allowedActions: [AppAllowedAction(action: .inspectQueue, coreCommandRef: "core://cloud.queue", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [],
            redaction: makeRedaction()
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope))
    }

    func testCloudClinicCannotReceiveClinicalGateApprovalAction() {
        let envelope = AppSurfaceEnvelope(
            appKind: .cloudClinic,
            actorRole: .serviceAdmin,
            subjectRefs: makeSubjectRefs(),
            allowedActions: [AppAllowedAction(action: .submitGateReview, coreCommandRef: "core://gate.resolve", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [],
            redaction: makeRedaction()
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope))
    }

    func testNotificationDoesNotExposeSensitivePayloadOrProviderSecrets() {
        let notification = AppNotificationSurface(
            id: UUID(),
            appKind: .cloudClinic,
            actorRole: .serviceAdmin,
            kind: .providerDegraded,
            summary: "provider_secret key leaked",
            refs: makeSubjectRefs(),
            payloadContainsSensitiveData: false,
            grantsAccess: false
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateNotification(notification)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .rawSensitiveLeak)
        }
    }

    func testPatientNotificationObligationRequiresCompletionRecord() {
        let record = NotificationObligationRecord(
            obligationId: UUID(),
            kind: .emergencyAccessOccurred,
            patientUserRef: SafeUserRef(core: .init(refId: "user", redactionStatus: .pseudonymized, capability: .navigationOnly)),
            markedComplete: true,
            completionRecordedAt: nil,
            completionRecordRef: nil
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateNotificationObligation(record)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .patientObligationRequiresRecordedCompletion)
        }
    }

    func testScribeSurfaceCannotExposeSortioGovernanceControls() {
        let envelope = AppSurfaceEnvelope(
            appKind: .scribe,
            actorRole: .professional,
            subjectRefs: makeSubjectRefs(),
            allowedActions: [AppAllowedAction(action: .requestConsentRevocation, coreCommandRef: "core://sortio.consent.revoke", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [],
            redaction: makeRedaction()
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope))
    }

    private func makeEnvelope(
        app: AppKind = .scribe,
        role: AppActorRole = .professional,
        legalAuthorizing: Bool = false
    ) -> AppSurfaceEnvelope {
        AppSurfaceEnvelope(
            appKind: app,
            actorRole: role,
            subjectRefs: makeSubjectRefs(),
            allowedActions: [AppAllowedAction(action: .submitCapture, coreCommandRef: "core://scribe.capture", requiresCoreMediation: true, legalAuthorizing: false)],
            deniedActions: [AppDeniedAction(action: .inspectQueue, reason: .appMismatch)],
            redaction: makeRedaction(),
            legalAuthorizing: legalAuthorizing
        )
    }

    private func makeSubjectRefs() -> AppSubjectRefs {
        AppSubjectRefs(
            user: SafeUserRef(core: .init(refId: "user-ref", displayLabel: "USR-001", redactionStatus: .pseudonymized, capability: .navigationOnly)),
            patient: SafePatientRef(core: .init(refId: "patient-ref", displayLabel: "PT-001", redactionStatus: .pseudonymized, capability: .navigationOnly)),
            professional: SafeProfessionalRef(core: .init(refId: "professional-ref", displayLabel: "PRO-001", redactionStatus: .pseudonymized, capability: .navigationOnly)),
            service: SafeServiceRef(core: .init(refId: "service-ref", displayLabel: "SRV-001", redactionStatus: .none, capability: .navigationOnly)),
            session: SafeSessionRef(core: .init(refId: "session-ref", displayLabel: "SES-001", redactionStatus: .redacted, capability: .navigationOnly)),
            draft: SafeDraftRef(core: .init(refId: "draft-ref", displayLabel: "DRF-001", redactionStatus: .redacted, capability: .navigationOnly)),
            gate: SafeGateRef(core: .init(refId: "gate-ref", displayLabel: "GAT-001", redactionStatus: .redacted, capability: .navigationOnly)),
            artifact: SafeArtifactRef(core: .init(refId: "artifact-ref", displayLabel: "ART-001", redactionStatus: .deidentified, capability: .navigationOnly)),
            export: SafeExportRef(core: .init(refId: "export-ref", displayLabel: "EXP-001", redactionStatus: .deidentified, capability: .navigationOnly)),
            audit: SafeAuditRef(core: .init(refId: "audit-ref", displayLabel: "AUD-001", redactionStatus: .restricted, capability: .navigationOnly)),
            provenance: SafeProvenanceRef(core: .init(refId: "prov-ref", displayLabel: "PRV-001", redactionStatus: .restricted, capability: .navigationOnly))
        )
    }

    func testSortioAdapterRejectRawCPF() {
        let envelope = AppSurfaceEnvelope(
            appKind: .sortio,
            actorRole: .patient,
            subjectRefs: makeSubjectRefs(),
            allowedActions: [],
            deniedActions: [],
            redaction: RedactionSurfaceStatus(
                status: .redacted,
                directIdentifierPresent: true,
                reidentificationRequired: false,
                reidentificationAllowed: false,
                reason: "raw cpf leak",
                lawfulScopeSummary: "test"
            )
        )
        XCTAssertThrowsError(try CrossAppSurfaceValidator.validateEnvelope(envelope)) { error in
            XCTAssertEqual(error as? CrossAppSurfaceFailure, .directIdentifierForbidden)
        }
    }

    private func makeRedaction() -> RedactionSurfaceStatus {
        RedactionSurfaceStatus(
            status: .pseudonymized,
            directIdentifierPresent: false,
            reidentificationRequired: false,
            reidentificationAllowed: false,
            reason: "default app-safe posture",
            lawfulScopeSummary: "professional session mediated by core"
        )
    }
}
