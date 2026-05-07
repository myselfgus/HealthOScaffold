# Settler Profile: settler-core-law

This profile narrows a Settler's attention to the Core law territory of the HealthOS repository. Core law is the sovereign layer for consent, habilitation, finality, gate, provenance, storage law, and lawfulContext. This Settler ensures that no work unit moves Core authority into subordinate layers (AACI, GOS, apps, tooling) and that all governance contracts remain fail-closed.

---

## territory-id

`core`

References Territory record: `.healthos-settler/territories/core.json`

---

## profile-id

`settler-core-law`

---

## description

Settler for Core law schema, service boundaries, consent/habilitation/gate/finality. Responsible for preserving the sovereign Core boundary, maintaining governance contracts, and ensuring that no subcomponent treats itself as a law engine.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `docs/architecture/01-overview.md` — HealthOS system overview and Core positioning
2. `docs/architecture/06-core-services.md` — Core service boundary semantics, shared outcome envelope
3. `docs/architecture/05-data-layers.md` — data layer stack and Core-owned storage law
4. `docs/execution/10-invariant-matrix.md` — non-negotiable invariants including Core sovereignty
5. `docs/architecture/17-glossary.md` — canonical nomenclature for consent, habilitation, finality, gate, provenance, lawfulContext
6. `docs/execution/skills/core-law-skill.md` — Core law engineering skill reference
7. `docs/execution/skills/core-governance-skill.md` — Core governance domain skill

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `swift/Sources/HealthOSCore/` — Core governance Swift contracts
- `schemas/contracts/` — JSON Schema governance contracts
- `schemas/entities/` — entity schema definitions
- `docs/architecture/` — architecture docs (read before proposing changes)
- `docs/execution/todo/core-laws.md` — Core-domain TODO tracker

Forbidden paths (must not propose writes here):

- `swift/Sources/HealthOSScribeStage/`
- `swift/Sources/HealthOSVeridiaStage/`
- `swift/Sources/HealthOSCloudClinicStage/`
- `ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. HealthOS Core remains sovereign for consent, habilitation, finality, gate, provenance, storage law, and lawfulContext. No other layer becomes Core law.
2. AACI, GOS, apps, providers, and construction tooling consume Core-mediated surfaces; they never become Core law engines.
3. Drafts never become final artifacts without an approved gate resolution. The gate is not optional.
4. Scaffold maturity is never described as production readiness, regulatory certification, or real provider integration.
5. No Core law is moved into AACI, GOS, apps, tooling, or Steward-family construction infrastructure.
6. Governance contracts (consent, habilitation, gate, finality, provenance) must fail-closed: absent or ambiguous state must deny, not permit.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Moving consent, habilitation, gate, finality, provenance, or lawfulContext logic out of Core and into AACI, GOS, apps, providers, construction tooling, or any other layer.
2. Making the gate optional, defaulting it to approved, or allowing any non-Core actor to resolve a gate without Core arbitration.
3. Claiming production regulatory authority, real RNDS/TISS/FHIR compliance, or real provider integration from scaffold-level contracts.
4. Weakening existing fail-closed validators without an explicit invariant-matrix amendment.
5. Writing clinical examples or demo narratives that imply real patient data or real provider integrations exist.
6. Treating app UI, GOS policy output, or provider inference as clinical authority.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make swift-build
make swift-test
make validate-contracts
make validate-schemas
make validate-all
```

For documentation-only changes:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No Core Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Individual Core contracts have varying maturity (see Territory record `core.json`: `tested operational path` for Core contracts themselves), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `docs/execution/todo/core-laws.md` reflecting task status.
3. Verification evidence that `make swift-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any Core contract that remains scaffolded or unimplemented.
5. No false maturity claims: any scaffolded seam must be labeled scaffolded or doctrine-only.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement the Core governance contracts themselves. It does not make any HealthOS Core contract production-hardened by its existence. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical.
