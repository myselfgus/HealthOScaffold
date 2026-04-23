# TODO — Core laws

## COMPLETED

### CL-001 Complete canonical schema set for governance objects
Outcome:
- added schemas for Consentimento, Habilitacao, Proveniencia, GateResolution, RegistroProfissional, MembroServico, Finalidade, and PoliticaAcesso
Files touched:
- `schemas/entities/*`
- `schemas/contracts/*`

### CL-002 Define service boundaries in docs
Outcome:
- added contract-level skeleton for IdentityService, HabilitationService, ConsentService, GateService, ProvenanceService, DataStoreService
Files touched:
- `docs/architecture/06-core-services.md`

### CL-003 Decide exact local API seam between Swift and TS
Outcome:
- initial seam fixed as loopback HTTP + PostgreSQL metadata + filesystem/object references
Files touched:
- `docs/adr/0006-local-swift-ts-seam.md`

## READY

### CL-004 Define deny/failure semantics for core services
Objective:
- specify how core services report denied access, invalid habilitation, expired consent, missing identity linkage, and gate rejection
Files:
- `docs/architecture/06-core-services.md`
- optionally schemas/contracts if needed
Dependencies:
- CL-001, CL-002, CL-003
Definition of done:
- each core service exposes lawful deny/failure outputs and these are not left implicit

### CL-005 Schema sanity pass across governance objects
Objective:
- verify terminology, field naming, and enum/state alignment across all governance schemas
Files:
- `schemas/entities/*`
- `schemas/contracts/*`
Dependencies:
- CL-001
Definition of done:
- no contradictory field names or state vocabularies remain across governance schemas

## TESTS / VALIDATION

- schema sanity pass
- cross-check terms against ADRs and overview docs
- confirm core-services document names no ambiguous overlap
