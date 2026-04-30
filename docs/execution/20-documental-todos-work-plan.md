# Work plan — documentary TODOs

Date: 2026-04-28.

## Purpose

This document lists every open documentation-writing TODO found in the repository as of this date, classifies each one, and prescribes an ordered execution plan for an AI coding agent to write them.

The plan covers only **documental tasks** — tasks whose primary deliverable is a written document, specification, schema description, or contract definition. Tasks whose primary deliverable is executable code are excluded even when they have a documentation component.

---

## Invariants (never violate)

1. HealthOS is the whole platform. HealthOScaffold is the historical repository name.
2. `healthos-mcp` is repository-maintenance MCP only — never clinical, never runtime authority.
3. Settler, Settlement, Territory records are engineering documents. They are not clinical agents, runtime actors, or authority records.
4. No maturity, production-readiness, or real-provider claim is made in any document.
5. Official docs (`docs/`) remain canonical. Repository-local roots (`.healthos-settler/`, `.healthos-territory/`) are derived and subordinate.
6. After each document is written, update `docs/execution/02-status-and-tracking.md` and the relevant `docs/execution/todo/*.md` in the same work unit.
7. Never mark a TODO done without concrete deliverable evidence.

---

## Classification

| ID | Task | File(s) to create or update | Type | Phase |
|----|------|------------------------------|------|-------|
| ST-006 | Define Territory record files | `.healthos-territory/territories/*.md` | Pure doc | 1 |
| ST-002 | Create Settler profile instruction files | `.healthos-settler/profiles/*.md` | Pure doc | 1 |
| ST-003 | Define Settlement record schema | `.healthos-settler/settlements/SCHEMA.md` | Pure doc | 1 |
| CL-006 | Shared error-envelope proposal | `docs/architecture/06-core-services.md` + optional schema | Architecture proposal | 2 |
| OPS-003 | Incident-response command set | `docs/architecture/14-operations-runbook.md` | Operations doc | 2 |
| ST-004 | Define healthos-mcp Settler operations | `docs/architecture/47-steward-settler-engineering-model.md` + `docs/execution/19-settler-model-task-tracker.md` | Architecture spec | 2 |
| Stream C (XA-004) | Tool runtime contracts | `docs/architecture/45-healthos-xcode-agent.md` + `docs/execution/18-healthos-xcode-agent-task-tracker.md` | Design spec | 3 |
| Stream D | Model backend layer contract | `docs/architecture/45-healthos-xcode-agent.md` + `docs/execution/18-healthos-xcode-agent-task-tracker.md` | Design spec | 3 |
| Stream F | Xcode context envelope | `docs/architecture/45-healthos-xcode-agent.md` + `docs/execution/18-healthos-xcode-agent-task-tracker.md` | Design spec | 3 |

---

## Phase 1 — Settler/Territory documentation

These tasks are self-contained, require no code, and are prerequisites for Phases 2 and 3.

### Task 1 of 9 — ST-006: Define Territory record files

**Source tracker**: `docs/execution/19-settler-model-task-tracker.md` → ST-006.

**Objective**: Create initial Territory records under `.healthos-territory/territories/`. Each record describes one documented repository domain so that a Settler profile or Steward can read it and stay within invariants.

**Territories to document** (derived from `docs/architecture/47-steward-settler-engineering-model.md`):

| Territory ID | Name | Primary canonical doc |
|---|---|---|
| `TERRITORY-CORE-LAW` | Core law | `docs/architecture/01-core-overview.md`, `docs/architecture/06-core-services.md` |
| `TERRITORY-STORAGE` | Storage and data layer | `docs/architecture/07-storage.md` |
| `TERRITORY-GOS` | Governance Operating System | `docs/architecture/08-gos.md` |
| `TERRITORY-AACI` | AACI runtime | `docs/architecture/10-aaci.md` |
| `TERRITORY-ASYNC-RUNTIME` | Async runtime | `docs/architecture/11-async-runtime.md` |
| `TERRITORY-PROVIDERS` | Providers and ML | `docs/architecture/16-providers-and-ml.md` |
| `TERRITORY-APPS` | Applications and interfaces | `docs/architecture/03-app-interfaces.md` |
| `TERRITORY-OPS` | Operations and observability | `docs/architecture/14-operations-runbook.md`, `docs/architecture/26-operator-observability-contract.md` |
| `TERRITORY-XCODE-TOOLING` | Xcode tooling and Steward | `docs/architecture/45-healthos-xcode-agent.md`, `docs/architecture/44-project-steward-agent.md` |
| `TERRITORY-DOCUMENTATION` | Documentation and execution governance | `docs/execution/README.md`, `docs/execution/10-invariant-matrix.md` |
| `TERRITORY-VALIDATION` | Validation and contracts | `docs/execution/06-scaffold-coverage-matrix.md`, `docs/execution/13-scaffold-release-candidate-criteria.md` |

**File pattern per territory**: `.healthos-territory/territories/<territory-id>.md`

**Required fields in each record** (from `.healthos-territory/territories/README.md`):
- `id` — machine-readable territory ID
- `name` — human-readable name
- `canonical-docs` — list of authoritative files
- `files-in-scope` — primary source paths
- `invariants` — non-negotiable rules that a Settler must preserve
- `skills` — relevant skill docs
- `tests` — test files that validate this territory
- `validation-commands` — make targets or test commands
- `forbidden-moves` — what an agent must never do in this territory
- `maturity` — current scaffold maturity level
- `known-gaps` — unresolved open questions or missing parts
- `owner-profile` — placeholder for future Settler profile reference

**Non-claims to include**: "This Territory record is subordinate to official docs. It does not grant authority, merge decisions, clinical access, or production-readiness."

**Tracking updates after completion**:
- Move ST-006 from TODO to COMPLETED in `docs/execution/19-settler-model-task-tracker.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**:
- All 11 Territory records exist under `.healthos-territory/territories/`.
- Each record contains all required fields.
- No record claims production readiness, clinical authority, or merge authority.

---

### Task 2 of 9 — ST-002: Create Settler profile instruction files

**Source tracker**: `docs/execution/19-settler-model-task-tracker.md` → ST-002.

**Objective**: Create profile instruction files for each initial Settler under `.healthos-settler/profiles/`. Each profile narrows one Settler's attention to one Territory and makes its invariants and forbidden moves explicit.

**Initial profiles to create**:

| Profile ID | Territory | Description |
|---|---|---|
| `settler-core-law` | TERRITORY-CORE-LAW | Settler for Core law schema, service boundaries, consent/habilitation/gate/finality |
| `settler-storage` | TERRITORY-STORAGE | Settler for storage layer, data contracts, lawfulContext guards |
| `settler-gos` | TERRITORY-GOS | Settler for GOS, compiler, mediation layer |
| `settler-aaci` | TERRITORY-AACI | Settler for AACI runtime, provider governance, capability signaling |
| `settler-ops` | TERRITORY-OPS | Settler for operations runbook, observability, incident response |
| `settler-apps` | TERRITORY-APPS | Settler for application surfaces, app-boundary contracts |
| `settler-xcode-tooling` | TERRITORY-XCODE-TOOLING | Settler for Steward, healthos-mcp, Xcode tooling streams |
| `settler-documentation` | TERRITORY-DOCUMENTATION | Settler for documentation drift, execution protocol, invariant matrix |
| `settler-validation` | TERRITORY-VALIDATION | Settler for coverage matrix, release criteria, contract validation |

**File pattern per profile**: `.healthos-settler/profiles/<profile-id>.md`

**Required fields in each profile** (from `.healthos-settler/profiles/README.md`):
- Territory assignment
- Canonical docs (read before acting)
- Files in scope
- Invariants (list, non-negotiable)
- Forbidden moves (explicit prohibitions)
- Validation expectations (what must pass before marking done)
- Maturity (doctrine-only / partially implemented / validated)
- Handoff requirements (what the Settler must produce before exiting)

**Non-claims to include**: "This Settler profile does not create a clinical agent, runtime actor, or HealthOS Core actor. The profile is an engineering instruction document."

**Dependency**: ST-006 complete (profiles reference Territory IDs).

**Tracking updates after completion**:
- Move ST-002 from TODO to COMPLETED in `docs/execution/19-settler-model-task-tracker.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**:
- All 9 profile files exist under `.healthos-settler/profiles/`.
- Each profile references a valid Territory ID from ST-006.
- No profile claims clinical authority or production readiness.

---

### Task 3 of 9 — ST-003: Define Settlement record schema

**Source tracker**: `docs/execution/19-settler-model-task-tracker.md` → ST-003.

**Objective**: Write a schema description document that defines the shape of a Settlement work unit. This is a documentation-only schema — not a JSON Schema or executable contract. The goal is to give future agents and humans a clear, unambiguous template when creating a Settlement record.

**File to create**: `.healthos-settler/settlements/SCHEMA.md`

**Required schema fields** (from `docs/execution/19-settler-model-task-tracker.md`, ST-2):
- `id` — unique settlement identifier (format: `SETTLEMENT-<YYYYMMDD>-<slug>`)
- `title` — short human-readable title
- `objective` — one-paragraph statement of what this Settlement delivers
- `territory` — Territory ID from ST-006
- `settler-profile` — Profile ID from ST-002
- `files-in-scope` — list of files the Settler may read and write
- `invariants` — non-negotiable rules inherited from Territory, plus any Settlement-specific additions
- `restrictions` — additional restrictions beyond Territory invariants
- `validation-commands` — make targets or test commands that must pass before marking done
- `done-criteria` — explicit list of deliverables that constitute completion
- `residual-gaps` — known unresolved questions or deferred work
- `handoff` — what is produced for the next agent (docs updated, tracking updated, PR description)
- `status` — one of: `DRAFT`, `IN-PROGRESS`, `COMPLETE`, `BLOCKED`

**Also include**:
- A completed example Settlement record to illustrate the schema (use a past completed work unit as the example, not a real clinical story).
- Non-claims section: "A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims."

**Tracking updates after completion**:
- Move ST-003 from TODO to COMPLETED in `docs/execution/19-settler-model-task-tracker.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**:
- `.healthos-settler/settlements/SCHEMA.md` exists and contains all fields with descriptions.
- An example Settlement record is included.
- No production-readiness or clinical claim is made.

---

## Phase 2 — Architecture proposals and operations documentation

These tasks extend existing architecture documents. They require reading the relevant arch doc before writing.

### Task 4 of 9 — CL-006: Shared error-envelope proposal for local service boundaries

**Source tracker**: `docs/execution/todo/core-laws.md` → CL-006.

**Objective**: Extend `docs/architecture/06-core-services.md` with a proposal section that defines whether denied/failure outputs share one transport envelope at the loopback HTTP seam. The goal is consistency: success, deny, and failure must be representable without ambiguity.

**Read before writing**:
- `docs/architecture/06-core-services.md` (current service boundary semantics)
- `docs/adr/0006-local-swift-ts-seam.md` (loopback HTTP seam decision)
- CL-004 outcome in `docs/execution/todo/core-laws.md` (deny/failure semantics)

**Content to add to `docs/architecture/06-core-services.md`**:

Add a new section `## Shared error envelope for local service boundaries` that covers:
1. The three outcome classes: success, deny (governed refusal), failure (runtime error).
2. Envelope shape proposal:
   - `status`: one of `ok` | `denied` | `error`
   - `code`: string code identifying the deny reason or error kind
   - `message`: human-readable explanation (non-sensitive, non-clinical)
   - `payload`: present only on `ok` responses
3. Transport contract:
   - HTTP 200 for `ok`
   - HTTP 403 for `denied` (governed refusal, not a crash)
   - HTTP 500 for `error` (runtime failure)
4. Invariants:
   - deny responses must never leak raw payload from the denied request
   - error responses must never leak stack traces to app-facing surfaces
   - both deny and error are fail-closed; they do not silently degrade to partial success

**Optional schema file**: If a JSON Schema is warranted, create `schemas/contracts/local-service-error-envelope.schema.json`. This is optional — only create it if the doc proposal is specific enough to warrant it.

**Tracking updates after completion**:
- Move CL-006 from READY to COMPLETED in `docs/execution/todo/core-laws.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Local service boundary can represent success, deny, and failure outcomes consistently. The proposal is written in `docs/architecture/06-core-services.md`.

---

### Task 5 of 9 — OPS-003: Define incident-response command set

**Source tracker**: `docs/execution/todo/ops-network-ml.md` → OPS-003.

**Objective**: Extend `docs/architecture/14-operations-runbook.md` with an explicit incident-response command vocabulary. An operator reading this section must be able to map a visible incident to a concrete action without ambiguity.

**Read before writing**:
- `docs/architecture/14-operations-runbook.md` (current runbook — OPS-001 outcome)
- `docs/architecture/26-operator-observability-contract.md` (visibility indicators and alert classes — OPS-002 outcome)
- `docs/execution/skills/network-fabric-skill.md`
- `docs/execution/skills/backup-restore-retention-export-skill.md`

**Incident categories to cover** (based on OPS-003 objective and existing runbook):
1. **Runtime failure** — service process down, health-check failing, critical error rate spike
2. **Queue saturation** — async job queue depth exceeding threshold, processing lag
3. **Backup concern** — backup job failure, integrity hash mismatch, retention policy violation
4. **Integrity incident** — provenance record mismatch, finality violation detected, unauthorized write attempt

**For each incident category, define**:
- Detection signal (which observability indicator or alert fires)
- Immediate operator action (concrete command or procedure)
- Escalation path (when to escalate and to whom)
- Recovery confirmation (what signal confirms resolution)
- Post-incident record (what must be recorded for audit)

**Add to `docs/architecture/14-operations-runbook.md`**:
A new section `## Incident-response command vocabulary` following the existing bootstrap and daily/weekly check sections.

**Tracking updates after completion**:
- Move OPS-003 from READY to COMPLETED in `docs/execution/todo/ops-network-ml.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Operator tooling can map visible incidents to explicit action vocabulary from this section.

---

### Task 6 of 9 — ST-004: Define healthos-mcp Settler operations spec

**Source tracker**: `docs/execution/19-settler-model-task-tracker.md` → ST-004.

**Objective**: Write a specification for the repository-maintenance MCP operations that Steward and Settlers will use via `healthos-mcp`. This is a design document — no implementation exists yet. The spec must stay outside the HealthOS clinical/runtime hierarchy.

**Read before writing**:
- `docs/architecture/47-steward-settler-engineering-model.md` (canonical model doc)
- `CLAUDE.md` (healthos-mcp boundary doctrine)
- `docs/execution/17-healthos-xcode-agent-migration-plan.md` (WS-2 definition)

**Operations to specify** (from canonical model doc + CLAUDE.md):
- `validate-docs` — runs `make validate-docs`, returns structured pass/fail with file list
- `validate-all` — runs `make validate-all`, returns structured pass/fail
- `scan-status` — reads `docs/execution/02-status-and-tracking.md` and returns current phase/status summary
- `next-task` — reads `docs/execution/todo/*.md` and returns highest-priority READY task
- `read-gap-register` — reads `docs/execution/14-final-gap-register.md` and returns open gaps
- `get-handoff` — reads `docs/execution/12-next-agent-handoff.md` and returns current handoff state
- `check-invariants` — reads `docs/execution/10-invariant-matrix.md` and verifies no contradictions in current code/docs
- `check-doc-drift` — compares current docs against code contracts, surfaces mismatches
- `generate-pr-review-draft` — produces a structured PR review template without posting it

**For each operation, specify**:
- Input parameters (typed)
- Output shape (structured, not free text)
- Error conditions and fail-closed behavior
- Dry-run support (operations must support `--dry-run`)
- Non-claims (operations do not move Core law into tooling, do not expose clinical payloads)

**Where to add this spec**:
- New section `## Operations specification` in `docs/architecture/47-steward-settler-engineering-model.md`
- Update `docs/execution/19-settler-model-task-tracker.md` → ST-004 with outcome

**Tracking updates after completion**:
- Move ST-004 from TODO to COMPLETED in `docs/execution/19-settler-model-task-tracker.md`.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Each operation has typed input, structured output, error conditions, and dry-run note. No clinical claim is made.

---

## Phase 3 — Xcode Agent stream design specifications

These tasks extend `docs/architecture/45-healthos-xcode-agent.md` and the Xcode Agent task tracker. They define the design contracts for unimplemented streams so that a future code-writing agent has a clear specification.

### Task 7 of 9 — Stream C (XA-004): Tool runtime contracts

**Source tracker**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream C.

**Objective**: Define structured tool contracts for the Steward tool runtime. A tool is a typed capability the runtime can invoke (file read, search, build, test). This is a design spec — no code is written.

**Read before writing**:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md` (WS-2 and WS-3 goals)
- `ts/agent-infra/healthos-steward/src/runtime/types.ts` (current runtime types baseline)

**Tool categories to specify**:
1. **File tools** — read file, list files, search files
2. **Search tools** — grep, find symbol, find references
3. **Build tools** — build project, get build log, list build errors
4. **Test tools** — run all tests, run specific tests, get test results
5. **Repository tools** — git status, git diff, read tracked file

**For each tool category, specify**:
- Tool capability name and identifier
- Input parameters (typed)
- Output shape
- Error conditions (tool unavailable, permission denied, build failed)
- Xcode-aware vs. generic variants
- Fail-closed behavior: a tool failure must not silently succeed

**Where to write**:
- New section in `docs/architecture/45-healthos-xcode-agent.md`: `## Tool runtime contracts`
- Update Stream C status in `docs/execution/18-healthos-xcode-agent-task-tracker.md`

**Tracking updates after completion**:
- Update Stream C in `docs/execution/18-healthos-xcode-agent-task-tracker.md` from TODO to design-complete.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Each tool category has typed input, output, and error conditions. Spec is sufficient for a code-writing agent to implement without clarification questions.

---

### Task 8 of 9 — Stream D: Model backend layer contract

**Source tracker**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream D.

**Objective**: Define the backend contract that subordinates a model backend to the runtime layer. The backend must not revive the old provider-centric architecture. This is a design spec.

**Read before writing**:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/18-healthos-xcode-agent-task-tracker.md` (working rules: do not reintroduce provider-centric architecture)
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

**Contract to specify**:
1. **Backend interface**: typed contract that the runtime calls, not a direct provider adapter
2. **Invocation path**: runtime → backend contract → backend implementation (backend is subordinate)
3. **Separation of concerns**: runtime owns session, policy, and tool selection; backend handles only model invocation
4. **Backend capability declaration**: backends must declare capabilities (streaming, tool-use support, context window limits) before invocation
5. **Failure modes**: backend unavailable, timeout, empty response, policy denial — all fail-closed
6. **Dry-run requirement**: every backend invocation must support dry-run mode
7. **No clinical payload**: backend inputs/outputs must not contain direct identifiers or clinical payloads

**Where to write**:
- New section in `docs/architecture/45-healthos-xcode-agent.md`: `## Model backend contract`
- Update Stream D status in `docs/execution/18-healthos-xcode-agent-task-tracker.md`

**Tracking updates after completion**:
- Update Stream D in `docs/execution/18-healthos-xcode-agent-task-tracker.md` from TODO to design-complete.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Backend contract separates model invocation from runtime orchestration. Spec is sufficient for a code-writing agent to implement.

---

### Task 9 of 9 — Stream F: Xcode context envelope

**Source tracker**: `docs/execution/18-healthos-xcode-agent-task-tracker.md` → Stream F.

**Objective**: Define the Xcode context envelope that bridges active file, selection, and diagnostics into runtime requests. This is a design spec for the Xcode conversation surface.

**Read before writing**:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/architecture/46-apple-sovereignty-architecture.md`
- `docs/execution/18-healthos-xcode-agent-task-tracker.md`

**Envelope to specify**:
1. **Context fields**:
   - `activeFile` — current file path and language
   - `selection` — selected text or cursor position
   - `diagnostics` — current compiler diagnostics (errors, warnings) for the active file
   - `buildState` — last known build state (passing / failing / unknown)
   - `projectName` — active Xcode project or workspace name
   - `targetName` — active build target

2. **Privacy invariants**:
   - The envelope must not contain clinical payloads, patient data, or direct identifiers
   - Diagnostic messages must be scrubbed of any content that could identify a patient
   - File paths must not leak user home directory structure beyond the project root

3. **Boundary**:
   - Xcode Intelligence is not HealthOS Core
   - The envelope is input to the Steward runtime, not to the HealthOS clinical runtime
   - Apple controls the Xcode Intelligence surface; HealthOS contributes instructions only

4. **Serialization**: the envelope must serialize to JSON for MCP transport

**Where to write**:
- New section in `docs/architecture/45-healthos-xcode-agent.md`: `## Xcode context envelope`
- Update Stream F status in `docs/execution/18-healthos-xcode-agent-task-tracker.md`

**Tracking updates after completion**:
- Update Stream F in `docs/execution/18-healthos-xcode-agent-task-tracker.md` from TODO to design-complete.
- Add outcome entry in `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Xcode context envelope fields are specified with privacy invariants. Spec is sufficient for a code-writing agent to implement the bridge.

---

## Execution rules for the AI agent executing this plan

1. **Sequence**: execute tasks in phase order (1 → 2 → 3). Within a phase, tasks may be executed in any order, but ST-006 must precede ST-002.

2. **Read before write**: for each task, read all listed docs before writing anything. Do not paraphrase from memory.

3. **Verify canonical docs exist**: before referencing a canonical doc path in a record, verify the file exists. If it does not exist, note the gap explicitly rather than inventing a path.

4. **Tracking**: after each task, update `docs/execution/02-status-and-tracking.md` and the relevant `docs/execution/todo/*.md` or tracker file. Do not batch updates.

5. **One commit per phase**: commit all files for a phase together in one coherent commit. Do not commit partial phases.

6. **Branch discipline**: all work in this plan happens on the active branch. Do not merge to main.

7. **Non-claims**: every new document must include a non-claims statement appropriate to its type. Never claim production readiness, clinical authority, or real provider integration.

8. **Ask if blocked**: if a task requires a canonical doc that is missing, a Territory that is not listed, or a design decision that is ambiguous — stop and note the open question in the task file rather than inventing an answer.

---

## Open questions (none as of this writing)

If any open questions arise during execution, record them here and in the relevant task's residual-gaps field.

---

## Artefatos de suporte criados

Os seguintes artefatos foram criados para apoiar a execução deste plano. Eles não são tarefas do plano — são ferramentas de execução.

### Prompts de fase (engenharia avançada de prompt)

Prompts auto-contidos prontos para execução por qualquer agente de IA, um por fase:

| Arquivo | Fase | Tarefas |
|---|---|---|
| `docs/execution/prompts/phase-1-settler-territory.md` | Phase 1 | ST-006, ST-002, ST-003 |
| `docs/execution/prompts/phase-2-architecture-proposals.md` | Phase 2 | CL-006, OPS-003, ST-004 |
| `docs/execution/prompts/phase-3-xcode-agent-streams.md` | Phase 3 | Stream C, D, F |

Cada prompt contém: identidade, invariantes absolutas, branch setup, leitura obrigatória, specs por tarefa, tracking requirements, workflow git, e definição de done.

### Automações Claude Code registradas

| Automação | Schedule | Arquivo de definição | O que faz |
|---|---|---|---|
| `update-claude-md` | Seg 09:03 | `.claude/automations/update-claude-md.md` | Atualiza CLAUDE.md com padrões descobertos |
| `daily-todo-tracker` | Diário 08:07 | `.claude/automations/daily-todo-tracker.md` | Digest diário de TODOs e status |
| `sync-work-plan` | Seg/Qua/Sex 08:47 | `.claude/automations/sync-work-plan.md` | Mantém este plano sincronizado com o estado real |

---

## Itens descobertos após criação do plano

### GAP-001 e GAP-002 — Resolução de contexto

**Fonte**: `docs/execution/14-final-gap-register.md`

GAP-001 (APP-008 — cross-app adapter propagation) e GAP-002 (OPS-003 — incident command set) estão marcados como `RESOLVED` no gap register para fins de scaffold RC closure. Isso **não significa** que as tarefas correspondentes no plano (Task 1/Phase 1 não relacionada; Task 5/Phase 2 — OPS-003) estão concluídas. Significa que o gap foi aceito como não-bloqueante para o RC do scaffold.

> **Impacto na prioridade**: OPS-003 (Task 5 deste plano) permanece valiosa para completude
> documental, mas já não bloqueia o scaffold RC. Pode ser executada depois de CL-006.

### DS-007, RT-008, AACI-009, APP-008 — Tarefas READY fora do escopo documental

**Fonte**: `docs/execution/todo/data-storage.md`, `runtimes-and-aaci.md`, `apps-and-interfaces.md`

Estas tarefas estão READY nos todo files mas **não fazem parte deste plano** por requererem código além de documentação. Estão registradas aqui para referência cruzada:

| ID | Domínio | Natureza |
|---|---|---|
| DS-007 | Data/storage | código Swift + docs |
| RT-008 | Runtimes/AACI | código Swift + docs |
| AACI-009 | Runtimes/AACI | código + docs |
| APP-008 | Apps | código Swift + docs |

---

## Status

Este plano está: **READY — não iniciado**.

Tarefas concluídas: 0 de 9.

Última sincronização: 2026-04-28 (primeira execução de sync-work-plan).
Próxima sincronização: automática — segunda/quarta/sexta 08:47.
