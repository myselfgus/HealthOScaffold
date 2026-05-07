# Glossary

## HealthOS
The whole app-agnostic sovereign computational environment for health operations. HealthOS includes Core, runtime/mediation layers, app integration boundaries, reference apps, tooling, tests, and docs at their explicit maturity levels. It is not defined by any one app or fixed set of apps.

## HealthOScaffold
The historical repository name and foundation/scaffold phase for building HealthOS. It is not a separate product from HealthOS.

## Platform/Core Layer
The HealthOS layer that owns Core law, sovereign contracts, storage law, consent, habilitation, finalidade, provenance, gate, and fail-closed governance.

## Runtime/Mediation Layer
The HealthOS layer that orchestrates and mediates work under Core law. It includes Session Runtime, AACI, GOS, MSR, providers, Async Runtime, User-Agent Runtime, and Service Runtime where evidenced.

## App Integration Boundary
The boundary between runtimes/Core and apps. It includes facades, command/result envelopes, safe refs, app-safe views, mediated state, degraded-state truth, and provenance-facing summaries. Apps consume this boundary; they do not define it.

## Reference App Layer
The app/interface layer containing initial reference apps such as Scribe, Veridia, CloudClinic, and future apps in arbitrary number. Reference apps are consumers of mediated HealthOS surfaces, not Core, runtime law, or the definition of HealthOS.

## Construction System
The engineering-tooling layer for building HealthOS: Steward, Settler, Territory, Settlement, and HealthOS Forge MCP. It is outside the HealthOS clinical/runtime hierarchy and has no clinical, constitutional, authorizing, or merge authority.

See `docs/architecture/50-app-layer-boundary-and-reference-apps.md` for the canonical app boundary and task-ordering doctrine.

## AACI
Ambient-Agentic Clinical Intelligence. A runtime inside HealthOS for parallel operational/bureaucratic automation during or around health work.

## GOS
Governed Operational Spec. A subordinate operational specification layer compiled from human-authored operational language into runtime-consumable structure; it never supersedes HealthOS Core law.

## Core
The law-bearing nucleus of HealthOS: identity, consent, habilitation, provenance, gate, storage/governance contracts.

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
