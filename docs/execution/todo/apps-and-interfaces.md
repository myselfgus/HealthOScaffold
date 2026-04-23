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

## READY

## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
- `swift build`
- `swift run HealthOSCLI`
- `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff`
- `swift run HealthOSScribeApp --smoke-test`
- `swift run HealthOSScribeApp --smoke-test-audio`
