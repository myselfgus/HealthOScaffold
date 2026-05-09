import Foundation

public enum TranscriptNormalizationStatus: String, Codable, Sendable {
    case pending
    case ready
    case degraded
    case blocked
    case failed
}

public struct TranscriptNormalizationArtifactMetadata: Codable, Sendable, Equatable {
    public let stage: String
    public let sourceTranscriptRef: String
    public let stageVersion: String
    public let promptVersion: String
    public let modelProvider: String
    public let modelId: String?
    public let inputHash: String
    public let outputHash: String
    public let lawfulContextSummary: String
    public let limitations: [String]
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        stage: String = "transcript_normalization",
        sourceTranscriptRef: String,
        stageVersion: String,
        promptVersion: String,
        modelProvider: String,
        modelId: String?,
        inputHash: String,
        outputHash: String,
        lawfulContextSummary: String,
        limitations: [String],
        legalAuthorizing: Bool = false,
        gateStillRequired: Bool = true
    ) {
        self.stage = stage
        self.sourceTranscriptRef = sourceTranscriptRef
        self.stageVersion = stageVersion
        self.promptVersion = promptVersion
        self.modelProvider = modelProvider
        self.modelId = modelId
        self.inputHash = inputHash
        self.outputHash = outputHash
        self.lawfulContextSummary = lawfulContextSummary
        self.limitations = limitations
        self.legalAuthorizing = legalAuthorizing
        self.gateStillRequired = gateStillRequired
    }
}

public struct NormalizedTranscriptArtifact: Codable, Sendable {
    public let metadata: TranscriptNormalizationArtifactMetadata
    public let normalizedTranscript: String
    public let correctionSummary: String
    public let sourceTranscriptObjectRef: StorageObjectRef

    public init(
        metadata: TranscriptNormalizationArtifactMetadata,
        normalizedTranscript: String,
        correctionSummary: String,
        sourceTranscriptObjectRef: StorageObjectRef
    ) {
        self.metadata = metadata
        self.normalizedTranscript = normalizedTranscript
        self.correctionSummary = correctionSummary
        self.sourceTranscriptObjectRef = sourceTranscriptObjectRef
    }
}

public struct TranscriptNormalizationRequest: Sendable {
    public let transcriptText: String
    public let sourceTranscriptRef: StorageObjectRef
    public let lawfulContext: [String: String]

    public init(
        transcriptText: String,
        sourceTranscriptRef: StorageObjectRef,
        lawfulContext: [String: String]
    ) {
        self.transcriptText = transcriptText
        self.sourceTranscriptRef = sourceTranscriptRef
        self.lawfulContext = lawfulContext
    }
}

public struct TranscriptNormalizationResult: Sendable {
    public let status: TranscriptNormalizationStatus
    public let normalizedText: String?
    public let correctionSummary: String
    public let promptVersion: String
    public let stageVersion: String
    public let providerExecution: ProviderExecutionMetadata?
    public let issueMessage: String?

    public init(
        status: TranscriptNormalizationStatus,
        normalizedText: String? = nil,
        correctionSummary: String,
        promptVersion: String = "transcript-normalization-v1",
        stageVersion: String = "session-transcript-normalization-001",
        providerExecution: ProviderExecutionMetadata? = nil,
        issueMessage: String? = nil
    ) {
        self.status = status
        self.normalizedText = normalizedText
        self.correctionSummary = correctionSummary
        self.promptVersion = promptVersion
        self.stageVersion = stageVersion
        self.providerExecution = providerExecution
        self.issueMessage = issueMessage
    }
}

public struct TranscriptNormalizationPersistedArtifact: Codable, Sendable {
    public let objectRef: StorageObjectRef
    public let metadata: TranscriptNormalizationArtifactMetadata
    public let summary: String

    public init(
        objectRef: StorageObjectRef,
        metadata: TranscriptNormalizationArtifactMetadata,
        summary: String
    ) {
        self.objectRef = objectRef
        self.metadata = metadata
        self.summary = summary
    }
}

public struct TranscriptNormalizationState: Codable, Sendable, Equatable {
    public let status: TranscriptNormalizationStatus
    public let artifactObjectPath: String?
    public let modelProvider: String?
    public let modelId: String?
    public let summary: String
    public let issueMessage: String?
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        status: TranscriptNormalizationStatus,
        artifactObjectPath: String? = nil,
        modelProvider: String? = nil,
        modelId: String? = nil,
        summary: String,
        issueMessage: String? = nil,
        legalAuthorizing: Bool = false,
        gateStillRequired: Bool = true
    ) {
        self.status = status
        self.artifactObjectPath = artifactObjectPath
        self.modelProvider = modelProvider
        self.modelId = modelId
        self.summary = summary
        self.issueMessage = issueMessage
        self.legalAuthorizing = legalAuthorizing
        self.gateStillRequired = gateStillRequired
    }

    public static var pending: Self {
        .init(
            status: .pending,
            summary: "Transcript normalization has not run yet."
        )
    }
}

public struct TranscriptNormalizationRunState: Codable, Sendable {
    public let normalizedTranscript: TranscriptNormalizationPersistedArtifact?
    public let state: TranscriptNormalizationState

    public init(
        normalizedTranscript: TranscriptNormalizationPersistedArtifact? = nil,
        state: TranscriptNormalizationState = .pending
    ) {
        self.normalizedTranscript = normalizedTranscript
        self.state = state
    }
}

public struct TranscriptNormalizationStateView: Codable, Sendable, Equatable {
    public let state: TranscriptNormalizationState
    public let derivedArtifactOnly: Bool
    public let legalAuthorizing: Bool
    public let summary: String

    public init(
        state: TranscriptNormalizationState = .pending,
        derivedArtifactOnly: Bool = true,
        legalAuthorizing: Bool = false,
        summary: String? = nil
    ) {
        self.state = state
        self.derivedArtifactOnly = derivedArtifactOnly
        self.legalAuthorizing = legalAuthorizing
        self.summary = summary ?? state.summary
    }

    public static var pending: Self {
        .init()
    }
}
