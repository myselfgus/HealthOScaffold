# TODO — Data and storage

## COMPLETED

### DS-001 Replace stubbed directory layout with canonical implementation
Outcome:
- canonical directory tree implementation added in Swift for root, user, service, and agent trees
Files touched:
- `swift/Sources/HealthOSCore/DirectoryLayout.swift`

### DS-003 Define StorageService API
Outcome:
- explicit storage contract added with owner, layer, object reference, and lawful-context-based operations
Files touched:
- `swift/Sources/HealthOSCore/StorageContracts.swift`
- `docs/architecture/07-storage-and-sql.md`

## READY

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

### DS-004 Add lawful-context examples for storage reads
Objective:
- document concrete examples of read contexts across user-owned and service-owned objects
Files:
- `docs/architecture/07-storage-and-sql.md`
Dependencies:
- DS-003
Definition of done:
- storage contract is actionable for runtime implementation and access checks

## TESTS / VALIDATION

- local bootstrap reproduces canonical tree
- path naming rules are deterministic
- storage docs clearly separate identifier, operational, governance, and derived layers
