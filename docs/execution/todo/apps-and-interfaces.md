# TODO — Apps and interfaces

## COMPLETED

### APP-001 Define shared UI state vocabulary
Outcome:
- canonical shared state vocabulary defined for session, draft, gate, consent, audit, queue, runtime health, and degraded modes
Files touched:
- `docs/architecture/10-app-state-model.md`

### SCRIBE-001 Detail screen flow for first slice
Outcome:
- Scribe flow expanded with primary screens, states, boundaries, and first-slice sequencing
Files touched:
- `docs/architecture/11-scribe.md`

### SORTIO-001 Detail sovereignty flows
Outcome:
- Sortio flow expanded with screens, user-facing sovereignty states, and explicit app boundaries
Files touched:
- `docs/architecture/12-sortio.md`

### CLOUD-001 Detail service operations flows
Outcome:
- CloudClinic flow expanded with operational screens, queue/gate states, and service-facing boundaries
Files touched:
- `docs/architecture/13-cloudclinic.md`

### APP-002 Define runtime-state surfaces per app
Outcome:
- runtime-state surface doctrine created and linked to the shared app state model so apps can distinguish operational degradation from governance decisions
Files touched:
- `docs/architecture/22-runtime-state-surfaces.md`
- `docs/architecture/10-app-state-model.md`

### APP-003 Deepen screen-level interaction contracts
Outcome:
- per-screen commands, contract calls, and result/error states documented for Scribe, Sortio, and CloudClinic
Files touched:
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/24-sortio-screen-contracts.md`
- `docs/architecture/25-cloudclinic-screen-contracts.md`

### APP-004 Link screen contracts back into main app architecture docs
Outcome:
- app overview docs now point explicitly to their detailed screen-contract documents
Files touched:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`

### APP-005 Define command/result envelopes for UI actions
Outcome:
- Scribe-first-slice bridge now exposes explicit app-action command envelopes and typed action-result envelopes
- result dispositions now separate complete success, partial success, governed deny, degraded state, and operational failure
- CLI now consumes the same envelope-based bridge surface step-by-step, reducing implicit coupling before future UI wiring
Files touched:
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`

### SCRIBE-002 Add minimal SwiftUI first-slice surface
Outcome:
- Scribe now has a minimal macOS SwiftUI validation surface for the first slice
- the UI consumes a small observable view model over `ScribeFirstSliceFacade` instead of reimplementing governance/runtime law
- first-slice executable wiring is shared between CLI and app through `HealthOSFirstSliceSupport`
Files touched:
- `swift/Package.swift`
- `swift/Sources/HealthOSFirstSliceSupport/`
- `swift/Sources/HealthOSScribeApp/`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/28-first-slice-executable-path.md`

### SCRIBE-003 Add minimal local-audio capture path to the Scribe validation surface
Outcome:
- Scribe now allows choosing between seeded text and a local audio file for first-slice capture
- the UI exposes explicit transcription and degraded-state surfaces instead of assuming capture always yields transcript text
- the app still consumes bridge state from `ScribeFirstSliceFacade` rather than taking ownership of capture/transcription law
Files touched:
- `swift/Sources/HealthOSScribeApp/`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/28-first-slice-executable-path.md`

### SCRIBE-004 Surface structured bounded context on the minimal Scribe UI
Outcome:
- Scribe now shows retrieval summary, top highlights, source hints, and explicit `partial` / `empty` / `degraded` context truth instead of a flat preview list
- the app continues to consume bridge state from `ScribeFirstSliceFacade`; no consent, habilitation, gate, or governance law moved into SwiftUI
- partial context and degraded retrieval remain visible as runtime truth without being confused with authorization decisions
Files touched:
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSScribeApp/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/28-first-slice-executable-path.md`

### SCRIBE-005 Enrich gate review and finalized-document visibility on the minimal Scribe surface
Outcome:
- Scribe now shows draft preview, gate review summary, and finalized-document state/path as separate surfaces instead of collapsing them into one generic success blob
- the bridge keeps gate reject explicit without treating it as a technical crash, and final-document state stays distinct from draft state
- the app still consumes `ScribeFirstSliceFacade` contracts rather than reimplementing consent, habilitation, gate, or effectuation law
Files touched:
- `swift/Sources/HealthOSCore/CanonicalTypes.swift`
- `swift/Sources/HealthOSCore/Entities.swift`
- `swift/Sources/HealthOSCore/GateContracts.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `swift/Sources/HealthOSScribeApp/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `docs/architecture/06-core-services.md`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/28-first-slice-executable-path.md`

### SCRIBE-006 Surface referral and prescription draft derivatives on the minimal Scribe surface
Outcome:
- Scribe now shows referral/prescription draft previews and `draft_only` state separately from SOAP draft, gate review, and finalized SOAP document state
- CLI and SwiftUI validation paths now make the draft-only semantics explicit so users do not confuse derived drafts with issued/effective acts
- the app still consumes `ScribeFirstSliceFacade` contracts rather than reimplementing referral/prescription law
Files touched:
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSFirstSliceSupport/ScribeFirstSliceAdapter.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `swift/Sources/HealthOSScribeApp/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`

## READY

## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
- `swift build`
- `swift run HealthOSCLI`
- `swift run HealthOSCLI --reject-gate`
- `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff`
- `swift run HealthOSScribeApp --smoke-test`
- `swift run HealthOSScribeApp --smoke-test-audio`
