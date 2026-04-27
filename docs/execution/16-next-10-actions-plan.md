# Next 10 actions plan (2026-04-26)

**⚠️ AVISO: ESTE PLANO DE AÇÕES FOI CONCLUÍDO. NÃO SEGUIR ESTAS AÇÕES.**
Este documento registra um histórico de planejamento concluído.

This document enumerates the next 10 prioritized actions for HealthOScaffold,
in order of execution. It is written to be read by a coding agent (human or AI)
without prior chat context.

It does **not** alter scaffold posture. It does **not** declare production
readiness. It does **not** override `01-agent-operating-protocol.md`,
`13-scaffold-release-candidate-criteria.md`, `14-final-gap-register.md`,
`15-scaffold-finalization-plan.md`. Treat it as the canonical sequencing layer
on top of those.

## Sources of truth this plan respects

- `CLAUDE.md` task selection order: `READY` in current phase → `BLOCKER` →
  doc/contract that unblocks coding → validation for just-finished work.
- `12-next-agent-handoff.md` priority gaps: close scaffold blockers
  (GAP-001, GAP-002), then RT-008 boundary coverage, then CI, then
  storage/retrieval/provider parity, then non-claim discipline.
- `13-scaffold-release-candidate-criteria.md` closure decision rule.
- `14-final-gap-register.md` for blocker classification.
- `15-scaffold-finalization-plan.md` for tagging + validation gates.

## Sequencing rules used to derive this plan

1. Blockers for scaffold RC closure come first (T01, T02).
2. Boundary-test coverage for non-Scribe runtimes follows blockers (T03)
   so closure tag prep has full app/aaci/gos/runtime negative coverage.
3. Storage parity beyond first-slice (T04) closes the highest-risk
   `READY` task in `core-laws`/`data-storage` even though SQL/object
   parity remains an explicit post-scaffold gap (GAP-003).
4. Doc and capability honesty passes (T05, T06) protect anti-overclaim
   posture before tagging.
5. Local service envelope hygiene (T07) is medium-priority cleanup
   that reduces drift between Swift and TS at the loopback seam.
6. CI wiring (T08) elevates `make validate-all` into a distributed gate
   without inflating maturity claims.
7. Tag prep + closure (T09) only runs after blockers close and gates pass.
8. Steward provider follow-up (T10) is intentionally last because it is
   non-blocking and explicitly classified as post-scaffold hardening.

## Per-task spec

Each task block uses the same fields so an agent can execute deterministically.

---

### T01 — APP-008 Cross-app envelope propagation into Sortio/CloudClinic adapters

- TODO id: `APP-008` in `docs/execution/todo/apps-and-interfaces.md`
- Closure mapping: `GAP-001` (scaffold blocker) in `14-final-gap-register.md`
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: High
- Skills: `docs/execution/skills/cross-app-surfaces-skill.md` +
  `docs/execution/skills/app-boundary-skill.md`
- Owner modules:
  - existing contract surface: `swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`
  - non-Scribe adapters: `ts/packages/runtime-user-agent/` (Sortio path) and
    the service-runtime equivalent (CloudClinic) under `ts/packages/` plus
    Swift seams that surface them
- Scope:
  - Make Sortio and CloudClinic adapters consume `AppSurfaceEnvelope` and the
    typed safe-ref taxonomy (`SafeUserRef`, `SafePatientRef`,
    `SafeProfessionalRef`, `SafeServiceRef`, `SafeSessionRef`, `SafeDraftRef`,
    `SafeGateRef`, `SafeArtifactRef`, `SafeExportRef`, `SafeAuditRef`,
    `SafeProvenanceRef`).
  - Reject raw clinical/identifier payloads at the adapter boundary (no raw
    CPF, no raw storage paths, no reidentification mappings by default).
  - Enforce `legalAuthorizing = false` and role/app-aware
    allowed/denied actions.
- Definition of done:
  - Sortio/CloudClinic adapter seams consume shared envelope contracts without
    raw payload leaks.
  - Swift XCTest negatives extended for app-kind + role mismatch and
    safe-ref enforcement on these adapters.
- Files expected to change:
  - `ts/packages/runtime-user-agent/src/index.ts`
  - service-runtime adapter (introduce or wire if not yet present)
  - `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift`
    (extend) or new dedicated adapter test files
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/06-scaffold-coverage-matrix.md`
  - `docs/execution/10-invariant-matrix.md`
  - `docs/execution/todo/apps-and-interfaces.md` (move APP-008 to COMPLETED)
- Validation:
  - `make swift-build && make swift-test`
  - `make ts-build && make ts-test`
  - `make validate-all`
- Anti-overclaim:
  - This is contract propagation, not final UI delivery.
  - Do not introduce app-owned consent/habilitation/gate/finalization logic.
- Risks if mishandled:
  - Sneaking raw payloads through the adapter undermines `GAP-001` closure.
  - Treating the envelope as authorization instead of mediation surface.

#### Coding agent prompt

You are implementing T01 (APP-008) in the HealthOScaffold repository. Read
this entire prompt before touching any file.

**Repository identity (never collapse)**

HealthOS is the whole platform. AACI is one runtime inside it. GOS is subordinate
to Core law. Scribe/Sortio/CloudClinic are app-layer interfaces consuming mediated
surfaces. Core law (consent, habilitation, gate, finality, provenance) never moves
into AACI, GOS, or apps. This repo is a scaffold — not production-ready, not a
full EHR, not a real regulatory integration.

**Required reading before writing any code**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/06-scaffold-coverage-matrix.md`
5. `docs/execution/10-invariant-matrix.md` (pay attention to invariants 4, 31,
   32, 39, 40, 41)
6. `docs/execution/14-final-gap-register.md` (GAP-001 is the blocker you close)
7. `docs/execution/todo/apps-and-interfaces.md` (find APP-008)
8. `docs/execution/skills/cross-app-surfaces-skill.md`
9. `docs/execution/skills/app-boundary-skill.md`
10. `swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift` — read
    fully; this is the contract you propagate
11. `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift` —
    existing tests; you extend them
12. `ts/packages/runtime-user-agent/src/index.ts` — Sortio adapter seam
13. `docs/architecture/11-scribe.md`, `12-sortio.md`, `13-cloudclinic.md` —
    app-layer posture reference

**Task objective**

Close GAP-001 (scaffold blocker): Sortio and CloudClinic adapters must consume
`AppSurfaceEnvelope` and the `Safe*Ref` taxonomy from
`CrossAppCoordinationContracts.swift` without raw payload leaks.

Invariant 39 states: `AppSurfaceEnvelope.legalAuthorizing` is always `false`.
Invariant 40 states: `Safe*Ref` types never carry raw CPF, raw storage paths,
or reidentification mappings, and navigation does not grant data access.
Invariant 41 states: cross-app notifications do not expose sensitive payload.
Invariant 4 states: apps do not interpret raw GOS spec — only mediated surface.
Invariant 31 states: user-agent path never executes a clinical/regulatory act.
Invariant 32 states: patient sovereignty is mediated, not raw access.

**Exact scope**

What to do:
- In `ts/packages/runtime-user-agent/src/index.ts` (Sortio adapter seam):
  wire `AppSurfaceEnvelope` and enforce role/app-kind boundary. Reject raw CPF,
  raw storage paths, reidentification mappings at the TypeScript adapter level.
  Use `legalAuthorizing: false` explicitly. Map `allowedActions`/`deniedActions`
  from the Swift contract vocabulary.
- If a CloudClinic adapter seam does not exist yet in `ts/packages/`, introduce
  a minimal `service-runtime` adapter file that enforces the same envelope
  boundary. Do not implement real CloudClinic UI; this is an adapter boundary
  contract only.
- Extend `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift`
  with negative tests covering:
  - app-kind mismatch (Sortio envelope used with CloudClinic role and vice versa)
  - role mismatch denial
  - raw CPF present in a `Safe*Ref` → denied
  - raw storage path present → denied
  - `legalAuthorizing = true` attempt → fails validation
  - navigation-only ref claiming `grantsDataAccess = true` → denied

What not to do:
- Do not add consent, habilitation, gate, or finalization logic inside any
  adapter. These stay in Core.
- Do not invent new Sortio or CloudClinic UI features or screens.
- Do not claim production-readiness in any doc or comment.
- Do not introduce raw clinical payloads even for tests — use well-governed
  test fixtures.
- Do not treat `AppSurfaceEnvelope` as an authorization token.

**Files to change (minimum)**

- `ts/packages/runtime-user-agent/src/index.ts`
- `ts/packages/service-runtime/src/index.ts` (create if absent, minimal)
- `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift` (extend)
- `docs/execution/02-status-and-tracking.md` (add APP-008 completed entry)
- `docs/execution/06-scaffold-coverage-matrix.md` (update maturity row)
- `docs/execution/10-invariant-matrix.md` (add parity note on inv. 39/40/41)
- `docs/execution/14-final-gap-register.md` (mark GAP-001 progress/closure)
- `docs/execution/todo/apps-and-interfaces.md` (move APP-008 to COMPLETED)

**Validation commands (run all before committing)**

```bash
make swift-build
make swift-test
make ts-build
make ts-test
make validate-all
```

**Commit discipline**

Single commit. Include all source changes + all doc/tracking updates together.
Title format: `feat(cross-app): propagate AppSurfaceEnvelope into Sortio/CloudClinic adapters (APP-008, GAP-001)`

---

### T02 — OPS-003 Incident-response command set for first operator tools

- TODO id: `OPS-003` in `docs/execution/todo/ops-network-ml.md`
- Closure mapping: `GAP-002` (scaffold blocker)
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: High
- Skills: `docs/execution/skills/network-fabric-skill.md` +
  `docs/execution/skills/backup-restore-retention-export-skill.md`
- Owner modules: doc-only.
- Scope:
  - Define canonical operator action vocabulary mapping incidents to actions:
    - runtime failure: lifecycle states (`unhealthy`, `degraded`),
      retry exhaust, dead-letter routing.
    - queue saturation: async runtime backpressure, pause/resume, requeue.
    - backup concern: manifest hash mismatch, retention/legal-hold conflict,
      restore dry-run vs apply.
    - integrity incident: storage hash mismatch, deidentification map
      access, reidentification denial.
  - Map each action to existing observability event taxonomy
    (`runtime.*`, `job.*`, `backup.*`, `restore.*`, `export.*`,
    `retention.*`, `dr.*`, `regulatory.*`, `emergency_access.*`).
- Definition of done:
  - First operator tooling can map visible incidents to explicit action
    vocabulary by reading the runbook and observability contract alone.
  - Doc drift check passes (`scripts/check-docs.sh`).
- Files expected to change:
  - `docs/architecture/14-operations-runbook.md`
  - `docs/architecture/26-operator-observability-contract.md`
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/06-scaffold-coverage-matrix.md`
  - `docs/execution/10-invariant-matrix.md`
  - `docs/execution/todo/ops-network-ml.md` (move OPS-003 to COMPLETED)
- Validation:
  - `make validate-docs`
  - `make validate-all`
- Anti-overclaim:
  - No tooling claim. The deliverable is command vocabulary, not an
    implemented operator console.
- Risks if mishandled:
  - Naming actions that imply automation that does not exist.
  - Drift between runbook vocabulary and observability event kinds.

#### Coding agent prompt

You are implementing T02 (OPS-003) in the HealthOScaffold repository. This is a
documentation-only task that closes the second scaffold blocker (GAP-002). Read
this entire prompt before touching any file.

**Repository identity (never collapse)**

HealthOS is the whole platform. This repo is a scaffold — not production-ready,
not a real operator console, not a deployed system. All observability event kinds
referenced here are contract vocabulary, not live telemetry streams.

**Required reading before writing anything**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/14-final-gap-register.md` (GAP-002 is the blocker you close)
5. `docs/execution/todo/ops-network-ml.md` (find OPS-003 under READY)
6. `docs/execution/skills/network-fabric-skill.md`
7. `docs/execution/skills/backup-restore-retention-export-skill.md`
8. `docs/architecture/14-operations-runbook.md` — existing runbook; you extend it
9. `docs/architecture/26-operator-observability-contract.md` — existing
   observability contract; you extend it
10. `swift/Sources/HealthOSCore/BackupGovernance.swift` — backup event kinds
11. `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift` — async job states

**Task objective**

Close GAP-002 (scaffold blocker): first operators must be able to map any
visible incident to an explicit action vocabulary purely by reading the runbook
and observability contract, without guessing. No new tooling is implemented;
only the vocabulary and mapping are defined.

**Exact scope**

What to do in `docs/architecture/14-operations-runbook.md`:
- Add an "Incident-response command vocabulary" section covering four incident
  classes, each with:
  - trigger condition (what the operator sees in the observability surface)
  - matching observability event kind(s) from the taxonomy
  - canonical response action(s) with explicit semantics
  - escalation path (what to do if the action fails or is unavailable)

  The four incident classes:
  1. **Runtime failure** — signals: `runtime.unhealthy`, `runtime.degraded`,
     retry-exhaust event; actions: isolate node, drain queue to dead-letter,
     trigger lifecycle restart, emit `runtime.restart.requested`.
  2. **Queue saturation** — signals: `job.queue.saturated`, backpressure
     threshold breach; actions: pause ingestion (`job.ingest.paused`), inspect
     dead-letter (`job.dead-letter.inspect`), requeue after drain
     (`job.requeue.requested`).
  3. **Backup concern** — signals: `backup.integrity.mismatch`,
     `retention.legal_hold.conflict`, `backup.manifest.missing`; actions:
     halt automated restore (`restore.dry-run.only`), verify hash chain,
     escalate to retention policy review (`retention.review.requested`).
  4. **Integrity incident** — signals: `storage.hash.mismatch`,
     `deidentification.access.denied`, `reidentification.denial`; actions:
     freeze affected partition (`storage.partition.frozen`), initiate audit
     log export (`export.audit.requested`), deny further reidentification
     until cleared.

What to do in `docs/architecture/26-operator-observability-contract.md`:
- Add or extend an "Incident → event kind → action mapping" table that cross-
  references each incident class with its canonical event kind(s) from the
  existing taxonomy section.
- Ensure all event kinds named in the runbook appear in the observability
  contract taxonomy (add any that are missing, prefixed by existing namespace
  conventions: `runtime.*`, `job.*`, `backup.*`, `restore.*`, `export.*`,
  `retention.*`, `dr.*`).

What not to do:
- Do not implement an operator console, dashboard widget, or automated response
  runner. Vocabulary only.
- Do not invent event kind namespaces that differ from existing taxonomy conventions.
- Do not claim automation exists where it does not.
- Do not add any code files.

**Files to change (minimum)**

- `docs/architecture/14-operations-runbook.md`
- `docs/architecture/26-operator-observability-contract.md`
- `docs/execution/02-status-and-tracking.md` (add OPS-003 completed entry)
- `docs/execution/06-scaffold-coverage-matrix.md` (update ops row)
- `docs/execution/10-invariant-matrix.md` (add note on incident-response
  vocabulary coverage if a new invariant is warranted)
- `docs/execution/14-final-gap-register.md` (mark GAP-002 progress/closure)
- `docs/execution/todo/ops-network-ml.md` (move OPS-003 to COMPLETED)

**Validation commands**

```bash
make validate-docs
make validate-all
```

`scripts/check-docs.sh` must exit 0.

**Commit discipline**

Single commit. All doc + tracking changes together.
Title format: `docs(ops): define incident-response command vocabulary for operator tools (OPS-003, GAP-002)`

---

### T03 — RT-008 Runtime-boundary tests for user-agent and service-runtime adapters

- TODO id: `RT-008` in `docs/execution/todo/runtimes-and-aaci.md`
- Closure mapping: `GAP-009`
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: High
- Skills: `docs/execution/skills/async-runtime-skill.md` +
  `docs/execution/skills/aaci-skill.md`
- Owner modules:
  - `swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`
  - `swift/Sources/HealthOSCore/ServiceOperationsContracts.swift`
  - `swift/Sources/HealthOSAACI/AACI.swift` (boundary surfaces)
- Scope:
  - User-agent boundary negatives: prohibited clinical/regulatory capability,
    raw CPF/identifier leak, missing `lawfulContext`, scope drift, sensitive
    layer denial, informational-only output enforcement.
  - Service-runtime boundary negatives: cross-service leakage,
    queue-as-authorization rejection, gate bypass attempt,
    administrative task allowlist enforcement, draft-vs-final gate
    protection.
  - Boundary surfaces tested across app/aaci/gos/runtime layers where
    currently contract-only.
- Definition of done:
  - Boundary denials are tested across app/aaci/gos/runtime surfaces where
    currently contract-only.
  - Honesty preserved for stubs (no fabricated capabilities).
- Files expected to change:
  - `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift` (extend)
  - `swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift` (extend)
  - optional: new dedicated runtime-adapter boundary test file
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/06-scaffold-coverage-matrix.md`
  - `docs/execution/10-invariant-matrix.md`
  - `docs/execution/todo/runtimes-and-aaci.md` (move RT-008 to COMPLETED)
- Validation:
  - `make swift-test`
  - `make validate-all`
- Anti-overclaim:
  - Do not introduce real provider/runtime behavior; this is negative coverage.
- Risks if mishandled:
  - Tests that assert success paths without exercising deny paths.

#### Coding agent prompt

You are implementing T03 (RT-008) in the HealthOScaffold repository. This task
expands Swift XCTest negative coverage for user-agent and service-runtime
adapter boundaries. Read this entire prompt before touching any file.

**Repository identity (never collapse)**

HealthOS Core is sovereign. AACI/GOS/apps are subordinate. This repo is a
scaffold — not production-ready. Every stub must signal `unavailable`/`degraded`
honestly. Tests never fabricate provider output or simulate production calls.

**Required reading before writing any code**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/10-invariant-matrix.md` (focus on invariants 31–38)
5. `docs/execution/14-final-gap-register.md` (GAP-009)
6. `docs/execution/todo/runtimes-and-aaci.md` (find RT-008)
7. `docs/execution/skills/async-runtime-skill.md`
8. `docs/execution/skills/aaci-skill.md`
9. `swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`
10. `swift/Sources/HealthOSCore/ServiceOperationsContracts.swift`
11. `swift/Sources/HealthOSAACI/AACI.swift`
12. `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift`
13. `swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift`

**Task objective**

Close GAP-009: add boundary-negative XCTest coverage for the user-agent and
service-runtime adapter paths that are currently contract-only with no test
proving the deny path fires.

**Exact scope**

What to add in `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift`:
- Negative: user-agent request with prohibited capability (`diagnose`,
  `prescribe`, `referral`, `finalize_document`, `sign_document`) → denied.
- Negative: user-agent request with raw CPF in payload → denied.
- Negative: user-agent request missing `lawfulContext` → denied.
- Negative: user-agent scope drift (session-scoped request accessing a
  patient outside that session's scope) → denied.
- Negative: user-agent request targeting a sensitive storage layer without
  explicit policy → denied.
- Negative: user-agent response type not `informational-user-facing` → denied
  before delivery.

What to add in `swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift`:
- Negative: cross-service leakage attempt (service A context used to access
  service B queue) → denied.
- Negative: queue item used as authorization (attempt to skip `lawfulContext`
  check by presenting a queue entry) → denied.
- Negative: gate bypass attempt via service runtime (`finalize` without
  approved gate) → denied.
- Negative: administrative task outside the explicit allowlist → denied.
- Negative: draft document surfaced as final → denied.
- Positive: a well-formed administrative task in the allowlist with proper
  audit provenance → passes.

Invariants covered: 31, 32, 34, 35, 36, 37, 38.

What not to do:
- Do not add real STT/provider/embedding calls in tests.
- Do not create fake transcript content.
- Do not add success-only tests without the corresponding deny-path twin.
- Do not introduce new contract types; use existing `UserSovereigntyContracts`
  and `ServiceOperationsContracts` only.

**Files to change (minimum)**

- `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift` (extend)
- `swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift` (extend)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md` (mark RT-008 coverage row closed)
- `docs/execution/14-final-gap-register.md` (mark GAP-009 progress)
- `docs/execution/todo/runtimes-and-aaci.md` (move RT-008 to COMPLETED)

**Validation commands**

```bash
make swift-build
make swift-test
make validate-all
```

All new tests must pass. No new test may use `XCTAssertTrue(true)` or any
tautological assertion — every test must exercise a real deny-path branch in
the contracts.

**Commit discipline**

Single commit. Source + tracking docs together.
Title format: `test(runtime-boundary): expand negative coverage for user-agent and service-runtime adapters (RT-008, GAP-009)`

---

### T04 — DS-007 LawfulContext and layer-guard parity beyond first-slice

- TODO id: `DS-007` in `docs/execution/todo/data-storage.md`
- Closure mapping: `GAP-003` (post-scaffold hardening; SQL/object backend
  parity remains explicit future work and stays a non-claim)
- Phase: Scaffold RC Fixes + Tag Prep (file-backed parity only)
- Priority: High
- Skill: `docs/execution/skills/storage-data-layer-skill.md`
- Owner modules:
  - `swift/Sources/HealthOSCore/StorageContracts.swift`
  - `swift/Sources/HealthOSCore/FirstSliceServices.swift`
  - non-first-slice consumers across `swift/Sources/HealthOSCore/*`
- Scope:
  - Audit Core storage/retrieval/ops entrypoints outside the first-slice path.
  - Apply same fail-closed `lawfulContext` enforcement and layer-aware
    guards (identifier, operational, governance, derived,
    reidentification mapping) that file-backed first-slice already enforces.
  - Add parity tests for governed-vs-operational failure distinction at
    each newly covered call site.
- Definition of done:
  - Remaining Core storage/retrieval/ops entrypoints reuse the same
    fail-closed context/layer checks.
  - Tests prove parity for governed-vs-operational boundaries.
- Files expected to change:
  - `swift/Sources/HealthOSCore/*` (call sites needing parity)
  - test files extending storage-related coverage
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/06-scaffold-coverage-matrix.md`
  - `docs/execution/10-invariant-matrix.md`
  - `docs/execution/todo/data-storage.md` (move DS-007 to COMPLETED)
- Validation:
  - `make swift-test`
  - `make validate-all`
- Anti-overclaim:
  - SQL/object backend parity remains explicit future work; do not
    silently expand storage backend claims.

#### Coding agent prompt

You are implementing T04 (DS-007) in the HealthOScaffold repository. This task
propagates the `lawfulContext` enforcement and storage-layer guards already
present in the first-slice file-backed path to all other Core storage/retrieval
entrypoints. Read this entire prompt before touching any file.

**Repository identity (never collapse)**

HealthOS Core is sovereign. Storage law (lawfulContext, layer guards,
fail-closed denials) stays in Core and never moves to app or runtime layers.
SQL/object backend parity is explicitly post-scaffold work and must remain a
non-claim. File-backed first-slice is the reference implementation.

**Required reading before writing any code**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/10-invariant-matrix.md` (invariants 14, 15, 21, 23, 26)
5. `docs/execution/14-final-gap-register.md` (GAP-003 — note post-scaffold
   scope; file-backed parity is in-scope, SQL/object is not)
6. `docs/execution/todo/data-storage.md` (find DS-007)
7. `docs/execution/skills/storage-data-layer-skill.md`
8. `swift/Sources/HealthOSCore/StorageContracts.swift` — the contract types
9. `swift/Sources/HealthOSCore/FirstSliceServices.swift` — reference impl
10. `swift/Sources/HealthOSCore/BackupGovernance.swift` — adjacent contracts
11. All other files under `swift/Sources/HealthOSCore/` that expose storage,
    retrieval, or ops entrypoints to audit for missing guards

**Task objective**

Bring all non-first-slice Core storage/retrieval/ops entrypoints to the same
`lawfulContext` enforcement and `StorageLayer` guard posture that
`FileBackedStorageService` already applies. Add parity tests for each newly
covered call site, specifically proving that governed-vs-operational boundary
failures fire correctly.

**Exact scope**

What to do:
1. Audit every `put`, `get`, `list`, `audit`, `delete`, `export`, and
   `restore` call site in `swift/Sources/HealthOSCore/` that does not yet
   invoke `LawfulContextValidator` or check `StorageLayer` sensitivity.
2. At each uncovered call site:
   - Apply `LawfulContextRequirement` validation (fail closed if
     `actorRole`, `scope`, `finalidade`, `patientUserId`, or `serviceId`
     is missing where required).
   - Apply `StorageLayer` classification and deny sensitive layers
     (`directIdentifiers`, `reidentificationMapping`) without explicit policy.
3. Add XCTest cases for each newly covered call site proving:
   - missing `lawfulContext` → `CoreLawError` (not a silent nil/empty result)
   - `directIdentifiers` layer without policy → denied
   - `reidentificationMapping` layer without scope → denied
   - well-governed context with correct layer → passes

What not to do:
- Do not add SQL or object-store backend code — file-backed only.
- Do not remove or weaken existing first-slice guards.
- Do not introduce new storage abstraction layers or major refactors; minimal
  targeted parity changes only.
- Do not claim SQL/object parity in any doc, comment, or tracking entry.

**Files to change (minimum)**

- `swift/Sources/HealthOSCore/` (targeted call sites — identify via audit)
- Existing or new test files under `swift/Tests/HealthOSTests/` covering
  newly guarded call sites
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md` (update invariants 14, 15 parity row)
- `docs/execution/todo/data-storage.md` (move DS-007 to COMPLETED)

**Validation commands**

```bash
make swift-build
make swift-test
make validate-all
```

**Commit discipline**

Single commit. Source + tracking docs together.
Title format: `feat(storage): propagate lawfulContext and layer-guard parity beyond first-slice (DS-007)`

---

### T05 — APP-009 Documentation drift check for app-boundary claims

- TODO id: `APP-009` in `docs/execution/todo/apps-and-interfaces.md`
- Closure mapping: scaffold cleanup (no separate gap row)
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: Medium
- Blocked by: T01 (claims must reflect actual adapter posture).
- Skill: `docs/execution/skills/documentation-drift-skill.md`
- Scope:
  - Sync app docs (`11-scribe.md`, `12-sortio.md`, `13-cloudclinic.md`,
    `19-interface-doctrine.md`) and execution tracking
    (`06-scaffold-coverage-matrix.md`, `10-invariant-matrix.md`,
    `11-current-maturity-map.md`) on current maturity.
  - Ensure no final-UI claims and no production-ready phrasing.
  - Confirm `scripts/check-docs.sh` passes.
- Definition of done:
  - App docs and execution tracking agree on current maturity (no
    final-UI claims).
- Files expected to change: doc set above + `02-status-and-tracking.md`.
- Validation:
  - `make validate-docs`
  - `make validate-all`
- Anti-overclaim:
  - Drift fixes only; no scope expansion.

#### Coding agent prompt

You are implementing T05 (APP-009) in the HealthOScaffold repository. This is a
documentation drift-correction task. Read this entire prompt before touching
any file. **T01 (APP-008) must be completed before this task runs.**

**Repository identity (never collapse)**

HealthOS is the whole platform. App docs (Scribe, Sortio, CloudClinic) must
accurately reflect scaffold posture — no final-UI claims, no production-ready
phrasing, no false capability claims. This is a scaffold, not a product release.

**Required reading before writing anything**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/06-scaffold-coverage-matrix.md` — current maturity table
5. `docs/execution/11-current-maturity-map.md`
6. `docs/execution/10-invariant-matrix.md` (invariant 43: scaffold closure ≠
   product readiness)
7. `docs/execution/todo/apps-and-interfaces.md` (find APP-009)
8. `docs/execution/skills/documentation-drift-skill.md`
9. `docs/architecture/11-scribe.md`
10. `docs/architecture/12-sortio.md`
11. `docs/architecture/13-cloudclinic.md`
12. `docs/architecture/19-interface-doctrine.md`
13. `scripts/check-docs.sh` — understand what the drift check tests

**Task objective**

Ensure that app architecture docs and execution tracking docs agree on current
scaffold maturity with no production-ready or final-UI claims anywhere. Fix
drift discovered by reading each doc against the actual implementation state.

**Exact scope**

What to do:
1. For each of `11-scribe.md`, `12-sortio.md`, `13-cloudclinic.md`,
   `19-interface-doctrine.md`:
   - Remove or qualify any phrase that implies final UI delivery, production
     availability, or real provider/signature/interoperability behavior.
   - Replace absolute status language ("is implemented", "is available") with
     scaffold-honest phrasing ("scaffold contract present", "adapter seam
     wired", "stub signals unavailable").
   - Ensure each doc has a clear "Scaffold posture / non-claims" statement or
     equivalent section.
2. In `06-scaffold-coverage-matrix.md` and `11-current-maturity-map.md`:
   - Confirm maturity levels for Scribe/Sortio/CloudClinic rows reflect the
     current post-T01 state.
   - Add T01 closure as a maturity uplift if appropriate.
3. Run `scripts/check-docs.sh` and fix every failure it surfaces.

What not to do:
- Do not add new features or expand any adapter scope.
- Do not remove accurate scaffold-posture descriptions.
- Do not alter `10-invariant-matrix.md` unless a direct drift correction is
  required (this is a separate invariant file, not an app doc).
- Do not introduce new architecture decisions; correct phrasing only.

**Files to change (minimum)**

- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md` (move APP-009 to COMPLETED)

**Validation commands**

```bash
make validate-docs
make validate-all
```

`scripts/check-docs.sh` must exit 0.

**Commit discipline**

Single commit. Doc + tracking changes together.
Title format: `docs(apps): correct documentation drift for app-boundary maturity claims (APP-009)`

---

### T06 — AACI-009 Honest capability signaling for transcription/retrieval

- TODO id: `AACI-009` in `docs/execution/todo/runtimes-and-aaci.md`
- Closure mapping: scaffold cleanup
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: Medium
- Skills: `docs/execution/skills/aaci-skill.md` +
  `docs/execution/skills/provider-governance-skill.md`
- Owner modules:
  - `swift/Sources/HealthOSAACI/AACI.swift`
  - `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift`
  - `swift/Sources/HealthOSProviders/*`
- Scope:
  - Make sure transcription path signals `unavailable` / `degraded` truth
    instead of fabricating transcripts when STT is stubbed.
  - Make sure retrieval semantic mode signals `unavailable` /
    `lexical-fallback` posture instead of inventing semantic scores.
  - Align doc claims, contract enums, and tests on this signaling.
- Definition of done:
  - Docs/contracts/tests align on `unavailable`/`degraded` truth without
    semantic/provider over-claims.
- Files expected to change:
  - source files above
  - `swift/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift`
    and/or `ProviderGovernanceTests.swift`
  - `docs/architecture/09-aaci.md`
  - `docs/architecture/16-providers-and-ml.md`
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/06-scaffold-coverage-matrix.md`
  - `docs/execution/10-invariant-matrix.md`
  - `docs/execution/todo/runtimes-and-aaci.md` (move AACI-009 to COMPLETED)
- Validation:
  - `make swift-test`
  - `make validate-all`
- Anti-overclaim:
  - Do not introduce provider integration; only honesty hardening.

#### Coding agent prompt

You are implementing T06 (AACI-009) in the HealthOScaffold repository. This
task hardens capability honesty for transcription and retrieval paths without
introducing any real provider. Read this entire prompt before touching any file.

**Repository identity (never collapse)**

Stubs remain stubs and signal `unavailable`/`degraded` — they never fabricate
output. Semantic retrieval is unavailable by design until a real embedding
provider is integrated. STT is unavailable by design until a real STT provider
is integrated. No provider integration is in scope for this task.

**Required reading before writing any code**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/10-invariant-matrix.md` (invariants 18, 21, 22, 23)
5. `docs/execution/todo/runtimes-and-aaci.md` (find AACI-009)
6. `docs/execution/skills/aaci-skill.md`
7. `docs/execution/skills/provider-governance-skill.md`
8. `swift/Sources/HealthOSAACI/AACI.swift`
9. `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift`
10. `swift/Sources/HealthOSProviders/StubProviders.swift`
11. `swift/Tests/HealthOSTests/ProviderGovernanceTests.swift`
12. `docs/architecture/09-aaci.md`
13. `docs/architecture/16-providers-and-ml.md`

**Task objective**

Ensure that:
1. The AACI transcription path returns `unavailable`/`degraded` status (not
   fabricated text) when no real STT provider is present and the input is not
   seeded text.
2. The retrieval path returns `unavailable` for semantic/hybrid mode when no
   embedding provider is registered; lexical fallback is explicitly labeled
   `lexical-deterministic` (not `semantic`).
3. Docs and tests confirm this signaling without overpromising.

Invariant 18: speech stub never generates "real" transcript text.
Invariant 22: without embedding provider, no semantic score is fabricated.
Invariant 23: app-facing retrieval payload never carries direct identifiers.

**Exact scope**

What to do in source:
- In `AACI.swift` transcription path: verify the stub STT branch returns a
  result with `status: .unavailable` or `.degraded` and `provenance:
  seeded-text` only for seeded inputs. If the code fabricates text for
  non-seeded audio, remove or guard that branch.
- In `RetrievalMemoryGovernance.swift` semantic/hybrid branch: verify the code
  returns `unavailable` when no embedding provider is registered. If it
  currently returns a fake score, replace with `unavailable` or
  `lexical-fallback` with explicit marking.
- In `StubProviders.swift`: confirm stub STT documents its `seeded-text` vs
  `unavailable` behavior clearly (no silent mixed paths).

What to do in tests:
- Extend `ProviderGovernanceTests.swift` or `RetrievalMemoryGovernanceTests.swift`:
  - `testAudioWithoutRealSTTReturnsUnavailableOrDegraded` (if not already present)
  - `testSemanticQueryWithoutEmbeddingProviderReturnsUnavailable` (if not present)
  - `testLexicalFallbackIsMarkedDeterministicNotSemantic`
  - `testSeededTextNotMarkedAsAudioTranscription`

What to do in docs:
- In `docs/architecture/09-aaci.md`: add or verify a "Capability honesty"
  section that states STT and semantic retrieval are unavailable/degraded in
  scaffold mode and documents the signaling contract.
- In `docs/architecture/16-providers-and-ml.md`: align provider capability
  claims with actual stub behavior; remove any phrasing that implies a working
  semantic retrieval pipeline.

What not to do:
- Do not add a real STT or embedding provider.
- Do not widen the seeded-text path to cover real audio.
- Do not invent semantic scores even as "placeholder".

**Files to change (minimum)**

- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift`
- `swift/Sources/HealthOSProviders/StubProviders.swift`
- `swift/Tests/HealthOSTests/ProviderGovernanceTests.swift` (extend)
- `docs/architecture/09-aaci.md`
- `docs/architecture/16-providers-and-ml.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/todo/runtimes-and-aaci.md` (move AACI-009 to COMPLETED)

**Validation commands**

```bash
make swift-build
make swift-test
make validate-all
```

**Commit discipline**

Single commit. Source + doc + tracking changes together.
Title format: `fix(aaci): enforce unavailable/degraded signaling for stub STT and semantic retrieval (AACI-009)`

---

### T07 — CL-006 Shared error envelope for local service boundaries

- TODO id: `CL-006` in `docs/execution/todo/core-laws.md`
- Closure mapping: post-scaffold hardening (acceptable to land before tag)
- Phase: Scaffold RC Fixes + Tag Prep (optional inclusion)
- Priority: Medium
- Skill: `docs/execution/skills/core-law-skill.md`
- Scope:
  - Decide whether denied/failure outputs share one transport envelope at
    the Swift ↔ TS loopback HTTP seam from ADR 0006.
  - Document success/deny/failure outcome representation consistently.
  - If approved, add a minimal schema under `schemas/contracts/` (e.g.,
    `service-boundary-outcome.schema.json`).
- Definition of done:
  - Local service boundary can represent success, deny, and failure
    outcomes consistently.
- Files expected to change:
  - `docs/architecture/06-core-services.md`
  - optional: new contract under `schemas/contracts/`
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/todo/core-laws.md`
- Validation:
  - `make validate-schemas`
  - `make validate-docs`
  - `make validate-all`
- Anti-overclaim:
  - This is an envelope decision, not an implementation claim.

#### Coding agent prompt

You are implementing T07 (CL-006) in the HealthOScaffold repository. This task
defines a consistent error/outcome envelope for the Swift ↔ TypeScript local
service boundary (loopback HTTP seam). Read this entire prompt before touching
any file.

**Repository identity (never collapse)**

HealthOS is the whole platform. The Swift ↔ TS loopback (ADR 0006) is a local
service seam, not a public API. This task defines envelope vocabulary only — it
does not claim a deployed service or runtime transport implementation.

**Required reading before writing anything**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/todo/core-laws.md` (find CL-006)
5. `docs/execution/skills/core-law-skill.md`
6. `docs/architecture/06-core-services.md` — the loopback seam description
7. `docs/adr/0006-*.md` — ADR that established the Swift ↔ TS loopback
8. `schemas/contracts/` — existing schema conventions for formatting reference
9. `ts/packages/contracts/src/index.ts` — existing TS contract types

**Task objective**

Define a typed outcome envelope for the local Swift ↔ TS service boundary that
covers success, deny, and failure outcomes consistently. If the decision is that
all three share a single envelope (with a discriminant field), produce a minimal
JSON Schema and matching TypeScript/Swift types. If the decision is to keep them
separate, document the explicit representation for each outcome type.

**Exact scope**

Decision to make and document:
- Does `success` / `deny` / `failure` share one envelope type with a
  `"outcome": "success" | "deny" | "failure"` discriminant field?
- Or are they separate typed responses at the HTTP seam?

Recommendation: use a single `ServiceBoundaryOutcome` envelope with:
- `outcome: "success" | "deny" | "failure"`
- `payload?: {}` (present only on success, opaque)
- `denyReason?: string` (present only on deny, typed enum or string)
- `errorKind?: string` (present only on failure, typed enum)
- `errorMessage?: string` (human-readable on failure, not surfaced to patient)

If this recommendation is adopted:
1. Add `schemas/contracts/service-boundary-outcome.schema.json` with the
   above structure (draft-07 JSON Schema, consistent with repo conventions).
2. Add the matching TypeScript type to `ts/packages/contracts/src/index.ts`.
3. Add a brief Swift struct or enum to `swift/Sources/HealthOSCore/` if the
   loopback seam has a Swift side.
4. Update `docs/architecture/06-core-services.md` with the outcome
   representation decision and a reference to the schema.

If a different decision is made, document it explicitly with rationale.

What not to do:
- Do not implement a running HTTP server or client — envelope only.
- Do not claim production delivery of the loopback transport.
- Do not introduce new architecture layers beyond this envelope contract.

**Files to change (minimum)**

- `docs/architecture/06-core-services.md`
- `schemas/contracts/service-boundary-outcome.schema.json` (new, if approved)
- `ts/packages/contracts/src/index.ts` (add type if approved)
- `swift/Sources/HealthOSCore/` (add struct if Swift side is relevant)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/core-laws.md` (move CL-006 to COMPLETED)

**Validation commands**

```bash
make validate-schemas
make validate-docs
make validate-all
```

**Commit discipline**

Single commit. Schema + source + doc + tracking changes together.
Title format: `feat(core): define shared outcome envelope for local service boundary (CL-006)`

---

### T08 — GAP-010 Wire `make validate-all` into CI

- TODO id: not in TODO files — derived from `14-final-gap-register.md`
  (`GAP-010`) and `12-next-agent-handoff.md` priority 3.
- Closure mapping: `GAP-010` (optional enhancement; does not block scaffold
  RC closure but raises distributed evidence quality)
- Phase: Post-scaffold hardening 04
- Priority: Medium
- Skill: `docs/execution/skills/project-steward-skill.md` (tooling) +
  ops doc references for run-cost honesty
- Scope:
  - Add a CI workflow that runs the same gates as `make validate-all`
    plus `swift test`, `ts test`, `python -m compileall .`, and smoke
    (`make smoke-cli`, `make smoke-scribe`).
  - Mirror exit semantics: any failure fails the workflow.
  - Do not declare production readiness in CI metadata or badges.
- Definition of done:
  - CI runs `validate-all` on PR and on `main` push.
  - `validate-all` is mirrored faithfully (no skipped gates).
- Files expected to change:
  - new `.github/workflows/validate.yml`
  - `docs/execution/02-status-and-tracking.md`
  - `docs/execution/15-scaffold-finalization-plan.md`
  - `docs/execution/14-final-gap-register.md` (mark GAP-010 progress)
- Validation:
  - first CI run green on a `main` push or PR.
- Anti-overclaim:
  - Workflow status equals local harness status; no extra production claim.

#### Coding agent prompt

You are implementing T08 (GAP-010) in the HealthOScaffold repository. This task
wires the local `make validate-all` validation harness into a GitHub Actions CI
workflow. Read this entire prompt before touching any file.

**Repository identity (never collapse)**

CI is a distributed gate that mirrors local harness quality — it is not a
production deployment pipeline, a compliance certificate, or a readiness claim.
The CI status badge (if added) must never be interpreted as product readiness.

**Required reading before writing any file**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/14-final-gap-register.md` (GAP-010 description)
4. `docs/execution/15-scaffold-finalization-plan.md` (validation gate list)
5. `Makefile` — read fully to understand what each target does and what
   commands it runs
6. `scripts/check-docs.sh`, `scripts/validate-schemas.sh`,
   `scripts/check-contract-drift.sh` — understand their exit semantics
7. `.github/` directory — see if any existing workflow files are present

**Task objective**

Add `.github/workflows/validate.yml` that:
- Triggers on push to `main` and on any pull request.
- Runs exactly the same gates as `make validate-all`, in the same order,
  without skipping any.
- Also runs `make swift-build`, `make swift-test`, `make ts-build`,
  `make ts-test`, `make python-check`, and smoke paths if available.
- Fails the workflow if any step exits non-zero.
- Does not claim production readiness in any job name, step name, or comment.

**Exact scope**

Workflow file `.github/workflows/validate.yml`:
- `name: Validate scaffold`
- `on: [push (main), pull_request]`
- `jobs.validate.runs-on: ubuntu-latest` (or `macos-latest` if Swift
  requires it for the XCTest suite — check `.swift-version` or `Package.swift`
  to determine minimum platform)
- Steps in order:
  1. `actions/checkout@v4`
  2. Set up Swift (use `swift-actions/setup-swift` or the appropriate action
     for the version in `swift/Package.swift`)
  3. Set up Node.js (use `actions/setup-node@v4` with the version from
     `ts/package.json` or `.nvmrc`)
  4. Set up Python (use `actions/setup-python@v5` with version from
     `python/` or `pyproject.toml`)
  5. `make bootstrap` (installs dependencies)
  6. `make validate-docs`
  7. `make validate-schemas`
  8. `make validate-contracts`
  9. `make swift-build`
  10. `make swift-test`
  11. `make ts-build`
  12. `make ts-test`
  13. `make python-check`
  14. `make smoke-cli` (if defined in Makefile and non-interactive)
  15. `make smoke-scribe` (if defined and non-interactive)

Known environment divergences to document (do not suppress with `continue-on-error`
unless the failure is pre-classified as a non-regression):
- `scripts/check-docs.sh` requires bash ≥ 4 (`mapfile` command).
  On `ubuntu-latest` this is fine. On `macos-latest` it may fail unless
  bash is upgraded; use `ubuntu-latest` for the workflow runner unless Swift
  tests require macOS.
- `make swift-test` requires Xcode (not bare swift toolchain). If using
  `ubuntu-latest`, Linux Swift builds run without XCTest issue; if macOS is
  required, use `macos-latest`.
- Python smoke paths use `python3`, not `python`; confirm `make python-check`
  uses `python3`.

What not to do:
- Do not add deployment steps, Docker builds, or cloud infrastructure.
- Do not add a badge claiming "production ready" — CI green means harness
  passes, nothing more.
- Do not skip gates to make CI green; fix the underlying issue or explicitly
  classify the failure as pre-existing with a comment.
- Do not use `continue-on-error: true` broadly.

**Files to change (minimum)**

- `.github/workflows/validate.yml` (new)
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/14-final-gap-register.md` (mark GAP-010 progress)
- `docs/execution/15-scaffold-finalization-plan.md` (add CI gate reference)

**Validation**

First CI run on `main` push or PR must be green or every failure must be
classified as a pre-existing non-regression with a `# pre-existing: <reason>`
comment in the workflow file.

**Commit discipline**

Single commit. Workflow + tracking docs together.
Title format: `ci: wire validate-all gates into GitHub Actions (GAP-010)`

---

### T09 — Scaffold RC tag prep and closure

- TODO id: not a single TODO; orchestrates closure per
  `15-scaffold-finalization-plan.md`.
- Closure mapping: scaffold closure decision rule from
  `13-scaffold-release-candidate-criteria.md`.
- Phase: Scaffold RC Fixes + Tag Prep
- Priority: High once T01–T03 close
- Blocked by: T01, T02, T03 (blockers must close or be explicitly accepted).
- Scope:
  - Run the full validation gate from `15-scaffold-finalization-plan.md`:
    - `make validate-all`
    - `cd swift && swift build && swift test`
    - `cd ts && npm install && npm run build && npm test --if-present`
    - `cd python && python -m compileall .`
    - `cd swift && swift run HealthOSCLI && swift run HealthOSScribeApp --smoke-test`
  - Reconcile entry docs (`README.md`, `AGENTS.md`, `CLAUDE.md`) and
    execution docs (`02-`, `06-`, `10-`, `11-`, `12-`, `13-`, `14-`,
    `15-`) so maturity claims agree.
  - Tag `scaffold-rc-1` on `main` only after blockers close or are
    explicitly accepted with owner and milestone in
    `14-final-gap-register.md`.
- Definition of done:
  - Tag created on `main`.
  - Entry docs synchronized.
  - Closure PR (or direct main commits, given solo workflow) mergeable per
    `15-` criteria.
- Files expected to change: doc set listed in `15-scaffold-finalization-plan.md`.
- Validation:
  - full validation gate above is green or every failure is explicitly
    classified per `15-` Validation criteria block.
- Anti-overclaim:
  - Never tag without honest closure of GAP-001 and GAP-002.
  - Tag name must encode scaffold (`scaffold-rc-N`), not product release.

#### Coding agent prompt

You are executing T09 (scaffold RC tag prep and closure) in the HealthOScaffold
repository. This is the orchestration task that closes the scaffold-rc-1 tag.
It must not run until T01, T02, and T03 are all merged to `main`.

Read this entire prompt before running any command or editing any file.

**Repository identity (never collapse)**

`scaffold-rc-1` is a scaffold tag, not a product release. It means all planned
scaffold contracts, governance coverage, and execution docs are coherent and
honestly classified — nothing more. GAP-001 and GAP-002 must be closed or
explicitly accepted before tagging. GAP-004 through GAP-009 remain as
non-claims in all entry docs.

**Required reading before any action**

In order:
1. `CLAUDE.md`
2. `docs/execution/01-agent-operating-protocol.md`
3. `docs/execution/02-status-and-tracking.md`
4. `docs/execution/06-scaffold-coverage-matrix.md`
5. `docs/execution/10-invariant-matrix.md`
6. `docs/execution/11-current-maturity-map.md`
7. `docs/execution/12-next-agent-handoff.md`
8. `docs/execution/13-scaffold-release-candidate-criteria.md` — the closure
   decision rule; read every criterion carefully
9. `docs/execution/14-final-gap-register.md` — GAP-001 and GAP-002 must show
   `scaffold blocker` resolved or explicitly accepted with rationale
10. `docs/execution/15-scaffold-finalization-plan.md` — the full gate sequence
    you must execute
11. `README.md`, `AGENTS.md` — entry docs you will sync

**Prerequisite gate (abort if not met)**

Verify all of the following before proceeding:
- T01 (APP-008) is merged to `main` and GAP-001 shows `resolved` or
  `explicitly accepted` in `14-final-gap-register.md`.
- T02 (OPS-003) is merged to `main` and GAP-002 shows `resolved` or
  `explicitly accepted`.
- T03 (RT-008) is merged to `main` and GAP-009 shows `resolved` or
  `explicitly accepted`.
- `docs/execution/02-status-and-tracking.md` shows all three as completed.

If any prerequisite is not met, stop and record the blocker in
`docs/execution/02-status-and-tracking.md`. Do not tag.

**Execution sequence**

Step 1: Run the full validation gate.
```bash
make validate-all
make swift-build
make swift-test
make ts-build
make ts-test
make python-check
make smoke-cli
make smoke-scribe
```

Record every failure with its pre-existing classification or as a new
regression. If a regression is found, stop and fix it (or raise it as a
blocker) before continuing.

Step 2: Reconcile entry docs.

For `README.md`, `AGENTS.md`, `CLAUDE.md`:
- Verify no production-ready, final-UI, or real-provider claims.
- Verify scaffold-rc-1 closure milestone is mentioned with accurate scope.
- Verify non-claim language matches `13-scaffold-release-candidate-criteria.md`.

For execution docs (`02-`, `06-`, `10-`, `11-`, `12-`, `13-`, `14-`, `15-`):
- Verify all task completion entries are present.
- Verify gap register reflects current status accurately.
- Verify maturity map rows are coherent with coverage matrix.

Step 3: Commit the final doc sync to `main`.

Step 4: Create the git tag.
```bash
git tag -a scaffold-rc-1 -m "Scaffold RC 1: all planned governance contracts coherent and honestly classified (not a product release)"
git push origin scaffold-rc-1
```

Step 5: Update `docs/execution/02-status-and-tracking.md` with the tag event
and push.

What not to do:
- Do not tag without completing Step 1 and Step 2.
- Do not use tag names that imply product release (`v1.0`, `release-1`, etc.).
- Do not suppress validation failures with `--no-verify` or by commenting
  out checks.
- Do not mark GAP-004 through GAP-009 as resolved — they are post-scaffold
  and must remain as non-claims.

**Files to change (minimum)**

- `README.md` (sync)
- `AGENTS.md` (sync)
- `CLAUDE.md` (sync if needed)
- All execution docs under `docs/execution/` (sync as needed)
- `docs/execution/14-final-gap-register.md` (final status)
- `docs/execution/15-scaffold-finalization-plan.md` (mark gate complete)

**Validation**

All gates in Step 1 must exit 0 or every non-zero exit must be classified as
pre-existing non-regression with explicit documentation in the finalization plan.

**Commit discipline**

Final sync commit before tag:
Title format: `chore(closure): sync entry and execution docs for scaffold-rc-1 tag prep`

---

### T10 — Steward provider follow-up: typed errors and output formatting

**Status: completed 2026-04-27** (tracked as `ML-008` in `docs/execution/todo/ops-network-ml.md`).

- TODO id: not a single TODO; derived from `12-next-agent-handoff.md`
  (`Steward provider follow-up`).
- Closure mapping: post-scaffold hardening (non-blocking).
- Phase: Post-scaffold hardening
- Priority: Low
- Skill: `docs/execution/skills/project-steward-skill.md`
- Owner modules: `ts/packages/healthos-steward/src/providers/*` and tests.
- Scope:
  - Improve adapter-specific error typing for OpenAI/Anthropic/xAI
    (auth error vs rate-limit vs schema-mismatch vs network vs server).
  - Improve output extraction robustness without weakening the existing
    real-output-only PR comment guarantee.
  - Keep dry-run path explicit and provider gating on
    `--provider` + `--allow-network` unchanged.
- Definition of done:
  - Typed error categories per adapter.
  - Consistent output extraction across providers.
  - Tests cover new error paths via mocked `fetch` only.
- Files expected to change:
  - `ts/packages/healthos-steward/src/providers/openai.ts`
  - `ts/packages/healthos-steward/src/providers/anthropic.ts`
  - `ts/packages/healthos-steward/src/providers/xai.ts`
  - `ts/packages/healthos-steward/test/providers.test.mjs`
  - `docs/architecture/44-project-steward-agent.md`
  - `docs/execution/02-status-and-tracking.md`
- Validation:
  - `make ts-test` (or workspace-scoped `npm test --workspace @healthos/steward`)
- Anti-overclaim:
  - No autonomy creep; no default network calls; no PR posting by default.

**Closure summary (2026-04-27):**
- `errorKind` union expanded from 12 to 17 typed cases; `formatStewardReviewComment` added with marker/header/footer and empty-body refusal; mode-aware extractors per provider (Responses/Messages/chatCompletions); `node:test` raised from 12 to 33 cases without live network. Cross-language documentation synchronized (architecture 44, status, todo ops-network-ml ML-008, project-state.json).

#### Coding agent prompt

T10 is **already completed** (2026-04-27, ML-008). Do not re-implement.

If you need the implementation reference, read:
- `ts/packages/healthos-steward/src/providers/types.ts` — expanded
  `StewardLLMFailure['errorKind']` union (17 cases) and `StewardReviewMetadata`
- `ts/packages/healthos-steward/src/providers/utils.ts` — mode-aware
  extractors, `classifyHttpError`, `classifyNetworkError`,
  `formatStewardReviewComment`
- `ts/packages/healthos-steward/test/providers.test.mjs` — 33 test cases
- `docs/execution/todo/ops-network-ml.md` ML-008 entry for outcome summary

If a follow-up steward task is needed, derive it as a new task and do not
modify the ML-008 closure record.

---

## Validation discipline that applies to every task

After each task closes:

```bash
make validate-all
make swift-test
make ts-test
make python-check
make smoke-cli
make smoke-scribe
```

Update in the same commit as the change:

- `docs/execution/02-status-and-tracking.md`
- the relevant `docs/execution/todo/*.md` entry (move from `READY` to `COMPLETED` with `Outcome:` and `Files touched:`)
- `docs/execution/06-scaffold-coverage-matrix.md` if maturity classification shifts
- `docs/execution/10-invariant-matrix.md` if a new invariant or test parity is enforced
- `docs/execution/14-final-gap-register.md` if a gap closes or downgrades

## Anti-overclaim posture (carry through every task)

- No fictitious clinical stories or demo narratives.
- No production-ready, real provider, real signature, real
  interoperability, or real semantic retrieval claims.
- Stubs remain stubs and signal `unavailable`/`degraded` honestly.
- No raw direct identifiers in app-facing surfaces.
- Every unresolved contradiction or gap is recorded explicitly.

## Cross-references

- `README.md`, `AGENTS.md`, `CLAUDE.md`
- `docs/execution/00-master-plan.md`
- `docs/execution/01-agent-operating-protocol.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`
- `docs/execution/skills/*.md`
