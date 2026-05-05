import Foundation

// Veridia session boundary protocol and types.
// Equivalent to ScribeFirstSliceFacade for the patient identity/governance domain.
// Implementations wire UserSovereigntyContracts.swift validators; they do not own Core law.

public struct VeridiaSessionStartRequest: Codable, Sendable {
    public let requestId: UUID
    public let userId: UUID
    public let finalidade: String
    public let lawfulContext: [String: String]
    public let cpfHashRef: String
    public let actorId: String
    public let runtimeId: String

    public init(
        requestId: UUID = UUID(),
        userId: UUID,
        finalidade: String,
        lawfulContext: [String: String],
        cpfHashRef: String,
        actorId: String,
        runtimeId: String
    ) {
        self.requestId = requestId
        self.userId = userId
        self.finalidade = finalidade
        self.lawfulContext = lawfulContext
        self.cpfHashRef = cpfHashRef
        self.actorId = actorId
        self.runtimeId = runtimeId
    }
}

public enum VeridiaSessionDisposition: String, Codable, Sendable, Equatable {
    case sessionStarted = "session-started"
    case sessionEnded = "session-ended"
    case governedDeny = "governed-deny"
    case validationFailure = "validation-failure"
}

public struct VeridiaSessionResult: Codable, Sendable {
    public let sessionId: UUID
    public let disposition: VeridiaSessionDisposition
    public let provenanceRef: UUID
    public let auditRef: UUID
    public let issueMessage: String?

    public init(
        sessionId: UUID,
        disposition: VeridiaSessionDisposition,
        provenanceRef: UUID = UUID(),
        auditRef: UUID = UUID(),
        issueMessage: String? = nil
    ) {
        self.sessionId = sessionId
        self.disposition = disposition
        self.provenanceRef = provenanceRef
        self.auditRef = auditRef
        self.issueMessage = issueMessage
    }
}

public protocol VeridiaSessionFacade {
    func startSession(_ request: VeridiaSessionStartRequest) async -> VeridiaSessionResult
    func endSession(sessionId: UUID, lawfulContext: [String: String]) async -> VeridiaSessionResult
}
