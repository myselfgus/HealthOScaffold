# TODO — Core laws

## READY

### CL-001 Complete canonical schema set for governance objects
Objective:
- add missing schemas for Consentimento, Habilitacao, Proveniencia, GateResolution, RegistroProfissional, MembroServico
Files:
- `schemas/entities/*`
- `schemas/contracts/*`
Dependencies:
- phase 00 complete
Definition of done:
- each schema exists and matches architecture docs
- no core entity remains only implicit in prose

### CL-002 Define service boundaries in docs
Objective:
- write contract-level docs for IdentityService, HabilitationService, ConsentService, GateService, ProvenanceService, DataStoreService
Files:
- `docs/architecture/06-core-services.md`
Dependencies:
- phase 00 complete
Definition of done:
- each service has inputs, outputs, invariants, and no ambiguous overlap

## BLOCKER-CHECK

### CL-003 Decide exact local API seam between Swift and TS
Objective:
- choose whether the first seam is HTTP loopback, file/event, or mixed
Blocker reason:
- affects runtime integration and app/service boundaries
Definition of done:
- decision recorded in ADR

## TESTS / VALIDATION

- schema sanity pass
- cross-check terms against ADRs and overview docs
