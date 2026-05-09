# Settler Profile: settler-storage

This profile narrows a Settler's attention to the Storage and Data territory of the HealthOS repository. Storage law governs how data is written, retained, and guarded against reidentification. This Settler ensures that lawfulContext guards are never bypassed, that direct identifiers remain governed, and that no app layer owns storage law.

---

## territory-id

`storage-and-data`

References Territory record: `HealthOS/Constructor/Settler/territories/storage-and-data.json`

---

## profile-id

`settler-storage`

---

## description

Settler for storage layer, data contracts, and lawfulContext guards. Responsible for preserving fail-closed storage invariants, maintaining backup/export interaction discipline, and ensuring that direct identifiers and reidentification paths remain under Core governance at all times.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `HealthOS/Shared/docs/architecture/05-data-layers.md` — data layer stack, lawfulContext, and Core-owned storage law
2. `HealthOS/Shared/docs/architecture/07-storage.md` — storage contracts and object integrity strategy
3. `HealthOS/Shared/docs/architecture/21-object-integrity-strategy.md` — object integrity and provenance chain
4. `HealthOS/Shared/docs/execution/10-invariant-matrix.md` — invariants for storage, lawfulContext, and reidentification
5. `HealthOS/Shared/docs/execution/skills/storage-data-layer-skill.md` — storage/data layer engineering skill reference
6. `HealthOS/Shared/docs/execution/skills/backup-restore-retention-export-skill.md` — backup, restore, retention, and export skill

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift` — Core-governed storage contracts
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ReidentificationGovernance.swift` — reidentification governance
- `HealthOS/Tier1-Mestral-Core/SQL/migrations/001_init.sql` — SQL schema baseline
- `HealthOS/Tier1-Mestral-Core/Schemas/contracts/` — JSON Schema storage contracts
- `HealthOS/Shared/docs/architecture/` — storage-related architecture docs (read only unless explicitly scoped)
- `HealthOS/Shared/docs/execution/todo/data-storage.md` — data/storage domain TODO tracker

Forbidden paths (must not propose writes here):

- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/`
- `HealthOS/Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage/`
- `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage/`
- `HealthOS/Constructor/ts/agent-infra/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. `lawfulContext` is never optional. Every storage write must carry a valid lawfulContext that was granted by Core governance, not assumed.
2. Direct identifiers (CPF, patient identifier) never appear in operational payloads, app-facing surfaces, API responses, or construction tooling output.
3. Reidentification paths remain owned by Core governance. No app, provider, or construction layer may bridge from pseudonymized operational payloads to direct identifiers without Core arbitration.
4. Storage integrity repair is never silent. Any repair action must be logged, provenance-traced, and auditable.
5. Backup existence is not proof of restore capability. Restore must be separately validated and documented.
6. App layers never own storage law. Storage law belongs to Core.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Making `lawfulContext` optional, defaulting it to a permissive value, or accepting a null/absent context as valid.
2. Exposing raw direct identifiers (CPF, patient keys) in operational payloads, API responses, app surfaces, or log output.
3. Moving storage law ownership into apps, AACI, GOS, or construction tooling.
4. Performing silent integrity repairs without audit trail or provenance record.
5. Treating backup file existence as proof that restore will succeed.
6. Claiming production-hardened storage compliance or real regulatory data residency compliance from scaffold contracts.

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

For documentation or contract changes without source change:
```bash
make validate-docs
git diff --check
```

---

## maturity

`doctrine-only`

No Storage Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Storage contracts themselves have varying maturity (see Territory record `storage-and-data.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entry in `HealthOS/Shared/docs/execution/todo/data-storage.md` reflecting task status.
3. Verification evidence that `make swift-test` and `make validate-all` pass (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any storage contract that remains scaffolded or unimplemented.
5. No false maturity claims: scaffold posture preserved.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement storage contracts or data governance. It does not make any storage system production-hardened or regulatory-compliant by its existence. Official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`) remain canonical.
