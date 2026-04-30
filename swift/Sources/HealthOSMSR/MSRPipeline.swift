import Foundation
import HealthOSCore

public struct MSROrchestrator: Sendable {
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
        state: MSRRunArtifacts
    ) async throws -> ASLExecutionResult {
        try MSRPipelineValidator.validateCanRun(stage: .asl, state: state)
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
        state: MSRRunArtifacts
    ) async throws -> VDLPExecutionResult {
        try MSRPipelineValidator.validateCanRun(stage: .vdlp, state: state)
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
        state: MSRRunArtifacts
    ) async throws -> GEMExecutionResult {
        try MSRPipelineValidator.validateCanRun(stage: .gem, state: state)
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

public enum MSRPipeline {
    public static let moduleVersion = "rt-msr-003"
}
