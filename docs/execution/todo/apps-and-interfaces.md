# TODO — Stages and interfaces

## COMPLETED

### SWIFT-ONTOLOGY-SECOND-PASS Boundary and Stage technical rename
Outcome:
- renamed the canonical Swift Boundary module from `HealthOSAppBoundary` to `HealthOSBoundary`
- renamed initial Stage executable products/targets from `HealthOSScribeApp`, `HealthOSVeridiaApp`, and `HealthOSCloudClinicApp` to `HealthOSScribeStage`, `HealthOSVeridiaStage`, and `HealthOSCloudClinicStage`
- updated SwiftPM, imports, tests, Xcode shared schemes, Makefile smoke commands, module READMEs, app/docs surfaces, Steward prompt text, and Settler/Territory metadata
- kept Stage wiring honest: Scribe and Veridia direct Tier 1/2 imports remain marked TODOs pending complete Boundary facades; CloudClinic remains Boundary-only
Files touched:
- `swift/Package.swift`
- `swift/Sources/HealthOSBoundary/`
- `swift/Tests/HealthOSBoundaryTests/`
- `swift/Sources/HealthOSScribeStage/`
- `swift/Sources/HealthOSVeridiaStage/`
- `swift/Sources/HealthOSCloudClinicStage/`
- `swift/.swiftpm/xcode/xcshareddata/xcschemes/`
- `Makefile`
- `.healthos-steward/`
- `.healthos-settler/`
- docs and README surfaces that referenced the old technical names
Validation:
- `cd swift && swift build` PASS after sandbox escalation for Swift/Clang cache access
- `cd swift && swift test` PASS — 269 XCTest tests passed plus Swift Testing suites loaded
- `git diff --check` PASS
- `make validate-docs` PASS
- `make validate-schemas` PASS
- `make validate-contracts` PASS
- `make smoke-scribe`, `make smoke-veridia`, and `make smoke-cloudclinic` PASS after serialized SwiftPM execution outside the sandbox

### APP-011 Veridia: smoke-testable executable path
Outcome:
- wired `UserSovereigntyContracts.swift` into a minimal `VeridiaSessionFacade` / `VeridiaSessionAdapter` so Veridia has an executable governed session boundary
- updated `HealthOSVeridiaStage --smoke-test` to verify `veridia.session.start` and `veridia.session.end`
- added boundary smoke tests for lawful-context denial, unknown/double end, and provenance/audit references
Files touched:
- `swift/Sources/HealthOSCore/VeridiaSessionContracts.swift`
- `swift/Sources/HealthOSCore/VeridiaSessionAdapter.swift`
- `swift/Sources/HealthOSVeridiaStage/VeridiaEntrypoint.swift`
- `swift/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift`
Validation:
- 268 Swift tests passed
- `make smoke-veridia` PASS (`veridia.session.start + veridia.session.end boundary verified`)
Residual gaps:
- no final Veridia UI
- no production readiness, real provider/signature/interoperability behavior, or clinical/regulatory authority

### APP-013A Remove residual legacy patient-app naming drift
Outcome:
- removed remaining working-tree uses of the legacy patient-app name from active docs, generated prompts, and construction metadata
- aligned Steward prompt assembly text so generated artifacts define Veridia as the patient health identity app
- validated zero remaining legacy patient-app name matches in the working tree
Files touched:
- `ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts`
- `.healthos-steward/prompts/generated/st-012-settler-profile-registry.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`
- supporting docs and metadata with stale naming
Validation:
- legacy patient-app naming grep across the working tree returned 0 matches

### APP-008 Propagate cross-app shared envelope consumption into non-Scribe adapters
Outcome:
- propagated `AppSurfaceEnvelope` validation into Veridia/User-Agent and CloudClinic/Service Runtime adapter seams without granting app-owned legal authority
- added boundary evidence for `legalAuthorizing = false`, raw direct identifier denial, app-kind mismatch, role/action mismatch, and safe-ref enforcement
- confirmed this closes the cross-app adapter propagation TODO at scaffold-contract maturity only; it does not implement final Veridia or CloudClinic UI/session flows
Files touched:
- `swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`
- `swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift`
- `ts/packages/runtime-user-agent/src/index.ts`
- `ts/packages/service-runtime/src/index.ts`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

### STR-005 Add placeholder Swift executable targets for Veridia and CloudClinic
Outcome:
- added `HealthOSVeridiaStage` and `HealthOSCloudClinicStage` as minimal Swift executable scaffold targets so the HealthOS product graph no longer represents only Scribe as an app/interface surface
- added honest `--smoke-test` paths for both placeholders: scaffold-only, no final UI, no clinical authority, and no production-readiness claim
- added `make smoke-veridia` and `make smoke-cloudclinic` while preserving existing CLI/Scribe smoke targets
- unblocked APP-011 and APP-012 as next Stage wiring tasks without implementing either session path at that time; ADR-0013 later blocked APP-012 pending Core/GOS/runtime/Boundary/Custom readiness
Files touched:
- `swift/Package.swift`
- `swift/Sources/HealthOSVeridiaStage/VeridiaEntrypoint.swift`
- `swift/Sources/HealthOSCloudClinicStage/CloudClinicEntrypoint.swift`
- `Makefile`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/architecture/12-veridia.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

### APP-010 Define native macOS 26+ UI scaffold and design-system scope
Outcome:
- added a canonical architecture document for native macOS 26+ app-shell and Liquid Glass scope across Scribe, Veridia, CloudClinic, and a future HealthOS control panel
- updated the SwiftPM manifest to `swift-tools-version: 6.2` and `.macOS(.v26)` so the package target matches the macOS 26 development baseline
- added a repository-local `native-macos-ui` execution skill that composes app-boundary discipline with SwiftPM, SwiftUI patterns, and Liquid Glass guidance
- clarified that Scribe remains the only implemented native validation surface, while Veridia, CloudClinic, and the control panel are scope-defined until executable targets are intentionally introduced
- preserved app-boundary doctrine: no UI-owned consent, habilitation, gate, finality, storage law, provider behavior, or GOS policy
Files touched:
- `swift/Package.swift`
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-veridia.md`
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

### DOC-README-VISUAL-PRESENTATION-001 README visual information and presentation pass
Outcome:
- audited the current README after DOC-README-001/ST-018 and avoided a broad rewrite of already-correct architecture, command, and reading-path sections
- added a compact entry lens for new agents: what HealthOS is, what is executable now, what remains scaffolded/placeholder, and where construction tooling sits
- added a clinical/runtime hierarchy versus repository construction-layer diagram that keeps Steward, Settlers, Settlements, Territories, and `healthos-forge-mcp` outside HealthOS clinical/runtime authority
- added an evidence/maturity lens using the official ladder and an honest note for the generated executive visual overview deck
- generated the editable PPTX as an external work-unit deliverable, not a versioned asset, because no clear `docs/assets/presentations/` pattern exists in this checkout
Files touched:
- `README.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`
- `docs/execution/12-next-agent-handoff.md`
Validation:
- `git diff --check` PASS
- `make validate-docs` PASS
- presentation artifact-tool build produced a non-empty 9-slide PPTX with rendered previews/contact sheet and 0 layout QA warnings before cleanup
Residual gaps:
- future repository decision needed before versioning PPTX assets under a durable docs/assets path
- downstream app-shell, product-wiring, CI, semantic retrieval, and production-hardening tasks remain open; this pass does not mark them DONE

### SCRIBE-008 Surface minimal honest GOS runtime mediation in Scribe
Outcome:
- expanded `ScribeSessionBridgeState.gosRuntimeState` from coarse active/inactive status into an app-safe audit surface with active workflow title, bundle/spec identity, bound actors/families, reasoning boundaries, and SOAP/referral/prescription mediation markers
- updated CLI and minimal SwiftUI Scribe output so the executable slice shows where AACI consumed GOS (`gos.use.compose.soap`, `gos.use.derive.referral`, `gos.use.derive.prescription`) while keeping app law ownership out of Scribe
- preserved raw-spec boundary: no compiled GOS spec JSON or runtime-binding JSON is exposed to the app surface, and GOS remains `legalAuthorizing=false`, gate-required, and draft-only for referral/prescription
- validation: `swift build`, `swift run HealthOSCLI`, `swift run HealthOSCLI --reject-gate`, `swift run HealthOSScribeStage --smoke-test`, and `swift run HealthOSScribeStage --smoke-test-audio` passed; follow-up `swift test` passed after TEST-001 cleanup
Files touched:
- `swift/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `swift/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `swift/Sources/HealthOSScribeStage/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeStage/Views/ScribeFirstSliceView.swift`
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
- Veridia flow expanded with screens, user-facing sovereignty states, and explicit app boundaries
Files touched:
- `docs/architecture/12-veridia.md`

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
- per-screen commands, contract calls, and result/error states documented for the initial Stages
Files touched:
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/architecture/24-veridia-screen-contracts.md`
- `docs/architecture/25-cloudclinic-screen-contracts.md`

### APP-004 Link screen contracts back into main app architecture docs
Outcome:
- app overview docs now point explicitly to their detailed screen-contract documents
Files touched:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-veridia.md`
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
- `swift/Sources/HealthOSScribeStage/`
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
- `swift/Sources/HealthOSScribeStage/`
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
- `swift/Sources/HealthOSScribeStage/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeStage/Views/ScribeFirstSliceView.swift`
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
- `swift/Sources/HealthOSScribeStage/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeStage/Views/ScribeFirstSliceView.swift`
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
- `swift/Sources/HealthOSScribeStage/Models/ScribeFirstSliceViewModel.swift`
- `swift/Sources/HealthOSScribeStage/Views/ScribeFirstSliceView.swift`
- `docs/architecture/11-scribe.md`
- `docs/architecture/23-scribe-screen-contracts.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`

### SORTIO-002 Harden user-agent and patient-sovereignty app-safe contracts
Outcome:
- User Agent scope/request/response and capability boundary contracts added in Swift Core + TS contracts, including fail-closed guards for prohibited clinical/regulatory capabilities and non-informational outputs
- patient-facing consent/audit/export/visibility surfaces are now explicit app-safe contracts with lawfulContext and sensitive-layer policy validation
- Veridia boundary validation contract now rejects raw CPF exposure, raw storage path leakage, and prohibited clinical capability surfacing
Files touched:
- `swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`
- `swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift`
- `ts/packages/contracts/src/index.ts`
- `ts/packages/runtime-user-agent/src/index.ts`
- `schemas/contracts/user-agent-patient-sovereignty-veridia.schema.json`
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
- added role/app-aware action and notification/obligation validators so Scribe/Veridia/CloudClinic surfaces fail-closed on app mismatch, role mismatch, non-core command refs, sensitive payload leaks, and unrecorded patient-obligation completion
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
- added explicit "Scaffold posture / non-claims" sections to initial Stage architecture docs
- interface doctrine doc now includes scaffold-honest summary clarifying Scribe as minimal SwiftUI validation surface and Veridia/CloudClinic as contract-first only
- wording hardened to avoid implying final UI, production readiness, or real provider integration
- execution tracking updated with APP-009 completion entry
Files touched:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-veridia.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

### DS-001 HealthOSDesignSystem: commit and Veridia alignment
Outcome:
- committed the untracked HealthOSDesignSystem/ directory as a construction artifact (presentation layer only; no Core law, consent, habilitation, gate, finality, or GOS)
- renamed all Veridia references to Veridia following APP-013: ui_kits/veridia/ → ui_kits/veridia/, glyph-veridia.svg → glyph-veridia.svg
- updated stale architecture doc pointers in README.md (12-veridia.md → 12-veridia.md, 24-veridia-screen-contracts.md → 24-veridia-screen-contracts.md) and SKILL.md
- maturity: Scribe kit = implemented seam; Veridia kit = scaffolded contract (placeholder); CloudClinic kit = scaffolded contract (placeholder)
Files touched:
- `HealthOSDesignSystem/README.md`
- `HealthOSDesignSystem/SKILL.md`
- `HealthOSDesignSystem/assets/glyph-veridia.svg` → `HealthOSDesignSystem/assets/glyph-veridia.svg`
- `HealthOSDesignSystem/ui_kits/veridia/` → `HealthOSDesignSystem/ui_kits/veridia/` (README.md and index.html updated)
- `HealthOSDesignSystem/preview/brand-glyphs.html`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

## READY

No Stage implementation TODO is currently READY after ADR-0013. New Stage wiring must wait for Core/GOS/runtime surface readiness, explicit Boundary, and complete Custom.

## BLOCKED / NEEDS-REVIEW

### APP-012 CloudClinic: smoke-testable executable path
Priority: Medium
Status: BLOCKED after ADR-0013
Skill: `docs/execution/skills/native-macos-ui/SKILL.md` + relevant app skill + `docs/execution/skills/liquid-glass/SKILL.md`
Definition of done:
- wire the existing CloudClinic boundary contracts into a minimal smoke-testable executable path
- consume only mediated contracts already available for CloudClinic
- do not move service access law, membership policy, gate/finality law, storage law, or clinical authority into the app target
- validate with SwiftPM and the CloudClinic smoke path

Blockers:
- Tier 1 platform/runtime foundations must be DONE or explicitly accepted as out-of-scope/degraded for APP-012: `CI-001`, `RT-ASYNC-001`, `RT-RETRIEVAL-001`.
- CloudClinic Boundary needs review: exact facade/envelope/app-safe view must be defined and proven stable.
- CloudClinic Custom is incomplete: degraded behavior, consumed surfaces, data exposure limits, and validation expectations must be completed before implementation.

Unblock criterion:
- Update `docs/architecture/50-app-layer-boundary-and-reference-apps.md` or a follow-up Custom doc with a complete CloudClinic Custom, prove the consumed mediated surfaces are implemented/stable, then reclassify APP-012 explicitly.


## TESTS / VALIDATION

- no app owns core law logic
- every app consumes core/runtime contracts instead of reimplementing them
- app boundaries match user role and service context
- `swift build`
- `swift test`
- `swift run HealthOSCLI`
- `swift run HealthOSCLI --reject-gate`
- `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff`
- `swift run HealthOSScribeStage --smoke-test`
- `swift run HealthOSScribeStage --smoke-test-audio`
- `swift run HealthOSVeridiaStage --smoke-test`
- `swift run HealthOSCloudClinicStage --smoke-test`
