# Scribe

## Purpose
Professional-facing interface for session work with AACI support.

## What Scribe is
- the professional UX for live and near-live work
- the place where drafts and gates become visible to the professional
- the place where draft review and finalized-document state become explicitly distinct
- the place where degraded runtime states must be made understandable without pretending they are legal decisions

## What Scribe is not
- not the owner of consent law
- not the owner of habilitation law
- not the source of truth for gate semantics
- not an EHR substitute by definition; it is an interface over HealthOS capabilities

## Primary flows
- authenticate and select service
- open work session
- select patient
- capture and review session inputs
- inspect context
- review SOAP plus derived drafts
- resolve gates
- inspect session history

## First-slice flow
1. authenticate
2. select service
3. validate habilitation
4. select patient
5. open active session
6. capture input / see transcription state
7. inspect context pane
8. inspect SOAP draft
9. review gate request
10. approve or reject
11. inspect provenance/session history markers

## Primary screens
- authentication / service selection
- patient selection
- active session workspace
- context pane
- draft review pane
- gate review modal/panel
- session history / audit slice

## Key UI states
- session opening / active / degraded / closing
- capture mode seeded_text / local_audio_file
- transcription pending / ready / degraded / unavailable
- context ready / partial / empty / degraded / denied
- draft ready / awaiting_gate / rejected / approved
- derived draft preview / draft_only
- gate pending / reviewing / approved / rejected / cancelled
- final document none / awaiting_gate / finalized / withheld

## Related detailed contract
See:
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`

## Boundaries
- Scribe may request actions through core/runtime contracts
- Scribe may display degraded or denied states
- Scribe may not invent authorization success or finalize documents without gate resolution

## Scaffold posture / non-claims

Scribe is a scaffold contract and minimal validation surface only:
- no final production UI has been implemented
- native macOS design-system and app-shell scope has been defined, but no final Scribe navigation architecture has been implemented
- local audio currently uses file selection/import rather than a full microphone-recording pipeline
- transcription remains stubbed (degraded/unavailable honesty preserved)
- retrieval is bounded lexical/tag/recency only (no semantic/embedding pipeline)
- draft refresh remains preview-only until full spine execution with gate resolution
- Scribe does not own consent/habilitation/gate/finality law; it consumes mediated surfaces from HealthOS Core

## Current minimal SwiftUI surface

The scaffold includes a minimal macOS SwiftUI validation surface in:
- `swift/Sources/HealthOSScribeApp/`

This surface is intentionally narrow:
- one window with session start, patient selection, capture-mode choice (seeded text or local audio file), SOAP draft preview, referral/prescription derived draft previews, gate review summary, and final-document result sections
- state is consumed through a small UI view model that talks to `ScribeFirstSliceFacade`
- executable slice orchestration remains outside the app in `HealthOSFirstSliceSupport`
- transcription status/source and structured retrieval state are shown explicitly instead of being implied from other UI state
- retrieval now surfaces summary, highlights, source hints, match count, and explicit `partial` / `empty` / `degraded` truth without moving law into the app
- gate review now surfaces review type, target, rationale, and reviewer timing/role without making SwiftUI the owner of gate law
- final-document state now stays separate from draft state, including explicit finalized vs withheld truth
- referral and prescription derivatives are shown explicitly as `draft_only` outputs tied to the same document spine, without claiming issuance or prescription effect

This surface is explicitly scaffold-only, not the final Scribe UI:
- no core law has been moved into the app (consent/habilitation/gate/finality remain in Core)
- draft refresh remains preview-only/degraded until the executable spine reaches gate resolution

## First-slice command/result envelopes backed by shared HealthOS envelope vocabulary

Scribe now consumes explicit first-slice command/result envelopes backed by shared HealthOS envelope vocabulary via the bridge contract, instead of a single implicit run call.

Commands currently formalized:
- `StartProfessionalSessionCommand`
- `SelectPatientCommand`
- `SubmitSessionCaptureCommand`
- `RequestDraftRefreshCommand`
- `ResolveGateCommand`

Result envelopes currently formalized:
- `SessionStartResult`
- `PatientSelectionResult`
- `CaptureSubmissionResult`
- `DraftStateResult`
- `GateResolutionResult`

Every result carries a `disposition` (`HealthOSCommandDisposition`) that keeps distinctions explicit between:
- complete success
- partial success
- governed deny
- degraded state
- operational failure

This improves UI readiness while preserving law ownership in core services (consent, habilitation, gate, and document finalization remain outside app ownership).
Derived referral/prescription previews also remain app-consumed state only; Scribe still does not own referral/prescription law or effectuation.

## First slice relevance

Scribe is the primary interface for the first end-to-end slice. This remains scaffold-level:
- the slice demonstrates contract wiring and provenance separation
- it does not claim production readiness or real provider integration
- microphone capture, real transcription, and semantic retrieval remain deferred

