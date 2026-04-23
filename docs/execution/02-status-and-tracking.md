# Status and tracking

## Current global status

Current phase: Phase 03 — Runtime / actor / agent contracts

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
- schema governance audit completed
- ADR and doctrine added clarifying that HealthOS is not end-user UX; apps/interfaces own end-user UX
- canonical directory layout implemented in Swift
- explicit storage contract added to Swift core
- storage architecture document aligned to the storage contract
- core-law deny/failure semantics documented
- initial SQL migration reorganized with sections, notes, and invariant comments
- lawful-context examples added to storage architecture
- initial object-integrity/hash strategy documented
- runtime lifecycle formalized in docs, schema, Swift, and TypeScript
- actor/agent distinction formalized and typed
- AACI session model expanded with bounded meaning and path classes
- AACI subagent contracts substantially defined in docs and Swift
- agent boundary and descriptor schemas added
- runtime retry/backpressure baseline documented
- provider-routing baseline documented by task class
- shared app state vocabulary expanded
- Scribe, Sortio, and CloudClinic flow maps expanded

## In progress

- moving from runtime contract hardening into late pre-coding closure
- identifying the last policy/details that should be closed before heavier implementation work

## Known gaps

- runtime-state surfaces across apps still need one more explicit closure pass
- lawfulContext may still need a stricter transport envelope decision
- ops runbook detail still needs strengthening
- provider/ML governance still needs deeper procedural detail for datasets, promotion, and rollback
- AI skills are still scaffolds, not fully reusable operational packs

## Open blockers / decisions

- decide whether first runnable slice should keep capture mocked or add native audio earlier
- decide when to convert the initial AI skill skeletons into enforced reusable workflows
- define shared error-envelope strategy for loopback local services, if needed
- decide whether lawfulContext remains flexible map-based or becomes strict transport contract
- decide how much provider benchmark thresholding should be formalized before slice implementation

## Tracking rules

Whenever a work unit ends, update:
- current phase if changed
- completed recently
- in progress
- known gaps
- open blockers / decisions
