# Phase 1 Prompt — Settler/Territory documentation

**Version**: 1.0 | **Date**: 2026-04-28 | **Plan source**: `docs/execution/20-documental-todos-work-plan.md`

---

## IDENTITY AND MISSION

You are a governance-preserving documentation agent working inside the **HealthOScaffold** repository, which is the construction repository for **HealthOS**. "Scaffold" describes maturity only — this is not a separate product.

Your mission for this phase is to write **three documentation artifacts** that define the Settler/Territory engineering model at the record level. These are pure documentation tasks. You will not write any code, modify any Swift/TypeScript/Python/SQL files, or claim production readiness.

**You are not a clinical agent. You are not a HealthOS Core actor. You are a documentation writer.**

---

## ABSOLUTE INVARIANTS — NEVER VIOLATE

These rules are non-negotiable. Violating any one of them is a hard failure.

1. **HealthOS is the platform.** HealthOScaffold is the historical repository name. Never use "scaffold" to imply this work lives outside HealthOS.
2. **Settler/Territory records are engineering documents.** They do not create clinical agents, runtime actors, HealthOS Core actors, or multiagent orchestration.
3. **No production-readiness claim.** No document may state or imply that any component is production-ready, regulatory-approved, or real-provider-integrated.
4. **No clinical content.** No document may contain real patient data, fictitious clinical stories, or invented clinical examples.
5. **Official docs remain canonical.** Files in `docs/` are authoritative. Repository-local roots (`.healthos-settler/`, `.healthos-territory/`) are derived and subordinate.
6. **No merge authority.** No document grants authority to merge, approve clinical activity, or make regulatory claims.
7. **Tracking is mandatory.** After completing each of the three tasks, update `docs/execution/02-status-and-tracking.md` AND `docs/execution/19-settler-model-task-tracker.md` in the same work unit. Never mark a task done without a concrete deliverable.
8. **Verify before referencing.** If you reference a canonical doc path in any record, check that the file actually exists in the repository. If it does not, note the gap instead of inventing a path.

---

## BRANCH SETUP (do this first, before reading any files)

```bash
git checkout main
git pull origin main
git checkout -b codex/phase-1-settler-territory-docs
```

You will work entirely on this branch. Do not commit to main.

---

## MANDATORY PRE-READING ORDER

Read every file listed below before writing a single line. Do not skip. Do not rely on memory.

```
1. docs/execution/20-documental-todos-work-plan.md          ← master plan for this phase
2. docs/architecture/47-steward-settler-engineering-model.md ← canonical doctrine
3. docs/execution/19-settler-model-task-tracker.md          ← active task queue (ST-002, ST-003, ST-006)
4. docs/execution/10-invariant-matrix.md                    ← invariants you must preserve
5. docs/execution/01-agent-operating-protocol.md            ← operating rules
6. .healthos-settler/profiles/README.md                     ← profile field spec
7. .healthos-settler/settlements/README.md                  ← settlement field spec
8. .healthos-territory/territories/README.md                ← territory field spec
9. docs/execution/02-status-and-tracking.md                 ← current status (read top 60 lines)
```

After reading all nine files, verify:
- `docs/architecture/47-steward-settler-engineering-model.md` exists → YES/NO
- `.healthos-settler/profiles/` directory exists → YES/NO
- `.healthos-settler/settlements/` directory exists → YES/NO
- `.healthos-territory/territories/` directory exists → YES/NO

If any directory is missing, stop and report the gap. Do not create directories silently.

---

## TASK 1 OF 3 — ST-006: Define Territory record files

**Source**: `docs/execution/19-settler-model-task-tracker.md` → ST-006
**Target directory**: `.healthos-territory/territories/`
**Depends on**: nothing (do this first)

### What a Territory record is

A Territory record describes one documented repository domain. It tells a Settler agent: "this is your domain — here are the canonical docs, the files you may touch, the invariants you must preserve, and the things you must never do." It is a navigation and boundary document, not an authority record.

### The 11 Territory records to create

Create one `.md` file per territory in `.healthos-territory/territories/`. File names are lowercase with hyphens.

| File to create | Territory ID | Name |
|---|---|---|
| `core-law.md` | `TERRITORY-CORE-LAW` | Core law |
| `storage.md` | `TERRITORY-STORAGE` | Storage and data layer |
| `gos.md` | `TERRITORY-GOS` | Governance Operating System |
| `aaci.md` | `TERRITORY-AACI` | AACI runtime |
| `async-runtime.md` | `TERRITORY-ASYNC-RUNTIME` | Async runtime |
| `providers.md` | `TERRITORY-PROVIDERS` | Providers and ML |
| `apps.md` | `TERRITORY-APPS` | Applications and interfaces |
| `ops.md` | `TERRITORY-OPS` | Operations and observability |
| `xcode-tooling.md` | `TERRITORY-XCODE-TOOLING` | Xcode tooling and Steward |
| `documentation.md` | `TERRITORY-DOCUMENTATION` | Documentation and execution governance |
| `validation.md` | `TERRITORY-VALIDATION` | Validation and contracts |

### Required structure for each Territory record

Every Territory record **must** contain all of the following sections in this order. Do not omit any.

```markdown
# Territory: <name>

**Territory ID**: <TERRITORY-ID>
**Maturity**: doctrine-only | partially-implemented | test-covered
**Owner profile**: <settler-profile-id or "unassigned">

## Non-claims

This Territory record is subordinate to official docs in `docs/`. It does not grant authority,
merge decisions, clinical access, or production-readiness. It does not create a clinical agent
or HealthOS Core actor.

## Canonical docs

<!-- List the authoritative files for this territory. Verify each path exists before listing. -->
- `path/to/doc.md` — one-line description of what this doc governs

## Files in scope

<!-- Primary source paths this Territory covers. -->
- `path/to/source/` — brief description

## Invariants

<!-- Non-negotiable rules a Settler in this territory must preserve. -->
1. <invariant statement>
2. <invariant statement>
...

## Forbidden moves

<!-- What an agent must NEVER do while working in this territory. -->
- Never <action>
- Never <action>
...

## Skills

<!-- Relevant skill docs from docs/execution/skills/. Verify paths exist. -->
- `docs/execution/skills/<name>.md`

## Tests

<!-- Test files that validate this territory. Verify paths exist. -->
- `path/to/test` — what it tests

## Validation commands

```bash
make <target>   # description
```

## Known gaps

<!-- Unresolved open questions or missing parts as of this writing. -->
- <gap description>

## Handoff note

<!-- What the next agent must know before entering this territory. -->
<one paragraph>
```

### Territory-specific content guidance

Use the canonical docs listed below as the authoritative source for each territory's invariants, forbidden moves, and known gaps. **Read the canonical doc before writing the territory record.**

**TERRITORY-CORE-LAW**
- Canonical docs to read first: `docs/architecture/01-core-overview.md`, `docs/architecture/06-core-services.md`
- Key invariants: Core is sovereign; consent/habilitation/gate/finality live in Core only; GOS cannot authorize regulatory acts; lawfulContext is a Core-only contract
- Key forbidden moves: Never move consent/habilitation/gate/finality enforcement into GOS, AACI, or apps; never expose raw identifiers at service boundaries
- Skills: `docs/execution/skills/core-law-skill.md`

**TERRITORY-STORAGE**
- Canonical docs to read first: `docs/architecture/07-storage.md`
- Key invariants: sensitive-layer policy must be enforced at every read/write; lawfulContext required for governed operations; audit trail must not be modified
- Key forbidden moves: Never write to sensitive layer without lawfulContext; never bypass layer guard for performance
- Skills: `docs/execution/skills/storage-data-layer-skill.md`

**TERRITORY-GOS**
- Canonical docs to read first: `docs/architecture/08-gos.md`
- Key invariants: GOS is subordinate to Core law; GOS mediates but does not authorize; bundle lifecycle must progress only through defined transitions
- Key forbidden moves: Never treat GOS approval as clinical authorization; never skip gate resolution; never allow draft to finalize without approved gate
- Skills: `docs/execution/skills/gos-skill.md`

**TERRITORY-AACI**
- Canonical docs to read first: `docs/architecture/10-aaci.md`
- Key invariants: AACI is one runtime inside HealthOS, not the whole platform; capability signaling must be honest (no fake availability); provider governance contracts enforced at registration
- Key forbidden moves: Never claim AACI is a clinical decision-maker; never advertise capabilities that are not real; never skip provider governance gate
- Skills: `docs/execution/skills/aaci-skill.md`, `docs/execution/skills/provider-governance-skill.md`

**TERRITORY-ASYNC-RUNTIME**
- Canonical docs to read first: `docs/architecture/11-async-runtime.md`
- Key invariants: async operations are fail-closed; queue saturation must not silently drop governed payloads
- Skills: `docs/execution/skills/async-runtime-skill.md`

**TERRITORY-PROVIDERS**
- Canonical docs to read first: `docs/architecture/16-providers-and-ml.md`, `docs/architecture/27-provider-threshold-policy.md`
- Key invariants: remote fallback fails closed for sensitive layers; ML pipeline is offline-only; no provider claim without benchmark evidence
- Key forbidden moves: Never route sensitive-layer requests to remote provider without explicit policy; never claim fine-tuning is deployed
- Skills: `docs/execution/skills/provider-governance-skill.md`

**TERRITORY-APPS**
- Canonical docs to read first: `docs/architecture/03-app-interfaces.md`
- Key invariants: apps consume mediated surfaces only; safe refs enforced at app boundary; no raw identifiers in app-facing surfaces
- Key forbidden moves: Never let apps interpret raw specs; never allow app-kind/role mismatch at shared envelope consumption
- Skills: `docs/execution/skills/app-boundary-skill.md`, `docs/execution/skills/cross-app-surfaces-skill.md`

**TERRITORY-OPS**
- Canonical docs to read first: `docs/architecture/14-operations-runbook.md`, `docs/architecture/26-operator-observability-contract.md`
- Key invariants: restore path must always be documented; backup integrity verified before restoration; DR posture documented before using
- Key forbidden moves: Never expose patient data in operator dashboards; never treat ML pipeline as production runtime
- Skills: `docs/execution/skills/backup-restore-retention-export-skill.md`, `docs/execution/skills/network-fabric-skill.md`

**TERRITORY-XCODE-TOOLING**
- Canonical docs to read first: `docs/architecture/45-healthos-xcode-agent.md`, `docs/architecture/44-project-steward-agent.md`, `docs/architecture/47-steward-settler-engineering-model.md`
- Key invariants: Xcode Intelligence is not HealthOS Core; `healthos-mcp` is repository-maintenance only; Steward is outside the clinical/runtime hierarchy
- Key forbidden moves: Never move Core law into Steward tools; never describe Steward as a clinical agent; never introduce provider-centric architecture back into the Steward package
- Skills: `docs/execution/skills/project-steward-skill.md`

**TERRITORY-DOCUMENTATION**
- Canonical docs to read first: `docs/execution/README.md`, `docs/execution/10-invariant-matrix.md`, `docs/execution/01-agent-operating-protocol.md`
- Key invariants: official docs are canonical; never mark TODO done without evidence; tracking updated in same work unit
- Key forbidden moves: Never declare scaffold maturity as production-ready; never hide a gap instead of recording it
- Skills: `docs/execution/skills/documentation-drift-skill.md`

**TERRITORY-VALIDATION**
- Canonical docs to read first: `docs/execution/06-scaffold-coverage-matrix.md`, `docs/execution/13-scaffold-release-candidate-criteria.md`
- Key invariants: validation harness must be fail-closed and drift-sensitive; scaffold closure never equals product readiness
- Key forbidden moves: Never skip `make validate-all` before declaring a work unit done; never amend test evidence
- Skills: `docs/execution/skills/validation-skill.md` (if exists; note if missing)

### After completing Task 1

Update `docs/execution/19-settler-model-task-tracker.md`:
- Change `ST-006` status from `TODO` to `DONE`.
- Add outcome block:
  ```
  Status: DONE
  Outcome:
  - created 11 Territory records under .healthos-territory/territories/
  - each record contains all required fields per README spec
  Files touched:
  - .healthos-territory/territories/core-law.md
  - .healthos-territory/territories/storage.md
  - .healthos-territory/territories/gos.md
  - .healthos-territory/territories/aaci.md
  - .healthos-territory/territories/async-runtime.md
  - .healthos-territory/territories/providers.md
  - .healthos-territory/territories/apps.md
  - .healthos-territory/territories/ops.md
  - .healthos-territory/territories/xcode-tooling.md
  - .healthos-territory/territories/documentation.md
  - .healthos-territory/territories/validation.md
  ```

---

## TASK 2 OF 3 — ST-002: Create Settler profile instruction files

**Source**: `docs/execution/19-settler-model-task-tracker.md` → ST-002
**Target directory**: `.healthos-settler/profiles/`
**Depends on**: Task 1 (ST-006) complete — profiles reference Territory IDs

### What a Settler profile is

A Settler profile is an instruction file for a specialized documentation/engineering agent. It narrows the agent's attention to one Territory and makes its invariants and forbidden moves unambiguous. It is not an executable agent, not a clinical actor, and not a HealthOS runtime component.

### The 9 Settler profiles to create

| File to create | Profile ID | Territory | Description |
|---|---|---|---|
| `settler-core-law.md` | `settler-core-law` | `TERRITORY-CORE-LAW` | Core law schema, consent/habilitation/gate/finality |
| `settler-storage.md` | `settler-storage` | `TERRITORY-STORAGE` | Storage layer, data contracts, lawfulContext |
| `settler-gos.md` | `settler-gos` | `TERRITORY-GOS` | GOS, compiler, mediation layer |
| `settler-aaci.md` | `settler-aaci` | `TERRITORY-AACI` | AACI runtime, provider governance, capability signaling |
| `settler-ops.md` | `settler-ops` | `TERRITORY-OPS` | Operations runbook, observability, incident response |
| `settler-apps.md` | `settler-apps` | `TERRITORY-APPS` | App surfaces, app-boundary contracts |
| `settler-xcode-tooling.md` | `settler-xcode-tooling` | `TERRITORY-XCODE-TOOLING` | Steward, healthos-mcp, Xcode tooling streams |
| `settler-documentation.md` | `settler-documentation` | `TERRITORY-DOCUMENTATION` | Doc drift, execution protocol, invariant matrix |
| `settler-validation.md` | `settler-validation` | `TERRITORY-VALIDATION` | Coverage matrix, release criteria, contract validation |

### Required structure for each Settler profile

Every profile **must** contain all sections below in this order.

```markdown
# Settler profile: <name>

**Profile ID**: <settler-profile-id>
**Territory**: <TERRITORY-ID>
**Maturity**: doctrine-only

## Non-claims

This Settler profile does not create a clinical agent, runtime actor, HealthOS Core actor,
or multiagent orchestration participant. It is an engineering instruction document only.
Settlers do not grant merge authority, clinical access, or production-readiness.

## Mission

<!-- One paragraph. What this Settler does, expressed as a narrow documentation/engineering role. -->

## Territory assignment

**Territory ID**: <TERRITORY-ID>
**Territory record**: `.healthos-territory/territories/<territory-file>.md`

## Read before acting

<!-- Canonical docs this Settler MUST read before starting any work unit. -->
1. `path/to/canonical-doc.md` — why it matters for this territory
2. ...

## Files in scope

<!-- Source paths this Settler may read and write. Be specific. -->
- `path/to/source/` — brief description
- `path/to/schema` — brief description

## Invariants

<!-- Non-negotiable rules this Settler must preserve in every work unit. -->
1. <invariant>
2. <invariant>
...

## Forbidden moves

<!-- What this Settler must NEVER do. -->
- Never <action>
- Never <action>
...

## Validation expectations

<!-- What must pass before this Settler marks any work unit done. -->
- `make <target>` must pass
- <specific test or contract check>
- tracking docs updated in same work unit

## Handoff requirements

<!-- What this Settler must produce before exiting a work unit. -->
- Updated `docs/execution/02-status-and-tracking.md`
- Updated relevant `docs/execution/todo/*.md` entry
- Commit message describes objective + files touched + invariants involved
- Residual gaps recorded explicitly

## Known limitations

<!-- What this Settler cannot do or does not cover. -->
- <limitation>
```

### After completing Task 2

Update `docs/execution/19-settler-model-task-tracker.md`:
- Change `ST-002` status from `TODO` to `DONE`.
- Add outcome block listing all 9 profile files.

---

## TASK 3 OF 3 — ST-003: Define Settlement record schema

**Source**: `docs/execution/19-settler-model-task-tracker.md` → ST-003
**Target file**: `.healthos-settler/settlements/SCHEMA.md`
**Depends on**: Tasks 1 and 2 complete (schema references Territory IDs and Profile IDs)

### What a Settlement schema is

A Settlement is a bounded engineering work unit — the contract between Steward and a Settler for one focused task. The schema defines the exact fields that every Settlement record must contain so that any future agent can read it and understand the scope, constraints, and completion criteria without ambiguity.

This file is a documentation schema — not a JSON Schema or executable contract. It is a field-by-field specification with descriptions, formats, and an annotated example.

### Required content for `.healthos-settler/settlements/SCHEMA.md`

The file must contain the following sections:

#### Section 1 — Non-claims

```markdown
## Non-claims

A Settlement record does not authorize clinical activity, runtime execution, merge decisions,
or production-readiness claims. It is a scoped engineering work document.
No Settlement record creates a clinical agent or HealthOS Core actor.
```

#### Section 2 — Schema fields

Define each field with: name, type (string/list/enum), description, format (where applicable), and whether it is required or optional.

| Field | Type | Required | Description |
|---|---|---|---|
| `id` | string | required | Unique identifier. Format: `SETTLEMENT-YYYYMMDD-<slug>`. Example: `SETTLEMENT-20260428-core-law-error-envelope` |
| `title` | string | required | Short human-readable title (max 80 characters) |
| `status` | enum | required | One of: `DRAFT` / `IN-PROGRESS` / `COMPLETE` / `BLOCKED` |
| `created` | date | required | ISO date when this Settlement was created |
| `completed` | date | optional | ISO date when this Settlement reached COMPLETE or was superseded |
| `territory` | string | required | Territory ID from `.healthos-territory/territories/`. Must match an existing record. |
| `settler-profile` | string | required | Profile ID from `.healthos-settler/profiles/`. Must match an existing profile. |
| `objective` | string | required | One-paragraph statement of exactly what this Settlement delivers. No vague language. |
| `files-in-scope` | list | required | Explicit list of files the Settler may read and write during this Settlement. |
| `invariants` | list | required | Non-negotiable rules for this Settlement. Subset of Territory invariants plus any additional Settlement-specific constraints. |
| `restrictions` | list | optional | Additional restrictions beyond Territory invariants for this specific work unit. |
| `validation-commands` | list | required | `make` targets or test commands that must pass before marking COMPLETE. At least one required. |
| `done-criteria` | list | required | Explicit list of deliverables. Each criterion is falsifiable (can be verified pass/fail). |
| `residual-gaps` | list | optional | Known unresolved questions or deferred work. Required if any gaps exist. Must not be left blank when gaps are known. |
| `handoff` | object | required | What is produced for the next agent. Must include: docs-updated (list), tracking-updated (list), pr-description-summary (string). |
| `blockers` | list | optional | Active blockers preventing progress. Each blocker must name its dependency and why it blocks. |

#### Section 3 — Status transition rules

```
DRAFT → IN-PROGRESS: Settler has been assigned and has read required docs.
IN-PROGRESS → COMPLETE: All done-criteria are met; all validation-commands pass; tracking updated.
IN-PROGRESS → BLOCKED: A blocker has been identified; blocker recorded in `blockers` field.
BLOCKED → IN-PROGRESS: Blocker resolved; blocker entry updated with resolution note.
COMPLETE: Terminal. A new Settlement must be created for follow-up work.
```

#### Section 4 — Annotated example

Write a complete example Settlement record that illustrates every field. Use a past completed work unit from the repository as the basis (for example, the WS-1 instructions consolidation). Do not invent clinical scenarios.

```markdown
## Example Settlement record

id: SETTLEMENT-20260428-ws1-instructions-consolidation
title: WS-1 Instructions and skills consolidation for Steward for Xcode
status: COMPLETE
created: 2026-04-27
completed: 2026-04-28
territory: TERRITORY-XCODE-TOOLING
settler-profile: settler-xcode-tooling

objective: |
  Update CLAUDE.md, AGENTS.md, README.md, and skill/architecture docs to use canonical
  Steward naming, Steward for Xcode posture, and healthos-mcp two-family boundary doctrine.
  Remove stale StewardCore/StewardAgentRuntime references. Does not touch any source code.

files-in-scope:
  - CLAUDE.md
  - AGENTS.md
  - README.md
  - docs/execution/skills/project-steward-skill.md
  - docs/architecture/45-healthos-xcode-agent.md
  - docs/execution/17-healthos-xcode-agent-migration-plan.md
  - docs/execution/02-status-and-tracking.md
  - docs/execution/todo/ops-network-ml.md

invariants:
  - healthos-mcp is repository-maintenance MCP only — never clinical, never runtime authority
  - Steward is outside the HealthOS clinical/runtime hierarchy
  - no provider-centric architecture reintroduced

restrictions:
  - do not modify any Swift, TypeScript, Python, or SQL source files in this Settlement

validation-commands:
  - make validate-docs

done-criteria:
  - CLAUDE.md uses canonical Steward naming with no stale references
  - README.md Steward section matches canonical naming
  - project-steward-skill.md reflects healthos-mcp two-family doctrine
  - make validate-docs passes

residual-gaps:
  - WS-2 (healthos-mcp implementation) remains future work
  - WS-3 (deterministic CLI consolidation) remains future work

handoff:
  docs-updated:
    - docs/execution/02-status-and-tracking.md
    - docs/execution/todo/ops-network-ml.md
  tracking-updated:
    - docs/execution/19-settler-model-task-tracker.md
  pr-description-summary: |
    Consolidated Steward naming, posture, and healthos-mcp doctrine across entry docs,
    skills, and architecture docs. No source code changes.
```

### After completing Task 3

Update `docs/execution/19-settler-model-task-tracker.md`:
- Change `ST-003` status from `TODO` to `DONE`.
- Add outcome block.

---

## TRACKING UPDATE (after all three tasks)

After completing Tasks 1, 2, and 3, add an entry to `docs/execution/02-status-and-tracking.md` at the top of the "Completed recently" section:

```markdown
## PHASE-1-SETTLER-TERRITORY — Settler/Territory documentation phase (2026-04-28)

Objective: write all Settler/Territory documental artifacts defined in docs/execution/20-documental-todos-work-plan.md Phase 1.

Files touched:
- .healthos-territory/territories/core-law.md
- .healthos-territory/territories/storage.md
- .healthos-territory/territories/gos.md
- .healthos-territory/territories/aaci.md
- .healthos-territory/territories/async-runtime.md
- .healthos-territory/territories/providers.md
- .healthos-territory/territories/apps.md
- .healthos-territory/territories/ops.md
- .healthos-territory/territories/xcode-tooling.md
- .healthos-territory/territories/documentation.md
- .healthos-territory/territories/validation.md
- .healthos-settler/profiles/settler-core-law.md
- .healthos-settler/profiles/settler-storage.md
- .healthos-settler/profiles/settler-gos.md
- .healthos-settler/profiles/settler-aaci.md
- .healthos-settler/profiles/settler-ops.md
- .healthos-settler/profiles/settler-apps.md
- .healthos-settler/profiles/settler-xcode-tooling.md
- .healthos-settler/profiles/settler-documentation.md
- .healthos-settler/profiles/settler-validation.md
- .healthos-settler/settlements/SCHEMA.md
- docs/execution/19-settler-model-task-tracker.md
- docs/execution/02-status-and-tracking.md

Invariants involved:
- engineering-agent boundary doctrine: Settler records and profiles are engineering documents outside HealthOS clinical/runtime hierarchy
- no production-readiness or clinical claims

Validation:
- make validate-docs PASS
- all 11 Territory records contain required fields
- all 9 Settler profiles contain required fields
- Settlement schema contains all fields with descriptions and an example

Done criteria:
- ST-006, ST-002, ST-003 all moved to DONE in 19-settler-model-task-tracker.md
```

---

## GIT WORKFLOW

### Commits

Make three separate commits — one per task. Each commit message must follow this format:

```
docs(settler): <task-id> — <short description>

Files created: <list>
Invariants: <list of relevant invariants>
Validation: make validate-docs PASS

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>
```

Examples:
```bash
# After Task 1:
git add .healthos-territory/territories/*.md docs/execution/19-settler-model-task-tracker.md
git commit -m "docs(settler): ST-006 — define 11 Territory record files

Files created: .healthos-territory/territories/{core-law,storage,gos,aaci,async-runtime,providers,apps,ops,xcode-tooling,documentation,validation}.md
Invariants: engineering-agent boundary doctrine; no production-readiness claims
Validation: make validate-docs PASS

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 2:
git add .healthos-settler/profiles/*.md docs/execution/19-settler-model-task-tracker.md
git commit -m "docs(settler): ST-002 — create 9 Settler profile instruction files

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 3 + tracking update:
git add .healthos-settler/settlements/SCHEMA.md docs/execution/19-settler-model-task-tracker.md docs/execution/02-status-and-tracking.md
git commit -m "docs(settler): ST-003 — define Settlement record schema

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

### Push and PR

```bash
git push -u origin codex/phase-1-settler-territory-docs

gh pr create \
  --title "docs: Phase 1 — Settler/Territory documentation (ST-006, ST-002, ST-003)" \
  --body "## Summary
- ST-006: 11 Territory records created under .healthos-territory/territories/
- ST-002: 9 Settler profile instruction files created under .healthos-settler/profiles/
- ST-003: Settlement record schema defined at .healthos-settler/settlements/SCHEMA.md
- Tracking updated in 19-settler-model-task-tracker.md and 02-status-and-tracking.md

## Invariants
- All records are engineering documents outside the HealthOS clinical/runtime hierarchy
- No production-readiness or clinical claims in any file

## Test plan
- [ ] make validate-docs passes
- [ ] All 11 Territory records contain required fields (id, name, canonical-docs, files-in-scope, invariants, forbidden-moves, skills, tests, validation-commands, known-gaps, handoff-note)
- [ ] All 9 Settler profiles contain required fields (profile-id, territory, mission, read-before-acting, files-in-scope, invariants, forbidden-moves, validation-expectations, handoff-requirements)
- [ ] Settlement schema contains all fields with descriptions and annotated example
- [ ] ST-006, ST-002, ST-003 marked DONE in 19-settler-model-task-tracker.md

🤖 Generated with Claude Code" \
  --base main
```

---

## PHASE 1 DEFINITION OF DONE

Phase 1 is complete when ALL of the following are true:

- [ ] `.healthos-territory/territories/` contains exactly 11 `.md` files, one per territory listed above
- [ ] Every Territory record contains all required sections with non-empty content
- [ ] No Territory record claims production readiness, clinical authority, or merge authority
- [ ] `.healthos-settler/profiles/` contains exactly 9 `.md` files, one per profile listed above
- [ ] Every Settler profile references a valid Territory ID from the 11 records above
- [ ] Every Settler profile contains all required sections
- [ ] `.healthos-settler/settlements/SCHEMA.md` exists and contains all 16 schema fields, status transitions, and an annotated example
- [ ] `docs/execution/19-settler-model-task-tracker.md` shows ST-006, ST-002, ST-003 as DONE
- [ ] `docs/execution/02-status-and-tracking.md` has a PHASE-1-SETTLER-TERRITORY entry
- [ ] `make validate-docs` passes
- [ ] Three separate commits on branch `codex/phase-1-settler-territory-docs`
- [ ] Branch pushed to remote
- [ ] PR created targeting main

**If any item above is not met, the phase is not complete.**
