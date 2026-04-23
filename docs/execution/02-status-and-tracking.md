# Status and tracking

## Current global status

Current phase: Phase 01 — Core laws of HealthOS

## Completed recently

- scaffold foundation created
- canonical architecture docs created
- ADR seed set created
- initial schemas created
- Swift / TypeScript / Python boundaries scaffolded
- initial SQL migration created
- execution layer created
- AI operating protocol and context bundle created
- AI skills roadmap and initial skill skeletons created
- missing core governance schemas added for consent, habilitation, provenance, gate resolution, professional record, service membership, finality, and access policy
- core services architecture skeleton added
- ADR created for the initial local Swift/TypeScript seam
- glossary added to reduce ontology drift for future AI work

## In progress

- refining phase 01 core-law closure
- converting remaining implicit governance semantics into explicit machine-readable or prose contracts
- preparing a clean schema sanity pass across governance objects

## Known gaps

- directory layout implementation is still minimal/stub-like in one Swift file
- app interfaces are still architectural shells, not detailed task systems
- denial/failure semantics for some core services still need explicit contract text
- schema sanity pass across all new governance schemas is still pending
- future AI skills exist only as initial skeletons, not yet as a complete skill system

## Open blockers / decisions

- refine canonical directory implementation in Swift beyond current stub
- decide whether first runnable slice should keep capture mocked or add native audio earlier
- define explicit deny/error contract outputs for IdentityService, ConsentService, HabilitationService, GateService, and DataStoreService
- decide when to convert the initial AI skill skeletons into enforced reusable workflows

## Tracking rules

Whenever a work unit ends, update:
- current phase if changed
- completed recently
- in progress
- known gaps
- open blockers / decisions
