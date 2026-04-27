# HealthOS Xcode Agent migration plan

Date baseline: April 27, 2026.

## Goal

Transform Project Steward from a deterministic CLI plus optional provider orchestration scaffold into a repository-aware engineering agent runtime with:
- Xcode-native conversation surface
- CLI conversational surface
- tool-mediated inspection/edit/validate/review behavior
- durable session continuity and handoff

## Source architecture

Target architecture is defined in:
- `docs/architecture/45-healthos-xcode-agent.md`

Current-state scaffold remains documented in:
- `docs/architecture/44-project-steward-agent.md`

## Migration principles

- keep official docs as source of truth
- preserve fail-closed behavior at every phase
- do not over-claim autonomous capability before tools/session/runtime are real
- keep deterministic commands available while agent runtime matures
- prefer shared runtime under multiple surfaces rather than separate implementations

## Workstreams

### WS-1 Runtime refactor

Objective:
- make `agent runtime` the architectural center

Actions:
- introduce explicit runtime abstraction separate from provider adapters
- introduce explicit session abstraction
- introduce explicit tool registry / tool runtime abstraction
- reframe provider adapters as model backends

Definition of done:
- code no longer models the system primarily as provider invocation
- runtime can route one request through deterministic-only or tool-using flow

### WS-2 Model backend layer

Objective:
- keep external models pluggable without making them the core architecture

Actions:
- rename/reframe provider contracts toward backend contracts
- keep health/error taxonomy and dry-run behavior
- preserve explicit network gating

Definition of done:
- OpenAI/Anthropic/xAI integrations remain available behind a backend interface
- backend selection is decoupled from session/tool orchestration

### WS-3 Tool runtime layer

Objective:
- promote tools to first-class runtime components

Actions:
- define read/search/edit/build/test/review capabilities explicitly
- add Xcode-aware tool contracts
- distinguish tool failure, tool denial, and backend failure in logs

Definition of done:
- runtime can invoke tools as structured actions
- logs show which tools were used for a session step

### WS-4 Session and memory layer

Objective:
- support real conversational continuity

Actions:
- define session state model
- persist session/action history in derived memory
- formalize handoff generation from session + repo state
- separate repository-memory snapshots from session-memory continuity

Definition of done:
- an interrupted task can be resumed with meaningful continuity
- handoff is derived from recorded session state, not only static prompts

### WS-5 CLI conversational surface

Objective:
- make CLI a real surface over the new runtime

Actions:
- add interactive chat/repl entrypoint
- keep one-shot commands for automation
- expose resume/session/task/review/validate flows

Definition of done:
- CLI can operate as a conversational engineering agent, not only as command launcher

### WS-6 Xcode conversation surface

Objective:
- provide an Xcode-native experience comparable to the current coding-assistant conversation model

Actions:
- define bridge from Xcode context into runtime input
- pass active file, selection, diagnostics, and build state into session context
- render plans, actions, edits, and validations conversationally

Definition of done:
- the same runtime can be driven from an Xcode conversation surface with workspace-aware context

### WS-7 Optional local frontend

Objective:
- enable a richer conversation UI if needed without forking logic

Actions:
- expose runtime/session APIs usable by a local web or desktop shell
- reuse the same session/memory/action protocols

Definition of done:
- any frontend is just another surface over the same runtime

## Proposed package direction

Target package split:
- `ts/packages/healthos-agent-core`
- `ts/packages/healthos-agent-models`
- `ts/packages/healthos-agent-tools`
- `ts/packages/healthos-agent-memory`
- `ts/packages/healthos-agent-cli`
- `ts/packages/healthos-agent-xcode-surface`
- optional `ts/packages/healthos-agent-web`

Transition options:
1. migrate `ts/packages/healthos-steward` in place and keep package name temporarily
2. create new `healthos-agent-*` packages and keep `healthos-steward` as compatibility facade

Recommended default:
- create new runtime-oriented packages while keeping `healthos-steward` as transition shell until command parity exists

## Suggested runtime entities

Core runtime entities:
- `AgentRuntime`
- `AgentSession`
- `ConversationSurface`
- `ModelBackend`
- `ToolRuntime`
- `PolicyGuard`
- `ActionRecord`
- `SessionSnapshot`

## Suggested CLI shape

```bash
healthos-agent chat
healthos-agent task next
healthos-agent review diff
healthos-agent review pr --pr <n>
healthos-agent validate
healthos-agent session list
healthos-agent session resume <id>
healthos-agent handoff generate
```

Compatibility commands may remain under `healthos-steward` during transition.

## Suggested Xcode surface context envelope

Minimum context envelope from Xcode:
- active file
- selected text
- visible diagnostics
- active scheme/workspace context when available
- recent build/test summary when available
- explicit user message

The runtime should decide what else to load.

## Memory evolution

Current `.healthos-steward/` should evolve toward:

```text
.healthos-steward/
  memory/
    derived/
    sessions/
    handoffs/
    state/
  policies/
  prompts/
  schemas/
```

Near-term rule:
- do not delete existing memory files abruptly
- migrate by adding structured directories and compatibility readers

## Phased delivery

### Phase A - architecture and compatibility shell

Outputs:
- target docs approved
- runtime/entity contracts introduced
- current steward docs updated to transitional posture

### Phase B - internal runtime extraction

Outputs:
- runtime/session/tool abstractions implemented
- provider layer reframed as model backends
- compatibility CLI still works

### Phase C - conversational CLI

Outputs:
- interactive chat surface
- resumable sessions
- action logs and handoff generation

### Phase D - Xcode surface

Outputs:
- Xcode-aware conversation integration
- active-file/selection/diagnostics context feed
- shared runtime behavior with CLI

### Phase E - cleanup and deprecation

Outputs:
- obsolete provider-centric command shapes retired or clearly marked compatibility-only
- docs and memory layout normalized around agent runtime model

## Acceptance criteria for target state

The target architecture is materially achieved only when all are true:
- the central runtime abstraction is session/tool oriented, not prompt/provider oriented
- CLI and Xcode surfaces use the same runtime
- session continuity and handoff are real runtime artifacts
- tool invocation is explicit, structured, and logged
- backend selection is pluggable and subordinate to runtime orchestration
- official docs remain canonical and fail-closed policy remains intact

## Immediate next implementation steps

1. Update steward architecture docs to mark current model as transitional.
2. Define TypeScript contracts for runtime/session/surface/tool/backend.
3. Add compatibility facade mapping old CLI commands onto new runtime entrypoints.
4. Design session storage format under `.healthos-steward/memory/sessions/`.
5. Implement CLI chat surface before attempting frontend richness.
6. Only then build Xcode-native conversation integration.

## Honesty constraints during migration

Do not claim:
- a real Xcode agent before Xcode surface context is actually wired
- conversational continuity before session persistence exists
- tool-using intelligence before structured tool execution is implemented
- autonomous engineering behavior when flows are still prompt scaffolds
