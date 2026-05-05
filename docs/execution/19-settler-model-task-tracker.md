# Settler model task tracker

## Repository identity note

HealthOScaffold is the historical repository name and construction repository for HealthOS.

Scaffold describes maturity or foundation phase. It does not describe a separate product identity.

## Current truth

The Steward / Settler construction model is now a scaffolded contract because `docs/execution/22-steward-construction-operating-model.md` and the initial construction directory skeleton exist.

No runtime implementation exists yet.

No multiagent runtime is implemented.

No `healthos-forge-mcp` server is implemented.

No Settler profiles are implemented as executable agents.

The Territory Registry exists under `.healthos-settler/territories/` as construction metadata only.

`docs/architecture/47-steward-settler-engineering-model.md` is the canonical architecture document for the model.

`docs/execution/22-steward-construction-operating-model.md` is the canonical construction operating model for future Steward-generated prompts, Settlement records, validation drafts, and derived handoff memory.

Repository-local documentation roots exist:
- `.healthos-settler/territories/` for Territory Registry records
- `.healthos-settler/settlers/` for future Settler Profile Registry records
- `.healthos-steward/settlements/` for future Settlement records
- `.healthos-steward/prompts/` for future generated prompts and prompt templates
- `.healthos-territory/` as a prior documentation-only Territory scaffold

These roots are documentation scaffolds only.

## Planned ST construction sequence

### ST-010 — Construction Operating Model baseline

Status: DONE.

Outcome:
- created `docs/execution/22-steward-construction-operating-model.md`
- created initial `.healthos-settler/` and `.healthos-steward/` construction-system skeletons
- created the initial scaffold Settlement schema template
- recorded that execution remains documentation/schema/scaffold-focused only

### ST-011 — Territory Registry

Status: DONE.

Outcome:
- created `.healthos-settler/territories/territory.schema.json`
- created initial Territory records for `core`, `gos`, `session-runtime`, `msr`, `aaci`, `providers`, `apps`, `type-script-runtimes`, `storage-and-data`, `regulatory-and-interoperability`, `operations-and-observability`, `construction-system`, `validation-and-ci`, and `documentation`
- kept every Territory record subordinate to official docs and outside the HealthOS clinical/runtime hierarchy

### ST-011B — HealthOS Technical Product Specification baseline

Status: DONE.

Outcome:
- created `docs/product/README.md`
- created `docs/product/01-healthos-technical-product-specification.md`
- consolidated current technical product definition across Core, GOS, Session Runtime, AACI, MSR, Providers, TypeScript runtimes, apps/interfaces, artifacts/provenance, and construction-layer boundaries
- updated reading-path and construction docs so Steward/Settlers consult the product technical specification baseline before generating future work units

### ST-012 — Settler Profile Registry

Status: DONE.

Goal:
- define Settler profile records under `.healthos-settler/settlers/`
- include territory assignment, invariants, forbidden moves, validation expectations, and handoff requirements
- keep Settlers non-authoritative and non-clinical

Outcome (2026-05-04):
- Created `.healthos-settler/settlers/README.md` — registry index table with all 9 profiles
- Created `.healthos-settler/settlers/settler-core-law.md` — Territory: core
- Created `.healthos-settler/settlers/settler-storage.md` — Territory: storage-and-data
- Created `.healthos-settler/settlers/settler-gos.md` — Territory: gos
- Created `.healthos-settler/settlers/settler-aaci.md` — Territory: aaci
- Created `.healthos-settler/settlers/settler-ops.md` — Territory: operations-and-observability
- Created `.healthos-settler/settlers/settler-apps.md` — Territory: apps
- Created `.healthos-settler/settlers/settler-xcode-tooling.md` — Territory: construction-system
- Created `.healthos-settler/settlers/settler-documentation.md` — Territory: documentation
- Created `.healthos-settler/settlers/settler-validation.md` — Territory: validation-and-ci
- Each profile contains: territory-id, profile-id, description, canonical-docs, files-in-scope, invariants (≥ 6), forbidden-moves (≥ 6), validation-expectations, maturity (doctrine-only), handoff-requirements, non-claims block
- Maturity: doctrine-only (all 9 profiles)
- Non-claims: no clinical agent, no runtime actor, no merge authority, no production-readiness, no Settler execution runtime implemented

### ST-013 — Settlement Record Schema and templates

Status: DONE.

Goal:
- mature the initial Settlement schema and templates
- keep records deterministic and non-executable unless a later CLI task implements readers

Outcome (2026-05-04):
- Created `.healthos-settler/settlements/SCHEMA.md` — authoritative Markdown spec defining all 13 Settlement record fields with descriptions, grouped into Identity, Scope, Governance, and Lifecycle categories; includes How-to section and non-claims block
- Created `.healthos-steward/settlements/templates/settlement-template.md` — blank template with `<PLACEHOLDER>` values and HTML comment guidance for all 13 fields
- Created `.healthos-steward/settlements/completed/st-012-settler-profile-registry.md` — completed example Settlement record (factual basis: ST-012 tracking docs and actual repository state)
- Updated `.healthos-steward/settlements/templates/settlement.schema.json` — patched to add `objective`, `restrictions`, and `handoff` fields which were absent; updated example; added `$comment` noting ST-013 review; JSON remains valid
- Maturity: scaffolded contract (schema, template, JSON Schema); no CLI, MCP server, runner, or executable Settlement implemented
- Non-claims: no clinical authority, no merge authority, no runtime behavior, no production-readiness claim

### ST-014 — Deterministic Steward CLI inspect/next/list

Status: DONE.

Goal:
- add deterministic inspection/listing support after records exist
- do not implement model calls or multiagent orchestration

Outcome (2026-05-04):
- Created `ts/agent-infra/healthos-steward/src/repo-root.ts` — resolves repo root from compiled dist/ path using import.meta.url
- Created `ts/agent-infra/healthos-steward/src/commands/list.ts` — `list territories|settlers|settlements`
- Created `ts/agent-infra/healthos-steward/src/commands/inspect.ts` — `inspect territory|settler|settlement <id>`
- Created `ts/agent-infra/healthos-steward/src/commands/next.ts` — returns first TODO ST task from tracker
- Updated `ts/agent-infra/healthos-steward/src/index.ts` — added list/inspect/next to StewardCommand type and switch
- Updated `ts/agent-infra/healthos-steward/src/cli.ts` — passes args slice to runStewardCommand
- Updated `CLAUDE.md` baseline note to list all 6 implemented commands
- Node built-ins only (node:fs, node:path, node:url); no new npm dependencies
- Maturity: implemented seam
- Non-claims: no model calls, no writes, no multiagent, no clinical authority, no MCP server, no merge authority

### ST-015 — Prompt Generation Engine

Status: DONE.

Goal:
- generate prompts from official docs, Settlement records, and templates
- preserve HealthOS invariants and non-claims

Outcome (2026-05-04):
- Created `ts/agent-infra/healthos-steward/src/lib/settlement-parser.ts` — line-based Settlement Markdown parser; fail-closed on missing required fields (id, title, objective, territory)
- Created `ts/agent-infra/healthos-steward/src/lib/territory-reader.ts` — reads Territory JSON records from `.healthos-settler/territories/<id>.json`
- Created `ts/agent-infra/healthos-steward/src/lib/settler-reader.ts` — parses Settler profile Markdown; extracts invariants and forbidden-moves from `## invariants` / `## forbidden-moves` sections
- Created `ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts` — assembles 16-section PromptSpec from Settlement + Territory + Settler data; `canonical_nomenclature` is a hard-coded constant never varying per Settlement
- Created `ts/agent-infra/healthos-steward/src/commands/generate-prompt.ts` — command handler for `generate-prompt <settlement-id>`; searches active/ then completed/; writes to `.healthos-steward/prompts/generated/`
- Updated `ts/agent-infra/healthos-steward/src/index.ts` — added `"generate-prompt"` to StewardCommand type and switch dispatcher
- Smoke: `generate-prompt st-012-settler-profile-registry` → 16-section PromptSpec written; grep count = 16; no undefined artifacts; exit 0
- Maturity: implemented seam
- Non-claims: no LLM calls, no model routing, no HTTP requests, no new npm dependencies, no clinical authority, no merge authority, no MCP server, no writes except `.healthos-steward/prompts/generated/`

### ST-016 — Settlement Validation and PR Review Draft Engine

Status: DONE.

Goal:
- generate deterministic validation/review drafts from Settlement records and repository evidence
- never create merge authority

Outcome (2026-05-04):
- Created `ts/agent-infra/healthos-steward/src/lib/validation-report-builder.ts` — pure function; exports `CriterionResult`, `FileCheckResult`, `ValidationEvidence`, `buildValidationReport`
- Created `ts/agent-infra/healthos-steward/src/lib/pr-draft-builder.ts` — pure function; exports `buildPrDraft`
- Created `ts/agent-infra/healthos-steward/src/commands/validate-settlement.ts` — PASS/FAIL/UNVERIFIED heuristic on done-criteria; exits 1 on any FAIL
- Created `ts/agent-infra/healthos-steward/src/commands/pr-draft.ts` — PR body Markdown from Settlement fields
- Smoke st-012: validate-settlement → 5 PASS, 0 FAIL, 2 UNVERIFIED; pr-draft → PR draft created; both exit 0
- Maturity: implemented seam
- Non-claims: no shell execution, no LLM calls, no merge authority, no clinical authority, no new npm deps, fail-closed on all error paths

### ST-017 — Derived Memory Builder

Status: DONE.

Goal:
- build derived handoff memory from official docs and validated repository state
- keep derived memory non-canonical

Outcome (2026-05-04):
- Created `ts/agent-infra/healthos-steward/src/lib/tracker-reader.ts` — reads all ST tasks from tracker (all ### ST-\d+ sections); exports `TrackerTask` and `readAllTrackerTasks()`
- Created `ts/agent-infra/healthos-steward/src/lib/memory-builder.ts` — 6 pure builder functions; no FS calls; exports `buildIndex`, `buildConstructionStatus`, `buildTerritoryIndex`, `buildSettlerIndex`, `buildSettlementIndex`, `buildHandoffSnapshot`
- Created `ts/agent-infra/healthos-steward/src/commands/build-memory.ts` — command handler; reads ST tracker, Territory JSON files, Settler README, Settlement .md files, and handoff doc; writes 6 files to `.healthos-steward/memory/derived/`; per-file error tolerance; fail-closed only on mkdirSync failure
- Updated `ts/agent-infra/healthos-steward/src/index.ts` — added `"build-memory"` to StewardCommand type and switch (total: 10 commands)
- Smoke: `build-memory` → "Built 6 derived memory files to .healthos-steward/memory/derived/"; 0 warnings; exit 0
- All 6 derived files carry NON-CANONICAL header; files are overwritten on each run (idempotent)
- Maturity: implemented seam
- Non-claims: no LLM calls, no shell execution, no HTTP requests, no new npm deps, no writes outside memory/derived/, no clinical authority, no merge authority, derived memory never replaces official docs

### ST-018 — healthos-forge-mcp surface over deterministic operations

Status: DONE.

Goal:
- expose deterministic repository-maintenance operations through `healthos-forge-mcp`
- keep `healthos-forge-mcp` separate from future HealthOS runtime MCP servers

Outcome (2026-05-05):
- Created `ts/agent-infra/healthos-forge-mcp/` (`@healthos/forge-mcp` 0.1.0) — new npm workspace package
- Created `ts/agent-infra/healthos-forge-mcp/package.json` — deps: `@modelcontextprotocol/sdk ^1.0.0`, `@healthos/steward 0.2.0`
- Created `ts/agent-infra/healthos-forge-mcp/tsconfig.json` — ES2022 / NodeNext / strict
- Created `ts/agent-infra/healthos-forge-mcp/src/server.ts` — stdio MCP server entry point (shebang, Server + StdioServerTransport)
- Created `ts/agent-infra/healthos-forge-mcp/src/tools.ts` — TOOLS array (10 tools) + callTool dispatcher; all handlers call @healthos/steward lib functions directly; repoRoot declared locally
- Updated `ts/agent-infra/healthos-steward/src/index.ts` — 17 lib re-exports added (tracker, territory, settler, settlement, prompt assembler, memory builders, validation types)
- 10 tools: steward_next_task, steward_scan_status, steward_get_handoff, steward_list_territories, steward_inspect_territory, steward_list_settlers, steward_list_settlements, steward_validate_settlement, steward_generate_prompt, steward_build_memory
- Smoke: initialize OK; tools/list → 10 tools; steward_next_task → ST-018 (first TODO); steward_inspect_territory core → core data; steward_list_territories → 14 territories; clinical tool grep → 0
- `make ts-build` PASS; @healthos/steward all 10 existing commands unchanged
- Known gap recorded: mcp-local has clinical tool names (patient_context, service_context, session_drafts) — boundary violation, future cleanup task
- Maturity: implemented seam (stdio MCP, 10 deterministic tools)
- Non-claims: no clinical tools, no LLM calls, no shell execution, no merge authority, separate from HealthOS runtime MCPs

### ST-019 — Forge MCP Activation + inspect settler command

Status: DONE.

Goal:
- activate `healthos-forge-mcp` as a real stdio MCP server usable from Claude Code and Xcode
- add `.mcp.json` at repo root pointing to `dist/server.js`
- implement (confirm) `healthos-steward inspect settler <id>` standalone command
- add `ts/agent-infra/healthos-forge-mcp/README.md` with usage, build, registration, and tool list

Outcome:
- `.mcp.json` created at repo root: `{ "mcpServers": { "healthos-forge-mcp": { "command": "node", "args": ["ts/agent-infra/healthos-forge-mcp/dist/server.js"] } } }`
- `inspect settler <id>` confirmed working — parses all 9 settler `.md` files, returns territory, maturity, invariant count, forbidden-moves count
- `ts/agent-infra/healthos-forge-mcp/README.md` created — documents server purpose, build command, registration, and all 10 tool names
- Smoke: `make ts-build` PASS; `inspect settler settler-xcode-tooling` PASS; `list settlers` → 9 profiles; forge-mcp server init → `{"result":{"protocolVersion":"2024-11-05","capabilities":{"tools":{}}}}` PASS
- Maturity: implemented seam (forge-mcp registered and active via `.mcp.json`)
- Settlement: SETTLEMENT-20260505-forge-mcp-activation (COMPLETE)
- Residual gaps: no test suite for steward/forge-mcp; mcp-local boundary violation deferred; Xcode Intelligence direct MCP not yet validated

### ST-020 — Use Steward to generate APP-011 prompt

Status: TODO.

Goal:
- use the construction system to generate the APP-011 prompt after the needed construction pieces exist
- APP-011 remains the next product task until executed separately

## Historical streams

### ST-1 Settler profile instructions

Create profile docs or skill files for each initial Settler.

Define territory, invariants, forbidden moves, validation expectations, maturity, and handoff requirements for each profile.

Current scaffold root: `.healthos-settler/profiles/`.

### ST-2 Settlement record schema

Define a schema for a Settlement work unit.

The schema should capture objective, Territory, files in scope, invariants, restrictions, validation commands, done criteria, residual gaps, and handoff.

No execution is implemented in this stream.

Current scaffold root: `.healthos-settler/settlements/`.

### ST-2a Territory record scaffolds

Define Territory records as documentation-only repository domain records.

Current scaffold root: `.healthos-territory/territories/`.

### ST-3 healthos-forge-mcp operations for Steward/Settlers

Expose repository-maintenance tools for Steward and Settlers.

Operations may include `validate-docs`, `validate-all`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, and `generate-pr-review-draft`.

No clinical tools are exposed.

### ST-4 Deterministic CLI support

Add deterministic CLI support when the doctrine and record shape are ready.

Possible operations:
- list Settlements
- generate next Settlement
- validate Settlement scope
- produce handoff

The CLI remains deterministic. It does not implement multiagent intelligence by itself.

### ST-5 Xcode surface alignment

Expose Settler profiles to Steward for Xcode as instruction material.

Xcode Intelligence may use instructions and MCP where available.

Xcode Intelligence is not HealthOS Core, not a clinical runtime, and not a HealthOS-controlled law engine.

## Active queue

### ST-001 Create Settler architecture doctrine

Status: DONE in this work unit.

Outcome:
- created canonical architecture doc for Steward / Settler / Settlement / Territory model
- documented that the model is outside the HealthOS clinical/runtime hierarchy
- kept `healthos-forge-mcp` as repository-maintenance MCP only

### ST-002 Create Settler profile instruction files

Status: TODO; documentation root scaffolded.

Goal:
- create instruction or skill artifacts for initial Settler profiles
- include territory, invariants, forbidden moves, validation expectations, and maturity

### ST-003 Define Settlement record schema

Status: TODO; documentation root scaffolded.

Goal:
- define the document/schema shape for bounded Settlement work units
- keep it non-executable until separately implemented

### ST-004 Define healthos-forge-mcp Settler operations

Status: TODO.

Goal:
- define repository-maintenance MCP operations that support Steward and Settlers
- keep all operations outside the clinical/runtime hierarchy

### ST-005 Add deterministic CLI support for settlement records

Status: TODO.

Goal:
- add deterministic CLI support for listing, generating, validating, and handing off Settlement records
- do not implement multiagent intelligence in the CLI

### ST-006 Define Territory record files

Status: TODO; documentation root scaffolded.

Goal:
- define initial Territory records under `.healthos-territory/territories/`
- keep records subordinate to official docs
- include canonical docs, files in scope, invariants, validation commands, maturity, and known gaps

## Non-claims

No runtime implementation exists yet.

No clinical agents are created.

No merge authority is granted.

No production readiness is claimed.

No `healthos-forge-mcp` server is implemented.

No HealthOS runtime MCP server is implemented.

No Territory loader is implemented.

Deterministic Steward CLI inspection seam implemented (ST-014): `list territories|settlers|settlements`, `inspect territory|settler|settlement <id>`, and `next` are delivered. All are read-only, deterministic, no model calls, no writes, no new npm deps.

No Settlement write/create CLI is implemented.

No prompt generation engine is implemented.
