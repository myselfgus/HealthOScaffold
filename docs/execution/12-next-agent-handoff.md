# Next agent handoff (2026-04-26)

## Current state

Repository is in controlled implementation/scaffold hardening with strong governance contracts, substantial Swift tests, TS build + GOS tooling tests, and updated anti-drift entry docs.

## How to choose next task

1. Open `docs/execution/02-status-and-tracking.md`.
2. Pick highest-priority `READY` task in `docs/execution/todo/*.md`.
3. Load matching skill in `docs/execution/skills/`.
4. Validate dependencies before coding.

## Do not touch without explicit reason

- constitutional wording that separates Core vs GOS vs AACI vs apps
- fail-closed guards around lawfulContext / consent / habilitation / gate / finalization
- append-only provenance assumptions

## Priority gaps now

1. propagate cross-app envelope usage into non-Scribe adapters
2. extend runtime adapter coverage (user-agent/service) with boundary tests
3. continue storage/retrieval/provider parity without fake capability claims
4. define operator incident command set from existing ops observability contracts

## Validation command baseline

```bash
make swift-build
make swift-test
make ts-build
make ts-test
make python-compile
make swift-smoke
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
