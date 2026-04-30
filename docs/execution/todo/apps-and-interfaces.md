# TODO — Apps and interfaces

## COMPLETED

### APP-010 Define native macOS 26+ UI scaffold and design-system scope
Outcome:
- added a canonical architecture document for native macOS 26+ app-shell and Liquid Glass scope across Scribe, Sortio, CloudClinic, and a future HealthOS control panel
- updated the SwiftPM manifest to `swift-tools-version: 6.2` and `.macOS(.v26)` so the package target matches the macOS 26 development baseline
- added a repository-local `native-macos-ui` execution skill that composes app-boundary discipline with SwiftPM, SwiftUI patterns, and Liquid Glass guidance
- clarified that Scribe remains the only implemented native validation surface, while Sortio, CloudClinic, and the control panel are scope-defined until executable targets are intentionally introduced
- preserved app-boundary doctrine: no UI-owned consent, habilitation, gate, finality, storage law, provider behavior, or GOS policy
Files touched:
- `swift/Package.swift`
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/execution/skills/native-macos-ui/SKILL.md`
- `docs/execution/skills/README.md`
- `README.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/12-next-agent-handoff.md`

### DOC-002 README entry-surface expansion and visual atlas pass
Outcome:
- `README.md` now functions more clearly as the repository entry surface with reading-path tables, visual repository/document maps, and cross-language contract orientation
- visual additions remain documentation-only and do not claim product UI maturity or Apple runtime behavior
Files touched:
- `README.md`
- `docs/execution/02-status-and-tracking.md`

### SCRIBE-008 Surface minimal honest GOS runtime mediation in Scribe
Outcome:
- expanded `ScribeSessionBridgeState.gosRuntimeState` from coarse active/inactive status into an app-safe audit surface with active workflow title, bundle/spec identity, bound actors/families, reasoning boundaries, and SOAP/referral/prescription mediation markers
- updated CLI and minimal SwiftUI Scribe output so the executable slice shows where AACI consumed GOS (`gos.use.compose.soap`, `gos.use.derive.referral`, `gos.use.derive.prescription`) while keeping app law ownership out of Scribe
- preserved raw-spec boundary: no compiled GOS spec JSON or runtime-binding JSON is exposed to the app surface, and GOS remains `legalAuthorizing=false`, gate-required, and draft-only for referral/prescription
- validation: `swift build`, `swift run HealthOSCLI`, `swift run HealthOSCLI --reject-gate`, `swift run HealthOSScribeApp --smoke-test`, and `swift run HealthOSScribeApp --smoke-test-audio` passed; follow-up `swift test` passed after TEST-001 cleanup
Files touched:
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `swift/Sources/HealthOSScribeApp/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `swift/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `docs/architecture/22-runtime-state-surfaces.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/33-gos-app-consumption-patterns.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/todo/apps-and-interfaces.md`

### SCRIBE-007 Harden Scribe professional workspace and AACI session app-safe contracts
Outcome:
- added explicit governed contracts for professional workspace context, Scribe session state machine, capture/transcription surface, retrieval/context surface, draft review surface, human gate review, final-document lineage surface, and aggregate app runtime boundary state
- hardened Scribe first-slice bridge state to carry runtime-mediated professional session state, workspace context, and allowed next actions without moving consent/habilitation/finality law into app/UI
- added dedicated Swift XCTest boundary suite (`ScribeProfessionalWorkspaceContractsTests`) covering required negative paths (habilitation/finalidade/patient gating, gate/finalization state-machine guards, degraded honesty, app-boundary leak prevention)
Files touched:
- `swift/Sources/HealthOSCore/ScribeProfessionalWorkspaceContracts.swift`
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `swift/Tests/HealthOSTests/ScribeProfessionalWorkspaceContractsTests.swift`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

### APP-006 Consolidate architecturalized compliance doctrine for app boundaries
Outcome:
- interface doctrine now states compliance as architecturalized in HealthOS seams/contracts
- app-boundary guarantee limits documented with ecosystem governance mitigations (review/licensing/revocation)
Files touched:
- `docs/architecture/19-interface-doctrine.md`
- `docs/adr/0010-health-exclusive-ontology-and-architecturalized-compliance.md`

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
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`

### SCRIBE-002 Add minimal SwiftUI first-slice surface
Outcome:
- Scribe now has a minimal macOS SwiftUI validation surface for the first slice
- the UI consumes a small observable view model over `ScribeFirstSliceFacade` instead of reimplementing governance/runtime law
- first-slice executable wiring is shared between CLI and app through `HealthOSSessionRuntime`
Files touched:
- `swift/Package.swift`
- `swift/Sources/HealthOSSessionRuntime/`
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
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
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
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
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
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
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
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `swift/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `swift/Sources/HealthOSScribeApp/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeApp/Views/ScribeFirstSliceView.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`

### SORTIO-002 Harden user-agent and patient-sovereignty app-safe contracts
Outcome:
- User Agent scope/request/response and capability boundary contracts added in Swift Core + TS contracts, including fail-closed guards for prohibited clinical/regulatory capabilities and non-informational outputs
- patient-facing consent/audit/export/visibility surfaces are now explicit app-safe contracts with lawfulContext and sensitive-layer policy validation
- Sortio boundary validation contract now rejects raw CPF exposure, raw storage path leakage, and prohibited clinical capability surfacing
Files touched:
- `swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`
- `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift`
- `ts/packages/contracts/src/index.ts`
- `ts/packages/runtime-user-agent/src/index.ts`
- `schemas/contracts/user-agent-patient-sovereignty-sortio.schema.json`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`

### CLOUD-002 Harden service-operations and CloudClinic app-safe core contracts
Outcome:
- added governed Service Operations contracts for context, membership roles, professional habilitation surface, patient-service relationship, queue/worklist, document/draft surface, gate worklist, and administrative task allowlist
- fail-closed Swift validators enforce CloudClinic mediation boundary (no direct law decisions, no queue-as-authorization, no admin clinical gate approval, no direct identifier leakage)
- cross-language contract alignment extended with TS contract types and JSON Schema for service operations surface bundle
- dedicated Swift XCTest coverage added for required negative and positive governance paths
Files touched:
- `swift/Sources/HealthOSCore/ServiceOperationsContracts.swift`
- `swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/service-operations-cloudclinic.schema.json`
- `docs/architecture/41-service-operations-cloudclinic-core-contracts.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`


### APP-007 Harden cross-app coordination shared app surfaces/contracts
Outcome:
- added shared cross-app app-facing envelope contract with typed app kind/actor role/safe subject refs/allowed-denied actions/issues/provenance-audit refs/redaction posture and explicit `legalAuthorizing = false`
- added typed safe-reference taxonomy (`SafeUserRef`, `SafePatientRef`, `SafeProfessionalRef`, `SafeServiceRef`, `SafeSessionRef`, `SafeDraftRef`, `SafeGateRef`, `SafeArtifactRef`, `SafeExportRef`, `SafeAuditRef`, `SafeProvenanceRef`) with navigation-vs-access capability posture and anti-sensitive-leak guards
- added role/app-aware action and notification/obligation validators so Scribe/Sortio/CloudClinic surfaces fail-closed on app mismatch, role mismatch, non-core command refs, sensitive payload leaks, and unrecorded patient-obligation completion
- added dedicated Swift XCTest boundary suite (`CrossAppCoordinationContractsTests`) covering shared envelope, safe refs, role-aware actions, redaction defaults, notification payload minimization, and cross-app surface isolation negatives
- aligned TypeScript contracts and JSON schema with the new shared cross-app surface vocabulary
Files touched:
- `swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`
- `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/cross-app-coordination-shared-surfaces.schema.json`
- `docs/architecture/43-cross-app-coordination-shared-surfaces.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/todo/apps-and-interfaces.md`

## COMPLETED (continued)

### APP-009 Documentation drift check for app-boundary claims
Outcome:
- added explicit "Scaffold posture / non-claims" sections to Scribe, Sortio, and CloudClinic architecture docs
- interface doctrine doc now includes scaffold-honest summary clarifying Scribe as minimal SwiftUI validation surface and Sortio/CloudClinic as contract-first only
- wording hardened to avoid implying final UI, production readiness, or real provider integration
- execution tracking updated with APP-009 completion entry
Files touched:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

## READY

### APP-008 Propagate cross-app shared envelope consumption into non-Scribe adapters
Priority: High
Skill: `docs/execution/skills/cross-app-surfaces-skill.md` + `docs/execution/skills/app-boundary-skill.md`
Definition of done:
- Sortio/CloudClinic adapter seams consume shared envelope contracts without raw payload leaks
- boundary tests added/updated for app-kind + role mismatch and safe-ref enforcement

### APP-011 Future native app-shell implementation pass
Priority: Medium
Skill: `docs/execution/skills/native-macos-ui/SKILL.md` + relevant app skill + `docs/execution/skills/liquid-glass/SKILL.md`
Definition of done:
- choose one shell explicitly: Scribe app-shell refactor, Sortio scaffold, CloudClinic scaffold, or HealthOS control panel scaffold
- consume only mediated contracts already available for that shell
- use macOS 26+ SwiftUI/Liquid Glass conventions without custom chrome or UI-owned law
- validate with SwiftPM and relevant smoke/test path


## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
- `swift build`
- `swift test`
- `swift run HealthOSCLI`
- `swift run HealthOSCLI --reject-gate`
- `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff`
- `swift run HealthOSScribeApp --smoke-test`
- `swift run HealthOSScribeApp --smoke-test-audio`
