# Next agent handoff (2026-04-26)

## Current state

Repository is in controlled implementation/scaffold hardening with strong governance contracts, substantial Swift tests, TS build + GOS tooling tests, and updated anti-drift entry docs.

HealthOScaffold is the historical repository name and construction repository for HealthOS. Future agents must treat implemented architecture, contracts, runtimes, apps, tests, and docs here as HealthOS work unless explicitly marked experimental or deprecated; scaffold vocabulary describes maturity/foundation phase only.

Repository audit note (2026-04-28): the current visible tree has no `.xcodeproj`, `.xcworkspace`, or `swift/Package.swift`, while canonical docs and tracking still reference a substantial Swift package under `swift/`. Treat this as a repository-truth blocker before attempting Xcode workspace setup.

## How to choose next task

1. Open `docs/execution/02-status-and-tracking.md`.
- run steward snapshot before task selection: `cd ts && npx --yes --workspace @healthos/steward healthos-steward status`
2. Confirm closure criteria and blockers in `docs/execution/13-scaffold-release-candidate-criteria.md` and `docs/execution/14-final-gap-register.md`.
3. Pick highest-priority `READY` task in `docs/execution/todo/*.md`.
4. Load matching skill in `docs/execution/skills/`.
5. Validate dependencies before coding.

## Do not touch without explicit reason

- constitutional wording that separates Core vs GOS vs AACI vs apps
- fail-closed guards around lawfulContext / consent / habilitation / gate / finalization
- append-only provenance assumptions

## Priority gaps now

1. close scaffold blockers listed in `docs/execution/14-final-gap-register.md` (currently GAP-001 cross-app adapter propagation and GAP-002 incident command set)
2. resolve the Swift package / Xcode entrypoint truth mismatch captured in `docs/execution/19-xcode-repository-organization-audit.md`
3. extend runtime adapter coverage (user-agent/service) with boundary tests
4. wire `make validate-all` quality gates into CI/distributed execution without declaring production-hardening
5. continue storage/retrieval/provider parity without fake capability claims

## Validation command baseline

```bash
make swift-build
make swift-test
make ts-build
make ts-test
make python-check
make validate-docs
make validate-schemas
make validate-contracts
make validate-all
make smoke-cli
make smoke-scribe
```

## Branch / PR discipline

- one coherent work chunk per commit
- update `02-status-and-tracking.md` + relevant TODO in same work unit
- do not close TODO without evidence

## Absolute honesty rules

- no fictitious examples/demo stories
- no production-ready claims
- no false claims for provider/signature/interoperability/semantic retrieval
- no wording that treats HealthOScaffold as a separate product or points to another HealthOS repository
- explicitly record residual gaps/failures

## Steward provider follow-up

Project Steward now has optional provider adapters and dry-run orchestration; however, the next strategic step is no longer incremental provider growth.

Use these docs as the target source of truth for future steward work:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

The intended evolution is an Xcode-native engineering agent with conversational surfaces, session continuity, tool runtime, and model backends subordinate to the agent runtime.
