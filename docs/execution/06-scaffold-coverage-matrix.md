# Scaffold coverage matrix

Legend:
- [x] established in scaffold
- [~] partially established / needs closure
- [ ] not yet established enough

## 1. Canonical system identity
- [x] HealthOS defined as the whole system
- [x] HealthOS explicitly defined as health-exclusive by ontology (not generic cloud + plugins)
- [x] AACI defined as runtime inside HealthOS
- [x] app/interface distinction established
- [x] architecturalized-compliance doctrine established (apps consume seams, do not reimplement law)
- [x] substrate/core/spec/runtime/agent/app hierarchy established
- [x] glossary added
- [x] interface doctrine established: HealthOS is not end-user UX; apps/interfaces are end-user UX

## 2. Core laws
- [x] user, service, professional record, membership, habilitation represented
- [x] consent represented as first-class object
- [x] gate request and gate resolution represented
- [x] gate workflow now carries explicit review type, finalization target, rationale, and reviewer metadata
- [x] provenance represented
- [x] deny/failure semantics explicitly documented for core services
- [x] lawfulContext contract now has reusable typed validation adapter (`LawfulContextValidator`) over existing map payloads
- [x] core law typed failure contract now includes explicit lawful-context/consent/habilitation/finality cases (`CoreLawError`)
- [~] some law-level invariants still need broader multi-runtime/global policy closure beyond current first-slice enforcement

## 3. Data and storage
- [x] SQL foundation exists
- [x] filesystem/object-store concept exists
- [x] layered data model exists
- [x] de-identification / re-identification concept exists
- [x] canonical directory implementation in Swift exists
- [x] storage API contract exists explicitly
- [x] initial hash/integrity strategy is established
- [x] lawfulContext v1 decision is established
- [x] file-backed storage now fail-closes governed get/list/audit paths with typed lawful-context validation and stronger audit context requirements
- [x] storage layer write enforcement now distinguishes direct identifiers / governance metadata / derived artifacts / reidentification mappings with explicit fail-closed guards
- [x] storage read audit now distinguishes direct-identifier access from common reads
- [x] reidentification governance scaffold now has explicit request/resolution/audit contracts with lawfulContext-based fail-closed checks
- [x] retrieval governance now has explicit query/policy/result contracts with fail-closed lawful-context/finality/patient-scope checks in Swift core
- [x] agent memory governance now has explicit scope contracts (user/professional/session/service/system/derived) with fail-closed scope/provenance/layer guards
- [x] semantic index/embedding governance now exists as scaffold contracts (status/placeholder/provenance/lawful-finalidade) without claiming real vector retrieval
- [~] deidentification/reidentification persistence remains scaffold-level (no production cryptographic key infrastructure yet)
- [x] backup/restore/retention/export/DR governance contracts now exist as executable Core scaffold types and validation guards in Swift (`BackupManifest`, `RestorePlan`, `RetentionPolicy`, `ExportRequest`, `DisasterRecoveryPlan`)
- [x] backup/restore/export governance now fail-closes on missing lawfulContext, direct-identifier/reidentification policy gaps, hash mismatch, missing restore manifest, and final-document lineage mismatch
- [x] backup/restore/export/retention/DR observability event taxonomy now includes `backup.*`, `restore.*`, `export.*`, `retention.*`, and `dr.*` event names with non-sensitive payload posture
- [~] backup encryption remains explicitly scaffolded (`scaffolded`/`required`/`notImplemented` status), without production KMS integration claims

## 4. Runtime / actor / agent model
- [x] actor/agent distinction documented and typed
- [x] runtime set established (AACI, async, user-agent)
- [x] message/mailbox concept exists
- [x] lifecycle states formalized across docs, schema, Swift, and TypeScript
- [x] permission/boundary model established at scaffold level
- [x] retry/backpressure baseline exists
- [x] runtime-state surfacing doctrine exists
- [x] async runtime now has typed job governance contracts (job kind taxonomy, lawful-context requirements, retry/backpressure policy, idempotency, and observability event taxonomy)
- [x] async runtime now has a minimal executable local executor with guarded lifecycle transitions, fail-closed sensitive-job checks, dead-letter flow, and operator control helpers
- [~] async runtime persistence/execution remains local scaffold-level (in-memory executor + SQL table shape); distributed queue/worker orchestration is intentionally not implemented

## 5. GOS (Governed Operational Spec)
- [x] GOS formally introduced as subordinate layer between HealthOS Core and runtimes
- [x] ADR established for GOS constitutional boundary and placement
- [x] architecture document established for GOS purpose, primitive families, compiler posture, and runtime posture
- [x] authoring/compiler architecture document established
- [x] runtime-binding architecture document established
- [x] lifecycle/storage architecture document established
- [x] app consumption patterns documented for Scribe, Sortio, and CloudClinic
- [x] canonical JSON schema established for compiled GOS form
- [x] lightweight authoring schema established for YAML source documents
- [x] bundle-manifest schema established for compiled-bundle lifecycle representation
- [x] primitive families explicitly declared: signal, slot, derivation, task, tool binding, draft output, guard, deadline, evidence hook, human gate requirement, escalation, scope requirement
- [x] app-boundary doctrine clarified so apps do not interpret GOS as sovereign law
- [x] authoring conventions for declarative YAML source form established
- [x] blank generic YAML authoring template added
- [x] TypeScript tooling package added for parse/canonicalize/schema-validate/cross-validate/CLI flows
- [x] cross-reference validation scaffold added
- [x] minimal evidence-hook completeness validation added
- [x] lifecycle state set and canonical bundle identity posture documented
- [x] Swift contracts established for compiled bundles, registry entries, bundle loader, bundle registry, and runtime binding plans
- [x] AACI default runtime binding plan scaffold established in Swift
- [x] minimal-functional file-backed runtime loader/registry established
- [x] loader/registry minimum hardening now checks active-pointer consistency, required bundle artifacts, compiler-report pass/fail status, and runtime-binding-plan compatibility
- [x] loader now fails with typed errors when registry entries are missing/corrupted, active pointers are missing but active candidates exist, or multiple known bundles are concurrently active for one spec
- [x] file-backed activation now enforces single-active-per-spec resolution by superseding previously active manifests when a different bundle is promoted
- [x] lifecycle transitions now enforce explicit policy-valid moves with typed invalid-transition failures rather than permissive state rewrites
- [x] AACI activation/load seam established
- [x] first-slice runner now consumes optional active GOS bundles to mediate persisted draft content, metadata, events, and provenance
- [x] AACI runtime draft composition/referral/prescription now consume active GOS mediation directly inside orchestrator execution paths
- [x] AACI now derives a small resolved runtime GOS view (bundle + bound actors + primitive families) and uses it directly in draft metadata, event attributes, and bounded runtime reasoning summaries
- [x] first-slice runtime adoption now also applies that resolved runtime GOS view to capture/transcription/context metadata, event attributes, and explicit non-draft provenance usage
- [x] first-slice provenance now records distinct GOS activation vs SOAP draft composition usage (`gos.use.compose.soap`) vs derived-draft generation usage (`gos.use.derive.referral`, `gos.use.derive.prescription`), with actor-specific usage provenance on each draft path
- [x] AACI resolved runtime GOS view now carries lifecycle/runtime-binding-plan identity and actor mediation flags used directly by SOAP/referral/prescription internal paths (`gosActorBound`, `gosDraftOutputBound`, `gosGateRequiredByBinding`, `gosDraftOnly`)
- [x] file-backed lifecycle now persists review approval records and append-only lifecycle audit records for bundle review/activation transitions
- [x] lifecycle persistence remains schema-aligned in `snake_case` across manifest, registry entry, review record, and audit artifacts
- [x] minimal reviewed→active promotion helper is now available in file-backed registry and CLI command path
- [x] minimal draft→reviewed review helper is now available in file-backed registry and CLI command path
- [x] baseline automated tests now cover TS GOS tooling compile/cross-reference/bundle behavior, and Swift XCTest now also covers lifecycle hardening paths (register/review/promote/activate, draft activation denial, revoked-load denial, revoke-pointer cleanup, non-active deprecate preservation)
- [x] TS GOS tooling automated tests now also cover CLI `validate`/`compile` success paths and explicit failure exits for evidence-hook completeness + cross-reference defects
- [x] Swift XCTest lifecycle hardening now also covers missing manifest/spec/compiler-report/source-provenance failures, unknown active-pointer bundle failures, and active-pointer cleanup on deprecating active bundles
- [x] Swift XCTest GOS/AACI/first-slice boundary coverage now verifies active-bundle and no-bundle execution, explicit gate.request/gate.resolve/finalize separation, and draft-only persistence under rejected human gate
- [x] Swift XCTest GOS/AACI/first-slice boundary coverage now also verifies ordered provenance transitions on approved paths (`gos.activate` → draft compose/derive → `gate.request` → `gate.resolve` → `document.finalize.soap`)
- [x] Swift XCTest GOS/AACI/first-slice boundary coverage now also verifies active GOS cannot bypass core habilitation/consent checks (inactive professional/patient still fail)
- [x] file-backed loader/registry now use typed lifecycle/registry/integrity failures for missing artifacts and invalid lifecycle transitions instead of generic NSError throws
- [x] AACI activation/load seam now maps registry/loader errors into explicit typed loader categories (`GOSLoadTypedError.failure`) while preserving underlying registry error context
- [x] AACI resolved GOS runtime metadata now exposes bounded diagnostics (`gosBindingCount`, `gosCompilerWarningCount`) alongside actor/family context without moving sovereign law into GOS/runtime
- [x] invariant enforcement layer now hard-fails on finalization without approved gate (`FirstSliceInvariantEnforcer`), invalid GOS activation state (`invalidActivationState`), invalid bundle lifecycle activation (`invalidBundleState`), and core-gate-required regulatory draft actors under AACI mediation
- [x] pragmatic invariant matrix now exists and maps constitutional invariants to concrete enforcement/tests/gaps (`docs/execution/10-invariant-matrix.md`)
- [x] Swift lifecycle hardening now includes explicit deprecated-bundle load denial under active-only load requirements and known-bundle history preservation checks on denied lifecycle transitions
- [~] provenance-preserving compile output can still be enriched beyond the current source-hash/report baseline
- [x] activation/review lifecycle now has pragmatic policy hardening (multi-review minimum, separation-of-duties checks, deterministic version/source/compiler/spec-hash pinning, and explicit denied/accepted lifecycle audit records)
- [~] activation/deprecation policy controls can still be deepened beyond current pragmatic hardening (reviewer authorization models, policy profiles, distributed governance)
- [~] deep execution-time adoption across AACI session modes remains partial: a generic mediation seam exists and is now wired for current first-slice runtime paths, but non-first-slice modes are still pending

## 6. AACI
- [x] purpose and boundaries established
- [x] session modes established with bounded meaning
- [x] hot/warm/cold path concept established
- [x] initial subagents established
- [x] subagent contracts substantially defined
- [x] provider-routing baseline exists by task class
- [x] provider-threshold policy exists by task class
- [x] AACI now explicitly described as primary early consumer of GOS
- [x] AACI now has a default GOS primitive-family binding map scaffold in Swift
- [x] AACI now has an activation seam for loading active GOS bundles
- [x] AACI now influences a real executable draft path through first-slice mediation when a bundle is active
- [x] AACI now has a small runtime-agnostic GOS mediation seam (`AACIGOSRuntimeResolver`, `AACIGOSMediationContext`, `AACIGOSProvenanceOperationResolver`) covering actor-binding lookup/fallback, mediation posture flags, and bounded `gos.use.*` operation naming
- [~] broader AACI mode adoption remains open: the seam is tested and reused by current capture/transcription/context/SOAP/referral/prescription first-slice paths, but other AACI session modes have not been implemented yet

## 7. Apps / interfaces
- [x] Scribe defined
- [x] Sortio defined
- [x] CloudClinic defined
- [x] app/core separation established
- [x] shared state vocabulary exists
- [x] primary flow maps exist for all three apps
- [x] runtime-state surfaces are defined
- [x] screen-level interaction contracts exist
- [x] first-slice-to-Scribe bridge contract exists (facade/state surface, no UI law ownership)
- [x] first-slice command/result envelopes are explicit for Scribe bridge actions
- [x] shared issue/disposition/failure vocabulary now backs first-slice command/result envelopes across core/adapter/CLI
- [x] minimal macOS SwiftUI Scribe validation surface now consumes the first-slice bridge without taking ownership of governance logic
- [x] minimal Scribe surface now exposes seeded-text and local-audio capture modes with explicit transcription state
- [x] minimal Scribe surface now exposes structured retrieval summary/highlights/source hints with explicit partial/empty/degraded context truth
- [x] Scribe professional workspace boundary now has explicit governed contracts for workspace context, session state machine, capture/transcription, retrieval/context, draft review, gate review, and final-document lineage surfaces
- [x] Scribe bridge state now exposes runtime-mediated professional `sessionState`, workspace context, and allowed-next-actions without granting app law decision power
- [x] Swift XCTest now includes dedicated Scribe workspace/session boundary negatives for habilitation/finalidade/patient gating, gate/finalization rules, degraded honesty, and sensitive app-boundary leak denials
- [x] app-boundary consumption patterns for GOS-derived state are now documented
- [x] Scribe bridge runtime-state boundary now has automated coverage confirming app state stays runtime-mediated and does not expose raw compiled GOS spec payloads
- [x] Scribe bridge now includes a dedicated runtime-mediated GOS app surface (`gosRuntimeState`) limited to lifecycle/spec-id/bundle-id/binding-source summaries plus provenance-facing/informational-only flags (no raw compiled spec or binding-plan payload exposure)
- [x] Scribe bridge GOS runtime app surface now carries an explicit non-authorizing flag (`legalAuthorizing = false`) so bundle/spec identifiers remain informational and provenance-facing only
- [x] Swift XCTest app-boundary coverage now verifies both active-GOS and no-active-GOS Scribe bridge paths return only safe GOS runtime surfaces while preserving gate-required + draft-only app semantics
- [x] user-agent/patient-sovereignty contracts now exist in Swift Core + TS contracts for capability scope, consent surface, patient audit surface, export request/status surface, visibility-vs-retention summaries, and Sortio interaction envelope boundaries
- [x] User Agent guard layer now fail-closes prohibited clinical/regulatory capabilities (`diagnose`, `prescribe`, `issue-referral`, `finalize-record`, `sign-document`, retention/habilitation bypass attempts), missing lawfulContext, denied sensitive layers, and non-informational outputs
- [x] Swift XCTest coverage now includes explicit patient sovereignty negative tests for consent revocation policy acknowledgements, cross-patient audit view denial, reidentification export denial-by-default, direct-identifier policy gates, and Sortio app-safe payload boundaries
- [x] service-operations/CloudClinic core contracts now exist in Swift+TS+schema for service context, membership roles, habilitation surface, patient-service relationship, operational queue, document/draft surface, gate worklist, and administrative task governance
- [x] Swift XCTest coverage now includes service-operations governance negatives/positives (lawfulContext/finality guards, role/membership denials, habilitation expiry/inactive denials, queue non-authorization, draft/final gate protections, admin gate-resolution denial, and admin-task allowlist enforcement)
- [x] cross-app shared app-surface envelope contract now exists (`AppSurfaceEnvelope`) with typed app kind, actor role, safe refs, allowed/denied actions, degraded issues, provenance/audit refs, redaction posture, and explicit `legalAuthorizing = false`
- [x] shared safe-reference taxonomy now exists across apps (`SafeUserRef`, `SafePatientRef`, `SafeProfessionalRef`, `SafeServiceRef`, `SafeSessionRef`, `SafeDraftRef`, `SafeGateRef`, `SafeArtifactRef`, `SafeExportRef`, `SafeAuditRef`, `SafeProvenanceRef`) with navigation-only/access-capability signaling
- [x] cross-app role/app-aware action policy guards now fail-closed on app mismatch, role mismatch, and non-core-mediated action refs
- [x] shared app-safe notification/obligation surface now exists with typed notification kinds and explicit obligation completion-record requirements
- [~] CloudClinic runtime adapter and persisted service-ops projections remain scaffold-level (contracts/validators only in this wave)

## 8. Networking / operations
- [x] topology doctrine refined: single-node as canonical bootstrap minimum, not system identity
- [x] production projection clarified as operator-owned Apple Silicon sovereign health fabric (physically distributed, logically one)
- [x] online-only mesh access posture made explicit
- [x] mesh/VPN posture established
- [x] launchd/backup/network docs scaffolded
- [x] runbook detail exists at meaningful baseline
- [x] MeshProvider abstraction has meaningful contract form
- [x] operator observability contract now includes async-job event and workload surfaces (retry/dead-letter visibility)
- [~] operator incident-command vocabulary can still be made more explicit

## 9. Providers / ML
- [x] provider abstraction established
- [x] provider capability profile contract established (kind/task/data-layer/privacy/network/latency/provenance/stub markers)
- [x] provider registration now rejects invalid/missing capability profiles
- [x] provider routing now returns typed outcomes (`selected`, `degradedFallback`, `deniedByPolicy`, `unavailable`, `stubOnly`) with typed denial reasons
- [x] remote fallback guard is fail-closed for direct identifiers/reidentification mapping and policy-missing/sensitive-content remote usage
- [x] embedding provider routing seam now exists with fail-closed policy denials for direct identifiers/reidentification mapping and explicit stub posture support
- [x] speech path honesty now preserves explicit degraded/unavailable truth when only stub STT exists (no fabricated transcript)
- [x] seeded-text path is explicitly separated from audio transcription provider execution metadata
- [x] offline ML boundary established
- [x] fine-tuning/adapters concept scaffolded
- [x] provider benchmark dimensions and routing outcomes exist
- [x] dataset governance and promotion/rollback baseline exists
- [x] model registry scaffold is now executable/testable with lifecycle guards (`draft/evaluated/promoted/deprecated/revoked`) and selection safeguards
- [x] fine-tuning governance scaffold is now executable/testable for dataset-version requirement, evaluation-gated promotion, and rollback contract
- [~] provider provenance is improved for routed execution metadata, but no measured cost/latency/quality telemetry exists yet
- [~] operator review checklist for promotions can still be added

## 10. AI execution layer
- [x] master plan created
- [x] AI operating protocol created
- [x] status tracking created
- [x] definition of done created
- [x] skills index exists and multiple domain skills exist
- [x] GOS backlog file added for compiler/runtime binding work
- [x] GOS authoring workspace added
- [x] GOS tooling package added to TypeScript workspace
- [~] skills can still be hardened into even more prescriptive reusable packs

## 11. First vertical slice readiness
- [x] slice target defined
- [x] slice dependency order defined
- [x] core-law failure semantics no longer block honest closure
- [x] storage and runtime baselines are strong enough for controlled implementation
- [x] app-state and interaction baselines are strong enough for controlled implementation
- [x] first-slice executable contracts are typed enough for app/runtime integration without ad hoc payload coupling
- [x] CLI consumes explicit bridge command/result envelopes instead of implicit single-call coupling
- [x] minimal SwiftUI Scribe surface consumes the same executable slice via shared support wiring
- [x] bounded file-backed retrieval substrate integrated into first slice executable spine
- [x] bounded retrieval now assembles a structured local clinical-operational context package before AACI draft composition
- [x] local audio file capture path is integrated into the first slice with persisted audio artifacts and explicit degraded transcription behavior
- [x] first slice now distinguishes draft SOAP snapshots from finalized SOAP documents with explicit source-draft and gate linkage
- [x] first slice now derives referral and prescription drafts as explicit draft-only artifacts linked to the same session/SOAP/context spine
- [x] first slice now also mediates those draft artifacts through an optional active GOS bundle when present
- [x] first slice now distinguishes and records GOS bundle activation separately from concrete draft-path usage in provenance
- [x] first slice now persists runtime-mediated GOS actor/family/reasoning-boundary metadata on SOAP/referral/prescription draft records when an active bundle exists
- [x] first slice now persists and records runtime-mediated GOS actor/family/reasoning-boundary context for transcription and context retrieval when an active bundle exists
- [x] minimal Scribe surface now reflects draft review, gate review, and finalized-document state separately
- [x] minimal Scribe surface now reflects referral/prescription draft-only previews separately from SOAP draft and finalized SOAP document state
- [~] local-audio transcription remains stubbed; a real Apple-first local provider is still deferred
- [~] retrieval quality is now deterministic lexical/tag/recency/category/intent bounded; semantic retrieval is intentionally deferred
- [~] semantic retrieval remains intentionally unavailable/degraded without real embedding provider and index implementation; lexical fallback is explicit and deterministic
- [~] referral/prescription effectuation remains intentionally out of scope; only draft derivation is established in this wave
- [~] a few procedural/operator details still remain optional hardening before heavy implementation

## Practical reading

The scaffold is no longer merely an outline.
It is a strong pre-implementation foundation.
What remains is mostly optional hardening and procedural refinement, not identity or architecture rescue work.

## 12. Doctrinal precision wave (sovereignty/compliance/topology)
- [x] patient sovereignty language refined to governance/control (without claiming full physical custody of bits)
- [x] privacy posture clarified as layered + pseudonymous + lawfulContext-mediated + core-visible operational data
- [x] topology vocabulary refined beyond ambiguous local-first framing
- [x] strategic regulatory backlog registered as future architecture expansion (not current implementation)

## 13. GOS doctrinal and tooling wave
- [x] HealthOS now has a named, native intermediate operational spec layer
- [x] that layer is explicitly subordinated to core law rather than competing with it
- [x] all declared GOS primitive families now exist in canonical schema form
- [x] GOS now also has authoring docs, runtime-binding docs, lifecycle docs, app-consumption docs, a generic YAML template, an authoring schema, a bundle-manifest schema, TypeScript tooling scaffold, and Swift runtime contracts
- [~] GOS still needs broader runtime adoption and richer lifecycle policy hardening before heavy production use

## 14. Regulatory / interoperability / signature / emergency governance
- [x] regulatory-audit scaffold now has governed contracts with fail-closed validation for legal basis, rationale, scope, lawfulContext, core mediation, and data-layer minimization
- [x] emergency/break-glass scaffold now has governed request+grant contracts with mandatory rationale/scope/duration, expirability, post-review obligation, patient-notification obligation, and AACI/GOS authority denial
- [x] retention-vs-visibility governance now has explicit contractual separation for legal retention obligation, patient visibility/export, service custody, deletion eligibility, and anonymization eligibility
- [x] digital-signature scaffold now enforces honest legal status (`unsigned` / `signature_requested` / placeholder states) and rejects signature flow without final-document lineage, approved gate, and document hash
- [x] interoperability scaffold now models FHIR/RNDS/TISS as profile adapters/packages with source refs/hashes/provenance and placeholder-only external delivery (no real endpoint integration)
- [x] legal/probative lineage now has explicit contract fields for source draft, gate request/resolution, final document ref/hash, signer metadata, signature envelope placeholder, provenance chain, retention class, and export/audit package refs
- [x] observability taxonomy now includes `regulatory.audit.*`, `emergency_access.*`, `retention.visibility_decision`, `signature.*`, and `interoperability.*` event kinds with non-sensitive payload posture
- [~] SQL persistence is scaffold-level only for new governance tables; no production RBAC/approval workflow engine is wired yet
- [~] cross-runtime adoption is partial: contracts and tests are in Core, while runtime/app/operator surfaces still consume previous governance set by default
