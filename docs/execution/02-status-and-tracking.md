# Status and tracking

## Current global status

Current phase: Controlled implementation — first vertical slice started

## Completed recently

## APP-009 — Documentation drift check for app-boundary claims (2026-04-27)

- app architecture docs now carry explicit "Scaffold posture / non-claims" sections for Scribe, Sortio, and CloudClinic
- interface doctrine doc (`19-interface-doctrine.md`) now includes scaffold-honest summary of all three app surfaces (Scribe minimal SwiftUI, Sortio/CloudClinic contract-first only)
- wording hardened across app docs to avoid implying final UI, production readiness, or real provider integration
- Scribe doc now clarifies scaffold-only status for microphone capture, transcription, semantic retrieval, and draft refresh
- Sortio doc now clarifies no final UI shell, no user-agent runtime wiring, and contract-first patient sovereignty surfaces
- CloudClinic doc now clarifies no final UI shell, no persisted queue/projection service, and contract-first service operations
- execution tracking (`02-status-and-tracking.md`) updated with APP-009 completion entry
Files touched:
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-sortio.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/todo/apps-and-interfaces.md`

## Steward provider hardening — typed errors and review comment formatter (2026-04-27)

- Steward provider `errorKind` union widened from 12 to 17 cases with documented operator-actionable categories: HTTP semantics now distinguish `auth` (401/403), `notFound` (404), `serverError` (5xx) and `rateLimited` (429); transport-layer failures now distinguish `networkUnavailable` (pre-response fetch failure) from `timeout` (`AbortSignal.timeout`/`AbortError`); payload-layer failures now distinguish `parseError` (JSON parse failure) from `payloadEmpty` (200 OK without extractable text)
- network-error classification no longer relies on substring matching of `error.message`; uses `error.name` (`TimeoutError`/`AbortError`) and `instanceof TypeError` to identify timeouts and `fetch failed` cases
- provider HTTP error responses now surface the provider-supplied human-readable message (`error.message` for OpenAI/xAI; nested `error.message` for Anthropic) instead of a generic status label
- response payload extraction now uses mode-aware extractors: OpenAI Responses walks `output_text` shortcut and `output[].content[].type === 'output_text'`; Anthropic Messages filters `content[]` to `type === 'text'` and ignores tool_use blocks; chatCompletions handles both string and array `message.content`
- payload-empty detection added: 200 OK with no extractable assistant text is reported as `errorKind: 'payloadEmpty'` rather than masquerading as a successful empty completion
- new `formatStewardReviewComment` produces a deterministic PR review comment body with HTML marker (`<!-- healthos-steward review -->`), provider/model/timestamp/policy-version header, and an explicit non-authority footer; throws on empty body so the steward never posts placeholder comments under any code path
- `agent review-pr --post-comment` now wraps the provider output through `formatStewardReviewComment` before posting; policy versions are read at post time from `.healthos-steward/policies/invariant-policy.yaml` and `pr-review-rubric.yaml`
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
- repository-scoped persistent steward memory/policy/prompt templates now exist at `.healthos-steward/` with explicit derived-index posture and no-secrets/no-clinical-payload constraints
- architecture/skill docs now document steward role/boundary (`docs/architecture/44-project-steward-agent.md`, `docs/execution/skills/project-steward-skill.md`) and agent entry docs now reference steward usage without replacing canonical execution docs
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
- pragmatic invariant enforcement matrix was added at `docs/execution/10-invariant-matrix.md`, including explicit constitutional invariants, real current enforcement, state-machine rules, test coverage, and hardening gaps (without claiming full formal proof)
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
- file-backed GOS lifecycle now persists explicit review approval records (`review-approval.json`) and append-only lifecycle audit records (`system/gos/audit.jsonl`) for review and activation transitions
- HealthOSCLI now exposes a minimal lifecycle path for `draft -> reviewed -> active` through `--gos-review-bundle` and `--gos-promote-bundle`, recording operator/reviewer identity and rationale
- Swift GOS lifecycle persistence is now schema-aligned in `snake_case` across manifest, registry entry, review record, and audit artifacts
- AACI now exposes a public, small resolved GOS runtime view (`bundle + workflow title + bound actors/families`) so runtime consumers do not need raw spec JSON or ad hoc dictionary access
- first-slice storage metadata and event attributes now derive directly from the AACI resolved GOS runtime view, carrying actor-specific primitive-family and reasoning-boundary context for SOAP/referral/prescription draft paths
- first-slice provenance now records GOS draft-path usage under the concrete composing actor ids (`aaci.draft-composer`, `aaci.referral-draft`, `aaci.prescription-draft`) instead of a generic `aaci.gos` actor marker
- TypeScript GOS tooling now has executable bundle-CLI coverage for canonical lifecycle artifacts (`manifest.json`, `spec.json`, `compiler-report.json`, `source-provenance.json`)
- local validation in this round explicitly confirmed the active-bundle path with `bash ./scripts/bootstrap-local.sh`, `npm run --workspace @healthos/gos-tooling test`, `swift test`, and `swift run HealthOSCLI --reject-gate`, including persisted GOS metadata and `gos.use.compose.*` provenance in `runtime-data/Users/Shared/HealthOS`
- local GOS closure validation is currently smoke-level end-to-end (`bootstrap-local`, TypeScript build, GOS validate/bundle, Swift build, HealthOSCLI smoke, HealthOSScribeApp `--smoke-test`), not production-readiness validation
- TypeScript GOS tooling was stabilized so schema resolution and strict typing now build cleanly, and canonical compiled metadata now conforms to compiled-schema constraints
- GOS file-backed registry/loader hardening now validates registry-pointer consistency, manifest/spec/compiler-report/source-provenance presence, compiler report pass/fail status, and runtime-binding-plan compatibility before activation
- AACI runtime now applies active GOS bundle mediation inside orchestrator draft composition/referral/prescription paths; runner-level draft mutation is no longer the primary mediation point
- first-slice now records explicit `gos.activate.failed` provenance when activation cannot be completed, instead of silently dropping runtime diagnosis
- HealthOSScribeApp now includes a headless smoke fallback for non-SwiftUI environments while keeping SwiftUI/macOS behavior intact
- first-slice runner now attempts optional GOS activation and uses the resulting active bundle to mediate persisted SOAP/referral/prescription drafts, storage metadata, event attributes, and provenance when an active bundle exists
- AACI activation now normalizes loader failures into typed runtime-consumable categories (`GOSLoadTypedError` + `GOSLoaderFailure`) while preserving underlying registry errors for diagnostics/tests
- GOS validator now performs minimal evidence-hook completeness checks for task and draft-output phases
- GOS app consumption patterns document added, clarifying what Scribe, Sortio, and CloudClinic may consume from GOS-driven runtime work
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
- generic GOS authoring workspace added under `gos/` with blank YAML template
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
- ADR and doctrine added clarifying that HealthOS is not end-user UX; apps/interfaces own end-user UX
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
- Scribe, Sortio, and CloudClinic flow maps expanded
- runtime-state surfacing doctrine documented
- screen-level contracts documented for Scribe, Sortio, and CloudClinic
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
- FirstSliceRunner now uses deterministic bounded retrieval + provenance/event wiring instead of hardcoded synthetic context list
- Scribe bridge state now exposes retrieval source/status/match preview for future UI wiring
- shared HealthOS envelope vocabulary added for first-slice command/result semantics (`HealthOSCommandDisposition`, `HealthOSIssueCode`, `HealthOSFailureKind`, `HealthOSIssue`)
- Scribe bridge + CLI adapter migrated from ad hoc issue strings to shared typed issue/disposition semantics
- first-slice runner/adapter wiring extracted into shared Swift support target so CLI and app surfaces consume the same executable slice path
- minimal macOS SwiftUI Scribe surface added as `HealthOSScribeApp` with a small observable view model over `ScribeFirstSliceFacade`
- local validation now covers both `swift run HealthOSCLI` and `swift run HealthOSScribeApp --smoke-test`
- first slice now accepts seeded text or local audio file capture, persists local audio artifacts, and surfaces explicit transcription state (`ready` / `degraded` / `unavailable`)
- local validation now also covers `swift run HealthOSCLI --audio-file /System/Library/Sounds/Glass.aiff` and `swift run HealthOSScribeApp --smoke-test-audio`
- bounded retrieval now carries richer snippet/index/match metadata, deterministic score breakdown, and a structured `RetrievalContextPackage` between raw matches and AACI draft composition
- first-slice local context assembly now produces explicit `ready` / `partial` / `empty` / `degraded` states with summary/highlights/source hints for both CLI and Scribe
- local validation now confirms the strengthened retrieval/context path across CLI and Scribe seeded-text and local-audio smoke flows
- first-slice gate workflow now carries richer review semantics (review type, target, rationale, reviewer role/timestamp) and keeps gate rejection explicit without treating it as a technical crash
- SOAP draft and finalized SOAP document are now separate typed contracts with explicit lineage between source draft, gate request/resolution, and persisted final document
- minimal Scribe surface now shows draft preview, gate review summary, and finalized-document state/path as distinct truths
- local validation now also confirms explicit approve/reject semantics, including withheld final-document state on CLI rejection runs

- user sovereignty/User-Agent governance scaffold is now formalized in Swift Core + TS contracts with explicit `UserAgentScope`/`UserAgentRequest`/`UserAgentResponse` capability boundaries, fail-closed guards for prohibited clinical/regulatory capabilities, lawfulContext requirements, data-layer denial checks, and informational-only output disposition
- patient-facing governed surfaces are now typed for consent management, patient access-audit views, export request/status, and visibility-vs-retention summary with app-safe boundary validation (no raw CPF, no reidentification mapping by default, no raw storage-path leakage)
- Swift XCTest coverage now includes a dedicated `UserSovereigntyGovernanceTests` suite covering User Agent negative capability paths, lawfulContext enforcement, consent revocation governance, patient audit scoping/redaction, export policy denials, visibility-vs-retention separation, and Sortio app-boundary payload constraints

- service-operations / CloudClinic core-governance contract set is now formalized in Swift/TS/schema with explicit fail-closed validators for service context, membership roles, professional habilitation surface, patient-service relationship, operational queue, document/draft surface, gate worklist, and administrative task allowlist boundaries
- Swift XCTest coverage now includes dedicated Service Operations governance negatives/positives (`ServiceOperationsGovernanceTests`) covering lawfulContext/finalidade requirements, role/membership denials, habilitation expiry/inactive denials, patient-service non-bypass of consent, queue non-authorization semantics, draft/final gate protections, admin gate-resolution denials, and administrative-task governance guards

- cross-app coordination shared-surface contracts are now formalized in Swift Core with a common `AppSurfaceEnvelope`, typed app-safe safe-reference taxonomy, role/app-aware allowed-denied action contracts, redaction/deidentification posture contract, and app-safe notification/obligation surfaces
- cross-app boundary validator now fail-closes non-mediated actions, app/role mismatches, navigation-ref access grants, direct-identifier/reidentification defaults, sensitive notification payload leaks, and unrecorded patient-notification completion claims
- Swift XCTest coverage now includes dedicated cross-app boundary negatives/positives (`CrossAppCoordinationContractsTests`) for shared envelope safety, safe refs, role-aware action isolation across Scribe/Sortio/CloudClinic, redaction posture defaults, notification payload minimization, and obligation-record integrity
- TypeScript contract workspace and JSON Schema now mirror the cross-app shared-surface vocabulary (`AppSurfaceEnvelope`, safe refs, app actions, notifications/obligations)

- repository validation harness is now executable through `make validate-all` / `scripts/validate-local.sh`, chaining docs/schema/contract drift checks plus Swift/TS/Python checks and smoke commands with fail-closed non-zero exits and local summary artifact output (`runtime-data/validation/latest-validation-summary.txt`)
- Makefile validation gate coverage now includes `validate-docs`, `validate-schemas`, `validate-contracts`, `validate-all`, `smoke-cli`, `smoke-scribe`, and `python-check`, with legacy aliases preserved for compatibility (`python-compile`, `swift-smoke`)
- new docs drift checker (`scripts/check-docs.sh`) now verifies required execution docs, referenced doc paths, documented Make targets, stale "no tests configured" claims, and accidental un-negated production-ready wording
- new contract drift checker (`scripts/check-contract-drift.sh`) now enforces baseline cross-layer presence for critical schema/Swift/TS/SQL/runtime files, storage-layer vocabulary parity, runtime lifecycle state parity, and GOS lifecycle state presence
- schema harness (`scripts/validate-schemas.sh`) now validates JSON syntax for all files under `schemas/` and enforces critical governance/GOS schema presence

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

- Sortio and user-agent runtime remain contract-first scaffolds in this wave: no final UI shell, no chatbot behavior, and no clinical act pathways are implemented

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

## Scaffold RC closure / final gap audit (2026-04-26)

- completed full-repo closure audit focused on scaffold readiness (not product readiness) and produced explicit closure criteria doc: `docs/execution/13-scaffold-release-candidate-criteria.md`
- created final actionable residual gap register with category + impact + owner/module + validation expectation: `docs/execution/14-final-gap-register.md`
- created explicit finalization plan sequencing last closure actions, merge criteria, validation criteria, and post-scaffold handoff: `docs/execution/15-scaffold-finalization-plan.md`
- synchronized entry/read-order docs (`README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/execution/README.md`) to include scaffold RC closure references and anti-overclaim posture
- synchronized maturity/handoff docs (`11-current-maturity-map.md`, `12-next-agent-handoff.md`) with closure classification and blocker-aware next task selection
- current explicit scaffold blockers for strict closure: GAP-001 (cross-app adapter propagation) and GAP-002 (incident command set)

Validation executed in this work unit:
- `make validate-all` => PASS (local harness)
- `cd swift && swift build && swift test` => PASS
- `cd ts && npm install && npm run build && npm test --if-present` => PASS (workspace has no root test script; command exits clean)
- `cd python && python -m compileall .` => PASS
- `cd swift && swift run HealthOSCLI && swift run HealthOSScribeApp --smoke-test` => PASS

- Project Steward evolved from deterministic checklist/prompt CLI to model-agnostic engineering orchestrator scaffold with optional providers (OpenAI/Anthropic/xAI/local-command), secure provider config schema/example, dry-run invocation path, invocation hashing logs, diff-aware PR review payload assembly, and explicit non-default PR comment posting (`--post-comment`)
- OPS-003: Incident-response command set for first operator tools (GAP-002) [COMPLETED]
- RT-008: Runtime-boundary tests for user-agent and service-runtime adapters (GAP-009) [COMPLETED]
- DS-007: LawfulContext and layer-guard parity beyond first-slice (GAP-003) [COMPLETED]
- APP-009: Documentation drift check for app-boundary maturity claims (T05) [COMPLETED]
- APP-009: Correct documentation drift for app-boundary maturity claims (GAP-006) [COMPLETED]
