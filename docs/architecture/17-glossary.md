# Glossary

## HealthOS
The whole sovereign computational environment for health operations. HealthOS includes Core, GOS, Runtimes, Boundary, Stages, tooling, tests, and docs at their explicit maturity levels. It is not defined by any one Stage or fixed set of Stages.

## HealthOScaffold
The historical repository name and foundation/scaffold phase for building HealthOS. It is not a separate product from HealthOS.

## Core
The HealthOS constitutional law layer. Core owns consent, habilitation, storage law, provenance, gate, finality, audit, sovereign contracts, and fail-closed governance.

## CoreLaw
The constitutional authority of Core expressed as enforceable law, contracts, and validation behavior. Custom, Boundary, GOS, Runtimes, and Stages are governed by CoreLaw; none of them supersede it.

## GOS
Governed Operational Spec. A subordinate operational specification layer compiled from human-authored operational language into runtime-consumable structure; it never supersedes CoreLaw.

## Runtimes
Execution and mediation layers operating under Core/GOS. Runtimes include Session Runtime, AACI, MSR, Async Runtime, User-Agent Runtime, and Service Runtime where evidenced.

## Boundary
The HealthOS-owned frontier between Core/GOS/Runtimes and Stages. Boundary exposes facades, command/result envelopes, safe refs, app-safe views, mediated state, degraded-state truth, provenance-facing summaries, and consumable surfaces. Stages consume Boundary; they do not define it.

## Stage
A governed application consumer inside HealthOS. Scribe, Veridia, CloudClinic, and future first-party, third-party, native, web, external, Swift, or other applications are Stages when they run in or are hosted by the HealthOS environment as governed consumers. Stage is the last tier of the HealthOS constitutional hierarchy.

## Custom
The CoreLaw-governed definition of a Stage: capabilities, limits, consumed surfaces, actors, degraded behavior, validation expectations, and prohibitions. Custom is applied via Boundary and is not a separate tier in the HealthOS hierarchy.

## Construction System
The engineering-tooling system for building HealthOS: Steward, Settlers, Territories, Settlements, and HealthOS Forge MCP. It is outside the HealthOS clinical/runtime hierarchy and has no clinical, constitutional, authorizing, runtime, Stage, or merge authority.

## Compatibility Terms
Existing technical names such as `HealthOSAppBoundary`, `AppSurfaceEnvelope`, and `HealthOSScribeApp` remain package/API/module names until an explicit rename work unit exists. Their names do not change the canonical conceptual terms Boundary and Stage.

See `docs/architecture/50-app-layer-boundary-and-reference-apps.md` for the canonical Boundary, Stage, Custom, and task-ordering doctrine.

## AACI
Ambient-Agentic Clinical Intelligence. A runtime inside HealthOS for parallel operational/bureaucratic automation during or around health work.

## Runtime
An execution environment with lifecycle and communication contracts.

## Actor
The isolation/concurrency primitive.

## Agent
An actor with semantic role, permissions, boundary, and domain responsibility.

## Gate
The required human-approval boundary that turns a computational draft into a human-plane act.

## Draft
A prepared but not yet effective artifact.

## Artifact
A persisted structured output, whether draft, final, derived, or supporting.

## Direct identifier
Data that directly identifies a person, such as CPF or name.

## Operational content
Data the platform must process to function operationally.

## Re-identification
Governed linkage from pseudonymous representation back to direct identity.


## Session Runtime
Swift runtime orchestration layer (`HealthOSSessionRuntime`) centered on `SessionRunner`; owns session-boundary habilitation/consent mediation, capture flow coordination, transcript normalization, gate handoff, and session provenance markers.

## MSR
Mental Space Runtime. Swift runtime peer to AACI under Session Runtime orchestration (`HealthOSMSR`), responsible for the derived artifact pipeline `ASL -> VDLP -> GEM` after normalized transcript input.

## Providers
Infrastructure layer (`HealthOSProviders`) for model adapters, routing, stubs, and capability profiles; not a law or runtime authority layer.

## Async Runtime
TypeScript asynchronous substrate (`runtime-async`) for jobs, idempotency, retry, dead-lettering, and backpressure behavior.

## User-Agent Runtime
TypeScript runtime (`runtime-user-agent`) for patient-governed/user-agent query boundaries and prohibited-capability enforcement.

## Service Runtime
TypeScript runtime (`service-runtime`) for service-facing operational envelopes and service-flow guards (including CloudClinic envelope adapter and LegalAuthorizing guard where evidenced).

## HealthOS Forge MCP
Repository-maintenance MCP/tooling surface (package/server name `healthos-forge-mcp`) for the construction layer (Steward, Settlers, Territories, Settlements). It is outside HealthOS clinical/runtime hierarchy. The repository implements this as `@healthos/forge-mcp` at `ts/agent-infra/healthos-forge-mcp/`, with 10 deterministic `steward_*` tools over stdio and Streamable HTTP.

## HealthOS runtime MCP servers
Separate future Core-governed MCP family for internal runtime/clinical/operational automation. These are distinct from HealthOS Forge MCP.
