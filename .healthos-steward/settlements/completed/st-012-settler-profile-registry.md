# Settlement Record: SETTLEMENT-20260504-settler-profile-registry

> **Non-claims**: A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims. Settlement records are subordinate to official docs. They are engineering work unit documentation.

---

## Identity

**id**: `SETTLEMENT-20260504-settler-profile-registry`

**title**: `ST-012 Settler Profile Registry`

**status**: `COMPLETE`

---

## Scope

**objective**:
Create 9 Settler profile records and a registry index under `.healthos-settler/settlers/` to formalize the construction-system Settler Profile Registry (ST-012). Each profile narrows a Settler's scope to one Territory, making invariants, forbidden moves, validation expectations, maturity, and handoff requirements explicit as engineering instruction documents. The profiles are documentation-only records; they do not implement executable agents, Settlement lifecycle management, Steward CLI operations, HealthOS Forge MCP, or runtime behavior.

**territory**:
- `construction-system`
- `documentation`

**settler-profile**:
- `settler-xcode-tooling`
- `settler-documentation`

**files-in-scope**:
- `.healthos-settler/settlers/README.md`
- `.healthos-settler/settlers/settler-core-law.md`
- `.healthos-settler/settlers/settler-storage.md`
- `.healthos-settler/settlers/settler-gos.md`
- `.healthos-settler/settlers/settler-aaci.md`
- `.healthos-settler/settlers/settler-ops.md`
- `.healthos-settler/settlers/settler-apps.md`
- `.healthos-settler/settlers/settler-xcode-tooling.md`
- `.healthos-settler/settlers/settler-documentation.md`
- `.healthos-settler/settlers/settler-validation.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/19-settler-model-task-tracker.md`
- `docs/execution/20-documental-todos-work-plan.md`
- `docs/execution/22-steward-construction-operating-model.md`

---

## Governance

**invariants**:
1. Construction-system boundary must be preserved: no clinical authority, no merge authority, no runtime behavior modified in this Settlement.
2. Settler profiles are documentation scaffolds only. No profile may claim executable agent status, HealthOS runtime authority, or production readiness.
3. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical. Settler profile records are subordinate and derived.
4. `healthos-forge-mcp` is the canonical name for the repository-maintenance MCP. The deprecated name `healthos-mcp` must not appear in any new record.
5. `HealthOSSessionRuntime` is the canonical Swift module name. The deprecated name `HealthOSFirstSliceSupport` must not appear.
6. Each Settler profile must include a non-claims block and a maturity field set to `doctrine-only`.

**restrictions**:
- Do not modify any Swift source under `swift/Sources/` or `swift/Tests/`.
- Do not modify any TypeScript source under `ts/`.
- Do not modify Territory records under `.healthos-settler/territories/` (read-only for this Settlement).
- Do not create Settlement instances, Steward CLI, HealthOS Forge MCP, or prompt generation engine.
- Do not create more than 9 Settler profile files and 1 registry README.
- Do not make production-readiness, clinical authority, or merge authority claims in any created file.

**validation-commands**:
- `make validate-docs`
- `make validate-all`

---

## Lifecycle

**done-criteria**:
- [x] `.healthos-settler/settlers/README.md` exists and contains a registry table with all 9 profiles.
- [x] 9 Settler profile files exist: `settler-core-law.md`, `settler-storage.md`, `settler-gos.md`, `settler-aaci.md`, `settler-ops.md`, `settler-apps.md`, `settler-xcode-tooling.md`, `settler-documentation.md`, `settler-validation.md`.
- [x] Each profile contains: territory-id, profile-id, description, canonical-docs, files-in-scope, invariants (≥ 6), forbidden-moves (≥ 6), validation-expectations, maturity (doctrine-only), handoff-requirements, non-claims block.
- [x] `docs/execution/02-status-and-tracking.md` updated with ST-012 completion entry.
- [x] `docs/execution/19-settler-model-task-tracker.md` ST-012 status updated to DONE.
- [x] `docs/execution/20-documental-todos-work-plan.md` Task 2 of 9 marked CONCLUÍDA.
- [x] `docs/execution/22-steward-construction-operating-model.md` ST-012 entry updated.

**residual-gaps**:
- ST-013 (Settlement Record Schema and Templates): TODO at time of ST-012 completion — no SCHEMA.md, template, or example Settlement existed.
- ST-014 (Deterministic Steward CLI inspect/next/list): TODO.
- ST-015 (Prompt Generation Engine): TODO.
- ST-016 (Settlement Validation and PR Review Draft Engine): TODO.
- ST-017 (Derived Memory Builder): TODO.
- ST-018 (healthos-forge-mcp surface over deterministic operations): DONE after ST-012 completion; implemented seam, repository-maintenance only.
- ST-019 (Xcode/Codex/Claude integration instructions): DONE after ST-012 completion.
- ST-020 (Use Steward to generate APP-012 prompt): needs-review / blocked as written after ADR-0013; must be reframed as CloudClinic Custom / Boundary-readiness work before execution.
- Settler profiles are doctrine-only; no Settler execution runtime exists for any profile.

**handoff**:
10 files created under `.healthos-settler/settlers/` (README.md registry index + 9 Settler profile records). 4 tracking docs updated: `docs/execution/02-status-and-tracking.md`, `docs/execution/19-settler-model-task-tracker.md`, `docs/execution/20-documental-todos-work-plan.md`, `docs/execution/22-steward-construction-operating-model.md`. Validation: `make validate-docs` PASS, `make validate-all` PASS (as recorded in task specification for ST-012). ST-013 (Settlement Record Schema and Templates) is the next construction-system task.

---

## Source docs

- `docs/execution/22-steward-construction-operating-model.md` — construction operating model, Settlement definition, directory model
- `docs/execution/19-settler-model-task-tracker.md` — ST-012 goal definition and outcome block
- `docs/architecture/47-steward-settler-engineering-model.md` — canonical Steward/Settler/Settlement/Territory model
- `.healthos-settler/territories/territory.schema.json` — Territory schema (for Territory ID cross-reference)
- `docs/execution/02-status-and-tracking.md` — ST-012 completion entry (factual basis for this record)
- `docs/execution/20-documental-todos-work-plan.md` — Task 2 of 9 (ST-002/ST-012) spec

---

## Validation evidence

- `make validate-docs`: PASS (recorded in task specification for ST-012)
- `make validate-all`: PASS (recorded in task specification for ST-012)
- No Swift source modified.
- No TypeScript source modified.
- No Territory records modified.
- No clinical contracts modified.
- Construction-system boundary invariants preserved.
