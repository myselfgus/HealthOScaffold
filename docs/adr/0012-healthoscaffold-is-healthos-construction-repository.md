# ADR 0012: HealthOScaffold is the HealthOS construction repository

## Status
Accepted

## Context

The repository was historically named HealthOScaffold because it began as the scaffolding/foundation phase for building HealthOS. As implementation progresses, this name must not create a false distinction between the foundation-phase repository name and HealthOS system identity.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

## Decision

HealthOScaffold is the canonical construction repository for HealthOS. "Scaffold" describes the initial maturity posture of components and the bootstrap/foundation phase of the repository, not a separate system identity.

All implemented architecture, contracts, runtimes, apps, tests, schemas, migrations, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated.

## Consequences

- Implemented code in this repository is HealthOS code.
- Components may remain doctrine-only, scaffolded contract, implemented seam, tested operational path, or production-hardened.
- Documentation must keep HealthOScaffold and HealthOS aligned as repository name and system identity.
- "Scaffold closure" means closure of the bootstrap/foundation phase, not abandonment or replacement by another repository.
- "Post-scaffold" means the next maturity phase of the same HealthOS project.
- Non-production warnings remain valid: this repository can contain HealthOS code without being production-ready.

## Non-goals

This ADR does not rename the repository, rename packages, declare production readiness, declare EHR completeness, or remove any stub/scaffold maturity warning.
