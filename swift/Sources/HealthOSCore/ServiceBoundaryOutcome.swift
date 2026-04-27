import Foundation

public enum ServiceOutcome: String, Codable, Sendable {
    case success
    case deny
    case failure
}

public struct ServiceBoundaryOutcome<T: Codable & Sendable>: Codable, Sendable {
    public let outcome: ServiceOutcome
    public let payload: T?
    public let denyReason: String?
    public let errorKind: String?
    public let errorMessage: String?

    public static func success(_ payload: T) -> Self {
        .init(outcome: .success, payload: payload, denyReason: nil, errorKind: nil, errorMessage: nil)
    }

    public static func deny(reason: String) -> Self {
        .init(outcome: .deny, payload: nil, denyReason: reason, errorKind: nil, errorMessage: nil)
    }

    public static func failure(kind: String, message: String) -> Self {
        .init(outcome: .failure, payload: nil, denyReason: nil, errorKind: kind, errorMessage: message)
    }
}
