# ADR 0007: HealthOS has no end-user UX of its own

Status: Accepted

## Decision

HealthOS, as the core platform, is not itself an end-user UI/UX product.

Its canonical operator surfaces are:
- CLI
- local/admin/service APIs
- engineering/runtime tools
- agent-assisted coding/operations workflows

End-user UX belongs to apps/interfaces built on top of HealthOS, such as:
- Scribe
- Sortio
- CloudClinic
- future apps/interfaces

## Why

- preserves the distinction between platform law and ergonomic presentation
- prevents governance logic from drifting into interface code
- keeps HealthOS substrate/core/runtime concerns separate from app concerns
- matches the role of HealthOS as a sovereign environment, not merely a user-facing app shell

## Non-goal

This does not forbid internal administrative tools or technical dashboards.
It means those are not the canonical human-facing clinical/user UX of the platform.

## Consequence

When implementing user/professional/service workflows, UX should be attached to apps/interfaces, while HealthOS itself remains a governed platform with technical/operator access surfaces.
