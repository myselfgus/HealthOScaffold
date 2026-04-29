# Steward for Xcode — migration plan

Historical/descriptive name: HealthOS Xcode Agent migration plan. Date baseline: April 28, 2026. Supersedes prior plan dated April 27, 2026.

## Goal

Simplify the engineering-agent layer to align with the Apple sovereignty thesis and reduce custom maintenance surface.

Prior goal: transform Project Steward from deterministic CLI plus optional provider orchestration into a custom multi-session agent runtime with custom model backends, tool runtime, and custom Xcode conversation surface.

Current goal:
- treat Xcode Intelligence as the native engineering-agent runtime surface per `docs/architecture/45-healthos-xcode-agent.md`
- align engineering posture with Apple sovereignty thesis per `docs/architecture/46-apple-sovereignty-architecture.md`
- contribute HealthOS-specific extensions: instructions, an MCP server, derived repository memory, and a deterministic CLI
- preserve fail-closed behavior and official-docs precedence throughout
- reduce custom code to what HealthOS must genuinely own

## Migration principles

- official docs (`docs/`, `README.md`, `CLAUDE.md`, `AGENTS.md`) are canonical; repository memory is derived
- fail-closed behavior is preserved at every phase; no step loosens boundary enforcement
- no overclaiming: do not claim Xcode Intelligence, MCP, or PCC integration before end-to-end verification
- deterministic operations remain available and functional during the entire transition
- Steward is outside the HealthOS clinical and runtime hierarchy; no migration step changes that
- scaffold describes maturity; HealthOScaffold is the historical construction repository for HealthOS, not a separate product

## Workstreams (simplified)

### WS-1: Instructions and skills consolidation

Objective: ensure that Xcode Intelligence and any compatible engineering assistant operating in this repository receives HealthOS-specific instructions and defaults to non-authoritative posture.

Actions:
- update `CLAUDE.md`, `AGENTS.md`, and relevant skill files in a future work unit
- define Settler profiles as instruction and skill material
- give each Settler a Territory, invariants, forbidden moves, and validation expectations
- state that no Settler can override Steward framing or official docs
- codify policy guards as instruction language:
  - official-doc precedence rule
  - non-authoritative posture rule
  - anti-overclaim rules (only canonical maturity levels)
  - non-clinical boundary rule
  - HealthOS repository identity rule (scaffold = maturity, not separate product)
- codify fail-closed default: when posture is ambiguous, deny rather than assume
- align existing skill files under `docs/execution/skills/` with the simplified target architecture

Definition of done:
- Xcode Intelligence or any engineering assistant operating in this repository receives clear HealthOS-specific instructions
- the agent defaults to non-authoritative posture by instruction
- the agent references official docs as source of truth
- the agent does not invent capability or claim integration before verification
- CLAUDE.md, AGENTS.md, and relevant skill files are consistent with docs 45 and 46
- Settler profile instructions exist as doctrine/instruction artifacts before any multiagent implementation

Constraint: this work unit (the architectural realignment documenting docs 45, 46, 17) is Phase A. WS-1 implementation is Phase B.

### WS-2: Local MCP server (healthos-mcp)

Objective: expose typed HealthOS repository-maintenance operations to Xcode Intelligence or any compatible MCP client, so Steward can invoke HealthOS-specific operations as structured tool calls.

Boundary constraint: `healthos-mcp` is the repository-maintenance MCP server only. It is outside the HealthOS clinical/runtime hierarchy. If HealthOS later uses MCP servers for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers and must not be named `healthos-mcp`. Do not collapse these two MCP families.

Settler boundary: `healthos-mcp` exposes operations for Steward and Settlers. Those operations are repository-maintenance operations. They are not clinical tools and do not execute HealthOS runtime acts.

Actions:
- build a local MCP server under a new or existing TS package
- expose typed operations:
  - `validate-all`
  - `validate-docs`
  - `scan-status`
  - `get-handoff`
  - `next-task`
  - `read-gap-register`
  - `generate-pr-review-draft`
  - `check-invariants`
  - `check-doc-drift`
- define typed error taxonomy per operation
- support dry-run mode for operations with side effects
- enforce: no secrets in logs, no clinical payloads in inputs/outputs, no direct HealthOS Core law mutation
- produce provenance-friendly output for repository-bound operations

Definition of done:
- Xcode Intelligence or compatible MCP client can invoke HealthOS-specific repository operations as structured tool calls
- typed errors and dry-run support are available
- operations do not move HealthOS clinical/constitutional law into tooling
- no production-readiness claim in any operation output

Constraint: WS-2 is Phase B work. Doc 45 describes the target boundary. This plan does not implement WS-2.

### WS-3: Deterministic CLI consolidation

Objective: keep `ts/packages/healthos-steward` narrow, deterministic, and CI-safe, while expanding the current hard-reset baseline into explicit repository-maintenance operations over time.

Actions:
- preserve the current baseline commands (`status`, `runtime`, `session`) until replacement operations are implemented
- remove or archive provider orchestration as primary architecture
- remove prompt-template-based pseudo-agent orchestration as primary interface
- add or restore deterministic repository operations deliberately rather than implying they already exist (`validate-docs`, `validate-all`, `scan-status`, `get-handoff`, `next-task`)
- optionally support Settlement records later, after the doctrine and record shape are defined
- keep Settlement support deterministic; the CLI does not implement multiagent intelligence by itself
- make CLI share operation implementations with MCP server where structurally possible once those operations exist
- ensure CLI works in CI/GitHub Actions without LLM dependency

Definition of done:
- CLI runs deterministic operations without LLM dependency
- CLI works in CI and GitHub Actions
- CLI preserves fail-closed semantics for every operation
- CLI does not claim agentic capability for deterministic operations
- provider-centric orchestration is not the primary entry point

Constraint: WS-3 is Phase B work. WS-3 must not reduce existing deterministic coverage while simplifying the architecture.

## Phased delivery (simplified)

### Phase A: Architecture realignment (this work unit)

Outputs:
- `docs/architecture/46-apple-sovereignty-architecture.md` created
- `docs/architecture/45-healthos-xcode-agent.md` rewritten to Xcode Intelligence extension posture
- `docs/execution/17-healthos-xcode-agent-migration-plan.md` rewritten (this document)
- `docs/architecture/44-project-steward-agent.md` marked as historical reference
- `docs/execution/02-status-and-tracking.md` updated
- `docs/execution/14-final-gap-register.md` GAP-003 reframed

Phase A is documentation and tracking only. No Swift, TypeScript, or schema source files are modified.

### Phase B: Extension implementation

Outputs:
- WS-1: `CLAUDE.md`, `AGENTS.md`, and skill files updated with consolidated HealthOS instructions
- Settler profiles exist as doctrine/instruction artifacts before any multiagent implementation
- WS-2: `healthos-mcp` local MCP server implemented with typed operations
- WS-3: deterministic CLI consolidated, provider orchestration removed as primary path
- validation docs updated to reflect new operations
- `make validate-docs` passes against updated doc set

Phase B may be executed in any order across WS-1, WS-2, WS-3. WS-1 is recommended first because it requires no new code and has the highest leverage for any agent working in the repository.

### Phase C: Steward retirement

Outputs:
- old provider and prompt orchestration in `ts/packages/healthos-steward` deprecated or removed
- deterministic CLI retained, renamed, or absorbed into the MCP server implementation as appropriate
- `docs/architecture/44-project-steward-agent.md` retained as historical reference; not deleted
- all active docs updated to reflect the current target (no references to the old 7-workstream custom runtime plan as a pending target)

Until Phase C is complete, documentation must distinguish clearly between:
- current delivered CLI baseline: `status`, `runtime`, `session`
- target deterministic repository operations: planned under WS-2 and WS-3, not yet delivered unless implemented and validated

Phase C is complete when the engineering-agent layer is consistent: Xcode Intelligence as the runtime surface, instructions/MCP/memory/CLI as the HealthOS contribution, and no active custom agent runtime work pending.

## What is preserved from the prior plan

The following concepts and patterns from the prior migration plan are preserved and adapted:

- PolicyGuard concept: reframed as instruction/boundary language consumed by Xcode Intelligence, typed MCP boundaries, and CLI checks (not a custom runtime enforcement entity)
- provider and backend error taxonomy: preserved for typed MCP operation errors if useful (not requiring custom agent runtime)
- provenance marker pattern: output of deterministic operations should carry provenance markers for repository-bound artifacts
- memory split:
  - repository memory: derived by HealthOS tooling under `.healthos-steward/memory/derived/`; never canonical truth
  - session memory: owned by Xcode Intelligence or the external assistant surface, not by HealthOS tooling
- fail-closed defaults: every boundary fails closed when policy is ambiguous
- honesty constraints: documented below; preserved unchanged

## What is descoped from the prior plan

The following targets from the prior migration plan are descoped as the primary architectural path:

- custom `AgentRuntime` TypeScript implementation as the primary engineering-agent target
- custom `ModelBackend` abstraction as the primary model routing layer
- custom `ToolRuntime` framework where MCP suffices for typed tool invocation
- custom Xcode conversation surface (Xcode Intelligence provides this natively)
- `ts/packages/healthos-agent-web` and the multi-package custom agent split
- multi-workstream custom runtime build (7 workstreams, 5 phases)

These are descoped as primary targets. If future evidence demonstrates that Xcode Intelligence is insufficient for a specific, documented HealthOS engineering need, a targeted custom surface may be scoped at that time. The justification must be documented explicitly.

## Acceptance criteria for target state

Target state is materially achieved when all are true:

- Xcode Intelligence integration posture is documented in docs 45 and 46 without false capability claims
- instructions and skills are consolidated (WS-1 complete): agent receives HealthOS-specific posture on entry
- MCP server exists and exposes typed repository operations (WS-2 complete)
- deterministic CLI works without LLM dependency and passes CI (WS-3 complete)
- official docs remain canonical; repository memory remains derived
- Steward has no authority over Core, GOS, or clinical runtime
- Settler profiles exist as doctrine/instruction artifacts before any multiagent implementation
- `make validate-docs` passes with no drift errors against updated doc set
- doc 44 is preserved as historical reference

## Honesty constraints during migration

During all phases:

- do not claim Xcode Intelligence integration before end-to-end verification is complete
- do not claim MCP server operation availability before the server is implemented and tested
- do not claim Claude/Codex/Xcode integration for specific capabilities unless verified from official documentation
- do not claim production readiness of any HealthOS component at any phase
- do not claim regulatory compliance at any phase
- do not claim that Apple substrate alone creates legal compliance; HealthOS Core governance is the governance layer
- do not claim non-Apple remote providers are impossible; they require explicit policy and degraded-sovereignty classification
- do not describe Xcode Intelligence as HealthOS-controlled; it is Apple-controlled
- do not describe Apple Intelligence as HealthOS Core; it is a distinct Apple service layer
