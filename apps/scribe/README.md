# Scribe

Professional-facing app.
Consumes:
- AACI runtime
- gate service
- session contracts
- patient context retrieval
- draft workflows

Current scaffold implementation note:
- a minimal macOS SwiftUI validation surface now lives in `swift/Sources/HealthOSScribeApp/`
- it consumes `ScribeFirstSliceFacade` via a small view model and does not own governance law

Primary screens:
- login / service selection
- active session
- context pane
- drafts pane
- gate queue
- session history
