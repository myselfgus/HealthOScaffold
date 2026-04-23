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

public enum DraftStatus: String, Codable, Sendable {
    case draft
    case awaitingGate = "awaiting_gate"
    case approved
    case rejected
    case superseded
}

public enum GateResolutionKind: String, Codable, Sendable {
    case approved
    case rejected
    case cancelled
}
