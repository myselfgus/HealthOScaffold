# 45) Steward for Xcode (target architecture)

Historical/descriptive names for this component: HealthOS Xcode Agent, Xcode Agent. Canonical name: Steward. Xcode-integration posture: Steward for Xcode.

## Purpose

Steward for Xcode is the target engineering-tooling posture for this repository.

It serves HealthOS construction — the work of building HealthOS in this repository. It is not a clinical runtime, not an AACI component, and not a HealthOS Core law engine.

It is:
- outside the HealthOS clinical and runtime hierarchy
- non-clinical
- non-constitutional
- non-authorizing

It is not a separate product from HealthOS. "Scaffold" here describes maturity of tooling, not a product identity distinct from HealthOS.

## Why Xcode Intelligence is the runtime

The prior target in this document assumed HealthOS must build a custom TypeScript agent runtime with custom session orchestration, model routing, and conversation surfaces. That assumption is superseded.

Xcode Intelligence provides native workspace-aware engineering-agent capability aligned with the Apple sovereignty thesis in `docs/architecture/46-apple-sovereignty-architecture.md`:

- It is Apple-controlled software on Apple-controlled hardware, consistent with the Apple-first engineering posture.
- It provides native IDE context: active file, selection, diagnostics, build state, and workspace structure.
- It reduces the maintenance surface HealthOS must own for conversational engineering capability.
- It is the canonical engineering intelligence surface for Apple-platform development.

HealthOS should not duplicate what Xcode provides natively. HealthOS contributes extension surfaces to the native runtime: instructions, skills, an MCP server, derived repository memory, and a deterministic CLI.

Language precision:

- Xcode Intelligence is Apple-controlled. It is not a HealthOS runtime. HealthOS does not own, fork, or extend the Xcode Intelligence runtime itself.
- Claude/Codex integration within Xcode is expected as part of the Xcode Intelligence surface. Specific integration capabilities should be verified from official Apple and Anthropic documentation before being claimed. Describe unverified capabilities as candidate or currently expected integration, not delivered fact.
- HealthOS does not configure or control Apple Intelligence. Apple Intelligence is a distinct Apple-provided capability layer and is not part of HealthOS Core.

The optional custom surface remains available: if Xcode Intelligence proves insufficient for a specific, documented HealthOS engineering need, a targeted custom surface may be built. That surface is not the primary target.

## Constitutional boundaries

Steward must never be:

- HealthOS Core law
- GOS authority or GOS compiler
- AACI runtime or AACI session orchestrator
- Async runtime
- User-Agent runtime
- a clinical actor
- an app runtime (not Scribe, Sortio, or CloudClinic)
- a merge approver
- a gate resolver
- a regulatory authority

It may recommend, inspect, edit, validate, and summarize. It may not redefine constitutional boundaries, claim product maturity that does not exist, or relocate Core law into the engineering-agent layer.

## Target relationship

```text
Xcode Intelligence (Apple-controlled engineering runtime surface)
  ├─ consumes HealthOS instructions and skills
  │    (CLAUDE.md, AGENTS.md, skill files, policy guard language)
  ├─ calls HealthOS MCP server for typed repository operations
  │    (healthos-mcp: validate-all, scan-status, next-task, check-invariants, ...)
  ├─ reads derived repository memory
  │    (.healthos-steward/memory/derived/)
  └─ delegates deterministic CI-safe operations to healthos-steward CLI
       (validation, status, handoff, next-task without LLM dependency)
```

```text
HealthOS clinical and runtime hierarchy (never collapses into engineering layer)
  Material substrate
    └─ HealthOS Core
      └─ GOS
        └─ Runtimes (AACI, Async, User-Agent)
          └─ Apps (Scribe, Sortio, CloudClinic)
```

These two structures never merge. Steward does not enter the clinical/runtime hierarchy. The clinical/runtime hierarchy does not depend on Steward.

## Steward / Settler model

Steward is the canonical engineering coordinator for the HealthOS construction repository.

Settlers are specialized engineering profiles for bounded repository Territories. A Territory is a documented repository domain with canonical docs, files in scope, invariants, tests, risks, and validation rules.

Settlements are bounded work units framed by Steward and assigned to one or more Settlers under Steward supervision.

Xcode Intelligence, where available, may host or assist interactions with Steward, Settlers, Settlements, and Territories. Xcode Intelligence is not HealthOS Core, not a HealthOS clinical runtime, and not a HealthOS-controlled law engine.

Steward for Xcode is the Xcode-native integration posture for Steward.

`healthos-mcp` is the repository-maintenance MCP for Steward and Settlers. HealthOS runtime MCP servers are separate future Core-governed systems and must not be collapsed into `healthos-mcp`.

The canonical model is defined in `docs/architecture/47-steward-settler-engineering-model.md`.

## What HealthOS contributes (extension surface)

HealthOS does not build the runtime. HealthOS contributes four extension points.

### Instructions and skills

Current:
- `CLAUDE.md` — primary instruction file for Claude Code and compatible agents
- `AGENTS.md` — repository instruction file for coding agents
- skill files under `docs/execution/skills/`

Content requirements for these files:
- policy guard language: non-authoritative posture, fail-closed behavior, official-doc precedence
- repository truth hierarchy: official docs are canonical; steward memory is derived
- anti-overclaim rules: no false maturity claims, no invented capability
- non-clinical boundary statements
- HealthOS repository identity: scaffold describes maturity, not separate product identity
- constitutional boundary reminders

This extension point is the highest-leverage investment. An agent operating inside the HealthOS workspace receives HealthOS-specific posture from these files without requiring custom runtime code.

WS-1 (instructions and skills consolidation) is the follow-up work item for this extension point.

### MCP server

Candidate name: `healthos-mcp`

A local MCP server exposes typed HealthOS repository operations to Xcode Intelligence or any compatible MCP client. Typed operations allow Steward to invoke HealthOS-specific repository actions as structured tool calls, not free-form shell commands.

Target operations (not delivered unless implemented):
- `validate-all` — run the full repository validation harness
- `validate-docs` — run documentation drift and presence checks
- `scan-status` — scan current repository status against execution docs
- `get-handoff` — retrieve next-agent handoff snapshot
- `next-task` — identify the highest-priority next task from execution docs
- `read-gap-register` — read the final gap register
- `generate-pr-review-draft` — assemble a PR review checklist against invariant policy
- `check-invariants` — check invariant enforcement posture
- `check-doc-drift` — check for documentation drift

All operations are target architecture. None are delivered until implemented and verified.

WS-2 (MCP server implementation) is the follow-up work item for this extension point.

### Repository memory

Location: `.healthos-steward/memory/derived/`

Memory constraints:
- derived index over official docs; never canonical truth
- no secrets, no tokens, no provider credentials
- no clinical payloads
- no direct identifiers
- declare stale or derived state explicitly when applicable

Official docs (`docs/`, `README.md`, `CLAUDE.md`, `AGENTS.md`) remain canonical. Memory is a speed layer, not an authority layer.

### Deterministic CLI

The `healthos-steward` CLI provides deterministic repository operations for CI and non-Xcode automation.

- runs without LLM dependency for deterministic flows
- produces provenance-friendly output
- exposes the same repository operations as the MCP server where possible
- fails closed on validation failures
- works in GitHub Actions and equivalent CI environments
- is not a conversational agent runtime

WS-3 (deterministic CLI consolidation) is the follow-up work item for this extension point.

## What HealthOS does not contribute

HealthOS does not build:

- a custom agent runtime as the primary engineering-agent target
- a custom multi-model router as the primary architecture
- a custom Xcode conversational UI, unless Xcode-native surface proves insufficient for a specific, documented case
- HealthOS-owned session continuity inside Xcode Intelligence
- clinical authority of any kind through Steward
- merge authority or gate resolution authority
- Core/GOS law relocation into the engineering-agent layer

## Operating modes

These are expected behaviors when Steward works inside the HealthOS workspace. They describe posture and constraint, not custom runtime modes that HealthOS must implement.

### Chat mode

Allowed:
- answer questions about HealthOS architecture, contracts, and status
- reference official docs as source of truth
- surface maturity caveats and non-claims honestly

Not allowed:
- invent capability not present in official docs
- claim production readiness
- claim PCC, Xcode Intelligence, or MCP integration before end-to-end verification
- claim clinical or regulatory authority

### Inspect mode

Allowed:
- read repository docs, source, schemas, and contracts
- explain architecture
- surface doc drift or maturity inconsistencies

Not allowed:
- treat steward memory as canonical
- assert implementation detail from memory without verifying current file state

### Plan mode

Allowed:
- select next task from execution docs
- generate handoff snapshots
- produce migration step plans

Not allowed:
- create new canonical documents that override official docs
- plan implementation of WS-1, WS-2, or WS-3 inside this work unit without explicit authorization

### Edit mode

Allowed:
- make explicit file changes with action trace
- follow the agent operating protocol in `docs/execution/01-agent-operating-protocol.md`
- update tracking docs in the same work unit as code/doc changes

Not allowed:
- silent mutation of tracking docs or invariant records
- bypass of `make validate-docs` or `make validate-all` after changes
- commit without recording in `02-status-and-tracking.md`

### Validate mode

Allowed:
- run `make validate-docs`, `make validate-schemas`, `make validate-all`
- summarize outcomes and gaps
- record validation evidence in tracking docs

Not allowed:
- claim validation passed without running the harness
- skip validation after changes

### Review mode

Allowed:
- review diffs, PRs, and doc drift against invariant policy
- produce draft review checklists
- surface maturity gaps and overclaims

Not allowed:
- approve or merge PRs autonomously
- post comments without explicit operator invocation

### Sync mode

Allowed:
- synchronize derived memory under `.healthos-steward/memory/derived/` against official docs
- mark stale memory entries

Not allowed:
- treat synced memory as superseding official docs
- sync clinical payloads or direct identifiers into memory

## Policy guards as instructions

PolicyGuard is not a sovereign runtime entity. It is instruction and boundary material consumed by Xcode Intelligence (through CLAUDE.md, AGENTS.md, and skill files), enforced as typed boundaries in the MCP server, and applied as checks in the deterministic CLI.

Policy guard language covers:

- fail-closed behavior: deny by default when posture is ambiguous
- official docs precedence: `docs/`, `README.md`, `CLAUDE.md`, `AGENTS.md` over memory
- no false maturity claims: use only canonical maturity levels
- no clinical payloads in memory, logs, or engineering outputs
- no silent mutation of canonical docs
- no GitHub write without explicit operator invocation
- no production-readiness claim
- no regulatory-compliance claim

## MCP boundary

`healthos-mcp` is the repository-maintenance MCP server for Steward. It is outside the HealthOS clinical/runtime hierarchy. It must never be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.

If HealthOS later uses MCP servers internally for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers. They must obey HealthOS Core invariants: lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-mcp`. Do not collapse these two MCP families.

When implemented, `healthos-mcp` must conform to:

- local server only; no external network exposure required
- typed operations with explicit input and output contracts
- typed error taxonomy per operation
- dry-run support where operations could have side effects
- no secrets in operation logs or memory
- no clinical payloads in operation inputs or outputs
- no direct mutation of HealthOS Core law contracts through MCP
- no production-readiness claim in operation outputs
- no silent file edits; every file change is explicit and logged

## Deterministic CLI boundary

The deterministic CLI must conform to:

- deterministic operations that work without an LLM
- appropriate for CI and GitHub Actions
- may share operation implementations with the MCP server
- not a conversational model runtime
- fail-closed on validation failures
- does not claim agentic capability for deterministic operations

The CLI is not being retired. It is being reduced to its essential deterministic scope.

## Compatibility and migration stance

`docs/architecture/44-project-steward-agent.md` is the historical reference for the Steward scaffold before this architectural realignment. It is preserved as reasoning history.

The old provider-centric steward architecture (`StewardAgentRuntime`, custom provider router, multi-model orchestration) should not be extended as the primary engineering-agent path. It may remain for deterministic operations during transition.

Migration must preserve:
- validation and fail-closed behavior
- existing deterministic CLI commands that are still valid
- `.healthos-steward/memory/derived/` as derived memory location
- provider error taxonomy for the MCP/CLI typed error surface (reused conceptually, not requiring custom agent runtime)

## Non-goals

This target architecture does not imply:

- implementing Xcode Intelligence (it is Apple-controlled)
- replacing Xcode IDE
- creating a clinical agent or clinical runtime
- building a custom conversational runtime unless future evidence requires it
- claiming Xcode Intelligence, MCP, or PCC integration before end-to-end verification
- making repository memory canonical truth
- granting autonomous merge authority or gate resolution authority
- production readiness of any HealthOS component

## Maturity

| Extension point | Current maturity | Notes |
|---|---|---|
| Xcode Intelligence integration | doctrine-only | No end-to-end verification in this work unit; must not be claimed above doctrine-only |
| Instructions / skills | scaffolded contract (files exist); content consolidation pending | WS-1 follow-up |
| MCP server (healthos-mcp) | doctrine-only | WS-2 follow-up; not implemented |
| Derived repository memory | scaffolded contract (.healthos-steward/memory/ exists) | Official docs remain canonical source |
| Deterministic CLI | implemented seam / tested operational path for existing commands | CI and non-Xcode path; WS-3 consolidation pending |
| Optional custom surface | doctrine-only | Only if Xcode-native surface proves insufficient for a documented case |

Maturity levels used: doctrine-only, scaffolded contract, implemented seam, tested operational path, production-hardened (per canonical ladder in `docs/execution/README.md`). Inv 43 applies: scaffold or foundation phase closure is not production readiness.
