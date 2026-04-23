import Foundation

public struct AgentMessage: Codable, Sendable {
    public let from: String
    public let to: String
    public let kind: String
    public let payload: [String: String]
    public let correlationId: String?

    public init(from: String, to: String, kind: String, payload: [String: String], correlationId: String? = nil) {
        self.from = from
        self.to = to
        self.kind = kind
        self.payload = payload
        self.correlationId = correlationId
    }
}

public protocol HealthActor: Sendable {
    var actorId: String { get }
    var runtimeKind: RuntimeKind { get }
    func receive(_ message: AgentMessage) async throws
}

public protocol HealthAgent: HealthActor {
    var permissions: [String] { get }
    var boundaryDescription: String { get }
}
