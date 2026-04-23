# Status and tracking

## Current global status

Current phase: Phase 00 — Governance and execution discipline

## Completed recently

- scaffold foundation created
- canonical architecture docs created
- ADR seed set created
- initial schemas created
- Swift / TypeScript / Python boundaries scaffolded
- initial SQL migration created
- execution layer started

## In progress

- phase files
- executable backlog decomposition
- AI operating instructions

## Known gaps

- execution layer was missing until now
- TODOs were not yet decomposed by domain and dependency
- app interfaces are still architectural shells, not detailed task systems
- directory layout implementation is still minimal/stub-like in one Swift file
- there is no explicit readiness checklist per phase yet

## Open blockers / decisions

- refine canonical directory implementation in Swift beyond current stub
- add more complete JSON Schemas for consent, habilitation, provenance, and gate resolution
- decide exact initial local API boundary between Swift and TypeScript services
- define whether first runnable slice should keep capture mocked or add native audio earlier

## Tracking rules

Whenever a work unit ends, update:
- current phase if changed
- completed recently
- in progress
- known gaps
- open blockers / decisions
