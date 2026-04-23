# TODO — Data and storage

## COMPLETED

### DS-001 Replace stubbed directory layout with canonical implementation
Outcome:
- canonical directory tree implementation added in Swift for root, user, service, and agent trees
Files touched:
- `swift/Sources/HealthOSCore/DirectoryLayout.swift`

### DS-002 Refine SQL migration
Outcome:
- initial migration reorganized into readable sections with design notes and invariant comments
Files touched:
- `sql/migrations/001_init.sql`

### DS-003 Define StorageService API
Outcome:
- explicit storage contract added with owner, layer, object reference, and lawful-context-based operations
Files touched:
- `swift/Sources/HealthOSCore/StorageContracts.swift`
- `docs/architecture/07-storage-and-sql.md`

### DS-004 Add lawful-context examples for storage reads
Outcome:
- concrete lawful-context examples added for self-access, service-context access, denied stale access, re-identification denial, and service draft metadata access
Files touched:
- `docs/architecture/07-storage-and-sql.md`

### DS-005 Decide hash strategy and integrity-verification implementation notes
Outcome:
- initial object-integrity strategy defined with SHA-256 baseline, verification points, and integrity-failure handling
Files touched:
- `docs/architecture/21-object-integrity-strategy.md`
- `docs/architecture/07-storage-and-sql.md`

## READY

### DS-006 Decide whether lawfulContext becomes a shared strict envelope
Objective:
- determine whether lawfulContext remains flexible map-based or evolves into a stricter transport contract
Files:
- `docs/architecture/07-storage-and-sql.md`
- optional schema/contract files
Dependencies:
- DS-003, DS-004
Definition of done:
- runtime implementers know whether lawful access context is flexible or strongly typed at the transport seam

## TESTS / VALIDATION

- local bootstrap reproduces canonical tree
- path naming rules are deterministic
- storage docs clearly separate identifier, operational, governance, and derived layers
- lawful-context examples are sufficient to guide runtime implementation and access checks
