import Foundation

public enum ScribeProfessionalSessionState: String, Codable, Sendable, CaseIterable {
    case idle
    case serviceSelected = "service_selected"
    case professionalValidated = "professional_validated"
    case patientSelected = "patient_selected"
    case captureReady = "capture_ready"
    case capturing
    case transcriptionPending = "transcription_pending"
    case transcriptionReady = "transcription_ready"
    case transcriptionDegraded = "transcription_degraded"
    case contextRetrievalPending = "context_retrieval_pending"
    case contextReady = "context_ready"
    case contextDegraded = "context_degraded"
    case draftPending = "draft_pending"
    case draftReady = "draft_ready"
    case awaitingGate = "awaiting_gate"
    case gateApproved = "gate_approved"
    case gateRejected = "gate_rejected"
    case finalizationPending = "finalization_pending"
    case finalized
    case failed
}

public enum ScribeWorkspaceOperation: String, Codable, Sendable, CaseIterable {
    case selectPatient = "select_patient"
    case submitCapture = "submit_capture"
    case transcribe = "transcribe"
    case retrieveContext = "retrieve_context"
    case composeDraft = "compose_draft"
    case openGate = "open_gate"
    case resolveGate = "resolve_gate"
    case finalizeDocument = "finalize_document"
}

public enum ScribeBoundaryIssue: String, Codable, Sendable {
    case missingHabilitation = "missing_habilitation"
    case missingFinalidade = "missing_finalidade"
    case patientNotSelected = "patient_not_selected"
    case invalidTransition = "invalid_transition"
    case gateRequiresDraft = "gate_requires_draft"
    case finalizationRequiresApprovedGate = "finalization_requires_approved_gate"
    case clinicalGateRequiresProfessional = "clinical_gate_requires_professional"
    case rationaleRequired = "rationale_required"
    case sensitiveBoundaryLeak = "sensitive_boundary_leak"
}

public struct ScribePatientSelectionRef: Codable, Sendable {
    public let patientUserId: UUID
    public let patientToken: String

    public init(patientUserId: UUID, patientToken: String) {
        self.patientUserId = patientUserId
        self.patientToken = patientToken
    }
}

public struct ProfessionalWorkspaceContext: Codable, Sendable {
    public let professionalUserId: UUID
    public let professionalRecordId: UUID?
    public let serviceId: UUID
    public let serviceMemberId: UUID?
    public let habilitationId: UUID?
    public let selectedPatientRef: ScribePatientSelectionRef?
    public let sessionId: UUID
    public let lawfulContext: [String: String]
    public let finalidade: String?
    public let allowedOperations: [ScribeWorkspaceOperation]
    public let deniedOperations: [ScribeWorkspaceOperation]
    public let runtimeStateRefs: [String]
    public let provenanceRefs: [UUID]
    public let auditRefs: [UUID]

    public init(
        professionalUserId: UUID,
        professionalRecordId: UUID? = nil,
        serviceId: UUID,
        serviceMemberId: UUID? = nil,
        habilitationId: UUID?,
        selectedPatientRef: ScribePatientSelectionRef? = nil,
        sessionId: UUID,
        lawfulContext: [String: String],
        finalidade: String?,
        allowedOperations: [ScribeWorkspaceOperation],
        deniedOperations: [ScribeWorkspaceOperation],
        runtimeStateRefs: [String] = [],
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = []
    ) {
        self.professionalUserId = professionalUserId
        self.professionalRecordId = professionalRecordId
        self.serviceId = serviceId
        self.serviceMemberId = serviceMemberId
        self.habilitationId = habilitationId
        self.selectedPatientRef = selectedPatientRef
        self.sessionId = sessionId
        self.lawfulContext = lawfulContext
        self.finalidade = finalidade?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.allowedOperations = allowedOperations
        self.deniedOperations = deniedOperations
        self.runtimeStateRefs = runtimeStateRefs
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
    }
}

public enum ScribeCaptureKind: String, Codable, Sendable {
    case seededText = "seeded_text"
    case audioFile = "audio_file"
    case microphoneFuturePlaceholder = "microphone_future_placeholder"
}

public enum ScribeTranscriptionSurfaceStatus: String, Codable, Sendable {
    case unavailable
    case degraded
    case ready
    case stub
    case providerBacked = "provider_backed"
}

public struct ScribeCaptureTranscriptionSurface: Codable, Sendable {
    public let captureId: UUID
    public let captureKind: ScribeCaptureKind
    public let transcriptionStatus: ScribeTranscriptionSurfaceStatus
    public let providerExecutionRef: String?
    public let inputObjectRef: String
    public let transcriptObjectRef: String?
    public let confidenceSummary: String?
    public let provenanceRefs: [UUID]

    public init(
        captureId: UUID,
        captureKind: ScribeCaptureKind,
        transcriptionStatus: ScribeTranscriptionSurfaceStatus,
        providerExecutionRef: String? = nil,
        inputObjectRef: String,
        transcriptObjectRef: String? = nil,
        confidenceSummary: String? = nil,
        provenanceRefs: [UUID] = []
    ) {
        self.captureId = captureId
        self.captureKind = captureKind
        self.transcriptionStatus = transcriptionStatus
        self.providerExecutionRef = providerExecutionRef
        self.inputObjectRef = inputObjectRef
        self.transcriptObjectRef = transcriptObjectRef
        self.confidenceSummary = confidenceSummary
        self.provenanceRefs = provenanceRefs
    }
}

public enum ScribeRetrievalMode: String, Codable, Sendable {
    case lexical
    case semantic
    case hybrid
    case unavailable
}

public enum ScribeRetrievalScoreKind: String, Codable, Sendable {
    case deterministic
    case lexical
    case semantic
    case stub
}

public enum ScribeContextStatus: String, Codable, Sendable {
    case ready
    case partial
    case empty
    case degraded
    case denied
}

public struct ScribeRetrievalContextSurface: Codable, Sendable {
    public let retrievalRequestId: UUID
    public let retrievalMode: ScribeRetrievalMode
    public let scoreKind: ScribeRetrievalScoreKind
    public let contextStatus: ScribeContextStatus
    public let sourceCount: Int
    public let sourceLayerSummaries: [String]
    public let lawfulScopeSummary: String
    public let redactionStatus: String
    public let provenanceRefs: [UUID]

    public init(
        retrievalRequestId: UUID,
        retrievalMode: ScribeRetrievalMode,
        scoreKind: ScribeRetrievalScoreKind,
        contextStatus: ScribeContextStatus,
        sourceCount: Int,
        sourceLayerSummaries: [String],
        lawfulScopeSummary: String,
        redactionStatus: String,
        provenanceRefs: [UUID] = []
    ) {
        self.retrievalRequestId = retrievalRequestId
        self.retrievalMode = retrievalMode
        self.scoreKind = scoreKind
        self.contextStatus = contextStatus
        self.sourceCount = sourceCount
        self.sourceLayerSummaries = sourceLayerSummaries
        self.lawfulScopeSummary = lawfulScopeSummary
        self.redactionStatus = redactionStatus
        self.provenanceRefs = provenanceRefs
    }
}

public enum ScribeDraftReviewKind: String, Codable, Sendable {
    case soap
    case referral
    case prescription
    case administrative
}

public struct ScribeDraftReviewSurface: Codable, Sendable {
    public let draftId: UUID
    public let draftKind: ScribeDraftReviewKind
    public let draftStatus: String
    public let draftOnly: Bool
    public let gateStillRequired: Bool
    public let createdByRuntimeActor: String
    public let sourceCaptureRef: String?
    public let sourceContextRef: String?
    public let provenanceRefs: [UUID]
    public let humanReviewStatus: String
    public let degradedReason: String?
    public let appSafePreview: String?

    public init(
        draftId: UUID,
        draftKind: ScribeDraftReviewKind,
        draftStatus: String,
        draftOnly: Bool = true,
        gateStillRequired: Bool = true,
        createdByRuntimeActor: String,
        sourceCaptureRef: String? = nil,
        sourceContextRef: String? = nil,
        provenanceRefs: [UUID] = [],
        humanReviewStatus: String,
        degradedReason: String? = nil,
        appSafePreview: String? = nil
    ) {
        self.draftId = draftId
        self.draftKind = draftKind
        self.draftStatus = draftStatus
        self.draftOnly = draftOnly
        self.gateStillRequired = gateStillRequired
        self.createdByRuntimeActor = createdByRuntimeActor
        self.sourceCaptureRef = sourceCaptureRef
        self.sourceContextRef = sourceContextRef
        self.provenanceRefs = provenanceRefs
        self.humanReviewStatus = humanReviewStatus
        self.degradedReason = degradedReason
        self.appSafePreview = appSafePreview
    }
}

public enum ScribeGateReviewAction: String, Codable, Sendable {
    case approve
    case reject
    case requestChanges = "request_changes"
}

public struct ScribeGateReviewContract: Codable, Sendable {
    public let gateRequestId: UUID
    public let targetDraftId: UUID
    public let targetKind: ScribeDraftReviewKind
    public let requiredReviewerRole: String
    public let reviewerProfessionalId: UUID?
    public let reviewAction: ScribeGateReviewAction
    public let rationale: String?
    public let timestamp: Date
    public let gateResolutionId: UUID
    public let provenanceRefs: [UUID]

    public init(
        gateRequestId: UUID,
        targetDraftId: UUID,
        targetKind: ScribeDraftReviewKind,
        requiredReviewerRole: String,
        reviewerProfessionalId: UUID?,
        reviewAction: ScribeGateReviewAction,
        rationale: String? = nil,
        timestamp: Date = .now,
        gateResolutionId: UUID,
        provenanceRefs: [UUID] = []
    ) {
        self.gateRequestId = gateRequestId
        self.targetDraftId = targetDraftId
        self.targetKind = targetKind
        self.requiredReviewerRole = requiredReviewerRole
        self.reviewerProfessionalId = reviewerProfessionalId
        self.reviewAction = reviewAction
        self.rationale = rationale?.trimmingCharacters(in: .whitespacesAndNewlines)
        self.timestamp = timestamp
        self.gateResolutionId = gateResolutionId
        self.provenanceRefs = provenanceRefs
    }
}

public struct ScribeFinalDocumentSurface: Codable, Sendable {
    public let finalDocumentId: UUID
    public let sourceDraftId: UUID
    public let gateRequestId: UUID
    public let gateResolutionId: UUID
    public let finalizationStatus: String
    public let documentHash: String
    public let signatureStatus: String
    public let provenanceRefs: [UUID]
    public let retentionClass: String
    public let appSafeSummary: String

    public init(
        finalDocumentId: UUID,
        sourceDraftId: UUID,
        gateRequestId: UUID,
        gateResolutionId: UUID,
        finalizationStatus: String,
        documentHash: String,
        signatureStatus: String,
        provenanceRefs: [UUID] = [],
        retentionClass: String,
        appSafeSummary: String
    ) {
        self.finalDocumentId = finalDocumentId
        self.sourceDraftId = sourceDraftId
        self.gateRequestId = gateRequestId
        self.gateResolutionId = gateResolutionId
        self.finalizationStatus = finalizationStatus
        self.documentHash = documentHash
        self.signatureStatus = signatureStatus
        self.provenanceRefs = provenanceRefs
        self.retentionClass = retentionClass
        self.appSafeSummary = appSafeSummary
    }
}

public struct ScribeAppRuntimeState: Codable, Sendable {
    public let workspaceContext: ProfessionalWorkspaceContext
    public let sessionState: ScribeProfessionalSessionState
    public let capture: ScribeCaptureTranscriptionSurface?
    public let retrieval: ScribeRetrievalContextSurface?
    public let drafts: [ScribeDraftReviewSurface]
    public let gate: ScribeGateReviewContract?
    public let finalDocument: ScribeFinalDocumentSurface?
    public let gosRuntimeSummary: String?
    public let providerRuntimeSummary: String?
    public let issues: [ScribeBoundaryIssue]
    public let allowedNextActions: [ScribeWorkspaceOperation]

    public init(
        workspaceContext: ProfessionalWorkspaceContext,
        sessionState: ScribeProfessionalSessionState,
        capture: ScribeCaptureTranscriptionSurface? = nil,
        retrieval: ScribeRetrievalContextSurface? = nil,
        drafts: [ScribeDraftReviewSurface] = [],
        gate: ScribeGateReviewContract? = nil,
        finalDocument: ScribeFinalDocumentSurface? = nil,
        gosRuntimeSummary: String? = nil,
        providerRuntimeSummary: String? = nil,
        issues: [ScribeBoundaryIssue] = [],
        allowedNextActions: [ScribeWorkspaceOperation] = []
    ) {
        self.workspaceContext = workspaceContext
        self.sessionState = sessionState
        self.capture = capture
        self.retrieval = retrieval
        self.drafts = drafts
        self.gate = gate
        self.finalDocument = finalDocument
        self.gosRuntimeSummary = gosRuntimeSummary
        self.providerRuntimeSummary = providerRuntimeSummary
        self.issues = issues
        self.allowedNextActions = allowedNextActions
    }
}

public enum ScribeBoundaryValidationError: Error, Equatable {
    case boundaryIssue(ScribeBoundaryIssue)
}

public enum ScribeBoundaryValidator {
    public static func validateWorkspaceContext(_ context: ProfessionalWorkspaceContext) throws {
        guard context.habilitationId != nil else {
            throw ScribeBoundaryValidationError.boundaryIssue(.missingHabilitation)
        }

        if context.allowedOperations.contains(.retrieveContext) || context.allowedOperations.contains(.composeDraft) {
            guard context.finalidade?.isEmpty == false else {
                throw ScribeBoundaryValidationError.boundaryIssue(.missingFinalidade)
            }
        }

        let patientScopedOps: Set<ScribeWorkspaceOperation> = [.submitCapture, .retrieveContext, .composeDraft, .openGate]
        if !patientScopedOps.isDisjoint(with: Set(context.allowedOperations)), context.selectedPatientRef == nil {
            throw ScribeBoundaryValidationError.boundaryIssue(.patientNotSelected)
        }
    }

    public static func validateTransition(
        from: ScribeProfessionalSessionState,
        to: ScribeProfessionalSessionState,
        hasDraft: Bool,
        gateApproved: Bool,
        degraded: Bool
    ) throws {
        let allowed = allowedTransitions(from: from, hasDraft: hasDraft, gateApproved: gateApproved, degraded: degraded)
        guard allowed.contains(to) else {
            if to == .awaitingGate && !hasDraft {
                throw ScribeBoundaryValidationError.boundaryIssue(.gateRequiresDraft)
            }
            if to == .finalized && !gateApproved {
                throw ScribeBoundaryValidationError.boundaryIssue(.finalizationRequiresApprovedGate)
            }
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
    }

    public static func allowedTransitions(
        from: ScribeProfessionalSessionState,
        hasDraft: Bool,
        gateApproved: Bool,
        degraded: Bool
    ) -> Set<ScribeProfessionalSessionState> {
        switch from {
        case .idle: return [.serviceSelected, .failed]
        case .serviceSelected: return [.professionalValidated, .failed]
        case .professionalValidated: return [.patientSelected, .failed]
        case .patientSelected: return [.captureReady, .failed]
        case .captureReady: return [.capturing, .failed]
        case .capturing: return [.transcriptionPending, .failed]
        case .transcriptionPending:
            var states: Set<ScribeProfessionalSessionState> = [.transcriptionReady, .failed]
            if degraded { states.insert(.transcriptionDegraded) }
            return states
        case .transcriptionReady, .transcriptionDegraded:
            return [.contextRetrievalPending, .failed]
        case .contextRetrievalPending:
            return degraded ? [.contextReady, .contextDegraded, .failed] : [.contextReady, .failed]
        case .contextReady, .contextDegraded:
            return [.draftPending, .failed]
        case .draftPending:
            return hasDraft ? [.draftReady, .failed] : [.failed]
        case .draftReady:
            return hasDraft ? [.awaitingGate, .failed] : [.failed]
        case .awaitingGate:
            return [.gateApproved, .gateRejected, .failed]
        case .gateApproved:
            return gateApproved ? [.finalizationPending, .failed] : [.failed]
        case .gateRejected:
            return [.failed]
        case .finalizationPending:
            return gateApproved ? [.finalized, .failed] : [.failed]
        case .finalized, .failed:
            return []
        }
    }

    public static func validateCaptureSurface(_ surface: ScribeCaptureTranscriptionSurface) throws {
        if surface.captureKind == .seededText, surface.transcriptionStatus == .providerBacked {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
        if surface.captureKind == .audioFile,
           surface.transcriptionStatus == .ready,
           surface.transcriptObjectRef == nil {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
        if surface.transcriptionStatus == .stub,
           (surface.providerExecutionRef?.contains("provider") ?? false) {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
    }

    public static func validateRetrievalSurface(_ surface: ScribeRetrievalContextSurface, lawfulContext: [String: String]) throws {
        guard lawfulContext["finalidade"]?.isEmpty == false else {
            throw ScribeBoundaryValidationError.boundaryIssue(.missingFinalidade)
        }
        if surface.retrievalMode == .lexical,
           !(surface.scoreKind == .deterministic || surface.scoreKind == .lexical) {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
        if surface.retrievalMode == .semantic,
           surface.contextStatus == .ready,
           surface.scoreKind == .stub {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
        let forbidden = ["raw-index", "reidentification", "cpf"]
        if surface.sourceLayerSummaries.contains(where: { item in forbidden.contains { item.localizedCaseInsensitiveContains($0) } }) {
            throw ScribeBoundaryValidationError.boundaryIssue(.sensitiveBoundaryLeak)
        }
    }

    public static func validateDraftSurface(_ surface: ScribeDraftReviewSurface) throws {
        guard surface.draftOnly, surface.gateStillRequired else {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
    }

    public static func validateGateReview(_ gate: ScribeGateReviewContract) throws {
        if gate.requiredReviewerRole == "professional", gate.reviewerProfessionalId == nil {
            throw ScribeBoundaryValidationError.boundaryIssue(.clinicalGateRequiresProfessional)
        }
        if gate.reviewAction == .reject || gate.reviewAction == .requestChanges,
           gate.rationale?.isEmpty != false {
            throw ScribeBoundaryValidationError.boundaryIssue(.rationaleRequired)
        }
        if gate.requiredReviewerRole == "admin", gate.reviewAction == .approve, gate.targetKind != .administrative {
            throw ScribeBoundaryValidationError.boundaryIssue(.clinicalGateRequiresProfessional)
        }
    }

    public static func validateFinalDocument(
        gate: ScribeGateReviewContract?,
        finalDocument: ScribeFinalDocumentSurface?
    ) throws {
        guard let finalDocument else { return }
        guard let gate, gate.reviewAction == .approve else {
            throw ScribeBoundaryValidationError.boundaryIssue(.finalizationRequiresApprovedGate)
        }
        guard finalDocument.sourceDraftId == gate.targetDraftId,
              finalDocument.gateRequestId == gate.gateRequestId,
              finalDocument.gateResolutionId == gate.gateResolutionId else {
            throw ScribeBoundaryValidationError.boundaryIssue(.invalidTransition)
        }
    }

    public static func validateAppBoundary(state: ScribeAppRuntimeState) throws {
        let forbiddenTokens = ["cpf", "identidades_civis", "reidentification", "storage://", "gos_compiled", "provider_secret"]
        let payload = [
            state.workspaceContext.lawfulContext.description,
            state.gosRuntimeSummary ?? "",
            state.providerRuntimeSummary ?? "",
            state.capture?.inputObjectRef ?? "",
            state.capture?.transcriptObjectRef ?? "",
            state.retrieval?.sourceLayerSummaries.joined(separator: " ") ?? ""
        ]
        let combined = payload.joined(separator: " ").lowercased()
        if forbiddenTokens.contains(where: { combined.contains($0) }) {
            throw ScribeBoundaryValidationError.boundaryIssue(.sensitiveBoundaryLeak)
        }
    }
}

