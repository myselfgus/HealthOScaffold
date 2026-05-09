# Skill: Xcode Developer Toolchain

## Overview
Use this skill when validating HealthOS build quality, performance, accessibility, or ML assets
using the Xcode Developer Tool suite (Xcode > Open Developer Tool).
Each tool has a defined role in the HealthOS validation lifecycle — read the relevant section
before making production-readiness claims.

---

## Instruments

**When to use:** Before any performance or memory claim on `HealthOSSessionRuntime`, `HealthOSCLI`,
or any Stage executable. Required gating criterion before RC declaration.

**HealthOS targets to profile:**
- `HealthOSSessionRuntime` — session pipeline latency, transcript normalization throughput
- `HealthOSCLI` — CLI command overhead, GOS bundle lifecycle timing
- `Scribe` — main-thread rendering, audio capture memory
- `Veridia` — identity session memory footprint
- `CloudClinic` — service-operations session startup time

**Instruments templates to use:**
- **Time Profiler** — CPU hotspots in session pipeline and MSR (ASL→VDLP→GEM)
- **Allocations** — heap growth during long sessions, verify no leak in provenance chain
- **Leaks** — retention cycles in actor model
- **SwiftUI** (if UI shell is active) — view body invalidation storms

**Workflow:**
1. `Product > Profile` (⌘I) on the target scheme
2. Choose template above
3. Run the smoke path: `--smoke-test` or `--smoke-test-audio`
4. Record baseline; annotate deviations > 20% as regression candidates

---

## Simulator

**When to use:** Smoke-testing Stage executables before committing without physical hardware.
Simulator does not replace device validation for audio capture (AVAudioSession) — use
stub/mock audio paths in Simulator runs.

**Standard smoke invocations via Simulator:**
```bash
cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test
cd HealthOS/Tier4-Stages-Cast/Veridia && swift run Veridia --smoke-test
cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift run CloudClinic --smoke-test
```

**Constraints:**
- Apple Foundation Models may not be available on all Simulator configurations; stub
  providers will activate automatically (fail-closed).
- Audio capture (`--smoke-test-audio`) requires a real device or a virtual audio device
  configured in Simulator settings.

---

## Accessibility Inspector

**When to use:** Any time a SwiftUI view is added or modified in a Stage UI shell.
Accessibility validation is a hard criterion in the Scaffold Release Candidate checklist
(`HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`).

**HealthOS surfaces to validate:**
- `ScribeFirstSliceView` — session start/stop controls, transcript display
- Veridia patient-identity surfaces (when UI shell is implemented)
- CloudClinic service-operations surfaces (when UI shell is implemented)

**Workflow:**
1. Run app in Simulator or on device
2. Open Accessibility Inspector (Xcode > Open Developer Tool > Accessibility Inspector)
3. Point at target app; verify: label, hint, trait, value for all interactive elements
4. Run Audit (⌘F7) — zero errors required before RC

---

## Create ML

**When to use:** If HealthOS introduces a locally-trained model for transcript normalization
or clinical classification that supplements or replaces the Apple Foundation Models adapter.

**Current status:** Not yet used. `HealthOSProviders/AppleFoundationModelsAdapter.swift`
is the primary inference path; stub providers cover unavailable cases.

**Future scope (when relevant):**
- Train a Create ML text classifier for ASL intent tagging (Tier 2, MSR pipeline)
- Export `.mlmodel` → bundle in `HealthOSProviders` or `HealthOSMSR`
- Gate behind `ModelGovernance` — no model ships without explicit operator approval
- Remote training is not permitted; on-device / local-machine training only

**Constraint:** Any model trained with Create ML must pass the same provenance and
governance checks as Foundation Models output. Do not bypass `ModelGovernance`.

---

## Reality Composer Pro

**When to use:** Only if a visionOS surface is added to HealthOS (no current plan).
No Reality Composer Pro assets are committed to this repository.

**If a visionOS surface appears:**
- Scope is Stage UI only
- Any 3D health content must obey the same de-identification rules as 2D surfaces
- Consult `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md` before adding

---

## Icon Composer

**When to use:** Creating or updating app icons for `Scribe`,
`Veridia`, or `CloudClinic`.

**Notes:**
- Icons are cosmetic; do not block any implementation task on icon completion
- Use Icon Composer to produce the `.icns` / asset catalog from a source vector
- Place outputs in `HealthOS/Tier4-Stages-Cast/<Stage>/Sources/<AppTarget>/Resources/Assets.xcassets/`
- Icons must not contain real patient imagery, clinical data, or regulated symbols
