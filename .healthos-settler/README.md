# HealthOS Settler documentation root

This folder contains construction profiles, not clinical runtime agents.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

## Boundary

Settlers are engineering profiles.

Territories are repository domains.

Nothing here is HealthOS Core, GOS, AACI, or app runtime.

No clinical data belongs here.

This folder does not implement multiagent orchestration. It does not grant merge authority, clinical authority, regulatory authority, or production-readiness authority.

Canonical doctrine remains in:
- `docs/architecture/47-steward-settler-engineering-model.md`
- `docs/execution/22-steward-construction-operating-model.md`
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/19-settler-model-task-tracker.md`

Official docs remain canonical. Files in this folder are instruction scaffolds and derived engineering records only.

## Intended layout

- `territories/` — future Territory Registry records.
- `settlers/` — future Settler Profile Registry records.
- `profiles/` — historical placeholder for profile instruction files.
- `settlements/` — historical placeholder for bounded Settlement record files.

No Settler profiles or Settlement records are executable by virtue of being present here.

## Maturity

Current maturity: documentation scaffold only.

Future work may add profile documents and deterministic record templates after the doctrine and validation shape are explicit.
