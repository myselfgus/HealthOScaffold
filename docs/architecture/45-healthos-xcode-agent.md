# 45) HealthOS Xcode Agent (target architecture)

## Purpose

HealthOS Xcode Agent is the target evolution of Project Steward from a prompt-and-provider scaffold into a real engineering agent runtime.

It remains:
- an engineering tool inside this repository
- subordinate to official repository docs and invariants
- non-clinical, non-constitutional, and non-authorizing

It serves the HealthOS construction repository. Any future migration must preserve that HealthOScaffold is the historical repository name for HealthOS work, with scaffold terminology limited to maturity.

It is intended to provide:
- repository-aware conversational interaction
- Xcode-native workspace intelligence
- deterministic and agentic execution modes
- tool-mediated inspection, editing, validation, and review
- persistent session continuity and handoff

## Why the current steward model is not enough

The current steward is centered on deterministic CLI commands plus optional LLM provider invocation.

That model is insufficient for the desired system because it treats intelligence as a text provider instead of a workspace-capable agent. The desired runtime must understand:
- the active file and selection
- project structure and diagnostics
- build/test status
- repository policies and official docs
- session continuity across engineering work

A provider-only model does not accurately represent those capabilities.

## Constitutional boundaries

HealthOS Xcode Agent must never be treated as:
- Core law
- AACI runtime
- GOS authority
- a clinical actor
- a merge approver or gate resolver

It may recommend, inspect, edit, validate, and summarize. It may not redefine constitutional boundaries or claim product/legal maturity that does not exist.

## Architectural shift

The architectural center moves from `provider invocation` to `agent runtime`.

Old center:
- prompt -> provider -> text output

New center:
- conversation surface -> agent runtime -> model backend + tools + memory + policy guards -> incremental output/actions

## Target runtime model

```text
Conversation Surface
  -> Agent Session
    -> Agent Runtime
      -> Policy Guards
      -> Memory / Context Assembly
      -> Model Backend
      -> Tool Runtime
      -> Action Log / Handoff / Validation Trail
```

## Core subsystems

### 1. Conversation surfaces

A surface is how an operator interacts with the agent.

Required surfaces:
- Xcode conversation surface
- CLI conversational surface

Optional future surface:
- local web/frontend surface

A surface is responsible for:
- collecting user input
- passing active context (file, selection, diagnostics, diff, phase docs)
- rendering streaming output, plan state, actions, and results
- resuming sessions

A surface is not responsible for repository reasoning or policy evaluation.

### 2. Agent runtime

The runtime is the central orchestrator.

It is responsible for:
- intent classification
- context assembly from official docs and active workspace state
- choosing deterministic vs agentic execution path
- invoking model backends when needed
- invoking tools when needed
- sequencing read/plan/edit/validate/review work
- updating memory/handoff/action logs
- enforcing fail-closed behavior

The runtime becomes the primary system concept. Everything else serves it.

### 3. Tool runtime

Tools are first-class and explicit.

Required tool groups:
- Xcode/workspace tools
- repository read/search tools
- build/test/validation tools
- diff/review tools
- optional GitHub/PR tools

Tool execution must be:
- capability-declared
- logged
- fail-closed on denial/unavailability
- distinguishable from pure model output

### 4. Model backends

Model backends provide intelligence but are no longer the architectural center.

Examples:
- OpenAI
- Anthropic
- xAI
- future local models

A model backend is only responsible for:
- inference
- structured output/tool-call output when supported
- backend health and error classification

It is not responsible for session memory, repo truth, or workflow orchestration.

### 5. Memory and session continuity

Memory remains derived, never canonical.

The target system needs two kinds of memory:
- repository memory: durable derived index over docs, state, gaps, validations, and known constraints
- session memory: conversational and action continuity for one engineering thread

Required memory outputs:
- session transcript or action history
- next-agent handoff snapshot
- derived gap/state sync notes
- validation trail

## Target entity model

### Model backend

Represents an inference engine.

Example concerns:
- backend id
- model id
- network policy
- tool-call capability
- structured output capability
- timeout and error taxonomy

### Tool runtime

Represents executable workspace capabilities.

Example concerns:
- xcode diagnostics/build/test
- file read/search/update
- git diff/status
- validation harness
- GitHub review ingestion/commenting

### Agent session

Represents one conversational work thread.

Example concerns:
- session id
- active mode
- active plan
- attached context refs
- action log
- current handoff state

### Conversation surface

Represents a user-facing interface.

Example kinds:
- `xcode-conversation`
- `cli-repl`
- `web-chat`

### Policy guard

Represents fail-closed repository-level behavioral enforcement.

Must enforce:
- official docs are source of truth
- no false production/provider/legal claims
- no clinical payloads in steward memory/logs
- no unapproved authority escalation
- no silent drift over tracking docs

## Required operating modes

### Chat mode

Conversational response with repository context and no file mutation by default.

### Inspect mode

Repository inspection, doc lookup, architecture reading, and issue explanation.

### Plan mode

Task selection, migration planning, next-step generation, and handoff creation.

### Edit mode

Explicit file changes with action trace.

### Validate mode

Build/test/check execution with summarized outcomes.

### Review mode

Diff review, PR review, drift review, and repository audit.

### Sync mode

Derived memory synchronization against official docs.

## Xcode-native surface requirements

The Xcode surface must be able to attach or infer:
- active file path
- selected text
- workspace or scheme context
- visible diagnostics/build issues
- recent build/test output when available

Expected UX:
- chat-style conversation
- visible plan and action progression
- explicit file edits and validation steps
- resumable context

This surface should feel like a real engineering conversation, not a prompt launcher.

## CLI surface requirements

The CLI must support both one-shot and interactive modes.

Required CLI patterns:
- `healthos-agent chat`
- `healthos-agent task next`
- `healthos-agent review diff`
- `healthos-agent validate`
- `healthos-agent session resume <id>`

CLI should expose the same runtime, not a separate implementation.

## Optional local frontend

A local frontend is acceptable if it uses the same runtime and session model.

Possible form factors:
- lightweight local web app
- desktop shell
- custom Xcode-adjacent panel if not embedded directly

The frontend must not invent a second source of truth for repository memory.

## Package/layout direction

Suggested package split:
- `ts/packages/healthos-agent-core`
- `ts/packages/healthos-agent-models`
- `ts/packages/healthos-agent-tools`
- `ts/packages/healthos-agent-memory`
- `ts/packages/healthos-agent-cli`
- `ts/packages/healthos-agent-xcode-surface`
- optional `ts/packages/healthos-agent-web`

The current `ts/packages/healthos-steward` may be migrated incrementally or retained temporarily as a compatibility shell.

## `.healthos-steward/` evolution

Retain `.healthos-steward/` as the repository-local state root, but evolve structure toward:

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
  surfaces/
  models/
```

Prompts remain helper templates, not the center of the system.

## Observability and audit

The target runtime must record:
- session id
- action type
- tools invoked
- changed files
- validation commands
- model/backend used
- dry-run vs live execution
- failures and denials

Logs must stay free of secrets and clinical payloads.

## Compatibility and migration stance

The current steward is still valid as an engineering scaffold, but it should be treated as transitional.

Near-term compatibility is acceptable when it helps migration, but the end state is not:
- provider-centric orchestration
- prompt-only pseudo-agent behavior
- command aliases that simulate missing agent capabilities

## Non-goals

This target architecture does not imply:
- product UI completion for HealthOS apps
- external provider maturity claims
- autonomous merge authority
- replacement of human gate/review/accountability
- conversion of repository memory into canonical truth

## Implementation standard

Any implementation of this architecture must preserve:
- fail-closed behavior
- explicit capability boundaries
- repository truthfulness
- action traceability
- official docs precedence
- separation of engineering tooling from constitutional runtime behavior
