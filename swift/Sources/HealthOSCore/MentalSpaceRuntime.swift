import Foundation

public enum MentalSpaceRuntimeStage: String, Codable, Sendable, CaseIterable {
    case normalization = "transcription_normalization"
    case asl = "asl"
    case vdlp = "vdlp"
    case gem = "gem"

    public var asyncJobKind: AsyncJobKind {
        switch self {
        case .normalization:
            return .mentalSpaceNormalization
        case .asl:
            return .mentalSpaceASL
        case .vdlp:
            return .mentalSpaceVDLP
        case .gem:
            return .mentalSpaceGEM
        }
    }
}

public enum MentalSpaceStageStatus: String, Codable, Sendable {
    case pending
    case ready
    case degraded
    case blocked
    case failed
}

public enum MentalSpaceClinicianReviewStatus: String, Codable, Sendable {
    case unreviewed
    case inReview = "in_review"
    case reviewed
    case rejected
}

public struct MentalSpaceArtifactMetadata: Codable, Sendable, Equatable {
    public let stage: MentalSpaceRuntimeStage
    public let sourceTranscriptRef: String
    public let stageVersion: String
    public let promptVersion: String
    public let modelProvider: String
    public let modelId: String?
    public let inputHash: String
    public let outputHash: String
    public let lawfulContextSummary: String
    public let clinicianReviewStatus: MentalSpaceClinicianReviewStatus
    public let limitations: [String]
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        stage: MentalSpaceRuntimeStage,
        sourceTranscriptRef: String,
        stageVersion: String,
        promptVersion: String,
        modelProvider: String,
        modelId: String?,
        inputHash: String,
        outputHash: String,
        lawfulContextSummary: String,
        clinicianReviewStatus: MentalSpaceClinicianReviewStatus = .unreviewed,
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
        self.clinicianReviewStatus = clinicianReviewStatus
        self.limitations = limitations
        self.legalAuthorizing = legalAuthorizing
        self.gateStillRequired = gateStillRequired
    }
}

public struct NormalizedTranscriptArtifact: Codable, Sendable {
    public let metadata: MentalSpaceArtifactMetadata
    public let normalizedTranscript: String
    public let correctionSummary: String
    public let sourceTranscriptObjectRef: StorageObjectRef

    public init(
        metadata: MentalSpaceArtifactMetadata,
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

public struct ASLArtifact: Codable, Sendable, Equatable {
    public let metadata: MentalSpaceArtifactMetadata
    public let linguisticSummary: String
    public let evidenceRefs: [String]

    public init(metadata: MentalSpaceArtifactMetadata, linguisticSummary: String, evidenceRefs: [String]) {
        self.metadata = metadata
        self.linguisticSummary = linguisticSummary
        self.evidenceRefs = evidenceRefs
    }
}

public struct VDLPArtifact: Codable, Sendable, Equatable {
    public let metadata: MentalSpaceArtifactMetadata
    public let dimensionalSummary: String
    public let dimensionRefs: [String]

    public init(metadata: MentalSpaceArtifactMetadata, dimensionalSummary: String, dimensionRefs: [String]) {
        self.metadata = metadata
        self.dimensionalSummary = dimensionalSummary
        self.dimensionRefs = dimensionRefs
    }
}

public struct GEMArtifact: Codable, Sendable, Equatable {
    public let metadata: MentalSpaceArtifactMetadata
    public let graphSummary: String
    public let layerRefs: [String]

    public init(metadata: MentalSpaceArtifactMetadata, graphSummary: String, layerRefs: [String]) {
        self.metadata = metadata
        self.graphSummary = graphSummary
        self.layerRefs = layerRefs
    }
}

public struct MentalSpaceStageExecutionState: Codable, Sendable, Equatable {
    public let stage: MentalSpaceRuntimeStage
    public let status: MentalSpaceStageStatus
    public let artifactObjectPath: String?
    public let modelProvider: String?
    public let modelId: String?
    public let clinicianReviewStatus: MentalSpaceClinicianReviewStatus
    public let summary: String
    public let issueMessage: String?
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        stage: MentalSpaceRuntimeStage,
        status: MentalSpaceStageStatus,
        artifactObjectPath: String? = nil,
        modelProvider: String? = nil,
        modelId: String? = nil,
        clinicianReviewStatus: MentalSpaceClinicianReviewStatus = .unreviewed,
        summary: String,
        issueMessage: String? = nil,
        legalAuthorizing: Bool = false,
        gateStillRequired: Bool = true
    ) {
        self.stage = stage
        self.status = status
        self.artifactObjectPath = artifactObjectPath
        self.modelProvider = modelProvider
        self.modelId = modelId
        self.clinicianReviewStatus = clinicianReviewStatus
        self.summary = summary
        self.issueMessage = issueMessage
        self.legalAuthorizing = legalAuthorizing
        self.gateStillRequired = gateStillRequired
    }

    public static func pending(_ stage: MentalSpaceRuntimeStage) -> Self {
        .init(
            stage: stage,
            status: .pending,
            summary: "Mental Space Runtime stage has not run yet."
        )
    }
}

public struct MentalSpacePersistedArtifact: Codable, Sendable {
    public let stage: MentalSpaceRuntimeStage
    public let objectRef: StorageObjectRef
    public let metadata: MentalSpaceArtifactMetadata
    public let summary: String

    public init(
        stage: MentalSpaceRuntimeStage,
        objectRef: StorageObjectRef,
        metadata: MentalSpaceArtifactMetadata,
        summary: String
    ) {
        self.stage = stage
        self.objectRef = objectRef
        self.metadata = metadata
        self.summary = summary
    }
}

public struct MentalSpaceRunArtifacts: Codable, Sendable {
    public let normalizedTranscript: MentalSpacePersistedArtifact?
    public let normalizationState: MentalSpaceStageExecutionState
    public let aslState: MentalSpaceStageExecutionState
    public let vdlpState: MentalSpaceStageExecutionState
    public let gemState: MentalSpaceStageExecutionState

    public init(
        normalizedTranscript: MentalSpacePersistedArtifact? = nil,
        normalizationState: MentalSpaceStageExecutionState = .pending(.normalization),
        aslState: MentalSpaceStageExecutionState = .pending(.asl),
        vdlpState: MentalSpaceStageExecutionState = .pending(.vdlp),
        gemState: MentalSpaceStageExecutionState = .pending(.gem)
    ) {
        self.normalizedTranscript = normalizedTranscript
        self.normalizationState = normalizationState
        self.aslState = aslState
        self.vdlpState = vdlpState
        self.gemState = gemState
    }

    public var stageStates: [MentalSpaceStageExecutionState] {
        [normalizationState, aslState, vdlpState, gemState]
    }

    public func updatingNormalization(
        artifact: MentalSpacePersistedArtifact?,
        state: MentalSpaceStageExecutionState
    ) -> Self {
        .init(
            normalizedTranscript: artifact,
            normalizationState: state,
            aslState: aslState,
            vdlpState: vdlpState,
            gemState: gemState
        )
    }
}

public enum MentalSpacePipelineError: Error, LocalizedError, Equatable, Sendable {
    case normalizedTranscriptRequired
    case aslRequired
    case vdlpRequired

    public var errorDescription: String? {
        switch self {
        case .normalizedTranscriptRequired:
            return "ASL requires a ready normalized transcript artifact."
        case .aslRequired:
            return "VDLP requires a ready ASL artifact."
        case .vdlpRequired:
            return "GEM requires a ready VDLP artifact."
        }
    }
}

public struct MentalSpacePipelineValidator {
    public static func validateCanRun(stage: MentalSpaceRuntimeStage, state: MentalSpaceRunArtifacts) throws {
        switch stage {
        case .normalization:
            return
        case .asl:
            guard state.normalizationState.status == .ready,
                  state.normalizedTranscript != nil else {
                throw MentalSpacePipelineError.normalizedTranscriptRequired
            }
        case .vdlp:
            guard state.aslState.status == .ready else {
                throw MentalSpacePipelineError.aslRequired
            }
        case .gem:
            guard state.vdlpState.status == .ready else {
                throw MentalSpacePipelineError.vdlpRequired
            }
        }
    }
}

public struct MentalSpaceNormalizationRequest: Sendable {
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

public struct MentalSpaceNormalizationResult: Sendable {
    public let status: MentalSpaceStageStatus
    public let normalizedText: String?
    public let correctionSummary: String
    public let promptVersion: String
    public let stageVersion: String
    public let providerExecution: ProviderExecutionMetadata?
    public let issueMessage: String?

    public init(
        status: MentalSpaceStageStatus,
        normalizedText: String? = nil,
        correctionSummary: String,
        promptVersion: String = "mental-space-normalization-v1",
        stageVersion: String = "1.0-normalization",
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

public struct MentalSpaceRuntimeStateView: Codable, Sendable, Equatable {
    public let stages: [MentalSpaceStageExecutionState]
    public let activeStage: MentalSpaceRuntimeStage?
    public let derivedArtifactsOnly: Bool
    public let clinicianReviewRequired: Bool
    public let legalAuthorizing: Bool
    public let summary: String

    public init(
        stages: [MentalSpaceStageExecutionState],
        activeStage: MentalSpaceRuntimeStage? = nil,
        derivedArtifactsOnly: Bool = true,
        clinicianReviewRequired: Bool = true,
        legalAuthorizing: Bool = false,
        summary: String
    ) {
        self.stages = stages
        self.activeStage = activeStage
        self.derivedArtifactsOnly = derivedArtifactsOnly
        self.clinicianReviewRequired = clinicianReviewRequired
        self.legalAuthorizing = legalAuthorizing
        self.summary = summary
    }

    public static var pending: Self {
        .init(
            stages: MentalSpaceRunArtifacts().stageStates,
            summary: "Mental Space Runtime has not produced derived artifacts for this session."
        )
    }
}

public enum MentalSpaceContentHasher {
    public static func sha256Hex(for text: String) -> String {
        sha256Hex(for: Data(text.utf8))
    }

    public static func sha256Hex(for data: Data) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
        process.arguments = ["-a", "256"]

        let input = Pipe()
        let output = Pipe()
        process.standardInput = input
        process.standardOutput = output

        do {
            try process.run()
            input.fileHandleForWriting.write(data)
            try input.fileHandleForWriting.close()
            process.waitUntilExit()
            let digestData = output.fileHandleForReading.readDataToEndOfFile()
            let raw = String(decoding: digestData, as: UTF8.self)
            if let digest = raw.split(separator: " ").first {
                return String(digest)
            }
        } catch {
            return deterministicFallbackHash(for: data)
        }
        return deterministicFallbackHash(for: data)
    }

    private static func deterministicFallbackHash(for data: Data) -> String {
        var hash: UInt64 = 0xcbf29ce484222325
        for byte in data {
            hash ^= UInt64(byte)
            hash &*= 0x100000001b3
        }
        return String(format: "fnv1a64-%016llx", hash)
    }
}
