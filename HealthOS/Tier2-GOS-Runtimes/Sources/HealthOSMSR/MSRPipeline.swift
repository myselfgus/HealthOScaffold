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
        let logger = HealthOSTelemetry.logger(.mentalSpaceRuntime)
        let signposter = HealthOSTelemetry.signposter(.mentalSpaceRuntime)
        let interval = signposter.beginInterval("msr.asl")
        defer { signposter.endInterval("msr.asl", interval) }

        logger.info("MSR ASL execution requested")
        try MSRPipelineValidator.validateCanRun(stage: .asl, state: state)
        let result = try await aslExecutor.execute(
            patientId: patientId,
            transcriptionText: normalizedTranscriptText,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
        logger.info("MSR ASL execution completed")
        return result
    }

    public func runVDLP(
        patientId: String,
        aslData: Data,
        patientSpeech: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String],
        state: MSRRunArtifacts
    ) async throws -> VDLPExecutionResult {
        let logger = HealthOSTelemetry.logger(.mentalSpaceRuntime)
        let signposter = HealthOSTelemetry.signposter(.mentalSpaceRuntime)
        let interval = signposter.beginInterval("msr.vdlp")
        defer { signposter.endInterval("msr.vdlp", interval) }

        logger.info("MSR VDLP execution requested")
        try MSRPipelineValidator.validateCanRun(stage: .vdlp, state: state)
        guard let vdlpExecutor else { throw VDLPExecutorError.providerUnavailable }
        let result = try await vdlpExecutor.execute(
            patientId: patientId,
            aslData: aslData,
            patientSpeech: patientSpeech,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
        logger.info("MSR VDLP execution completed")
        return result
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
        let logger = HealthOSTelemetry.logger(.mentalSpaceRuntime)
        let signposter = HealthOSTelemetry.signposter(.mentalSpaceRuntime)
        let interval = signposter.beginInterval("msr.gem")
        defer { signposter.endInterval("msr.gem", interval) }

        logger.info("MSR GEM execution requested")
        try MSRPipelineValidator.validateCanRun(stage: .gem, state: state)
        guard let gemBuilder else { throw GEMArtifactBuilderError.providerUnavailable }
        let result = try await gemBuilder.execute(
            patientId: patientId,
            transcriptionText: normalizedTranscriptText,
            aslData: aslData,
            vdlpData: vdlpData,
            sourceTranscriptRef: sourceTranscriptRef,
            lawfulContext: lawfulContext
        )
        logger.info("MSR GEM execution completed")
        return result
    }
}

public enum MSRPipeline {
    public static let moduleVersion = "rt-msr-003"
}
