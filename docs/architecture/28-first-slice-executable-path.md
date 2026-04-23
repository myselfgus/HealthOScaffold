# First slice executable path

## Purpose

Describe the first implemented executable path now present in the scaffold.

## Current implementation path

The current Swift/CLI path exercises these steps:
1. bootstrap canonical directories
2. validate professional habilitation
3. validate patient consent basis for context retrieval
4. open a work session
5. persist a transcript artifact
6. run bounded file-backed retrieval from service record index
7. record retrieval-context event
8. compose a SOAP draft
9. create a gate request
10. resolve the gate as approved/rejected
11. persist final artifact when approved
12. append provenance records
13. persist gate and event artifacts

## Files involved
- `swift/Sources/HealthOSCore/FirstSliceServices.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `services/<service-id>/records/patient-record-index.json` (runtime-data, seeded when missing for demo execution)
- `swift/Sources/HealthOSCLI/FirstSliceRunner.swift`
- `swift/Sources/HealthOSCLI/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`

## What is real now
- first-slice flow is no longer only conceptual
- file-backed persistence exists for artifacts/audit/provenance baseline
- gate resolution changes whether a final artifact is persisted
- the CLI path prints concrete outputs for session, draft, gate, and provenance counts
- first-slice contracts now use explicit envelopes for session input, transcription, retrieval, draft package, gate outcome, and run summary
- session events now use typed event kinds/payload envelopes instead of ad hoc string dictionaries
- a minimal Scribe bridge/facade contract exists so Scribe can consume the executable spine without owning governance law
- Scribe bridge now uses explicit command/result envelopes backed by shared HealthOS envelope vocabulary for session start, patient selection, capture submission, draft refresh request, and gate resolution
- command results carry explicit disposition semantics (`complete_success`, `partial_success`, `governed_deny`, `degraded`, `operational_failure`) and typed issue payloads
- first-slice command results now use shared `HealthOSCommandDisposition`, `HealthOSIssueCode`, and `HealthOSFailureKind` vocabulary rather than ad hoc per-file issue strings
- retrieval bridge state now exposes UI-ready status/source/count/preview fields including explicit degraded mode

## What remains intentionally stubbed
- capture is still text-seeded rather than native audio capture
- transcription is still stubbed
- context retrieval now uses a bounded, file-backed patient record index with deterministic matching
- no UI app is yet wired to this path
- draft refresh is currently degraded preview only; full draft/retrieval material is still finalized in the same executable step as gate resolution
- retrieval ranking is lexical/tag/date bounded; no semantic search or embeddings yet

## Why this is acceptable now
The objective of this wave is to establish a lawful end-to-end executable spine without prematurely coupling to UI or production providers.
