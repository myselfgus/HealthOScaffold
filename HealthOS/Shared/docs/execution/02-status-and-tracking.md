# Status and tracking

## Current global status

Current phase: Controlled implementation — first vertical slice started

## Completed recently

## PUBLIC-LANDING-001 — External stakeholder landing page (2026-05-11)

- Objective: add a dependency-free public landing page for investors, partners, early adopters, press, and technical stakeholders using only repository-verifiable HealthOS claims.
- Classification: External — public presentation/documentation surface. It is not Core, GOS/runtime, Boundary, Stage, Construction System authority, clinical authority, regulatory authority, or production-readiness evidence.
- Outcome:
  - Added `HealthOS/Public/landing/index.html` and `HealthOS/Public/landing/styles.css` as a static, responsive, accessible landing page that can be served from the repository without introducing web-framework dependencies.
  - Copy is constrained to documented HealthOS identity: scaffold/foundation-stage Juridical Application Engine posture, Core Law, tiered platform model, executable first-slice orchestration, cross-language contracts, native macOS Stage scaffolds, and explicit non-production maturity.
  - CTAs point only to existing repository documentation (`README.md`, architecture overview, and status tracking).
- Validation status:
  - `python3 -m html.parser HealthOS/Public/landing/index.html` PASS.
  - `git diff --check` PASS.
  - `make validate-docs` PASS.


## GAI-001 — Governed AI Agent Society first slice (2026-05-09)

- Objective: introduce a governed AI agent society across Tier 1-3: personal AI agents for patient/professional/user plus internal Core, runtime, provider/model, and Boundary/protocol agent families.
- Classification: Tier 1 — Core contracts and policy validation; Tier 2 — User-Agent Runtime / provider-routing seam; Tier 3 — Boundary protocol projection. Explicitly not Tier 4 Stage work. Veridia/Scribe/CloudClinic roles were not moved, and Veridia was not made a key vault.
- Architecture:
  - ADR-0014 and `52-governed-ai-agent-society.md` define agent as persistent governed identity with `AgentID`, represented principal, mandate, memory scope, tool grants, provider policy, delegation policy, and protocol posture. LLM/model/provider remains selectable engine, not authority.
  - Core contracts now include `AgentPrincipalRef`, `AgentMandate`, `DelegationPolicy`, `AgentMemoryScope`, `AgentToolGrant`, `AgentProviderRoutingPolicy`, `AgentNegotiationEnvelope`, `EphemeralAccessGrantRef`, `CustodyControlRef`, `GovernedAIAgentDescriptor`, `AgentProtocolProjection`, and fail-closed validators.
  - `PersonalAgentRuntime` starts patient, professional, and generic user personal agents, validates Core policy, preserves informational-only responses, supports governed offline queue posture, and uses provider routing when configured.
  - `AgentProtocolBoundary` projects HealthOS AACP/A2A/ACP adapter payloads without raw identifiers, reidentification maps, raw storage, key material, internal memory, tool implementations, or legal-authorizing claims.
- Contracts:
  - Swift, TypeScript, and JSON Schema now mirror the governed AI agent society vocabulary.
  - Runtime kind vocabulary now includes Core, GOS, MSR, provider, service, session, user-agent, and Boundary surfaces.
- Validation status:
  - `git diff --check` PASS.
  - `make validate-docs` PASS.
  - `make validate-schemas` PASS.
  - `make validate-contracts` PASS.
  - `make ts-build` PASS.
  - `make ts-test` PASS.
  - `make swift-build` PASS after sandbox escalation for Swift/Clang cache access.
  - `cd HealthOS && swift test` PASS with 293 XCTest tests.
  - `cd HealthOS && swift test --filter GovernedAIAgentTests` PASS.
  - `cd HealthOS && swift test --filter PersonalAgentRuntimeTests` PASS.
  - `cd HealthOS && swift test --filter AgentNegotiationBoundaryTests` PASS.
  - `make validate-all` PASS: bootstrap-local, validate-docs, validate-schemas, validate-contracts, swift-build, swift-test, stage-package-check, ts-build, ts-test, python-check, smoke-cli, smoke-scribe, smoke-veridia, and smoke-cloudclinic.
  - Validation remains local scaffold validation only; it is not production validation or compliance certification.

## DOC-JAE-APPLE-SUBSTRATE — Apple substrate JAE doctrine and Stage import guard (2026-05-09)

- Objective: document how Apple-native frameworks enter HealthOS as governed JAE substrate capabilities and add an executable Stage package/source guard against direct Tier 2 or Apple authority imports.
- Classification: Tier 3 — Boundary / Custom doctrine and tests, Tier 4 — Stage package structural guard, Tier 2 — provider/runtime doctrine, Tier 1 — storage/evidence doctrine, plus External — CI/construction guidance. No runtime Apple integration, provider maturity upgrade, canonical storage change, regulatory/legal claim, production-readiness claim, Xcode Intelligence claim, or Apple Private Cloud Compute claim changed.
- Architecture:
  - Added `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md` to define SwiftData, CloudKit, FoundationModels, Core ML, Create ML, NaturalLanguage, RegexBuilder, CryptoKit, AppleArchive, XPC, ServiceManagement, Network, ThreadNetwork, Virtualization/vmnet, FSKit, and Xcode Cloud as HealthOS-governed substrate capabilities.
  - Preserved the exposure model: Stage request -> Custom -> Boundary -> Core Law -> runtime adapter -> Apple substrate -> provenance/audit -> Boundary-mediated result.
  - Kept non-claims explicit: no SwiftData/CloudKit canonical custody, no Stage-owned provider authority, no real semantic retrieval, no distributed mesh/workers, no regulatory/legal signature integration, and no production readiness.
- Gap tracking:
  - Added Apple-native implementation-track notes for GAP-003 through GAP-010 without changing gap classification or maturity.
  - README, AGENTS, CLAUDE, and the skills index now point agents to the JAE Apple substrate rules.
- Tests:
  - Strengthened `StagePackageStructureTests` and `scripts/check-stage-packages.sh` so Stage packages must depend on `HealthOSBoundary` and `CustomSDK`, must not depend on Tier 1/2 HealthOS products, must not import Tier 2 or Apple authority frameworks directly, and must document any future SwiftData import as projection/cache-only.
- Validation status:
  - `make stage-package-check` PASS.
  - `make validate-docs` PASS.
  - `git diff --check` PASS.
  - `cd HealthOS && swift test --filter StagePackageStructureTests` not run to completion in this Linux container because the package imports Apple-only `OSLog`; rerun on the documented macOS 26+ toolchain.

## STAGE-PACKAGE-CUSTOM-SDK — Stage package split and Custom SDK guard (2026-05-09)

- Objective: resolve the post-tier-root contradiction where Tier 4 Stages were documented as separate governed consumers but still lived as executable products in the central `HealthOS/Package.swift`.
- Classification: Tier 3 — Custom Boundary plus Tier 4 — Stage structural package work. No Core law, runtime behavior, provider maturity, clinical authority, or production-readiness claim changed.
- Package graph:
  - `HealthOS/Package.swift` now owns platform products only: Tiers 1-3, `CustomSDK`, `HealthOSBoundary`, `HealthOSCLI`, and structural/shared test targets.
  - `Scribe`, `Veridia`, and `CloudClinic` each own a separate `Package.swift` under `HealthOS/Tier4-Stages-Cast/<Stage>/`.
  - Stage packages depend on the platform package only through `HealthOSBoundary` and `CustomSDK`.
- Custom/Boundary:
  - `CustomSDK` was added as the scaffold SDK vocabulary for Stage Custom manifests, consumed Boundary surfaces, capabilities, prohibitions, degradation policy, validation requirements, maturity, and compliance checks.
  - `HealthOSBoundary` remains the Stage import surface and currently carries a transitional re-export shim while explicit mediated facades continue to mature.
- Naming:
  - Technical Stage product/source names were changed from `HealthOS*Stage` to `Scribe`, `Veridia`, and `CloudClinic`.
  - Old Stage package/scheme/test names were removed from `HealthOS/Package.swift`, Xcode schemes, README diagrams, active docs, design exports, and UX proposal filenames.
- Xcode:
  - Workspace listing now exposes `Scribe`, `Veridia`, and `CloudClinic` as visible Stage package schemes alongside the tier/all/provider/construction/support/profile schemes.
  - Tier 4 package-level scheme/test plan now points at `StagePackageStructureTests` instead of the former Stage smoke test target.
- Validation status:
  - `make stage-package-check` PASS.
  - `cd HealthOS && swift package dump-package` PASS; `swift build` PASS; `swift test` PASS with 274 XCTest tests.
  - Stage package validation PASS for `Scribe`, `Veridia`, and `CloudClinic`: `swift package dump-package`, `swift build`, and `swift test` in each Stage package root.
  - Smokes PASS: `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, `make smoke-cloudclinic`.
  - `xcodebuild -list -workspace HealthOS.xcworkspace` PASS and lists `Scribe`, `Veridia`, and `CloudClinic`.
  - `make validate-docs` PASS; `git diff --check` PASS; drift search for old `HealthOS*Stage` names in live repo paths/files PASS.

## XCODE-TIER-ROOT-BIG-BANG — HealthOS root physical tier migration (2026-05-08)

- Objective: reorganize the repository around the canonical operational root `HealthOS/`, with physical tier directories for Core/Mestral, GOS/Runtimes, Custom/Boundary, Stages/Cast, external Construction System, provider/support surfaces, shared docs/design/runtime data, and Xcode configuration.
- Classification: cross-tier structural repository organization touching Tier 1, Tier 2, Tier 3, Tier 4, Shared support surfaces, and External Construction System metadata/tooling. No Core law, GOS mediation semantics, runtime behavior, Boundary envelope behavior, Stage behavior, provider policy, schema/SQL semantics, clinical authority, or production-readiness claim changed.
- Files and structure updated:
  - `HealthOS/Package.swift` is now the canonical SwiftPM package; root `Package.swift` remains only as a repository compatibility stub.
  - Swift targets now use explicit `path:` values under `HealthOS/Tier1-Mestral-Core/`, `HealthOS/Tier2-GOS-Runtimes/`, `HealthOS/Tier3-Custom-Boundary/`, `HealthOS/Tier4-Stages-Cast/`, and `HealthOS/Shared/`.
  - `HealthOS/Shared/docs/`, `HealthOS/Tier1-Mestral-Core/Schemas/`, `HealthOS/Tier1-Mestral-Core/SQL/`, `HealthOS/Constructor/`, `HealthOS/Support/`, and Stage `Custom.md` files are now the active operational paths.
  - `HealthOS/Xcode/TestPlans/` contains tier/all test plans, and `HealthOS/Xcode/PromptPacks/HealthOS-Agentic-Coding.md` records the Xcode agentic-coding posture as engineering-only.
  - `HealthOS/Xcode/TestPlans/` now also includes provider, construction, support, and validation-gate plans; package/workspace shared schemes include provider, construction, support, and profile-oriented Core/runtime/provider/validation-gate schemes.
  - `HealthOS.xcworkspace` lists navigable shared schemes for `HealthOS-All`, tiers 1-4, providers, construction, support, profiles, CLI, Stage package smokes, and `HealthOSTests`; command-line scheme execution is validated from the package context with `cd HealthOS && xcodebuild -scheme ...`.
  - `HealthOS/Xcode/Visible-Construction-Support.md`, workspace file refs, and structural tests keep `HealthOS/Constructor/` and `HealthOS/Support/` visible in Xcode navigation as non-tier roots.
  - Shared HealthOS telemetry now uses `os.Logger`/`OSSignposter` categories for Core validation, Session Runtime, MSR, providers, and validation gates without changing runtime semantics.
  - `Support` documentation treats Create ML, Core ML, and MLX as governed tooling surfaces only, blocked from real patient data or loadable-model claims until ModelGovernance/provenance exists.
- Construction System updates:
  - Steward, Settler, Territory, Settlement, Forge MCP, generated prompts, derived memory, and managed-agent state moved under `HealthOS/Constructor/` and remain outside the clinical/runtime hierarchy.
  - TypeScript source/tests were updated for the new repo root, schema path, GOS spec path, and managed-agent state path.
  - Root `AGENTS.md` and `CLAUDE.md` were kept aligned with `Constructor`, `Support`, scheme/test-plan, profile, signpost, provider, and governed ML/tooling posture.
- Validation status:
  - Preflight: `git fetch origin --prune` PASS; `main` and `origin/main` both at `d629c4fb98b1a26dcbfb138447d8006531ef175b`; `git rev-list --left-right --count main...origin/main` returned `0 0`; branch `codex/healthos-tier-root-big-bang` created.
  - SwiftPM: `cd HealthOS && swift package dump-package` PASS; `swift build` PASS; `swift test` PASS with 274 XCTest tests and Swift Testing suites loaded.
  - Xcode package schemes: `HealthOS-Tier1-Mestral-Core`, `HealthOS-Tier2-GOS-Runtimes`, `HealthOS-Tier3-Custom-Boundary`, `HealthOS-Tier4-Stages-Cast`, `HealthOS-Providers`, `HealthOS-Construction`, `HealthOS-Support`, and `HealthOS-All` PASS with `xcodebuild -scheme ... -destination platform=macOS`.
  - Xcode profile package schemes: `HealthOS-Profile-Core`, `HealthOS-Profile-Runtimes`, `HealthOS-Profile-Providers`, and `HealthOS-Profile-Validation-Gates` PASS with `xcodebuild -scheme ... -destination platform=macOS build`.
  - Workspace listing: `xcodebuild -list -workspace HealthOS.xcworkspace` PASS and lists all shared schemes.
  - Repository gates: `make validate-docs` PASS; `make validate-schemas` PASS; `make validate-contracts` PASS; `make ts-build` PASS; `make ts-test` PASS; `make validate-all` PASS; `git diff --check` PASS.
  - Smokes: `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, and `make smoke-cloudclinic` PASS.
- Residual note: the first broad validation pass exposed TypeScript path drift from the move; after fixing that drift, the complete local gate passed. The workspace is validated as the navigable/listable Apple entry; the CLI-tested build/test path for tier and profile schemes remains the Swift package context.

## CS-FORGE-PARITY — Forge MCP parity tests and shared settlement validation (2026-05-07)

- Objective: continue Construction System hardening by making Forge MCP parity executable in tests and sharing Settlement done-criteria classification between `healthos-steward` and `healthos-forge-mcp`.
- Classification: External — Construction System. No HealthOS clinical/runtime hierarchy, Core law, Boundary, Stage, provider behavior, schema contract, SQL, or production-readiness claim changed.
- Implementation updates:
  - Extracted Settlement done-criteria classification into `@healthos/steward` shared library exports so CLI validation and Forge MCP validation use the same PASS/FAIL/UNVERIFIED heuristic.
  - Added `@healthos/forge-mcp` package tests covering the documented 10 `steward_*` tools, callable Settlement `id` plus `canonicalId`, and `steward_validate_settlement` / `steward_generate_prompt` resolution for both ID forms.
  - Added test-only read-only prompt generation support in the Forge MCP handler so ID resolution can be tested without writing generated artifacts from workspace test cwd.
- Validation status:
  - `cd HealthOS/Constructor/ts && npm test --workspace @healthos/steward` PASS.
  - `cd HealthOS/Constructor/ts && npm test --workspace @healthos/forge-mcp` PASS.
  - `make validate-construction-system` PASS.
  - `make ts-build` PASS.
  - `make ts-test` PASS.
  - `make validate-docs` PASS.
  - `git diff --check` PASS.

## CS-HARDENING — Construction System truth, validation, and generated artifact policy (2026-05-07)

- Objective: harden the external Construction System by aligning live HealthOS/Shared/docs/records with implemented Steward/Forge seams, making ST-020 explicitly CloudClinic Boundary/Custom readiness work, and adding deterministic validation for Construction System invariants.
- Classification: External — Construction System. No HealthOS clinical/runtime hierarchy, Core law, Stage implementation, provider behavior, schema contract, SQL, or production-readiness claim changed.
- Implementation updates:
  - `healthos-steward` now exposes `validate-construction-system` and its usage text lists all implemented commands.
  - Settlement lookup now resolves both filename IDs such as `st-012-settler-profile-registry` and canonical IDs such as `SETTLEMENT-20260504-settler-profile-registry`.
  - ST tracker parsing now preserves `rawStatus` and classifies composite states such as `NEEDS-REVIEW / BLOCKED AS WRITTEN`.
  - `healthos-forge-mcp` settlement list responses now include callable `id`, `canonicalId`, and path fields.
- Documentation/metadata updates:
  - Construction docs, handoff, Territory/Settler records, and Settlement templates now describe `healthos-steward`, prompt generation, validation/report drafting, derived memory, and `healthos-forge-mcp` as implemented repository-maintenance seams where validated.
  - ST-020 remains needs-review / blocked as written and must be reframed as CloudClinic Custom / Boundary-readiness work before any APP-012 Stage implementation prompt is generated.
  - Generated prompts and derived memory are explicitly non-canonical, regenerable local artifacts.
- Validation status:
  - `make validate-construction-system` PASS.
  - `cd HealthOS/Constructor/ts && npm test --workspace @healthos/steward` PASS.
  - `make ts-build` PASS.
  - `make ts-test` PASS.
  - `make validate-docs` PASS.
  - `git diff --check` PASS.

## SWIFT-ONTOLOGY-SECOND-PASS — Boundary and Stage technical rename (2026-05-07)

- Objective: complete the second ontology alignment pass by renaming Swift modules, targets, tests, imports, package references, Xcode schemes, Steward/Settler guidance, and technical docs to the canonical HealthOS vocabulary.
- Classification: Tier 3 Boundary, Tier 4 Stage, and External Construction System metadata/docs. No CoreLaw, GOS, runtime behavior, clinical flow, provider behavior, schema contract, SQL, or production claim changed.
- Code/package renames:
  - `HealthOSAppBoundary` -> `HealthOSBoundary`; `AppBoundary` placeholder -> `Boundary`; `HealthOSAppBoundaryTests` -> `HealthOSBoundaryTests`.
  - `HealthOSScribeApp` -> `Scribe`; `HealthOSVeridiaApp` -> `Veridia`; `HealthOSCloudClinicApp` -> `CloudClinic`.
  - SwiftPM products, targets, test target, imports, Makefile smoke commands, Xcode shared schemes, and `PackageTargetsExplorer.swift` updated to the new names.
- Boundary dependency posture:
  - All Stage targets depend on `HealthOSBoundary` as their primary consumption surface.
  - Current direct Tier 1/2 deviations remain explicit TODOs in `HealthOS/Package.swift`: Scribe still imports Core/SessionRuntime until the Scribe session facade moves into Boundary; Veridia still imports Core until Veridia session types move into Boundary.
  - CloudClinic remains Boundary-only at the package level.
- Docs and construction metadata updated:
  - `README.md`, `HealthOS/Tier4-Stages-Cast/AppDocs/`, Swift module READMEs, architecture/execution docs, skills/prompts, `HealthOS/Constructor/Steward/`, and `HealthOS/Constructor/Settler/` now refer to the new technical names.
  - The historical file path `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md` is retained as a compatibility path, with an explicit note that the canonical concepts are Boundary, Stage, and Custom.
- Audit result:
  - Active code/package/docs no longer use `HealthOSAppBoundary`, `HealthOSAppBoundaryTests`, `HealthOSScribeApp`, `HealthOSVeridiaApp`, `HealthOSCloudClinicApp`, `AppBoundary`, `App Integration Boundary`, `app boundary`, `App Charter`, `Reference App`, `reference app`, `app implementation`, or `app wiring` as live canonical names.
  - Remaining matches for old terms are limited to this audit/rename record, explicit compatibility/history notes, and derived historical Steward memory digests under `HealthOS/Constructor/Steward/memory/automations/`.
  - Residual matches under `.claude/worktrees/` are pre-existing local worktree content outside this branch and were intentionally not modified.
- Validation status:
  - `git diff --check` PASS.
  - `cd HealthOS && swift build` PASS after sandbox escalation for Swift/Clang cache access.
  - `cd HealthOS && swift test` PASS — 269 XCTest tests passed plus Swift Testing suites loaded.
  - `make validate-docs` PASS.
  - `make validate-schemas` PASS.
  - `make validate-contracts` PASS.
  - Additional smoke validation: `make smoke-scribe`, `make smoke-veridia`, and `make smoke-cloudclinic` PASS after sandbox escalation and serialized SwiftPM execution.

## DOC-CONSTITUTIONAL-STAGE-CUSTOM — HealthOS ontology language alignment (2026-05-07)

- Objective: align documentation/governance with the current HealthOS ontology: Core, GOS, Runtimes, Boundary, Stage, Custom, and separate Construction System.
- Canonical docs in scope:
  - `HealthOS/Shared/docs/adr/0013-healthos-platform-app-layer-construction-system-boundary.md`
  - `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`
- Files updated:
  - `AGENTS.md` and `CLAUDE.md` — classification now uses Core, GOS/Runtimes, Boundary, Stage, and external Construction System; Stage wiring requires stable mediated surfaces and Custom readiness.
  - `README.md`, `HealthOS/Shared/docs/architecture/17-glossary.md`, `19-interface-doctrine.md`, and Stage/Boundary docs — Boundary replaces the former App Integration Boundary concept; Stage replaces the former reference-app/app-implementation language; Custom replaces the former App Charter language as the governed Stage definition.
  - `HealthOS/Shared/docs/adr/README.md`, `EXECUTIVE-SUMMARY.md`, `GAPS-AND-CONFLICTS.md`, `0001-healthos-is-the-whole-system.md`, and `0011-governed-operational-spec-is-subordinate-to-core.md` — ADR-0013 registered and terminology clarified.
  - `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`, `12-next-agent-handoff.md`, `todo/apps-and-interfaces.md`, `todo/runtimes-and-aaci.md`, `19-settler-model-task-tracker.md`, `22-steward-construction-operating-model.md`, maturity/gap/release docs, and relevant skills — open tasks mapped by HealthOS hierarchy plus external Construction System; Stage wiring reclassified.
  - `HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md`, `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts`, `HealthOS/Tier4-Stages-Cast/AppDocs/`, `HealthOS/README.md`, `HealthOS/Tier3-Custom-Boundary/Sources/HealthOSBoundary/README.md`, Swift package comments, and `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` — agent guidance, Steward prompt text, technical compatibility notes, and product spec updated without renaming technical targets/packages at that time.
- Task reclassification:
  - Tier 1 READY: `CI-001`, `RT-ASYNC-001`, `RT-RETRIEVAL-001`.
  - Boundary needs-review: CloudClinic exact facade-envelope decision.
  - Custom needs-review: CloudClinic Custom is incomplete.
  - Stage BLOCKED: `APP-012` until Core/GOS/runtime/Boundary/Custom readiness criteria are met or explicitly accepted with degraded/out-of-scope semantics.
  - Construction System needs-review/blocked as written: `ST-020`, because its current target is APP-012 prompt generation before APP-012 is unblocked; independent construction-system work remains parallelizable.
- Drift registered: Boundary naming drift, closed-set reference-app wording, App Charter/Custom drift, APP-012 ordering drift, and risk of treating Scribe/Veridia Boundary scaffold as permission for further Stage wiring before upstream surfaces stabilize.
- Invariants: documentation/governance only; Core sovereignty preserved; GOS remains subordinate; Stages remain optional/multiplicable consumers; Construction System remains outside the clinical/runtime hierarchy; no production/EHR/provider/signature/interoperability/semantic retrieval claim added.
- Validation: `git diff --check` PASS; `make validate-docs` PASS; touched Mermaid blocks render with `@mermaid-js/mermaid-cli` PASS; `make ts-build` PASS for the Steward prompt string update; `make swift-build` PASS after Swift documentation/comment updates.
- Residual gaps at that time: CloudClinic Custom remained incomplete; CloudClinic Boundary needed a focused follow-up; semantic retrieval and SQL async runtime remained platform work; CI remained local-only until `CI-001`; older technical names were left for a later code rename pass.
- Next recommended work: Tier 1/Core or Tier 2 runtime foundation work, preferably `CI-001` or `RT-ASYNC-001` / `RT-RETRIEVAL-001`, not Stage wiring.

## DOC-APP-011-FORGE-DRIFT — documentation drift correction (2026-05-07)

- Objective: correct factual documentation/tracking drift after audit without changing runtime, schemas, SQL, package manifests, or tests.
- Files updated:
  - `README.md` — Veridia now described as smoke-testable session boundary; CloudClinic remains scaffold placeholder / APP-012.
  - `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` — APP-011 marked DONE; at that time APP-012 was the next Stage wiring task.
  - `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — Veridia moved to COMPLETED with recorded validation evidence; at that time APP-012 was READY.
  - `HealthOS/Constructor/Steward/README.md` — stale 3-command CLI baseline corrected to the implemented deterministic baseline.
  - `HealthOS/Shared/docs/architecture/17-glossary.md`, `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md`, `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`, `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`, `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md` — Forge MCP and app readiness wording aligned with current repo state.
- Invariants: documentation-only; product queue remains separate from construction-system queue; no production readiness, full EHR, real regulatory/provider/signature/interoperability, clinical authority, or runtime MCP claim added.
- Next at that time: ST-020 — use Steward to generate the APP-012 CloudClinic prompt path; DOC-APP-LAYER-BOUNDARY-ORDERING later reclassified APP-012 as BLOCKED.

## ST-023 — session client workflows for construction lifecycle (2026-05-05)

- Objective: add a typed TypeScript session client module to `@healthos/managed-agent` for human-triggered Steward construction lifecycle workflows via Anthropic Managed Agents sessions.
- Branch: `feat/st-023-session-client-workflows`
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/session-client.ts` — implemented seam module with four async workflow functions: `discover`, `brief`, `validate`, `handoff`; reads registered agent ID from `HealthOS/Constructor/Steward/managed-agent/agent.json` at call time; creates a Managed Agents session; streams the response; returns typed result objects with `_disclaimer: "non-canonical construction-system artifact"`
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/workflows.ts` — thin barrel re-export for the workflow functions and result types
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/index.ts` — re-exports workflow public surface
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — ST-023 marked DONE
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` — construction task sequence updated for ST-023
- Validation: `make ts-build` PASS; `cd HealthOS/Constructor/ts && npx tsc --noEmit -p agent-infra/healthos-managed-agent/tsconfig.json` PASS; `dist/session-client.js` and `dist/workflows.js` exist after build; `cd HealthOS/Constructor/ts && node agent-infra/healthos-managed-agent/dist/create-agent.js --dry-run` PASS; `make validate-docs` PASS
- Invariants: construction-system only; no clinical authority; no merge authority; no production-readiness claim; execute stage remains external; no git automation; no Swift, Xcode, product, runtime, contracts, forge-mcp, or steward CLI files touched; no new npm dependencies; credentials are never logged
- Maturity: implemented seam
- Residual gaps: no live Managed Agents API workflow run in validation because that requires registered `agent.json`, beta-enabled Anthropic auth, and a publicly accessible `FORGE_MCP_URL`; no CLI entry point for individual workflows; remote Managed Agent access still depends on public reachability of `healthos-forge-mcp`
- Next at that time: ST-020 — use Steward to generate the APP-012 CloudClinic prompt path; DOC-APP-LAYER-BOUNDARY-ORDERING later reclassified APP-012 as BLOCKED in doc 21.

## ST-022 — Steward Coordinator Managed Agent definition (2026-05-05)

- Objective: create `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/` (`@healthos/managed-agent` 0.1.0) — new TypeScript package defining the HealthOS Steward Coordinator agent for the Anthropic Managed Agents API (`managed-agents-2026-04-01` beta); includes agent config with system prompt encoding the doc-22 construction lifecycle, `create-agent.ts` idempotent upsert script, and `HealthOS/Constructor/Steward/managed-agent/agent.json` state persistence.
- Branch: `feat/st-022-steward-coordinator-agent`
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/agent-def.ts` — `STEWARD_COORDINATOR_DEF` constant: model `claude-opus-4-7`, system prompt (7-stage lifecycle, 10 forge-mcp tools, strict boundary invariants), `mcp_servers` pointing to `FORGE_MCP_URL` (default `http://127.0.0.1:3791/mcp`), `mcp_toolset` tool
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/create-agent.ts` — upsert script: create if no `agent.json`; show saved ID if exists; `--force` updates; `--dry-run` validates config without API call; requires `ANTHROPIC_API_KEY` at runtime only
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/index.ts` — re-exports `STEWARD_COORDINATOR_DEF`, `FORGE_MCP_URL`
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/package.json` — `@anthropic-ai/sdk ^0.40.0` dep; `create-agent`, `create-agent:dry-run`, `create-agent:force` scripts
  - `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/tsconfig.json`
  - `HealthOS/Constructor/Steward/managed-agent/.gitkeep` — directory anchor; `agent.json` written at runtime
- Validation: `make ts-build` PASS; `node dist/create-agent.js --dry-run` PASS (config valid, no API call); `make validate-docs` PASS
- Constraint documented: `FORGE_MCP_URL` must be a publicly-accessible HTTP endpoint for Managed Agents API (which connects remotely); `127.0.0.1` is for local development only; tunnel or deployed endpoint required for cloud use
- Invariants: no clinical tools; no clinical authority; no merge authority; no production claim; `ANTHROPIC_API_KEY` never logged or persisted; agent definition is construction-system tooling only; forge-mcp package unmodified
- Maturity: implemented seam
- Residual gaps: ST-023 (session client workflows for construction lifecycle) remains TODO; actual agent registration requires `ANTHROPIC_API_KEY` + publicly-accessible `FORGE_MCP_URL`
- Next: ST-023 — session client workflows for construction lifecycle coordination

## ST-021 — forge-mcp HTTP/Streamable HTTP transport (2026-05-05)

- Objective: add `src/server-http.ts` to `@healthos/forge-mcp`, exposing the same 10 deterministic tools via `StreamableHTTPServerTransport` (MCP Streamable HTTP spec) on `http://127.0.0.1:${FORGE_MCP_PORT:-3791}/mcp`; required for Managed Agents API compatibility (API expects HTTP MCP servers, not stdio).
- Branch: `feat/st-021-forge-mcp-http-transport`
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/server-http.ts` — HTTP entry point; stateless per-request `McpServer` + `StreamableHTTPServerTransport`; binds only to 127.0.0.1; port from `FORGE_MCP_PORT` env (default 3791); no new npm dependencies (`@hono/node-server` already transitive via MCP SDK 1.29.0)
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json` — added `healthos-forge-mcp-http` bin entry (`dist/server-http.js`) and `start:http` script
- Validation: `make ts-build` PASS; smoke `initialize` → `{"serverInfo":{"name":"healthos-forge-mcp","version":"0.1.0"}}` PASS; smoke `tools/list` → 10 tools PASS
- Invariants: no clinical tools; no LLM calls; no shell execution; no merge authority; no new npm dependencies; stdio transport (server.ts) unmodified; healthos-forge-mcp remains outside clinical/runtime hierarchy; `_non_canonical` in every tool response; bind 127.0.0.1 only
- Maturity: implemented seam (HTTP transport added alongside existing stdio)
- Residual gaps: ST-022 (Steward Coordinator Managed Agent definition) and ST-023 (session client workflows) remain TODO
- Next: ST-022 — define Steward Coordinator Managed Agent using Anthropic Managed Agents API

## DOC-README-VISUAL-PRESENTATION-001 — README visual information and presentation pass (2026-05-05)

- Objective: audit the current README entry surface after DOC-README-001/ST-018 alignment, add only the missing visual/evidence orientation, and create an editable executive visual overview deck without changing runtime behavior.
- Files updated:
  - `README.md` — added a compact "How to Read This Repository" entry surface, clinical/runtime vs construction-layer diagram, evidence/maturity reading lens, and external-deck note.
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this completion record.
  - `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — README/docs visual entrypoint tracking update.
  - `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — handoff note for the external deck and future versioned-asset decision.
- Presentation deliverable: PPTX generated outside the commit at `outputs/019dfa9f-e108-7a93-b35e-837683539cc0/presentations/healthos-visual-overview/output/healthos-visual-overview.pptx` because no clear `HealthOS/Shared/docs/assets/presentations/` versioning pattern exists in the checkout.
- Validation: `git diff --check` PASS; `make validate-docs` PASS; PPTX exists and is non-empty; artifact-tool build produced 9 slides; final previews/contact sheet were rendered and visually inspected; layout QA reported 0 errors and 0 warnings before cleanup; diagnostic greps across the required touched-doc set surfaced historical `healthos-mcp` / `HealthOSFirstSliceSupport` mentions already present in this tracking log, while README and the updated TODO did not reintroduce those names; README still preserves `production-ready` non-claim language.
- Invariants preserved: no Swift/TypeScript/schema/SQL/Makefile/runtime behavior changed; HealthOS remains the system and HealthOScaffold remains the historical repository/foundation phase; Core law remains sovereign; GOS remains subordinate; apps remain mediated surfaces; Steward/Settler/Territory/Settlement/Forge MCP remain construction tooling outside the clinical/runtime hierarchy.
- Residual gaps: the overview deck is not versioned until a repository asset policy/path exists; README remains an entry surface, not the canonical maturity source; final app shells, semantic retrieval, provider deployment, regulatory/signature/interoperability integrations, distributed CI, and production hardening remain separate future work.

## APP-013A — Remove residual legacy patient-app naming drift (2026-05-05)

- Objective: eliminate remaining working-tree uses of the legacy patient-app name so active source, generated artifacts, docs, and construction metadata use `Veridia` consistently.
- Files updated: `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts`, `HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry.md`, execution/HealthOS/Shared/docs/design-system/supporting docs with stale patient-app naming.
- Validation: legacy patient-app naming grep across the working tree returned 0 matches.
- Invariants: naming-only cleanup; no runtime law moved; no product-scope expansion; no production-readiness claim added.
- Residual gaps: none for active naming drift; git history still contains historical legacy-name commits.

## FORGE-MCP-V2 — healthos-forge-mcp Zod rewrite (2026-05-05)

- Objective: upgrade `@healthos/forge-mcp` from low-level `Server+setRequestHandler` to `McpServer` high-level API; add Zod input validation for all 10 tools; extract handler business logic to `src/handlers.ts`; add package README.
- Branch: `feat/forge-mcp-v2-zod-typed`
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/handlers.ts` — all 10 handler functions with try/catch, `HandlerResult` return type, `_non_canonical` in every response
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/tools-id-arg.ts` — id-arg tool registrations (separate module to work around TS2589 depth limit with Zod 4 + MCP SDK 1.29.0 dual compat types)
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/README.md` — build instructions, tool listing, Claude Desktop + generic stdio MCP client configuration
- Files rewritten:
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/server.ts` — now uses `McpServer` from `@modelcontextprotocol/sdk/server/mcp.js`; calls `registerTools(server)`; connects `StdioServerTransport`
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/tools.ts` — registers 7 no-arg tools via `server.registerTool()` with descriptions; imports `registerIdArgTools` from `tools-id-arg.ts`; no more `TOOLS` array or `callTool` dispatcher
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json` — `@modelcontextprotocol/sdk` bumped to `^1.29.0`; `zod ^3.23.0` added (Zod 4.4.3 installs in practice per MCP SDK peer dep resolution)
- Validation: `make ts-build` PASS (zero TypeScript errors); smoke test `tools/list` → 10 tools PASS; `grep 'as string|as any' src/tools.ts src/handlers.ts` → 0 matches PASS
- Invariants: no clinical tools; no shell execution; no LLM calls; no merge authority; healthos-forge-mcp remains outside clinical/runtime hierarchy; `_non_canonical` field in every tool response
- Known limitation: `// @ts-nocheck` in `tools-id-arg.ts` works around TS2589 caused by MCP SDK 1.29.0's `AnySchema = z3.ZodTypeAny | z4.$ZodType` dual-compat union with Zod 4.x; runtime Zod validation is unaffected; `handlers.ts` remains fully type-checked
- Maturity: implemented seam (upgraded to McpServer high-level API + Zod-validated inputs)
- Residual gaps: none after FORGE-MCP-V2-FIX (see below)
- Next: ST-020 — Use Steward to generate APP-012 (CloudClinic) prompt

## FORGE-MCP-V2-FIX — resolve residual gaps (2026-05-05)

- Objective: close all three residual gaps from FORGE-MCP-V2 on the same branch.
- Branch: `feat/forge-mcp-v2-zod-typed` (same PR #104)
- Gap 1 resolved — `// @ts-nocheck` in `tools-id-arg.ts`:
  - Root cause fully documented in the file header: `McpServer.registerTool()` with Zod `inputSchema` causes TS2589 at multiple points within multi-line call expressions (call site, callback signature, return type), making per-line `// @ts-ignore` insufficient. The SDK's dual-compat conditional `SchemaOutput<S> = S extends z3.ZodTypeAny ? ... : S extends z4.$ZodType ? ...` exhausts TypeScript's 100-instantiation depth limit.
  - Workaround: narrowly-scoped `// @ts-nocheck` on `tools-id-arg.ts` only (zero business logic in this file; all logic in fully-typed `handlers.ts`; explicit `({ id }: { id: string })` annotations on all callbacks).
  - Disposition: accepted compiler limitation, not a code bug. Remove `// @ts-nocheck` when MCP SDK > 1.29.0 resolves the z3/z4 compat depth issue.
- Gap 2 resolved — "No resources or prompts capability":
  - Intentional by design — repository-maintenance surface has no use case for resources/prompts. Documented in README as design decision, not a gap.
- Gap 3 resolved — "`dist/` not committed":
  - Added `"prepare": "tsc -p tsconfig.json"` to `package.json` scripts. `cd HealthOS/Constructor/ts && npm install` now auto-builds `dist/` via npm's prepare lifecycle. README updated to reflect this.
- Validation: `make ts-build` PASS; smoke test 10 tools PASS; `make validate-docs` PASS

## DOC-README-001 — Repository README alignment with current implementation state (2026-05-05)

- Objective: update `README.md` to accurately reflect implemented state through ST-018 DONE, PR #99.
- Branch: `HealthOS/Shared/docs/readme-alignment-st018`
- Files updated:
  - `README.md` — all 12 goals completed (see below)
- Goals completed:
  1. All Veridia → Veridia references fixed (posture table + non-claims)
  2. Repository Posture heading updated April → May 2026; Construction System row added
  3. Steward CLI block rewritten: all 10 commands shown; false "only 3 commands" claim removed; fake flags removed
  4. Steward mermaid updated: forge-mcp node "not yet implemented" → "implemented seam ST-018 · 10 tools"; edge labels updated
  5. Repository Atlas mermaid EG node: `Territory` removed (correct path is `HealthOS/Constructor/Settler/territories/`)
  6. Repository Map text: `HealthOS/Constructor/Territory/` entry removed; `HealthOS/Constructor/Settler/` updated with correct subdirs
  7. `healthos-forge-mcp` added to Internal Documentation Index
  8. Reading Paths table: construction system entries added (doc 22, doc 19, Steward CLI, forge-mcp)
  9. "Where Agents Should Start": docs 14 and 15 added (doc 22 + doc 19); subsequent items renumbered
  10. Construction System lifecycle mermaid added in Steward section
  11. Maturity Snapshot updated with construction system entry
  12. HealthOSDesignSystem (DS-001) referenced in Liquid Glass scaffold state
- Validation: `grep -n "Veridia" README.md` → 0; `grep -n "not yet implemented" README.md` → 0; `grep -n "healthos-territory" README.md` → 0; 14 npx CLI command lines (≥ 10); false claim removed
- Invariants: no source code changed (.ts, .swift, .json, .sql, Makefile); construction-system boundary preserved; no clinical authority; official docs remain canonical
- Maturity: instruction surface aligned (documentation-only task)
- Residual gaps:
  - APP-012 CloudClinic smoke-testable path — separate product task
  - CI-001 GitHub Actions validate-all — separate task
- Next: ST-020 — Use Steward to generate APP-012 (CloudClinic) prompt

## APP-011 — Veridia: smoke-testable executable session boundary (2026-05-04)

- Objective: wire `UserSovereigntyContracts.swift` into a minimal `VeridiaSessionFacade` so Veridia has an executable governance session boundary, not just contract-only posture.
- Branch: `feat/app-011-veridia-session-wire`
- Files created:
  - `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/VeridiaSessionContracts.swift` — `VeridiaSessionStartRequest`, `VeridiaSessionResult`, `VeridiaSessionDisposition`, `VeridiaSessionFacade` protocol
  - `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/VeridiaSessionAdapter.swift` — actor implementation; validates via `UserAgentGovernanceValidator` and `VeridiaBoundaryValidator`; records `veridia.session.start` and `veridia.session.end` `ProvenanceRecord` in-memory
  - `HealthOS/Shared/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift` — 8 boundary smoke tests (start/end happy path, deny on missing lawful context, double-end, distinct provenance refs)
- Files updated:
  - `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/VeridiaEntrypoint.swift` — wires `VeridiaSessionAdapter` in async smoke path; exits 0 only when start+end boundary both pass
- Validation: 268 Swift tests pass, `make smoke-veridia` OK (`veridia.session.start + veridia.session.end boundary verified`)

## APP-013 — Rename Veridia to Veridia and redefine patient app scope (2026-05-04)

- Objective: rename the Veridia patient app concept to Veridia and redefine it as the patient health identity app for HealthOS across all active docs, source, schema, and construction metadata.
- Files moved (git mv):
  - `HealthOS/Shared/docs/architecture/12-veridia.md` → `HealthOS/Shared/docs/architecture/12-veridia.md`
  - `HealthOS/Shared/docs/architecture/24-veridia-screen-contracts.md` → `HealthOS/Shared/docs/architecture/24-veridia-screen-contracts.md`
  - `HealthOS/Tier4-Stages-Cast/AppDocs/veridia/` → `HealthOS/Tier4-Stages-Cast/AppDocs/veridia/`
  - `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/` → `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/`
  - `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/VeridiaEntrypoint.swift` → `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/VeridiaEntrypoint.swift`
  - `HealthOS/Shared/docs/execution/skills/user-agent-veridia-skill.md` → `HealthOS/Shared/docs/execution/skills/user-agent-veridia-skill.md`
  - `HealthOS/Tier1-Mestral-Core/Schemas/contracts/user-agent-patient-sovereignty-veridia.schema.json` → `HealthOS/Tier1-Mestral-Core/Schemas/contracts/user-agent-patient-identity-veridia.schema.json`
- Key files updated: `HealthOS/Package.swift`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`, `HealthOS/Shared/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift`, `HealthOS/Shared/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift`, `HealthOS/Constructor/ts/packages/contracts/src/index.ts`, `Makefile`, `README.md`, `AGENTS.md`, `CLAUDE.md`, `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md`, `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`, `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`, `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md`, `HealthOS/Constructor/Settler/territories/apps.json`, `HealthOS/Constructor/Settler/territories/type-script-runtimes.json`, and all settler profile files.
- Smoke target: `make smoke-veridia` replaced by `make smoke-veridia`.
- Validation: all make targets PASS.
- Residual gaps: Veridia final UI not implemented; patient agent runtime wiring completed in APP-011 (see above).

## ST-019 — Xcode/Codex/Claude integration instructions (2026-05-05)

- Objective: align CLAUDE.md and tracking docs with the actual implemented state of ST-018; add all 10 CLI commands to CLAUDE.md bash block; correct forge-mcp tool list from stale planned names to actual steward_* names; revise ST-020 goal from APP-011 (DONE) to APP-012 (CloudClinic).
- Branch: `feat/st-019-integration-instructions`
- Files updated:
  - `CLAUDE.md` — bash code block now includes all 10 implemented `healthos-steward` CLI commands (added `validate-settlement <settlement-id>`, `pr-draft <settlement-id>`, `build-memory`); forge-mcp boundary section corrected from stale planned tool names (`validate-all`, `validate-docs`, etc.) to actual implemented `steward_*` names; both forge-mcp paragraphs merged into a single coherent description
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` — ST-019 marked DONE; ST-020 goal revised to APP-012 (CloudClinic) with note that APP-011 is DONE (PR #98)
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — ST-019 marked DONE with full Outcome block
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` (this file) — ST-019 entry added
- Also removed `HealthOS/Constructor/ts/agent-infra/mcp-local/` — unused stub with clinical tool names (`patient_context`, `service_context`, `session_drafts`); `construction-system.json`, `settler-xcode-tooling.md`, `README.md`, `CLAUDE.md`, doc 22 updated; `HealthOS/Constructor/ts/package-lock.json` updated via `npm install`
- Validation: `make validate-docs` PASS; `make ts-build` PASS
- Invariants: construction-system boundary preserved; no clinical authority; no runtime scope; `healthos-forge-mcp` is the sole repository-maintenance MCP surface
- Maturity: instruction surface aligned and boundary violation resolved (scaffolded contract)
- Residual gaps: none (mcp-local boundary violation resolved in this task)
- Next: ST-020 — Use Steward to generate APP-012 (CloudClinic) prompt

## ST-018 — healthos-forge-mcp stdio MCP server (2026-05-05)

- Objective: create `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` (`@healthos/forge-mcp` 0.1.0) — a stdio JSON-RPC MCP server exposing 10 deterministic repository-maintenance tools wrapping `@healthos/steward` lib functions.
- Branch: `feat/st-018-healthos-forge-mcp`
- Package created: `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` (`@healthos/forge-mcp` 0.1.0)
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json` — npm workspace package; deps: `@modelcontextprotocol/sdk ^1.0.0`, `@healthos/steward 0.2.0`
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/tsconfig.json` — same compiler options as steward (ES2022, NodeNext, strict)
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/server.ts` — stdio MCP entry point; uses `Server` + `StdioServerTransport` from MCP SDK; registers `ListToolsRequestSchema` and `CallToolRequestSchema` handlers
  - `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/tools.ts` — 10 tool definitions (TOOLS array) and `callTool` async dispatcher; all handlers call lib functions directly; repoRoot declared locally (4-level resolution from dist/)
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added 17 lib re-exports for forge-mcp consumption (TrackerTask, readAllTrackerTasks, TerritoryRecord, readTerritory, SettlerRecord, readSettler, SettlementRecord, parseSettlement, repoRoot, assemblePromptSpec, AssemblyInput, 6 memory builder functions, CriterionResult, FileCheckResult, ValidationEvidence, buildValidationReport)
  - `HealthOS/Constructor/ts/package-lock.json` — updated (86 packages added, including `@modelcontextprotocol/sdk` and its dependencies)
- Tools exposed (10): `steward_next_task`, `steward_scan_status`, `steward_get_handoff`, `steward_list_territories`, `steward_inspect_territory`, `steward_list_settlers`, `steward_list_settlements`, `steward_validate_settlement`, `steward_generate_prompt`, `steward_build_memory`
- Smoke:
  - `initialize` → `{"serverInfo":{"name":"healthos-forge-mcp","version":"0.1.0"}}` ✓
  - `tools/list` → 10 tools, all `steward_` prefix ✓
  - `steward_next_task` → ST-018 (first TODO in tracker before this update) ✓
  - `steward_inspect_territory core` → `{id: "core", name: "Core", maturity: "tested operational path", invariants: 4}` ✓
  - `steward_list_territories` → 14 territories ✓
  - Clinical tool name grep → 0 ✓
- Validation: `make ts-build` PASS (all 8 workspace packages), `@healthos/steward` existing 10 commands unchanged
- Invariants: no clinical tools; no LLM calls; no shell execution; no HTTP requests; no merge authority; every tool response includes `_non_canonical` field; no writes outside settlement/prompt/memory dirs; separate from future HealthOS runtime MCP servers
- Maturity: implemented seam (stdio MCP, 10 deterministic tools)
- Known gap (resolved in ST-019 2026-05-05): `mcp-local` (`HealthOS/Constructor/ts/agent-infra/mcp-local/`) had clinical tool names — removed; `healthos-forge-mcp` is the sole repository-maintenance MCP surface
- Residual gaps: ST-019 DONE, ST-020 TODO

## DS-001 — HealthOSDesignSystem: commit and Veridia alignment (2026-05-05)

- Objective: commit the untracked HealthOS/Shared/DesignSystem/ directory as a construction artifact, rename all Veridia references to Veridia following APP-013, update stale architecture doc pointers, and rename ui_kits/veridia/ → ui_kits/veridia/.
- Branch: feat/ds-001-design-system-veridia-align
- Files renamed: assets/glyph-veridia.svg → assets/glyph-veridia.svg, ui_kits/veridia/ → ui_kits/veridia/
- Files updated: README.md (brand table, sources section, index, type/casing/person sections), SKILL.md (product layer table, asset locations, design guidance), ui_kits/veridia/README.md (full content update), ui_kits/veridia/index.html (title, glyph ref, copy, source docs), preview/brand-glyphs.html (glyph ref and label)
- Validation: grep -r "Veridia" HealthOS/Shared/DesignSystem/ → 0 naming-context results (1 historical traceability note in veridia/README.md permitted by task spec); make validate-docs [see result]; make swift-build PASS
- Maturity: Scribe kit = implemented seam; Veridia kit = scaffolded contract (placeholder); CloudClinic kit = scaffolded contract (placeholder)
- Residual gaps: no native SwiftUI design token integration; Veridia and CloudClinic kits remain placeholder; no font files committed (substitution flags in README are accurate)

## ST-017 — Derived Memory Builder (2026-05-04)

- Objective: add `build-memory` command to `@healthos/steward` that reads current repo state from official sources and writes 6 non-canonical derived memory snapshot files to `HealthOS/Constructor/Steward/memory/derived/`.
- Files created (source):
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/tracker-reader.ts` — reads all ST tasks from tracker; exports `TrackerTask` and `readAllTrackerTasks()`
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/memory-builder.ts` — 6 pure builder functions (no FS calls); exports `buildIndex`, `buildConstructionStatus`, `buildTerritoryIndex`, `buildSettlerIndex`, `buildSettlementIndex`, `buildHandoffSnapshot`
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/build-memory.ts` — command handler; orchestrates reads, calls builders, writes to derived/; per-file error tolerance; mkdirSync failure → exit 1
- Files written (derived — produced by smoke run, not hand-authored):
  - `HealthOS/Constructor/Steward/memory/derived/INDEX.md`
  - `HealthOS/Constructor/Steward/memory/derived/construction-status.md`
  - `HealthOS/Constructor/Steward/memory/derived/territory-index.md`
  - `HealthOS/Constructor/Steward/memory/derived/settler-index.md`
  - `HealthOS/Constructor/Steward/memory/derived/settlement-index.md`
  - `HealthOS/Constructor/Steward/memory/derived/handoff-snapshot.md`
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added `"build-memory"` to `StewardCommand` type and switch (now 10 commands)
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` (this file)
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `CLAUDE.md` — updated command count from 9 to 10; added `build-memory` description
- Smoke `build-memory`:
  - Output: `Built 6 derived memory files to HealthOS/Constructor/Steward/memory/derived/`
  - Files listed: `INDEX.md, construction-status.md, territory-index.md, settler-index.md, settlement-index.md, handoff-snapshot.md`
  - Exit: **0**, 0 warnings ✓
- Validation checks:
  - NON-CANONICAL header present in all 6 files: **6** ✓
  - ST-0 entries in construction-status.md: **12** (≥ 11) ✓
  - Pipe lines in territory-index.md: **15** (≥ 15) ✓
  - Undefined/[object Object] artifacts: **0** ✓
  - Idempotency: second run → same output, exit 0 ✓
  - project-state.json exists (not deleted): ✓
  - construction-status.md: 7 DONE, 10 TODO of 17 total ST tasks
- Validation: `make ts-build` PASS, `make validate-docs` PASS, `make validate-all` PASS (all 11 gates)
- Invariants preserved: no shell execution; no LLM calls; no HTTP requests; no new npm dependencies (Node built-ins only); no writes outside `HealthOS/Constructor/Steward/memory/derived/`; per-file error tolerance (warnings do not abort run); no clinical authority; no merge authority; all 6 files carry NON-CANONICAL header; derived memory never replaces official docs
- Maturity: implemented seam
- Residual gaps: ST-018 (healthos-forge-mcp surface), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (Use Steward to generate APP-011 prompt) remain TODO

## ST-016 — Settlement Validation and PR Review Draft Engine (2026-05-04)

- Objective: add `validate-settlement <id>` and `pr-draft <id>` commands to `@healthos/steward` that deterministically check Settlement done-criteria against filesystem evidence and generate PR body Markdown from Settlement fields.
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/validation-report-builder.ts` — pure function; exports `buildValidationReport(settlement, evidence): string`; no FS calls
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/pr-draft-builder.ts` — pure function; exports `buildPrDraft(settlement): string`; no FS calls
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/validate-settlement.ts` — command handler; path extraction heuristic (PASS/FAIL/UNVERIFIED); exits 1 on any FAIL
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/pr-draft.ts` — command handler; writes PR body Markdown; exits 0 on success
  - `HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry-validation.md` — smoke-generated ValidationReport (non-canonical derived artifact)
  - `HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry-pr-draft.md` — smoke-generated ReviewDraft (non-canonical derived artifact)
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added `"validate-settlement"` and `"pr-draft"` to `StewardCommand` type and switch
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` (this file)
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `CLAUDE.md` — added `validate-settlement`, `pr-draft` to implemented commands list (now 9 total)
- Smoke `validate-settlement st-012-settler-profile-registry`:
  - Output: `Validation report: HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry-validation.md`
  - Results: **5 PASS, 0 FAIL, 2 UNVERIFIED** — exit 0
  - ValidationReport section count (grep for 4 section headers): **4** ✓
  - Undefined/[object Object] artifacts: **0** ✓
- Smoke `pr-draft st-012-settler-profile-registry`:
  - Output: `PR draft: HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry-pr-draft.md`
  - Exit: **0** ✓
  - PR draft section count (grep for 4 section headers): **4** ✓
  - Undefined/[object Object] artifacts: **0** ✓
- Validation: `make ts-build` PASS, `make validate-docs` PASS, `make validate-all` PASS (all 11 gates)
- Invariants preserved: no shell execution; no LLM calls; no HTTP requests; no new npm dependencies (Node built-ins only); fail-closed on missing/malformed Settlement (exit 1); exits 1 on any FAIL criterion (CI-compatible); no clinical authority; no merge authority; no MCP server; writes only to `HealthOS/Constructor/Steward/prompts/generated/`
- Maturity: implemented seam
- Residual gaps: ST-017 (Derived Memory Builder), ST-018 (healthos-forge-mcp surface), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (Use Steward to generate APP-011 prompt) remain TODO

## ST-015 — Prompt Generation Engine (2026-05-04)

- Objective: add `generate-prompt <settlement-id>` command to `@healthos/steward` that deterministically assembles a bounded 16-section PromptSpec Markdown file from a Settlement record, referenced Territory JSON records, and Settler profile records.
- Files created:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/settlement-parser.ts` — line-based Settlement Markdown parser; exports `parseSettlement(markdown)` → `SettlementRecord`
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/territory-reader.ts` — reads Territory JSON by ID; exports `readTerritory(id)` → `TerritoryRecord`
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/settler-reader.ts` — reads Settler profile Markdown by ID; exports `readSettler(id)` → `SettlerRecord`
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts` — assembles 16-section PromptSpec from `AssemblyInput`; `canonical_nomenclature` section is a hard-coded constant
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/generate-prompt.ts` — command handler; fail-closed on missing/malformed records; writes to `HealthOS/Constructor/Steward/prompts/generated/`
  - `HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry.md` — smoke-generated PromptSpec (non-canonical derived artifact)
- Files updated:
  - `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added `"generate-prompt"` to `StewardCommand` type and switch
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` (this file)
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `CLAUDE.md` — added `generate-prompt` to implemented commands list
- Smoke test: `generate-prompt st-012-settler-profile-registry` → `Generated: HealthOS/Constructor/Steward/prompts/generated/st-012-settler-profile-registry.md`
  - First 5 lines of generated output:
    ```
    <!-- Generated by healthos-steward generate-prompt -->
    <!-- Settlement: SETTLEMENT-20260504-settler-profile-registry -->
    <!-- Generated: 2026-05-04 -->
    <!-- Non-canonical: this PromptSpec is a derived artifact, not an official doc -->
    ```
  - Section count (grep for 16 opening tags): **16** ✓
  - Undefined/[object Object] artifacts: **0** ✓
- Validation: `make ts-build` PASS, `make validate-docs` PASS, `make validate-all` PASS
- Invariants preserved: no LLM calls; no new npm dependencies (Node built-ins only); fail-closed on missing Settlement/Territory/Settler; writes only to `HealthOS/Constructor/Steward/prompts/generated/`; no clinical authority; no merge authority; no MCP server implemented
- Maturity: implemented seam
- Residual gaps: ST-016 (Settlement Validation + PR Review Draft Engine), ST-017 (Derived Memory Builder), ST-018 (healthos-forge-mcp), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (Use Steward to generate APP-011 prompt) remain TODO

## ST-014 — Deterministic Steward CLI inspect/next/list (2026-05-04)

- Outcome recorded in 19-settler-model-task-tracker.md.

## ST-013 — Settlement Record Schema and Templates (2026-05-04)

- Objective: mature the Settlement record infrastructure by creating SCHEMA.md (authoritative Markdown spec of all Settlement fields), a blank Markdown template, and one completed example Settlement record (ST-012 factual basis). Review and patch the existing JSON Schema scaffold.
- Files created:
  - `HealthOS/Constructor/Settler/settlements/SCHEMA.md` — authoritative human-readable Markdown spec of all 13 Settlement record fields
  - `HealthOS/Constructor/Steward/settlements/templates/settlement-template.md` — blank template with placeholder values for creating new Settlements
  - `HealthOS/Constructor/Steward/settlements/completed/st-012-settler-profile-registry.md` — completed example Settlement record (ST-012 factual basis)
- Files updated:
  - `HealthOS/Constructor/Steward/settlements/templates/settlement.schema.json` — reviewed and patched: added `objective` (string), `restrictions` (array), and `handoff` (string) fields which were absent from the initial ST-010 scaffold; added `$comment` noting ST-013 review
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md` (this file)
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- Result: Settlement schema, blank template, and example Settlement completed. JSON Schema remains valid (`python3 -m json.tool` PASS). No Swift, TypeScript, schema, or SQL source was modified.
- Invariants preserved: construction-system boundary (no clinical authority, no merge authority, no runtime behavior changed), official docs canonical, healthos-forge-mcp naming correct, HealthOSSessionRuntime naming correct, no production-readiness claim.
- Maturity: scaffolded contract (Settlement schema and template); doctrine-only (example Settlement record, no CLI/MCP/runner implemented).
- Residual gaps: ST-014 (Deterministic Steward CLI), ST-015 (Prompt Generation Engine), ST-016 (Settlement Validation/PR Review Draft Engine), ST-017 (Derived Memory Builder), ST-018 (healthos-forge-mcp), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (Use Steward to generate APP-011 prompt) remain TODO.

## ST-012 — Create Settler Profile Registry (2026-05-04)

- Objective: create 9 Settler profile records and a registry index under `HealthOS/Constructor/Settler/settlers/` without implementing Settlers as executable agents, Settlement instances, Steward CLI, Forge MCP, or runtime behavior.
- Files created:
  - `HealthOS/Constructor/Settler/settlers/README.md`
  - `HealthOS/Constructor/Settler/settlers/settler-core-law.md`
  - `HealthOS/Constructor/Settler/settlers/settler-storage.md`
  - `HealthOS/Constructor/Settler/settlers/settler-gos.md`
  - `HealthOS/Constructor/Settler/settlers/settler-aaci.md`
  - `HealthOS/Constructor/Settler/settlers/settler-ops.md`
  - `HealthOS/Constructor/Settler/settlers/settler-apps.md`
  - `HealthOS/Constructor/Settler/settlers/settler-xcode-tooling.md`
  - `HealthOS/Constructor/Settler/settlers/settler-documentation.md`
  - `HealthOS/Constructor/Settler/settlers/settler-validation.md`
- Files updated:
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- Result: Settler Profile Registry created. Each profile defines territory assignment, canonical docs, files in scope, invariants (≥ 6 per profile), forbidden moves (≥ 6 per profile), validation expectations, maturity (doctrine-only), handoff requirements, and non-claims block. README contains registry table with all 9 profiles.
- Invariants preserved: construction-system boundary (no clinical authority, no merge authority, no runtime behavior changed), official docs canonical, healthos-forge-mcp naming correct, HealthOSSessionRuntime naming correct, no production-readiness claim.
- Maturity: doctrine-only (Settler profiles); scaffolded contract (construction system overall).
- Residual gaps: ST-013 (Settlement Record Schema), ST-014 (Deterministic Steward CLI), ST-015 (Prompt Generation Engine), ST-016 (Settlement Validation/PR Review Draft Engine), ST-017 (Derived Memory Builder), ST-018 (healthos-forge-mcp), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (Use Steward to generate APP-011 prompt) remain TODO.

## ST-011B — Create HealthOS Technical Product Specification baseline (2026-05-01)

- Objective: create the first consolidated technical product specification baseline for HealthOS without changing runtime behavior.
- Files created:
  - `HealthOS/Shared/docs/product/README.md`
  - `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md`
- Files updated:
  - `README.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- Result: baseline technical product specification now consolidates current technical product definition and explicit maturity/non-claims while preserving architecture/execution canon.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (scaffold/foundation maturity is not production readiness), construction boundary invariants (Steward/Settlers/Forge MCP remain outside clinical/runtime hierarchy).
- Residual gaps: detailed follow-on technical specs remain future work (GOS primitives, Session Runtime, STT/normalization, MSR artifacts, Service Runtime, provider policy, app interfaces, construction-system detail). ST-012 remains next construction-system task.

## Daily TODO/status audit (2026-05-01 local / 2026-05-02 UTC)

- Objective: audit READY / in-progress task trackers against recent git history and current code evidence without implementing new runtime or app behavior.
- Evidence checked: `git log --oneline -30`, historical commits for APP-008 / OPS-003 / CL-006 / DS-007 / RT-008 / AACI-009, current adapter/test files, and all files under `HealthOS/Shared/docs/execution/todo/`.
- Result: TODO trackers were corrected so completed items no longer remain under READY:
  - APP-008 cross-app envelope propagation is completed at scaffold-contract maturity.
  - APP-011 is DONE.
  - APP-012 was READY for separate CloudClinic smoke-testable session wiring at the time of this audit; DOC-CONSTITUTIONAL-STAGE-CUSTOM later reclassified it as BLOCKED pending Core/GOS/runtime/Boundary/Custom readiness.
  - CL-006 shared service-boundary outcome envelope is completed; no Core-law TODO is currently promoted by the TODO tracker.
  - DS-007 lawfulContext/layer-guard parity is completed; SQL/object backend hardening remains a post-scaffold gap.
  - OPS-003 incident-response command vocabulary is completed as documentation/contract vocabulary, not an implemented operator console.
  - RT-008 runtime-boundary adapter tests and AACI-009 capability-honesty signaling are completed; RT-ASYNC-001 and RT-RETRIEVAL-001 were still blocked in doc 21 at the time of this audit, then reclassified as READY Tier 1 platform/runtime foundation tasks by DOC-APP-LAYER-BOUNDARY-ORDERING.
- Current promoted pending product/repo tasks after DOC-APP-LAYER-BOUNDARY-ORDERING: CI-001, RT-ASYNC-001, and RT-RETRIEVAL-001 are READY; APP-012 is BLOCKED; APP-011 is DONE.
- Current promoted construction-system task: ST-012 Settler Profile Registry remains TODO after ST-011/ST-011A; it is tracked in `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` and `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`.
- Non-claims preserved: no production readiness, no final UI, no real semantic retrieval, no regulatory/provider effectuation, and no movement of consent/habilitation/gate/finality law out of Core.

## ST-011 — Create Territory Registry (2026-05-01)

- Objective: create the first structured Territory Registry for the Steward / Settler / Settlement construction system without implementing Settlers, Settlement instances, prompt generation, Steward CLI, Forge MCP, or runtime behavior.
- Files created:
  - `HealthOS/Constructor/Settler/territories/territory.schema.json`
  - `HealthOS/Constructor/Settler/territories/core.json`
  - `HealthOS/Constructor/Settler/territories/gos.json`
  - `HealthOS/Constructor/Settler/territories/session-runtime.json`
  - `HealthOS/Constructor/Settler/territories/msr.json`
  - `HealthOS/Constructor/Settler/territories/aaci.json`
  - `HealthOS/Constructor/Settler/territories/providers.json`
  - `HealthOS/Constructor/Settler/territories/apps.json`
  - `HealthOS/Constructor/Settler/territories/type-script-runtimes.json`
  - `HealthOS/Constructor/Settler/territories/storage-and-data.json`
  - `HealthOS/Constructor/Settler/territories/regulatory-and-interoperability.json`
  - `HealthOS/Constructor/Settler/territories/operations-and-observability.json`
  - `HealthOS/Constructor/Settler/territories/construction-system.json`
  - `HealthOS/Constructor/Settler/territories/validation-and-ci.json`
  - `HealthOS/Constructor/Settler/territories/documentation.json`
- Files updated:
  - `HealthOS/Constructor/Settler/territories/README.md`
  - `HealthOS/Constructor/Settler/README.md`
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- Result: ST-011 complete after validation; Territory records are construction metadata only and remain subordinate to official docs.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (scaffold/foundation maturity is not production readiness), engineering-agent boundary invariants (Territories organize repository work and do not become HealthOS runtime or clinical authority).
- Residual gaps: Settler Profile Registry, Settlement instances, Steward CLI consumption, prompt generation, PR review/validation engine, derived memory builder, and HealthOS Forge MCP remain future work. ST-012 is next.

## RT-PROVIDER-001 — Real Apple Foundation Models integration for normalization (2026-04-30)

- Objective: replace the always-stubbed Apple language-model provider with a real local Foundation Models adapter for transcript normalization only.
- Files updated:
  - `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift`
  - `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/StubProviders.swift`
  - `HealthOS/Shared/Tests/HealthOSTests/MSRRuntimeTests.swift`
  - `HealthOS/Shared/Tests/HealthOSTests/ProviderGovernanceTests.swift`
  - `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
  - `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- API confirmed: current Foundation Models SDK exposes `SystemLanguageModel.default.availability`, `SystemLanguageModel.supportsLocale(_:)`, `LanguageModelSession(model:tools:instructions:)`, `LanguageModelSession.respond(to:options:)`, `LanguageModelSession.Response<String>.content`, and unavailable reasons for device eligibility, Apple Intelligence enablement, and model readiness.
- Result: transcript normalization now calls Apple Foundation Models locally when the framework is compiled in, the current locale is supported, and `SystemLanguageModel.default` is available. Remote fallback remains denied for v1. Unavailable framework/model/locale and forced-stub paths remain explicit degraded/stub-only states and do not persist stub output as normalized transcript.
- Validation run: `cd HealthOS && swift build`; `cd HealthOS && swift test` (260 tests, 0 failures; the Foundation Models availability test executed the real provider on this machine).
- Invariants: normalization remains a `HealthOSSessionRuntime` concern; ASL, VDLP, and GEM were not widened in this work unit; derived artifacts remain non-authorizing and clinician-review-bound.
- Residual gaps: production provider hardening and broader local-model policy remain future work; Foundation Models output quality remains a local-provider capability, not a production clinical claim.

## STR-006 — Formalize MSR naming and move transcript normalization to Session Runtime (2026-04-30)

- Objective: make `MSR` the official runtime sigla, rename the Swift module/runtime infrastructure from `MentalSpace*` to `MSR*`, and move transcript normalization ownership out of MSR and into `HealthOSSessionRuntime`.
- Files updated:
  - `HealthOS/Package.swift`
  - `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/MSRRuntime.swift`
  - `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/TranscriptNormalization.swift`
  - `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/*`
  - `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/*`
  - `HealthOS/Constructor/ts/packages/contracts/src/index.ts`
  - `HealthOS/Tier1-Mestral-Core/Schemas/contracts/mental-space-artifact.schema.json`
  - `HealthOS/Tier1-Mestral-Core/Schemas/contracts/async-job.schema.json`
  - `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md`
  - `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
  - `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
  - `HealthOS/Shared/docs/execution/10-invariant-matrix.md`
  - `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- Result: package/module naming and ownership boundaries now match the intended architecture; transcript normalization is a session-runtime concern and MSR is limited to `ASL -> VDLP -> GEM`.
- Residual gaps: full end-to-end Swift validation was not completed in this work unit because interactive builds were interrupted; any remaining compile drift must be resolved in the next validation pass.

## ST-010 — Create Steward Construction Operating Model baseline (2026-04-30)

- Objective: create the canonical construction operating model baseline for Steward, Settler, Settlement, and Territory work without implementing product behavior, MCP, model calls, or multiagent orchestration.
- Files created:
  - `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
  - `HealthOS/Constructor/Settler/territories/README.md`
  - `HealthOS/Constructor/Settler/settlers/README.md`
  - `HealthOS/Constructor/Steward/settlements/README.md`
  - `HealthOS/Constructor/Steward/settlements/templates/settlement.schema.json`
  - `HealthOS/Constructor/Steward/prompts/generated/README.md`
  - `HealthOS/Constructor/Steward/prompts/templates/README.md`
- Files updated:
  - `HealthOS/Constructor/Settler/README.md`
  - `AGENTS.md`
  - `CLAUDE.md`
  - `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
  - `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
  - `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
  - `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- Validation run: `git status --short`, required file assertions, `python3 -m json.tool HealthOS/Constructor/Steward/settlements/templates/settlement.schema.json`, `make validate-docs`, `make validate-schemas`, `make validate-contracts`, `make ts-build`, `make swift-build`, `make swift-test`, `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, `make smoke-cloudclinic`, `make validate-all`.
- Result: ST-010 complete after validation; construction operating model and skeleton exist as scaffolded contract only.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (scaffold/foundation maturity is not production readiness), engineering-agent boundary invariants (Steward and Settlers remain outside HealthOS clinical/runtime hierarchy).
- Residual gaps: Territory Registry not implemented; Settler Profile Registry not implemented; Settlement CLI not implemented; prompt generation not implemented; `healthos-mcp` not implemented.


## STR-005 — Add Veridia and CloudClinic scaffold executable targets (2026-04-30)

- Objective: make the Swift HealthOS product graph honest by adding minimal placeholder executable targets for Veridia and CloudClinic alongside Scribe.
- Files created:
  - `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/VeridiaEntrypoint.swift`
  - `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic/CloudClinicEntrypoint.swift`
- Package wiring added: `Veridia` and `CloudClinic` executable products/targets in `HealthOS/Package.swift`, each depending only on `HealthOSCore`.
- Smoke targets added: `make smoke-veridia` and `make smoke-cloudclinic`; `swift-smoke` now includes CLI and initial reference-app smoke paths.
- Validation run: `git status --short`, entrypoint file assertions, `cd HealthOS/Tier4-Stages-Cast/Veridia && swift package dump-package`, `cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift package dump-package`, `cd HealthOS && swift build`, `cd HealthOS/Tier4-Stages-Cast/Veridia && swift run Veridia --smoke-test`, `cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift run CloudClinic --smoke-test`, `cd HealthOS && swift test`, `make swift-build`, `make swift-test`, `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, `make smoke-cloudclinic`, `make validate-docs`, `make validate-schemas`, `make validate-contracts`, `make ts-build`, `make validate-all`.
- Result: STR-005 complete after validation; APP-011 and APP-012 are unblocked and ready, but not implemented.
- Invariants: Inv 1 (Core sovereignty), Boundary invariants (Veridia/CloudClinic remain mediated app surfaces), Inv 43 (scaffold/foundation maturity is not production readiness).
- Residual gaps: Veridia session wiring remains APP-011; CloudClinic session wiring remains APP-012; no final UI shell is implemented; no clinical authority or production behavior was added.


## STR-004 — Rename HealthOSFirstSliceSupport to HealthOSSessionRuntime (2026-04-30)

- Objective: remove development-phase vocabulary from the Swift product graph by renaming `HealthOSFirstSliceSupport` to `HealthOSSessionRuntime` without changing runtime behavior.
- Files moved with history via `git mv`:
  - `swift/Sources/HealthOSFirstSliceSupport/` → `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/`
  - `FirstSliceRunner.swift` → `SessionRunner.swift`
  - `ScribeFirstSliceAdapter.swift` → `ScribeSessionAdapter.swift`
  - `ScribeFirstSliceDemoBootstrap.swift` → `ScribeSessionDemoBootstrap.swift`
- Module/API wiring updated: `HealthOS/Package.swift`, CLI/Scribe/test imports and references now consume `HealthOSSessionRuntime`; primary public runtime types renamed to session-runtime vocabulary.
- Validation run: `test ! -d swift/Sources/HealthOSFirstSliceSupport`, `test -d HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime`, grep checks for stale imports/module names, `cd HealthOS && swift package dump-package | grep -A8 HealthOSSessionRuntime`, `cd HealthOS && swift build`, `cd HealthOS && swift test`, `make swift-build`, `make swift-test`, `make smoke-cli`, `make smoke-scribe`, `make validate-docs`, `make validate-schemas`, `make validate-contracts`, `make validate-all`.
- Result: STR-004 complete; no Core/GOS/AACI/Mental Space/app clinical behavior changes.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (scaffold/foundation maturity is not production readiness), app/session boundary invariants preserved.
- Residual gaps: no Veridia/CloudClinic targets were added (reserved for STR-005); internal `FirstSlice*` contracts in `HealthOSCore` remain intentionally unchanged for scope control.


## STR-003 — Separate AGENT packages from PRODUCT in HealthOS/Constructor/ts/ (2026-04-29)

- Objective: move repository engineering-agent packages out of `HealthOS/Constructor/ts/packages/` into `HealthOS/Constructor/ts/agent-infra/` so product/build vs agent infrastructure boundaries are explicit and enforceable.
- Files moved with history via `git mv`:
  - `HealthOS/Constructor/ts/packages/healthos-steward` → `HealthOS/Constructor/ts/agent-infra/healthos-steward`
  - `HealthOS/Constructor/ts/packages/mcp-local` → `HealthOS/Constructor/ts/agent-infra/mcp-local`
- Workspace contract updated: `HealthOS/Constructor/ts/package.json` and lockfile now include both `packages/*` and `agent-infra/*`.
- Validation run: directory assertions, `git log --follow` checks, `cd HealthOS/Constructor/ts && npm install`, `cd HealthOS/Constructor/ts && npm ls --workspaces --depth=0`, `cd HealthOS/Constructor/ts && npm run build --workspaces`, `make ts-build`, `make validate-docs`, `make validate-schemas`, `make validate-contracts`, `make swift-build`, `make swift-test`, `make smoke-cli`, `make smoke-scribe`, `make validate-all` (all PASS).
- Result: STR-003 complete; `HealthOS/Constructor/ts/packages/` now product/build only and `HealthOS/Constructor/ts/agent-infra/` now steward + mcp-local infrastructure.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (scaffold maturity is not production readiness), engineering-agent boundary invariants preserved.
- Residual gaps: Steward/Settler/Territory operationalization remains future work; `healthos-mcp` remains repository-maintenance MCP (not runtime MCP); no clinical/runtime behavior changed.

## STR-002 — Archive Skill macOS legacy scripts (2026-04-29)

Objective: archive legacy TypeScript Mental Space scripts from repository root into `HealthOS/Shared/docs/reference/mental-space-legacy/` to remove active-runtime ambiguity while preserving history and governance posture.

Files touched:
- `HealthOS/Shared/docs/reference/mental-space-legacy/` (moved from `Skill macOS/` via `git mv`)
- `HealthOS/Shared/docs/reference/mental-space-legacy/README.md`
- `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md`
- `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`

Invariants involved:
- Inv 1 — Core sovereignty
- Inv 17/22 — provider honesty / anti-fake posture
- Inv 25a — Mental Space artifacts remain derived/gated
- Inv 43 — scaffold/foundation maturity is not production readiness

Validation:
- `git status --short` PASS
- `test ! -d "Skill macOS"` PASS
- `test -d "HealthOS/Shared/docs/reference/mental-space-legacy"` PASS
- `find "HealthOS/Shared/docs/reference/mental-space-legacy" -maxdepth 2 -type f | sort` PASS
- `git log --oneline --follow -- "HealthOS/Shared/docs/reference/mental-space-legacy/4-asl.ts" | head` PASS
- `git log --oneline --follow -- "HealthOS/Shared/docs/reference/mental-space-legacy/5-vdlp.ts" | head` PASS
- `git log --oneline --follow -- "HealthOS/Shared/docs/reference/mental-space-legacy/6-gem.ts" | head` PASS
- `grep -RIn "Skill macOS" README.md docs swift ts schemas Steward Settler Territory 2>/dev/null || true` PASS (expected residual historical planning references)
- `make validate-docs` PASS
- `make validate-schemas` PASS
- `make validate-contracts` PASS
- `cd HealthOS && swift build` PASS
- `cd HealthOS && swift test` PASS
- `make validate-all` FAIL due to known unrelated TypeScript workspace issue (`HealthOS/Constructor/ts/agent-infra/healthos-steward/tsconfig.json` no `src/**/*.ts` inputs; TS18003)

Result:
- STR-002 complete: legacy scripts are archived reference material under `HealthOS/Shared/docs/reference/mental-space-legacy/`; root ambiguity removed.

Residual gaps:
- legacy scripts are reference only; no Swift runtime behavior changed
- production provider/runtime hardening remains separate work
- Steward/Settler/Territory operationalization remains separate work

## STR-001 — Wire HealthOSProviders into HealthOSMSR (2026-04-29)

Objective: wire `HealthOSProviders` into `HealthOSMSR` so future provider-backed Mental Space executors can route through the governed provider layer without moving constitutional authority out of Core.

Files touched:
- `HealthOS/Package.swift`
- `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`

Invariants involved:
- Inv 1 — Core sovereignty
- Inv 17 — provider honesty
- Inv 43 — scaffold/foundation maturity is not production readiness

Validation:
- `cd HealthOS && swift build` PASS
- `cd HealthOS && swift test` PASS
- `cd HealthOS && swift package dump-package | grep -A8 HealthOSMSR` PASS (shows `HealthOSProviders`)
- `make validate-docs` PASS
- `make validate-all` PASS

Result:
- STR-001 complete: `HealthOSMSR` now depends on both `HealthOSCore` and `HealthOSProviders`.

Residual gaps:
- ASL executor still not implemented
- VDLP executor still not implemented
- GEM builder still not implemented
- no provider call introduced

## RT-010 — Mental Space Runtime contracts and first normalization slice (2026-04-29)

Objective: establish Mental Space Runtime as a staged HealthOS runtime domain for derived linguistic/cognitive artifacts, then implement the first executable normalization stage after transcription without weakening Core law, provider honesty, or app boundaries.

Files touched:
- `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md` — new canonical architecture contract for Mental Space Runtime, stage order, artifact posture, provider posture, and app-safe surface
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/MentalSpaceRuntime.swift` — new Swift contracts for stages, metadata, normalized/ASL/VDLP/GEM artifacts, stage state, pipeline dependency validation, normalization request/result, runtime view, and content hashing
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/AsyncRuntimeJobs.swift`, `HealthOS/Constructor/ts/packages/contracts/src/index.ts`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/async-job.schema.json` — async job taxonomy extended with Mental Space stage jobs
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift` — local-first transcript normalization provider boundary added; remote fallback denied and stub output degraded for v1
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift` — normalization now runs after non-empty transcript persistence and stores a normalized transcript as a derived artifact only when a real local model is available
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/FirstSliceContracts.swift`, `ScribeFirstSliceBridge.swift`, `ScribeSessionAdapter.swift`, and `Scribe/Views/ScribeFirstSliceView.swift` — first-slice/Scribe surfaces now carry minimal Mental Space runtime state
- `HealthOS/Shared/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift` — tests for stage ordering, async substrate job kind, provider degradation, derived artifact persistence, and app-safe Scribe surface
- `HealthOS/Tier1-Mestral-Core/Schemas/contracts/mental-space-artifact.schema.json`, `HealthOS/Shared/docs/execution/skills/mental-space-runtime-skill.md`, tracking docs

Invariants involved:
- Inv 1 (HealthOS Core is sovereign)
- Inv 17/18 (provider/ML honesty and fail-closed remote/stub posture)
- Inv 24/25 (async jobs remain governed/idempotent substrate)
- Inv 25a (Mental Space artifacts are derived/gated insight surfaces only)
- Inv 38 (Scribe consumes mediated state only)
- Inv 43 (scaffold closure never equals product readiness)

Validation:
- `cd HealthOS && swift test --filter MentalSpaceRuntimeTests` PASS — 5 tests
- `cd HealthOS && swift test --filter AsyncRuntimeGovernanceTests` PASS — 23 tests
- `cd HealthOS && swift build` PASS
- `cd HealthOS && swift test` PASS — 246 tests, 0 failures
- `cd HealthOS/Constructor/ts && npm run build` PASS
- `make validate-schemas` PASS
- `make validate-docs` PASS
- `make validate-contracts` PASS
- `git diff --check` PASS
- `make validate-all` PASS, including Swift/TS/Python checks plus CLI and Scribe smokes

Done criteria:
- Mental Space Runtime is named and documented separately from async runtime
- normalization is the only executable stage in this slice
- ASL/VDLP/GEM are represented as contracts/job kinds but not falsely claimed as executable
- normalized transcript artifacts are persisted under `derived-artifacts` with source transcript lineage and limitations
- Scribe sees only status/summary/provider/artifact availability, not raw artifact JSON or diagnostic authority

Residual gaps:
- ASL, VDLP, and GEM adapters are not implemented yet
- no real Apple Foundation/local model integration is shipped; existing Apple provider remains stub-marked
- no production provider, semantic retrieval, diagnosis, or regulatory effectuation claim is made

## APP-010 — Native macOS 26+ UI scaffold and design-system scope (2026-04-29)

Objective: align the repository with macOS 26+ native UI work, Liquid Glass guidance, and app-boundary-safe scope for Scribe, Veridia, CloudClinic, and a future HealthOS control panel.

Files touched:
- `HealthOS/Package.swift` — raised manifest to PackageDescription 6.2 and `.macOS(.v26)`
- `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` — new canonical scope doc for macOS 26+ app shells, Liquid Glass, design-system boundaries, and control-panel scope
- `HealthOS/Shared/docs/architecture/11-scribe.md`, `12-veridia.md`, `13-cloudclinic.md`, `19-interface-doctrine.md` — linked app docs to the new native UI scope while preserving scaffold non-claims
- `HealthOS/Shared/docs/execution/skills/native-macos-ui/SKILL.md` — new local skill for native macOS UI scaffold work
- `HealthOS/Shared/docs/execution/skills/README.md` — skill index updated
- `README.md` — app-boundary reading path updated
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — APP-010 completion and APP-011 future implementation task added
- `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`, `HealthOS/Shared/docs/execution/11-current-maturity-map.md`, `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — tracking aligned with macOS 26+ baseline

Invariants involved:
- Inv 1 (HealthOS Core is sovereign)
- Inv 38 (Scribe consumes mediated state only)
- Inv 39/40/41 (cross-app app-safe envelope, safe refs, notification boundary)
- Inv 43 (scaffold closure never equals product readiness)

Validation:
- `cd HealthOS && swift package dump-package` PASS; manifest resolves as tools version 6.2.0 and platform macOS 26.0
- `cd HealthOS && swift build` PASS
- `cd HealthOS && swift test` PASS — 241 tests, 0 failures
- `cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test` PASS
- `make validate-docs` PASS
- `make validate-all` PASS

Done criteria:
- native app work now treats macOS 26+ as the target baseline
- Liquid Glass is documented as the macOS 26+ design baseline without decorative overuse
- Scribe remains the only implemented native validation surface
- Veridia, CloudClinic, and HealthOS control panel shells are scope-defined but not falsely claimed as implemented

Residual gaps:
- no final Scribe/Veridia/CloudClinic UI shell delivered
- no HealthOS control panel executable target exists yet
- existing Scribe validation UI has not been refactored into a macOS 26 app shell

## WS-1b — Codex external executor for Steward-scoped Xcode-facing maintenance (2026-04-29)

Objective: register Codex as an external executor for Steward-scoped Xcode-facing repository maintenance without creating a new Steward authority category.

Files touched:
- `README.md` — Steward and automation sections now describe the Codex companion local automation
- `AGENTS.md` — Steward section now defines the bounded Codex external executor role and local automation path
- `CLAUDE.md` — same Steward role definition plus repository-maintenance automation note
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` — Steward for Xcode doctrine now includes the bounded Codex executor role
- `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md` — Xcode Settler scope now includes Xcode-facing automation-maintenance surfaces
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` — WS-1/Phase B updated for Codex automation-maintenance posture
- `HealthOS/Shared/docs/execution/skills/project-steward-skill.md` — Steward skill now includes Codex external executor scope and `.claude` automation surfaces
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — handoff note updated
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — WS-1 follow-up note added

Invariants involved:
- engineering-agent boundary doctrine: Codex remains an external executor, not an internal Steward provider
- Steward for Xcode remains outside HealthOS clinical/runtime hierarchy
- `healthos-mcp` remains doctrine-only and non-clinical
- no merge authority or Core-law authority is granted

Validation:
- `git diff --check` PASS
- `make validate-docs` PASS
- scheduled-task registry parse PASS at the time; current repository posture retires that registry and uses Codex grouped automation instead

Done criteria:
- Codex executor role is documented as Steward-scoped Xcode-facing repository maintenance
- local Codex automation is registered at `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`
- repository-maintenance automation ownership is explicit and PR-only for document changes; as of 2026-05-07, Codex owns grouped maintenance jobs and no Claude Code scheduled-task registry remains in the repo
- no production, clinical/runtime, Xcode Intelligence implementation, or `healthos-mcp` implementation claim was added

Residual gaps:
- local Codex automation registry is outside the repository and is not a HealthOS runtime artifact
- `healthos-mcp` remains unimplemented

## DOC-PLAN-001 — Documentary TODOs work plan + AI phase prompts (2026-04-28)

Objective: audit the full repository for open documentation TODOs, produce a sequential AI work plan, and write self-contained execution prompts for each phase.

Files touched:
- `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md` — comprehensive plan with 9 tasks across 3 phases
- `HealthOS/Shared/docs/execution/prompts/README.md` — prompt index
- `HealthOS/Shared/docs/execution/prompts/phase-1-settler-territory.md` — Phase 1 AI execution prompt (ST-006, ST-002, ST-003)
- `HealthOS/Shared/docs/execution/prompts/phase-2-architecture-proposals.md` — Phase 2 AI execution prompt (CL-006, OPS-003, ST-004)
- `HealthOS/Shared/docs/execution/prompts/phase-3-xcode-agent-streams.md` — Phase 3 AI execution prompt (Streams C, D, F)

Outcome:
- 9 documental TODO tasks identified, classified, and ordered
- 3 self-contained phase prompts with: identity, invariants, branch setup, mandatory pre-reading, per-task specs, tracking requirements, git workflow, definition of done
- Each task includes exact field specs, file targets, and PR templates

Residual gaps:
- none; prompts are READY — no phase has been executed yet

## ST-001a — README and repository roots for Settler/Territory scaffolds (2026-04-29)

Objective: update the main README and repository-local documentation roots after introducing Steward, Settler, Settlement, and Territory vocabulary.

Files touched:
- `README.md` — added Steward/Settler/Territory reading path, repository map entries, updated diagrams, and an engineering-layer diagram outside the clinical/runtime hierarchy
- `HealthOS/Constructor/Settler/README.md` — documentation-only root for Settler profile and Settlement record scaffolds
- `HealthOS/Constructor/Settler/profiles/README.md` — future profile instruction scaffold
- `HealthOS/Constructor/Settler/settlements/README.md` — future Settlement record scaffold
- `HealthOS/Constructor/Territory/README.md` — documentation-only root for Territory record scaffolds
- `HealthOS/Constructor/Territory/territories/README.md` — future Territory record scaffold
- `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md` — repository-local root doctrine added
- `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — active queue updated for scaffolded roots and future Territory records
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — handoff note updated
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — Settler/Territory scaffold completion note added

Invariants involved:
- Inv 1 (HealthOS Core is sovereign)
- Inv 42 (validation harness fail-closed and drift-sensitive)
- Inv 43 (scaffold closure never equals product readiness)
- engineering-agent boundary doctrine: Steward, Settlers, Settlements, Territories, Constructor roots, and `healthos-mcp` remain outside the HealthOS clinical/runtime hierarchy

Validation:
- `git diff --check` PASS
- `make validate-docs` PASS
- `make validate-all` PASS

Done criteria:
- README names the new engineering concepts without collapsing them into HealthOS runtime authority
- `HealthOS/Constructor/Settler/` and `HealthOS/Constructor/Territory/` exist as documentation scaffolds only
- diagrams and repository maps show the new roots as engineering surfaces outside clinical/runtime hierarchy
- status, handoff, and tracker docs are updated

Residual gaps:
- executable Settlers not implemented
- Settlement schema not implemented
- Territory records not defined beyond scaffold READMEs
- Territory loader not implemented
- `healthos-mcp` not implemented

## ST-001 — Steward / Settler engineering model doctrine (2026-04-29)

Objective: introduce the Steward / Settler / Settlement / Territory engineering model as documentation-only repository doctrine.

Files touched:
- `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md` — canonical doctrine for the model
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` — Steward for Xcode linked to Settlers, Settlements, Territories, and `healthos-mcp`
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` — simplified migration plan updated with Settler profile, Settlement record, MCP, and deterministic CLI boundaries
- `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — tracker for future Settler model implementation
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — short handoff note for future agents

Invariants involved:
- Inv 1 (HealthOS Core is sovereign)
- Inv 42 (validation harness fail-closed and drift-sensitive)
- Inv 43 (scaffold closure never equals product readiness)
- engineering-agent boundary doctrine: Steward, Settlers, Settlements, Territories, and `healthos-mcp` remain outside the HealthOS clinical/runtime hierarchy

Validation:
- `make validate-docs` PASS

Done criteria:
- doc 47 exists and contains all required sections
- doc 45 links to doc 47
- doc 17 includes Settler model updates while preserving simplified scope
- tracker 19 exists
- status and handoff tracking are updated
- no Swift, TypeScript, schema, or runtime source is modified

Residual gaps:
- executable Settlers not implemented
- `healthos-mcp` not implemented
- Settlement schema not implemented
- Settler profile skills not implemented

## TEST-001 — Swift test blocker cleanup for app/retrieval boundary suites (2026-04-28)

Objective: remove stale Swift XCTest compile blockers that prevented the repository test suite from running after the Scribe/GOS visibility work.

Files touched:
- `HealthOS/Shared/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift` — moved the Veridia raw-CPF boundary test back inside the test case so shared helpers remain in scope
- `HealthOS/Shared/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift` — moved the semantic-retrieval fixture test back inside the test case and updated its `RetrievalQuery` construction to the current contract shape
- `HealthOS/Shared/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift` — corrected the direct-identifier policy fixture so it exercises the intended fail-closed rule after lawful-context validation
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry and validation status correction
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — Scribe/GOS validation note updated now that `swift test` passes
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md` — AACI/GOS validation note updated now that `swift test` passes

Invariants involved: Inv 4 (apps do not interpret raw GOS spec), Inv 21/22 (retrieval honesty and provider boundary), Inv 31/32 (user-agent/patient sovereignty boundary), Inv 39/40/41 (cross-app app-safe envelope and refs).

Validation:
- `swift test` PASS — 241 tests, 0 failures

Done criteria:
- Swift XCTest target compiles again
- prior `CrossAppCoordinationContractsTests.swift` and `RetrievalMemoryGovernanceTests.swift` top-level brace/scope blockers are gone
- the residual user-agent fixture failure is corrected without weakening runtime/Boundary rules

Residual gaps:
- no production capability is implied; this work only restores local Swift test execution and boundary-regression coverage

## DOC-002 — README entry-surface expansion and visual atlas pass (2026-04-28)

Objective: strengthen `README.md` as the primary entry surface for HealthOS by adding clearer reading paths, repository/document maps, and more visually structured diagrams without removing existing constitutional content.

Files touched:
- `README.md` — added audience-based reading paths, visual reading map, repository atlas, next-step routes, cross-language contract diagram, and code-to-doc orientation table
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md` — documentation-entrypoint note updated for this work unit

Invariants involved: Inv 42 (validation/drift sensitivity), Inv 43 (scaffold closure is not product readiness), plus repository identity and anti-overclaim doctrine.

Validation:
- README expansion reviewed against `HealthOS/Shared/docs/architecture/01-overview.md`, `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md`, and `HealthOS/Shared/docs/execution/README.md`
- Liquid Glass guidance checked against Apple documentation and applied as documentation-design principles only: hierarchy, grouping, restrained emphasis, no false UI-capability claim

Done criteria:
- README remains constitutionally accurate while becoming a better navigation surface
- no existing README content removed
- diagrams improve visibility of system structure, reading order, and cross-language contract alignment

Residual gaps:
- markdown can only approximate a more expressive visual design; no actual Apple UI material/system behavior exists in repository docs rendering
- broader doc-site level visual system would require a dedicated publishing surface beyond plain README markdown

## WS-3-docs — Steward documentation precision pass (2026-04-28)

Objective: align canonical docs with the real post-reset `healthos-steward` baseline so the repository stops implying deterministic commands and Xcode-agent capabilities that are still only target architecture.

Files touched:
- `README.md` — Steward section reorganized around current baseline vs target architecture; clarified current session store and non-delivered operations
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/README.md` — package scope tightened to actual commands and explicit non-scope
- `HealthOS/Constructor/Steward/README.md` — derived-state root clarified; historical provider artifacts reframed as non-canonical and subordinate
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` — Steward follow-up rewritten around current baseline and target posture
- `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md` — removed false dependence on non-existent `scan`/`handoff` CLI commands
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` — WS-3 corrected to preserve current baseline while adding future deterministic operations explicitly
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — WS-3 objective/definition of done updated to match the real baseline and documentation needs
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry

Invariants involved: Inv 42 (validation/drift sensitivity), Inv 43 (scaffold closure is not product readiness), and repository-level anti-overclaim posture for Steward/`healthos-mcp`.

Validation:
- documentation consistency pass completed in-repo
- command surface verified against `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/steward.ts`

Done criteria:
- current docs describe only delivered `healthos-steward` commands (`status`, `runtime`, `session`) as implemented
- planned deterministic operations and `healthos-mcp` remain clearly labeled as target architecture
- Steward for Xcode stays outside the HealthOS clinical/runtime hierarchy in all touched docs

Residual gaps:
- WS-2 (`healthos-mcp`) remains doctrine-only/not implemented
- WS-3 code expansion for deterministic repository-maintenance operations remains pending

## WS-1 — Steward naming consolidation and healthos-mcp boundary doctrine (2026-04-28)

Objective: execute WS-1 (instructions and skills consolidation) and codify healthos-mcp boundary doctrine in all instruction and architecture files.

Files touched:
- `CLAUDE.md` — Steward section: canonical naming, Steward for Xcode posture, healthos-mcp boundary, deterministic baseline commands; removed stale StewardCore/StewardAgentRuntime references
- `AGENTS.md` — same updates as CLAUDE.md
- `README.md` — Steward section updated to canonical naming and Steward for Xcode posture
- `HealthOS/Shared/docs/execution/skills/project-steward-skill.md` — renamed to Steward, added canonical naming table, updated scope/reads/invariants/validation for current hard-reset baseline, added healthos-mcp boundary doctrine
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` — MCP boundary section: two-family boundary distinction added
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` — WS-2 boundary constraint added
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — WS-1 marked COMPLETED

Invariants involved: Inv 1 (Core sovereignty), Inv 17/22 (provider honesty and anti-fake posture), Inv 43 (scaffold closure is not production readiness).

Validation: `make validate-docs`

Done criteria:
- CLAUDE.md, AGENTS.md, README.md use canonical Steward naming
- healthos-mcp boundary doctrine present in instruction files, skill file, docs 45 and 17
- no false healthos-mcp implementation claims
- no collapse of healthos-mcp into clinical/runtime domain
- WS-1 marked COMPLETED in ops-network-ml.md
- `make validate-docs` passes

Residual gaps:
- WS-2 (healthos-mcp) not yet implemented
- WS-3 (deterministic CLI consolidation) not yet implemented

## ARCH-001 — Engineering-agent architectural realignment to Apple sovereignty thesis (2026-04-28)

Objective: apply a directional documentation correction to the engineering-agent layer, aligning it with the Apple sovereignty thesis and simplifying the target from a custom TypeScript agent runtime to Xcode Intelligence extension surfaces.

Files touched:
- `HealthOS/Shared/docs/architecture/44-project-steward-agent.md` — historical-reference header added
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` — rewritten as Steward for Xcode target architecture: Xcode Intelligence as native runtime surface; HealthOS contributes instructions, healthos-mcp, derived memory, deterministic CLI
- `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md` — created: Apple sovereignty thesis as unified architectural statement covering data plane, compute plane, and governance plane
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` — rewritten as Steward for Xcode migration plan: 3 workstreams (WS-1 instructions/skills, WS-2 healthos-mcp, WS-3 deterministic CLI), 3 phases
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — this entry
- `HealthOS/Shared/docs/execution/14-final-gap-register.md` — GAP-003 reframed: SQL/object backends are complementary query/index/projection substrates, not parity replacements for file-backed canonical storage
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md` — WS-1, WS-2, WS-3 added as READY items

Invariants involved: Inv 1 (Core sovereignty), Inv 14/15 (lawfulContext and storage layer enforcement), Inv 17/22 (provider honesty and anti-fake posture), Inv 43 (scaffold closure is not production readiness).

Validation: `make validate-docs`

Done criteria:
- docs 44, 45, 46, 17 present, voice-consistent, UTF-8 clean
- cross-references resolve to existing files
- no false Xcode Intelligence, Apple Private Cloud Compute, MCP, or Codex integration claims
- maturity ladder uses only canonical levels

Residual gaps:
- WS-1 (instructions and skills consolidation) is not implemented in this work unit
- WS-2 (healthos-mcp local MCP server) is not implemented in this work unit
- WS-3 (deterministic CLI consolidation) is not implemented in this work unit

## SCRIBE-008 — Minimal GOS runtime visibility in first-slice/Scribe surface (2026-04-28)

- expanded the app-safe `gosRuntimeState` bridge contract to include active workflow title, bound actor/family summaries, reasoning-boundary summaries, and draft-path mediation markers for SOAP/referral/prescription
- kept the Scribe/CLI surface informational and provenance-facing only: no raw compiled spec/runtime-binding JSON is exposed, and `legalAuthorizing=false`, `gateStillRequired=true`, and draft-only semantics remain explicit
- updated the minimal SwiftUI Scribe validation surface and Scribe smoke output to show active bundle/spec, bound actors, and exact `gos.use.*` mediation operations
- updated runtime-state/app-consumption docs so apps can audit GOS-mediated AACI work without interpreting GOS as sovereign policy
- validation: `swift build` PASS; `swift run HealthOSCLI` PASS; `swift run HealthOSCLI --reject-gate` PASS; `swift run Scribe --smoke-test` PASS; `swift run Scribe --smoke-test-audio` PASS; follow-up `swift test` PASS after TEST-001 cleanup
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ScribeFirstSliceBridge.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/ScribeSessionAdapter.swift`
- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/Models/ScribeFirstSliceViewModel.swift`
- `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/Views/ScribeFirstSliceView.swift`
- `HealthOS/Shared/Sources/HealthOSCLI/CLIEntrypoint.swift`
- `HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `HealthOS/Shared/docs/architecture/22-runtime-state-surfaces.md`
- `HealthOS/Shared/docs/architecture/23-scribe-screen-contracts.md`
- `HealthOS/Shared/docs/architecture/33-gos-app-consumption-patterns.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md`

## AACI-009 / GOS runtime guidance for derived drafts (2026-04-28)

- linked the referral and prescription draft derivatives to the active GOS resolved runtime view through an explicit `DerivedDraftOperationalGuidance` contract carried on the existing same-session/SOAP/context spine link
- derived draft payloads, persisted metadata, session-event attributes, and note summaries now surface bounded operational guidance: actor id, semantic role, primitive families, reasoning boundary, `gos.use.derive.*` operation, draft-only flag, gate-required flag, and non-authorizing posture
- kept derivation intentionally low-authority: no new clinical semantics, no GOS mini-language, no referral/prescription effectuation path, and both derivatives remain `DraftStatus.draft`
- validation status: `swift build` PASS; follow-up `swift test` PASS after TEST-001 cleanup; `cd HealthOS/Constructor/ts && npm run build` PASS; `make validate-schemas` PASS; `swift run HealthOSCLI` PASS; `swift run HealthOSCLI --reject-gate` PASS; `swift run Scribe --smoke-test` PASS; `swift run Scribe --smoke-test-audio` PASS
Files touched:
- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/FirstSliceContracts.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift`
- `HealthOS/Constructor/ts/packages/contracts/src/index.ts`
- `HealthOS/Tier1-Mestral-Core/Schemas/contracts/referral-draft-document.schema.json`
- `HealthOS/Tier1-Mestral-Core/Schemas/contracts/prescription-draft-document.schema.json`
- `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md`
- `HealthOS/Shared/docs/architecture/31-gos-runtime-binding.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- `HealthOS/Shared/docs/execution/todo/gos-and-compilers.md`


## OPS-004 — Xcode repository organization audit and monorepo entrypoint decision (2026-04-28)

- audited the repository for Apple/Xcode entrypoint readiness and confirmed the canonical Swift package exists at `HealthOS/Package.swift` with core, AACI, providers, first-slice support, CLI, Scribe app, and XCTest targets
- confirmed the correct repository posture is a multi-stack monorepo, with Xcode as an Apple-layer entrypoint and SwiftPM remaining the canonical build graph for Swift
- added a root `HealthOS.xcworkspace` that points to `HealthOS/Package.swift`, giving the repository a stable Xcode-native entrypoint without collapsing TypeScript/Python/docs into Xcode build ownership
- documented the organization decision and target layout in a dedicated repository audit note
- validation status: repository structure and package manifest verified; no full Xcode build was run in this work unit
Files touched:
- `HealthOS.xcworkspace/contents.xcworkspacedata`
- `HealthOS/Shared/docs/execution/19-xcode-repository-organization-audit.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md`
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
- `README.md`

## DOC-001 — HealthOScaffold / HealthOS repository identity vocabulary correction (2026-04-28)

- added ADR 0012 to establish that HealthOScaffold is the historical repository name and HealthOS construction repository, not a separate scaffold product
- aligned README, AGENTS, CLAUDE, GEMINI, execution docs, maturity/coverage docs, architecture docs, steward/Xcode Agent docs, TODOs, and skills so "scaffold" means maturity/foundation phase only
- clarified that implemented architecture, contracts, runtimes, apps, tests, schemas, migrations, and documentation in this repository are HealthOS work unless explicitly experimental or deprecated
- preserved non-production warnings: not production-ready, not a complete EHR, no real provider/signature/interoperability/semantic retrieval claims, no final UI claim, and no production cloud/fabric claim
- validation: `make validate-docs` PASS; `make validate-all` FAIL only at `swift-test` due existing Swift test compile errors in `CrossAppCoordinationContractsTests.swift` and `RetrievalMemoryGovernanceTests.swift` (files not changed in this work unit); all other validate-all steps passed
Files touched:
- `HealthOS/Shared/docs/adr/0012-healthoscaffold-is-healthos-construction-repository.md`
- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `GEMINI.md`
- `HealthOS/Shared/docs/execution/README.md`
- `HealthOS/Shared/docs/execution/00-master-plan.md`
- `HealthOS/Shared/docs/execution/01-agent-operating-protocol.md`
- `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`
- `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
- `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`
- `HealthOS/Shared/docs/execution/14-final-gap-register.md`
- `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md`
- `HealthOS/Shared/docs/architecture/01-overview.md`
- `HealthOS/Shared/docs/architecture/19-interface-doctrine.md`
- `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md`
- `HealthOS/Shared/docs/architecture/44-project-steward-agent.md`
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md`
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md`
- `HealthOS/Shared/docs/execution/18-healthos-xcode-agent-task-tracker.md`
- `HealthOS/Constructor/Steward/README.md`
- `HealthOS/Shared/docs/execution/skills/README.md`
- `HealthOS/Shared/docs/execution/skills/documentation-drift-skill.md`
- `HealthOS/Shared/docs/execution/skills/project-steward-skill.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`

## ML-012 — HealthOS steward hard reset and new clean runtime baseline (2026-04-27)

- removed the previous `HealthOS/Constructor/ts/agent-infra/healthos-steward` implementation entirely instead of preserving compatibility layers or a `legacy` path inside the package
- recreated `@healthos/steward` from scratch as a minimal runtime baseline centered on runtime requests, sessions, surface identity, and file-backed session persistence
- added `HealthOS/Constructor/Steward/memory/sessions/` as the first real runtime-owned state directory for the new steward
- new package baseline now exposes only `status`, `runtime`, and `session` flows; old provider/prompt/review command implementation is no longer present in the package runtime
- dedicated initiative tracker remains at `HealthOS/Shared/docs/execution/18-healthos-xcode-agent-task-tracker.md` and was rewritten to reflect the hard reset rather than an incremental migration fiction
- validation status: no build/test run in this environment after the reset; a minimal runtime test file exists for future package validation
Files touched:
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/package.json`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/README.md`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/cli.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/steward.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/runtime/types.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/runtime/session-store.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/runtime/runtime.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/test/runtime.test.mjs`
- `HealthOS/Shared/docs/execution/18-healthos-xcode-agent-task-tracker.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md`

## ML-011 — HealthOS Xcode Agent initiative tracker and first runtime-core implementation (2026-04-27)

- created a dedicated multi-turn initiative tracker at `HealthOS/Shared/docs/execution/18-healthos-xcode-agent-task-tracker.md` to keep architecture, streams, queue, and open decisions synchronized across future work units
- introduced the first concrete runtime-centric TypeScript implementation under `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/agent/` with explicit contracts for runtime mode, conversation surface, session snapshot, action record, policy guard, tool runtime, and model backend
- added minimal executable helpers for session creation, session message append, policy evaluation, request summarization, and a first compatibility `runAgentRuntime` flow that no longer depends on provider CLI paths as the sole entry model
- exported the new agent runtime API surface from the package root and added a first validation test file for future `npm test` execution
- updated the initiative tracker to mark XA-002 complete and XA-003 in progress
- validation status: no build/test run in this environment; TypeScript compilation remains to be executed in a future validated shell/build step
Files touched:
- `HealthOS/Shared/docs/execution/18-healthos-xcode-agent-task-tracker.md`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/agent/types.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/agent/runtime.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/agent/guards.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/agent/index.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/test/agent-runtime.test.mjs`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md`

## ML-010 — HealthOS Xcode Agent target architecture and migration documentation (2026-04-27)

- documented the target evolution of Project Steward into a repository-aware engineering agent with conversation surfaces, sessions, tool runtime, policy guards, and model backends subordinate to the runtime
- established an explicit separation between current steward scaffold (`44-project-steward-agent.md`) and target architecture (`45-healthos-xcode-agent.md`)
- added a concrete migration plan covering runtime extraction, session model, CLI conversation surface, Xcode-native surface, optional frontend surface, and compatibility strategy
- updated steward entry docs and handoff docs so future work does not continue reinforcing the provider-centric model by accident
- validation status: documentation work only; no code build/test run as part of this work unit
Files touched:
- `HealthOS/Shared/docs/architecture/44-project-steward-agent.md`
- `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md`
- `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
- `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md`
- `HealthOS/Constructor/Steward/README.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md`

## ML-009 — Steward agent command de-aliasing and provider config selection hardening (2026-04-27)

- `healthos-steward` now loads provider config in the expected precedence order: `providers.local.json` -> `providers.json` -> `providers.example.json`, so real repository config is no longer skipped when local overrides are absent
- provider kind fallback no longer silently degrades into a local `echo` command; disabled/unknown non-invokable kinds now fail closed instead of masquerading as runnable adapters
- agent subcommands `handoff`, `generate-codex-prompt`, and `sync-memory` now execute distinct prompt/template flows instead of aliasing to `plan-next`
- deterministic `prompt codex-next` / `next-task` now read the Codex-specific prompt file rather than the model-planning prompt
- TypeScript tests expanded to cover provider-config precedence, fail-closed disabled provider behavior, and non-aliased agent dry-run command outputs
- validation status: source/test edits completed, but build/test execution was not run in this environment because shell execution was interrupted and Xcode diagnostics are unavailable for these TypeScript files
Files touched:
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/providers/router.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/steward.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/test/cli.test.mjs`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/test/providers.test.mjs`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/ops-network-ml.md`

## APP-009 — Documentation drift check for app-boundary claims (2026-04-27)

- Stage architecture docs now carry explicit "Scaffold posture / non-claims" sections for the initial Stages
- interface doctrine doc (`19-interface-doctrine.md`) now includes scaffold-honest summary of all three Stage surfaces (Scribe minimal SwiftUI, Veridia/CloudClinic contract-first only)
- wording hardened across Stage docs to avoid implying final UI, production readiness, or real provider integration
- Scribe doc now clarifies scaffold-only status for microphone capture, transcription, semantic retrieval, and draft refresh
- Veridia doc now clarifies no final UI shell, no user-agent runtime wiring, and contract-first patient sovereignty surfaces
- CloudClinic doc now clarifies no final UI shell, no persisted queue/projection service, and contract-first service operations
- execution tracking (`02-status-and-tracking.md`) updated with APP-009 completion entry
Files touched:
- `HealthOS/Shared/docs/architecture/11-scribe.md`
- `HealthOS/Shared/docs/architecture/12-veridia.md`
- `HealthOS/Shared/docs/architecture/13-cloudclinic.md`
- `HealthOS/Shared/docs/architecture/19-interface-doctrine.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/todo/apps-and-interfaces.md`

## Steward provider hardening — typed errors and review comment formatter (2026-04-27)

- Steward provider `errorKind` union widened from 12 to 17 cases with documented operator-actionable categories: HTTP semantics now distinguish `auth` (401/403), `notFound` (404), `serverError` (5xx) and `rateLimited` (429); transport-layer failures now distinguish `networkUnavailable` (pre-response fetch failure) from `timeout` (`AbortSignal.timeout`/`AbortError`); payload-layer failures now distinguish `parseError` (JSON parse failure) from `payloadEmpty` (200 OK without extractable text)
- network-error classification no longer relies on substring matching of `error.message`; uses `error.name` (`TimeoutError`/`AbortError`) and `instanceof TypeError` to identify timeouts and `fetch failed` cases
- provider HTTP error responses now surface the provider-supplied human-readable message (`error.message` for OpenAI/xAI; nested `error.message` for Anthropic) instead of a generic status label
- response payload extraction now uses mode-aware extractors: OpenAI Responses walks `output_text` shortcut and `output[].content[].type === 'output_text'`; Anthropic Messages filters `content[]` to `type === 'text'` and ignores tool_use blocks; chatCompletions handles both string and array `message.content`
- payload-empty detection added: 200 OK with no extractable assistant text is reported as `errorKind: 'payloadEmpty'` rather than masquerading as a successful empty completion
- new `formatStewardReviewComment` produces a deterministic PR review comment body with HTML marker (`<!-- healthos-steward review -->`), provider/model/timestamp/policy-version header, and an explicit non-authority footer; throws on empty body so the steward never posts placeholder comments under any code path
- `agent review-pr --post-comment` now wraps the provider output through `formatStewardReviewComment` before posting; policy versions are read at post time from `HealthOS/Constructor/Steward/policies/invariant-policy.yaml` and `pr-review-rubric.yaml`
- Steward agent runtime now memoizes the provider router instead of recreating it per invocation, removing redundant config reads on multi-step `agent review-pr` flows
- `node:test` coverage increased from 12 to 33 cases without live network: typed assertions for every new errorKind branch, mode-specific extractor shapes (OpenAI walked output, Anthropic content-block filtering, xAI chat completions), `formatStewardReviewComment` empty-body refusal and metadata header, and the `classifyHttpError`/`classifyNetworkError`/`extractProviderErrorMessage` helpers

## Governance/doc readiness consolidation (2026-04-26)


- Project Steward conceptual correction completed: deterministic `StewardCore` and provider-required `StewardAgentRuntime` are now explicitly separated in CLI/runtime behavior
- Steward provider layer is now explicitly LLM-focused (OpenAI/Anthropic/xAI/disabled), with Codex/Claude Code treated as external executors rather than internal providers
- agentic operations now require explicit `--provider` and `--allow-network`; deterministic commands continue working without provider or network
- deterministic `healthos-steward next-task` is restored as a non-deprecated core command for offline task scaffolding; model-backed planning remains under `agent plan-next`
- Steward provider closure now enforces real-output-only PR review posting (`--post-comment`) and never posts placeholder comments when provider invocation fails
- steward provider test coverage now includes mocked-fetch invocation tests for OpenAI/Anthropic/xAI real-call code paths (no live network)

- Project Steward engineering scaffold was introduced with a TypeScript CLI package (`@healthos/steward`) and commands for status/scan/next-task/validate/review-pr/memory/prompt/handoff, with explicit fail-closed behavior when GitHub CLI is unavailable or not authenticated
- repository-scoped persistent steward memory/policy/prompt templates now exist at `HealthOS/Constructor/Steward/` with explicit derived-index posture and no-secrets/no-clinical-payload constraints
- architecture/skill docs now document steward role/boundary (`HealthOS/Shared/docs/architecture/44-project-steward-agent.md`, `HealthOS/Shared/docs/execution/skills/project-steward-skill.md`) and agent entry docs now reference steward usage without replacing canonical execution docs
- Project Steward now has real GitHub CLI integration for PR ingestion (PR metadata/checks/comments) and write-through comment commands for PR/issue (`comment-pr`, `comment-issue`), with explicit authenticated-`gh` requirement and fail-closed setup errors

- repository entry docs were reconciled to reduce drift across `README.md`, `AGENTS.md`, `CLAUDE.md`, execution guides, TODOs, and skills
- command baseline now includes explicit test/check commands in `Makefile` (`swift-test`, `ts-test`, `python-compile`, `swift-smoke`)
- maturity signaling is now explicitly consolidated in `11-current-maturity-map.md` using the canonical ladder (`doctrine-only` → `production-hardened`)
- next-agent handoff is now centralized in `12-next-agent-handoff.md` to reduce repeated context reconstruction and false maturity claims

- Scribe / Professional Workspace / AACI session contracts were hardened in Swift Core with explicit app-safe governed surfaces for professional workspace context, session state machine states, capture-transcription honesty, retrieval-context posture, draft review, human gate review, final-document lineage, and aggregate Scribe app runtime state (`ScribeProfessionalWorkspaceContracts.swift`)
- Scribe-first-slice bridge state now exposes explicit professional session state, workspace context, and allowed-next-actions metadata so app-facing session orchestration remains runtime-mediated and does not imply app-owned law decisions
- Swift XCTest coverage now includes dedicated Scribe workspace/session boundary negatives (`ScribeProfessionalWorkspaceContractsTests`) for missing habilitation/finalidade/patient selection, gate/finalization state-machine denials, capture/transcription honesty, retrieval scope and leak checks, draft-only/gate-required invariants, gate reviewer/rationale policy, final document lineage, and app-boundary sensitive leak denial

- regulatory/interoperability/signature/emergency governance scaffold is now formalized in Swift Core (`RegulatoryAuditRequest`, `EmergencyAccessRequest`, `RetentionVisibilityDecision`, `DigitalSignatureRequest`, `InteroperabilityPackage`, `ProbativeDocumentLineage`) with fail-closed validators for legal basis/scope/duration/lawfulContext, package layer minimization, placeholder-only external delivery, and signature lineage guards
- regulatory observability taxonomy is now explicitly typed (`regulatory.audit.*`, `emergency_access.*`, `retention.visibility_decision`, `signature.*`, `interoperability.*`) with non-sensitive attribute posture (no clinical payload, no raw CPF, no private key material)
- Swift XCTest coverage now includes dedicated regulatory governance negatives/positives (`RegulatoryGovernanceTests`) covering audit request denials, emergency/break-glass expiry guards, retention-vs-visibility/deletion separation, signature scaffold honesty (no fake qualified status without prerequisites), interoperability package lineage checks, and AACI/GOS boundary denials
- backup/restore/retention/export/DR governance scaffold is now formalized in Swift Core contracts (`BackupManifest`, `RestorePlan`, `RetentionPolicy`, `ExportRequest`, `DisasterRecoveryPlan`) with explicit fail-closed validators for lawfulContext, direct-identifier/reidentification policy gates, restore hash integrity, final-document gate lineage, and revoked-lifecycle non-reactivation
- backup/export/restore/retention/DR observability event taxonomy is now explicitly typed (`backup.*`, `restore.*`, `export.*`, `retention.*`, `dr.*`) and constrained to non-sensitive operational attributes
- Swift XCTest coverage now includes dedicated backup governance negatives/positives (`BackupGovernanceTests`) covering manifest schema/hash rules, restore dry-run/hash/conflict/revoked/finality guards, retention legal-hold and rationale checks, export lawful-context + reidentification/direct-identifier denials, DR readiness checks, and AACI/GOS control-plane boundary denials

- async runtime failure handling now emits explicit `job.policy_denied` observability events for fail-closed lawful-context/policy denials, and preserves policy-denied failures in execution records for operator inspection
- async runtime failure transitions were tightened to enforce `running -> failed -> retry_scheduled/dead_letter` progression before retry/dead-letter routing, reducing silent transition drift in guarded failure paths
- async runtime governance tests now assert policy-denied observability emission and record-level preservation of policy-denied failures

- async runtime governance moved from stub posture to typed executable scaffold in Swift Core and TypeScript contracts/runtime package, with explicit async job taxonomy, lifecycle states, lawful-context requirements, retry/backoff policy, idempotency contract, and observability event taxonomy
- a local minimal async executor now exists (`InMemoryAsyncJobRuntime`) with fail-closed policy checks for sensitive jobs, direct-identifier/reidentification scope guards, bounded retry scheduling, dead-letter handling, pending cancellation, and idempotency reuse behavior for completed jobs
- operator control surface for async jobs is now executable at contract level (`listJobs`, `inspectJob`, `cancelPendingJob`, `requeueDeadLetter`, `healthSummary`) without introducing distributed queue infrastructure or production scheduler claims
- SQL canonical migration now includes async runtime metadata tables (`async_jobs`, `async_job_attempts`, `async_job_events`) for persisted job state/attempt/event modeling when SQL-backed execution is wired in future waves
- Swift XCTest coverage now includes dedicated async runtime governance tests (`AsyncRuntimeGovernanceTests`) covering lifecycle transitions, lawful-context negatives, retry/backpressure/idempotency behavior, observability-event emission, and app/AACI/GOS/provider boundary denials

- retrieval/memory/index governance scaffold landed in Swift Core with explicit governed contracts (`GovernedRetrievalQuery`, retrieval mode/policy/failure typing, memory scope contracts, semantic index/embedding scaffold contracts) and fail-closed validation for lawfulContext/finalidade/patient scope/layer denial
- bounded retrieval now has an explicit governed retrieval entrypoint that preserves deterministic lexical behavior while failing honestly for semantic/hybrid requests without compatible embedding providers (`unavailable` or explicit lexical fallback marked by policy)
- first-slice retrieval path was minimally migrated to the governed query flow and now appends explicit retrieval provenance checkpoints (`retrieval.request`, `retrieval.policy.evaluate`, `context.package.assemble`) without changing external first-slice semantics
- provider routing now includes embedding-provider registration/routing seams, preserving fail-closed policy denial for direct identifiers/reidentification layers and enabling explicit semantic-provider boundary checks
- Swift XCTest coverage now includes dedicated retrieval/memory governance negatives and first-slice regression checks (`RetrievalMemoryGovernanceTests`) covering lawfulContext requirements, memory-scope isolation, semantic-unavailable honesty, lexical deterministic fallback labeling, result redaction, and mediated app-facing retrieval summaries

- AI provider governance hardening landed in Swift with typed provider capability profiles (`ProviderCapabilityProfile`), typed task classes/kinds, registration validation, and fail-closed provider routing outcomes (`selected`, `degradedFallback`, `deniedByPolicy`, `unavailable`, `stubOnly`) plus typed denial reasons.
- remote fallback guard scaffold is now explicitly fail-closed for direct identifiers, reidentification mappings, and sensitive operational content without explicit policy; remote provider integration remains stub-only in this round.
- first-slice/AACI transcription path now routes through policy-aware speech selection and carries explicit provider execution metadata that distinguishes seeded-text path vs stub speech path without fabricating transcript text.
- first-slice provenance for draft composition no longer hardcodes a provider id; it now records provider/model metadata from typed language-model routing decisions.
- model registry scaffold became executable/testable via typed contracts (`ModelRegistryEntry`, lifecycle status, selection/promotion guards) with explicit non-production/template posture support.
- fine-tuning governance scaffold became executable/testable via typed contracts (`DatasetVersion`, `TrainingJobRecord`, `AdapterArtifact`, `EvaluationResult`, promotion/rollback decisions) and fail-closed checks for missing dataset/evaluation.
- Swift XCTest coverage now includes a dedicated `ProviderGovernanceTests` suite covering provider capability validation, routing safety denials, stub-only behavior, speech honesty negatives, model-registry lifecycle guards, fine-tuning governance guards, and no-online-training side effects.

- storage layer governance contracts were hardened in Swift with explicit layer sensitivity semantics, per-layer write guards, and metadata/context requirements (including stricter handling for direct identifiers, governance metadata, derived artifacts, and reidentification mappings)
- file-backed storage now enforces layer-aware fail-closed writes, deterministic SHA-256 hashing in-process, and automatic read-audit entries that distinguish direct-identifier reads from common reads
- first-slice storage writes now provide stronger metadata context (finalidade/provenance operation/governance actor where applicable) and pass lawfulContext through sensitive write paths
- reidentification governance scaffold contracts were added (`DeidentificationMap`, `ReidentificationRequest`, `ReidentificationResolution`, `ReidentificationAuditEntry`) with fail-closed contextual validation and provenance append hooks
- Swift XCTest coverage now includes negative tests for sensitive-layer writes without governed context, missing reidentification scope, missing derived-artifact provenance metadata, reidentification request/resolution guards, direct-identifier read audit tagging, and CPF-hash path use without app-facing identifier leakage
- Core constitutional hardening now includes a reusable typed lawful-context contract (`LawfulContextValidator` + `LawfulContextRequirement` + `CoreLawfulContext`) that accepts existing dictionary payloads while enforcing required law fields.
- Core typed law failures were strengthened with explicit `CoreLawError` cases for lawful-context gaps, consent/habilitation requirements, and regulated finalization denial pathways.
- file-backed storage enforcement now fail-closes `get/list/audit` on missing governed context and requires stronger lawful context for storage-audit writes (service/patient/habilitation/finality/session).
- first-slice provenance now records explicit `habilitation.validate` and `consent.validate` operations and separate `storage.write` / `storage.audit` operations on key draft/finalization persistence paths.
- Swift XCTest coverage now includes lawful-context contract negatives/positive, storage governed-vs-operational failure distinction, explicit missing-finality consent failure, and additional finalization-state negative guard coverage.
- GOS lifecycle policy hardening now enforces pragmatic review/activation policy in the file-backed registry: required rationale, compiler-report pass checks, append-only multi-review records, typed policy failures, and policy-denied lifecycle audit entries
- reviewed-bundle activation policy now supports minimum multi-review thresholds, separation-of-duties between reviewer/activator, deterministic version/source/compiler pin checks, and compiled-spec hash pin checks via `GOSActivationPins`
- lifecycle audit actions now explicitly include policy lifecycle checkpoints (`review_submitted`, `review_denied_policy`, `activation_requested`, `activation_denied_policy`) while keeping append-only audit history
- HealthOSCLI promotion path now accepts minimal policy pin inputs (`--activator-id`, `--pin-*`) for deterministic activation pinning checks
- Swift XCTest lifecycle coverage now includes review rationale failure, review compiler-report failure, insufficient-review activation denial, separation-of-duties denial, pin mismatch denials, and denied-vs-accepted lifecycle audit assertions
- pragmatic invariant enforcement matrix was added at `HealthOS/Shared/docs/execution/10-invariant-matrix.md`, including explicit constitutional invariants, real current enforcement, state-machine rules, test coverage, and hardening gaps (without claiming full formal proof)
- Swift XCTest lifecycle coverage now explicitly asserts deprecated-bundle load denial for active-only runtime loads (`bundleDeprecated`) and verifies known-bundle history remains intact after denied invalid lifecycle transitions
- file-backed GOS registry now enforces deterministic multi-bundle load safety per spec: missing registry entries, corrupted registry files, missing active pointers with active known bundles, and competing active bundles all fail with typed errors
- file-backed lifecycle transitions are now explicitly hardened with typed invalid-transition errors for out-of-policy moves, while preserving the intended transition set (`draft -> reviewed`, `reviewed -> active`, `reviewed -> revoked`, `active -> deprecated`, `active -> revoked`)
- activating a new reviewed/active bundle for the same spec now supersedes the previously active bundle manifest, preserving history while keeping a single active bundle resolution path
- Swift XCTest lifecycle/loader coverage now includes registry-missing/corruption failures, active-pointer inconsistency failures, deterministic competing-active rejection, and missing-runtime-binding-plan fallback via AACI default bindings
- Swift GOS/AACI/first-slice boundary tests now assert ordered provenance separation on approved paths (`gos.activate` precedes draft composition/derivation, which precedes `gate.request`, then `gate.resolve`, then `document.finalize.soap`)
- Swift boundary tests now verify active GOS cannot bypass core habilitation/consent checks: inactive professional/patient inputs still fail before runtime mediation executes
- Scribe bridge GOS runtime surface now includes an explicit non-authorizing contract flag (`legalAuthorizing: false`) so spec/bundle IDs remain informational/provenance-facing only
- Scribe first-slice bridge now surfaces a dedicated runtime-mediated GOS app state contract (`gosRuntimeState`) with explicit informational/provenance-facing posture, explicit gate-still-required + draft-only flags, and bounded mediation summaries (actor ids, primitive-family count, `gos.*` provenance operations) instead of app-facing raw spec/binding payloads
- Swift boundary tests now verify Scribe app-bridge GOS surfaces in both active and inactive runtime paths, ensuring no raw compiled spec/binding JSON leaks while gate-required/finalization boundaries stay Core-driven
- first-slice provenance now records explicit `gate.request` before `gate.resolve`, so GOS activation/usage, draft composition, gate transitions, and final document creation are auditable as distinct operations
- Swift boundary tests now verify active-GOS first-slice runs still preserve draft-only outputs until human gate approval/rejection, and only approved gate paths produce `document.finalize.soap`
- Swift boundary tests now verify Scribe bridge state remains runtime-mediated and does not expose raw compiled GOS spec/runtime-binding payloads as app-law inputs
- AACI resolved runtime GOS view now includes lifecycle + binding-runtime-kind context and actor mediation flags (`gosActorBound`, `gosDraftOutputBound`, `gosGateRequiredByBinding`, `gosDraftOnly`) so internal subagent paths consume bounded resolved bindings instead of ad hoc checks
- AACI SOAP/referral/prescription internal composition paths now consult mediation flags from the resolved runtime view to reinforce draft-only + human-gate-required boundaries without moving sovereign law out of Core
- first-slice provenance now differentiates SOAP draft composition usage (`gos.use.compose.soap`) from derived-draft generation usage (`gos.use.derive.referral`, `gos.use.derive.prescription`)
- TypeScript `@healthos/gos-tooling` test coverage now includes CLI `validate` + `compile` success paths and explicit failure assertions for bundle/validate cross-reference and evidence-hook completeness defects
- Swift XCTest GOS lifecycle coverage now includes missing-manifest activation denial, missing spec/compiler-report/source-provenance load denial, unknown active-pointer bundle denial, and active-pointer cleanup on deprecating active bundles
- AACI resolved runtime-view metadata now carries explicit `gosBindingCount` and `gosCompilerWarningCount` values so runtime-mediated payloads/provenance expose bounded bundle-context diagnostics without exposing raw spec interpretation
- first-slice GOS adoption now reaches beyond draft composition: capture, transcription, and context-retrieval paths consume the resolved AACI runtime view for metadata, reasoning boundaries, and explicit `gos.use.*` provenance
- GOS file-backed lifecycle now enforces typed load/activation/review failures (instead of generic NSError), including explicit handling for missing manifest/spec/compiler-report/source-provenance artifacts, registry pointer inconsistencies, deprecated/revoked bundles, and invalid runtime binding plans
- file-backed registry now exposes small explicit result contracts for draft→reviewed and reviewed→active lifecycle transitions (`GOSReviewResult`, `GOSActivationResult`) while keeping CLI/runtime-facing lifecycle surface minimal
- Swift XCTest lifecycle coverage now validates register/review/promote/activate flows, activation denial for drafts, load denial for revoked bundles, active-pointer cleanup on revoke, known-bundle preservation on non-active deprecation, and active-load success for valid lifecycle artifacts
- file-backed GOS lifecycle now persists explicit review approval records (`review-approval.json`) and append-only lifecycle audit records (`system/HealthOS/Tier2-GOS-Runtimes/GOS/audit.jsonl`) for review and activation transitions
- HealthOSCLI now exposes a minimal lifecycle path for `draft -> reviewed -> active` through `--gos-review-bundle` and `--gos-promote-bundle`, recording operator/reviewer identity and rationale
- Swift GOS lifecycle persistence is now schema-aligned in `snake_case` across manifest, registry entry, review record, and audit artifacts
- AACI now exposes a public, small resolved GOS runtime view (`bundle + workflow title + bound actors/families`) so runtime consumers do not need raw spec JSON or ad hoc dictionary access
- first-slice storage metadata and event attributes now derive directly from the AACI resolved GOS runtime view, carrying actor-specific primitive-family and reasoning-boundary context for SOAP/referral/prescription draft paths
- first-slice provenance now records GOS draft-path usage under the concrete composing actor ids (`aaci.draft-composer`, `aaci.referral-draft`, `aaci.prescription-draft`) instead of a generic `aaci.gos` actor marker
- TypeScript GOS tooling now has executable bundle-CLI coverage for canonical lifecycle artifacts (`manifest.json`, `spec.json`, `compiler-report.json`, `source-provenance.json`)
- local validation in this round explicitly confirmed the active-bundle path with `bash ./scripts/bootstrap-local.sh`, `npm run --workspace @healthos/gos-tooling test`, `swift test`, and `swift run HealthOSCLI --reject-gate`, including persisted GOS metadata and `gos.use.compose.*` provenance in `HealthOS/Shared/runtime-data/Users/Shared/HealthOS`
- local GOS closure validation is currently smoke-level end-to-end (`bootstrap-local`, TypeScript build, GOS validate/bundle, Swift build, HealthOSCLI smoke, Scribe `--smoke-test`), not production-readiness validation
- TypeScript GOS tooling was stabilized so schema resolution and strict typing now build cleanly, and canonical compiled metadata now conforms to compiled-schema constraints
- GOS file-backed registry/loader hardening now validates registry-pointer consistency, manifest/spec/compiler-report/source-provenance presence, compiler report pass/fail status, and runtime-binding-plan compatibility before activation
- AACI runtime now applies active GOS bundle mediation inside orchestrator draft composition/referral/prescription paths; runner-level draft mutation is no longer the primary mediation point
- first-slice now records explicit `gos.activate.failed` provenance when activation cannot be completed, instead of silently dropping runtime diagnosis
- Scribe now includes a headless smoke fallback for non-SwiftUI environments while keeping SwiftUI/macOS behavior intact
- first-slice runner now attempts optional GOS activation and uses the resulting active bundle to mediate persisted SOAP/referral/prescription drafts, storage metadata, event attributes, and provenance when an active bundle exists
- AACI activation now normalizes loader failures into typed runtime-consumable categories (`GOSLoadTypedError` + `GOSLoaderFailure`) while preserving underlying registry errors for diagnostics/tests
- GOS validator now performs minimal evidence-hook completeness checks for task and draft-output phases
- GOS Stage consumption patterns document added, clarifying what initial Stages may consume from GOS-driven runtime work
- GOS TypeScript tooling now performs authoring-schema validation, compiled-schema validation, cross-reference validation, and simple invariant checks
- GOS compiler output now includes source provenance hashing/reporting
- GOS CLI now supports `validate`, `compile`, and `bundle`
- GOS bundle generation now emits manifest, compiled spec, compiler report, and source provenance files
- Swift file-backed GOS registry/loader scaffold was upgraded into a minimal functional implementation that can register manifests, activate bundles, and load active bundles
- AACI now has an executable GOS activation seam through `AACIOrchestrator.activateGOS(specId:loader:)`
- GOS runtime-binding architecture doc updated to reflect executable Swift seams, default AACI binding map, and activation behavior
- Swift contracts added for GOS bundle loading, registry entries, runtime binding plans, compiled bundles, compiler reports, and lifecycle states
- default AACI GOS runtime binding plan scaffold added in Swift
- minimal file-backed GOS registry/loader scaffold added in Swift so bundle loading now has a typed runtime seam, even though the implementation remains intentionally minimal
- GOS lifecycle/storage architecture document added with bundle identity, lifecycle states, activation posture, rollback posture, and canonical storage recommendation
- lightweight authoring schema added for YAML-form GOS source documents
- GOS bundle-manifest schema added for compiled-bundle lifecycle representation
- GOS moved beyond doctrine-only and now has authoring/compiler/validator scaffolding in-repo
- GOS authoring and compiler architecture document added
- GOS runtime-binding architecture document added
- generic GOS authoring workspace added under `HealthOS/Tier2-GOS-Runtimes/GOS/` with blank YAML template
- TypeScript package `@healthos/gos-tooling` added with parse/canonicalize/validate/CLI scaffolds
- README expanded to surface GOS workspace and tooling as first-class repository components
- GOS backlog updated to reflect authoring, compiler, validator, runtime-binding, and lifecycle scaffolds now in place
- Governed Operational Spec (GOS) introduced as a formal subordinate layer between HealthOS Core and runtimes
- ADR 0011 added to establish GOS as HealthOS-native intermediate operational spec, explicitly subordinate to core law
- GOS architecture document added with canonical placement, constitutional boundary, primitive families, compiler posture, and runtime posture
- canonical JSON schema added for GOS compiled form, with explicit primitive families: signal, slot, derivation, task, tool binding, draft output, guard, deadline, evidence hook, human gate requirement, escalation, and scope requirement specs
- README, AACI runtime doc, and interface doctrine updated so GOS now appears in canonical hierarchy and app-boundary doctrine without moving law away from core
- GOS backlog added for compiler, validator, runtime-binding, lifecycle, and app-boundary follow-up work
- doctrinal consolidation wave completed: HealthOS reinforced as health-exclusive sovereign environment (not generic cloud)
- interface doctrine refined to make compliance architecturalized in core seams/contracts, with explicit app-boundary guarantee limits
- privacy/sovereignty language refined: patient sovereignty framed as governance/access control, while HealthOS remains infrastructure custodian
- topology vocabulary refined: single-node clarified as canonical bootstrap minimum; production projection clarified as operator-owned Apple Silicon sovereign health fabric (physically distributed, logically one)
- ADR 0009 added for topology vocabulary and single-node bootstrap framing
- ADR 0010 added for health-exclusive ontology and architecturalized compliance
- strategic regulatory backlog added (break-glass, legal retention vs visibility, regulatory audit pathways, assinatura digital qualificada, interoperability roadmap)
- first slice now derives typed referral and prescription drafts from the same session/SOAP/context spine, with persisted artifacts, events, and provenance while keeping both explicitly draft-only
- minimal Scribe surface + CLI now expose referral/prescription draft previews and statuses separately from SOAP draft, gate review, and finalized SOAP document state
- first-slice Scribe bridge upgraded with explicit command/result envelopes (session start, patient selection, capture submission, draft refresh, gate resolution)
- command results now carry explicit dispositions for complete/partial/degraded/deny/operational-failure outcomes
- CLI flow refactored to consume the envelope-based bridge API step-by-step instead of one implicit bridge call
- scaffold foundation created
- canonical architecture docs created
- ADR seed set created
- initial schemas created
- Swift / TypeScript / Python boundaries scaffolded
- initial SQL migration created
- execution layer created
- AI operating protocol and context bundle created
- AI skills index and domain skills created
- missing core governance schemas added for consent, habilitation, provenance, gate resolution, professional record, service membership, finality, and access policy
- core services architecture skeleton added
- ADR created for the initial local Swift/TypeScript seam
- glossary added to reduce ontology drift for future AI work
- schema governance audit completed
- ADR and doctrine added clarifying that HealthOS is not end-user UX; HealthOS/Tier4-Stages-Cast/AppDocs/interfaces own end-user UX
- canonical directory layout implemented in Swift
- explicit storage contract added to Swift core
- storage architecture document aligned to the storage contract
- core-law deny/failure semantics documented
- initial SQL migration reorganized with sections, notes, and invariant comments
- lawful-context examples added to storage architecture
- lawfulContext v1 decision recorded
- initial object-integrity/hash strategy documented
- runtime lifecycle formalized in docs, schema, Swift, and TypeScript
- actor/agent distinction formalized and typed
- AACI session model expanded with bounded meaning and path classes
- AACI subagent contracts substantially defined in docs and Swift
- agent boundary and descriptor schemas added
- runtime retry/backpressure baseline documented
- provider-routing baseline documented by task class
- provider threshold guidance documented by task class
- shared app state vocabulary expanded
- initial Stage flow maps expanded
- runtime-state surfacing doctrine documented
- screen-level contracts documented for the initial Stages
- operator observability contract documented
- operations runbook strengthened
- MeshProvider contract strengthened
- provider/ML governance made more procedural
- first vertical slice executable path documented
- first vertical slice core services, file-backed persistence, and CLI runner added
- first-slice executable spine refactored with typed envelopes/contracts for capture, transcription, retrieval, draft, gate outcome, and run summary
- first-slice session events upgraded to typed event model with explicit event kind and payload envelopes
- first-slice provenance recording made more consistent across transcription, retrieval, draft compose, gate resolve, and final document finalization
- minimal Scribe bridge contract + adapter added to consume the first-slice spine without moving law into the app layer
- first-slice bounded retrieval substrate added with typed query/match/result contracts and file-backed service-record index
- SessionRunner now uses deterministic bounded retrieval + provenance/event wiring instead of hardcoded synthetic context list
- Scribe bridge state now exposes retrieval source/status/match preview for future UI wiring
- shared HealthOS envelope vocabulary added for first-slice command/result semantics (`HealthOSCommandDisposition`, `HealthOSIssueCode`, `HealthOSFailureKind`, `HealthOSIssue`)
- Scribe bridge + CLI adapter migrated from ad hoc issue strings to shared typed issue/disposition semantics
- first-slice runner/adapter wiring extracted into shared Swift support target so CLI and app surfaces consume the same executable slice path
- minimal macOS SwiftUI Scribe surface added as `Scribe` with a small observable view model over `ScribeFirstSliceFacade`
- local validation now covers both `swift run HealthOSCLI` and `swift run Scribe --smoke-test`
- first slice now accepts seeded text or local audio file capture, persists local audio artifacts, and surfaces explicit transcription state (`ready` / `degraded` / `unavailable`)
- local validation now also covers `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff` and `swift run Scribe --smoke-test-audio`
- bounded retrieval now carries richer snippet/index/match metadata, deterministic score breakdown, and a structured `RetrievalContextPackage` between raw matches and AACI draft composition
- first-slice local context assembly now produces explicit `ready` / `partial` / `empty` / `degraded` states with summary/highlights/source hints for both CLI and Scribe
- local validation now confirms the strengthened retrieval/context path across CLI and Scribe seeded-text and local-audio smoke flows
- first-slice gate workflow now carries richer review semantics (review type, target, rationale, reviewer role/timestamp) and keeps gate rejection explicit without treating it as a technical crash
- SOAP draft and finalized SOAP document are now separate typed contracts with explicit lineage between source draft, gate request/resolution, and persisted final document
- minimal Scribe surface now shows draft preview, gate review summary, and finalized-document state/path as distinct truths
- local validation now also confirms explicit approve/reject semantics, including withheld final-document state on CLI rejection runs

- user sovereignty/User-Agent governance scaffold is now formalized in Swift Core + TS contracts with explicit `UserAgentScope`/`UserAgentRequest`/`UserAgentResponse` capability boundaries, fail-closed guards for prohibited clinical/regulatory capabilities, lawfulContext requirements, data-layer denial checks, and informational-only output disposition
- patient-facing governed surfaces are now typed for consent management, patient access-audit views, export request/status, and visibility-vs-retention summary with app-safe boundary validation (no raw CPF, no reidentification mapping by default, no raw storage-path leakage)
- Swift XCTest coverage now includes a dedicated `UserSovereigntyGovernanceTests` suite covering User Agent negative capability paths, lawfulContext enforcement, consent revocation governance, patient audit scoping/redaction, export policy denials, visibility-vs-retention separation, and Veridia app-boundary payload constraints

- service-operations / CloudClinic core-governance contract set is now formalized in Swift/TS/schema with explicit fail-closed validators for service context, membership roles, professional habilitation surface, patient-service relationship, operational queue, document/draft surface, gate worklist, and administrative task allowlist boundaries
- Swift XCTest coverage now includes dedicated Service Operations governance negatives/positives (`ServiceOperationsGovernanceTests`) covering lawfulContext/finalidade requirements, role/membership denials, habilitation expiry/inactive denials, patient-service non-bypass of consent, queue non-authorization semantics, draft/final gate protections, admin gate-resolution denials, and administrative-task governance guards

- cross-app coordination shared-surface contracts are now formalized in Swift Core with a common `AppSurfaceEnvelope`, typed app-safe safe-reference taxonomy, role/app-aware allowed-denied action contracts, redaction/deidentification posture contract, and app-safe notification/obligation surfaces
- cross-Boundary validator now fail-closes non-mediated actions, app/role mismatches, navigation-ref access grants, direct-identifier/reidentification defaults, sensitive notification payload leaks, and unrecorded patient-notification completion claims
- Swift XCTest coverage now includes dedicated cross-Boundary negatives/positives (`CrossAppCoordinationContractsTests`) for shared envelope safety, safe refs, role-aware action isolation across Scribe/Veridia/CloudClinic, redaction posture defaults, notification payload minimization, and obligation-record integrity
- TypeScript contract workspace and JSON Schema now mirror the cross-app shared-surface vocabulary (`AppSurfaceEnvelope`, safe refs, app actions, notifications/obligations)

- repository validation harness is now executable through `make validate-all` / `scripts/validate-local.sh`, chaining HealthOS/Shared/docs/schema/contract drift checks plus Swift/TS/Python checks and smoke commands with fail-closed non-zero exits and local summary artifact output (`HealthOS/Shared/runtime-data/validation/latest-validation-summary.txt`)
- Makefile validation gate coverage now includes `validate-docs`, `validate-schemas`, `validate-contracts`, `validate-all`, `smoke-cli`, `smoke-scribe`, and `python-check`, with legacy aliases preserved for compatibility (`python-compile`, `swift-smoke`)
- new docs drift checker (`scripts/check-docs.sh`) now verifies required execution docs, referenced doc paths, documented Make targets, stale "no tests configured" claims, and accidental un-negated production-ready wording
- new contract drift checker (`scripts/check-contract-drift.sh`) now enforces baseline cross-layer presence for critical schema/Swift/TS/SQL/runtime files, storage-layer vocabulary parity, runtime lifecycle state parity, and GOS lifecycle state presence
- schema harness (`scripts/validate-schemas.sh`) now validates JSON syntax for all files under `HealthOS/Tier1-Mestral-Core/Schemas/` and enforces critical governance/GOS schema presence

## In progress

- Scribe-first-slice runtime remains scaffold-level for partial flows: draft refresh still degrades honestly before full spine execution/gate resolution, and microphone capture remains placeholder-only
- first vertical slice implementation continues with seeded-text compatibility, a structured local retrieval/context package, richer gate/document semantics, draft-only referral/prescription derivatives, and a now-wired local-audio path, while real local transcription and earlier draft-refresh finalization remain deferred
- doctrinal language hardening completed for sovereignty/privacy/compliance/topology without introducing infrastructure expansion
- GOS now exists as doctrine + schema + authoring workspace + schema-aware compiler/validator/CLI + lifecycle/bundle posture + Swift runtime contracts + hardened loader seams + runtime-mediated first-slice adoption across capture/transcription/context/draft paths, while broader runtime adoption still remains open
- AACI now consumes an explicit resolved GOS runtime view across current first-slice execution paths, with actor/family-aware metadata and bounded runtime reasoning summaries rather than opaque active-bundle flags
- first-slice provenance now distinguishes bundle activation from bundle usage in transcription, context retrieval, SOAP draft composition, and derived-draft generation (`gos.use.transcription`, `gos.use.context.retrieve`, `gos.use.compose.soap`, `gos.use.derive.referral`, `gos.use.derive.prescription`)
- AACI now exposes a small runtime-agnostic/subagent-aware GOS mediation seam (`AACIGOSRuntimeResolver` + `AACIGOSMediationContext`) that resolves actor binding/fallback, primitive families, mediation posture flags, and bounded provenance operation names without exposing raw compiled spec payloads
- first-slice GOS usage provenance now also includes `gos.use.capture`, and the current capture/transcription/context/SOAP/referral/prescription paths consume the shared mediation context seam for runtime metadata instead of ad hoc per-path lookups
- smoke-level lifecycle ergonomics now include both review and reviewed→active promotion command paths (`swift run HealthOSCLI --gos-review-bundle ...`, `swift run HealthOSCLI --gos-promote-bundle ...`)
- scaffold validation coverage now includes in-repo Swift XCTest cases for AACI/registry/first-slice GOS paths (including lifecycle hardening assertions) plus executable Node tests for TS GOS tooling compile/cross-reference/bundle contracts

## Invariant Enforcement Status

- Draft finalization is now guarded by explicit typed enforcement (`missingGateApproval`, `invalidDraftFinalizationState`) before any SOAP final document write path executes.
- GOS file-backed activation now rejects inconsistent activation state with typed failures (`invalidActivationState`, `invalidBundleState`) before active-pointer mutation.
- AACI GOS runtime mediation now enforces core gate-required behavior for regulatory draft actors even if a bundle binding omits explicit human-gate primitive families.
- Swift tests now assert both finalization-without-approved-gate rejection and activation denial when competing active bundles exist.
- Swift tests now also assert active-only runtime load denial for deprecated bundles and preservation of known bundle history even when lifecycle transitions are denied.

## Known gaps

- Veridia and user-agent runtime remain contract-first scaffolds in this wave: no final UI shell, no chatbot behavior, and no clinical act pathways are implemented

- regulatory/interop/signature pathways remain scaffold-only: no RNDS/TISS endpoint delivery, no ICP-Brasil or qualified signature provider integration, and no production compliance claim
- async runtime remains local scaffold (in-memory executor + SQL contract shape); no distributed queue, worker mesh, or production scheduler is implemented in this wave
- language-model and speech providers remain stubbed for execution quality (no real external provider/API integration in this wave)
- provider provenance is now more explicit for routed execution metadata, but end-to-end cost/latency/quality reporting remains intentionally unimplemented (no fabricated benchmark/cost claims)
- model registry and fine-tuning governance are contractual scaffolds; they are not yet wired to a production artifact catalog or distributed promotion workflow
- microphone capture is not implemented yet; the current local-first audio path uses file selection/import
- local transcription remains stubbed, so audio capture degrades honestly instead of yielding fabricated transcript text
- bounded retrieval now uses a stronger local score (lexical/tag/recency/category/intent), but still stops well short of semantic retrieval or embeddings
- semantic retrieval/indexing remains scaffold-level governance only: no real embedding provider integration, no real vector index, and no fabricated semantic scores
- Scribe now has a minimal validation UI surface, but it is not yet a full/final app shell
- draft refresh remains preview/degraded until gate resolution runs the full executable spine
- referral/prescription drafts now exist, but their regulatory effectuation/issuance remains intentionally deferred
- richer operator policy governance (reviewer role authorization model, policy profile management, and distributed/multi-node review governance) remains open beyond current pragmatic hardening
- broader GOS adoption across AACI session modes remains partial (`[~]`): the generic mediation seam exists and is tested, but only the current first-slice runtime paths consume it so far

- CloudClinic Service Operations remains contract-first in this wave: no final CloudClinic UI shell and no persisted queue/task projection service yet

## Open blockers / decisions

- decide authorization and escalation policy depth for regulatory-audit approvals, emergency post-review workflows, and patient-notification dispatch integration (currently represented as obligations/contracts only)
- decide when to replace the current stubbed local transcription path with a real local Apple-first transcription provider
- decide whether the next first-slice step after this wave is microphone capture, moving draft/retrieval finalization earlier than gate resolution, or introducing lawful effectuation paths for referral/prescription
- decide when to convert the AI skills into enforced reusable workflows/templates
- decide when to replace the current deterministic local retrieval/context package with semantic/clinical retrieval while preserving lawful scope and topology-invariant governance constraints
- decide the long-term production policy envelope for reviewer authorization and multi-node activation governance beyond current local pragmatic hardening

## Tracking rules

Whenever a work unit ends, update:
- current phase if changed
- completed recently
- in progress
- known gaps
- open blockers / decisions

## Scaffold/foundation phase RC closure / final gap audit (2026-04-26)

- completed full-repo closure audit focused on scaffold readiness (not product readiness) and produced explicit closure criteria doc: `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`
- created final actionable residual gap register with category + impact + owner/module + validation expectation: `HealthOS/Shared/docs/execution/14-final-gap-register.md`
- created explicit finalization plan sequencing last closure actions, merge criteria, validation criteria, and next HealthOS maturity handoff: `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md`
- synchronized entry/read-order docs (`README.md`, `AGENTS.md`, `CLAUDE.md`, `HealthOS/Shared/docs/execution/README.md`) to include scaffold RC closure references and anti-overclaim posture
- synchronized maturity/handoff docs (`11-current-maturity-map.md`, `12-next-agent-handoff.md`) with closure classification and blocker-aware next task selection
- historical strict-closure blockers GAP-001 (cross-app adapter propagation) and GAP-002 (incident command set) are no longer active TODO blockers after APP-008 and OPS-003 evidence was reconciled; remaining work is tracked as post-scaffold/product maturity unless a future RC audit reclassifies it.

Validation executed in this work unit:
- `make validate-all` => PASS (local harness)
- `cd HealthOS && swift build && swift test` => PASS
- `cd HealthOS/Constructor/ts && npm install && npm run build && npm test --if-present` => PASS (workspace has no root test script; command exits clean)
- `cd python && python -m compileall .` => PASS
- `cd HealthOS && swift run HealthOSCLI && swift run Scribe --smoke-test` => PASS

- Project Steward evolved from deterministic checklist/prompt CLI to model-agnostic engineering orchestrator scaffold with optional providers (OpenAI/Anthropic/xAI/local-command), secure provider config schema/example, dry-run invocation path, invocation hashing logs, diff-aware PR review payload assembly, and explicit non-default PR comment posting (`--post-comment`)
- OPS-003: Incident-response command set for first operator tools (GAP-002) [COMPLETED]
- RT-008: Runtime-boundary tests for user-agent and service-runtime adapters (GAP-009) [COMPLETED]
- DS-007: LawfulContext and layer-guard parity beyond first-slice (GAP-003) [COMPLETED]
- APP-009: Documentation drift check for app-boundary maturity claims (T05) [COMPLETED]
- APP-009: Correct documentation drift for app-boundary maturity claims (GAP-006) [COMPLETED]
- AACI-009: Capability honesty signaling in AACI/Retrieval (GAP-009) [COMPLETED]
- CL-006: Shared error envelope for local service boundaries [COMPLETED]
- APP-008: Cross-app envelope propagation [COMPLETED]
- Scaffold/foundation phase RC 1 final validation: COMPLETED


## RT-MSR-001 — Implement ASLExecutor with real Claude API adapter (2026-04-29)

Objective: implement a provider-backed ASL stage executor in Mental Space Runtime without widening authority beyond derived, gated, non-authorizing artifacts.

Files touched:
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/Executors/ASLExecutor.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/MSRPipeline.swift`
- `HealthOS/Shared/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`

Invariants involved:
- Inv 1 — Core sovereignty
- Inv 17/22 — provider honesty and anti-fake posture
- Inv 43 — implementation is not production readiness

Validation:
- `cd HealthOS && swift build` PASS
- `cd HealthOS && swift test --filter MentalSpaceRuntimeTests` PASS
- `cd HealthOS && swift test --filter AsyncRuntimeGovernanceTests` PASS
- `cd HealthOS && swift test` PASS
- `make validate-docs` PASS
- `make validate-schemas` PASS
- `make validate-contracts` PASS
- `make validate-all` FAIL (`HealthOS/Constructor/ts/agent-infra/healthos-steward/tsconfig.json` has no `src/**/*.ts` inputs, causing `npm run build` to fail in `@healthos/steward`; unrelated to RT-MSR-001 Swift/doc changes).

Result:
- RT-MSR-001 complete for ASL stage: executor now loads canonical prompt resource, uses governed provider routing boundary, enforces fail-closed input/provider/response behavior, applies 10k-token chunking with batch size 3, parses structured JSON into typed `ASLArtifact`, and emits provenance operation marker `mental-space.asl`.

Residual gaps:
- VDLP remains scaffolded
- GEM remains scaffolded
- remote provider hardening/production concerns remain out of scope


## RT-MSR-002 — Implement VDLPExecutor with real Claude API adapter (2026-04-29)

Objective: implement provider-backed VDLP stage through `HealthOSProviders` with fail-closed ASL prerequisite checks, speech-only chunking, typed artifact output, and VDLP provenance marker.

Files touched:
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/Executors/VDLPExecutor.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/MSRPipeline.swift`
- `HealthOS/Shared/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`

Validation:
- `cd HealthOS && swift build`
- `cd HealthOS && swift test --filter MentalSpaceRuntimeTests`
- `cd HealthOS && swift test --filter AsyncRuntimeGovernanceTests`
- `cd HealthOS && swift test`
- `make validate-docs`
- `make validate-schemas`
- `make validate-contracts`
- `make validate-all`

Invariants involved:
- Inv 1 — Core sovereignty
- Inv 17/22 — provider honesty / anti-fake posture
- Inv 25a — Mental Space artifacts are derived/gated
- Inv 43 — implementation progress is not production readiness

Residual gaps:
- GEM still scaffolded
- Remote provider use remains explicit and governed
- Production hardening remains out of scope


## RT-MSR-003 — Implement GEMArtifactBuilder with real Claude API adapter (2026-04-29)

Objective: implement GEM stage as a provider-backed executor via HealthOSProviders while preserving fail-closed triad validation and non-authorizing derived artifact boundaries.

Files changed:
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/Executors/GEMArtifactBuilder.swift`
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/MSRPipeline.swift`
- `HealthOS/Shared/Tests/HealthOSTests/MentalSpaceRuntimeTests.swift`
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `HealthOS/Shared/docs/execution/todo/runtimes-and-aaci.md`

Validation run:
- `cd HealthOS && swift build`
- `cd HealthOS && swift test --filter MentalSpaceRuntimeTests`
- `cd HealthOS && swift test --filter AsyncRuntimeGovernanceTests`
- `cd HealthOS && swift test`
- `make validate-docs`
- `make validate-schemas`
- `make validate-contracts`
- `make validate-all` (fails due to pre-existing TypeScript steward workspace TS18003: no src/**/*.ts in HealthOS/Constructor/ts/agent-infra/healthos-steward/tsconfig.json)

Result: RT-MSR-003 implementation and targeted/full Swift validations passed; validate-all remains blocked by unrelated pre-existing TS workspace issue.

Invariants: Inv 1 (Core sovereignty), Inv 17/22 (provider honesty / anti-fake posture), Inv 25a (MSR artifacts derived and gated), Inv 43 (implementation progress != production readiness).

Residual gaps: Apple Foundation Models normalization separate; semantic retrieval separate; SQL async runtime separate; production provider hardening out of scope; STR-002 Skill macOS archival still pending.

## ST-011A — Align runtime taxonomy and Forge MCP naming with README architecture (2026-05-01)

- Objective: align runtime taxonomy and construction MCP naming doctrine with the current README architecture without changing runtime behavior.
- Files updated: `README.md`, `AGENTS.md`, `CLAUDE.md`, `HealthOS/Shared/docs/architecture/17-glossary.md`, `HealthOS/Shared/docs/architecture/20-runtime-operational-policy.md`, `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md`, `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md`, `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md`, `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md`, `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`, `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`, `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`, `HealthOS/Constructor/Steward/README.md`.
- Validation commands run: full ST-011A command set (`make validate-docs`, `make validate-schemas`, `make validate-contracts`, `make ts-build`, `make swift-build`, `make swift-test`, `make smoke-cli`, `make smoke-scribe`, `make smoke-veridia`, `make smoke-cloudclinic`, `make validate-all`) plus required grep diagnostics.
- Result: documentation/ontology alignment completed; no Swift/TS package/module rename, no runtime behavior change.
- Invariants: Inv 1 (Core sovereignty), Inv 43 (naming/ontology alignment does not imply production readiness), engineering-agent boundary invariants (construction tooling remains outside clinical/runtime hierarchy).
- Residual gaps: HealthOS Forge MCP is not implemented; `mcp-local` package path/metadata rename to `healthos-forge-mcp` remains future follow-up (ST-018A); HealthOS runtime MCP servers are not implemented; Service Runtime may need deeper implementation documentation; no runtime behavior changed.


## ST-014 — Deterministic Steward CLI inspect/next/list (2026-05-04)

Task: ST-014 — Deterministic Steward CLI inspect/next/list
Status: DONE
Commands added: `list <territories|settlers|settlements>`, `inspect <territory|settler|settlement> <id>`, `next`

Files created:
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/repo-root.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/list.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/inspect.ts`
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/next.ts`

Files updated:
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added list/inspect/next to StewardCommand type; updated runStewardCommand
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/cli.ts` — passes args slice to runStewardCommand
- `CLAUDE.md` — baseline note updated to list all 6 implemented commands
- `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — ST-014 marked DONE
- `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` — ST-014 entry updated

Smoke test results:
- `list territories`: 14 Territory records printed (id/name/maturity)
- `list settlers`: 9 Settler profiles printed (profile-id/territory-id/maturity)
- `list settlements`: st-012-settler-profile-registry [completed]
- `inspect territory core`: Territory/Name/Maturity/Canonical HealthOS/Shared/docs/Known gaps printed
- `inspect settler settler-core-law`: Settler/Territory/Maturity/Invariants(6)/Forbidden moves(6) printed
- `inspect settlement st-012-settler-profile-registry`: 30-line preview printed [completed]
- `next`: returned ST-014 as first TODO (correct pre-update; returns ST-015 post-update)
- `list bogus`: exits 1 with error message (PASS)
- `status`, `runtime`, `session`: original scaffold placeholders unchanged

Invariants: no model calls, no writes, no new npm dependencies, fail-closed on missing/malformed records, no clinical authority, no merge authority.
Maturity: implemented seam
Residual gaps: ST-015 (Prompt Generation Engine), ST-016 (Settlement Validation/PR Review Draft Engine), ST-017 (Derived Memory Builder), ST-018 (healthos-forge-mcp), ST-019 (Xcode/Codex/Claude integration instructions), ST-020 (generate APP-011 prompt) remain TODO.
