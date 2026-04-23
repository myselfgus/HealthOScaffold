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
}

public enum ScribeRetrievalStatus: String, Codable, Sendable {
    case ready
    case empty
    case degraded
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
    public let previewItems: [String]

    public init(status: ScribeRetrievalStatus, source: String, matchCount: Int, previewItems: [String]) {
        self.status = status
        self.source = source
        self.matchCount = matchCount
        self.previewItems = previewItems
    }
}

public struct ScribeSessionBridgeState: Codable, Sendable {
    public let sessionId: UUID
    public let draftState: ScribeDraftState
    public let gateState: ScribeGateState
    public let transcriptPreview: String
    public let draftPreview: String
    public let retrieval: ScribeRetrievalBridgeState
    public let runSummary: SliceRunSummary?

    public init(
        sessionId: UUID,
        draftState: ScribeDraftState,
        gateState: ScribeGateState,
        transcriptPreview: String,
        draftPreview: String,
        retrieval: ScribeRetrievalBridgeState,
        runSummary: SliceRunSummary?
    ) {
        self.sessionId = sessionId
        self.draftState = draftState
        self.gateState = gateState
        self.transcriptPreview = transcriptPreview
        self.draftPreview = draftPreview
        self.retrieval = retrieval
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
