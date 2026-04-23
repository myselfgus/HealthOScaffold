import Foundation

public struct AppleFoundationProvider: LanguageModelProvider {
    public let providerName = "apple-foundation"

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        // TODO: integrate with on-device provider
        return "[apple-foundation stub] \(prompt.prefix(64))"
    }
}

public struct LocalHTTPModelProvider: LanguageModelProvider {
    public let providerName = "local-http"

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        return "[local-http stub] \(prompt.prefix(64))"
    }
}

public struct RemoteFallbackProvider: LanguageModelProvider {
    public let providerName = "remote-fallback"

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        return "[remote-fallback stub] \(prompt.prefix(64))"
    }
}

public struct NativeSpeechProvider: SpeechToTextProvider {
    public let providerName = "native-speech"

    public init() {}

    public func transcribe(audioURL: URL) async throws -> SpeechTranscriptionResult {
        SpeechTranscriptionResult(
            status: .degraded,
            message: "Native local transcription remains stubbed for now; audio was stored locally but transcript text is unavailable for \(audioURL.lastPathComponent)."
        )
    }
}
