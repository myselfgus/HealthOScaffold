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

public struct SpeechTranscriptionResult: Sendable {
    public let status: TranscriptionStatus
    public let transcriptText: String?
    public let message: String?

    public init(
        status: TranscriptionStatus,
        transcriptText: String? = nil,
        message: String? = nil
    ) {
        self.status = status
        self.transcriptText = transcriptText
        self.message = message
    }
}

public protocol SpeechToTextProvider: Sendable {
    var providerName: String { get }
    func transcribe(audioURL: URL) async throws -> SpeechTranscriptionResult
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
    private var speechProviders: [String: any SpeechToTextProvider] = [:]

    public init() {}

    public func register(_ provider: any LanguageModelProvider) {
        languageProviders[provider.providerName] = provider
    }

    public func register(_ provider: any SpeechToTextProvider) {
        speechProviders[provider.providerName] = provider
    }

    public func route(taskKind: String) -> ProviderRouteDecision {
        if let first = languageProviders.keys.sorted().first {
            return ProviderRouteDecision(providerName: first, reason: "default route for \(taskKind)")
        }
        return ProviderRouteDecision(providerName: "none", reason: "no language provider registered")
    }

    public func speechProvider(taskKind: String) -> (any SpeechToTextProvider)? {
        _ = taskKind
        return speechProviders.keys.sorted().first.flatMap { speechProviders[$0] }
    }
}
