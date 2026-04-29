import Foundation
import HealthOSCore

public struct MentalSpacePipelineOrchestrator: Sendable {
    private let aslExecutor: any ASLExecuting
    private let vdlpExecutor: (any VDLPExecuting)?
    private let gemBuilder: (any GEMArtifactBuilding)?

    public init(aslExecutor: any ASLExecuting, vdlpExecutor: (any VDLPExecuting)? = nil, gemBuilder: (any GEMArtifactBuilding)? = nil) {
        self.aslExecutor = aslExecutor
        self.vdlpExecutor = vdlpExecutor
        self.gemBuilder = gemBuilder
    }

    public func runASL(
        patientId: String,
        normalizedTranscriptText: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String],
        state: MentalSpaceRunArtifacts
    ) async throws -> ASLExecutionResult {
        try MentalSpacePipelineValidator.validateCanRun(stage: .asl, state: state)
        return try await aslExecutor.execute(
            patientId: patientId,
            transcriptionText: normalizedTranscriptText,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
    }

    public func runVDLP(
        patientId: String,
        aslData: Data,
        patientSpeech: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String],
        state: MentalSpaceRunArtifacts
    ) async throws -> VDLPExecutionResult {
        try MentalSpacePipelineValidator.validateCanRun(stage: .vdlp, state: state)
        guard let vdlpExecutor else { throw VDLPExecutorError.providerUnavailable }
        return try await vdlpExecutor.execute(
            patientId: patientId,
            aslData: aslData,
            patientSpeech: patientSpeech,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
    }


    public func runGEM(
        patientId: String,
        normalizedTranscriptText: String,
        aslData: Data,
        vdlpData: Data,
        sourceTranscriptRef: String,
        lawfulContext: [String: String],
        state: MentalSpaceRunArtifacts
    ) async throws -> GEMExecutionResult {
        try MentalSpacePipelineValidator.validateCanRun(stage: .gem, state: state)
        guard let gemBuilder else { throw GEMArtifactBuilderError.providerUnavailable }
        return try await gemBuilder.execute(
            patientId: patientId,
            transcriptionText: normalizedTranscriptText,
            aslData: aslData,
            vdlpData: vdlpData,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
    }
}

public enum MentalSpacePipeline {
    public static let moduleVersion = "rt-msr-003"
}
