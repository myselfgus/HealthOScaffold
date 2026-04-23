# TODO — Runtimes and AACI

## READY AFTER PHASES 01-03

### RT-001 Formalize actor vs agent model
Objective:
- define whether agents are specialized actors with permissions, boundary, and semantic role
Files:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `swift/Sources/HealthOSCore/ActorModel.swift`
Dependencies:
- CL-002
Definition of done:
- model is documented and reflected in code contracts

### RT-002 Define runtime lifecycle contract
Objective:
- define start, ready, active, paused, terminating, terminated, failed states for runtimes
Files:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `swift/Sources/HealthOSCore/*`
- `ts/packages/*`
Dependencies:
- RT-001
Definition of done:
- each runtime can be described in the same lifecycle language

### AACI-001 Expand AACI session model
Objective:
- document all session modes and what each permits
Files:
- `docs/architecture/09-aaci.md`
- `schemas/contracts/sessao-trabalho.schema.json`
Dependencies:
- RT-002
Definition of done:
- session modes are explicit and bounded

### AACI-002 Define hot / warm / cold path routing
Objective:
- classify AACI work types by latency and execution path
Files:
- `docs/architecture/09-aaci.md`
Dependencies:
- AACI-001
Definition of done:
- every initial subagent function belongs to one path class

### AACI-003 Specify subagent boundaries
Objective:
- define input boundary, output contract, permissions, provenance hooks for CaptureAgent, TranscriptionAgent, IntentionAgent, ContextRetrievalAgent, DraftComposerAgent, TaskExtractionAgent, ReferralDraftAgent, PrescriptionDraftAgent, NoteOrganizerAgent, RecordLocatorAgent
Files:
- `docs/architecture/09-aaci.md`
- `swift/Sources/HealthOSAACI/AACI.swift`
Dependencies:
- AACI-002
Definition of done:
- each subagent has bounded contract and cannot be confused with gate or professional authority

## TESTS / VALIDATION

- no AACI path bypasses gate
- no subagent requires undefined access semantics
- provider routing remains provider-agnostic at contract level
