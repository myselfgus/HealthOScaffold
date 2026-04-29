// VDLPExecutor — Vetores-Dimensão do Espaço-Campo Mental stage executor (scaffold)
//
// Wraps the VDLP prompt-engineered adapter. The 15-dimension framework (v₁–v₁₅) and all
// formulas live entirely in Prompts/vdlp-system.md — this file is dispatch and boundary only.
//
// Input contract:
//   patientId    — opaque identifier
//   aslData      — ASL JSON blob from ASLExecutor (must be ready, not degraded)
//   patientSpeech — filtered transcript (patient turns only; extracted from aslData
//                   at asl.transcricao_filtrada.fala_falante_completa)
//
// Output contract:
//   VDLP JSON blob: metadata + dimensoes_espaco_mental (v1–v15) + mapeamento_global
//   + validacao_cruzada + perfil_dimensional_integrativo
//   See Prompts/vdlp-system.md Part 3 for full schema.
//
// Chunking: split at 10k tokens (ASL + speech combined); ASL is a summary and stays whole;
//   only speech is split. First chunk scores are authoritative (derived from full ASL);
//   subsequent chunks contribute additional textual evidence only.
//   See Prompts/vdlp-system.md Implementation Notes.
//
// Dependency: requires a ready ASL artifact. Throws .upstreamNotReady if ASL is absent
//   or marked degraded — never falls through with partial input.
//
// Provider posture: same as ASL — remote only, explicit, lawful-context checked, provenance recorded.
//
// See: RT-MSR-001 in docs/execution/todo/runtimes-and-aaci.md

import Foundation
import HealthOSCore

// MARK: - Public API

public protocol VDLPExecuting: Sendable {
    func execute(patientId: String, aslData: Data, patientSpeech: String) async throws -> Data
}

// MARK: - Errors

public enum VDLPExecutorError: Error, Sendable {
    case upstreamNotReady
    case providerUnavailable
    case emptyPatientSpeech
    case invalidResponse(String)
    case chunkConsolidationFailed
}

// MARK: - Scaffold placeholder

/// Scaffold placeholder — replace body with real implementation in RT-MSR-001.
/// Do not call this in production paths; it always throws `.providerUnavailable`.
public struct VDLPExecutor: VDLPExecuting {

    public init() {}

    public func execute(patientId: String, aslData: Data, patientSpeech: String) async throws -> Data {
        guard !aslData.isEmpty else {
            throw VDLPExecutorError.upstreamNotReady
        }
        guard !patientSpeech.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw VDLPExecutorError.emptyPatientSpeech
        }
        // Scaffold: no provider wired. Fail closed.
        throw VDLPExecutorError.providerUnavailable
    }
}
