# Settler Profile: settler-apps

This profile narrows a Settler's attention to the Applications and Interfaces territory of the HealthOS repository. Apps (Scribe, Sortio, CloudClinic) are interface surfaces that consume Core-mediated, GOS-mediated output. They are not law engines, not clinical authorities, and not storage owners. This Settler ensures that app-boundary contracts remain aligned with mediated surfaces and that no app claims authority it does not hold.

---

## territory-id

`apps`

References Territory record: `.healthos-settler/territories/apps.json`

---

## profile-id

`settler-apps`

---

## description

Settler for application surfaces and app-boundary contracts. Responsible for maintaining Scribe, Sortio, and CloudClinic as non-authoritative interface consumers, ensuring safe-reference navigation, cross-app shared envelope discipline, and app non-authority posture. Ensures that no app leaks direct identifiers or claims final clinical authority.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `docs/architecture/11-scribe.md` — Scribe application design, capture, transcription, draft review surface
2. `docs/architecture/12-sortio.md` — Sortio application design, task/triage surface
3. `docs/architecture/13-cloudclinic.md` — CloudClinic application design, encounter surface
4. `docs/architecture/19-interface-doctrine.md` — interface doctrine: app non-authority, safe refs, mediated surfaces
5. `docs/architecture/43-cross-app-coordination-shared-surfaces.md` — cross-app coordination and shared envelope contracts
6. `docs/execution/10-invariant-matrix.md` — invariants for app boundaries and non-authority posture
7. `docs/execution/skills/scribe-skill.md` — Scribe engineering skill reference (if present)

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `swift/Sources/HealthOSScribeApp/` — Scribe app Swift source
- `swift/Sources/HealthOSSortioApp/` — Sortio app Swift source
- `swift/Sources/HealthOSCloudClinicApp/` — CloudClinic app Swift source
- `schemas/` — app-facing schema contracts and shared envelopes
- `docs/execution/todo/apps-and-interfaces.md` — apps domain TODO tracker

Forbidden paths (must not propose writes here):

- `swift/Sources/HealthOSCore/` — Core law (read-only; changes require Core Settler)
- `swift/Sources/HealthOSAACI/` — AACI runtime (requires AACI Settler)
- `swift/Sources/HealthOSSessionRuntime/` — Session Runtime (requires AACI/core-law Settler)
- `ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. Apps are interface surfaces only. No app (Scribe, Sortio, CloudClinic) owns Core law, storage law, consent, habilitation, gate, finality, or provenance.
2. App navigation references (safe refs) must not grant data access. A safe ref is a pointer, not a data carrier.
3. Direct identifiers (CPF, patient keys) must never appear in app-facing surfaces, navigation payloads, or API responses.
4. App UI state must not be treated as clinical authority. A practitioner reviewing a draft in the app is not equivalent to a Core-approved gate resolution.
5. Cross-app shared envelopes must remain non-clinical: they carry coordination metadata, not clinical payloads.
6. Scaffold maturity UI (mock screens, placeholder workflows) must never be described as production-ready or final clinical UX.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Implementing Core law, storage law, consent, habilitation, gate, or finality logic inside any app layer.
2. Exposing raw direct identifiers (CPF, patient ID) in app-facing screens, navigation URLs, or shared app payloads.
3. Treating navigation ref as a data grant — following a safe ref must never bypass Core mediation.
4. Claiming a final clinical UI or production-ready patient-facing interface exists from scaffold-maturity code.
5. Allowing any app to resolve a clinical gate, approve a final artifact, or bypass the Core approval workflow.
6. Writing demo narratives or fictional clinical stories that imply real patient data exists in these app surfaces.

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
cd swift && swift run HealthOSScribeApp --smoke-test
```

For Sortio changes:
```bash
cd swift && swift run HealthOSSortioApp --smoke-test
```

For CloudClinic changes:
```bash
cd swift && swift run HealthOSCloudClinicApp --smoke-test
```

For documentation-only changes:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No App Boundary Settler execution runtime exists. This profile is a documentation-only engineering instruction record. App surface components have varying maturity (see Territory record `apps.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `docs/execution/todo/apps-and-interfaces.md` reflecting task status.
3. Verification evidence that `make swift-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. For UI-bearing changes: explicit smoke-test evidence from the relevant app smoke target.
5. Explicit residual-gap record for any app contract or UI flow that remains scaffolded or unimplemented.
6. No production-readiness or final-clinical-UX claims.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement app UI or session logic. It does not make any app a clinical authority or allow any app to own Core law. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical.
