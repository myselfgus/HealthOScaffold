# TODO — Apps and interfaces

## COMPLETED

### APP-001 Define shared UI state vocabulary
Outcome:
- canonical shared state vocabulary defined for session, draft, gate, consent, audit, queue, runtime health, and degraded modes
Files touched:
- `docs/architecture/10-app-state-model.md`

### SCRIBE-001 Detail screen flow for first slice
Outcome:
- Scribe flow expanded with primary screens, states, boundaries, and first-slice sequencing
Files touched:
- `docs/architecture/11-scribe.md`

### SORTIO-001 Detail sovereignty flows
Outcome:
- Sortio flow expanded with screens, user-facing sovereignty states, and explicit app boundaries
Files touched:
- `docs/architecture/12-sortio.md`

### CLOUD-001 Detail service operations flows
Outcome:
- CloudClinic flow expanded with operational screens, queue/gate states, and service-facing boundaries
Files touched:
- `docs/architecture/13-cloudclinic.md`

### APP-002 Define runtime-state surfaces per app
Outcome:
- runtime-state surface doctrine created and linked to the shared app state model so apps can distinguish operational degradation from governance decisions
Files touched:
- `docs/architecture/22-runtime-state-surfaces.md`
- `docs/architecture/10-app-state-model.md`

### APP-003 Deepen screen-level interaction contracts
Outcome:
- per-screen commands, contract calls, and result/error states documented for Scribe, Sortio, and CloudClinic
Files touched:
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/24-sortio-screen-contracts.md`
- `docs/architecture/25-cloudclinic-screen-contracts.md`

## READY

### APP-004 Link screen contracts back into main app architecture docs
Objective:
- add explicit references from Scribe, Sortio, and CloudClinic docs to the new screen-contract documents
Files:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`
Dependencies:
- APP-003
Definition of done:
- app overview docs and screen-contract docs form one navigable set

## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
