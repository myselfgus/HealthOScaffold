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

### CL-004 Define deny/failure semantics for core services
Outcome:
- core service document now distinguishes deny/failure outputs from success outputs and states that deny is not a crash
Files touched:
- `docs/architecture/06-core-services.md`

### CL-005 Schema sanity pass across governance objects
Outcome:
- schema audit recorded naming split, ID conventions, state vocabulary, and non-destructive normalization guidance
Files touched:
- `docs/architecture/18-schema-governance-audit.md`

### CL-006 Add shared error-envelope proposal for local service boundaries
Outcome:
- added a shared service boundary outcome envelope so loopback/service boundaries can represent success, denied, and failure outcomes consistently
- preserved deny-as-governance semantics and kept Core law ownership in Core rather than transport/app surfaces
Files touched:
- `docs/architecture/06-core-services.md`

## READY

No READY core-law TODO is currently promoted by this tracker. Re-check `docs/execution/21-structural-ontology-and-product-readiness-plan.md` and current git history before selecting new Core work.

## TESTS / VALIDATION

- cross-check terms against ADRs and overview docs
- confirm core-services document names no ambiguous overlap
- confirm schema audit and service semantics do not contradict each other
