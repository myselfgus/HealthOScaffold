# Settler Profile: settler-gos

This profile narrows a Settler's attention to the Governance Operating System (GOS) territory of the HealthOS repository. GOS is the operational mediation layer: it authors, compiles, distributes, and lifecycle-manages Governed Operational Specs. GOS is subordinate to Core law and never becomes a constitutional authority. This Settler ensures that GOS remains a mediation layer, not a sovereign law engine.

---

## territory-id

`gos`

References Territory record: `.healthos-settler/territories/gos.json`

---

## profile-id

`settler-gos`

---

## description

Settler for GOS, compiler, and mediation layer. Responsible for maintaining GOS boundary discipline: GOS is an operational mediator for governed specs, not a law engine. This Settler ensures that spec authoring, compiler output, lifecycle management, and app consumption all remain subordinate to Core law.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `docs/architecture/29-governed-operational-spec.md` — GOS spec definition and structure
2. `docs/architecture/30-gos-compiler.md` — GOS compiler design and output contracts
3. `docs/architecture/31-gos-lifecycle.md` — GOS lifecycle phases (draft → review → activate → retire)
4. `docs/architecture/32-gos-runtime-binding.md` — GOS runtime binding and app consumption model
5. `docs/architecture/33-gos-app-consumption.md` — how apps consume mediated GOS surfaces
6. `docs/architecture/34-gos-review-and-activation-policy.md` — GOS review and activation policy
7. `docs/execution/10-invariant-matrix.md` — invariants for GOS sovereignty boundary
8. `docs/execution/skills/gos-skill.md` — GOS engineering skill reference

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `gos/specs/` — GOS spec authoring files
- `schemas/governed-operational-spec.json` — GOS JSON Schema
- `schemas/governed-operational-spec-*.json` — GOS variant schemas
- `ts/packages/healthos-gos-tooling/` — GOS compiler and tooling package
- `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift` — Core-level GOS Swift contract
- `docs/execution/todo/gos.md` — GOS domain TODO tracker (if present)

Forbidden paths (must not propose writes here):

- `swift/Sources/HealthOSScribeStage/`
- `swift/Sources/HealthOSVeridiaStage/`
- `swift/Sources/HealthOSCloudClinicStage/`
- `swift/Sources/HealthOSAACI/`
- `ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. GOS is subordinate to Core law. GOS is an operational mediation layer; it is never a constitutional authority, never Core law, and never a sovereign system.
2. GOS specs may only be activated after explicit review and approval by an authorized reviewer. No spec activates automatically without the review/audit trail.
3. Raw GOS specs are never exposed directly to app surfaces as law. Apps consume mediated surfaces only.
4. GOS compiler output is deterministic and auditable. Compiler behavior must not depend on external model inference.
5. Scenario fiction and fabricated clinical evidence must never be used as activation rationale or review material.
6. Spec retirement and lifecycle transitions must preserve audit trails.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Making GOS sovereign — treating GOS output or GOS policy as equivalent to Core law.
2. Exposing raw GOS spec content directly to app surfaces as if it were final clinical authority.
3. Activating a GOS spec without an explicit review record and audit trail.
4. Creating scenario-based or fictional clinical evidence as review/activation rationale.
5. Allowing GOS to resolve consent, habilitation, gate, finality, or provenance — those remain Core responsibilities.
6. Claiming GOS is production-ready, fully regulatory-compliant, or that it satisfies real provider integration requirements.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make ts-build
make ts-test
make validate-schemas
make validate-contracts
make validate-all
```

For Swift GOS contracts:
```bash
make swift-build
make swift-test
```

For documentation-only changes:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No GOS Settler execution runtime exists. This profile is a documentation-only engineering instruction record. GOS components have varying maturity (see Territory record `gos.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in relevant GOS tracker reflecting task status.
3. Verification evidence that `make ts-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any GOS contract that remains scaffolded or unimplemented.
5. No false sovereignty claims: GOS must remain subordinate to Core in all documentation.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement the GOS compiler or spec lifecycle. It does not make GOS a sovereign system or a law engine. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical.
