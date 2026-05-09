import Foundation

public enum RuntimeKind: String, Codable, Sendable {
    case aaci
    case async
    case userAgent = "user-agent"
}

public enum SessionKind: String, Codable, Sendable {
    case encounter
    case chartReview = "chart_review"
    case documentClose = "document_close"
    case postVisit = "post_visit"
    case preBriefing = "pre_briefing"
    case adminBlock = "admin_block"
    case handoff
}

public enum DraftKind: String, Codable, Sendable {
    case soap
    case prescription
    case referral
    case note
    case retrievalSummary = "retrieval_summary"
    case adminTaskList = "admin_task_list"
}

public enum DraftStatus: String, Codable, Sendable {
    case draft
    case awaitingGate = "awaiting_gate"
    case approved
    case rejected
    case superseded
}

public enum GateRequestStatus: String, Codable, Sendable {
    case pending
    case approved
    case rejected
    case cancelled
}

public enum GateReviewType: String, Codable, Sendable {
    case professionalDocumentReview = "professional_document_review"
}

public enum FinalDocumentKind: String, Codable, Sendable {
    case soapNote = "soap_note"
}

public enum FinalDocumentStatus: String, Codable, Sendable {
    case finalized
}

public enum GateResolutionKind: String, Codable, Sendable {
    case approved
    case rejected
    case cancelled
}
