# Object integrity strategy

## Purpose

Define how object payload integrity is verified across filesystem/object references and SQL metadata.

## Baseline rule

Every persisted object payload should have:
- deterministic content hash
- canonical object path
- SQL metadata linkage

## Initial strategy

### Algorithm
- use SHA-256 as initial content hash algorithm
- store it as lowercase hex string

### Verification points
- on write: compute hash before final metadata registration
- on read: verify object bytes against stored content hash when integrity-sensitive path requires it
- on background audit: sample or scheduled integrity check may re-verify stored objects

### Failure handling
- hash mismatch is an `integrity_failure`
- integrity mismatch must never be silently repaired in place
- mismatch should surface as denied/failed retrieval plus audit/provenance event

## Path/metadata relation

The object path locates the payload.
The content hash verifies the payload.
SQL metadata binds owner/layer/governance context to that payload.

## Practical implications
- renaming a path should not alter content hash
- rewriting a payload must produce a new content hash and metadata update path
- drafts and superseding artifacts should preserve lineage instead of mutating bodies silently

## Open implementation questions
- whether to verify every read or only sensitive reads + sampled background audits
- whether to include optional payload-size and checksum metadata alongside SHA-256
