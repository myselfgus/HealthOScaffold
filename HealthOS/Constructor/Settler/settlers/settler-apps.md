# Settler Profile: settler-apps

This profile narrows a Settler's attention to the Stages and Interfaces territory of the HealthOS repository. Scribe, Veridia, and CloudClinic are governed Stage surfaces that consume Core-mediated and GOS-mediated output. They are not law engines, not clinical authorities, and not storage owners. This Settler ensures that Boundary contracts remain aligned with mediated surfaces and that no Stage claims authority it does not hold.

---

## territory-id

`apps`

References Territory record: `HealthOS/Constructor/Settler/territories/apps.json`

---

## profile-id

`settler-apps`

---

## description

Settler for Stage surfaces and Boundary contracts. Responsible for maintaining Scribe, Veridia, and CloudClinic as non-authoritative interface consumers, ensuring safe-reference navigation, cross-Stage shared envelope discipline, and Stage non-authority posture. Ensures that no Stage leaks direct identifiers or claims final clinical authority.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `HealthOS/Shared/docs/architecture/11-scribe.md` — Scribe Stage design, capture, transcription, draft review surface
2. `HealthOS/Shared/docs/architecture/12-veridia.md` — Veridia Stage design, patient health identity surface
3. `HealthOS/Shared/docs/architecture/13-cloudclinic.md` — CloudClinic Stage design, encounter surface
4. `HealthOS/Shared/docs/architecture/19-interface-doctrine.md` — interface doctrine: Stage non-authority, safe refs, mediated surfaces
5. `HealthOS/Shared/docs/architecture/43-cross-app-coordination-shared-surfaces.md` — cross-Stage coordination and shared envelope contracts
6. `HealthOS/Shared/docs/execution/10-invariant-matrix.md` — invariants for Boundary and non-authority posture
7. `HealthOS/Shared/docs/execution/skills/scribe-skill.md` — Scribe engineering skill reference (if present)

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/` — Scribe Stage Swift source
- `HealthOS/Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage/` — Veridia Stage Swift source
- `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage/` — CloudClinic Stage Swift source
- `HealthOS/Tier1-Mestral-Core/Schemas/` — Stage-facing schema contracts and shared envelopes
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — Stages domain TODO tracker (path retained for compatibility)

Forbidden paths (must not propose writes here):

- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` — Core law (read-only; changes require Core Settler)
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/` — AACI runtime (requires AACI Settler)
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/` — Session Runtime (requires AACI/core-law Settler)
- `HealthOS/Constructor/ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. Stages are interface surfaces only. No Stage (Scribe, Veridia, CloudClinic) owns Core law, storage law, consent, habilitation, gate, finality, or provenance.
2. Stage navigation references (safe refs) must not grant data access. A safe ref is a pointer, not a data carrier.
3. Direct identifiers (CPF, patient keys) must never appear in Stage-facing surfaces, navigation payloads, or API responses.
4. Stage UI state must not be treated as clinical authority. A practitioner reviewing a draft in the Stage is not equivalent to a Core-approved gate resolution.
5. Cross-Stage shared envelopes must remain non-clinical: they carry coordination metadata, not clinical payloads.
6. Scaffold maturity UI (mock screens, placeholder workflows) must never be described as production-ready or final clinical UX.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Implementing Core law, storage law, consent, habilitation, gate, or finality logic inside any Stage.
2. Exposing raw direct identifiers (CPF, patient ID) in Stage-facing screens, navigation URLs, or shared Stage payloads.
3. Treating navigation ref as a data grant — following a safe ref must never bypass Core mediation.
4. Claiming a final clinical UI or production-ready patient-facing interface exists from scaffold-maturity code.
5. Allowing any Stage to resolve a clinical gate, approve a final artifact, or bypass the Core approval workflow.
6. Writing demo narratives or fictional clinical stories that imply real patient data exists in these Stage surfaces.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make swift-build
make swift-test
make validate-all
```

For Scribe UI or session flow changes:
```bash
cd HealthOS && swift run HealthOSScribeStage --smoke-test
```

For Veridia changes:
```bash
cd HealthOS && swift run HealthOSVeridiaStage --smoke-test
```

For CloudClinic changes:
```bash
cd HealthOS && swift run HealthOSCloudClinicStage --smoke-test
```

For documentation-only changes:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No Boundary Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Stage surface components have varying maturity (see Territory record `apps.json`; id retained for compatibility), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` reflecting task status.
3. Verification evidence that `make swift-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. For UI-bearing changes: explicit smoke-test evidence from the relevant Stage smoke target.
5. Explicit residual-gap record for any Stage contract or UI flow that remains scaffolded or unimplemented.
6. No production-readiness or final-clinical-UX claims.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement Stage UI or session logic. It does not make any Stage a clinical authority or allow any Stage to own Core law. Official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`) remain canonical.
