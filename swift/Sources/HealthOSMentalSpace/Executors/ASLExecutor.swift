import Foundation
import HealthOSCore
import HealthOSProviders

public struct ASLExecutionResult: Sendable {
    public let artifact: ASLArtifact
    public let provenanceOperation: String

    public init(artifact: ASLArtifact, provenanceOperation: String = "mental-space.asl") {
        self.artifact = artifact
        self.provenanceOperation = provenanceOperation
    }
}

public protocol ASLExecuting: Sendable {
    func execute(
        patientId: String,
        transcriptionText: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> ASLExecutionResult
}

public enum ASLExecutorError: Error, Sendable, Equatable {
    case providerUnavailable
    case emptyTranscription
    case invalidResponse(String)
    case chunkConsolidationFailed
}

public struct ASLExecutor: ASLExecuting {
    public static let chunkTokenThreshold = 10_000
    public static let maxParallelBatchSize = 3

    private let router: ProviderRouter
    private let promptTemplate: String
    private let model: String

    public init(router: ProviderRouter, useHaikuModel: Bool = false) throws {
        self.router = router
        self.promptTemplate = try ASLExecutor.loadPromptTemplate()
        self.model = useHaikuModel ? "claude-3-5-haiku-latest" : "claude-sonnet-4-20250514"
    }

    public func execute(
        patientId: String,
        transcriptionText: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> ASLExecutionResult {
        let trimmed = transcriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw ASLExecutorError.emptyTranscription }

        let request = ProviderRoutingRequest(
            taskClass: .languageModel,
            dataLayer: .derivedArtifacts,
            lawfulContext: lawfulContext,
            finalidade: "mental-space-asl",
            allowsRemoteFallback: true,
            fallbackAllowed: true,
            preferLocal: false
        )
        let decision = await router.routeLanguage(request: request)
        let selection: ProviderSelection
        switch decision {
        case .selected(let s), .degradedFallback(let s, _): selection = s
        case .stubOnly, .deniedByPolicy, .unavailable: throw ASLExecutorError.providerUnavailable
        }
        guard let provider = await router.languageProvider(for: selection), !selection.isStub else {
            throw ASLExecutorError.providerUnavailable
        }

        let chunks = chunk(transcript: trimmed)
        let rawResults = try await processChunks(chunks, patientId: patientId, provider: provider)
        guard let consolidated = consolidate(rawResults) else {
            throw ASLExecutorError.chunkConsolidationFailed
        }

        let outputData = try JSONSerialization.data(withJSONObject: consolidated, options: [.sortedKeys])
        let artifact = ASLArtifact(
            metadata: MentalSpaceArtifactMetadata(
                stage: .asl,
                sourceTranscriptRef: sourceTranscriptRef,
                stageVersion: "rt-msr-001",
                promptVersion: "asl-system.md",
                modelProvider: selection.providerId,
                modelId: provider.modelId ?? model,
                inputHash: MentalSpaceContentHasher.sha256Hex(for: trimmed),
                outputHash: MentalSpaceContentHasher.sha256Hex(for: String(data: outputData, encoding: .utf8) ?? ""),
                lawfulContextSummary: lawfulContext["finalidade"] ?? "mental-space-asl",
                limitations: ["Derived artifact only", "Non-authorizing", "Gate required"]
            ),
            linguisticSummary: (consolidated["sintese_interpretativa"] as? [String: Any])?["perfil_linguistico_geral"] as? String ?? "ASL synthesis available.",
            evidenceRefs: ((consolidated["sintese_interpretativa"] as? [String: Any])?["achados_mais_salientes"] as? [String]) ?? []
        )
        return ASLExecutionResult(artifact: artifact)
    }

    private func processChunks(
        _ chunks: [String],
        patientId: String,
        provider: any LanguageModelProvider
    ) async throws -> [[String: Any]] {
        var outputs: [[String: Any]] = []
        var index = 0
        while index < chunks.count {
            let batch = Array(chunks[index..<min(index + Self.maxParallelBatchSize, chunks.count)])
            let batchResponses = try await withThrowingTaskGroup(of: (Int, String).self) { group in
                for (offset, chunk) in batch.enumerated() {
                    group.addTask {
                        let prompt = self.buildPrompt(patientId: patientId, transcriptionText: chunk)
                        let response = try await provider.generate(prompt: prompt, context: [
                            "task": "mental-space-asl",
                            "model": self.model,
                            "temperature": "0",
                            "max_tokens": "60000",
                            "anthropic-beta": "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11"
                        ])
                        return (offset, response)
                    }
                }
                var responses = [String?](repeating: nil, count: batch.count)
                for try await (offset, response) in group { responses[offset] = response }
                return responses.compactMap { $0 }
            }
            for response in batchResponses {
                outputs.append(try parseProviderJSON(response))
            }
            index += Self.maxParallelBatchSize
        }
        return outputs
    }

    private func buildPrompt(patientId: String, transcriptionText: String) -> String {
        promptTemplate
            .replacingOccurrences(of: "{{patientId}}", with: patientId)
            .replacingOccurrences(of: "{{transcriptionText}}", with: transcriptionText)
    }

    private func chunk(transcript: String) -> [String] {
        let words = transcript.split(whereSeparator: \ .isWhitespace)
        if words.count <= Self.chunkTokenThreshold { return [transcript] }
        var result: [String] = []
        var start = 0
        while start < words.count {
            let end = min(start + Self.chunkTokenThreshold, words.count)
            result.append(words[start..<end].joined(separator: " "))
            start = end
        }
        return result
    }

    private func parseProviderJSON(_ response: String) throws -> [String: Any] {
        guard let data = response.data(using: .utf8),
              let json = try? JSONSerialization.jsonObject(with: data) as? [String: Any] else {
            throw ASLExecutorError.invalidResponse("Provider did not return a valid JSON object")
        }
        return json
    }

    private func consolidate(_ chunks: [[String: Any]]) -> [String: Any]? {
        guard let first = chunks.first else { return nil }
        if chunks.count == 1 { return first }
        var consolidated = first
        let summaries = chunks.compactMap {
            (($0["sintese_interpretativa"] as? [String: Any])?["perfil_linguistico_geral"] as? String)
        }
        let allEvidence = chunks.flatMap {
            (($0["sintese_interpretativa"] as? [String: Any])?["achados_mais_salientes"] as? [String]) ?? []
        }

        var synth = (consolidated["sintese_interpretativa"] as? [String: Any]) ?? [:]
        if !summaries.isEmpty { synth["perfil_linguistico_geral"] = summaries.joined(separator: "\n") }
        if !allEvidence.isEmpty { synth["achados_mais_salientes"] = allEvidence }
        consolidated["sintese_interpretativa"] = synth
        return consolidated
    }

    private static func loadPromptTemplate() throws -> String {
        guard let url = Bundle.module.url(forResource: "asl-system", withExtension: "md", subdirectory: "Prompts") else {
            throw ASLExecutorError.invalidResponse("Missing ASL prompt template")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
