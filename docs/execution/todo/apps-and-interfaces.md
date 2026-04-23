# TODO — Apps and interfaces

## READY AFTER CORE + RUNTIME CONTRACTS

### APP-001 Define shared UI state vocabulary
Objective:
- establish canonical UI states for session, draft, gate, consent, audit, queue, and pending work
Files:
- `apps/shared-ui/README.md`
- `docs/architecture/10-app-state-model.md`
Dependencies:
- CL-002, RT-002
Definition of done:
- apps use shared terms and do not invent conflicting state names

### SCRIBE-001 Detail screen flow for first slice
Objective:
- map login/service select, session start, patient select, active session, draft review, gate queue, session history
Files:
- `apps/scribe/README.md`
- `docs/architecture/11-scribe.md`
Dependencies:
- AACI-003
Definition of done:
- every first-slice step has a screen/state location

### SORTIO-001 Detail sovereignty flows
Objective:
- map consent management, data visibility, audit trail, export, user-agent chat shell
Files:
- `apps/sortio/README.md`
- `docs/architecture/12-sortio.md`
Dependencies:
- CL-001, RT-002
Definition of done:
- user-facing sovereignty functions are explicit and separate from professional flows

### CLOUD-001 Detail service operations flows
Objective:
- map service dashboard, patient registry, queue, pending drafts, gates, operational documents
Files:
- `apps/cloudclinic/README.md`
- `docs/architecture/13-cloudclinic.md`
Dependencies:
- CL-001, RT-002
Definition of done:
- CloudClinic is clearly service-facing and does not duplicate Scribe or Sortio responsibilities

## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
