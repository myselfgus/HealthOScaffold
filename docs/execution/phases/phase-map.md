# Phase map

## Phase 00 — Governance and execution discipline
Prerequisites: none

Tasks:
- create execution docs
- create status tracking
- create domain TODO files
- update README pointers
- define definition of done conventions

Done when:
- an AI can select the next task without ambiguity
- the repository exposes explicit execution order

## Phase 01 — Core laws
Prerequisites: phase 00

Tasks:
- complete canonical contracts for Usuario, Servico, RegistroProfissional, Habilitacao, Consentimento, GateRequest, GateResolution, Proveniencia
- add missing schemas for core governance objects
- document service boundaries for IdentityService, HabilitationService, ConsentService, GateService, ProvenanceService, DataStoreService
- define finality/purpose check contract

Done when:
- app/runtime code can consume stable core contracts
- gate and access semantics are explicit and testable

## Phase 02 — Data and storage foundation
Prerequisites: phase 01

Tasks:
- finalize canonical directory layout
- refine SQL migration and indexes
- define storage API for put/get/list/audit
- define de-identification and re-identification workflow
- define artifact and object path conventions

Done when:
- there is one canonical answer for where each class of data lives
- storage and metadata layers are linked cleanly

## Phase 03 — Runtime / actor / agent contracts
Prerequisites: phases 01-02

Tasks:
- define runtime lifecycle states
- define actor vs agent relationship formally
- define mailbox semantics and event model
- define permission and boundary model
- define inter-runtime communication contracts

Done when:
- AACI, async, and user-agent runtimes can be implemented against the same contract vocabulary

## Phase 04 — AACI runtime
Prerequisites: phases 01-03

Tasks:
- define session modes
- define hot/warm/cold task routing
- define subagent input/output boundaries
- define provider routing strategy
- define provenance hooks for every subagent action
- define draft production path

Done when:
- AACI can run the first slice without violating core laws

## Phase 05 — Scribe and first slice
Prerequisites: phases 01-04

Tasks:
- define Scribe screens and state model
- define professional session flow
- define gate presentation and review flow
- connect first slice end to end

Done when:
- the first vertical slice is fully specified and build-ready

## Phase 06 — User Agent and Sortio
Prerequisites: phases 01-03

Tasks:
- define user-agent shell and boundaries
- define patient-facing data visibility and consent flows
- define audit access views and exports

Done when:
- patient sovereignty flows are architecturally complete

## Phase 07 — CloudClinic
Prerequisites: phases 01-03

Tasks:
- define service dashboard
- define patient registry and queue model
- define operational document and pending-work views
- define service-level access boundaries

Done when:
- service operations have a coherent interface contract

## Phase 08 — Networking and operations
Prerequisites: phases 00-03

Tasks:
- finalize private port and exposure policy
- define MeshProvider contract
- define launchd supervision plan
- define health checks, backup checks, restore drills
- define local secrets/config handling

Done when:
- single-node operations are repeatable and auditable

## Phase 09 — Providers and offline ML
Prerequisites: phases 01-04

Tasks:
- define provider benchmark matrix
- define model registry lifecycle
- define dataset governance
- define adapter promotion and rollback flow
- define offline tuning safety policy

Done when:
- provider choice and specialization are governed rather than ad hoc

## Phase 10 — Hardening and readiness
Prerequisites: phases 01-09

Tasks:
- expand threat model
- add readiness checklist
- create unresolved-risk ledger
- define internal-use acceptance criteria

Done when:
- the system can be evaluated as a serious internal platform foundation
