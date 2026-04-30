import Foundation
import HealthOSCore
import HealthOSProviders

public struct GEMExecutionResult: Sendable {
    public let artifact: GEMArtifact
    public let provenanceOperation: String

    public init(artifact: GEMArtifact, provenanceOperation: String = "mental-space.gem") {
        self.artifact = artifact
        self.provenanceOperation = provenanceOperation
    }
}

public protocol GEMArtifactBuilding: Sendable {
    func execute(
        patientId: String,
        transcriptionText: String,
        aslData: Data,
        vdlpData: Data,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> GEMExecutionResult
}

public enum GEMArtifactBuilderError: Error, Sendable, Equatable {
    case triadIncomplete(missing: String)
    case providerUnavailable
    case emptyTranscription
    case degradedDependency(String)
    case invalidResponse(String)
    case chunkConsolidationFailed
}

public struct GEMArtifactBuilder: GEMArtifactBuilding {
    public static let chunkTokenThreshold = 50_000

    private let router: ProviderRouter
    private let promptTemplate: String
    private let model: String

    public init(router: ProviderRouter, useHaikuModel: Bool = false) throws {
        self.router = router
        self.promptTemplate = try Self.loadPromptTemplate()
        self.model = useHaikuModel ? "claude-3-5-haiku-latest" : "claude-sonnet-4-20250514"
    }

    public func execute(
        patientId: String,
        transcriptionText: String,
        aslData: Data,
        vdlpData: Data,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> GEMExecutionResult {
        let trimmed = transcriptionText.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmed.isEmpty else { throw GEMArtifactBuilderError.emptyTranscription }
        guard !aslData.isEmpty else { throw GEMArtifactBuilderError.triadIncomplete(missing: "asl") }
        guard !vdlpData.isEmpty else { throw GEMArtifactBuilderError.triadIncomplete(missing: "vdlp") }

        let aslJSON = try parseProviderJSON(String(decoding: aslData, as: UTF8.self))
        guard (aslJSON["sintese_interpretativa"] as? [String: Any]) != nil else {
            throw GEMArtifactBuilderError.degradedDependency("ASL artifact missing sintese_interpretativa")
        }

        let vdlpJSON = try parseProviderJSON(String(decoding: vdlpData, as: UTF8.self))
        guard (vdlpJSON["dimensoes_espaco_mental"] as? [String: Any]) != nil else {
            throw GEMArtifactBuilderError.degradedDependency("VDLP artifact missing dimensoes_espaco_mental")
        }

        let request = ProviderRoutingRequest(taskClass: .languageModel, dataLayer: .derivedArtifacts, lawfulContext: lawfulContext, finalidade: "mental-space-gem", allowsRemoteFallback: true, fallbackAllowed: true, preferLocal: false)
        let decision = await router.routeLanguage(request: request)
        let selection: ProviderSelection
        switch decision {
        case .selected(let s), .degradedFallback(let s, _): selection = s
        case .stubOnly, .deniedByPolicy, .unavailable: throw GEMArtifactBuilderError.providerUnavailable
        }
        guard let provider = await router.languageProvider(for: selection), !selection.isStub else {
            throw GEMArtifactBuilderError.providerUnavailable
        }

        let chunks = chunk(transcript: trimmed)
        var outputs: [[String: Any]] = []
        for chunk in chunks {
            let prompt = buildPrompt(patientId: patientId, transcriptionText: chunk, aslData: String(decoding: aslData, as: UTF8.self), vdlpData: String(decoding: vdlpData, as: UTF8.self))
            let response = try await provider.generate(prompt: prompt, context: [
                "task": "mental-space-gem",
                "model": model,
                "temperature": "0.2",
                "max_tokens": "60000",
                "anthropic-beta": "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11"
            ])
            outputs.append(try parseProviderJSON(response))
        }

        guard let consolidated = consolidate(outputs) else { throw GEMArtifactBuilderError.chunkConsolidationFailed }
        let layers = ["aje", "ire", "e", "epe"]
        let gem = (consolidated["gem"] as? [String: Any]) ?? consolidated
        for layer in layers {
            guard gem[layer] != nil else { throw GEMArtifactBuilderError.invalidResponse("Missing GEM layer: \(layer)") }
        }

        let outputData = try JSONSerialization.data(withJSONObject: consolidated, options: [.sortedKeys])
        let artifact = GEMArtifact(
            metadata: MentalSpaceArtifactMetadata(stage: .gem, sourceTranscriptRef: sourceTranscriptRef, stageVersion: "rt-msr-003", promptVersion: "gem-system.md", modelProvider: selection.providerId, modelId: provider.modelId ?? model, inputHash: MentalSpaceContentHasher.sha256Hex(for: trimmed), outputHash: MentalSpaceContentHasher.sha256Hex(for: String(decoding: outputData, as: UTF8.self)), lawfulContextSummary: lawfulContext["finalidade"] ?? "mental-space-gem", limitations: ["Derived artifact only", "Non-authorizing", "Gate required"]),
            graphSummary: ((consolidated["statistics"] as? [String: Any])?["global_summary"] as? String) ?? "GEM graph available.",
            layerRefs: layers
        )
        return GEMExecutionResult(artifact: artifact)
    }

    private func chunk(transcript: String) -> [String] {
        let words = transcript.split(whereSeparator: \.isWhitespace)
        guard words.count > Self.chunkTokenThreshold else { return [transcript] }
        var result: [String] = []
        var idx = 0
        while idx < words.count {
            let end = min(idx + Self.chunkTokenThreshold, words.count)
            result.append(words[idx..<end].joined(separator: " "))
            idx = end
        }
        return result
    }

    private func buildPrompt(patientId: String, transcriptionText: String, aslData: String, vdlpData: String) -> String {
        promptTemplate
            .replacingOccurrences(of: "{{patientId}}", with: patientId)
            .replacingOccurrences(of: "{{transcriptionText}}", with: transcriptionText)
            .replacingOccurrences(of: "{{aslData}}", with: aslData)
            .replacingOccurrences(of: "{{vdlpData}}", with: vdlpData)
    }

    private func parseProviderJSON(_ response: String) throws -> [String: Any] {
        do {
            return try MentalSpaceJSONRepair.parse(response)
        } catch {
            throw GEMArtifactBuilderError.invalidResponse("Provider did not return a valid JSON object")
        }
    }

    // Full field-aware consolidation matching the validated 6-gem.ts logic.
    // Concatenates .aje/.ire/.e/.epe arrays across chunks; handles gem nested or at root.
    private func consolidate(_ chunks: [[String: Any]]) -> [String: Any]? {
        guard let first = chunks.first else { return nil }
        if chunks.count == 1 { return first }
        var result = first
        for chunk in chunks.dropFirst() {
            gemMergeChunk(&result, chunk: chunk)
        }
        return result
    }

    private func gemMergeChunk(_ base: inout [String: Any], chunk: [String: Any]) {
        let isNested = base["gem"] != nil
        var bGem = (base["gem"] as? [String: Any]) ?? base
        let cGem = (chunk["gem"] as? [String: Any]) ?? chunk

        for layer in ["aje", "ire", "e", "epe"] {
            bGem[layer] = (bGem[layer] as? [Any] ?? []) + (cGem[layer] as? [Any] ?? [])
        }

        if isNested {
            base["gem"] = bGem
        } else {
            for layer in ["aje", "ire", "e", "epe"] { base[layer] = bGem[layer] }
        }
    }

    private static func loadPromptTemplate() throws -> String {
        guard let url = Bundle.module.url(forResource: "gem-system", withExtension: "md", subdirectory: "Prompts") else {
            throw GEMArtifactBuilderError.invalidResponse("Missing GEM prompt template")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
