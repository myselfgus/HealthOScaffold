import Foundation
import HealthOSCore

#if canImport(XCTest)
import XCTest

final class ScribeProfessionalWorkspaceContractsTests: XCTestCase {
    func testWorkspaceFailsWithoutActiveHabilitation() {
        let context = makeWorkspace(habilitationId: nil, finalidade: "care", hasPatient: true, allowed: [.retrieveContext])

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateWorkspaceContext(context)) { error in
            XCTAssertEqual(error as? ScribeBoundaryValidationError, .boundaryIssue(.missingHabilitation))
        }
    }

    func testWorkspaceFailsWithoutFinalidadeForContextAndDraft() {
        let context = makeWorkspace(habilitationId: UUID(), finalidade: nil, hasPatient: true, allowed: [.retrieveContext, .composeDraft])

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateWorkspaceContext(context)) { error in
            XCTAssertEqual(error as? ScribeBoundaryValidationError, .boundaryIssue(.missingFinalidade))
        }
    }

    func testWorkspaceBlocksPatientScopedOpsWithoutPatientSelection() {
        let context = makeWorkspace(habilitationId: UUID(), finalidade: "care", hasPatient: false, allowed: [.submitCapture])

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateWorkspaceContext(context)) { error in
            XCTAssertEqual(error as? ScribeBoundaryValidationError, .boundaryIssue(.patientNotSelected))
        }
    }

    func testWorkspaceValidContextPasses() throws {
        let context = makeWorkspace(habilitationId: UUID(), finalidade: "care", hasPatient: true, allowed: [.submitCapture, .retrieveContext, .composeDraft])
        XCTAssertNoThrow(try ScribeBoundaryValidator.validateWorkspaceContext(context))
    }

    func testSessionStateDoesNotOpenGateWithoutDraft() {
        XCTAssertThrowsError(
            try ScribeBoundaryValidator.validateTransition(
                from: .draftPending,
                to: .awaitingGate,
                hasDraft: false,
                gateApproved: false,
                degraded: false
            )
        ) { error in
            XCTAssertEqual(error as? ScribeBoundaryValidationError, .boundaryIssue(.gateRequiresDraft))
        }
    }

    func testSessionStateDoesNotFinalizeWithoutApprovedGate() {
        XCTAssertThrowsError(
            try ScribeBoundaryValidator.validateTransition(
                from: .finalizationPending,
                to: .finalized,
                hasDraft: true,
                gateApproved: false,
                degraded: false
            )
        ) { error in
            XCTAssertEqual(error as? ScribeBoundaryValidationError, .boundaryIssue(.finalizationRequiresApprovedGate))
        }
    }

    func testCaptureSurfaceHonestyRules() {
        let seededAsProvider = ScribeCaptureTranscriptionSurface(
            captureId: UUID(),
            captureKind: .seededText,
            transcriptionStatus: .providerBacked,
            providerExecutionRef: "provider:real",
            inputObjectRef: "capture://seeded"
        )
        XCTAssertThrowsError(try ScribeBoundaryValidator.validateCaptureSurface(seededAsProvider))

        let audioWithoutTranscript = ScribeCaptureTranscriptionSurface(
            captureId: UUID(),
            captureKind: .audioFile,
            transcriptionStatus: .ready,
            inputObjectRef: "capture://audio"
        )
        XCTAssertThrowsError(try ScribeBoundaryValidator.validateCaptureSurface(audioWithoutTranscript))

        let stubMarkedProvider = ScribeCaptureTranscriptionSurface(
            captureId: UUID(),
            captureKind: .audioFile,
            transcriptionStatus: .stub,
            providerExecutionRef: "provider:stub",
            inputObjectRef: "capture://audio"
        )
        XCTAssertThrowsError(try ScribeBoundaryValidator.validateCaptureSurface(stubMarkedProvider))
    }

    func testRetrievalSurfaceFailsWithoutLawfulFinalidadeAndBoundaryLeaks() {
        let retrieval = ScribeRetrievalContextSurface(
            retrievalRequestId: UUID(),
            retrievalMode: .lexical,
            scoreKind: .semantic,
            contextStatus: .ready,
            sourceCount: 1,
            sourceLayerSummaries: ["raw-index-hit", "operational"],
            lawfulScopeSummary: "bounded",
            redactionStatus: "redacted"
        )

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateRetrievalSurface(retrieval, lawfulContext: [:]))

        XCTAssertThrowsError(
            try ScribeBoundaryValidator.validateRetrievalSurface(
                retrieval,
                lawfulContext: ["finalidade": "care"]
            )
        )
    }

    func testDraftSurfaceAlwaysDraftOnlyAndGateRequired() {
        let invalid = ScribeDraftReviewSurface(
            draftId: UUID(),
            draftKind: .soap,
            draftStatus: "approved",
            draftOnly: false,
            gateStillRequired: false,
            createdByRuntimeActor: "aaci.draft-composer",
            humanReviewStatus: "none"
        )

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateDraftSurface(invalid))
    }

    func testGateReviewRequiresProfessionalAndRationale() {
        let clinicalByAdmin = ScribeGateReviewContract(
            gateRequestId: UUID(),
            targetDraftId: UUID(),
            targetKind: .soap,
            requiredReviewerRole: "admin",
            reviewerProfessionalId: nil,
            reviewAction: .approve,
            gateResolutionId: UUID()
        )
        XCTAssertThrowsError(try ScribeBoundaryValidator.validateGateReview(clinicalByAdmin))

        let rejectWithoutReason = ScribeGateReviewContract(
            gateRequestId: UUID(),
            targetDraftId: UUID(),
            targetKind: .soap,
            requiredReviewerRole: "professional",
            reviewerProfessionalId: UUID(),
            reviewAction: .reject,
            rationale: nil,
            gateResolutionId: UUID()
        )
        XCTAssertThrowsError(try ScribeBoundaryValidator.validateGateReview(rejectWithoutReason))
    }

    func testFinalDocumentRequiresApprovedGateAndLineage() {
        let gate = ScribeGateReviewContract(
            gateRequestId: UUID(),
            targetDraftId: UUID(),
            targetKind: .soap,
            requiredReviewerRole: "professional",
            reviewerProfessionalId: UUID(),
            reviewAction: .approve,
            rationale: "ok",
            gateResolutionId: UUID()
        )

        let final = ScribeFinalDocumentSurface(
            finalDocumentId: UUID(),
            sourceDraftId: UUID(),
            gateRequestId: gate.gateRequestId,
            gateResolutionId: gate.gateResolutionId,
            finalizationStatus: "finalized",
            documentHash: "hash",
            signatureStatus: "unsigned",
            retentionClass: "clinical-note",
            appSafeSummary: "ok"
        )

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateFinalDocument(gate: gate, finalDocument: final))
    }

    func testAppBoundaryDoesNotAllowSensitiveLeaks() {
        let context = makeWorkspace(habilitationId: UUID(), finalidade: "care", hasPatient: true, allowed: [.retrieveContext])
        let state = ScribeAppRuntimeState(
            workspaceContext: context,
            sessionState: .contextReady,
            retrieval: ScribeRetrievalContextSurface(
                retrievalRequestId: UUID(),
                retrievalMode: .lexical,
                scoreKind: .deterministic,
                contextStatus: .ready,
                sourceCount: 1,
                sourceLayerSummaries: ["reidentification-map"],
                lawfulScopeSummary: "bounded",
                redactionStatus: "redacted"
            ),
            gosRuntimeSummary: "informational",
            providerRuntimeSummary: "provider_secret=token"
        )

        XCTAssertThrowsError(try ScribeBoundaryValidator.validateAppBoundary(state: state))
    }

    private func makeWorkspace(
        habilitationId: UUID?,
        finalidade: String?,
        hasPatient: Bool,
        allowed: [ScribeWorkspaceOperation]
    ) -> ProfessionalWorkspaceContext {
        ProfessionalWorkspaceContext(
            professionalUserId: UUID(),
            serviceId: UUID(),
            habilitationId: habilitationId,
            selectedPatientRef: hasPatient ? .init(patientUserId: UUID(), patientToken: "patient-ref") : nil,
            sessionId: UUID(),
            lawfulContext: ["actorRole": "professional-agent"],
            finalidade: finalidade,
            allowedOperations: allowed,
            deniedOperations: ScribeWorkspaceOperation.allCases.filter { !allowed.contains($0) }
        )
    }
}
#endif
