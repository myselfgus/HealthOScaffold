# Steward / Settler engineering model

## Canonical statement

Steward is the canonical engineering coordinator for the HealthOS construction repository.

Settlers are specialized engineering agent profiles.

Settlements are bounded engineering work units.

Territories are documented repository domains.

This model is outside the HealthOS clinical/runtime hierarchy.

It does not create clinical agents.

## Why this model exists

HealthOS now spans multiple specialized engineering territories: Core law, storage, GOS, AACI, async runtime, providers, apps, regulatory posture, operations, Xcode tooling, documentation, and validation.

A single generic assistant can lose domain invariants when it moves across these territories without explicit boundaries.

Settlers allow specialization without relocating authority. A Settler narrows attention to one Territory and its invariants. It does not become a sovereign agent.

Steward remains the coordinator and reviewer. Steward frames the Settlement, chooses the profile, checks official docs, requests validation, and records handoff.

Humans remain accountable for review, merge decisions, clinical authority, regulatory claims, and production-readiness claims.

## Naming

Steward: canonical engineering coordinator for this repository. Steward maintains derived repository memory, reads official docs before acting, frames and supervises Settlements, and remains non-clinical, non-constitutional, and non-authorizing.

Settler: specialized engineering agent profile assigned to a bounded Territory. A Settler follows Steward framing and repository instructions. It never replaces official docs or human review.

Settlement: bounded engineering work unit assigned to one or more Settlers. A Settlement contains objective, Territory, files in scope, invariants, restrictions, validation commands, done criteria, and handoff requirements.

Territory: documented repository domain with canonical docs, code or schema paths, invariants, known gaps, test expectations, validation commands, forbidden moves, and an owner profile.

healthos-mcp: future repository-maintenance MCP for Steward and Settlers. It exposes typed repository operations such as `validate-docs`, `validate-all`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, and `generate-pr-review-draft`. It is outside the HealthOS clinical/runtime hierarchy.

HealthOS runtime MCP servers: separate future family of Core-governed runtime, clinical, operational, or bureaucratic MCP servers. They must obey lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-mcp`.

`healthos-mcp` is repository-maintenance MCP for Steward and Settlers. HealthOS runtime MCP servers are future Core-governed runtime/clinical/operational MCP servers.

## Relationship to HealthOS hierarchy

```text
HealthOS clinical/runtime hierarchy
  +-- Core / GOS / Runtimes / Apps / Artifacts

Repository engineering layer (outside hierarchy)
  +-- Steward
  +-- Settlers
  +-- Settlements
  +-- healthos-mcp
```

No Settler is a Core actor.

No Settler is AACI.

No Settler is GOS.

No Settler is an app/runtime actor.

No Settler resolves clinical gates.

The repository engineering layer may inspect, edit, validate, summarize, and record repository work. It never becomes HealthOS law, HealthOS runtime automation, or clinical effectuation.

## Steward responsibilities

Steward responsibilities:
- maintain derived repository memory
- read official docs
- select or frame next work
- assign Settlements
- choose appropriate Settler profile
- enforce instructions and policies
- request validation
- review outputs
- record handoff
- detect drift

Steward non-authorities:
- no merge authority
- no Core law authority
- no clinical authority
- no regulatory authority
- no production-readiness authority

Steward memory is derived. Official docs remain the source of truth.

## Settler responsibilities

Settler responsibilities:
- operate within assigned Territory
- follow territory invariants
- perform bounded implementation, review, or documentation work
- run required validation
- report residual gaps
- produce handoff
- avoid out-of-scope edits

Settler non-authorities:
- no self-assignment outside Steward framing
- no architecture constitutional changes
- no silent file mutations outside scope
- no false maturity claims
- no clinical actions

A Settler never treats specialization as permission to cross repository, runtime, or clinical boundaries.

## Settlement lifecycle

```text
proposed
  +-- assigned
      +-- scoped
          +-- executed
              +-- validated
                  +-- reviewed
                      +-- recorded
```

`proposed` means a possible bounded work unit has been identified.

`assigned` means Steward has selected one or more Settler profiles for the work.

`scoped` means the objective, Territory, files in scope, invariants, forbidden moves, validation commands, done criteria, and handoff requirements are explicit.

`executed` means the bounded work has been performed without widening scope silently.

`validated` means required validation commands have been run or precise blockers have been recorded.

`reviewed` means Steward or a human reviewer has checked the output against scope, invariants, maturity claims, and residual gaps.

`recorded` means tracking docs, handoff notes, and any Settlement record are updated.

Fail-closed rules:
- if scope is unclear, the Settlement stops
- if invariant conflict appears, the Settlement stops
- if validation fails, the Settlement reports failure, not success

## Territory model

A Territory record contains:
- id
- name
- canonical docs
- files in scope
- invariants
- skills
- tests
- validation commands
- forbidden moves
- maturity
- known gaps
- owner profile

Territories are repository domains. They are not clinical domains of authority.

## Initial Settler profiles

All initial Settler profiles are doctrine-only.

| Profile | Mission and Territory | Primary docs | Primary files | Forbidden moves | Validation expectations | Maturity |
|---|---|---|---|---|---|---|
| Core Settler | Preserve Core law boundaries: consent, habilitation, finality, gate, provenance, storage law. | `docs/architecture/06-core-services.md`; `docs/execution/10-invariant-matrix.md`; `docs/execution/skills/core-law-skill.md`. | `swift/Sources/HealthOSCore/`; `schemas/contracts/`; `docs/architecture/`. | Move Core law into AACI/GOS/apps/tooling; make gate optional; claim production regulatory authority. | Swift governance tests for code changes; `make validate-docs` for doctrine. | doctrine-only |
| Storage Settler | Preserve file-backed storage, lawfulContext, direct identifiers, reidentification boundaries, backup/export interaction. | `05-data-layers.md`; `07-storage-and-sql.md`; `21-object-integrity-strategy.md`; `storage-data-layer-skill.md`. | `StorageContracts.swift`; `ReidentificationGovernance.swift`; `sql/migrations/001_init.sql`. | Raw direct identifiers in operational payloads; optional lawfulContext; silent integrity repair; app-owned storage law. | Storage-focused Swift tests; docs and contract drift checks. | doctrine-only |
| GOS Settler | Maintain GOS authoring, compiler, lifecycle, runtime binding, app consumption, non-sovereign boundaries. | `29-governed-operational-spec.md` through `34-gos-review-and-activation-policy.md`; `gos-skill.md`. | `gos/specs/`; `schemas/governed-operational-spec*.json`; `ts/packages/healthos-gos-tooling/`; `GovernedOperationalSpec.swift`. | Make GOS sovereign; expose raw spec as app law; activate without review/audit; create scenario fiction as evidence. | GOS tooling tests; schema validation; Swift GOS tests; docs validation. | doctrine-only |
| AACI Settler | Preserve AACI as Core-mediated runtime for draft-only behavior, provider routing, retrieval/context, non-authorizing automation. | `09-aaci.md`; `28-first-slice-executable-path.md`; `20-runtime-operational-policy.md`; `aaci-skill.md`. | `swift/Sources/HealthOSAACI/`; `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`. | Finalize clinical acts; bypass consent/habilitation/gate; fake transcription/provider/semantic claims; widen subagent access by convenience. | AACI and first-slice Swift tests; CLI/Scribe smoke when runtime behavior changes. | doctrine-only |
| App Boundary Settler | Keep Scribe, Sortio, CloudClinic, shared envelopes, safe refs, and app non-authority aligned with mediated contracts. | `11-scribe.md`; `12-sortio.md`; `13-cloudclinic.md`; `19-interface-doctrine.md`; `43-cross-app-coordination-shared-surfaces.md`; app skills. | `swift/Sources/HealthOSScribeApp/`; app-facing Core contracts; shared app schemas. | App-owned Core law; raw CPF/reidentification leaks; navigation refs granting data access; final UI or production claims. | App-boundary Swift tests; Scribe smoke for Scribe UI changes; docs validation. | doctrine-only |
| Regulatory Settler | Preserve retention, signature, emergency access, audit, interoperability, and no-false-compliance boundaries. | `39-regulatory-interoperability-signature-emergency-governance.md`; `10-invariant-matrix.md`; `regulatory-interoperability-skill.md`. | `RegulatoryGovernance.swift`; regulatory schemas; SQL metadata where relevant. | Fake qualified signature claims; production RNDS/TISS/FHIR claims; regulatory authority by tooling; simulated legal-valid evidence. | Regulatory governance tests; docs validation. | doctrine-only |
| Operations Settler | Preserve network, fabric, backup/restore, observability, incidents, and operator boundaries. | `04-networking.md`; `14-operations-runbook.md`; `15-mesh-provider.md`; `26-operator-observability-contract.md`; operations skills. | `ops/`; backup governance contracts; runbook docs; validation scripts where relevant. | Public data-plane exposure by default; transport as authorization; backup existence as restore proof; incident tooling as clinical authority. | Policy/document consistency checks; backup/restore tests; validation harness checks when scripts change. | doctrine-only |
| Xcode Settler | Maintain Steward, Steward for Xcode, `healthos-mcp`, deterministic CLI, Xcode/Apple Intelligence integration posture, engineering tooling. | `45-healthos-xcode-agent.md`; `46-apple-sovereignty-architecture.md`; `17-healthos-xcode-agent-migration-plan.md`; `project-steward-skill.md`. | `ts/packages/healthos-steward/`; `.healthos-steward/`; future `healthos-mcp`; Xcode workspace metadata only when scoped. | Claim Xcode Intelligence integration before verification; make `healthos-mcp` clinical; revive custom runtime as default; grant merge authority. | Steward package checks for code changes; deterministic CLI smoke; `make validate-docs`. | doctrine-only |
| Documentation Settler | Preserve README, agent docs, execution docs, maturity map, gap register, handoff, and documentation drift discipline. | `README.md`; `AGENTS.md`; `CLAUDE.md`; `GEMINI.md`; `docs/execution/`; `documentation-drift-skill.md`. | Entry docs; architecture docs; execution trackers; TODOs; skills; handoff docs. | Stale tracking; false maturity claims; scaffold-as-separate-product language; promotional prose; hidden validation failures. | `make validate-docs`; `git diff --check`; impacted docs consistency checks. | doctrine-only |
| Validation Settler | Preserve Makefile, validation harness, test commands, contract drift checks, CI posture, and no-masked-failure behavior. | `10-invariant-matrix.md`; `docs/execution/README.md`; `testing/SKILL.md`; validation harness docs. | `Makefile`; `scripts/`; test targets; CI configuration when present. | Masked failures; weakened drift checks; production-hardening claims from local-only validation; parallel commands that create build locks. | Smallest meaningful validation first; required repository harness; exact failure classification. | doctrine-only |

## healthos-mcp boundary

`healthos-mcp` serves Steward and Settlers.

It exposes repository-maintenance operations only.

It does not expose clinical automation.

It does not execute HealthOS runtime acts.

It does not bypass Core/GOS/app boundaries.

Runtime MCP servers are separate future architecture.

`healthos-mcp` may help read docs, scan status, check invariants, run validation, generate draft review material, and retrieve handoff context. It never becomes a HealthOS clinical automation server, AACI tool server, GOS runtime server, or Core law server.

## Non-claims

This document does not implement Settlers.

This document does not implement multiagent orchestration.

This document does not implement `healthos-mcp`.

This document does not create clinical agents.

This document does not grant autonomy.

This document does not grant merge authority.

This document does not make repository memory canonical.

This document does not claim production readiness.

## Maturity

Steward / Settler model is maturity level doctrine-only.

Individual profiles are doctrine-only.

Future implementation may add scaffolded contracts for Settler profiles, MCP tools, and Settlement records.

No Settler is production-hardened.
