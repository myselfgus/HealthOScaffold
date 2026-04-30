# TODO — Runtimes and AACI

Repository identity note: HealthOScaffold is the HealthOS construction repository. Use "scaffold" only for maturity or foundation-phase status, not to deny that implemented runtime/AACI work here is HealthOS work.

## COMPLETED


### STR-001 Wire HealthOSProviders into HealthOSMentalSpace
Outcome:
- `HealthOSMentalSpace` now declares both `HealthOSCore` and `HealthOSProviders` in SwiftPM target dependencies, unblocking provider-backed runtime executor implementation work.
- No ASL/VDLP/GEM provider execution was implemented in this work unit; executors remain scaffolded fail-closed boundaries.
Files touched:
- `swift/Package.swift`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `docs/execution/todo/runtimes-and-aaci.md`
- `docs/execution/02-status-and-tracking.md`

### RT-010 Establish Mental Space Runtime contracts and first normalization slice
Outcome:
- Mental Space Runtime is now defined as a staged derived-artifact runtime domain for transcription normalization, ASL, VDLP, and GEM, separate from the async runtime substrate
- Swift Core now has Mental Space artifact contracts, stage states, fail-closed dependency validation, app-safe runtime view, and normalization result/request contracts
- async job taxonomy now includes `mental_space_normalization`, `mental_space_asl`, `mental_space_vdlp`, and `mental_space_gem` in Swift, TypeScript, and JSON Schema
- AACI now exposes local-first transcript normalization with remote fallback denied for v1 and stub output degraded instead of persisted
- the first slice persists normalized transcript output as a `derived-artifacts` Mental Space artifact only when a real local model is available, with source transcript lineage, model/prompt/stage metadata, limitations, and provenance
- Scribe bridge/UI now surfaces minimal Mental Space stage status without raw artifact JSON, prompt internals, direct identifiers, or legal-authorizing claims
- ASL, VDLP, and GEM remain scaffolded stage contracts/job kinds only; existing prompt-engineered scripts still need future adapter wrapping in order
Files touched:
- `docs/architecture/49-mental-space-runtime.md`
- `swift/Sources/HealthOSCore/MentalSpaceRuntime.swift`
- `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `swift/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/async-job.schema.json`
- `schemas/contracts/mental-space-artifact.schema.json`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/skills/mental-space-runtime-skill.md`

### DOC-001 Correct HealthOScaffold / HealthOS repository identity vocabulary
Outcome:
- added an accepted ADR clarifying that HealthOScaffold is the historical repository name and construction repository for HealthOS
- aligned entry docs, execution docs, architecture docs, maturity maps, steward/Xcode Agent docs, TODO/skill guidance, and handoff language so scaffold means maturity/foundation phase rather than separate product identity
- preserved non-production, non-EHR, no-real-provider, no-real-signature, no-real-semantic-retrieval, and no-final-UI warnings
- validation: `make validate-docs` PASS; `make validate-all` FAIL only at `swift-test` due existing Swift test compile errors outside this documentation-only work unit; remaining validate-all steps passed
Files touched:
- `docs/adr/0012-healthoscaffold-is-healthos-construction-repository.md`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `docs/execution/*`
- `docs/architecture/*`
- `.healthos-steward/README.md`
- `docs/execution/skills/*`
- `docs/execution/todo/runtimes-and-aaci.md`

### RT-009 Establish repository validation harness and drift detectors
Outcome:
- local validation harness added (`scripts/validate-local.sh`) with fail-closed sequencing for bootstrap, docs/schema/contract checks, Swift build/test, TS build/test, Python compile check, and CLI/Scribe smoke checks
- documentation drift checker added (`scripts/check-docs.sh`) to validate required docs, referenced paths, documented Make targets, stale test claims, and accidental production-ready wording
- contract drift checker added (`scripts/check-contract-drift.sh`) for critical schema/Swift/TS/SQL presence plus storage/runtime/GOS vocabulary parity checks
- schema syntax harness added (`scripts/validate-schemas.sh`) and Makefile targets aligned (`validate-docs`, `validate-schemas`, `validate-contracts`, `validate-all`, `python-check`, `smoke-cli`, `smoke-scribe`)
Files touched:
- `Makefile`
- `scripts/validate-local.sh`
- `scripts/check-docs.sh`
- `scripts/check-contract-drift.sh`
- `scripts/validate-schemas.sh`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/todo/runtimes-and-aaci.md`

### RT-007 Harden async policy-denial observability and failure transition guards
Outcome:
- async runtime now emits explicit `job.policy_denied` events when lawful-context/policy checks fail closed before handler execution
- failure progression now enforces state-machine transitions through `failed` before retry/dead-letter routing in the runtime failure path
- execution record retention now preserves `policy_denied` failures for operator inspection workflows
- Swift XCTest coverage now asserts policy-denied observability and failure-record retention (`AsyncRuntimeGovernanceTests`)
Files touched:
- `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift`
- `swift/Tests/HealthOSTests/AsyncRuntimeGovernanceTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`

### RT-006 Harden async runtime/jobs/queues observability scaffold
Outcome:
- async runtime moved from simple stub to typed governance contracts with job taxonomy, lifecycle states, lawful-context requirements, retry/backpressure policy, idempotency rules, and observability event taxonomy
- Swift Core now provides a local governed executor (`InMemoryAsyncJobRuntime`) with guarded state transitions, fail-closed policy denial for sensitive jobs, retry/dead-letter behavior, cancellation, dead-letter requeue, and minimal operator control helpers
- SQL migration now includes async job metadata tables (`async_jobs`, `async_job_attempts`, `async_job_events`) for future persisted execution
- TypeScript contracts/runtime-async package now mirror the typed async job contract surface for cross-language consistency
- Swift test coverage now includes lifecycle/lawfulContext/retry/idempotency/observability/boundary negative tests (`AsyncRuntimeGovernanceTests`)
Files touched:
- `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift`
- `swift/Tests/HealthOSTests/AsyncRuntimeGovernanceTests.swift`
- `ts/packages/contracts/src/index.ts`
- `ts/packages/runtime-async/src/index.ts`
- `schemas/contracts/async-job.schema.json`
- `sql/migrations/001_init.sql`
- `docs/architecture/20-runtime-operational-policy.md`
- `docs/architecture/26-operator-observability-contract.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`

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
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionDemoBootstrap.swift`
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
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
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
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/referral-draft-document.schema.json`
- `schemas/contracts/prescription-draft-document.schema.json`
- `docs/architecture/09-aaci.md`
- `docs/architecture/28-first-slice-executable-path.md`

### AACI-009 Reflect active GOS operational guidance in derived draft lineage
Outcome:
- referral and prescription draft derivatives now carry a small `DerivedDraftOperationalGuidance` object on their existing spine link when an active resolved GOS runtime view is available
- summaries, payload metadata, storage metadata, and session events expose only bounded operational facts: actor, semantic role, primitive families, reasoning boundary, `gos.use.derive.*` operation, draft-only, gate-required, and non-authorizing flags
- no new effectuation path was added; referral and prescription remain draft-only derivatives tied to the same session/SOAP/context spine
- validation: `swift build`, TS build, schema validation, CLI approved/rejected smokes, and Scribe seeded/audio smokes passed; follow-up `swift test` passed after TEST-001 cleanup
Files touched:
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/referral-draft-document.schema.json`
- `schemas/contracts/prescription-draft-document.schema.json`
- `docs/architecture/28-first-slice-executable-path.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`
- `docs/execution/todo/gos-and-compilers.md`

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
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Sources/HealthOSProviders/ProviderProtocols.swift`
- `swift/Sources/HealthOSProviders/StubProviders.swift`
- `swift/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`


### RT-010 Add Project Steward repository engineering scaffold
Outcome:
- introduced a local TypeScript CLI package (`@healthos/steward`) with deterministic engineering commands: status, scan, next-task, validate, review-pr, memory, prompt, handoff
- added versioned steward memory/policies/prompts under `.healthos-steward/` with explicit non-secret and derived-index posture
- documented steward architecture and skill guidance for future agents without turning it into a clinical or autonomous merge agent
Files touched:
- `ts/agent-infra/healthos-steward/*`
- `.healthos-steward/*`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `README.md`, `AGENTS.md`, `CLAUDE.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`

### RT-011 Add real GitHub integration to Project Steward
Outcome:
- `healthos-steward review-pr` now reads PR metadata, status checks, issue comments, and review comments through authenticated `gh` CLI
- `healthos-steward comment-pr` and `healthos-steward comment-issue` now post comments to GitHub targets through `gh`
- removed steward-local mock/test artifacts to keep the implementation fully live and non-simulated
Files touched:
- `ts/agent-infra/healthos-steward/src/steward.ts`
- `ts/agent-infra/healthos-steward/package.json`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`


### STR-002 Archive Skill macOS legacy scripts (DONE 2026-04-29)
Outcome:
- repository-root `Skill macOS/` scripts were moved with history to `docs/reference/mental-space-legacy/` and are now explicitly archived reference implementations
- the active Mental Space implementation remains the Swift runtime in `swift/Sources/HealthOSMentalSpace/`
- this does not imply production-ready ML, clinical authority, or runtime/provider hardening completion
Files touched:
- `docs/reference/mental-space-legacy/*`
- `docs/reference/mental-space-legacy/README.md`
- `docs/architecture/49-mental-space-runtime.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `docs/execution/todo/runtimes-and-aaci.md`
- `docs/execution/02-status-and-tracking.md`

## READY

### STR-001 Wire HealthOSProviders into HealthOSMentalSpace (Package.swift)
Priority: **P0 — DO FIRST**
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → STR-001
Definition of done:
- `swift/Package.swift` — `HealthOSMentalSpace` dependencies include `"HealthOSProviders"`
- `swift build` PASS; `swift test` PASS; `make validate-all` PASS
Branch: `feat/str-001-mentlspace-providers-dep`

### RT-MSR-001 Implement ASLExecutor with real Claude API adapter (DONE 2026-04-29)
Priority: **P0 — after STR-001**
Prerequisite: STR-001 DONE
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → RT-MSR-001
Skill: `docs/execution/skills/mental-space-runtime-skill.md`
Reference: `docs/reference/mental-space-legacy/4-asl.ts`
Definition of done:
- `ASLExecutor` loads `Prompts/asl-system.md`, calls Claude Sonnet via `HealthOSProviders`, chunks at 10k tokens (parallel batches of 3), parses JSON → `ASLArtifact`, records provenance `mental-space.asl`
- prompt caching headers: `anthropic-beta: prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11`
- temperature 0, max_tokens 60_000
- stub provider → `.providerUnavailable`; empty transcription → `.upstreamMissing`
- `MentalSpacePipelineOrchestrator` sequences normalization → ASL with fail-closed dependency
- tests: empty input, stub provider, valid mock input, provenance verification
- `make swift-build && make swift-test && make validate-all` PASS
Branch: `feat/rt-msr-001-asl-executor`

### RT-MSR-002 Implement VDLPExecutor with real Claude API adapter
Priority: **P0 — after RT-MSR-001**
Prerequisite: RT-MSR-001 DONE
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → RT-MSR-002
Reference: `docs/reference/mental-space-legacy/5-vdlp.ts`
Definition of done:
- Requires ready ASL blob + non-empty patient speech; chunk at 10k tokens, speech-only split
- Claude Sonnet, temp 0, max_tokens 60k, same caching headers
- output: 15 dimensions v₁–v₁₅ → `VDLPArtifact`; provenance: `mental-space.vdlp`
- `.triadIncomplete` if ASL missing; `.providerUnavailable` if stub
- all tests pass; `make validate-all` PASS
Branch: `feat/rt-msr-002-vdlp-executor`

### RT-MSR-003 Implement GEMArtifactBuilder with real Claude API adapter
Priority: **P0 — after RT-MSR-002**
Status: **DONE (2026-04-29)**
Prerequisite: RT-MSR-002 DONE
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → RT-MSR-003
Reference: `docs/reference/mental-space-legacy/6-gem.ts`
Definition of done:
- Requires normalization + ASL + VDLP; chunk at 50k tokens, transcription-only split
- Claude Sonnet, **temperature 0.2**, max_tokens 60k, same caching headers
- output: 4-layer graph `.aje/.ire/.e/.epe` → `GEMArtifact`; provenance: `mental-space.gem`
- `.triadIncomplete` if any upstream missing; `.providerUnavailable` if stub
- all tests pass; `make validate-all` PASS
Branch: `feat/rt-msr-003-gem-builder`

### RT-PROVIDER-001 Real Apple Foundation Models integration for normalization
Priority: **P3** (after P0 complete)
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → RT-PROVIDER-001
Note: search Apple docs for `FoundationModels` API before implementing (macOS 26+ new framework)
Definition of done:
- normalization produces real normalized transcript when Foundation Models available locally
- stub path remains active and honest when unavailable
- `make swift-build && make swift-test` PASS

### RT-008 Extend runtime-boundary tests for user-agent and service-runtime adapters
Priority: **P2** (parallel with STR-005)
Skill: `docs/execution/skills/async-runtime-skill.md` + `docs/execution/skills/aaci-skill.md`
Definition of done:
- boundary denials tested across app/aaci/gos/runtime surfaces where currently contract-only

### AACI-009 Harden non-fake capability signaling for transcription/retrieval modes
Priority: Medium
Skill: `docs/execution/skills/aaci-skill.md` + `docs/execution/skills/provider-governance-skill.md`
Definition of done:
- docs/contracts/tests align on unavailable/degraded truth without semantic/provider over-claims


## TESTS / VALIDATION

- no AACI path bypasses gate
- no subagent requires undefined access semantics
- provider routing remains provider-agnostic at contract level
- actor/agent/runtime vocabulary matches glossary and schemas

### RT-010 Scaffold/foundation phase RC closure audit and final gap classification
Outcome:
- scaffold RC closure criteria now explicit and objective in a dedicated execution doc
- final residual gap register now classifies blockers, next HealthOS maturity hardening, production, and regulatory requirements with owner/module/validation fields
- scaffold finalization plan now defines last-action ordering, merge/validation criteria, and non-blocking production-phase items
- entry/handoff/maturity docs were synchronized to avoid drift and false production claims during closure prep
Files touched:
- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/execution/README.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/todo/runtimes-and-aaci.md`


Update 2026-04-29: ASL stage is now provider-backed through HealthOSProviders with fail-closed validation and provenance marker `mental-space.asl`. VDLP and GEM remain scaffolded; no production-readiness claim.


- [DONE] RT-MSR-002: VDLP executor now provider-backed via HealthOSProviders; fail-closed on missing/degraded ASL and empty speech; GEM remains scaffolded and out of scope for this unit.


- [DONE] RT-MSR-003: GEM executor path is provider-backed through HealthOSProviders with fail-closed dependency checks for normalized transcript + ASL + VDLP, transcription-only chunking at 50k threshold, consolidation, and `mental-space.gem` provenance in tests. ASL/VDLP/GEM now all have provider-backed executor paths with mocked test coverage. This does not imply production-ready ML or clinical diagnosis authority. STR-002 (Skill macOS archive) is complete; scripts now live under `docs/reference/mental-space-legacy/`.
