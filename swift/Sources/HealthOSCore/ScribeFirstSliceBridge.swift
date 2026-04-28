import Foundation

public enum ScribeDraftState: String, Codable, Sendable {
    case empty
    case ready
    case awaitingGate = "awaiting_gate"
    case approved
    case rejected
}

public enum ScribeGateState: String, Codable, Sendable {
    case none
    case pending
    case approved
    case rejected
    case cancelled
}

public enum ScribeRetrievalStatus: String, Codable, Sendable {
    case ready
    case partial
    case empty
    case degraded
}

public enum ScribeFinalDocumentState: String, Codable, Sendable {
    case none
    case awaitingGate = "awaiting_gate"
    case finalized
    case withheld
}

public enum ScribeDerivedDraftState: String, Codable, Sendable {
    case none
    case preview
    case draftOnly = "draft_only"
}

public enum GOSRuntimeLifecycleView: String, Codable, Sendable {
    case active
    case inactive
}

public enum GOSBindingPlanSourceView: String, Codable, Sendable {
    case bundleProvided = "bundle_provided"
    case runtimeDefault = "runtime_default"
}

public struct GOSBoundActorRuntimeView: Codable, Sendable {
    public let actorId: String
    public let semanticRole: String
    public let primitiveFamilies: [String]

    public init(
        actorId: String,
        semanticRole: String,
        primitiveFamilies: [String]
    ) {
        self.actorId = actorId
        self.semanticRole = semanticRole
        self.primitiveFamilies = primitiveFamilies
    }
}

public struct GOSDraftMediationRuntimeView: Codable, Sendable {
    public let draftKind: DraftKind
    public let runtimePath: String
    public let runtimeActorId: String
    public let primitiveFamilies: [String]
    public let reasoningBoundary: String
    public let provenanceOperation: String?
    public let mediated: Bool
    public let gateStillRequired: Bool
    public let draftOnly: Bool

    public init(
        draftKind: DraftKind,
        runtimePath: String,
        runtimeActorId: String,
        primitiveFamilies: [String],
        reasoningBoundary: String,
        provenanceOperation: String? = nil,
        mediated: Bool,
        gateStillRequired: Bool,
        draftOnly: Bool
    ) {
        self.draftKind = draftKind
        self.runtimePath = runtimePath
        self.runtimeActorId = runtimeActorId
        self.primitiveFamilies = primitiveFamilies
        self.reasoningBoundary = reasoningBoundary
        self.provenanceOperation = provenanceOperation
        self.mediated = mediated
        self.gateStillRequired = gateStillRequired
        self.draftOnly = draftOnly
    }
}

public struct GOSMediationSummaryView: Codable, Sendable {
    public let mediatedActorIds: [String]
    public let mediatedPrimitiveFamilyCount: Int
    public let provenanceOperations: [String]
    public let boundActors: [GOSBoundActorRuntimeView]
    public let reasoningBoundaries: [String]
    public let draftMediations: [GOSDraftMediationRuntimeView]

    public init(
        mediatedActorIds: [String],
        mediatedPrimitiveFamilyCount: Int,
        provenanceOperations: [String],
        boundActors: [GOSBoundActorRuntimeView] = [],
        reasoningBoundaries: [String] = [],
        draftMediations: [GOSDraftMediationRuntimeView] = []
    ) {
        self.mediatedActorIds = mediatedActorIds
        self.mediatedPrimitiveFamilyCount = mediatedPrimitiveFamilyCount
        self.provenanceOperations = provenanceOperations
        self.boundActors = boundActors
        self.reasoningBoundaries = reasoningBoundaries
        self.draftMediations = draftMediations
    }
}

public struct GOSRuntimeStateView: Codable, Sendable {
    public let lifecycle: GOSRuntimeLifecycleView
    public let specId: String?
    public let bundleId: String?
    public let workflowTitle: String?
    public let bindingPlanSource: GOSBindingPlanSourceView?
    public let mediationSummary: GOSMediationSummaryView?
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool
    public let draftOnly: Bool
    public let provenanceFacingOnly: Bool
    public let informationalOnly: Bool

    public init(
        lifecycle: GOSRuntimeLifecycleView,
        specId: String? = nil,
        bundleId: String? = nil,
        workflowTitle: String? = nil,
        bindingPlanSource: GOSBindingPlanSourceView? = nil,
        mediationSummary: GOSMediationSummaryView? = nil,
        legalAuthorizing: Bool = false,
        gateStillRequired: Bool,
        draftOnly: Bool,
        provenanceFacingOnly: Bool,
        informationalOnly: Bool
    ) {
        self.lifecycle = lifecycle
        self.specId = specId
        self.bundleId = bundleId
        self.workflowTitle = workflowTitle
        self.bindingPlanSource = bindingPlanSource
        self.mediationSummary = mediationSummary
        self.legalAuthorizing = legalAuthorizing
        self.gateStillRequired = gateStillRequired
        self.draftOnly = draftOnly
        self.provenanceFacingOnly = provenanceFacingOnly
        self.informationalOnly = informationalOnly
    }
}

public struct StartProfessionalSessionCommand: Codable, Sendable {
    public let professional: Usuario
    public let service: Servico

    public init(professional: Usuario, service: Servico) {
        self.professional = professional
        self.service = service
    }
}

public struct SelectPatientCommand: Codable, Sendable {
    public let sessionId: UUID
    public let patient: Usuario

    public init(sessionId: UUID, patient: Usuario) {
        self.sessionId = sessionId
        self.patient = patient
    }
}

public struct SubmitSessionCaptureCommand: Codable, Sendable {
    public let sessionId: UUID
    public let capture: SessionCaptureInput

    public init(sessionId: UUID, capture: SessionCaptureInput) {
        self.sessionId = sessionId
        self.capture = capture
    }
}

public struct RequestDraftRefreshCommand: Codable, Sendable {
    public let sessionId: UUID

    public init(sessionId: UUID) {
        self.sessionId = sessionId
    }
}

public struct ResolveGateCommand: Codable, Sendable {
    public let sessionId: UUID
    public let approve: Bool

    public init(sessionId: UUID, approve: Bool) {
        self.sessionId = sessionId
        self.approve = approve
    }
}

public struct ScribeRetrievalBridgeState: Codable, Sendable {
    public let status: ScribeRetrievalStatus
    public let source: String
    public let matchCount: Int
    public let summary: String
    public let highlights: [String]
    public let sourceItems: [String]
    public let notice: String?

    public init(
        status: ScribeRetrievalStatus,
        source: String,
        matchCount: Int,
        summary: String,
        highlights: [String],
        sourceItems: [String],
        notice: String? = nil
    ) {
        self.status = status
        self.source = source
        self.matchCount = matchCount
        self.summary = summary
        self.highlights = highlights
        self.sourceItems = sourceItems
        self.notice = notice
    }
}

public struct ScribeTranscriptionBridgeState: Codable, Sendable {
    public let status: TranscriptionStatus
    public let source: String
    public let audioDisplayName: String?
    public let issueMessage: String?

    public init(
        status: TranscriptionStatus,
        source: String,
        audioDisplayName: String? = nil,
        issueMessage: String? = nil
    ) {
        self.status = status
        self.source = source
        self.audioDisplayName = audioDisplayName
        self.issueMessage = issueMessage
    }
}

public struct ScribeGateReviewBridgeState: Codable, Sendable {
    public let state: ScribeGateState
    public let requiredReviewType: GateReviewType?
    public let finalizationTarget: FinalDocumentKind?
    public let requestedAction: String?
    public let rationaleNote: String?
    public let reviewedAt: Date?
    public let resolverRole: String?

    public init(
        state: ScribeGateState,
        requiredReviewType: GateReviewType? = nil,
        finalizationTarget: FinalDocumentKind? = nil,
        requestedAction: String? = nil,
        rationaleNote: String? = nil,
        reviewedAt: Date? = nil,
        resolverRole: String? = nil
    ) {
        self.state = state
        self.requiredReviewType = requiredReviewType
        self.finalizationTarget = finalizationTarget
        self.requestedAction = requestedAction
        self.rationaleNote = rationaleNote
        self.reviewedAt = reviewedAt
        self.resolverRole = resolverRole
    }
}

public struct ScribeFinalDocumentBridgeState: Codable, Sendable {
    public let state: ScribeFinalDocumentState
    public let status: FinalDocumentStatus?
    public let summary: String
    public let objectPath: String?
    public let finalizedAt: Date?
    public let sourceDraftId: UUID?
    public let gateResolutionId: UUID?

    public init(
        state: ScribeFinalDocumentState,
        status: FinalDocumentStatus? = nil,
        summary: String,
        objectPath: String? = nil,
        finalizedAt: Date? = nil,
        sourceDraftId: UUID? = nil,
        gateResolutionId: UUID? = nil
    ) {
        self.state = state
        self.status = status
        self.summary = summary
        self.objectPath = objectPath
        self.finalizedAt = finalizedAt
        self.sourceDraftId = sourceDraftId
        self.gateResolutionId = gateResolutionId
    }
}

public struct ScribeDerivedDraftBridgeState: Codable, Sendable {
    public let kind: DraftKind
    public let state: ScribeDerivedDraftState
    public let draftStatus: DraftStatus?
    public let summary: String
    public let preview: String
    public let objectPath: String?
    public let readyForFutureGate: Bool
    public let draftOnlyNote: String?

    public init(
        kind: DraftKind,
        state: ScribeDerivedDraftState,
        draftStatus: DraftStatus? = nil,
        summary: String,
        preview: String,
        objectPath: String? = nil,
        readyForFutureGate: Bool = false,
        draftOnlyNote: String? = nil
    ) {
        self.kind = kind
        self.state = state
        self.draftStatus = draftStatus
        self.summary = summary
        self.preview = preview
        self.objectPath = objectPath
        self.readyForFutureGate = readyForFutureGate
        self.draftOnlyNote = draftOnlyNote
    }
}

public struct ScribeSessionBridgeState: Codable, Sendable {
    public let sessionId: UUID
    public let sessionState: ScribeProfessionalSessionState
    public let workspaceContext: ProfessionalWorkspaceContext?
    public let allowedNextActions: [ScribeWorkspaceOperation]
    public let captureMode: CaptureMode?
    public let draftState: ScribeDraftState
    public let gateState: ScribeGateState
    public let transcriptPreview: String
    public let draftPreview: String
    public let transcription: ScribeTranscriptionBridgeState
    public let retrieval: ScribeRetrievalBridgeState
    public let gateReview: ScribeGateReviewBridgeState
    public let referralDraft: ScribeDerivedDraftBridgeState
    public let prescriptionDraft: ScribeDerivedDraftBridgeState
    public let finalDocument: ScribeFinalDocumentBridgeState
    public let gosRuntimeState: GOSRuntimeStateView
    public let runSummary: SliceRunSummary?

    public init(
        sessionId: UUID,
        sessionState: ScribeProfessionalSessionState,
        workspaceContext: ProfessionalWorkspaceContext?,
        allowedNextActions: [ScribeWorkspaceOperation],
        captureMode: CaptureMode?,
        draftState: ScribeDraftState,
        gateState: ScribeGateState,
        transcriptPreview: String,
        draftPreview: String,
        transcription: ScribeTranscriptionBridgeState,
        retrieval: ScribeRetrievalBridgeState,
        gateReview: ScribeGateReviewBridgeState,
        referralDraft: ScribeDerivedDraftBridgeState,
        prescriptionDraft: ScribeDerivedDraftBridgeState,
        finalDocument: ScribeFinalDocumentBridgeState,
        gosRuntimeState: GOSRuntimeStateView,
        runSummary: SliceRunSummary?
    ) {
        self.sessionId = sessionId
        self.sessionState = sessionState
        self.workspaceContext = workspaceContext
        self.allowedNextActions = allowedNextActions
        self.captureMode = captureMode
        self.draftState = draftState
        self.gateState = gateState
        self.transcriptPreview = transcriptPreview
        self.draftPreview = draftPreview
        self.transcription = transcription
        self.retrieval = retrieval
        self.gateReview = gateReview
        self.referralDraft = referralDraft
        self.prescriptionDraft = prescriptionDraft
        self.finalDocument = finalDocument
        self.gosRuntimeState = gosRuntimeState
        self.runSummary = runSummary
    }
}

public struct SessionStartResult: Codable, Sendable {
    public let disposition: HealthOSCommandDisposition
    public let state: ScribeSessionBridgeState?
    public let issues: [HealthOSIssue]

    public init(disposition: HealthOSCommandDisposition, state: ScribeSessionBridgeState?, issues: [HealthOSIssue] = []) {
        self.disposition = disposition
        self.state = state
        self.issues = issues
    }
}

public struct PatientSelectionResult: Codable, Sendable {
    public let disposition: HealthOSCommandDisposition
    public let state: ScribeSessionBridgeState?
    public let issues: [HealthOSIssue]

    public init(disposition: HealthOSCommandDisposition, state: ScribeSessionBridgeState?, issues: [HealthOSIssue] = []) {
        self.disposition = disposition
        self.state = state
        self.issues = issues
    }
}

public struct CaptureSubmissionResult: Codable, Sendable {
    public let disposition: HealthOSCommandDisposition
    public let state: ScribeSessionBridgeState?
    public let issues: [HealthOSIssue]

    public init(disposition: HealthOSCommandDisposition, state: ScribeSessionBridgeState?, issues: [HealthOSIssue] = []) {
        self.disposition = disposition
        self.state = state
        self.issues = issues
    }
}

public struct DraftStateResult: Codable, Sendable {
    public let disposition: HealthOSCommandDisposition
    public let state: ScribeSessionBridgeState?
    public let issues: [HealthOSIssue]

    public init(disposition: HealthOSCommandDisposition, state: ScribeSessionBridgeState?, issues: [HealthOSIssue] = []) {
        self.disposition = disposition
        self.state = state
        self.issues = issues
    }
}

public struct GateResolutionResult: Codable, Sendable {
    public let disposition: HealthOSCommandDisposition
    public let state: ScribeSessionBridgeState?
    public let issues: [HealthOSIssue]

    public init(disposition: HealthOSCommandDisposition, state: ScribeSessionBridgeState?, issues: [HealthOSIssue] = []) {
        self.disposition = disposition
        self.state = state
        self.issues = issues
    }
}

public protocol ScribeFirstSliceFacade: Sendable {
    func startProfessionalSession(_ command: StartProfessionalSessionCommand) async -> SessionStartResult
    func selectPatient(_ command: SelectPatientCommand) async -> PatientSelectionResult
    func submitSessionCapture(_ command: SubmitSessionCaptureCommand) async -> CaptureSubmissionResult
    func requestDraftRefresh(_ command: RequestDraftRefreshCommand) async -> DraftStateResult
    func resolveGate(_ command: ResolveGateCommand) async -> GateResolutionResult
}
