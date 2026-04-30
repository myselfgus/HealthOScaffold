import Foundation
import HealthOSCore
import HealthOSProviders

public struct VDLPExecutionResult: Sendable {
    public let artifact: VDLPArtifact
    public let provenanceOperation: String

    public init(artifact: VDLPArtifact, provenanceOperation: String = "mental-space.vdlp") {
        self.artifact = artifact
        self.provenanceOperation = provenanceOperation
    }
}

public protocol VDLPExecuting: Sendable {
    func execute(
        patientId: String,
        aslData: Data,
        patientSpeech: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> VDLPExecutionResult
}

public enum VDLPExecutorError: Error, Sendable, Equatable {
    case triadIncomplete
    case providerUnavailable
    case emptyPatientSpeech
    case invalidResponse(String)
    case chunkConsolidationFailed
}

public struct VDLPExecutor: VDLPExecuting {
    public static let chunkTokenThreshold = 10_000

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
        aslData: Data,
        patientSpeech: String,
        sourceTranscriptRef: String,
        lawfulContext: [String: String]
    ) async throws -> VDLPExecutionResult {
        guard !aslData.isEmpty else { throw VDLPExecutorError.triadIncomplete }
        let aslJSON = try parseProviderJSON(String(decoding: aslData, as: UTF8.self))
        guard isASLReady(aslJSON) else { throw VDLPExecutorError.triadIncomplete }
        let trimmedSpeech = patientSpeech.trimmingCharacters(in: .whitespacesAndNewlines)
        guard !trimmedSpeech.isEmpty else { throw VDLPExecutorError.emptyPatientSpeech }

        let request = ProviderRoutingRequest(taskClass: .languageModel, dataLayer: .derivedArtifacts, lawfulContext: lawfulContext, finalidade: "mental-space-vdlp", allowsRemoteFallback: true, fallbackAllowed: true, preferLocal: false)
        let decision = await router.routeLanguage(request: request)
        let selection: ProviderSelection
        switch decision {
        case .selected(let s), .degradedFallback(let s, _): selection = s
        case .stubOnly, .deniedByPolicy, .unavailable: throw VDLPExecutorError.providerUnavailable
        }
        guard let provider = await router.languageProvider(for: selection), !selection.isStub else { throw VDLPExecutorError.providerUnavailable }

        let speechChunks = chunkSpeech(trimmedSpeech)
        var chunkOutputs: [[String: Any]] = []
        for speechChunk in speechChunks {
            let prompt = buildPrompt(patientId: patientId, aslJSON: String(decoding: aslData, as: UTF8.self), patientSpeech: speechChunk)
            let response = try await provider.generate(prompt: prompt, context: ["task": "mental-space-vdlp", "model": model, "temperature": "0", "max_tokens": "60000", "anthropic-beta": "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11"])
            chunkOutputs.append(try parseProviderJSON(response))
        }

        guard let consolidated = consolidate(chunkOutputs) else { throw VDLPExecutorError.chunkConsolidationFailed }
        let dimensionRefs = (1...15).map { "v\($0)" }
        let dimensionKeys = Set((consolidated["dimensoes_espaco_mental"] as? [String: Any])?.keys.map { $0 } ?? [])
        guard Set(dimensionRefs).isSubset(of: dimensionKeys) else {
            throw VDLPExecutorError.invalidResponse("Missing one or more mental-space dimensions v1-v15")
        }

        let outputData = try JSONSerialization.data(withJSONObject: consolidated, options: [.sortedKeys])
        let artifact = VDLPArtifact(
            metadata: MentalSpaceArtifactMetadata(stage: .vdlp, sourceTranscriptRef: sourceTranscriptRef, stageVersion: "rt-msr-002", promptVersion: "vdlp-system.md", modelProvider: selection.providerId, modelId: provider.modelId ?? model, inputHash: MentalSpaceContentHasher.sha256Hex(for: trimmedSpeech), outputHash: MentalSpaceContentHasher.sha256Hex(for: String(decoding: outputData, as: UTF8.self)), lawfulContextSummary: lawfulContext["finalidade"] ?? "mental-space-vdlp", limitations: ["Derived artifact only", "Non-authorizing", "Gate required"]),
            dimensionalSummary: ((consolidated["perfil_dimensional_integrativo"] as? [String: Any])?["sintese_global"] as? String) ?? "VDLP dimensions available.",
            dimensionRefs: dimensionRefs
        )
        return VDLPExecutionResult(artifact: artifact)
    }

    private func isASLReady(_ aslJSON: [String: Any]) -> Bool {
        (aslJSON["sintese_interpretativa"] as? [String: Any]) != nil
    }

    private func chunkSpeech(_ speech: String) -> [String] {
        let words = speech.split(whereSeparator: \.isWhitespace)
        guard words.count > Self.chunkTokenThreshold else { return [speech] }
        var chunks: [String] = []
        var index = 0
        while index < words.count {
            let end = min(index + Self.chunkTokenThreshold, words.count)
            chunks.append(words[index..<end].joined(separator: " "))
            index = end
        }
        return chunks
    }

    private func buildPrompt(patientId: String, aslJSON: String, patientSpeech: String) -> String {
        promptTemplate
            .replacingOccurrences(of: "{{patientId}}", with: patientId)
            .replacingOccurrences(of: "{{aslData}}", with: aslJSON)
            .replacingOccurrences(of: "{{patientSpeech}}", with: patientSpeech)
    }

    private func parseProviderJSON(_ response: String) throws -> [String: Any] {
        do {
            return try MentalSpaceJSONRepair.parse(response)
        } catch {
            throw VDLPExecutorError.invalidResponse("Provider did not return a valid JSON object")
        }
    }

    // Full field-aware consolidation matching the validated 5-vdlp.ts logic.
    // Per dimension: concat evidencias_textuais, dedup componentes_asl_usados, keep first score.
    private func consolidate(_ chunks: [[String: Any]]) -> [String: Any]? {
        guard let first = chunks.first else { return nil }
        if chunks.count == 1 { return first }
        var result = first
        for chunk in chunks.dropFirst() {
            vdlpMergeChunk(&result, chunk: chunk)
        }
        return result
    }

    private func vdlpMergeChunk(_ base: inout [String: Any], chunk: [String: Any]) {
        // dimensoes_espaco_mental: per dimension key
        if var bDims = base["dimensoes_espaco_mental"] as? [String: Any],
           let cDims = chunk["dimensoes_espaco_mental"] as? [String: Any] {
            for key in bDims.keys {
                guard var bDim = bDims[key] as? [String: Any],
                      let cDim = cDims[key] as? [String: Any] else { continue }
                // evidencias_textuais: concatenate
                bDim["evidencias_textuais"] = (bDim["evidencias_textuais"] as? [Any] ?? []) + (cDim["evidencias_textuais"] as? [Any] ?? [])
                // componentes_asl_usados: concatenate preserving order, deduplicating
                var bComps = bDim["componentes_asl_usados"] as? [String] ?? []
                var seen = Set(bComps)
                for comp in cDim["componentes_asl_usados"] as? [String] ?? [] where seen.insert(comp).inserted {
                    bComps.append(comp)
                }
                bDim["componentes_asl_usados"] = bComps
                // score: keep first chunk value — the TS comment: "score já vem da ASL que é única e completa"
                bDims[key] = bDim
            }
            base["dimensoes_espaco_mental"] = bDims
        }

        // perfil_dimensional_integrativo.evidencias: ordered deduplicated concat
        if var bPDI = base["perfil_dimensional_integrativo"] as? [String: Any],
           let cPDI = chunk["perfil_dimensional_integrativo"] as? [String: Any] {
            var bEv = bPDI["evidencias"] as? [String] ?? []
            var seen = Set(bEv)
            for ev in cPDI["evidencias"] as? [String] ?? [] where seen.insert(ev).inserted {
                bEv.append(ev)
            }
            bPDI["evidencias"] = bEv
            base["perfil_dimensional_integrativo"] = bPDI
        }

        // All other top-level keys (sintese_global, etc.): keep first chunk value
    }

    private static func loadPromptTemplate() throws -> String {
        guard let url = Bundle.module.url(forResource: "vdlp-system", withExtension: "md", subdirectory: "Prompts") else {
            throw VDLPExecutorError.invalidResponse("Missing VDLP prompt template")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
