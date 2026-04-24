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
- [~] some law-level invariants still need stronger contract wording

## 3. Data and storage
- [x] SQL foundation exists
- [x] filesystem/object-store concept exists
- [x] layered data model exists
- [x] de-identification / re-identification concept exists
- [x] canonical directory implementation in Swift exists
- [x] storage API contract exists explicitly
- [x] initial hash/integrity strategy is established
- [x] lawfulContext v1 decision is established

## 4. Runtime / actor / agent model
- [x] actor/agent distinction documented and typed
- [x] runtime set established (AACI, async, user-agent)
- [x] message/mailbox concept exists
- [x] lifecycle states formalized across docs, schema, Swift, and TypeScript
- [x] permission/boundary model established at scaffold level
- [x] retry/backpressure baseline exists
- [x] runtime-state surfacing doctrine exists

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
- [x] AACI activation/load seam established
- [x] first-slice runner now consumes optional active GOS bundles to mediate persisted draft content, metadata, events, and provenance
- [x] AACI runtime draft composition/referral/prescription now consume active GOS mediation directly inside orchestrator execution paths
- [x] AACI now derives a small resolved runtime GOS view (bundle + bound actors + primitive families) and uses it directly in draft metadata, event attributes, and bounded runtime reasoning summaries
- [x] first-slice provenance now records distinct GOS activation vs per-draft-path usage events for SOAP/referral/prescription composition, with actor-specific usage provenance on each draft path
- [x] minimal reviewed→active promotion helper is now available in file-backed registry and CLI command path
- [x] baseline automated tests now cover TS GOS tooling compile/cross-reference/bundle behavior, while Swift GOS activation/runtime-usage assertions are present in-repo and local runtime truth is additionally smoke-validated through `HealthOSCLI`
- [~] provenance-preserving compile output can still be enriched beyond the current source-hash/report baseline
- [~] activation/deprecation policy controls can still be deepened beyond current minimum hardening
- [~] deep execution-time adoption across additional AACI subagent paths remains to be completed

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
- [x] app-boundary consumption patterns for GOS-derived state are now documented

## 8. Networking / operations
- [x] topology doctrine refined: single-node as canonical bootstrap minimum, not system identity
- [x] production projection clarified as operator-owned Apple Silicon sovereign health fabric (physically distributed, logically one)
- [x] online-only mesh access posture made explicit
- [x] mesh/VPN posture established
- [x] launchd/backup/network docs scaffolded
- [x] runbook detail exists at meaningful baseline
- [x] MeshProvider abstraction has meaningful contract form
- [~] operator incident-command vocabulary can still be made more explicit

## 9. Providers / ML
- [x] provider abstraction established
- [x] offline ML boundary established
- [x] fine-tuning/adapters concept scaffolded
- [x] provider benchmark dimensions and routing outcomes exist
- [x] dataset governance and promotion/rollback baseline exists
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
- [x] minimal Scribe surface now reflects draft review, gate review, and finalized-document state separately
- [x] minimal Scribe surface now reflects referral/prescription draft-only previews separately from SOAP draft and finalized SOAP document state
- [~] local-audio transcription remains stubbed; a real Apple-first local provider is still deferred
- [~] retrieval quality is now deterministic lexical/tag/recency/category/intent bounded; semantic retrieval is intentionally deferred
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
- [~] GOS still needs deeper runtime adoption and operational hardening before heavy production use
