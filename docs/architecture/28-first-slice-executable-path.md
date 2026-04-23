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
6. record retrieval-context event
7. compose a SOAP draft
8. create a gate request
9. resolve the gate as approved/rejected
10. persist final artifact when approved
11. append provenance records
12. persist gate and event artifacts

## Files involved
- `swift/Sources/HealthOSCore/FirstSliceServices.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSCLI/FirstSliceRunner.swift`
- `swift/Sources/HealthOSCLI/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSCLI/main.swift`

## What is real now
- first-slice flow is no longer only conceptual
- file-backed persistence exists for artifacts/audit/provenance baseline
- gate resolution changes whether a final artifact is persisted
- the CLI path prints concrete outputs for session, draft, gate, and provenance counts
- first-slice contracts now use explicit envelopes for session input, transcription, retrieval, draft package, gate outcome, and run summary
- session events now use typed event kinds/payload envelopes instead of ad hoc string dictionaries
- a minimal Scribe bridge/facade contract exists so Scribe can consume the executable spine without owning governance law

## What remains intentionally stubbed
- capture is still text-seeded rather than native audio capture
- transcription is still stubbed
- context retrieval is still a bounded synthetic context list
- no UI app is yet wired to this path

## Why this is acceptable now
The objective of this wave is to establish a lawful end-to-end executable spine without prematurely coupling to UI or production providers.
