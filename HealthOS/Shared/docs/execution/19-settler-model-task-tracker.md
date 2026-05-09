# Settler model task tracker

## Repository identity note

HealthOScaffold is the historical repository name and construction repository for HealthOS.

Scaffold describes maturity or foundation phase. It does not describe a separate product identity.

## Current truth

The Steward / Settler construction model is now an implemented construction seam for deterministic repository-maintenance operations, while Settler execution remains doctrine-only.

No HealthOS clinical/runtime implementation exists in the Construction System.

No multiagent runtime is implemented.

`healthos-forge-mcp` is implemented as repository-maintenance MCP only, with stdio and Streamable HTTP transports over the 10 deterministic `steward_*` tools. It is not a HealthOS runtime MCP server.

No Settler profiles are implemented as executable agents.

The Territory Registry exists under `HealthOS/Constructor/Settler/territories/` as construction metadata only.

`HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md` is the canonical architecture document for the model.

`HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` is the canonical construction operating model for Steward-generated prompts, Settlement records, validation drafts, and derived handoff memory.

Repository-local documentation roots exist:
- `HealthOS/Constructor/Settler/territories/` for Territory Registry records
- `HealthOS/Constructor/Settler/settlers/` for Settler Profile Registry records
- `HealthOS/Constructor/Steward/settlements/` for active, completed, and template Settlement records
- `HealthOS/Constructor/Steward/prompts/` for generated prompts, validation drafts, PR drafts, and prompt templates
- `HealthOS/Constructor/Territory/` as a prior documentation-only Territory scaffold

These roots are construction metadata and derived artifacts only. They do not create clinical authority, runtime behavior, merge authority, or production readiness.

## Planned ST construction sequence

### ST-010 — Construction Operating Model baseline

Status: DONE.

Outcome:
- created `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- created initial `HealthOS/Constructor/Settler/` and `HealthOS/Constructor/Steward/` construction-system skeletons
- created the initial scaffold Settlement schema template
- recorded that execution remains documentation/schema/scaffold-focused only

### ST-011 — Territory Registry

Status: DONE.

Outcome:
- created `HealthOS/Constructor/Settler/territories/territory.schema.json`
- created initial Territory records for `core`, `gos`, `session-runtime`, `msr`, `aaci`, `providers`, `apps`, `type-script-runtimes`, `storage-and-data`, `regulatory-and-interoperability`, `operations-and-observability`, `construction-system`, `validation-and-ci`, and `documentation`
- kept every Territory record subordinate to official docs and outside the HealthOS clinical/runtime hierarchy

### ST-011B — HealthOS Technical Product Specification baseline

Status: DONE.

Outcome:
- created `HealthOS/Shared/docs/product/README.md`
- created `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md`
- consolidated current technical product definition across Core, GOS, Session Runtime, AACI, MSR, Providers, TypeScript runtimes, HealthOS/Tier4-Stages-Cast/AppDocs/interfaces, artifacts/provenance, and construction-layer boundaries
- updated reading-path and construction docs so Steward/Settlers consult the product technical specification baseline before generating future work units

### ST-012 — Settler Profile Registry

Status: DONE.

Goal:
- define Settler profile records under `HealthOS/Constructor/Settler/settlers/`
- include territory assignment, invariants, forbidden moves, validation expectations, and handoff requirements
- keep Settlers non-authoritative and non-clinical

Outcome (2026-05-04):
- Created `HealthOS/Constructor/Settler/settlers/README.md` — registry index table with all 9 profiles
- Created `HealthOS/Constructor/Settler/settlers/settler-core-law.md` — Territory: core
- Created `HealthOS/Constructor/Settler/settlers/settler-storage.md` — Territory: storage-and-data
- Created `HealthOS/Constructor/Settler/settlers/settler-gos.md` — Territory: gos
- Created `HealthOS/Constructor/Settler/settlers/settler-aaci.md` — Territory: aaci
- Created `HealthOS/Constructor/Settler/settlers/settler-ops.md` — Territory: operations-and-observability
- Created `HealthOS/Constructor/Settler/settlers/settler-apps.md` — Territory: apps
- Created `HealthOS/Constructor/Settler/settlers/settler-xcode-tooling.md` — Territory: construction-system
- Created `HealthOS/Constructor/Settler/settlers/settler-documentation.md` — Territory: documentation
- Created `HealthOS/Constructor/Settler/settlers/settler-validation.md` — Territory: validation-and-ci
- Each profile contains: territory-id, profile-id, description, canonical-docs, files-in-scope, invariants (≥ 6), forbidden-moves (≥ 6), validation-expectations, maturity (doctrine-only), handoff-requirements, non-claims block
- Maturity: doctrine-only (all 9 profiles)
- Non-claims: no clinical agent, no runtime actor, no merge authority, no production-readiness, no Settler execution runtime implemented

### ST-013 — Settlement Record Schema and templates

Status: DONE.

Goal:
- mature the initial Settlement schema and templates
- keep records deterministic and non-executable unless a later CLI task implements readers

Outcome (2026-05-04):
- Created `HealthOS/Constructor/Settler/settlements/SCHEMA.md` — authoritative Markdown spec defining all 13 Settlement record fields with descriptions, grouped into Identity, Scope, Governance, and Lifecycle categories; includes How-to section and non-claims block
- Created `HealthOS/Constructor/Steward/settlements/templates/settlement-template.md` — blank template with `<PLACEHOLDER>` values and HTML comment guidance for all 13 fields
- Created `HealthOS/Constructor/Steward/settlements/completed/st-012-settler-profile-registry.md` — completed example Settlement record (factual basis: ST-012 tracking docs and actual repository state)
- Updated `HealthOS/Constructor/Steward/settlements/templates/settlement.schema.json` — patched to add `objective`, `restrictions`, and `handoff` fields which were absent; updated example; added `$comment` noting ST-013 review; JSON remains valid
- Maturity: scaffolded contract (schema, template, JSON Schema); no CLI, MCP server, runner, or executable Settlement implemented
- Non-claims: no clinical authority, no merge authority, no runtime behavior, no production-readiness claim

### ST-014 — Deterministic Steward CLI inspect/next/list

Status: DONE.

Goal:
- add deterministic inspection/listing support after records exist
- do not implement model calls or multiagent orchestration

Outcome (2026-05-04):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/repo-root.ts` — resolves repo root from compiled dist/ path using import.meta.url
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/list.ts` — `list territories|settlers|settlements`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/inspect.ts` — `inspect territory|settler|settlement <id>`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/next.ts` — returns first TODO ST task from tracker
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added list/inspect/next to StewardCommand type and switch
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/cli.ts` — passes args slice to runStewardCommand
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
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/settlement-parser.ts` — line-based Settlement Markdown parser; fail-closed on missing required fields (id, title, objective, territory)
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/territory-reader.ts` — reads Territory JSON records from `HealthOS/Constructor/Settler/territories/<id>.json`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/settler-reader.ts` — parses Settler profile Markdown; extracts invariants and forbidden-moves from `## invariants` / `## forbidden-moves` sections
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/prompt-assembler.ts` — assembles 16-section PromptSpec from Settlement + Territory + Settler data; `canonical_nomenclature` is a hard-coded constant never varying per Settlement
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/generate-prompt.ts` — command handler for `generate-prompt <settlement-id>`; searches active/ then completed/; writes to `HealthOS/Constructor/Steward/prompts/generated/`
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added `"generate-prompt"` to StewardCommand type and switch dispatcher
- Smoke: `generate-prompt st-012-settler-profile-registry` → 16-section PromptSpec written; grep count = 16; no undefined artifacts; exit 0
- Maturity: implemented seam
- Non-claims: no LLM calls, no model routing, no HTTP requests, no new npm dependencies, no clinical authority, no merge authority, no MCP server, no writes except `HealthOS/Constructor/Steward/prompts/generated/`

### ST-016 — Settlement Validation and PR Review Draft Engine

Status: DONE.

Goal:
- generate deterministic validation/review drafts from Settlement records and repository evidence
- never create merge authority

Outcome (2026-05-04):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/validation-report-builder.ts` — pure function; exports `CriterionResult`, `FileCheckResult`, `ValidationEvidence`, `buildValidationReport`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/pr-draft-builder.ts` — pure function; exports `buildPrDraft`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/validate-settlement.ts` — PASS/FAIL/UNVERIFIED heuristic on done-criteria; exits 1 on any FAIL
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/pr-draft.ts` — PR body Markdown from Settlement fields
- Smoke st-012: validate-settlement → 5 PASS, 0 FAIL, 2 UNVERIFIED; pr-draft → PR draft created; both exit 0
- Maturity: implemented seam
- Non-claims: no shell execution, no LLM calls, no merge authority, no clinical authority, no new npm deps, fail-closed on all error paths

### ST-017 — Derived Memory Builder

Status: DONE.

Goal:
- build derived handoff memory from official docs and validated repository state
- keep derived memory non-canonical

Outcome (2026-05-04):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/tracker-reader.ts` — reads all ST tasks from tracker (all ### ST-\d+ sections); exports `TrackerTask` and `readAllTrackerTasks()`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/lib/memory-builder.ts` — 6 pure builder functions; no FS calls; exports `buildIndex`, `buildConstructionStatus`, `buildTerritoryIndex`, `buildSettlerIndex`, `buildSettlementIndex`, `buildHandoffSnapshot`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/build-memory.ts` — command handler; reads ST tracker, Territory JSON files, Settler README, Settlement .md files, and handoff doc; writes 6 files to `HealthOS/Constructor/Steward/memory/derived/`; per-file error tolerance; fail-closed only on mkdirSync failure
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — added `"build-memory"` to StewardCommand type and switch (total: 10 commands)
- Smoke: `build-memory` → "Built 6 derived memory files to HealthOS/Constructor/Steward/memory/derived/"; 0 warnings; exit 0
- All 6 derived files carry NON-CANONICAL header; files are overwritten on each run (idempotent)
- Maturity: implemented seam
- Non-claims: no LLM calls, no shell execution, no HTTP requests, no new npm deps, no writes outside memory/derived/, no clinical authority, no merge authority, derived memory never replaces official docs

### ST-018 — healthos-forge-mcp surface over deterministic operations

Status: DONE.

Goal:
- expose deterministic repository-maintenance operations through `healthos-forge-mcp`
- keep `healthos-forge-mcp` separate from future HealthOS runtime MCP servers

Outcome (2026-05-05):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` (`@healthos/forge-mcp` 0.1.0) — new npm workspace package
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json` — deps: `@modelcontextprotocol/sdk ^1.0.0`, `@healthos/steward 0.2.0`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/tsconfig.json` — ES2022 / NodeNext / strict
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/server.ts` — stdio MCP server entry point (shebang, Server + StdioServerTransport)
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/tools.ts` — TOOLS array (10 tools) + callTool dispatcher; all handlers call @healthos/steward lib functions directly; repoRoot declared locally
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/index.ts` — 17 lib re-exports added (tracker, territory, settler, settlement, prompt assembler, memory builders, validation types)
- 10 tools: steward_next_task, steward_scan_status, steward_get_handoff, steward_list_territories, steward_inspect_territory, steward_list_settlers, steward_list_settlements, steward_validate_settlement, steward_generate_prompt, steward_build_memory
- Smoke: initialize OK; tools/list → 10 tools; steward_next_task → ST-018 (first TODO); steward_inspect_territory core → core data; steward_list_territories → 14 territories; clinical tool grep → 0
- `make ts-build` PASS; @healthos/steward all 10 existing commands unchanged
- Known gap recorded: mcp-local has clinical tool names (patient_context, service_context, session_drafts) — boundary violation, future cleanup task
- Maturity: implemented seam (stdio MCP, 10 deterministic tools)
- Non-claims: no clinical tools, no LLM calls, no shell execution, no merge authority, separate from HealthOS runtime MCPs

Hardening follow-up (2026-05-07):
- Added `@healthos/forge-mcp` tests for the documented 10 `steward_*` tools and round-trip Settlement ID behavior (`id` / `canonicalId`).
- Shared Settlement done-criteria classification now lives in `@healthos/steward` and is consumed by both `healthos-steward validate-settlement` and Forge MCP validation handlers.
- Forge MCP prompt generation can be exercised in read-only test mode for ID-resolution coverage; normal MCP handler behavior still writes generated prompt artifacts.
- Validation: `cd HealthOS/Constructor/ts && npm test --workspace @healthos/forge-mcp` PASS; `cd HealthOS/Constructor/ts && npm test --workspace @healthos/steward` PASS; `make validate-construction-system` PASS; `make ts-build` PASS; `make ts-test` PASS; `make validate-docs` PASS; `git diff --check` PASS.

### ST-019 — Xcode/Codex/Claude integration instructions

Status: DONE.

Goal:
- align assistant instructions with the construction operating model
- do not claim Xcode Intelligence, Codex, or Claude can execute Steward capabilities not yet implemented

Outcome (2026-05-05):
- Updated `CLAUDE.md` — bash code block now includes all 10 implemented `healthos-steward` CLI commands (added missing `validate-settlement <settlement-id>`, `pr-draft <settlement-id>`, `build-memory` lines); forge-mcp boundary section corrected from stale planned tool names to actual implemented `steward_*` names; both forge-mcp paragraphs now consistent
- Updated `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` — ST-019 marked DONE; ST-020 goal revised from APP-011 (DONE) to APP-012 (CloudClinic) with explanatory note
- Updated `HealthOS/Shared/docs/execution/02-status-and-tracking.md` — ST-019 completion entry added
- Updated `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` (this file) — ST-019 DONE with this Outcome block
- Also removed `HealthOS/Constructor/ts/agent-infra/mcp-local/` — unused stub with clinical tool names (`patient_context`, `service_context`, `session_drafts`); `construction-system.json`, `settler-xcode-tooling.md`, `README.md`, `CLAUDE.md`, doc 22 updated; `HealthOS/Constructor/ts/package-lock.json` updated via `npm install`; `make ts-build` PASS
- Validation: `make validate-docs` PASS; `make ts-build` PASS
- Invariants: construction-system boundary preserved; no clinical authority; no runtime scope; `healthos-forge-mcp` remains the sole repository-maintenance MCP surface
- Maturity: instruction surface aligned and boundary violation resolved (scaffolded contract)
- Residual gaps: none (mcp-local boundary violation resolved in this task)

### DOC-README-001 — Repository README alignment with current implementation state

Status: DONE (2026-05-05).

Goal:
- update README.md to reflect actual implemented state through ST-018 (PR #99)
- fix all stale Veridia references, stale CLI block, stale forge-mcp mermaid, wrong directory paths
- add construction system reading paths, lifecycle mermaid, maturity snapshot entry

Outcome (2026-05-05):
- All 12 goals completed; see `HealthOS/Shared/docs/execution/02-status-and-tracking.md` DOC-README-001 entry for full detail
- Branch: `HealthOS/Shared/docs/readme-alignment-st018`
- Validation: Veridia → 0 matches; "not yet implemented" → 0; `Territory` → 0; 14 npx CLI lines; false claim removed
- Invariants: no source code changed; construction-system boundary preserved; no clinical authority
- Residual gaps: APP-012 and CI-001 remain separate future tasks

### ST-022 — Steward Coordinator Managed Agent definition (2026-05-05)

Status: DONE.

Goal:
- create @healthos/managed-agent package defining the Steward Coordinator agent for Anthropic Managed Agents API
- system prompt encoding doc-22 construction lifecycle (7 stages, 10 forge-mcp tools, strict boundaries)
- idempotent create-agent script (upsert: create / show-saved / --force update / --dry-run)
- mcp_servers pointing to forge-mcp HTTP server (ST-021); FORGE_MCP_URL configurable for public endpoint

Outcome (2026-05-05):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/` (`@healthos/managed-agent` 0.1.0)
- `src/agent-def.ts` — STEWARD_COORDINATOR_DEF: model claude-opus-4-7, system prompt with 7-stage lifecycle + 10 tool descriptions + boundary invariants, mcp_servers + mcp_toolset
- `src/create-agent.ts` — upsert script with --dry-run (no API), --force (update), state persistence to HealthOS/Constructor/Steward/managed-agent/agent.json
- `src/index.ts` — re-exports
- `package.json` — @anthropic-ai/sdk ^0.40.0; scripts: create-agent, create-agent:dry-run, create-agent:force
- `HealthOS/Constructor/Steward/managed-agent/.gitkeep`
- Validation: make ts-build PASS; --dry-run PASS; make validate-docs PASS
- Constraint: FORGE_MCP_URL must be publicly accessible for Managed Agents API cloud calls
- Maturity: implemented seam
- Non-claims: no clinical authority; no merge authority; no production readiness; ANTHROPIC_API_KEY never persisted

### ST-023 — session client workflows for construction lifecycle (2026-05-05)

Status: DONE.

Goal:
- add a typed `session-client.ts` module to `@healthos/managed-agent`
- wrap Anthropic Managed Agents sessions into four human-triggered construction workflow functions: `discover`, `brief`, `validate`, `handoff`
- keep execution external; do not create a CLI, HTTP server, cron runner, or clinical/runtime surface

Outcome (2026-05-05):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/session-client.ts` — implemented seam module; reads `HealthOS/Constructor/Steward/managed-agent/agent.json` at call time; requires `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN`; creates Managed Agents sessions; streams responses; returns typed results with `_disclaimer`
- Created `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/src/workflows.ts` — thin barrel re-export for workflow functions and result types
- Updated `src/index.ts` to re-export the workflow public surface
- Validation: `make ts-build` PASS; managed-agent `tsc --noEmit` PASS; dist workflow files exist; `create-agent --dry-run` PASS; `make validate-docs` PASS
- Maturity: implemented seam
- Non-claims: no clinical authority; no merge authority; no production readiness; no autonomous execution; no live Managed Agents API workflow run in validation

### ST-021 — forge-mcp HTTP/Streamable HTTP transport (2026-05-05)

Status: DONE.

Goal:
- add HTTP/SSE transport to healthos-forge-mcp so Managed Agents API can connect to it (requires HTTP MCP server, not stdio)
- expose same 10 deterministic tools via StreamableHTTPServerTransport on http://127.0.0.1:${FORGE_MCP_PORT:-3791}/mcp
- keep stdio transport (server.ts) unmodified
- require zero new npm dependencies

Outcome (2026-05-05):
- Created `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/src/server-http.ts` — new HTTP entry point; stateless per-request McpServer + StreamableHTTPServerTransport; binds 127.0.0.1 only; port from FORGE_MCP_PORT (default 3791); reuses registerTools() from tools.ts without modification
- Updated `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json` — added `healthos-forge-mcp-http` bin and `start:http` script
- Updated `HealthOS/Shared/docs/execution/02-status-and-tracking.md`, `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` (this file), `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- Validation: `make ts-build` PASS; smoke initialize PASS; smoke tools/list → 10 tools PASS
- Maturity: implemented seam
- Non-claims: no clinical authority; no merge authority; no production readiness; no runtime MCP; no new npm deps; stdio transport unmodified; healthos-forge-mcp is not a HealthOS runtime MCP server

### ST-020 — Use Steward to generate APP-012 (CloudClinic) prompt

Status: NEEDS-REVIEW / BLOCKED AS WRITTEN after ADR-0013.

Goal:
- current wording asks the construction system to generate an APP-012 implementation prompt
- APP-012 is now blocked as Stage implementation until Core/GOS/runtime readiness, CloudClinic Boundary, and CloudClinic Custom criteria are satisfied
- required reframe before execution: create a CloudClinic Custom / Boundary-readiness Settlement and PromptSpec instead of an APP-012 implementation prompt
- note: APP-011 is DONE (VeridiaSessionFacade, PR #98, 2026-05-04); APP-011 remains valid boundary scaffold evidence, not a reason to bypass ADR-0013 ordering
- next acceptable output: a bounded construction work unit that defines CloudClinic consumed surfaces, degraded behavior, Custom evidence, and objective APP-012 unblock criteria without wiring the CloudClinic Stage

## Historical streams

### ST-1 Settler profile instructions

Create profile docs or skill files for each initial Settler.

Define territory, invariants, forbidden moves, validation expectations, maturity, and handoff requirements for each profile.

Current scaffold root: `HealthOS/Constructor/Settler/profiles/`.

### ST-2 Settlement record schema

Define a schema for a Settlement work unit.

The schema should capture objective, Territory, files in scope, invariants, restrictions, validation commands, done criteria, residual gaps, and handoff.

No execution is implemented in this stream.

Current scaffold root: `HealthOS/Constructor/Settler/settlements/`.

### ST-2a Territory record scaffolds

Define Territory records as documentation-only repository domain records.

Current scaffold root: `HealthOS/Constructor/Territory/territories/`.

### ST-3 healthos-forge-mcp operations for Steward/Settlers

Expose repository-maintenance tools for Steward and Settlers.

Implemented operations are the 10 deterministic `steward_*` tools exposed by `healthos-forge-mcp`. Older planned names such as `scan-status`, `next-task`, `check-invariants`, and `check-doc-drift` remain historical/planned labels unless implemented and locally smoked.

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
- define initial Territory records under `HealthOS/Constructor/Territory/territories/`
- keep records subordinate to official docs
- include canonical docs, files in scope, invariants, validation commands, maturity, and known gaps

## Non-claims

No HealthOS runtime implementation exists in the Construction System.

No clinical agents are created.

No merge authority is granted.

No production readiness is claimed.

`healthos-forge-mcp` is implemented as a repository-maintenance MCP seam only.

No HealthOS runtime MCP server is implemented.

Territory loading is implemented for deterministic Steward/Forge inspection flows. It does not make Territory records canonical law.

Deterministic Steward CLI inspection seam implemented (ST-014): `list territories|settlers|settlements`, `inspect territory|settler|settlement <id>`, and `next` are delivered. All are read-only, deterministic, no model calls, no writes, no new npm deps.

No Settlement write/create CLI is implemented.

Prompt generation is implemented as deterministic PromptSpec assembly from Settlement, Territory, and Settler records. It does not call an LLM and does not execute work.
