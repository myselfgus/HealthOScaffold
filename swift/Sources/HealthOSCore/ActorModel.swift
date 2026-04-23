import Foundation

public enum RuntimeLifecycleState: String, Codable, Sendable {
    case booting
    case ready
    case active
    case paused
    case terminating
    case terminated
    case failed
}

public enum RuntimeFailureKind: String, Codable, Sendable {
    case configurationFailure = "configuration_failure"
    case dependencyFailure = "dependency_failure"
    case authorizationFailure = "authorization_failure"
    case integrityFailure = "integrity_failure"
    case transportFailure = "transport_failure"
    case timeoutFailure = "timeout_failure"
    case internalFailure = "internal_failure"
}

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

public struct AgentBoundary: Codable, Sendable {
    public let reads: [String]
    public let writes: [String]
    public let invokes: [String]
    public let governanceChecks: [String]
    public let forbiddenFinalizations: [String]

    public init(
        reads: [String] = [],
        writes: [String] = [],
        invokes: [String] = [],
        governanceChecks: [String] = [],
        forbiddenFinalizations: [String] = []
    ) {
        self.reads = reads
        self.writes = writes
        self.invokes = invokes
        self.governanceChecks = governanceChecks
        self.forbiddenFinalizations = forbiddenFinalizations
    }
}

public protocol RuntimeManaged: Sendable {
    var runtimeKind: RuntimeKind { get }
    var lifecycleState: RuntimeLifecycleState { get }
}

public protocol HealthActor: Sendable {
    var actorId: String { get }
    var runtimeKind: RuntimeKind { get }
    func receive(_ message: AgentMessage) async throws
}

public protocol HealthAgent: HealthActor {
    var semanticRole: String { get }
    var permissions: [String] { get }
    var boundaryDescription: String { get }
    var boundary: AgentBoundary { get }
    var allowedInputKinds: [String] { get }
    var emittedOutputKinds: [String] { get }
}
