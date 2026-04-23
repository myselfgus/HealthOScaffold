# Master execution plan for HealthOS

## Objective

Turn the current scaffold into a buildable, governable platform with explicit execution order.

## Canonical hierarchy to preserve

1. Material substrate
2. HealthOS Core
3. HealthOS Runtimes
4. Actors / Agents
5. Apps / Interfaces
6. Artifacts / Effects

## Work order

### Phase 00 — Governance and execution discipline
Outputs:
- execution docs
- status tracking
- dependency map
- backlog decomposition

### Phase 01 — Core laws of HealthOS
Outputs:
- domain contracts for user, service, consent, habilitation, gate, provenance
- sharper schema coverage
- clear core service boundaries

### Phase 02 — Data and storage foundation
Outputs:
- canonical directory model
- SQL schema refinement
- storage service contract
- de-identification / re-identification flow
- indexing plan

### Phase 03 — Runtime / actor / agent contracts
Outputs:
- actor model rules
- runtime lifecycle contracts
- mailbox/event model
- permission/boundary model

### Phase 04 — AACI runtime
Outputs:
- session modes
- hot/warm/cold paths
- subagent contracts
- orchestration flow
- provider routing

### Phase 05 — Scribe app and first vertical slice
Outputs:
- screen map
- UI state model
- session flow
- gate flow
- slice implementation plan

### Phase 06 — User Agent and Sortio
Outputs:
- user-agent shell
- patient sovereignty flows
- consent management flow
- audit visibility flow

### Phase 07 — CloudClinic
Outputs:
- service dashboard
- patient operations model
- operational queue and draft visibility

### Phase 08 — Networking, mesh, ops, observability
Outputs:
- access policy
- health checks
- backup and restore runbooks
- launchd and runtime supervision details

### Phase 09 — Providers and offline ML
Outputs:
- model registry workflow
- provider benchmark policy
- fine-tuning/adapters process
- dataset governance

### Phase 10 — Hardening and readiness
Outputs:
- expanded threat model
- readiness checklist
- internal-use criteria
- unresolved-risk ledger

## Non-negotiable execution rules

- Core before apps.
- Gate before regulatory effects.
- Consent/habilitation before bounded retrieval.
- Provenance before production-like automation.
- Single-node correctness before mesh expansion.

## First production-shaping slice

The first slice remains:
- professional session start
- habilitation validation
- patient selection
- capture
- transcription
- context retrieval
- SOAP draft
- gate request
- approval/rejection
- provenance append
- artifact persistence
