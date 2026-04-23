import Foundation
import HealthOSCore

public struct ProviderRouteDecision: Codable, Sendable {
    public let providerName: String
    public let reason: String
}

public protocol LanguageModelProvider: Sendable {
    var providerName: String { get }
    func generate(prompt: String, context: [String: String]) async throws -> String
}

public protocol SpeechToTextProvider: Sendable {
    var providerName: String { get }
    func transcribe(audioURL: URL) async throws -> String
}

public protocol EmbeddingProvider: Sendable {
    var providerName: String { get }
    func embed(text: String) async throws -> [Double]
}

public protocol RetrievalProvider: Sendable {
    var providerName: String { get }
    func search(query: String, scope: [String: String]) async throws -> [String]
}

public protocol FineTuningProvider: Sendable {
    var providerName: String { get }
    func enqueue(jobName: String, datasetRef: String, baseModel: String) async throws -> String
}

public actor ProviderRouter {
    private var languageProviders: [String: any LanguageModelProvider] = [:]

    public init() {}

    public func register(_ provider: any LanguageModelProvider) {
        languageProviders[provider.providerName] = provider
    }

    public func route(taskKind: String) -> ProviderRouteDecision {
        if let first = languageProviders.keys.sorted().first {
            return ProviderRouteDecision(providerName: first, reason: "default route for \(taskKind)")
        }
        return ProviderRouteDecision(providerName: "none", reason: "no language provider registered")
    }
}
