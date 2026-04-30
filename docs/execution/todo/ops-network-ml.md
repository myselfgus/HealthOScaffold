# TODO — Ops, network, providers, ML

## COMPLETED

### ST-001a README and repository roots for Settler/Territory scaffolds
Outcome:
- README now names Steward, Settlers, Settlements, and Territories as repository engineering concepts outside the HealthOS clinical/runtime hierarchy
- diagrams and repository maps include `.healthos-steward/`, `.healthos-settler/`, and `.healthos-territory/` as engineering surfaces
- `.healthos-settler/` and `.healthos-territory/` exist as documentation-only roots for future profile, Settlement, and Territory records
- tracker 19 records the scaffolded roots and keeps executable Settlers, Settlement schema, Territory records, Territory loader, and `healthos-mcp` as future work
Files touched:
- `README.md`
- `.healthos-settler/*`
- `.healthos-territory/*`
- `docs/architecture/47-steward-settler-engineering-model.md`
- `docs/execution/19-settler-model-task-tracker.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/todo/ops-network-ml.md`

### OPS-004 Clarify online-only mesh doctrine and sovereign fabric projection
Outcome:
- networking/mesh doctrine now states online-only access posture and rejects offline-mode drift
- topology vocabulary now distinguishes single-node bootstrap minimum from sovereign fabric production projection
Files touched:
- `docs/architecture/04-networking.md`
- `docs/architecture/15-mesh-provider.md`
- `docs/adr/0009-single-node-bootstrap-and-sovereign-fabric-topology.md`

### OPS-001 Define single-node runbook
Outcome:
- operations runbook strengthened with bootstrap, daily/weekly checks, incident categories, and operator visibility surfaces
Files touched:
- `docs/architecture/14-operations-runbook.md`

### NET-001 Define MeshProvider abstraction and access policy
Outcome:
- MeshProvider contract strengthened with identity, ACL, health, and failure posture expectations
Files touched:
- `docs/architecture/15-mesh-provider.md`
- `ops/network/*`

### OPS-002 Define operator dashboards/minimum observability contract
Outcome:
- minimum operator visibility indicators and alert classes defined
Files touched:
- `docs/architecture/26-operator-observability-contract.md`
- `docs/architecture/14-operations-runbook.md`

### ML-001 Define provider benchmark and selection policy
Outcome:
- provider routing baseline, benchmark dimensions, task-class policy outcomes, and benchmark harness artifacts documented
Files touched:
- `docs/architecture/16-providers-and-ml.md`

### ML-002 Define fine-tuning governance
Outcome:
- dataset governance, adapter promotion path, rollback rule, and offline-only specialization posture documented
Files touched:
- `docs/architecture/16-providers-and-ml.md`
- `python/README.md`
- `python/healthos_ml/*`

### ML-003 Define benchmark threshold policy by task class
Outcome:
- explicit threshold guidance added by task class for provider selection decisions
Files touched:
- `docs/architecture/27-provider-threshold-policy.md`
- `docs/architecture/16-providers-and-ml.md`

### ML-004 Harden provider governance contracts and routing safety scaffolds
Outcome:
- provider capability profile contract added with typed validation gates at provider registration
- provider routing evolved to typed policy outcomes/denial reasons with local-vs-remote + data-layer aware checks
- remote fallback guard now fails closed for sensitive layers without explicit policy
- model registry and fine-tuning governance scaffolds are now executable/testable contracts (without claiming production catalogs/trainers)
- speech path now preserves honest degraded/unavailable behavior for stub STT and keeps seeded-text provenance distinct
Files touched:
- `swift/Sources/HealthOSProviders/ProviderProtocols.swift`
- `swift/Sources/HealthOSProviders/StubProviders.swift`
- `swift/Sources/HealthOSProviders/ModelGovernance.swift`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `swift/Sources/HealthOSCore/FirstSliceContracts.swift`
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `swift/Tests/HealthOSTests/ProviderGovernanceTests.swift`
- `docs/architecture/16-providers-and-ml.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`

### OPS-005 Establish governed backup/restore/retention/export/DR contracts
Outcome:
- backup/restore/retention/export/disaster-recovery governance contracts added in Swift Core with fail-closed validation for lawfulContext, sensitive-layer policy, integrity hashes, conflict handling, lifecycle safety, and final-document lineage
- observability taxonomy extended with backup/restore/export/retention/DR event kinds without leaking direct identifiers
- executable XCTest suite added for mandatory negative/positive governance checks and AACI/GOS control-plane boundary denials
Files touched:
- `swift/Sources/HealthOSCore/BackupGovernance.swift`
- `swift/Tests/HealthOSTests/BackupGovernanceTests.swift`
- `schemas/contracts/backup-restore-retention-export-dr-governance.schema.json`
- `ts/packages/contracts/src/index.ts`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`


### OPS-006 Harden regulatory/interoperability/signature/emergency governance scaffold
Outcome:
- new Core contracts/validators added for regulatory audit pathways, emergency/break-glass access, retention-vs-visibility governance, digital-signature scaffold, interoperability package scaffold, and legal/probative lineage guards
- regulatory observability taxonomy expanded with explicit non-sensitive event kinds (`regulatory.audit.*`, `emergency_access.*`, `retention.visibility_decision`, `signature.*`, `interoperability.*`)
- SQL scaffold metadata tables added for regulatory audit requests, emergency access requests, digital signature requests, and interoperability packages (placeholder-only delivery posture)
- executable Swift XCTest suite added for mandatory negative/positive boundary checks (`RegulatoryGovernanceTests`)
Files touched:
- `swift/Sources/HealthOSCore/RegulatoryGovernance.swift`
- `swift/Tests/HealthOSTests/RegulatoryGovernanceTests.swift`
- `schemas/contracts/regulatory-interoperability-signature-emergency-governance.schema.json`
- `ts/packages/contracts/src/index.ts`
- `sql/migrations/001_init.sql`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`

### ML-006 Project Steward agent runtime conceptual correction and provider hardening closure
Outcome:
- separated deterministic Steward Core commands from provider-backed Agent Runtime commands
- restricted primary internal LLM providers to openai/anthropic/xai/disabled and removed codex/claude internal-provider posture from examples
- reinforced explicit network gating (`--allow-network`) and explicit provider requirement for agentic commands
Files touched:
- `ts/agent-infra/healthos-steward/*`
- `.healthos-steward/providers/*`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`

### ML-007 Complete Steward provider hardening validation closure
Outcome:
- restored deterministic `healthos-steward next-task` command (non-deprecated) for offline/core task scaffolding
- hardened provider adapters with consistent dry-run-disabled behavior, HTTP error classification, and shared output extraction for OpenAI/Anthropic/xAI
- PR review posting now writes the real provider output only when invocation succeeds; no placeholder comment is posted on failure
- provider unit tests now mock `fetch` for OpenAI/Anthropic/xAI real invocation paths without live network
Files touched:
- `ts/agent-infra/healthos-steward/src/steward.ts`
- `ts/agent-infra/healthos-steward/src/providers/xai.ts`
- `ts/agent-infra/healthos-steward/test/cli.test.mjs`
- `ts/agent-infra/healthos-steward/test/providers.test.mjs`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`

### ML-012 Hard reset `@healthos/steward` and recreate the package baseline from scratch
Outcome:
- deleted the prior package implementation (`src`, `test`, `dist`) instead of carrying forward compatibility or `legacy` layers inside the package
- rebuilt `ts/agent-infra/healthos-steward/` from zero with a new minimal baseline around runtime requests, sessions, session persistence, and CLI surface identity
- created `.healthos-steward/memory/sessions/` as the first runtime-owned state location for the new steward
- rewrote the initiative tracker so future work continues from the clean reset rather than from the removed provider-centric runtime
Files touched:
- `ts/agent-infra/healthos-steward/src/*`
- `ts/agent-infra/healthos-steward/test/runtime.test.mjs`
- `ts/agent-infra/healthos-steward/package.json`
- `ts/agent-infra/healthos-steward/README.md`
- `docs/execution/18-healthos-xcode-agent-task-tracker.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/ops-network-ml.md`

### ML-011 Create Xcode Agent initiative tracker and land first runtime-core code
Outcome:
- dedicated initiative tracker added at `docs/execution/18-healthos-xcode-agent-task-tracker.md` with streams, active queue, open decisions, and per-work-unit continuity rules
- first runtime-centric TypeScript files landed under `ts/agent-infra/healthos-steward/src/agent/` defining session, surface, tool, backend, policy, and runtime contracts
- package root now exports the first agent runtime API surface, keeping the implementation additive and compatible with the current steward scaffold
- minimal runtime helpers landed for session creation, policy evaluation, and non-provider-centric request handling
- initial test scaffold added for future package build/test validation
Files touched:
- `docs/execution/18-healthos-xcode-agent-task-tracker.md`
- `ts/agent-infra/healthos-steward/src/agent/*`
- `ts/agent-infra/healthos-steward/src/index.ts`
- `ts/agent-infra/healthos-steward/test/agent-runtime.test.mjs`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/ops-network-ml.md`

### ML-010 Define target architecture for HealthOS Xcode Agent and migration path
Outcome:
- target architecture documented for evolving Project Steward into a repository-aware engineering agent centered on runtime, sessions, tools, and conversation surfaces instead of provider invocation
- explicit migration plan added for runtime extraction, model-backend reframing, CLI conversation mode, Xcode-native conversation surface, and optional frontend surface
- current steward docs and handoff entrypoints updated so future work does not accidentally keep reinforcing the old provider-centric abstraction
Files touched:
- `docs/architecture/44-project-steward-agent.md`
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`
- `.healthos-steward/README.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/ops-network-ml.md`

### ML-009 De-alias steward agent commands and restore provider config precedence
Outcome:
- `providers.json` is now part of the real config resolution chain instead of being skipped when no local override exists
- disabled/unsupported non-invokable provider kinds no longer masquerade as a runnable local `echo` fallback
- `agent handoff`, `agent generate-codex-prompt`, and `agent sync-memory` now run distinct prompt/template paths instead of silently delegating to `plan-next`
- deterministic Codex prompt surfaces now read `codex-next-task.md` rather than the generic model next-task prompt
- coverage added for config precedence, fail-closed disabled provider behavior, and command de-aliasing in dry-run mode
Files touched:
- `ts/agent-infra/healthos-steward/src/providers/router.ts`
- `ts/agent-infra/healthos-steward/src/steward.ts`
- `ts/agent-infra/healthos-steward/test/cli.test.mjs`
- `ts/agent-infra/healthos-steward/test/providers.test.mjs`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/ops-network-ml.md`

### ML-008 Steward provider error taxonomy and review comment formatting
Outcome:
- expanded `StewardLLMFailure['errorKind']` union with operator-actionable HTTP categories (`auth`, `notFound`, `serverError`, `rateLimited`, `badRequest`), pre-response transport categories (`networkUnavailable`, `timeout`), and payload categories (`parseError`, `payloadEmpty`); kept the existing union members backward-compatible
- replaced fragile `error.message` substring matching with `error.name`-based classification (`TimeoutError`/`AbortError` for timeout; `instanceof TypeError` for pre-response fetch failure)
- added mode-aware response extractors: OpenAI Responses walks `output[].content[]` filtered by `type === 'output_text'` (with `output_text` shortcut still preferred); Anthropic Messages walks `content[]` filtered by `type === 'text'` so tool_use/tool_result blocks no longer leak into review text; chatCompletions handles both string and array `message.content`
- 200 OK responses with no extractable assistant text now surface as `errorKind: 'payloadEmpty'` and `status: 'providerError'` instead of pretending to be a successful empty completion
- HTTP error responses now extract the provider-supplied human-readable message (`error.message` for OpenAI/xAI shape; nested `error.message` for Anthropic shape) and surface it as `errorMessage`
- added `formatStewardReviewComment` that produces a deterministic PR review body with HTML marker (`<!-- healthos-steward review -->`), provider/model/timestamp/policy-version header, and an explicit non-authority footer; refuses empty body so no placeholder comment is ever posted
- `agent review-pr --post-comment` now wraps provider output through `formatStewardReviewComment` and reads policy versions from `.healthos-steward/policies/*.yaml` at post time
- `StewardAgentRuntime` now memoizes the provider router instead of recreating it per invocation
- `node:test` coverage increased from 12 to 33 cases without live network, asserting every new errorKind branch and the formatter contract
Files touched:
- `ts/agent-infra/healthos-steward/src/providers/types.ts`
- `ts/agent-infra/healthos-steward/src/providers/utils.ts`
- `ts/agent-infra/healthos-steward/src/providers/openai.ts`
- `ts/agent-infra/healthos-steward/src/providers/anthropic.ts`
- `ts/agent-infra/healthos-steward/src/providers/xai.ts`
- `ts/agent-infra/healthos-steward/src/steward.ts`
- `ts/agent-infra/healthos-steward/test/providers.test.mjs`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/16-next-10-actions-plan.md`
- `docs/execution/todo/ops-network-ml.md`
- `.healthos-steward/memory/project-state.json`

## COMPLETED (WS-1)

### WS-1 Instructions and skills consolidation (Steward for Xcode — Phase B)
Outcome:
- CLAUDE.md and AGENTS.md updated: canonical Steward naming, Steward for Xcode posture, healthos-mcp boundary doctrine, deterministic baseline commands, stale StewardCore/StewardAgentRuntime references removed
- README.md Steward section updated to canonical naming and Steward for Xcode posture
- docs/execution/skills/project-steward-skill.md rewritten: canonical naming table, updated scope/reads/invariants/validation, healthos-mcp two-family boundary doctrine
- docs/architecture/45-healthos-xcode-agent.md: MCP two-family boundary note added to MCP section
- docs/execution/17-healthos-xcode-agent-migration-plan.md: WS-2 boundary constraint added
- Follow-up (2026-04-29): Codex external executor posture added for Steward-scoped Xcode-facing repository maintenance, with local automation registered at `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`; this is PR-based maintenance only and does not create a new Steward authority category.
Files touched:
- `CLAUDE.md`
- `AGENTS.md`
- `README.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/ops-network-ml.md`

### STR-002 Archive `Skill macOS/` to `docs/reference/mental-space-legacy/`
Priority: **P1** — do after RT-MSR-003 is DONE
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → STR-002
Definition of done:
- `git mv "Skill macOS" docs/reference/mental-space-legacy` preserves full history
- `docs/reference/mental-space-legacy/README.md` created, marks scripts as archived reference
- `docs/architecture/49-mental-space-runtime.md` updated: `Skill macOS/` → `docs/reference/mental-space-legacy/`
- `make validate-docs && make validate-all` PASS
Branch: `feat/str-002-archive-skill-macos`

### STR-003 Separate AGENT packages from PRODUCT in `ts/packages/` (DONE 2026-04-29)
Priority: **P1** — independent, can run parallel to STR-002
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → STR-003
Definition of done:
- `ts/agent-infra/` created; `healthos-steward` and `mcp-local` moved there via `git mv`
- npm workspace (`ts/package.json`) includes both `"packages/*"` and `"agent-infra/*"`
- `CLAUDE.md`, `README.md`, `docs/architecture/45-healthos-xcode-agent.md`, `docs/execution/17-healthos-xcode-agent-migration-plan.md` path references updated
- `make ts-build && make validate-docs && make validate-all` PASS
Completion note: moved `healthos-steward` and `mcp-local` into `ts/agent-infra/` with `git mv`, resolved steward TS build input blocker with minimal `src/` entrypoints, and updated affected path references/documentation without changing HealthOS clinical/runtime behavior.
Branch: `feat/str-003-ts-agent-infra-dir`

### STR-004 Rename `HealthOSFirstSliceSupport` → `HealthOSSessionRuntime`
Priority: **P1** — independent, can run parallel to STR-002 and STR-003
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → STR-004
Definition of done:
- `swift/Sources/HealthOSFirstSliceSupport/` renamed to `swift/Sources/HealthOSSessionRuntime/`
- `Package.swift` updated; all imports updated in CLI, ScribeApp, and test targets
- Primary public types renamed (at minimum: `FirstSliceRunner` → `SessionRunner`, `ScribeFirstSliceAdapter` → `ScribeSessionAdapter`)
- `swift build` PASS; `swift test` PASS (all existing tests pass, no regression); `make validate-all` PASS
- `grep -r "HealthOSFirstSliceSupport" swift/` → no results
Branch: `feat/str-004-session-runtime-rename`

### STR-005 Add placeholder Swift executable targets for Sortio and CloudClinic
Priority: **P2** — after P1 complete or in parallel
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → STR-005
Definition of done:
- `swift/Sources/HealthOSSortioApp/SortioEntrypoint.swift` created (minimal `@main` with `--smoke-test` flag)
- `swift/Sources/HealthOSCloudClinicApp/CloudClinicEntrypoint.swift` created (same pattern)
- `Package.swift`: both added as `.executableTarget` products
- `swift run HealthOSSortioApp --smoke-test` exits 0
- `swift run HealthOSCloudClinicApp --smoke-test` exits 0
- `swift build && swift test` PASS; `make validate-all` PASS
Branch: `feat/str-005-sortio-cloudclinic-targets`

### CI-001 Wire `make validate-all` into GitHub Actions
Priority: **P4** — after P0–P2 complete
Plan: `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → CI-001
Definition of done:
- `.github/workflows/validate.yml` runs `make validate-all` on push/PR to main
- `.github/workflows/swift-test.yml` runs `make swift-test` on macOS runner with Swift 6.2
- PRs with failing validation cannot be merged (branch protection)
- No secrets or clinical data in CI logs
Branch: `feat/ci-001-github-actions-validate`

### WS-2 Local MCP server (healthos-mcp)
Priority: Medium
Docs: `docs/execution/17-healthos-xcode-agent-migration-plan.md` (WS-2), `docs/architecture/45-healthos-xcode-agent.md`
Objective:
- build a local MCP server exposing typed HealthOS repository operations to Xcode Intelligence or compatible MCP client
Files:
- new package (location TBD, likely under `ts/packages/`)
Dependencies:
- Phase A (ARCH-001) complete; WS-1 recommended first
Definition of done:
- Xcode Intelligence or compatible MCP client can invoke typed HealthOS repository operations
- typed errors, dry-run support, fail-closed posture present
- no secrets in logs, no clinical payloads in operations
- operations do not move HealthOS Core law into tooling

### WS-3 Deterministic CLI consolidation
Priority: Medium
Docs: `docs/execution/17-healthos-xcode-agent-migration-plan.md` (WS-3), `docs/architecture/45-healthos-xcode-agent.md`
Objective:
- preserve the current hard-reset baseline (`status`, `runtime`, `session`) while expanding it deliberately into deterministic CI-safe repository operations
- remove provider orchestration as the primary architectural path
Files:
- `ts/agent-infra/healthos-steward/src/*`
- `ts/agent-infra/healthos-steward/package.json`
- `ts/agent-infra/healthos-steward/README.md`
- `README.md`
- `.healthos-steward/README.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/15-scaffold-finalization-plan.md`
Dependencies:
- Phase A (ARCH-001) complete
Definition of done:
- CLI runs deterministic operations without LLM dependency
- CLI works in CI/GitHub Actions
- docs distinguish current delivered baseline from planned deterministic operations
- deterministic repository-maintenance commands beyond `status`/`runtime`/`session` are added only when implemented and validated
- provider-centric orchestration is no longer the primary entry point
- `make validate-docs` and `make ts-build` pass

### OPS-003 Define incident-response command set for first operator tools
Priority: High
Skill: `docs/execution/skills/network-fabric-skill.md` + `docs/execution/skills/backup-restore-retention-export-skill.md`
Objective:
- list canonical operator actions for runtime failure, queue saturation, backup concern, and integrity incident handling
Files:
- `docs/architecture/14-operations-runbook.md`
- `docs/architecture/26-operator-observability-contract.md`
Dependencies:
- OPS-001, OPS-002
Definition of done:
- first operator tooling can map visible incidents to explicit action vocabulary

## TESTS / VALIDATION

- no public data service exposure by default
- restore path is documented
- ML pipeline remains offline boundary, not accidental production runtime

### ML-005 Extend Project Steward with model-agnostic provider orchestration (OpenAI/Anthropic/xAI + local-command)
Outcome:
- optional provider adapter layer added under `ts/agent-infra/healthos-steward/src/providers/*`
- provider config schema/example added under `.healthos-steward/providers/`
- dry-run safe routing + invocation logs (hash-based) implemented
- CLI expanded with `providers`, `ask`, `delegate`, and provider-aware `review-pr`/`prompt` flows
- provider tests and CLI tests added without real network/API usage
Files touched:
- `ts/agent-infra/healthos-steward/*`
- `.healthos-steward/providers/*`
- `.healthos-steward/prompts/*`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`
