import Foundation
import HealthOSCore

public struct AppleFoundationProvider: LanguageModelProvider {
    public let providerName = "apple-foundation"
    public let modelId: String? = nil
    public let modelVersion: String? = nil
    public let capabilityProfile = ProviderCapabilityProfile(
        providerId: "apple-foundation",
        providerKind: .appleNative,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.operationalContent, .derivedArtifacts, .governanceMetadata],
        allowsPHI: true,
        allowsIdentifiableData: false,
        requiresNetwork: false,
        latencyClass: .interactive,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: true
    )

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        _ = context
        return "[apple-foundation stub] \(prompt.prefix(64))"
    }
}

public struct LocalHTTPModelProvider: LanguageModelProvider {
    public let providerName = "local-http"
    public let modelId: String? = nil
    public let modelVersion: String? = nil
    public let capabilityProfile = ProviderCapabilityProfile(
        providerId: "local-http",
        providerKind: .httpLocal,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.operationalContent, .derivedArtifacts],
        allowsPHI: true,
        allowsIdentifiableData: false,
        requiresNetwork: false,
        latencyClass: .nearRealtime,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: true
    )

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        _ = context
        return "[local-http stub] \(prompt.prefix(64))"
    }
}

public enum RemoteFallbackGuardError: Error, Equatable, Sendable {
    case missingExplicitPolicy
    case directIdentifierDenied
    case reidentificationDenied
    case sensitiveOperationalDenied
}

public struct RemoteFallbackProvider: LanguageModelProvider {
    public let providerName = "remote-fallback"
    public let modelId: String? = nil
    public let modelVersion: String? = nil
    public let capabilityProfile = ProviderCapabilityProfile(
        providerId: "remote-fallback",
        providerKind: .remote,
        supportedTaskClasses: [.languageModel, .evaluation],
        allowedDataLayers: [.derivedArtifacts],
        allowsPHI: false,
        allowsIdentifiableData: false,
        requiresNetwork: true,
        latencyClass: .batch,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: true
    )

    public init() {}

    public func generate(prompt: String, context: [String : String]) async throws -> String {
        _ = context
        return "[remote-fallback stub] \(prompt.prefix(64))"
    }

    public func guardedGenerate(
        prompt: String,
        context: [String: String],
        routingRequest: ProviderRoutingRequest
    ) async throws -> String {
        guard routingRequest.allowsRemoteFallback else {
            throw RemoteFallbackGuardError.missingExplicitPolicy
        }
        switch routingRequest.dataLayer {
        case .directIdentifiers:
            throw RemoteFallbackGuardError.directIdentifierDenied
        case .reidentificationMapping:
            throw RemoteFallbackGuardError.reidentificationDenied
        case .operationalContent:
            guard routingRequest.allowsRemoteForOperationalSensitiveContent else {
                throw RemoteFallbackGuardError.sensitiveOperationalDenied
            }
        default:
            break
        }
        return try await generate(prompt: prompt, context: context)
    }
}

public struct NativeSpeechProvider: SpeechToTextProvider {
    public let providerName = "native-speech"
    public let modelId: String? = nil
    public let modelVersion: String? = nil
    public let capabilityProfile = ProviderCapabilityProfile(
        providerId: "native-speech",
        providerKind: .appleNative,
        supportedTaskClasses: [.speechToText],
        allowedDataLayers: [.operationalContent],
        allowsPHI: true,
        allowsIdentifiableData: false,
        requiresNetwork: false,
        latencyClass: .interactive,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: true
    )

    public init() {}

    public func transcribe(audioURL: URL) async throws -> SpeechTranscriptionResult {
        SpeechTranscriptionResult(
            status: .degraded,
            message: "Native local transcription remains stubbed for now; audio was stored locally but transcript text is unavailable for \(audioURL.lastPathComponent)."
        )
    }
}

public struct InvalidCapabilityLanguageProvider: LanguageModelProvider {
    public let providerName: String
    public let capabilityProfile: ProviderCapabilityProfile
    public let modelId: String? = nil
    public let modelVersion: String? = nil

    public init(providerName: String, capabilityProfile: ProviderCapabilityProfile) {
        self.providerName = providerName
        self.capabilityProfile = capabilityProfile
    }

    public func generate(prompt: String, context: [String: String]) async throws -> String {
        _ = context
        return prompt
    }
}
