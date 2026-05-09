# Settler Profile Registry

This directory contains the initial Settler profile records for the HealthOS construction system (ST-012).

Settler profiles are engineering instruction documents. Each profile narrows a Settler's scope to one Territory and makes its invariants, forbidden moves, validation expectations, and handoff requirements explicit.

These records are subordinate to official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`). They do not create clinical agents, runtime actors, or authority surfaces.

## Registry

| Profile ID | Territory ID | Description | Maturity |
|---|---|---|---|
| [settler-core-law](./settler-core-law.md) | `core` | Core law schema, service boundaries, consent/habilitation/gate/finality | doctrine-only |
| [settler-storage](./settler-storage.md) | `storage-and-data` | Storage layer, data contracts, lawfulContext guards | doctrine-only |
| [settler-gos](./settler-gos.md) | `gos` | GOS, compiler, mediation layer | doctrine-only |
| [settler-aaci](./settler-aaci.md) | `aaci` | AACI runtime, provider governance, capability signaling | doctrine-only |
| [settler-ops](./settler-ops.md) | `operations-and-observability` | Operations runbook, observability, incident response | doctrine-only |
| [settler-apps](./settler-apps.md) | `apps` | Application surfaces, app-boundary contracts | doctrine-only |
| [settler-xcode-tooling](./settler-xcode-tooling.md) | `construction-system` | Steward, healthos-forge-mcp, Xcode tooling streams | doctrine-only |
| [settler-documentation](./settler-documentation.md) | `documentation` | Doc drift, execution protocol, invariant matrix | doctrine-only |
| [settler-validation](./settler-validation.md) | `validation-and-ci` | Coverage matrix, release criteria, contract validation | doctrine-only |

## Territory cross-references

Profile IDs map to Territory records under `HealthOS/Constructor/Settler/territories/`. The Territory record holds the canonical domain definition (canonical docs, primary paths, invariants, validation commands). The Settler profile inherits from the Territory and adds profile-specific invariants, forbidden moves, and handoff requirements.

## Non-claims

This registry is a construction-system instruction surface. The registry itself does not implement Settlers as executable agents, multiagent orchestration, runtime behavior, merge authority, clinical access, or production-readiness. Deterministic Steward/Forge seams are documented in `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`; official docs remain canonical.

## Related records

- Territory Registry: `HealthOS/Constructor/Settler/territories/`
- Territory Schema: `HealthOS/Constructor/Settler/territories/territory.schema.json`
- Construction Operating Model: `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- Architecture doctrine: `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md`
- ST task tracker: `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
