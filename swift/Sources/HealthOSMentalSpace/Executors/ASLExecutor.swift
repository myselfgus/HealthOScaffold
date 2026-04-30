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
        do {
            return try MentalSpaceJSONRepair.parse(response)
        } catch {
            throw ASLExecutorError.invalidResponse("Provider did not return a valid JSON object")
        }
    }

    // Full field-aware consolidation matching the validated 4-asl.ts logic.
    // Each field uses the correct merge strategy (sum / weighted-average / concat / keep-first).
    private func consolidate(_ chunks: [[String: Any]]) -> [String: Any]? {
        guard let first = chunks.first else { return nil }
        if chunks.count == 1 { return first }
        var result = first
        for (idx, chunk) in chunks.dropFirst().enumerated() {
            aslMergeChunk(&result, chunk: chunk, chunkIndex: idx + 1)
        }
        return result
    }

    // swiftlint:disable:next function_body_length
    private func aslMergeChunk(_ base: inout [String: Any], chunk: [String: Any], chunkIndex i: Int) {
        func intVal(_ v: Any?) -> Int {
            if let x = v as? Int { return x }
            if let x = v as? Double { return Int(x) }
            return 0
        }
        func dblVal(_ v: Any?) -> Double {
            if let x = v as? Double { return x }
            if let x = v as? Int { return Double(x) }
            return 0.0
        }

        // 1. metadata — sum transcript-level counts
        if var bM = base["metadata"] as? [String: Any], let cM = chunk["metadata"] as? [String: Any] {
            bM["num_turnos_falante"]    = intVal(bM["num_turnos_falante"])    + intVal(cM["num_turnos_falante"])
            bM["total_palavras_falante"] = intVal(bM["total_palavras_falante"]) + intVal(cM["total_palavras_falante"])
            bM["total_sentencas_falante"] = intVal(bM["total_sentencas_falante"]) + intVal(cM["total_sentencas_falante"])
            base["metadata"] = bM
        }

        // 2. transcricao_filtrada — concat turns and full speech
        if var bTF = base["transcricao_filtrada"] as? [String: Any],
           let cTF = chunk["transcricao_filtrada"] as? [String: Any] {
            bTF["turnos_individuais"] = (bTF["turnos_individuais"] as? [Any] ?? []) + (cTF["turnos_individuais"] as? [Any] ?? [])
            let bFala = bTF["fala_falante_completa"] as? String ?? ""
            let cFala = cTF["fala_falante_completa"] as? String ?? ""
            bTF["fala_falante_completa"] = bFala.isEmpty ? cFala : (cFala.isEmpty ? bFala : bFala + "\n\n" + cFala)
            base["transcricao_filtrada"] = bTF
        }

        // 3. morfossintaxe — sum all quantitative counters
        if var bMorf = base["morfossintaxe"] as? [String: Any],
           let cMorf = chunk["morfossintaxe"] as? [String: Any] {
            // estrutura_sintatica.metricas_quantitativas.num_sentencas_total
            if var bES = bMorf["estrutura_sintatica"] as? [String: Any],
               let cES = cMorf["estrutura_sintatica"] as? [String: Any] {
                if var bMQ = bES["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cES["metricas_quantitativas"] as? [String: Any] {
                    bMQ["num_sentencas_total"] = intVal(bMQ["num_sentencas_total"]) + intVal(cMQ["num_sentencas_total"])
                    bES["metricas_quantitativas"] = bMQ
                }
                bMorf["estrutura_sintatica"] = bES
            }
            // classes_gramaticais.metricas_quantitativas.contagens_absolutas — sum all keys
            if var bCG = bMorf["classes_gramaticais"] as? [String: Any],
               let cCG = cMorf["classes_gramaticais"] as? [String: Any] {
                if var bMQ = bCG["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCG["metricas_quantitativas"] as? [String: Any] {
                    if var bCA = bMQ["contagens_absolutas"] as? [String: Any],
                       let cCA = cMQ["contagens_absolutas"] as? [String: Any] {
                        for key in cCA.keys { bCA[key] = intVal(bCA[key]) + intVal(cCA[key]) }
                        bMQ["contagens_absolutas"] = bCA
                    }
                    bCG["metricas_quantitativas"] = bMQ
                }
                bMorf["classes_gramaticais"] = bCG
            }
            // conjugacao_verbal.metricas_quantitativas.total_verbos
            if var bCV = bMorf["conjugacao_verbal"] as? [String: Any],
               let cCV = cMorf["conjugacao_verbal"] as? [String: Any] {
                if var bMQ = bCV["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCV["metricas_quantitativas"] as? [String: Any] {
                    bMQ["total_verbos"] = intVal(bMQ["total_verbos"]) + intVal(cMQ["total_verbos"])
                    bCV["metricas_quantitativas"] = bMQ
                }
                bMorf["conjugacao_verbal"] = bCV
            }
            // marcadores_morfologicos.metricas_quantitativas.pronomes_pessoais.{primeira,segunda,terceira}_pessoa.total
            if var bMM = bMorf["marcadores_morfologicos"] as? [String: Any],
               let cMM = cMorf["marcadores_morfologicos"] as? [String: Any] {
                if var bMQ = bMM["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cMM["metricas_quantitativas"] as? [String: Any] {
                    if var bPP = bMQ["pronomes_pessoais"] as? [String: Any],
                       let cPP = cMQ["pronomes_pessoais"] as? [String: Any] {
                        for person in ["primeira_pessoa", "segunda_pessoa", "terceira_pessoa"] {
                            if var bP = bPP[person] as? [String: Any], let cP = cPP[person] as? [String: Any] {
                                bP["total"] = intVal(bP["total"]) + intVal(cP["total"])
                                bPP[person] = bP
                            }
                        }
                        bMQ["pronomes_pessoais"] = bPP
                    }
                    bMM["metricas_quantitativas"] = bMQ
                }
                bMorf["marcadores_morfologicos"] = bMM
            }
            base["morfossintaxe"] = bMorf
        }

        // 4. semantica — mixed strategies per subcategory
        if var bSem = base["semantica"] as? [String: Any],
           let cSem = chunk["semantica"] as? [String: Any] {
            // diversidade_lexical: sum total_tokens + total_types
            if var bDL = bSem["diversidade_lexical"] as? [String: Any],
               let cDL = cSem["diversidade_lexical"] as? [String: Any] {
                if var bMQ = bDL["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cDL["metricas_quantitativas"] as? [String: Any] {
                    bMQ["total_tokens"] = intVal(bMQ["total_tokens"]) + intVal(cMQ["total_tokens"])
                    bMQ["total_types"]  = intVal(bMQ["total_types"])  + intVal(cMQ["total_types"])
                    bDL["metricas_quantitativas"] = bMQ
                }
                bSem["diversidade_lexical"] = bDL
            }
            // campos_semanticos.metricas_quantitativas.densidade_por_campo: weighted average per key
            if var bCS = bSem["campos_semanticos"] as? [String: Any],
               let cCS = cSem["campos_semanticos"] as? [String: Any] {
                if var bMQ = bCS["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCS["metricas_quantitativas"] as? [String: Any] {
                    if var bDPC = bMQ["densidade_por_campo"] as? [String: Any],
                       let cDPC = cMQ["densidade_por_campo"] as? [String: Any] {
                        for key in cDPC.keys {
                            bDPC[key] = (dblVal(bDPC[key]) * Double(i) + dblVal(cDPC[key])) / Double(i + 1)
                        }
                        bMQ["densidade_por_campo"] = bDPC
                    }
                    bCS["metricas_quantitativas"] = bMQ
                }
                bSem["campos_semanticos"] = bCS
            }
            // polaridade_emocional: concat palavras_positivas + palavras_negativas arrays
            if var bPE = bSem["polaridade_emocional"] as? [String: Any],
               let cPE = cSem["polaridade_emocional"] as? [String: Any] {
                if var bMQ = bPE["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cPE["metricas_quantitativas"] as? [String: Any] {
                    bMQ["palavras_positivas"] = (bMQ["palavras_positivas"] as? [Any] ?? []) + (cMQ["palavras_positivas"] as? [Any] ?? [])
                    bMQ["palavras_negativas"] = (bMQ["palavras_negativas"] as? [Any] ?? []) + (cMQ["palavras_negativas"] as? [Any] ?? [])
                    bPE["metricas_quantitativas"] = bMQ
                }
                bSem["polaridade_emocional"] = bPE
            }
            // densidade_conteudo: sum palavras_conteudo + palavras_funcao
            if var bDC = bSem["densidade_conteudo"] as? [String: Any],
               let cDC = cSem["densidade_conteudo"] as? [String: Any] {
                if var bMQ = bDC["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cDC["metricas_quantitativas"] as? [String: Any] {
                    bMQ["palavras_conteudo"] = intVal(bMQ["palavras_conteudo"]) + intVal(cMQ["palavras_conteudo"])
                    bMQ["palavras_funcao"]   = intVal(bMQ["palavras_funcao"])   + intVal(cMQ["palavras_funcao"])
                    bDC["metricas_quantitativas"] = bMQ
                }
                bSem["densidade_conteudo"] = bDC
            }
            base["semantica"] = bSem
        }

        // 5. coerencia_coesao — sum conectivos, weighted-average score_coerencia_global
        if var bCC = base["coerencia_coesao"] as? [String: Any],
           let cCC = chunk["coerencia_coesao"] as? [String: Any] {
            if var bCG = bCC["coesao_gramatical"] as? [String: Any],
               let cCG = cCC["coesao_gramatical"] as? [String: Any] {
                if var bMQ = bCG["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCG["metricas_quantitativas"] as? [String: Any] {
                    bMQ["total_conectivos"] = intVal(bMQ["total_conectivos"]) + intVal(cMQ["total_conectivos"])
                    bCG["metricas_quantitativas"] = bMQ
                }
                bCC["coesao_gramatical"] = bCG
            }
            if var bCT = bCC["coerencia_textual"] as? [String: Any],
               let cCT = cCC["coerencia_textual"] as? [String: Any] {
                if var bMQ = bCT["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCT["metricas_quantitativas"] as? [String: Any] {
                    bMQ["score_coerencia_global"] = (dblVal(bMQ["score_coerencia_global"]) * Double(i) + dblVal(cMQ["score_coerencia_global"])) / Double(i + 1)
                    bCT["metricas_quantitativas"] = bMQ
                }
                bCC["coerencia_textual"] = bCT
            }
            base["coerencia_coesao"] = bCC
        }

        // 6. pragmatica — sum act counts + modalization marker counts
        if var bPrag = base["pragmatica"] as? [String: Any],
           let cPrag = chunk["pragmatica"] as? [String: Any] {
            if var bAF = bPrag["atos_de_fala"] as? [String: Any],
               let cAF = cPrag["atos_de_fala"] as? [String: Any] {
                if var bMQ = bAF["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cAF["metricas_quantitativas"] as? [String: Any] {
                    for key in ["assertivos", "diretivos", "expressivos", "total"] {
                        bMQ[key] = intVal(bMQ[key]) + intVal(cMQ[key])
                    }
                    bAF["metricas_quantitativas"] = bMQ
                }
                bPrag["atos_de_fala"] = bAF
            }
            if var bMod = bPrag["modalizacao"] as? [String: Any],
               let cMod = cPrag["modalizacao"] as? [String: Any] {
                if var bMQ = bMod["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cMod["metricas_quantitativas"] as? [String: Any] {
                    for markerKey in ["marcadores_certeza", "marcadores_incerteza"] {
                        if var bMK = bMQ[markerKey] as? [String: Any], let cMK = cMQ[markerKey] as? [String: Any] {
                            bMK["count"] = intVal(bMK["count"]) + intVal(cMK["count"])
                            bMQ[markerKey] = bMK
                        }
                    }
                    bMod["metricas_quantitativas"] = bMQ
                }
                bPrag["modalizacao"] = bMod
            }
            base["pragmatica"] = bPrag
        }

        // 7. consistencia_temporal — sum passado/presente/futuro
        if var bCT = base["consistencia_temporal"] as? [String: Any],
           let cCT = chunk["consistencia_temporal"] as? [String: Any] {
            if var bMQ = bCT["metricas_quantitativas"] as? [String: Any],
               let cMQ = cCT["metricas_quantitativas"] as? [String: Any] {
                if var bDTR = bMQ["distribuicao_temporal_referencias"] as? [String: Any],
                   let cDTR = cMQ["distribuicao_temporal_referencias"] as? [String: Any] {
                    for key in ["passado", "presente", "futuro"] {
                        bDTR[key] = intVal(bDTR[key]) + intVal(cDTR[key])
                    }
                    bMQ["distribuicao_temporal_referencias"] = bDTR
                }
                bCT["metricas_quantitativas"] = bMQ
            }
            base["consistencia_temporal"] = bCT
        }

        // 8. fragmentacao_fluencia — sum disfluency counts
        if var bFF = base["fragmentacao_fluencia"] as? [String: Any],
           let cFF = chunk["fragmentacao_fluencia"] as? [String: Any] {
            if var bMQ = bFF["metricas_quantitativas"] as? [String: Any],
               let cMQ = cFF["metricas_quantitativas"] as? [String: Any] {
                if var bDisfl = bMQ["disfluencias"] as? [String: Any],
                   let cDisfl = cMQ["disfluencias"] as? [String: Any] {
                    for key in ["false_starts", "repeticoes_hesitantes", "autocorrecoes"] {
                        bDisfl[key] = intVal(bDisfl[key]) + intVal(cDisfl[key])
                    }
                    bMQ["disfluencias"] = bDisfl
                }
                bFF["metricas_quantitativas"] = bMQ
            }
            base["fragmentacao_fluencia"] = bFF
        }

        // 9. complexidade_densidade — sum palavras_unicas + proposicoes_estimadas
        if var bCD = base["complexidade_densidade"] as? [String: Any],
           let cCD = chunk["complexidade_densidade"] as? [String: Any] {
            if var bCL = bCD["complexidade_lexical"] as? [String: Any],
               let cCL = cCD["complexidade_lexical"] as? [String: Any] {
                if var bMQ = bCL["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cCL["metricas_quantitativas"] as? [String: Any] {
                    bMQ["palavras_unicas"] = intVal(bMQ["palavras_unicas"]) + intVal(cMQ["palavras_unicas"])
                    bCL["metricas_quantitativas"] = bMQ
                }
                bCD["complexidade_lexical"] = bCL
            }
            if var bDI = bCD["densidade_informacional"] as? [String: Any],
               let cDI = cCD["densidade_informacional"] as? [String: Any] {
                if var bMQ = bDI["metricas_quantitativas"] as? [String: Any],
                   let cMQ = cDI["metricas_quantitativas"] as? [String: Any] {
                    bMQ["proposicoes_estimadas"] = intVal(bMQ["proposicoes_estimadas"]) + intVal(cMQ["proposicoes_estimadas"])
                    bDI["metricas_quantitativas"] = bMQ
                }
                bCD["densidade_informacional"] = bDI
            }
            base["complexidade_densidade"] = bCD
        }

        // 10. caracteristicas_prosodicas_textuais — sum emphasis marker counts
        if var bCPT = base["caracteristicas_prosodicas_textuais"] as? [String: Any],
           let cCPT = chunk["caracteristicas_prosodicas_textuais"] as? [String: Any] {
            if var bMQ = bCPT["metricas_quantitativas"] as? [String: Any],
               let cMQ = cCPT["metricas_quantitativas"] as? [String: Any] {
                if var bME = bMQ["marcadores_enfase"] as? [String: Any],
                   let cME = cMQ["marcadores_enfase"] as? [String: Any] {
                    for key in ["maiusculas", "exclamacoes", "interrogacoes"] {
                        bME[key] = intVal(bME[key]) + intVal(cME[key])
                    }
                    bMQ["marcadores_enfase"] = bME
                }
                bCPT["metricas_quantitativas"] = bMQ
            }
            base["caracteristicas_prosodicas_textuais"] = bCPT
        }

        // contexto_identificado — keep first chunk (base already holds it)
        // sintese_interpretativa — keep first chunk (base already holds it)
    }

    private static func loadPromptTemplate() throws -> String {
        guard let url = Bundle.module.url(forResource: "asl-system", withExtension: "md", subdirectory: "Prompts") else {
            throw ASLExecutorError.invalidResponse("Missing ASL prompt template")
        }
        return try String(contentsOf: url, encoding: .utf8)
    }
}
