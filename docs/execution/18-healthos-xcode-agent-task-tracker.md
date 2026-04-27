# HealthOS Xcode Agent task tracker

Date baseline: April 27, 2026.

Tracker location for future work units:
- `docs/execution/18-healthos-xcode-agent-task-tracker.md`

Canonical architecture docs:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

Current implementation root:
- `ts/packages/healthos-steward/`

## Current truth

The previous provider-centric `healthos-steward` implementation was removed.

The package was reset from scratch and now contains only a new baseline centered on:
- runtime requests/responses
- session persistence
- surface identity
- future tool/backend expansion

There is no legacy runtime preserved inside the package.

## Active baseline

Implemented now:
- minimal CLI with `status`, `runtime`, and `session`
- runtime request/session model in TypeScript
- file-backed session store at `.healthos-steward/memory/sessions/`
- package reset README and fresh package exports

Not implemented yet:
- tool runtime
- model backend integration
- conversational CLI loop
- Xcode surface bridge
- session resume/list ergonomics beyond direct id lookup

## Working rules

- official docs remain canonical
- memory remains derived
- no false autonomy/production claims
- every work unit must update this tracker and `docs/execution/02-status-and-tracking.md`
- do not reintroduce provider-centric architecture into the package

## Streams

### Stream A — Runtime core
Status: IN PROGRESS
Next steps:
- expand runtime beyond simple request acceptance
- add stronger action/state transitions
- add explicit policy guard layer into the new baseline

### Stream B — Session model
Status: IN PROGRESS
Next steps:
- support session listing
- support session resume ergonomics
- define handoff generation from persisted session state

### Stream C — Tool runtime
Status: TODO
Next steps:
- define structured tool contracts
- add file/read/search/build/test capability model
- add Xcode-aware tool capability vocabulary

### Stream D — Model backend layer
Status: TODO
Next steps:
- define backend contract subordinate to runtime
- integrate backend invocation without reviving old provider architecture

### Stream E — CLI conversation surface
Status: TODO
Next steps:
- add interactive conversation mode
- share session lifecycle with one-shot commands

### Stream F — Xcode conversation surface
Status: TODO
Next steps:
- define Xcode context envelope
- bridge active file, selection, and diagnostics into runtime requests

## Active queue

### XA-001 Hard reset package from scratch
Status: DONE
Outcome:
- removed old `src`, `test`, and `dist`
- removed old provider-centric implementation from package runtime
- recreated clean baseline files only

### XA-002 Establish minimal runtime/session baseline
Status: DONE
Outcome:
- `src/runtime/types.ts`
- `src/runtime/session-store.ts`
- `src/runtime/runtime.ts`
- `src/steward.ts`
- `src/index.ts`
- `src/cli.ts`
- `test/runtime.test.mjs`

### XA-003 Add session lifecycle ergonomics
Status: NEXT
Goal:
- add list/resume-friendly commands and richer session summaries

### XA-004 Add tool runtime contracts
Status: NEXT
Goal:
- introduce explicit tool model for file/xcode/build/test actions

### XA-005 Add first conversational CLI mode
Status: NEXT
Goal:
- move beyond one-shot runtime requests into continuous conversation

## Change log

### 2026-04-27
- tracker created
- target architecture and migration docs created
- package `ts/packages/healthos-steward/` hard-reset from scratch
- new runtime/session baseline created
- session storage directory established at `.healthos-steward/memory/sessions/`
