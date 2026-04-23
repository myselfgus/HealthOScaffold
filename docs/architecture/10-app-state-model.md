# App state model

Shared state vocabulary should cover:
- session state
- draft state
- gate state
- consent state
- audit visibility state
- queue/pending-work state

## Principle
Apps consume core/runtime contracts. They do not invent separate law models.

## Cross-app shared state groups
- AuthenticationContext
- ServiceContext
- SessionContext
- PatientContext
- DraftReviewState
- GateReviewState
- ConsentManagementState
- AuditTrailState
- QueueState
- RuntimeHealthState
- DegradedModeState

## Canonical state vocabularies

### SessionContext
- idle
- opening
- active
- degraded
- paused
- closing
- closed
- failed

### DraftReviewState
- empty
- loading
- ready
- awaiting_gate
- approved
- rejected
- superseded
- failed

### GateReviewState
- none
- pending
- reviewing
- approved
- rejected
- cancelled
- failed

### ConsentManagementState
- loading
- active
- restricted
- expired
- revoked
- updating
- failed

### AuditTrailState
- loading
- ready
- filtered
- redacted
- export_pending
- failed

### QueueState
- empty
- loading
- ready
- saturated
- deferred
- failed

### RuntimeHealthState
- unknown
- healthy
- degraded
- paused
- failed

### DegradedModeState
- none
- transcription_degraded
- retrieval_degraded
- provider_fallback
- offline_mode
- partial_results

## Rule for apps
An app may show degraded states, but it may not reinterpret them as legal/governance success.
For example, a degraded retrieval does not imply access was authorized; it only indicates an operational state.

## Role-specific emphasis
- Scribe emphasizes SessionContext, DraftReviewState, GateReviewState, RuntimeHealthState
- Sortio emphasizes ConsentManagementState, AuditTrailState, RuntimeHealthState
- CloudClinic emphasizes QueueState, GateReviewState, AuditTrailState, RuntimeHealthState
