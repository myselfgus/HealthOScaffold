# Governed AI Agent Society

HealthOS treats agents as governed AI entities, not as model instances. An agent has a stable `AgentID`, represented principal, mandate, memory scope, tool grants, provider-routing policy, delegation policy, protocol posture, audit/provenance refs, and lifecycle. An LLM, Apple-native model, local model, or external provider is only a selected execution engine.

## Classification

This first slice is:
- **Tier 1 - Core:** contracts, policy vocabulary, fail-closed validation, custody/grant refs, audit/provenance posture.
- **Tier 2 - GOS / Runtimes:** `PersonalAgentRuntime` as the patient/professional/user personal-agent lifecycle and async/offline posture seam.
- **Tier 3 - Boundary:** `AgentProtocolBoundary` projection to HealthOS AACP, A2A, and future ACP UI adapter.

It is not Tier 4 Stage work. Veridia, Scribe, and CloudClinic keep their documented roles and may consume mediated surfaces later.

## Agent Model

Personal AI agents:
- `PatientPersonalAgent`: patient juridical-digital representative; educates, negotiates, applies preferences, and mediates consent/access requests under Core policy.
- `ProfessionalPersonalAgent`: professional representative for a habilitated professional persona; prepares professional context, requests access, and tracks active mediated consent.
- `UserPersonalAgent`: generic user-side form for non-clinical or future roles.

Core governance agents:
- `ConsentGovernanceAgent`
- `HabilitationGovernanceAgent`
- `GateFinalityAgent`
- `CustodyAccessAgent`
- `AuditProvenanceAgent`

Runtime AI agents:
- `SessionAgent`
- `AACIAgent`
- `MSRAgent`
- `AsyncJobAgent`
- `ServiceRuntimeAgent`
- `UserAgentRuntimeAgent`

Provider/model agents:
- `ProviderRouterAgent`
- `ModelGovernanceAgent`

Boundary/protocol agents:
- `AgentProtocolBoundary`
- `AppSurfaceBoundaryAgent`

## Contract Rules

Every governed AI agent must declare:
- `AgentID`
- represented principal via safe ref, never raw CPF
- `AgentMandate`
- `DelegationPolicy`
- `AgentMemoryScope`
- `AgentToolGrant`
- `AgentProviderRoutingPolicy`
- protocol kinds and Boundary posture

Negotiation envelopes must fail closed on:
- missing `lawfulContext`
- direct identifiers by default
- reidentification maps by default
- raw storage paths
- key material
- internal memory exposure
- legal-authorizing claims
- autonomous diagnosis, prescription, referral issuance, finalization, signature, professional habilitation, or legal-retention mutation
- external provider routing without explicit policy
- external routing of direct identifiers or reidentification mappings

## Provider Policy

Apple Silicon/local-first is preferred when appropriate. It is not an exclusive rule. External models are permitted only when the agent/provider policy explicitly allows them and when the data layer, finality, provenance, audit, and minimization constraints pass.

`AgentProviderRoutingPolicy` records:
- local/Apple preference
- allowed provider kinds
- explicit external-provider policy ref
- operational-sensitive external allowance
- allowed/denied data layers
- model provenance requirement
- degraded-sovereignty posture

## Blind Data Doctrine

"Dados cegos" means pseudonymization and controlled separation of identity, content, persona, and custody. It does not mean Veridia stores keys or that any Stage owns custody law.

The governed agent model uses:
- safe refs for protocol/app surfaces
- `CustodyControlRef` handles instead of key material
- `EphemeralAccessGrantRef` for time-bounded grants
- Core-mediated reidentification
- audit/provenance refs on all negotiations

## Protocol Posture

HealthOS AACP is the governed internal profile. A2A is used as the external agent-agent reference for tasks, messages, artifacts, streaming, async, and opaque execution. ACP is treated as a future UI adapter reference for existing application interfaces.

Protocol projections must not expose:
- raw direct identifiers
- raw storage
- key material
- internal memory
- tool implementation
- legal authorization

## Non-Scope Guard

This first slice intentionally does not:
- implement Stage UI;
- move or rename Veridia/Scribe;
- make Veridia a key vault;
- make Scribe a professional-persona authority;
- implement a real external LLM provider;
- create production custody, EHR, signature, regulatory, or clinical-act authority.

## Implementation Evidence

- Swift Core: `GovernedAIAgentContracts.swift`
- Tier 2 runtime: `PersonalAgentRuntime`
- Tier 3 Boundary: `AgentProtocolBoundary`
- TypeScript mirror: `HealthOS/Constructor/ts/packages/contracts/src/index.ts`
- JSON Schema mirror: `governed-ai-agent-society.schema.json`
- Tests: `GovernedAIAgentTests`, `PersonalAgentRuntimeTests`, `AgentNegotiationBoundaryTests`
