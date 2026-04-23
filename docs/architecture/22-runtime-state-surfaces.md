# Runtime state surfaces

## Purpose

Define how runtime truth appears in apps without letting apps reinterpret governance or legal meaning.

## Global rule

Runtime state is operational truth, not governance truth.
A runtime shown as healthy does not imply access is allowed.
A runtime shown as degraded does not imply access is denied.

## Surface classes

### 1. health surface
Used to show whether a runtime is healthy, degraded, paused, or failed.

### 2. degraded-mode surface
Used to show specific diminished capability, such as degraded transcription or retrieval fallback.

### 3. deny surface
Used when core law denies access/action.
Must be shown separately from runtime failure.

### 4. queue/pending surface
Used when work is deferred, queued, or retrying.

## Scribe
Must surface:
- AACI runtime health
- transcription degraded state
- retrieval degraded state
- draft pending/retry state
- explicit deny states for context access or gate eligibility

Must never imply:
- degraded transcription means consent failure
- healthy runtime means gate is satisfied

## Sortio
Must surface:
- user-agent runtime health
- consent load/update state
- audit export pending state
- explicit denied/restricted states where platform law requires redaction or bounded visibility

Must never imply:
- degraded user-agent means user lost ownership rights
- healthy runtime means a restricted record becomes visible

## CloudClinic
Must surface:
- queue saturation/deferred state
- pending gate backlog state
- service-facing degraded runtime signals relevant to operations
- explicit denied states when service scope is insufficient

Must never imply:
- operational visibility equals clinical authority
- a queue item in good state equals regulatory completion

## Rendering rule
Apps should render runtime states and governance states as separate UI signals.
Example:
- `retrieval_degraded` + `access denied` are two different facts

## Suggested UI pattern
- top-level runtime health indicator
- in-flow degraded banners for affected task class
- deny cards/messages for governance decisions
- queue badges for deferred/retry work
