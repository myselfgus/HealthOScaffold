import Foundation

public struct GateRequest: Codable, Sendable, Identifiable {
    public let id: UUID
    public let draftId: UUID
    public let requestedAction: String
    public let requiredRole: String
    public let requiresSignature: Bool

    public init(
        id: UUID = UUID(),
        draftId: UUID,
        requestedAction: String,
        requiredRole: String,
        requiresSignature: Bool
    ) {
        self.id = id
        self.draftId = draftId
        self.requestedAction = requestedAction
        self.requiredRole = requiredRole
        self.requiresSignature = requiresSignature
    }
}

public struct GateResolution: Codable, Sendable, Identifiable {
    public let id: UUID
    public let gateRequestId: UUID
    public let resolverUserId: UUID
    public let resolution: GateResolutionKind
    public let note: String?

    public init(
        id: UUID = UUID(),
        gateRequestId: UUID,
        resolverUserId: UUID,
        resolution: GateResolutionKind,
        note: String? = nil
    ) {
        self.id = id
        self.gateRequestId = gateRequestId
        self.resolverUserId = resolverUserId
        self.resolution = resolution
        self.note = note
    }
}
