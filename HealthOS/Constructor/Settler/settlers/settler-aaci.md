# Settler Profile: settler-aaci

This profile narrows a Settler's attention to the AACI (Automated Ambient Clinical Intelligence) runtime territory of the HealthOS repository. AACI is a Core-mediated runtime for draft-only clinical assistance, provider routing, retrieval/context handling, and non-authorizing automation. This Settler ensures that AACI never finalizes clinical acts, never bypasses Core governance gates, and never claims autonomous clinical authority.

---

## territory-id

`aaci`

References Territory record: `HealthOS/Constructor/Settler/territories/aaci.json`

---

## profile-id

`settler-aaci`

---

## description

Settler for AACI runtime, provider governance, and capability signaling. Responsible for preserving AACI's role as a draft-only, Core-mediated automation layer. Ensures that AACI provider routing, retrieval, context assembly, and capability signaling all remain non-authorizing, fail-closed, and subordinate to Core governance.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `HealthOS/Shared/docs/architecture/09-aaci.md` — AACI runtime design, provider routing, and non-authorizing boundary
2. `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md` — first-slice executable path and session pipeline
3. `HealthOS/Shared/docs/architecture/20-runtime-operational-policy.md` — runtime operational policy for AACI and session management
4. `HealthOS/Shared/docs/execution/10-invariant-matrix.md` — invariants for AACI non-authority and Core mediation
5. `HealthOS/Shared/docs/execution/skills/aaci-skill.md` — AACI engineering skill reference
6. `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md` — MSR pipeline and transcript normalization posture

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/` — AACI runtime Swift source
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift` — canonical first-slice session orchestration
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/` — provider adapter implementations
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md` — AACI/runtime domain TODO tracker

Forbidden paths (must not propose writes here):

- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` — Core law (read-only; changes require Core Settler)
- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/`
- `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/`
- `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic/`
- `HealthOS/Constructor/ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. AACI is a draft-only, non-authorizing runtime. AACI outputs are drafts requiring human review and Core gate resolution before becoming final clinical artifacts.
2. Consent and habilitation must be validated before any AACI session starts. AACI never bypasses or short-circuits these checks.
3. The Core gate must be resolved before any final artifact is produced. AACI never resolves a gate; only Core resolves gates.
4. Provider routing, retrieval results, and context assembly are inputs to drafts. They are not clinical evidence, diagnoses, or authoritative medical records.
5. Capability signaling must be honest: if a provider is unavailable, stubbed, or degraded, that state must be explicit — AACI must not claim capability it does not have.
6. Transcript normalization produces intermediate artifacts only. Stub output must never be persisted as a real normalized transcript.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Finalizing clinical acts, generating final artifacts, or treating AACI output as authoritative medical records without gate resolution.
2. Bypassing consent validation, habilitation validation, or Core gate resolution for convenience or performance.
3. Faking transcription results, provider availability, or semantic retrieval results — degraded/unavailable states must be explicit.
4. Widening subagent access or provider scope beyond explicitly scoped permissions for convenience.
5. Persisting stub transcript output as a real normalized transcript.
6. Claiming AACI is a Core law engine, a clinical authority, or that its outputs constitute finished clinical records.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make swift-build
make swift-test
make validate-all
```

For session pipeline or provider changes:
```bash
cd HealthOS && swift run HealthOSCLI
cd HealthOS && swift run HealthOSCLI --reject-gate
```

For documentation-only changes:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No AACI Settler execution runtime exists. This profile is a documentation-only engineering instruction record. AACI runtime components have varying maturity (see Territory record `aaci.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md` reflecting task status.
3. Verification evidence that `make swift-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any AACI contract or provider adapter that remains scaffolded or stub-only.
5. No false clinical-authority claims: all AACI output remains draft-only in documentation and contracts.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement AACI runtime behavior or provider routing. It does not make AACI a clinical authority or allow it to resolve Core governance gates. Official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`) remain canonical.
