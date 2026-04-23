import Foundation

public enum HealthOSCommandDisposition: String, Codable, Sendable {
    case completeSuccess = "complete_success"
    case partialSuccess = "partial_success"
    case degraded = "degraded"
    case governedDeny = "governed_deny"
    case operationalFailure = "operational_failure"
}

public enum HealthOSFailureKind: String, Codable, Sendable {
    case authorization = "authorization"
    case dependency = "dependency"
    case integrity = "integrity"
    case timeout = "timeout"
    case validation = "validation"
    case state = "state"
    case internalFailure = "internal_failure"
}

public enum HealthOSIssueCode: String, Codable, Sendable {
    case sessionNotFound = "session.not_found"
    case patientMissing = "patient.missing"
    case captureMissing = "capture.missing"
    case captureIncomplete = "capture.incomplete"
    case captureAudioFileMissing = "capture.audio_file_missing"
    case captureAudioFileUnreadable = "capture.audio_file_unreadable"

    case professionalInactive = "habilitation.inactive_professional"
    case patientInactive = "consent.inactive_patient"

    case serviceInvalid = "service.invalid"
    case transcriptionDegraded = "transcription.degraded"
    case transcriptionUnavailable = "transcription.unavailable"
    case retrievalDegraded = "retrieval.degraded"
    case retrievalPartial = "retrieval.partial_context"
    case retrievalEmpty = "retrieval.empty_context"
    case draftRefreshDegraded = "draft.refresh.degraded"
    case gateRejected = "gate.rejected"
    case spineExecutionFailed = "spine.execution_failed"
}

public struct HealthOSIssue: Codable, Sendable {
    public let code: HealthOSIssueCode
    public let message: String
    public let failureKind: HealthOSFailureKind?

    public init(code: HealthOSIssueCode, message: String, failureKind: HealthOSFailureKind? = nil) {
        self.code = code
        self.message = message
        self.failureKind = failureKind
    }
}
