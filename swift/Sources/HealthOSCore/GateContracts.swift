import Foundation

public struct GateRequest: Codable, Sendable, Identifiable {
    public let id: UUID
    public let draftId: UUID
    public let requestedAction: String
    public let requiredRole: String
    public let requiredReviewType: GateReviewType
    public let finalizationTarget: FinalDocumentKind
    public let requiresSignature: Bool
    public let rationaleNote: String?
    public let status: GateRequestStatus
    public let requestedAt: Date

    public init(
        id: UUID = UUID(),
        draftId: UUID,
        requestedAction: String,
        requiredRole: String,
        requiredReviewType: GateReviewType,
        finalizationTarget: FinalDocumentKind,
        requiresSignature: Bool,
        rationaleNote: String? = nil,
        status: GateRequestStatus = .pending,
        requestedAt: Date = .now
    ) {
        self.id = id
        self.draftId = draftId
        self.requestedAction = requestedAction
        self.requiredRole = requiredRole
        self.requiredReviewType = requiredReviewType
        self.finalizationTarget = finalizationTarget
        self.requiresSignature = requiresSignature
        self.rationaleNote = rationaleNote
        self.status = status
        self.requestedAt = requestedAt
    }
}

public struct GateResolution: Codable, Sendable, Identifiable {
    public let id: UUID
    public let gateRequestId: UUID
    public let resolverUserId: UUID
    public let resolverRole: String
    public let resolution: GateResolutionKind
    public let rationaleNote: String?
    public let reviewedAt: Date

    public init(
        id: UUID = UUID(),
        gateRequestId: UUID,
        resolverUserId: UUID,
        resolverRole: String,
        resolution: GateResolutionKind,
        rationaleNote: String? = nil,
        reviewedAt: Date = .now
    ) {
        self.id = id
        self.gateRequestId = gateRequestId
        self.resolverUserId = resolverUserId
        self.resolverRole = resolverRole
        self.resolution = resolution
        self.rationaleNote = rationaleNote
        self.reviewedAt = reviewedAt
    }
}
