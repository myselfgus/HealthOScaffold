# Next agent handoff (2026-04-26)

## Current state

Repository is in controlled implementation/scaffold hardening with strong governance contracts, substantial Swift tests, TS build + GOS tooling tests, and updated anti-drift entry docs.

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
- explicitly record residual gaps/failures
