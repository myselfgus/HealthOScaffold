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
- start capture
- pause capture
- observe live session state
Contract calls:
- AACI session start/continue
- capture event emission
Result states:
- active
- degraded transcription
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
- empty
- denied
- degraded

## Draft review pane
Primary actions:
- inspect draft
- request refresh/regeneration
- send to gate
Contract calls:
- DraftComposerAgent
- provenance append
- GateService create request
Result states:
- ready
- awaiting_gate
- rejected
- failed

## Gate review panel
Primary actions:
- approve
- reject
- inspect rationale / signature requirement
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

`ScribeSessionBridgeState` exposes retrieval state in UI-ready form:
- retrieval status (`ready`, `empty`, `degraded`)
- retrieval source
- match count
- preview items

In the current executable spine, `requestDraftRefresh` intentionally returns degraded when only preview state is available; full retrieval/draft-final snapshots still become complete at gate resolution execution. This preserves current law-bearing core flow while keeping state transport explicit for future UI wiring.

## Minimal SwiftUI first-slice implementation

The current macOS validation surface in `HealthOSScribeApp` maps these contracts directly:
- session start section -> `startProfessionalSession(StartProfessionalSessionCommand)`
- patient selection controls -> `selectPatient(SelectPatientCommand)`
- seeded capture field + submit action -> `submitSessionCapture(SubmitSessionCaptureCommand)`
- advance action -> `requestDraftRefresh(RequestDraftRefreshCommand)`
- approve/reject buttons -> `resolveGate(ResolveGateCommand)`

The UI consumes:
- `ScribeSessionBridgeState` for transcript preview, retrieval summary, draft preview, gate state, and final summary/path
- `HealthOSCommandDisposition` + typed `HealthOSIssue` for degraded, deny, and operational-failure rendering

The UI does not own:
- consent validation
- habilitation validation
- gate law
- final artifact effectuation
