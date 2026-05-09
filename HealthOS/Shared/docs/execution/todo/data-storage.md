# TODO — Data and storage

## COMPLETED

### DS-001 Replace stubbed directory layout with canonical implementation
Outcome:
- canonical directory tree implementation added in Swift for root, user, service, and agent trees
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/DirectoryLayout.swift`

### DS-002 Refine SQL migration
Outcome:
- initial migration reorganized into readable sections with design notes and invariant comments
Files touched:
- `HealthOS/Tier1-Mestral-Core/SQL/migrations/001_init.sql`

### DS-003 Define StorageService API
Outcome:
- explicit storage contract added with owner, layer, object reference, and lawful-context-based operations
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift`
- `HealthOS/Shared/docs/architecture/07-storage-and-sql.md`

### DS-004 Add lawful-context examples for storage reads
Outcome:
- concrete lawful-context examples added for self-access, service-context access, denied stale access, re-identification denial, and service draft metadata access
Files touched:
- `HealthOS/Shared/docs/architecture/07-storage-and-sql.md`

### DS-005 Decide hash strategy and integrity-verification implementation notes
Outcome:
- initial object-integrity strategy defined with SHA-256 baseline, verification points, and integrity-failure handling
Files touched:
- `HealthOS/Shared/docs/architecture/21-object-integrity-strategy.md`
- `HealthOS/Shared/docs/architecture/07-storage-and-sql.md`

### DS-006 Decide whether lawfulContext becomes a shared strict envelope
Outcome:
- lawfulContext strictness is now pragmatically enforced in storage contracts through typed validation and per-layer fail-closed write/read guards (while preserving map transport compatibility)
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift`
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/FirstSliceServices.swift`
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ReidentificationGovernance.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`
- `HealthOS/Shared/docs/execution/10-invariant-matrix.md`

### DS-007 Propagate lawfulContext and layer guard parity beyond first-slice call sites
Outcome:
- propagated lawfulContext and storage-layer guard parity beyond the original first-slice call sites
- added evidence for governed-vs-operational boundary behavior without replacing the canonical file-backed record posture
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift`
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/FirstSliceServices.swift`
- `HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/data-storage.md`

## READY

No READY data/storage TODO is currently promoted by this tracker. SQL/object backend hardening remains a post-scaffold gap, not a parity replacement for file-backed canonical storage.


## TESTS / VALIDATION

- local bootstrap reproduces canonical tree
- path naming rules are deterministic
- storage docs clearly separate identifier, operational, governance, and derived layers
- lawful-context examples are sufficient to guide runtime implementation and access checks
