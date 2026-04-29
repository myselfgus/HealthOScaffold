// ASLExecutor — Análise Sistêmica da Linguagem stage executor (scaffold)
//
// Wraps the ASL prompt-engineered adapter. The clinical logic lives entirely in
// Prompts/asl-system.md — this file is dispatch, provenance, and fail-closed boundary only.
//
// Input contract:
//   patientId        — opaque identifier (no direct PII in this layer)
//   transcriptionText — full raw transcript (all speakers)
//
// Output contract:
//   ASL JSON blob matching the 80+ field schema in Prompts/asl-system.md Part 2
//   Provenance record written by caller via HealthOSCore artifacts layer
//
// Chunking: split at 10k tokens; parallel batches of 3; consolidate by summing counts,
//   concatenating examples, averaging scores — see Prompts/asl-system.md Implementation Notes.
//
// Provider posture: remote only for this stage (no local model supports the 8-domain schema);
//   must be explicit, lawful-context checked, and provenance recorded.
//   Unavailable provider → throws ASLExecutorError.providerUnavailable (never silently degrades).
//
// See: RT-MSR-001 in docs/execution/todo/runtimes-and-aaci.md

import Foundation
import HealthOSCore

// MARK: - Public API

public protocol ASLExecuting: Sendable {
    func execute(patientId: String, transcriptionText: String) async throws -> Data
}

// MARK: - Errors

public enum ASLExecutorError: Error, Sendable {
    case providerUnavailable
    case emptyTranscription
    case invalidResponse(String)
    case chunkConsolidationFailed
}

// MARK: - Scaffold placeholder

/// Scaffold placeholder — replace body with real implementation in RT-MSR-001.
/// Do not call this in production paths; it always throws `.providerUnavailable`.
public struct ASLExecutor: ASLExecuting {

    public init() {}

    public func execute(patientId: String, transcriptionText: String) async throws -> Data {
        guard !transcriptionText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw ASLExecutorError.emptyTranscription
        }
        // Scaffold: no provider wired. Fail closed.
        throw ASLExecutorError.providerUnavailable
    }
}
