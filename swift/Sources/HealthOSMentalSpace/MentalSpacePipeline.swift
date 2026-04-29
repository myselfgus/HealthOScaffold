// MentalSpacePipeline — Mental Space Runtime module root (scaffold)
//
// Module layout:
//   Prompts/
//     asl-system.md       — ASL clinical prompts (validated, 400 patients)
//     vdlp-system.md      — VDLP 15-dimension prompts (validated, 400 patients)
//     gem-system.md       — GEM 4-layer graph prompts (validated, 400 patients)
//   Executors/
//     ASLExecutor.swift   — dispatch boundary for stage 2
//     VDLPExecutor.swift  — dispatch boundary for stage 3 (requires ASL)
//     GEMArtifactBuilder.swift — dispatch boundary for stage 4 (requires triad)
//
// Stage order (fixed; each stage fails closed when upstream is missing):
//   1. Normalization  — HealthOSAACI (local-first; already executable)
//   2. ASL            — ASLExecutor  (scaffold placeholder; remote provider)
//   3. VDLP           — VDLPExecutor (scaffold placeholder; requires ASL)
//   4. GEM            — GEMArtifactBuilder (scaffold placeholder; requires triad)
//
// Prompt files are the clinical contracts — do not alter their content without
// re-validation against clinical cohort data. Swift files are dispatch and provenance only.
//
// Implementation: RT-MSR-001 in docs/execution/todo/runtimes-and-aaci.md

import Foundation
import HealthOSCore

// Replaced by MentalSpacePipelineOrchestrator in RT-MSR-001
public enum MentalSpacePipeline {
    public static let moduleVersion = "scaffold-placeholder-v1"
}
