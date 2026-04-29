# Next agent handoff (2026-04-28)

## Current state

Repository is in controlled implementation/scaffold hardening with strong governance contracts, substantial Swift tests, TS build + GOS tooling tests, and updated anti-drift entry docs.

HealthOScaffold is the historical repository name and construction repository for HealthOS. Future agents must treat implemented architecture, contracts, runtimes, apps, tests, and docs here as HealthOS work unless explicitly marked experimental or deprecated; scaffold vocabulary describes maturity/foundation phase only.

Repository audit note (2026-04-28): the canonical Swift package exists at `swift/Package.swift`, and the repository now exposes a root `HealthOS.xcworkspace` that points to it. Treat SwiftPM as the canonical Apple build graph; the workspace is the Xcode entrypoint, not a replacement for TS/Python native tooling.

## How to choose next task

1. Open `docs/execution/02-status-and-tracking.md`.
   Use the current deterministic Steward baseline before task selection:
   `cd ts && npx --yes --workspace @healthos/steward healthos-steward status`
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
2. extend runtime adapter coverage (user-agent/service) with boundary tests
3. wire `make validate-all` quality gates into CI/distributed execution without declaring production-hardening
4. continue storage/retrieval/provider parity without fake capability claims
5. keep regulatory/provider/semantic non-claims explicit while preparing scaffold RC fixes + tag prep

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

## Steward follow-up

Current `healthos-steward` baseline is intentionally narrow: `status`, `runtime`, and `session` only. Treat it as a repository-local continuity and session-persistence seam, not as a complete deterministic operations surface.

Use these docs as the target source of truth for future steward work:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

The intended evolution is Steward for Xcode: Xcode Intelligence as the Apple-controlled engineering runtime surface, with HealthOS contributing instructions, `healthos-mcp`, derived repository memory, and an expanded deterministic CLI.

Settler model note: the Steward / Settler / Settlement / Territory model was added as doctrine-only in `docs/architecture/47-steward-settler-engineering-model.md`, with future implementation tracked in `docs/execution/19-settler-model-task-tracker.md`. Future work should use those docs and must not treat Settlers as clinical or runtime agents.

Repository-local roots now exist for the model:
- `.healthos-settler/` is a documentation-only root for future Settler profiles and Settlement records.
- `.healthos-territory/` is a documentation-only root for future Territory records.

These roots are subordinate to official docs and do not implement executable Settlers, a Settlement schema, a Territory loader, or `healthos-mcp`.
