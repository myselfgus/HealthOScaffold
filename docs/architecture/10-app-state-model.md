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

## Initial state groups
- AuthenticationContext
- ServiceContext
- SessionContext
- PatientContext
- DraftReviewState
- GateReviewState
- ConsentManagementState
- AuditTrailState
- QueueState
