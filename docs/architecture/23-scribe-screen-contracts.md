# Scribe screen contracts

## Authentication / service selection
Primary actions:
- authenticate
- choose service
Contract calls:
- IdentityService authenticate
- HabilitationService validate/open context
Result states:
- authenticated
- service selected
- denied
- failed
- degraded

## Patient selection
Primary actions:
- search/select patient
- open new session context
Contract calls:
- bounded patient lookup
- session open request
Result states:
- patient selected
- no match
- denied
- degraded

## Active session workspace
Primary actions:
- choose capture mode
- start capture
- select local audio file
- pause capture
- observe live session state
Contract calls:
- AACI session start/continue
- capture event emission
Result states:
- active
- transcription pending
- degraded transcription
- transcription unavailable
- partial context
- degraded retrieval
- paused
- failed

## Context pane
Primary actions:
- request contextual retrieval
- manual refresh
Contract calls:
- ContextRetrievalAgent via lawful session context
Result states:
- available
- partial
- empty
- denied
- degraded

## Draft review pane
Primary actions:
- inspect SOAP draft plus derived referral/prescription drafts
- request refresh/regeneration
- send to gate
Contract calls:
- DraftComposerAgent
- ReferralDraftAgent
- PrescriptionDraftAgent
- provenance append
- GateService create request
Result states:
- ready
- awaiting_gate
- approved
- rejected
- failed

Derived draft-specific visibility in the current wave:
- referral draft may appear as `preview` before the executable spine runs, then as `draft_only`
- prescription draft may appear as `preview` before the executable spine runs, then as `draft_only`
- neither derived draft may render as issued/effective/prescribed/referred in this wave

## Gate review panel
Primary actions:
- approve
- reject
- inspect rationale / signature requirement / review type / finalization target
Contract calls:
- GateService resolve
Result states:
- approved
- rejected
- cancelled
- failed

## Session history / audit slice
Primary actions:
- inspect recent events, drafts, and provenance markers
Contract calls:
- event/artifact/provenance reads under lawful context
Result states:
- ready
- partially redacted
- failed


## Bridge command/result contract (first executable slice)

The first executable bridge now uses explicit command/result envelopes backed by shared HealthOS envelope vocabulary to reduce ambiguity between app intent and core/runtime execution.

Commands:
- `startProfessionalSession(StartProfessionalSessionCommand)`
- `selectPatient(SelectPatientCommand)`
- `submitSessionCapture(SubmitSessionCaptureCommand)`
- `requestDraftRefresh(RequestDraftRefreshCommand)`
- `resolveGate(ResolveGateCommand)`

Every result returns:
- `disposition`: `complete_success`, `partial_success`, `governed_deny`, `degraded`, or `operational_failure` via shared `HealthOSCommandDisposition`
- `state`: `ScribeSessionBridgeState?` snapshot for UI consumption
- `issues`: typed issues (`HealthOSIssueCode`, `message`, optional `HealthOSFailureKind`)

`ScribeSessionBridgeState` exposes UI-ready operational state including:
- capture mode (`seeded_text` or `local_audio_file`)
- transcription status/source/audio display name
- retrieval status (`ready`, `partial`, `empty`, `degraded`)
- retrieval source
- match count
- retrieval summary
- top highlights / source items / optional notice
- SOAP draft preview plus SOAP draft review state
- referral draft preview/state/object path/draft-only note
- prescription draft preview/state/object path/draft-only note
- gate review summary (state, review type, target, rationale, reviewer role/timestamp)
- final-document summary/path/state that stays distinct from draft approval state
- GOS runtime state limited to active/inactive lifecycle, spec/bundle/workflow identity, binding-plan source, bound actor/family summaries, reasoning-boundary summaries, provenance-facing `gos.use.*` operations, and SOAP/referral/prescription mediation markers

In the current executable spine, `requestDraftRefresh` intentionally returns degraded when only preview state is available; full retrieval/draft-final snapshots still become complete at gate resolution execution. The bridge now still exposes honest preview-only gate/document state during this step so the app can distinguish "awaiting human review" from "finalized".

## Minimal SwiftUI first-slice implementation

The current macOS validation surface in `HealthOSScribeApp` maps these contracts directly:
- session start section -> `startProfessionalSession(StartProfessionalSessionCommand)`
- patient selection controls -> `selectPatient(SelectPatientCommand)`
- capture-mode picker plus seeded-text editor or local-audio file chooser -> `submitSessionCapture(SubmitSessionCaptureCommand)`
- advance action -> `requestDraftRefresh(RequestDraftRefreshCommand)`
- approve/reject buttons -> `resolveGate(ResolveGateCommand)`

The UI consumes:
- `ScribeSessionBridgeState` for capture mode, transcription preview/status, retrieval summary/highlights/source hints, SOAP draft preview, derived referral/prescription draft previews, gate review state/summary, and final document summary/path
- `gosRuntimeState` as runtime-mediated audit context only, including active bundle, bound actors/families, reasoning boundaries, and exact draft-path mediation operations without exposing raw compiled spec JSON
- `HealthOSCommandDisposition` + typed `HealthOSIssue` for degraded, deny, and operational-failure rendering

The UI does not own:
- consent validation
- habilitation validation
- gate law
- final document effectuation
- referral/prescription effectuation
- GOS interpretation or policy execution
