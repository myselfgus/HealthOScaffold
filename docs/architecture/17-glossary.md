# Glossary

## HealthOS
The whole sovereign computational environment for health operations.

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
