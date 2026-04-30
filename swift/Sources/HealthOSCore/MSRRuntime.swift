import Foundation

public enum MSRStage: String, Codable, Sendable, CaseIterable {
    case asl
    case vdlp
    case gem

    public var asyncJobKind: AsyncJobKind {
        switch self {
        case .asl:
            return .msrASL
        case .vdlp:
            return .msrVDLP
        case .gem:
            return .msrGEM
        }
    }
}

public enum MSRStageStatus: String, Codable, Sendable {
    case pending
    case ready
    case degraded
    case blocked
    case failed
}

public enum MSRClinicianReviewStatus: String, Codable, Sendable {
    case unreviewed
    case inReview = "in_review"
    case reviewed
    case rejected
}

public struct MSRArtifactMetadata: Codable, Sendable, Equatable {
    public let stage: MSRStage
    public let sourceTranscriptRef: String
    public let stageVersion: String
    public let promptVersion: String
    public let modelProvider: String
    public let modelId: String?
    public let inputHash: String
    public let outputHash: String
    public let lawfulContextSummary: String
    public let clinicianReviewStatus: MSRClinicianReviewStatus
    public let limitations: [String]
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        stage: MSRStage,
        sourceTranscriptRef: String,
        stageVersion: String,
        promptVersion: String,
        modelProvider: String,
        modelId: String?,
        inputHash: String,
        outputHash: String,
        lawfulContextSummary: String,
        clinicianReviewStatus: MSRClinicianReviewStatus = .unreviewed,
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

public struct ASLArtifact: Codable, Sendable, Equatable {
    public let metadata: MSRArtifactMetadata
    public let linguisticSummary: String
    public let evidenceRefs: [String]

    public init(metadata: MSRArtifactMetadata, linguisticSummary: String, evidenceRefs: [String]) {
        self.metadata = metadata
        self.linguisticSummary = linguisticSummary
        self.evidenceRefs = evidenceRefs
    }
}

public struct VDLPArtifact: Codable, Sendable, Equatable {
    public let metadata: MSRArtifactMetadata
    public let dimensionalSummary: String
    public let dimensionRefs: [String]

    public init(metadata: MSRArtifactMetadata, dimensionalSummary: String, dimensionRefs: [String]) {
        self.metadata = metadata
        self.dimensionalSummary = dimensionalSummary
        self.dimensionRefs = dimensionRefs
    }
}

public struct GEMArtifact: Codable, Sendable, Equatable {
    public let metadata: MSRArtifactMetadata
    public let graphSummary: String
    public let layerRefs: [String]

    public init(metadata: MSRArtifactMetadata, graphSummary: String, layerRefs: [String]) {
        self.metadata = metadata
        self.graphSummary = graphSummary
        self.layerRefs = layerRefs
    }
}

public struct MSRStageExecutionState: Codable, Sendable, Equatable {
    public let stage: MSRStage
    public let status: MSRStageStatus
    public let artifactObjectPath: String?
    public let modelProvider: String?
    public let modelId: String?
    public let clinicianReviewStatus: MSRClinicianReviewStatus
    public let summary: String
    public let issueMessage: String?
    public let legalAuthorizing: Bool
    public let gateStillRequired: Bool

    public init(
        stage: MSRStage,
        status: MSRStageStatus,
        artifactObjectPath: String? = nil,
        modelProvider: String? = nil,
        modelId: String? = nil,
        clinicianReviewStatus: MSRClinicianReviewStatus = .unreviewed,
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

    public static func pending(_ stage: MSRStage) -> Self {
        .init(
            stage: stage,
            status: .pending,
            summary: "MSR stage has not run yet."
        )
    }
}

public struct MSRPersistedArtifact: Codable, Sendable {
    public let stage: MSRStage
    public let objectRef: StorageObjectRef
    public let metadata: MSRArtifactMetadata
    public let summary: String

    public init(
        stage: MSRStage,
        objectRef: StorageObjectRef,
        metadata: MSRArtifactMetadata,
        summary: String
    ) {
        self.stage = stage
        self.objectRef = objectRef
        self.metadata = metadata
        self.summary = summary
    }
}

public struct MSRRunArtifacts: Codable, Sendable {
    public let aslState: MSRStageExecutionState
    public let vdlpState: MSRStageExecutionState
    public let gemState: MSRStageExecutionState

    public init(
        aslState: MSRStageExecutionState = .pending(.asl),
        vdlpState: MSRStageExecutionState = .pending(.vdlp),
        gemState: MSRStageExecutionState = .pending(.gem)
    ) {
        self.aslState = aslState
        self.vdlpState = vdlpState
        self.gemState = gemState
    }

    public var stageStates: [MSRStageExecutionState] {
        [aslState, vdlpState, gemState]
    }
}

public enum MSRPipelineError: Error, LocalizedError, Equatable, Sendable {
    case aslRequired
    case vdlpRequired

    public var errorDescription: String? {
        switch self {
        case .aslRequired:
            return "VDLP requires a ready ASL artifact."
        case .vdlpRequired:
            return "GEM requires a ready VDLP artifact."
        }
    }
}

public struct MSRPipelineValidator {
    public static func validateCanRun(stage: MSRStage, state: MSRRunArtifacts) throws {
        switch stage {
        case .asl:
            return
        case .vdlp:
            guard state.aslState.status == .ready else {
                throw MSRPipelineError.aslRequired
            }
        case .gem:
            guard state.vdlpState.status == .ready else {
                throw MSRPipelineError.vdlpRequired
            }
        }
    }
}

public struct MSRRuntime: Codable, Sendable, Equatable {
    public let stages: [MSRStageExecutionState]
    public let activeStage: MSRStage?
    public let derivedArtifactsOnly: Bool
    public let clinicianReviewRequired: Bool
    public let legalAuthorizing: Bool
    public let summary: String

    public init(
        stages: [MSRStageExecutionState],
        activeStage: MSRStage? = nil,
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
            stages: MSRRunArtifacts().stageStates,
            summary: "MSR has not produced derived artifacts for this session."
        )
    }
}

public enum MSRContentHasher {
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
