# First slice executable path

## Purpose

Describe the first implemented executable path now present in HealthOS at scaffold/foundation maturity.

## Current implementation path

The current Swift executable path (CLI plus minimal Scribe SwiftUI surface) exercises these steps:
1. bootstrap canonical directories
2. validate professional habilitation
3. validate patient consent basis for context retrieval
4. open a work session
5. accept either seeded text or a local audio file reference as session capture
6. persist local audio capture when audio mode is used
7. process transcription as `ready`, `degraded`, or `unavailable`
8. persist a transcript artifact when transcript text exists
9. run bounded file-backed retrieval from service record index
10. assemble a structured clinical-operational context package
11. record retrieval-context event
12. compose a SOAP draft
13. derive referral and prescription drafts from the same bounded spine
14. create a gate request
15. resolve the gate as approved/rejected
16. persist a finalized SOAP document when approved
17. append provenance records
18. persist gate and event artifacts

## Files involved
- `swift/Sources/HealthOSCore/FirstSliceServices.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceDemoBootstrap.swift`
- `services/<service-id>/records/patient-record-index.json` (runtime-data, seeded when missing for demo execution)
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `swift/Sources/HealthOSScribeApp/`

## What is real now
- first-slice flow is no longer only conceptual
- file-backed persistence exists for artifacts/audit/provenance baseline
- gate resolution changes whether a finalized SOAP document is persisted
- the CLI path prints concrete outputs for session, draft, gate, and provenance counts
- first-slice contracts now use explicit envelopes for session input, transcription, retrieval, draft package, gate outcome, and run summary
- session events now use typed event kinds/payload envelopes instead of ad hoc string dictionaries
- a minimal Scribe bridge/facade contract exists so Scribe can consume the executable spine without owning governance law
- Scribe bridge now uses explicit command/result envelopes backed by shared HealthOS envelope vocabulary for session start, patient selection, capture submission, draft refresh request, and gate resolution
- command results carry explicit disposition semantics (`complete_success`, `partial_success`, `governed_deny`, `degraded`, `operational_failure`) and typed issue payloads
- first-slice command results now use shared `HealthOSCommandDisposition`, `HealthOSIssueCode`, and `HealthOSFailureKind` vocabulary rather than ad hoc per-file issue strings
- the CLI path can now validate both approval and rejection semantics explicitly, including a rejected gate path that withholds final-document persistence without masquerading as a technical crash
- the executable spine now supports a minimal local-first audio path by persisting audio files into the service record area and then attempting transcription through a local provider stub
- transcription state is now explicit (`ready`, `degraded`, `unavailable`) rather than inferred from the mere existence of capture input
- retrieval scoring now combines normalized lexical/tag matching with deterministic recency/category/intent boosts, while remaining fully local and bounded
- a structured local context package now sits between raw retrieval matches and AACI draft composition, exposing summary, highlights, supporting snippets, provenance hints, and explicit `ready` / `partial` / `empty` / `degraded` truth
- the first slice now distinguishes typed SOAP draft snapshots from finalized SOAP documents, with explicit source-draft and gate linkage carried into the final persisted payload
- the executable spine now also materializes typed referral and prescription drafts as draft-only derivatives linked back to the same session/SOAP/context spine
- referral/prescription drafts are persisted with their own object refs, session events, and provenance records while remaining explicitly non-effective
- gate request/resolution contracts now carry review type, finalization target, rationale, reviewer role, and reviewed timestamp
- retrieval bridge state now exposes UI-ready status/source/count/summary/highlight fields including explicit degraded and partial modes
- a minimal macOS SwiftUI Scribe surface now consumes the same bridge through a small view model instead of touching core/runtime services directly
- the minimal Scribe surface now shows SOAP draft preview, referral/prescription draft-only previews, gate review summary, and final-document state/path as separate truths
- the same `HealthOSFirstSliceSupport` target now backs both CLI and SwiftUI validation paths, reducing duplicated first-slice wiring

## What remains intentionally stubbed
- microphone recording is not implemented yet; the current audio path is local file selection/import
- local-audio transcription is still stubbed, so the honest default outcome for audio capture is degraded transcription unless a real provider is introduced later
- context retrieval still uses a bounded, file-backed patient record index; it is stronger now, but still deterministic/local rather than semantic/vector-based
- the SwiftUI surface is validation-only and not yet the full Scribe product UI
- draft refresh is currently degraded preview only; full draft/retrieval material is still finalized in the same executable step as gate resolution
- referral/prescription derivation now exists, but effectuation/issuance remains out of scope for this wave
- retrieval ranking is still local-first lexical/tag/recency/category/intent bounded; no semantic search, embeddings, or vector DB are in this wave

## Why this is acceptable now
The objective of this wave is to establish a lawful end-to-end executable spine and a minimal app-facing validation surface without prematurely coupling to a full UI architecture or production providers.
This is HealthOS code in a not-production-ready maturity posture; it is not disposable foundation code to be replaced by another HealthOS later.
