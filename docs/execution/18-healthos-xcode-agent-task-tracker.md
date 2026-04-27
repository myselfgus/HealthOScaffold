# HealthOS Xcode Agent task tracker

Date baseline: April 27, 2026.

This file exists to keep the Xcode Agent initiative coherent across multiple work units.

Canonical architecture docs:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

Current implementation root:
- `ts/packages/healthos-steward/`

## Objective

Evolve Project Steward into a repository-aware engineering agent with:
- Xcode-native conversation surface
- CLI conversational surface
- session continuity
- explicit tool runtime
- model backends subordinate to an agent runtime

## Working rules

- official docs remain canonical
- memory remains derived
- no false claims of autonomy or production readiness
- every work unit must update this tracker and `02-status-and-tracking.md`
- keep compatibility with current steward commands until replacement paths exist

## Streams

### Stream A — Runtime core
Status: IN PROGRESS
Target:
- define `AgentRuntime`, `AgentSession`, `PolicyGuard`, `ActionRecord`
Next steps:
- introduce initial TS contracts
- add minimal runtime orchestration helpers
- map deterministic steward operations into runtime-compatible shapes

### Stream B — Model backends
Status: TODO
Target:
- reframe provider layer as model backend layer
Next steps:
- define backend-neutral contract
- adapt current provider types to backend compatibility model
- preserve explicit network/error/dry-run behavior

### Stream C — Tool runtime
Status: TODO
Target:
- define structured tool capabilities for read/search/edit/build/test/review
Next steps:
- create tool contract set
- represent Xcode-aware capabilities explicitly
- attach tool action logging model

### Stream D — Session memory
Status: TODO
Target:
- persist session state and resumable handoff
Next steps:
- define session snapshot format
- create `.healthos-steward/memory/sessions/` layout
- connect session state to handoff generation

### Stream E — CLI conversation surface
Status: TODO
Target:
- interactive CLI over shared runtime
Next steps:
- define REPL command shape
- wire one-shot and interactive paths to same runtime

### Stream F — Xcode conversation surface
Status: TODO
Target:
- workspace-aware surface comparable to the current coding assistant interaction
Next steps:
- define context envelope for active file/selection/diagnostics
- define surface-to-runtime bridge
- attach session rendering expectations

### Stream G — Optional frontend
Status: TODO
Target:
- local frontend using same runtime/session API
Next steps:
- decide if this follows CLI/Xcode surface or remains optional

## Open decisions

1. Keep package name `@healthos/steward` during migration or introduce `@healthos/agent-*` split first.
2. Decide whether the first live conversational surface should be CLI or Xcode-first.
3. Decide when to create persistent session directories under `.healthos-steward/memory/`.
4. Decide whether compatibility commands stay in the same package or move to facade layer.

## Active queue

### XA-001 Create dedicated initiative tracker and target docs linkage
Status: DONE
Outcome:
- tracker created
- architecture and migration docs already linked here

### XA-002 Introduce initial runtime-centric TypeScript contracts
Status: DONE
Goal:
- land the first concrete code entities for runtime/session/surface/tool/backend
Primary files:
- `ts/packages/healthos-steward/src/agent/*`
- `ts/packages/healthos-steward/src/index.ts`
Definition of done:
- package exports initial agent runtime contracts
- implementation is additive and compatible with current steward
Notes:
- initial types, default guards, session snapshot helpers, and minimal runtime executor created
- package root now exports the first agent runtime API surface

### XA-003 Introduce first minimal runtime implementation helpers
Status: IN PROGRESS
Goal:
- create non-provider-centric runtime assembly path
Definition of done:
- a caller can construct runtime configuration and session state without going through provider CLI commands

### XA-004 Reframe current provider layer as backend compatibility layer
Status: TODO
Goal:
- stop treating provider types as the central architecture in new code

### XA-005 Define session persistence layout
Status: TODO
Goal:
- choose file structure and compatibility story for session continuity

## Change log

### 2026-04-27
- initiative tracker created
- migration effort formally split into streams and queued tasks
- first implementation work started under XA-002
- initial runtime-centric TS code landed under `src/agent/` with exported contracts and minimal executor helpers
- validation scaffold test file added for future build/test execution
