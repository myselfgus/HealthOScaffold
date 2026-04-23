# Status and tracking

## Current global status

Current phase: Controlled implementation — first vertical slice started

## Completed recently

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

## In progress

- first vertical slice implementation continues with seeded-text compatibility, a structured local retrieval/context package, richer gate/document semantics, draft-only referral/prescription derivatives, and a now-wired local-audio path, while real local transcription and earlier draft-refresh finalization remain deferred
- doctrinal language hardening completed for sovereignty/privacy/compliance/topology without introducing infrastructure expansion

## Known gaps

- microphone capture is not implemented yet; the current local-first audio path uses file selection/import
- local transcription remains stubbed, so audio capture degrades honestly instead of yielding fabricated transcript text
- bounded retrieval now uses a stronger local score (lexical/tag/recency/category/intent), but still stops well short of semantic retrieval or embeddings
- Scribe now has a minimal validation UI surface, but it is not yet a full/final app shell
- draft refresh remains preview/degraded until gate resolution runs the full executable spine
- referral/prescription drafts now exist, but their regulatory effectuation/issuance remains intentionally deferred

## Open blockers / decisions

- decide when to replace the current stubbed local transcription path with a real local Apple-first transcription provider
- decide whether the next first-slice step after this wave is microphone capture, moving draft/retrieval finalization earlier than gate resolution, or introducing lawful effectuation paths for referral/prescription
- decide when to convert the AI skills into enforced reusable workflows/templates
- decide when to replace the current deterministic local retrieval/context package with semantic/clinical retrieval while preserving lawful scope and topology-invariant governance constraints

## Tracking rules

Whenever a work unit ends, update:
- current phase if changed
- completed recently
- in progress
- known gaps
- open blockers / decisions
