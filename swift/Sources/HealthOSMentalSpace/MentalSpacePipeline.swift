// HealthOSMentalSpace — Mental Space Runtime pipeline module (scaffold placeholder)
//
// This module is the future home for the MSR pipeline orchestrator and stage executors.
// It exists now to establish the module boundary before implementation begins.
//
// Current location of MSR code:
//   HealthOSCore/MentalSpaceRuntime.swift     — contracts, types, pipeline validator
//   HealthOSAACI/AACI.swift                   — normalization stage executor (local-first)
//
// This module will own (implement when each stage is built):
//   MentalSpacePipelineOrchestrator  — sequences stages, dispatches async jobs, exposes state view
//   ASLExecutor                      — wraps ASL prompt-engineered adapter (stage 2)
//   VDLPExecutor                     — wraps VDLP adapter (stage 3, requires ASL ready)
//   GEMArtifactBuilder               — wraps GEM graph construction (stage 4, requires VDLP ready)
//
// Migration path (start when ASL is implemented — see RT-MSR-001 in runtimes-and-aaci.md):
//   1. Add ASLExecutor here; wire HealthOSFirstSliceSupport to import HealthOSMentalSpace
//   2. Add MentalSpacePipelineOrchestrator to coordinate all stages
//   3. Normalization executor can stay in AACI or move here — decide at that point

import Foundation
import HealthOSCore

// Placeholder — replaced by real orchestrator in RT-MSR-001
public enum MentalSpacePipeline {
    public static let moduleVersion = "scaffold-placeholder-v1"
}
