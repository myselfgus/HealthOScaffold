import Foundation
import HealthOSCore

public struct MentalSpacePipelineOrchestrator: Sendable {
    private let aslExecutor: any ASLExecuting

    public init(aslExecutor: any ASLExecuting) {
        self.aslExecutor = aslExecutor
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
}

public enum MentalSpacePipeline {
    public static let moduleVersion = "rt-msr-001"
}
