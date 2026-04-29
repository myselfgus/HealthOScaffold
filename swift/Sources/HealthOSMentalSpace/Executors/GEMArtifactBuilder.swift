// GEMArtifactBuilder — Grafo do Espaço-Campo Mental stage executor (scaffold)
//
// Wraps the GEM prompt-engineered adapter. The 4-layer graph architecture (.aje, .ire, .e, .epe)
// and theoretical foundation (Leibniz, Wittgenstein, Spinoza, Euler, Deleuze) live entirely in
// Prompts/gem-system.md — this file is dispatch, triad validation, and provenance boundary only.
//
// Input contract (triad — all three required, none optional):
//   transcriptionText — full normalized transcript
//   aslData           — ASL JSON blob from ASLExecutor (ready)
//   vdlpData          — VDLP JSON blob from VDLPExecutor (ready)
//
// Output contract:
//   GEM JSON blob: gem (.aje, .ire, .e, .epe) + statistics + cross_references
//   + key_insights (5 strings) + validation_score (float)
//   Validation thresholds (enforced by prompt, verified here):
//     global coherence >0.85 | .aje coherence >0.8 | .ire density >0.75 | .e causal_strength >0.8
//   See Prompts/gem-system.md for full schema and alignment requirements.
//
// Chunking: threshold 50k tokens (combined input); split transcription only (ASL+VDLP are
//   summaries and stay whole). Chunk consolidation: concatenate .aje, .ire, .e, .epe arrays.
//   See Prompts/gem-system.md Implementation Notes.
//
// Dependency: requires ready transcript + ASL + VDLP triad. Any missing upstream artifact
//   throws .triadIncomplete — the GEM is meaningless without all three inputs.
//
// Temperature: 0.2 (unlike ASL/VDLP which use 0; slight variation needed for graph construction).
//
// Provider posture: remote only, explicit, lawful-context checked, provenance recorded.
//
// See: RT-MSR-001 in docs/execution/todo/runtimes-and-aaci.md

import Foundation
import HealthOSCore

// MARK: - Public API

public protocol GEMArtifactBuilding: Sendable {
    func build(
        transcriptionText: String,
        aslData: Data,
        vdlpData: Data
    ) async throws -> Data
}

// MARK: - Errors

public enum GEMArtifactBuilderError: Error, Sendable {
    case triadIncomplete(missing: String)
    case providerUnavailable
    case validationScoreBelowThreshold(Double)
    case invalidResponse(String)
    case chunkConsolidationFailed
}

// MARK: - Scaffold placeholder

/// Scaffold placeholder — replace body with real implementation in RT-MSR-001.
/// Do not call this in production paths; it always throws `.providerUnavailable`.
public struct GEMArtifactBuilder: GEMArtifactBuilding {

    public init() {}

    public func build(
        transcriptionText: String,
        aslData: Data,
        vdlpData: Data
    ) async throws -> Data {
        if transcriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            throw GEMArtifactBuilderError.triadIncomplete(missing: "transcription")
        }
        if aslData.isEmpty {
            throw GEMArtifactBuilderError.triadIncomplete(missing: "asl")
        }
        if vdlpData.isEmpty {
            throw GEMArtifactBuilderError.triadIncomplete(missing: "vdlp")
        }
        // Scaffold: no provider wired. Fail closed.
        throw GEMArtifactBuilderError.providerUnavailable
    }
}
