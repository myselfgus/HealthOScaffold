# Next 10 actions plan (2026-04-26)

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

---

### T10 — Steward provider follow-up: typed errors and output formatting

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
