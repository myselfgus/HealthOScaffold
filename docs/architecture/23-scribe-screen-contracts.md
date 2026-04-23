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
