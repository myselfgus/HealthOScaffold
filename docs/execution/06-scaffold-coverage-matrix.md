# Scaffold coverage matrix

Legend:
- [x] established in scaffold
- [~] partially established / needs closure
- [ ] not yet established enough

## 1. Canonical system identity
- [x] HealthOS defined as the whole system
- [x] AACI defined as runtime inside HealthOS
- [x] app/interface distinction established
- [x] substrate/core/runtime/agent/app hierarchy established
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

## 5. AACI
- [x] purpose and boundaries established
- [x] session modes established with bounded meaning
- [x] hot/warm/cold path concept established
- [x] initial subagents established
- [x] subagent contracts substantially defined
- [x] provider-routing baseline exists by task class
- [x] provider-threshold policy exists by task class

## 6. Apps / interfaces
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

## 7. Networking / operations
- [x] local-first stance established
- [x] mesh/VPN posture established
- [x] launchd/backup/network docs scaffolded
- [x] runbook detail exists at meaningful baseline
- [x] MeshProvider abstraction has meaningful contract form
- [~] operator incident-command vocabulary can still be made more explicit

## 8. Providers / ML
- [x] provider abstraction established
- [x] offline ML boundary established
- [x] fine-tuning/adapters concept scaffolded
- [x] provider benchmark dimensions and routing outcomes exist
- [x] dataset governance and promotion/rollback baseline exists
- [~] operator review checklist for promotions can still be added

## 9. AI execution layer
- [x] master plan created
- [x] AI operating protocol created
- [x] status tracking created
- [x] definition of done created
- [x] skills index exists and multiple domain skills exist
- [~] skills can still be hardened into even more prescriptive reusable packs

## 10. First vertical slice readiness
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
- [x] local-first audio file capture path is integrated into the first slice with persisted audio artifacts and explicit degraded transcription behavior
- [x] first slice now distinguishes draft SOAP snapshots from finalized SOAP documents with explicit source-draft and gate linkage
- [x] first slice now derives referral and prescription drafts as explicit draft-only artifacts linked to the same session/SOAP/context spine
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
