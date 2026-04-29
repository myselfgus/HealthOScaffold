# Structural Ontology and Product Readiness Plan (2026-04-29)

This document is the canonical priority-ordered work plan produced by the ontology and production-readiness analysis performed on 2026-04-29. It is the authoritative task queue for AI coding agents operating in this repository from this date forward, until superseded by a later analysis.

Read this document **before** reading the per-domain TODO files. The priority tiers here override the ordering within any individual TODO file.

---

## How to use this document (for AI coding agents)

1. Read the full **Priority Grid** below to understand tier ordering.
2. Pick the highest-priority task whose **Status** is `READY` and whose **Prerequisites** are all `DONE`.
3. Read the task's full spec (file, branch, DoD, validation, git workflow).
4. Execute it exactly as specified.
5. After completing validation, follow the **Git + PR Workflow** section.
6. Update `docs/execution/02-status-and-tracking.md` and mark the task `DONE` in this document and in the relevant TODO file.

**Never skip prerequisites. Never declare done without all validation commands passing.**

---

## Priority Grid

| Task ID | Priority | Status | Title | Prerequisite |
|---------|----------|--------|-------|-------------|
| STR-001 | **P0** | DONE | Wire `HealthOSProviders` into `HealthOSMentalSpace` in Package.swift | — |
| RT-MSR-001 | **P0** | READY | Implement `ASLExecutor` with real Claude API adapter | STR-001 |
| RT-MSR-002 | **P0** | BLOCKED | Implement `VDLPExecutor` with real Claude API adapter | RT-MSR-001 |
| RT-MSR-003 | **P0** | BLOCKED | Implement `GEMArtifactBuilder` with real Claude API adapter | RT-MSR-002 |
| STR-002 | **P1** | READY | Archive `Skill macOS/` to `docs/reference/mental-space-legacy/` | — |
| STR-003 | **P1** | READY | Separate AGENT packages from PRODUCT in `ts/packages/` | — |
| STR-004 | **P1** | READY | Rename `HealthOSFirstSliceSupport` → `HealthOSSessionRuntime` | — |
| STR-005 | **P2** | READY | Add placeholder Swift targets for Sortio and CloudClinic | — |
| APP-011 | **P2** | BLOCKED | Sortio: smoke-testable executable path | STR-005 |
| APP-012 | **P2** | BLOCKED | CloudClinic: smoke-testable executable path | STR-005 |
| RT-ASYNC-001 | **P3** | BLOCKED | SQL-backed async runtime executor | Core SQL migration (exists) |
| RT-PROVIDER-001 | **P3** | READY | Real Apple Foundation Models integration for normalization stage | — |
| RT-RETRIEVAL-001 | **P3** | BLOCKED | Semantic retrieval with real embeddings provider | Provider adapter exists |
| CI-001 | **P4** | READY | Wire `make validate-all` into GitHub Actions CI | — |

---

## Git + PR Workflow (applies to every task)

Every task must follow this exact flow. No exceptions.

```bash
# 1. Start from main, clean
git checkout main
git pull origin main

# 2. Create task branch
git checkout -b feat/<TASK-ID>-<short-slug>
# e.g.: feat/str-001-mentlspace-providers-dep

# 3. Implement (see task spec below)

# 4. Run all validation
make swift-build
make swift-test
make ts-build
make validate-docs
make validate-schemas
make validate-contracts
make validate-all
make smoke-cli
make smoke-scribe

# 5. Stage only the files listed in the task spec
git add <files explicitly listed in task spec>

# 6. Commit
git commit -m "$(cat <<'EOF'
feat(<scope>): <short title>

<2-3 sentence body: what changed, why, what invariants it touches>

Invariants: <list from task spec>
Residual gaps: <explicit list of what is NOT done>

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
EOF
)"

# 7. Push
git push -u origin feat/<TASK-ID>-<short-slug>

# 8. Open PR
gh pr create \
  --title "<TASK-ID>: <title>" \
  --body "$(cat <<'EOF'
## Summary
- <bullet 1>
- <bullet 2>
- <bullet 3>

## Invariants involved
- <list from task spec>

## Validation
- [ ] make swift-build PASS
- [ ] make swift-test PASS
- [ ] make ts-build PASS
- [ ] make validate-all PASS
- [ ] make smoke-cli PASS
- [ ] make smoke-scribe PASS

## Residual gaps
- <explicit non-done items>

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
```

PR title format: `feat(msr): STR-001 wire HealthOSProviders into HealthOSMentalSpace`
Branch format: `feat/str-001-mentlspace-providers-dep`

**Never push directly to `main`. Always open a PR.**

---

## P0 — Clinical Pipeline Activation

These tasks unlock the 400-patient validated ASL/VDLP/GEM clinical pipeline. They are the highest-leverage work in the repository because they convert the core clinical AI capability from stubs that always fail into executable product code.

Do P0 tasks before any P1/P2/P3/P4 task. They must be executed in order (STR-001 first, then RT-MSR-001, then RT-MSR-002, then RT-MSR-003).

---

### STR-001: Wire `HealthOSProviders` into `HealthOSMentalSpace`

**Priority:** P0 | **Status:** DONE | **Branch:** `feat/str-001-mentlspace-providers-dep`

**Why this first:** `HealthOSMentalSpace` cannot call Claude API without `HealthOSProviders`. This is a one-line Package.swift change that unblocks RT-MSR-001.

**Files to touch:**

- `swift/Package.swift` — add `"HealthOSProviders"` to `HealthOSMentalSpace` dependencies array
- `docs/execution/02-status-and-tracking.md` — add STR-001 completion entry
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — mark STR-001 DONE

**Exact change in Package.swift:**

```swift
// Before:
.target(name: "HealthOSMentalSpace", dependencies: ["HealthOSCore"],
        resources: [.copy("Prompts")]),

// After:
.target(name: "HealthOSMentalSpace", dependencies: ["HealthOSCore", "HealthOSProviders"],
        resources: [.copy("Prompts")]),
```

**Definition of done:**
- `swift build` PASS with the new dependency declared
- `swift test` PASS (no regressions)
- `swift package dump-package` shows `HealthOSMentalSpace` depending on `["HealthOSCore", "HealthOSProviders"]`

**Validation commands:**
```bash
cd swift && swift build
cd swift && swift test
cd swift && swift package dump-package | grep -A5 HealthOSMentalSpace
make validate-all
```

**Invariants:** Inv 1 (Core sovereignty), Inv 17 (provider honesty), Inv 43 (scaffold is not production)

**Residual gaps after this task:** Executors still throw `.providerUnavailable`; only the dependency graph is fixed.

**Completion note (2026-04-29):** Dependency graph wired. `HealthOSMentalSpace` now declares `HealthOSProviders` alongside `HealthOSCore`. Residual gap remains explicit: ASL/VDLP/GEM executors still throw `.providerUnavailable` until RT-MSR-001/002/003; no provider call was implemented in STR-001.

---

### RT-MSR-001: Implement `ASLExecutor` with real Claude API adapter

**Priority:** P0 | **Status:** READY (after STR-001) | **Branch:** `feat/rt-msr-001-asl-executor`

**Prerequisite:** STR-001 DONE.

**Why:** ASL (Analise Sistemica da Linguagem) is the first stage of the clinical pipeline. It extracts 8 psycholinguistic domains from a transcript. The prompt is validated against 400 patients and lives at `swift/Sources/HealthOSMentalSpace/Prompts/asl-system.md`. The executor stub always throws `.providerUnavailable`. This task makes it callable.

**Reference implementation:** `Skill macOS/4-asl.ts` — use for chunking logic and output structure only. Do not copy TypeScript syntax.

**Files to touch:**

- `swift/Sources/HealthOSMentalSpace/Executors/ASLExecutor.swift` — implement real executor
- `swift/Sources/HealthOSMentalSpace/MentalSpacePipeline.swift` — update orchestrator to call ASL executor
- `swift/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift` — add ASL executor tests
- `docs/execution/02-status-and-tracking.md` — completion entry
- `docs/execution/todo/runtimes-and-aaci.md` — mark RT-MSR-001 DONE
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — mark RT-MSR-001 DONE

**Implementation spec:**

```swift
// ASLExecutor.swift implementation requirements:
// 1. Load Prompts/asl-system.md from Bundle.module at init time
// 2. Accept: non-empty transcription text (String)
// 3. Chunk at 10,000 tokens; process parallel batches of max 3
// 4. Call Claude Sonnet via HealthOSProviders language model adapter
// 5. Request headers must include:
//    anthropic-beta: prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11
// 6. Temperature: 0, max_tokens: 60_000
// 7. Parse structured JSON output into ASLArtifact (contract already in HealthOSCore)
// 8. Record provenance: "mental-space.asl"
// 9. Throw .providerUnavailable if provider is stub-only
// 10. Throw .upstreamMissing if transcription is empty
```

**Output structure (from reference TS):** ASL produces 8 domain scores with supporting evidence per domain. Match the existing `ASLArtifact` type in `HealthOSCore/MentalSpaceRuntime.swift`.

**Tests required:**
- Test: empty transcription → throws `.upstreamMissing` (or equivalent)
- Test: stub provider → throws `.providerUnavailable`
- Test: valid input with mock provider → returns `ASLArtifact` with 8 domains populated
- Test: provenance records `mental-space.asl` operation

**Definition of done:**
- `ASLExecutor` protocol conformance is real (not a stub `throw`)
- `MentalSpacePipelineOrchestrator` sequences normalization → ASL with fail-closed dependency check
- All new tests pass
- `make swift-build && make swift-test` PASS
- `make validate-all` PASS

**Invariants:** Inv 1, Inv 17 (provider honesty — stub output never persisted), Inv 25a (MSR artifacts are derived/gated), Inv 43

**Residual gaps:** VDLP and GEM remain stubs; no real Claude API key required for tests (use mock provider).

---

### RT-MSR-002: Implement `VDLPExecutor` with real Claude API adapter

**Priority:** P0 | **Status:** BLOCKED on RT-MSR-001 | **Branch:** `feat/rt-msr-002-vdlp-executor`

**Prerequisite:** RT-MSR-001 DONE.

**Reference implementation:** `Skill macOS/5-vdlp.ts`

**Files to touch:**
- `swift/Sources/HealthOSMentalSpace/Executors/VDLPExecutor.swift`
- `swift/Sources/HealthOSMentalSpace/MentalSpacePipeline.swift`
- `swift/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**Implementation spec:**
- Requires ready ASL blob + non-empty patient speech text
- Chunk at 10,000 tokens; speech-only split
- Claude Sonnet, temperature 0, max_tokens 60,000, same caching headers as ASL
- Output: 15 mental space dimensions v₁–v₁₅ mapped to `VDLPArtifact` in HealthOSCore
- Provenance: `mental-space.vdlp`
- Throw `.triadIncomplete` if ASL artifact is missing or degraded

**Tests required:**
- Missing ASL input → throws `.triadIncomplete`
- Stub provider → throws `.providerUnavailable`
- Valid input with mock → `VDLPArtifact` with 15 dimensions
- Provenance records `mental-space.vdlp`

**Definition of done:** same pattern as RT-MSR-001; all validation commands PASS.

---

### RT-MSR-003: Implement `GEMArtifactBuilder` with real Claude API adapter

**Priority:** P0 | **Status:** BLOCKED on RT-MSR-002 | **Branch:** `feat/rt-msr-003-gem-builder`

**Prerequisite:** RT-MSR-002 DONE.

**Reference implementation:** `Skill macOS/6-gem.ts`

**Files to touch:**
- `swift/Sources/HealthOSMentalSpace/Executors/GEMArtifactBuilder.swift`
- `swift/Sources/HealthOSMentalSpace/MentalSpacePipeline.swift`
- `swift/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/runtimes-and-aaci.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**Implementation spec:**
- Requires all three upstream artifacts: normalization, ASL, VDLP
- Chunk at 50,000 tokens; transcription-only split
- Claude Sonnet, temperature **0.2**, max_tokens 60,000, same caching headers
- Output: 4-layer cognitive graph (`.aje` / `.ire` / `.e` / `.epe`) mapped to `GEMArtifact` in HealthOSCore
- Provenance: `mental-space.gem`
- Throw `.triadIncomplete` if any upstream artifact is missing

**Tests required:**
- Any upstream missing → throws `.triadIncomplete`
- Stub provider → throws `.providerUnavailable`
- Valid input with mock → `GEMArtifact` with 4 layers
- Provenance records `mental-space.gem`

**Definition of done:** same pattern; all validation commands PASS. After this task, `Skill macOS/` TS scripts are no longer the active pipeline — they become archived reference.

---

## P1 — Repository Ontology Correction

These tasks eliminate structural confusion between product, build, and agent layers. They are independent of each other and can be executed in any order or in parallel branches.

---

### STR-002: Archive `Skill macOS/` to `docs/reference/mental-space-legacy/`

**Priority:** P1 | **Status:** READY | **Branch:** `feat/str-002-archive-skill-macos`

**Do this after RT-MSR-003 is DONE.** Archiving before executors are validated loses the reference implementation.

**Why:** `Skill macOS/` at repository root implies it is an active production component at the same level as `swift/`, `ts/`, and `schemas/`. It is not. The prompt contracts are already migrated to `swift/Sources/HealthOSMentalSpace/Prompts/`. The TS scripts are reference implementations during the Swift migration, nothing more.

**Files to touch:**
```bash
# git mv preserves full history
git mv "Skill macOS" "docs/reference/mental-space-legacy"
```
- `docs/reference/mental-space-legacy/README.md` — new file, marks these as archived reference
- `docs/architecture/49-mental-space-runtime.md` — update any reference to `Skill macOS/` → `docs/reference/mental-space-legacy/`
- `docs/execution/02-status-and-tracking.md` — completion entry
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — mark STR-002 DONE

**`docs/reference/mental-space-legacy/README.md` content required:**
```
# Mental Space Legacy Reference Scripts

These TypeScript scripts are the original validated implementation of the
ASL/VDLP/GEM clinical pipeline (tested on 400 patients, 2024–2026).

They are ARCHIVED REFERENCE IMPLEMENTATIONS. They are not the active pipeline.

The active pipeline is:
  swift/Sources/HealthOSMentalSpace/

The canonical prompt contracts are extracted verbatim from these scripts and
version-controlled at:
  swift/Sources/HealthOSMentalSpace/Prompts/

Do not alter prompt content here — edit the Swift Prompts/ copies instead.
Do not run these scripts against production data.
```

**Definition of done:**
- `ls "Skill macOS"` → no such directory
- `ls docs/reference/mental-space-legacy/` → lists all 8 original files + README.md
- `git log --oneline docs/reference/mental-space-legacy/4-asl.ts` → shows history
- `make validate-docs` PASS
- `make validate-all` PASS

---

### STR-003: Separate AGENT packages from PRODUCT in `ts/packages/`

**Priority:** P1 | **Status:** READY | **Branch:** `feat/str-003-ts-agent-infra-dir`

**Why:** `ts/packages/` currently conflates three distinct layers — product runtimes, BUILD tooling, and AGENT infrastructure — at the same directory level. This creates false structural equivalence between components that must not be mixed operationally.

**Current (wrong) structure:**
```
ts/packages/
├── contracts/           # PRODUCT — TypeScript contract mirror
├── healthos-gos-tooling/ # BUILD  — GOS compiler/validator CLI
├── healthos-steward/    # AGENT  — Steward agent package
├── mcp-local/           # AGENT  — healthos-mcp scaffold
├── runtime-async/       # PRODUCT — async runtime TS layer
├── runtime-user-agent/  # PRODUCT — user-agent runtime TS layer
└── service-runtime/     # PRODUCT — service runtime TS layer
```

**Target (correct) structure:**
```
ts/packages/             # PRODUCT + BUILD only
├── contracts/
├── healthos-gos-tooling/
├── runtime-async/
├── runtime-user-agent/
└── service-runtime/

ts/agent-infra/          # AGENT only
├── healthos-steward/
└── mcp-local/
```

**Files to touch:**
```bash
mkdir -p ts/agent-infra
git mv ts/packages/healthos-steward ts/agent-infra/healthos-steward
git mv ts/packages/mcp-local ts/agent-infra/mcp-local
```
- `pnpm-workspace.yaml` — add `"ts/agent-infra/*"` to packages array
- `CLAUDE.md` — update Steward CLI path references from `ts/packages/healthos-steward` → `ts/agent-infra/healthos-steward`
- `README.md` — same path updates
- `docs/architecture/45-healthos-xcode-agent.md` — same path updates
- `docs/execution/17-healthos-xcode-agent-migration-plan.md` — same path updates
- `docs/execution/02-status-and-tracking.md` — completion entry
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — mark STR-003 DONE

**Definition of done:**
- `ls ts/packages/healthos-steward` → no such directory
- `ls ts/agent-infra/healthos-steward/src/` → source files present with history
- `cd ts && npm run build` PASS (pnpm workspace resolves both paths)
- `make ts-build` PASS
- `make validate-docs` PASS (no broken path references)

**Validation commands:**
```bash
cd ts && npm run build
make ts-build
make validate-docs
make validate-all
```

---

### STR-004: Rename `HealthOSFirstSliceSupport` → `HealthOSSessionRuntime`

**Priority:** P1 | **Status:** READY | **Branch:** `feat/str-004-session-runtime-rename`

**Why:** `HealthOSFirstSliceSupport` encodes a development phase ("first slice") into the product's dependency graph. In a product, session orchestration is an architectural concept, not a development milestone. Renaming to `HealthOSSessionRuntime` correctly positions this module as the session orchestration layer.

**Files to touch:**
```bash
git mv swift/Sources/HealthOSFirstSliceSupport swift/Sources/HealthOSSessionRuntime
```
- `swift/Package.swift` — rename all occurrences of `HealthOSFirstSliceSupport` → `HealthOSSessionRuntime`
- `swift/Sources/HealthOSSessionRuntime/FirstSliceRunner.swift` — rename file to `SessionRunner.swift` and update any internal references to "FirstSlice" in public API names (keep internal names if needed for now; public API only)
- `swift/Sources/HealthOSSessionRuntime/ScribeFirstSliceAdapter.swift` — rename to `ScribeSessionAdapter.swift` and update public type names
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift` — update imports: `HealthOSFirstSliceSupport` → `HealthOSSessionRuntime`
- `swift/Sources/HealthOSScribeApp/` — update imports
- `swift/Tests/HealthOSTests/` — update imports and any references in test files
- `docs/execution/02-status-and-tracking.md` — completion entry
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — mark STR-004 DONE
- Update any doc references to `HealthOSFirstSliceSupport` in `docs/architecture/`

**Note:** Do NOT rename internal types that begin with `FirstSlice` if doing so would break too many things in one PR. Rename the module and its primary public types; leave internal helper names as a follow-up.

**Definition of done:**
- `ls swift/Sources/HealthOSFirstSliceSupport` → no such directory
- `swift build` PASS with the renamed module
- `swift test` PASS — all 246 tests pass, no regressions
- `grep -r "HealthOSFirstSliceSupport" swift/` → no results
- `make validate-all` PASS

---

## P2 — Product Completeness

These tasks add missing product targets. They can be done after P1 or in parallel.

---

### STR-005: Add placeholder Swift executable targets for Sortio and CloudClinic

**Priority:** P2 | **Status:** READY | **Branch:** `feat/str-005-sortio-cloudclinic-targets`

**Why:** Sortio and CloudClinic have governance contracts, boundary tests, and architecture docs, but no Swift executable targets. The Xcode workspace references only Scribe as an app. This creates a false picture of the product: one app is buildable, two are documentation-only. Adding minimal placeholder targets forces the product graph to be honest and gives CI a build surface for all three apps.

**Files to create:**
```
swift/Sources/HealthOSSortioApp/SortioEntrypoint.swift
swift/Sources/HealthOSCloudClinicApp/CloudClinicEntrypoint.swift
```

**`SortioEntrypoint.swift` minimum:**
```swift
import Foundation
import HealthOSCore

// Sortio is the patient sovereignty interface for HealthOS.
// This target is a scaffold placeholder — no final UI shell is implemented.
// Architecture: docs/architecture/12-sortio.md
// Governance contracts: HealthOSCore/UserAgentGovernance.swift

@main
struct SortioEntrypoint {
    static func main() {
        let args = CommandLine.arguments
        if args.contains("--smoke-test") {
            print("HealthOSSortio scaffold: smoke OK (no final UI)")
            exit(0)
        }
        print("HealthOSSortio: scaffold placeholder — no final UI shell (see docs/architecture/12-sortio.md)")
    }
}
```

**`CloudClinicEntrypoint.swift` minimum:** same pattern, referencing `13-cloudclinic.md` and `ServiceOperationsGovernance.swift`.

**`swift/Package.swift` additions:**
```swift
.executableTarget(
    name: "HealthOSSortioApp",
    dependencies: ["HealthOSCore"]
),
.executableTarget(
    name: "HealthOSCloudClinicApp",
    dependencies: ["HealthOSCore"]
),
```

Also add to products:
```swift
.executable(name: "HealthOSSortioApp", targets: ["HealthOSSortioApp"]),
.executable(name: "HealthOSCloudClinicApp", targets: ["HealthOSCloudClinicApp"]),
```

**Files to touch:**
- `swift/Package.swift`
- `swift/Sources/HealthOSSortioApp/SortioEntrypoint.swift` (new)
- `swift/Sources/HealthOSCloudClinicApp/CloudClinicEntrypoint.swift` (new)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**Definition of done:**
- `swift build` PASS — all 5 executable targets build (CLI, Scribe, Sortio, CloudClinic + test target)
- `swift run HealthOSSortioApp --smoke-test` exits 0 and prints scaffold message
- `swift run HealthOSCloudClinicApp --smoke-test` exits 0 and prints scaffold message
- `swift test` PASS — no regressions
- `make validate-all` PASS

---

### APP-011: Sortio — wire existing boundary contracts to session runtime

**Priority:** P2 | **Status:** BLOCKED on STR-005 | **Branch:** `feat/app-011-sortio-session-wire`

**Prerequisite:** STR-005 DONE. Also depends on STR-004 if already done.

**Scope:** Wire `UserAgentGovernance.swift` contracts into a minimal `SortioSessionFacade` (equivalent pattern to `ScribeFirstSliceFacade`) so Sortio has an executable session boundary, not just a contract-only posture.

**Definition of done:**
- `HealthOSSortioApp` can run a governed user-agent session scaffold (seeded input, governed output, honest degraded state)
- Provenance records at least `sortio.session.start` and `sortio.session.end`
- `make swift-test` PASS with new Sortio boundary smoke test added
- `make smoke-scribe` still PASS (no regression)

---

### APP-012: CloudClinic — wire existing boundary contracts to session runtime

**Priority:** P2 | **Status:** BLOCKED on STR-005 | **Branch:** `feat/app-012-cloudclinic-session-wire`

**Same pattern as APP-011, using `ServiceOperationsGovernance.swift` contracts.**

---

## P3 — Runtime Hardening

Do after P0 and P1 are complete. These tasks advance the runtime tier from "implemented seam" toward "tested operational path" in production-relevant dimensions.

---

### RT-PROVIDER-001: Real Apple Foundation Models integration for normalization

**Priority:** P3 | **Status:** READY | **Branch:** `feat/rt-provider-001-apple-foundation-models`

**Why:** Normalization is the only MSR stage that must use a local Apple provider (remote fallback denied for v1 per architecture). Currently the Apple provider is stub-marked. This task implements a real local model call using Apple Foundation Models (FoundationModels framework, macOS 26+).

**Key constraint:** Search Apple documentation for `FoundationModels` API before implementing — this is new API beyond training data. Use `DocumentationSearch` MCP tool.

**Files to touch:**
- `swift/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift` (new or update existing stub)
- `swift/Sources/HealthOSAACI/AACI.swift` — update normalization provider selection to use real adapter when available
- `swift/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift` — add normalization with real local provider test (mark as requiring macOS 26 device)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**Definition of done:**
- Normalization can produce a real normalized transcript (not stub) on a device with Foundation Models available
- Stub path remains active and honest when Foundation Models unavailable
- `swift build` PASS; `swift test` PASS

---

### RT-ASYNC-001: SQL-backed async runtime executor

**Priority:** P3 | **Status:** BLOCKED on SQL migration (exists) + PostgreSQL connection infrastructure | **Branch:** `feat/rt-async-001-sql-executor`

**Why:** The async runtime is currently `InMemoryAsyncJobRuntime` only. The SQL schema exists (`sql/migrations/001_init.sql` includes `async_jobs`, `async_job_attempts`, `async_job_events` tables). This task wires a real PostgreSQL-backed executor using those tables.

**Prerequisite:** Local PostgreSQL running per single-node runbook. Connection infrastructure in `HealthOSCore` or `HealthOSProviders`.

**Files to touch:**
- `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift` — add `PostgreSQLAsyncJobRuntime` conforming to same protocol as `InMemoryAsyncJobRuntime`
- `swift/Tests/HealthOSTests/AsyncRuntimeGovernanceTests.swift` — add SQL-backed executor tests (using a local test DB)
- `sql/migrations/001_init.sql` — no changes required (schema already exists)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**Definition of done:**
- `PostgreSQLAsyncJobRuntime` passes the same governance test suite as `InMemoryAsyncJobRuntime`
- Job lifecycle transitions persist to DB and survive restart
- `make swift-test` PASS (SQL tests skipped cleanly if no local DB; not a hard failure)

---

### RT-RETRIEVAL-001: Semantic retrieval with real embeddings provider

**Priority:** P3 | **Status:** BLOCKED on embeddings provider adapter | **Branch:** `feat/rt-retrieval-001-semantic-retrieval`

**Why:** Retrieval currently returns honest `unavailable` for semantic queries. The governed retrieval contracts and fail-closed embedding boundary exist. This task wires a real embeddings provider (Apple or remote, per policy) to make semantic retrieval operational.

**Constraint:** Remote embeddings provider requires explicit policy approval for the data layer involved. Do not wire remote embeddings for direct-identifier or sensitive layers without explicit policy.

**Files to touch:**
- `swift/Sources/HealthOSProviders/EmbeddingsAdapter.swift` (new)
- `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift` — update semantic retrieval to use adapter when available
- `swift/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift` — add semantic retrieval tests
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

---

## P4 — Infrastructure / CI

These tasks improve engineering infrastructure. Do after P0–P2 are complete.

---

### CI-001: Wire `make validate-all` into GitHub Actions

**Priority:** P4 | **Status:** READY | **Branch:** `feat/ci-001-github-actions-validate`

**Why:** The local validation harness (`make validate-all`) is tested and passes locally. Without CI integration, each PR depends on the author running it locally, creating drift risk.

**Files to create/touch:**
- `.github/workflows/validate.yml` (new) — trigger on push/PR to main; run `make validate-all`
- `.github/workflows/swift-test.yml` (new) — separate job for `make swift-test` with macOS 26 runner
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

**GitHub Actions spec:**
```yaml
# validate.yml minimum
name: Validate
on: [push, pull_request]
jobs:
  validate:
    runs-on: macos-26  # or latest macOS supporting Swift 6.2
    steps:
      - uses: actions/checkout@v4
      - name: Bootstrap
        run: make bootstrap
      - name: Validate all
        run: make validate-all
```

**Definition of done:**
- PRs automatically run `make validate-all`
- A PR with a failing validation command cannot be merged (branch protection rule set)
- `make validate-docs` and `make validate-schemas` run in CI
- No secrets or clinical data in CI logs

---

## Ontology invariants (never violate)

Regardless of which task is being executed:

1. **Core sovereignty:** Nothing in P0–P4 moves consent, habilitation, gate, or finality logic out of `HealthOSCore`.
2. **Provider honesty:** Stub output is never persisted as real clinical output. Degraded state is surfaced honestly, not hidden.
3. **Draft-only:** AACI and MSR produce derived artifacts and drafts. No task in this plan effectuates a clinical act without a human gate.
4. **No production claims:** These tasks advance maturity but do not make the system production-ready. Update maturity docs honestly after each task.
5. **Append-only provenance:** Provenance records are never mutated after write.
6. **App boundaries:** Scribe, Sortio, and CloudClinic consume mediated state. No task moves law interpretation into SwiftUI or app layers.

---

## Completion tracking

When a task is done:
1. Update the **Status** column in the Priority Grid above from `READY`/`BLOCKED` → `DONE`
2. Add a completion entry to `docs/execution/02-status-and-tracking.md` (follow existing format)
3. Update the relevant `docs/execution/todo/*.md` file
4. Update `docs/execution/11-current-maturity-map.md` if the task advances a component's maturity tier
5. The PR description must list residual gaps explicitly — never close a task without listing what was NOT done

---

*Last updated: 2026-04-29 — produced from structural ontology analysis. Supersedes ordering in individual TODO files for priority decisions.*
