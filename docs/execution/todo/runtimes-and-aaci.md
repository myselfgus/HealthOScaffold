# TODO — Runtimes and AACI

## COMPLETED

### RT-005 Refine sovereignty/privacy/topology vocabulary for runtime-facing doctrine
Outcome:
- patient sovereignty language aligned to governance/control instead of physical byte custody claims
- data-layer and overview docs aligned with lawfulContext, pseudonymization, and online-only mesh posture
Files touched:
- `docs/architecture/01-overview.md`
- `docs/architecture/05-data-layers.md`
- `docs/architecture/10-app-state-model.md`

### RT-001 Formalize actor vs agent model
Outcome:
- actor/agent distinction formalized in architecture and reflected in Swift/TypeScript contracts
Files touched:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `swift/Sources/HealthOSCore/ActorModel.swift`
- `ts/packages/contracts/src/index.ts`

### RT-002 Define runtime lifecycle contract
Outcome:
- runtime lifecycle states and failure categories formalized in docs, schemas, Swift, and TypeScript
Files touched:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `schemas/contracts/runtime-lifecycle.schema.json`
- `swift/Sources/HealthOSCore/ActorModel.swift`
- `ts/packages/contracts/src/index.ts`

### AACI-001 Expand AACI session model
Outcome:
- session modes documented with bounded meaning and explicit authorization caveat
Files touched:
- `docs/architecture/09-aaci.md`

### AACI-002 Define hot / warm / cold path routing
Outcome:
- path classes documented and baseline task allocation defined
Files touched:
- `docs/architecture/09-aaci.md`

### AACI-003 Specify subagent boundaries
Outcome:
- subagent boundaries defined in architecture and reflected in Swift descriptors for the initial subagent set
Files touched:
- `docs/architecture/09-aaci.md`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `schemas/contracts/agent-boundary.schema.json`
- `schemas/contracts/agent-descriptor.schema.json`

### RT-003 Decide retry envelope and backpressure policy by runtime
Outcome:
- runtime operational policy added covering degradation, retry, backpressure, and failure visibility across AACI hot/warm paths, async runtime, and user-agent runtime
Files touched:
- `docs/architecture/20-runtime-operational-policy.md`

### AACI-004 Define provider-routing policy per task class
Outcome:
- provider routing baseline defined by task class, privacy mode, and fallback policy
Files touched:
- `docs/architecture/16-providers-and-ml.md`

### RT-004 Define runtime status surfaces for apps/interfaces
Outcome:
- runtime/app state doctrine is now consumable by executable first-slice contracts via typed run summary and Scribe bridge state surface
Files touched:
- `docs/architecture/10-app-state-model.md`
- `docs/architecture/22-runtime-state-surfaces.md`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`

### AACI-005 Add minimal local-first audio capture/transcription path to the executable slice
Outcome:
- AACI/first-slice execution now accepts seeded text or a local audio file reference
- local audio is persisted before transcription so provenance and storage evidence remain explicit even when transcription is degraded
- retrieval and draft composition now degrade honestly when transcription yields no searchable text
Files touched:
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSProviders/ProviderProtocols.swift`
- `swift/Sources/HealthOSProviders/StubProviders.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceDemoBootstrap.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `docs/architecture/09-aaci.md`
- `docs/architecture/28-first-slice-executable-path.md`

### AACI-006 Strengthen local clinical-operational retrieval assembly for the first slice
Outcome:
- bounded retrieval remains local/file-backed but now uses deterministic lexical/tag/recency/category/intent scoring with explicit score breakdown
- AACI consumes a structured context package with summary, highlights, supporting snippets, provenance hints, and explicit `ready` / `partial` / `empty` / `degraded` truth
- degraded retrieval remains honest when transcription is weak or absent, without widening scope or inventing context
Files touched:
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/FirstSliceServices.swift`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `docs/architecture/09-aaci.md`
- `docs/architecture/28-first-slice-executable-path.md`

### AACI-007 Materialize referral and prescription draft derivatives in the first slice
Outcome:
- AACI now materializes typed referral and prescription drafts from the same session/SOAP/context spine
- both derivatives persist their own artifacts, provenance records, and session events while remaining explicitly `draft`
- the current wave still does not issue/effectuate referral or prescription acts
Files touched:
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/referral-draft-document.schema.json`
- `schemas/contracts/prescription-draft-document.schema.json`
- `docs/architecture/09-aaci.md`
- `docs/architecture/28-first-slice-executable-path.md`

### AACI-008 Harden retrieval/memory/index governance contracts without fake semantic execution
Outcome:
- retrieval now has explicit governed contracts for query/scope/policy/failure and an executable governed retrieval entrypoint over bounded lexical retrieval
- memory scope contracts now explicitly separate user/professional/session/service/system/derived memory and enforce scope/provenance/layer guard rails
- semantic index/embedding contracts now exist as scaffold only (status/provenance/vector-placeholder semantics) with explicit unavailable/degraded honesty
- first-slice retrieval path now uses governed query flow and records explicit retrieval provenance checkpoints while preserving deterministic lexical behavior
- provider routing now exposes embedding-provider routing boundary so semantic retrieval can fail closed when incompatible/unavailable
Files touched:
- `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift`
- `swift/Sources/HealthOSCore/FirstSliceServices.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `swift/Sources/HealthOSProviders/ProviderProtocols.swift`
- `swift/Sources/HealthOSProviders/StubProviders.swift`
- `swift/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`

## READY

## TESTS / VALIDATION

- no AACI path bypasses gate
- no subagent requires undefined access semantics
- provider routing remains provider-agnostic at contract level
- actor/agent/runtime vocabulary matches glossary and schemas
