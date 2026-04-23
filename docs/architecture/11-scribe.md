# Scribe

## Purpose
Professional-facing interface for session work with AACI support.

## What Scribe is
- the professional UX for live and near-live work
- the place where drafts and gates become visible to the professional
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
- review drafts
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
- transcription healthy / degraded
- context available / missing / denied
- draft ready / awaiting_gate / rejected / approved
- gate pending / reviewing / approved / rejected

## Related detailed contract
See:
- `docs/architecture/23-scribe-screen-contracts.md`

## Boundaries
- Scribe may request actions through core/runtime contracts
- Scribe may display degraded or denied states
- Scribe may not invent authorization success or finalize artifacts without gate resolution

## Current minimal SwiftUI surface

The scaffold now includes a minimal macOS SwiftUI validation surface in:
- `swift/Sources/HealthOSScribeApp/`

This surface is intentionally narrow:
- one window with session start, patient selection, seeded capture, draft preview, gate actions, and result sections
- state is consumed through a small UI view model that talks to `ScribeFirstSliceFacade`
- executable slice orchestration remains outside the app in `HealthOSFirstSliceSupport`

This surface is intentionally not the final Scribe UI:
- no design system or navigation architecture has been introduced
- no core law has been moved into the app
- draft refresh remains preview-only/degraded until the existing executable spine reaches gate resolution

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

This improves UI readiness while preserving law ownership in core services (consent, habilitation, gate, and effectuation remain outside app ownership).


## First slice relevance
Scribe is the primary interface for the first end-to-end slice.
