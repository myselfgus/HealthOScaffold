# TODO — Ops, network, providers, ML

## COMPLETED

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
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
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
- `ts/packages/healthos-steward/*`
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
- `ts/packages/healthos-steward/src/steward.ts`
- `ts/packages/healthos-steward/src/providers/xai.ts`
- `ts/packages/healthos-steward/test/cli.test.mjs`
- `ts/packages/healthos-steward/test/providers.test.mjs`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`

## READY

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
- optional provider adapter layer added under `ts/packages/healthos-steward/src/providers/*`
- provider config schema/example added under `.healthos-steward/providers/`
- dry-run safe routing + invocation logs (hash-based) implemented
- CLI expanded with `providers`, `ask`, `delegate`, and provider-aware `review-pr`/`prompt` flows
- provider tests and CLI tests added without real network/API usage
Files touched:
- `ts/packages/healthos-steward/*`
- `.healthos-steward/providers/*`
- `.healthos-steward/prompts/*`
- `docs/architecture/44-project-steward-agent.md`
- `docs/execution/skills/project-steward-skill.md`
- `docs/execution/02-status-and-tracking.md`
