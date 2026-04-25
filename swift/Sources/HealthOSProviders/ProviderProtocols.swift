import Foundation
import HealthOSCore

public enum ProviderKind: String, Codable, Sendable {
    case local
    case remote
    case appleNative = "apple-native"
    case httpLocal = "http-local"
    case trainingOffline = "training-offline"
}

public enum ProviderTaskClass: String, Codable, Sendable, CaseIterable {
    case speechToText = "speech-to-text"
    case languageModel = "language-model"
    case embedding
    case retrieval
    case fineTuning = "fine-tuning"
    case evaluation
}

public enum ProviderLatencyClass: String, Codable, Sendable {
    case interactive
    case nearRealtime = "near-realtime"
    case batch
    case offline
}

public enum ProviderExecutionStatus: String, Codable, Sendable {
    case selected
    case degraded
    case denied
    case unavailable
    case stubOnly = "stub-only"
}

public struct ProviderCapabilityProfile: Codable, Sendable {
    public let providerId: String
    public let providerKind: ProviderKind
    public let supportedTaskClasses: Set<ProviderTaskClass>
    public let allowedDataLayers: Set<StorageLayer>
    public let allowsPHI: Bool
    public let allowsIdentifiableData: Bool
    public let requiresNetwork: Bool
    public let latencyClass: ProviderLatencyClass
    public let supportsCostReporting: Bool
    public let supportsProvenanceReporting: Bool
    public let isStub: Bool

    public init(
        providerId: String,
        providerKind: ProviderKind,
        supportedTaskClasses: Set<ProviderTaskClass>,
        allowedDataLayers: Set<StorageLayer>,
        allowsPHI: Bool,
        allowsIdentifiableData: Bool,
        requiresNetwork: Bool,
        latencyClass: ProviderLatencyClass,
        supportsCostReporting: Bool,
        supportsProvenanceReporting: Bool,
        isStub: Bool
    ) {
        self.providerId = providerId
        self.providerKind = providerKind
        self.supportedTaskClasses = supportedTaskClasses
        self.allowedDataLayers = allowedDataLayers
        self.allowsPHI = allowsPHI
        self.allowsIdentifiableData = allowsIdentifiableData
        self.requiresNetwork = requiresNetwork
        self.latencyClass = latencyClass
        self.supportsCostReporting = supportsCostReporting
        self.supportsProvenanceReporting = supportsProvenanceReporting
        self.isStub = isStub
    }
}

public enum ProviderCapabilityValidationError: Error, Equatable, Sendable {
    case missingProviderId
    case noSupportedTaskClass
    case noAllowedDataLayer
}

public enum ProviderSafetyDenialReason: String, Codable, Sendable, Equatable {
    case missingCapabilityProfile = "missing-capability-profile"
    case taskNotSupported = "task-not-supported"
    case dataLayerNotAllowed = "data-layer-not-allowed"
    case phiNotAllowed = "phi-not-allowed"
    case identifiableDataNotAllowed = "identifiable-data-not-allowed"
    case remotePolicyMissing = "remote-policy-missing"
    case remoteDirectIdentifiersDenied = "remote-direct-identifiers-denied"
    case remoteReidentificationDenied = "remote-reidentification-denied"
    case remoteOperationalSensitiveDenied = "remote-operational-sensitive-denied"
    case noProviderAvailable = "no-provider-available"
    case noRealProviderAvailable = "no-real-provider-available"
    case fallbackNotAllowed = "fallback-not-allowed"
}

public struct ProviderRoutingRequest: Sendable {
    public let taskClass: ProviderTaskClass
    public let dataLayer: StorageLayer
    public let lawfulContext: [String: String]
    public let finalidade: String
    public let allowsRemoteFallback: Bool
    public let allowsRemoteForOperationalSensitiveContent: Bool
    public let fallbackAllowed: Bool
    public let preferLocal: Bool

    public init(
        taskClass: ProviderTaskClass,
        dataLayer: StorageLayer,
        lawfulContext: [String: String],
        finalidade: String,
        allowsRemoteFallback: Bool,
        allowsRemoteForOperationalSensitiveContent: Bool = false,
        fallbackAllowed: Bool,
        preferLocal: Bool = true
    ) {
        self.taskClass = taskClass
        self.dataLayer = dataLayer
        self.lawfulContext = lawfulContext
        self.finalidade = finalidade
        self.allowsRemoteFallback = allowsRemoteFallback
        self.allowsRemoteForOperationalSensitiveContent = allowsRemoteForOperationalSensitiveContent
        self.fallbackAllowed = fallbackAllowed
        self.preferLocal = preferLocal
    }
}

public enum ProviderRoutingDecision: Sendable, Equatable {
    case selected(ProviderSelection)
    case degradedFallback(ProviderSelection, reason: ProviderSafetyDenialReason)
    case deniedByPolicy(ProviderSafetyDenialReason)
    case unavailable(ProviderSafetyDenialReason)
    case stubOnly(ProviderSelection, reason: ProviderSafetyDenialReason)
}

public struct ProviderSelection: Sendable, Equatable {
    public let providerId: String
    public let providerKind: ProviderKind
    public let taskClass: ProviderTaskClass
    public let modelId: String?
    public let modelVersion: String?
    public let isStub: Bool

    public init(
        providerId: String,
        providerKind: ProviderKind,
        taskClass: ProviderTaskClass,
        modelId: String? = nil,
        modelVersion: String? = nil,
        isStub: Bool
    ) {
        self.providerId = providerId
        self.providerKind = providerKind
        self.taskClass = taskClass
        self.modelId = modelId
        self.modelVersion = modelVersion
        self.isStub = isStub
    }
}

public struct ProviderRouteDecision: Codable, Sendable {
    public let providerName: String
    public let reason: String
}

public protocol LanguageModelProvider: Sendable {
    var providerName: String { get }
    var capabilityProfile: ProviderCapabilityProfile { get }
    var modelId: String? { get }
    var modelVersion: String? { get }
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
    var capabilityProfile: ProviderCapabilityProfile { get }
    var modelId: String? { get }
    var modelVersion: String? { get }
    func transcribe(audioURL: URL) async throws -> SpeechTranscriptionResult
}

public protocol EmbeddingProvider: Sendable {
    var providerName: String { get }
    var capabilityProfile: ProviderCapabilityProfile { get }
    func embed(text: String) async throws -> [Double]
}

public protocol RetrievalProvider: Sendable {
    var providerName: String { get }
    var capabilityProfile: ProviderCapabilityProfile { get }
    func search(query: String, scope: [String: String]) async throws -> [String]
}

public protocol FineTuningProvider: Sendable {
    var providerName: String { get }
    var capabilityProfile: ProviderCapabilityProfile { get }
    func enqueue(jobName: String, datasetRef: String, baseModel: String) async throws -> String
}

public actor ProviderRouter {
    private var languageProviders: [String: any LanguageModelProvider] = [:]
    private var speechProviders: [String: any SpeechToTextProvider] = [:]

    public init() {}

    public func register(_ provider: any LanguageModelProvider) throws {
        try validateCapability(provider.capabilityProfile)
        languageProviders[provider.providerName] = provider
    }

    public func register(_ provider: any SpeechToTextProvider) throws {
        try validateCapability(provider.capabilityProfile)
        speechProviders[provider.providerName] = provider
    }

    public func route(taskKind: String) -> ProviderRouteDecision {
        let request = ProviderRoutingRequest(
            taskClass: .languageModel,
            dataLayer: .derivedArtifacts,
            lawfulContext: ["scope": "runtime-routing"],
            finalidade: taskKind,
            allowsRemoteFallback: false,
            fallbackAllowed: true
        )
        switch routeLanguage(request: request) {
        case .selected(let selection), .degradedFallback(let selection, _), .stubOnly(let selection, _):
            return ProviderRouteDecision(providerName: selection.providerId, reason: "policy-routed for \(taskKind)")
        case .deniedByPolicy(let reason), .unavailable(let reason):
            return ProviderRouteDecision(providerName: "none", reason: reason.rawValue)
        }
    }

    public func speechProvider(taskKind: String) -> (any SpeechToTextProvider)? {
        _ = taskKind
        return speechProviders.keys.sorted().first.flatMap { speechProviders[$0] }
    }

    public func routeLanguage(request: ProviderRoutingRequest) -> ProviderRoutingDecision {
        route(request: request, providers: Array(languageProviders.values).sorted(by: { $0.providerName < $1.providerName })) {
            ProviderSelection(
                providerId: $0.providerName,
                providerKind: $0.capabilityProfile.providerKind,
                taskClass: request.taskClass,
                modelId: $0.modelId,
                modelVersion: $0.modelVersion,
                isStub: $0.capabilityProfile.isStub
            )
        }
    }

    public func routeSpeech(request: ProviderRoutingRequest) -> ProviderRoutingDecision {
        route(request: request, providers: Array(speechProviders.values).sorted(by: { $0.providerName < $1.providerName })) {
            ProviderSelection(
                providerId: $0.providerName,
                providerKind: $0.capabilityProfile.providerKind,
                taskClass: request.taskClass,
                modelId: $0.modelId,
                modelVersion: $0.modelVersion,
                isStub: $0.capabilityProfile.isStub
            )
        }
    }

    public func speechProvider(for selection: ProviderSelection) -> (any SpeechToTextProvider)? {
        speechProviders[selection.providerId]
    }

    public func languageProvider(for selection: ProviderSelection) -> (any LanguageModelProvider)? {
        languageProviders[selection.providerId]
    }

    private func validateCapability(_ profile: ProviderCapabilityProfile) throws {
        guard !profile.providerId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ProviderCapabilityValidationError.missingProviderId
        }
        guard !profile.supportedTaskClasses.isEmpty else {
            throw ProviderCapabilityValidationError.noSupportedTaskClass
        }
        guard !profile.allowedDataLayers.isEmpty else {
            throw ProviderCapabilityValidationError.noAllowedDataLayer
        }
    }

    private func route<P>(
        request: ProviderRoutingRequest,
        providers: [P],
        makeSelection: (P) -> ProviderSelection
    ) -> ProviderRoutingDecision where P: Sendable {
        guard !providers.isEmpty else {
            return .unavailable(.noProviderAvailable)
        }

        if request.dataLayer == .directIdentifiers {
            return .deniedByPolicy(.remoteDirectIdentifiersDenied)
        }
        if request.dataLayer == .reidentificationMapping {
            return .deniedByPolicy(.remoteReidentificationDenied)
        }

        let candidates: [(P, ProviderSelection, ProviderCapabilityProfile)] = providers.compactMap { provider in
            switch provider {
            case let typed as any LanguageModelProvider:
                let profile = typed.capabilityProfile
                return (provider, makeSelection(provider), profile)
            case let typed as any SpeechToTextProvider:
                let profile = typed.capabilityProfile
                return (provider, makeSelection(provider), profile)
            default:
                return nil
            }
        }

        let taskFiltered = candidates.filter { _, _, profile in
            profile.supportedTaskClasses.contains(request.taskClass)
        }
        guard !taskFiltered.isEmpty else {
            return .deniedByPolicy(.taskNotSupported)
        }

        let layerFiltered = taskFiltered.filter { _, _, profile in
            profile.allowedDataLayers.contains(request.dataLayer)
        }
        guard !layerFiltered.isEmpty else {
            return .deniedByPolicy(.dataLayerNotAllowed)
        }

        let identitySensitive = request.dataLayer == .directIdentifiers || request.dataLayer == .reidentificationMapping
        let phiRequired = request.dataLayer == .operationalContent || request.dataLayer == .derivedArtifacts
        let privacyFiltered = layerFiltered.filter { _, _, profile in
            (!identitySensitive || profile.allowsIdentifiableData) && (!phiRequired || profile.allowsPHI)
        }
        guard !privacyFiltered.isEmpty else {
            return .deniedByPolicy(phiRequired ? .phiNotAllowed : .identifiableDataNotAllowed)
        }

        let localCandidates = privacyFiltered.filter { _, _, profile in
            switch profile.providerKind {
            case .local, .appleNative, .httpLocal, .trainingOffline:
                return true
            case .remote:
                return false
            }
        }
        let remoteCandidates = privacyFiltered.filter { _, _, profile in
            profile.providerKind == ProviderKind.remote
        }

        if request.preferLocal, let localReal = localCandidates.first(where: { !$0.2.isStub }) {
            return .selected(localReal.1)
        }

        if let remoteReal = remoteCandidates.first(where: { !$0.2.isStub }) {
            if !request.allowsRemoteFallback {
                return .deniedByPolicy(.remotePolicyMissing)
            }
            if request.dataLayer == .operationalContent && !request.allowsRemoteForOperationalSensitiveContent {
                return .deniedByPolicy(.remoteOperationalSensitiveDenied)
            }
            return .degradedFallback(remoteReal.1, reason: .fallbackNotAllowed)
        }

        if let localStub = localCandidates.first(where: { $0.2.isStub }) {
            return .stubOnly(localStub.1, reason: .noRealProviderAvailable)
        }

        if let remoteStub = remoteCandidates.first(where: { $0.2.isStub }) {
            if !request.allowsRemoteFallback {
                return .deniedByPolicy(.remotePolicyMissing)
            }
            if request.dataLayer == .operationalContent && !request.allowsRemoteForOperationalSensitiveContent {
                return .deniedByPolicy(.remoteOperationalSensitiveDenied)
            }
            return .stubOnly(remoteStub.1, reason: .noRealProviderAvailable)
        }

        if !request.fallbackAllowed {
            return .unavailable(.fallbackNotAllowed)
        }
        return .unavailable(.noProviderAvailable)
    }
}
