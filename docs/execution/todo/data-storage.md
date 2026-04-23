# TODO — Data and storage

## READY AFTER PHASE 01

### DS-001 Replace stubbed directory layout with canonical implementation
Objective:
- implement full directory scaffold creation in Swift and align it with templates and docs
Files:
- `swift/Sources/HealthOSCore/DirectoryLayout.swift`
- `templates/user-structure.txt`
- `templates/service-structure.txt`
Dependencies:
- CL-001, CL-002
Definition of done:
- code and templates match
- user, service, agent, model, network, backup, log trees are reproducible

### DS-002 Refine SQL migration
Objective:
- split large migration into readable sections or add migration notes
- add missing comments and ensure index rationale is documented
Files:
- `sql/migrations/001_init.sql`
- `docs/architecture/07-storage-and-sql.md`
Dependencies:
- CL-001
Definition of done:
- migration is understandable and aligned to docs

### DS-003 Define StorageService API
Objective:
- specify put/get/list/audit operations for object/document storage
Files:
- `docs/architecture/07-storage-and-sql.md`
- `swift/Sources/HealthOSCore/*`
Dependencies:
- CL-002
Definition of done:
- storage API is explicit and references consent/provenance hooks

## TESTS / VALIDATION

- local bootstrap reproduces canonical tree
- path naming rules are deterministic
- storage docs clearly separate identifier, operational, governance, and derived layers
