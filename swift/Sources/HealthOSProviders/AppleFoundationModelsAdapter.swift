import Foundation
import HealthOSCore

#if canImport(FoundationModels)
import FoundationModels
#endif

public enum AppleFoundationModelsProviderError: Error, LocalizedError, Sendable, Equatable {
    case frameworkUnavailable
    case modelUnavailable(String)
    case unsupportedLocale(String)

    public var errorDescription: String? {
        switch self {
        case .frameworkUnavailable:
            return "FoundationModels framework is unavailable in this build."
        case .modelUnavailable(let reason):
            return "Apple Foundation Models unavailable: \(reason)."
        case .unsupportedLocale(let identifier):
            return "Apple Foundation Models do not support the current locale: \(identifier)."
        }
    }
}

public struct AppleFoundationProvider: LanguageModelProvider {
    public let providerName = "apple-foundation"
    public let modelId: String? = "SystemLanguageModel.default"
    public let modelVersion: String? = "FoundationModels"
    public let capabilityProfile: ProviderCapabilityProfile

    public init(forceStub: Bool = false) {
        self.capabilityProfile = ProviderCapabilityProfile(
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
            isStub: forceStub || !Self.isFrameworkCompiledIn
        )
    }

    public func generate(prompt: String, context: [String: String]) async throws -> String {
#if canImport(FoundationModels)
        guard #available(macOS 26.0, iOS 26.0, visionOS 26.0, *) else {
            throw AppleFoundationModelsProviderError.frameworkUnavailable
        }

        let model = SystemLanguageModel.default
        guard model.supportsLocale(.current) else {
            throw AppleFoundationModelsProviderError.unsupportedLocale(Locale.current.identifier)
        }
        switch model.availability {
        case .available:
            let session = LanguageModelSession(
                model: model,
                instructions: Self.instructions(context: context)
            )
            let response = try await session.respond(
                to: Self.prompt(from: prompt),
                options: GenerationOptions(temperature: 0.0, maximumResponseTokens: 1200)
            )
            return response.content
        case .unavailable(let reason):
            throw AppleFoundationModelsProviderError.modelUnavailable(Self.describeUnavailableReason(reason))
        }
#else
        _ = prompt
        _ = context
        throw AppleFoundationModelsProviderError.frameworkUnavailable
#endif
    }

    public static var isFrameworkCompiledIn: Bool {
#if canImport(FoundationModels)
        true
#else
        false
#endif
    }

    public static func runtimeAvailabilityDescription() -> String {
#if canImport(FoundationModels)
        guard #available(macOS 26.0, iOS 26.0, visionOS 26.0, *) else {
            return "framework-unavailable"
        }
        let model = SystemLanguageModel.default
        guard model.supportsLocale(.current) else {
            return "unsupported-locale:\(Locale.current.identifier)"
        }
        switch model.availability {
        case .available:
            return "available"
        case .unavailable(let reason):
            return "unavailable:\(describeUnavailableReason(reason))"
        }
#else
        return "framework-unavailable"
#endif
    }

    private static func instructions(context: [String: String]) -> String {
        let promptVersion = context["promptVersion"] ?? "transcript-normalization-v1"
        return """
        You normalize HealthOS session transcripts locally on device.
        Task: \(context["task"] ?? "session-transcript-normalization")
        Prompt version: \(promptVersion)

        Return only the normalized transcript text.
        Preserve clinical meaning, speaker intent, and language.
        Correct spacing, punctuation, obvious transcription artifacts, and duplicated filler.
        Do not add facts, diagnoses, orders, referrals, prescriptions, or external context.
        Do not include explanations, JSON, markdown, labels, or metadata.
        """
    }

    private static func prompt(from transcript: String) -> String {
        """
        Normalize this transcript for clinician review and downstream derived-artifact processing.

        Transcript:
        \(transcript)
        """
    }

#if canImport(FoundationModels)
    @available(macOS 26.0, iOS 26.0, visionOS 26.0, *)
    private static func describeUnavailableReason(_ reason: SystemLanguageModel.Availability.UnavailableReason) -> String {
        switch reason {
        case .deviceNotEligible:
            return "device-not-eligible"
        case .appleIntelligenceNotEnabled:
            return "apple-intelligence-not-enabled"
        case .modelNotReady:
            return "model-not-ready"
        @unknown default:
            return "unknown"
        }
    }
#endif
}
