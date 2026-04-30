import Foundation
import HealthOSCore
import HealthOSProviders

public protocol TranscriptNormalizationExecuting: Sendable {
    func execute(_ request: TranscriptNormalizationRequest) async -> TranscriptNormalizationResult
}

public struct TranscriptNormalizationExecutor: TranscriptNormalizationExecuting {
    private let router: ProviderRouter

    public init(router: ProviderRouter) {
        self.router = router
    }

    public func execute(_ request: TranscriptNormalizationRequest) async -> TranscriptNormalizationResult {
        let routingRequest = ProviderRoutingRequest(
            taskClass: .languageModel,
            dataLayer: .derivedArtifacts,
            lawfulContext: request.lawfulContext,
            finalidade: "session-transcript-normalization",
            allowsRemoteFallback: false,
            fallbackAllowed: true,
            preferLocal: true
        )
        let decision = await router.routeLanguage(request: routingRequest)

        switch decision {
        case .deniedByPolicy(let reason):
            return TranscriptNormalizationResult(
                status: .degraded,
                correctionSummary: "Transcript normalization was not run because provider routing denied the request.",
                providerExecution: ProviderExecutionMetadata(
                    providerId: "none",
                    providerKind: "none",
                    taskClass: routingRequest.taskClass.rawValue,
                    status: ProviderExecutionStatus.denied.rawValue,
                    isStub: false,
                    reason: reason.rawValue
                ),
                issueMessage: "Transcript normalization denied by provider policy: \(reason.rawValue)."
            )
        case .unavailable(let reason):
            return TranscriptNormalizationResult(
                status: .degraded,
                correctionSummary: "Transcript normalization was not run because no local language model provider was available.",
                providerExecution: ProviderExecutionMetadata(
                    providerId: "none",
                    providerKind: "none",
                    taskClass: routingRequest.taskClass.rawValue,
                    status: ProviderExecutionStatus.unavailable.rawValue,
                    isStub: false,
                    reason: reason.rawValue
                ),
                issueMessage: "Transcript normalization unavailable: \(reason.rawValue)."
            )
        case .stubOnly(let selection, let reason):
            return TranscriptNormalizationResult(
                status: .degraded,
                correctionSummary: "Transcript normalization requires a real local model; stub provider output was not used.",
                providerExecution: ProviderExecutionMetadata(
                    providerId: selection.providerId,
                    providerKind: selection.providerKind.rawValue,
                    taskClass: selection.taskClass.rawValue,
                    status: ProviderExecutionStatus.stubOnly.rawValue,
                    modelId: selection.modelId,
                    modelVersion: selection.modelVersion,
                    isStub: true,
                    reason: reason.rawValue
                ),
                issueMessage: "Only a stub local model is available for transcript normalization."
            )
        case .selected(let selection), .degradedFallback(let selection, _):
            guard selection.providerKind != .remote else {
                return TranscriptNormalizationResult(
                    status: .degraded,
                    correctionSummary: "Transcript normalization refused remote execution in v1.",
                    providerExecution: ProviderExecutionMetadata(
                        providerId: selection.providerId,
                        providerKind: selection.providerKind.rawValue,
                        taskClass: selection.taskClass.rawValue,
                        status: ProviderExecutionStatus.denied.rawValue,
                        modelId: selection.modelId,
                        modelVersion: selection.modelVersion,
                        isStub: selection.isStub,
                        reason: ProviderSafetyDenialReason.remotePolicyMissing.rawValue
                    ),
                    issueMessage: "Remote provider fallback is not allowed for transcript normalization."
                )
            }
            guard let provider = await router.languageProvider(for: selection), !selection.isStub else {
                return TranscriptNormalizationResult(
                    status: .degraded,
                    correctionSummary: "Transcript normalization requires a real local model; selected provider was unavailable or stub-only.",
                    providerExecution: ProviderExecutionMetadata(
                        providerId: selection.providerId,
                        providerKind: selection.providerKind.rawValue,
                        taskClass: selection.taskClass.rawValue,
                        status: ProviderExecutionStatus.stubOnly.rawValue,
                        modelId: selection.modelId,
                        modelVersion: selection.modelVersion,
                        isStub: selection.isStub,
                        reason: ProviderSafetyDenialReason.noRealProviderAvailable.rawValue
                    ),
                    issueMessage: "Selected transcript normalization provider was not a real local provider."
                )
            }

            do {
                let normalized = try await provider.generate(
                    prompt: request.transcriptText,
                    context: [
                        "task": "session-transcript-normalization",
                        "promptVersion": "transcript-normalization-v1",
                        "sourceTranscriptHash": request.sourceTranscriptRef.contentHash
                    ]
                )
                let normalizedText = normalized.trimmingCharacters(in: .whitespacesAndNewlines)
                guard !normalizedText.isEmpty else {
                    return TranscriptNormalizationResult(
                        status: .degraded,
                        correctionSummary: "Transcript normalization provider returned empty output.",
                        providerExecution: ProviderExecutionMetadata(
                            providerId: selection.providerId,
                            providerKind: selection.providerKind.rawValue,
                            taskClass: selection.taskClass.rawValue,
                            status: ProviderExecutionStatus.degraded.rawValue,
                            modelId: selection.modelId,
                            modelVersion: selection.modelVersion,
                            isStub: false,
                            reason: "empty-normalization-output"
                        ),
                        issueMessage: "Transcript normalization returned no usable text."
                    )
                }
                return TranscriptNormalizationResult(
                    status: .ready,
                    normalizedText: normalizedText,
                    correctionSummary: "Transcript normalized by a local language model; clinician review remains required before downstream MSR analysis.",
                    providerExecution: ProviderExecutionMetadata(
                        providerId: selection.providerId,
                        providerKind: selection.providerKind.rawValue,
                        taskClass: selection.taskClass.rawValue,
                        status: ProviderExecutionStatus.selected.rawValue,
                        modelId: selection.modelId,
                        modelVersion: selection.modelVersion,
                        isStub: false,
                        reason: "local-transcript-normalization"
                    )
                )
            } catch {
                return TranscriptNormalizationResult(
                    status: .degraded,
                    correctionSummary: "Transcript normalization failed during local model execution.",
                    providerExecution: ProviderExecutionMetadata(
                        providerId: selection.providerId,
                        providerKind: selection.providerKind.rawValue,
                        taskClass: selection.taskClass.rawValue,
                        status: ProviderExecutionStatus.degraded.rawValue,
                        modelId: selection.modelId,
                        modelVersion: selection.modelVersion,
                        isStub: false,
                        reason: "normalization-execution-error"
                    ),
                    issueMessage: "Transcript normalization failed: \(error.localizedDescription)"
                )
            }
        }
    }
}
