# Steward Construction Operating Model

## Canonical statement

Steward is the construction coordinator for the HealthOS repository.

Settlers are specialized engineering profiles.

Settlements are bounded work units.

Territories are repository domains.

This construction system exists to generate prompts, validate work, preserve memory, and maintain handoffs.

It is outside the HealthOS clinical/runtime hierarchy. Steward, Settlers, Settlements, Territories, `healthos-steward`, and `healthos-forge-mcp` do not become HealthOS Core, GOS, AACI, app runtimes, clinical actors, or authority surfaces.

## Why this exists now

P0/P1/P2 structural cleanup made the repository ontology clearer: Mental Space Runtime has a named runtime boundary, legacy material has been archived, agent infrastructure has been separated from product packages, session runtime vocabulary has been corrected, and Veridia/CloudClinic now have honest scaffold executable targets.

Manual prompt generation is now becoming the bottleneck. The repository can continue to execute APP/RT/STR tasks manually, but repeated hand-authored prompts make scope, invariants, validation, and residual-gap recording harder to keep consistent.

The repository needs deterministic construction tooling before more product work relies on Steward. Steward should eventually generate prompts like those used for STR, RT, and APP tasks, but only from official docs and bounded Settlement records.

## Relationship to doc 21

`HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` remains the canonical product task queue until superseded.

This document defines how construction work is organized.

ST tasks are construction-system tasks.

APP, RT, STR, and CI tasks remain product/repo tasks.

Steward will eventually read doc 21 to generate Settlements. Until that capability exists and is validated, agents must keep reading doc 21 directly for product task selection.
For product-definition grounding, Steward and Settlers must also consult `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` as the consolidated technical product baseline, while keeping architecture doctrine and execution governance canonical.

## Operational primitives

Steward: canonical engineering coordinator for the HealthOS construction repository. Steward frames work, reads official docs, selects or proposes Settlements, chooses Settler profiles, requests validation, reviews scope, and records handoffs. Steward is non-clinical, non-constitutional, non-authorizing, and has no merge authority.

Settler: specialized engineering profile assigned to a Territory. A Settler narrows attention to a repository domain, its docs, files, invariants, tests, and forbidden moves. A Settler never holds clinical authority, Core law authority, merge authority, or autonomous execution authority.

Settlement: bounded construction work unit. A Settlement records the objective, task id, status, priority, Territories, Settlers, source docs, files in scope, forbidden files, invariants, allowed changes, forbidden changes, validation commands, done criteria, residual gaps, and handoff requirements.

Territory: repository domain with docs, files, invariants, tests, maturity, known gaps, and validation expectations. Territories are navigation and scoping records, not canonical law.

PromptSpec: derived prompt instruction record generated from official docs, Settlement records, and templates. A PromptSpec must preserve HealthOS invariants, non-claims, scope limits, validation requirements, and residual-gap expectations.

ReviewDraft: derived review material for a Settlement or PR. A ReviewDraft may summarize scope, validation evidence, invariant checks, and residual gaps. It is not an approval, merge authorization, clinical judgment, or canonical doc.

DerivedMemory: repository-local derived memory under `HealthOS/Constructor/Steward/memory/`. DerivedMemory accelerates navigation and handoff but never replaces official docs.

healthos-forge-mcp: repository-maintenance MCP server for Steward and Settlers. Implemented as a stdio JSON-RPC MCP server at `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` (`@healthos/forge-mcp` 0.1.0, ST-018, 2026-05-05). Exposes 10 deterministic repository-maintenance tools wrapping `@healthos/steward` lib functions: steward_next_task, steward_scan_status, steward_get_handoff, steward_list_territories, steward_inspect_territory, steward_list_settlers, steward_list_settlements, steward_validate_settlement, steward_generate_prompt, steward_build_memory. It is not a HealthOS runtime MCP server. (`HealthOS/Constructor/ts/agent-infra/mcp-local` was a pre-ST-018 stub with clinical tool names; it was removed in ST-019 (2026-05-05) — `healthos-forge-mcp` is the sole repository-maintenance MCP surface.) (FORGE-MCP-V2, 2026-05-05): upgraded to McpServer high-level API + Zod-validated inputs; handler business logic extracted to `src/handlers.ts`; `src/tools.ts` uses `McpServer.registerTool()` with Zod `inputSchema`; `README.md` added with Claude Desktop and generic stdio client configuration. SDK updated to `^1.29.0`. Known workaround: `// @ts-nocheck` in `src/tools-id-arg.ts` for TS2589 depth-limit issue with Zod 4 + MCP SDK 1.29.0 dual-compat types — runtime Zod validation unaffected.

## Construction lifecycle

```text
discover
  └─ select
    └─ assign
      └─ generate-prompt
        └─ execute
          └─ validate
            └─ review
              └─ record
```

`discover` means Steward identifies candidate work from official docs, trackers, handoffs, repository status, or operator instruction.

`select` means the next bounded work unit is chosen according to official task order and prerequisites.

`assign` means one or more Settler profiles and Territories are selected for the work.

`generate-prompt` means the deterministic prompt generation engine creates a bounded PromptSpec from official docs, Settlement records, and templates. It is an implemented seam, not an executor or LLM caller.

`execute` means an implementer performs only the scoped work without widening product/runtime behavior.

`validate` means required commands run and failures are fixed if caused by the Settlement or recorded precisely if unrelated.

`review` means the output is checked against scope, invariants, maturity claims, non-claims, validation evidence, and residual gaps.

`record` means tracking docs, handoff notes, Settlement records, and derived memory are updated without making derived memory canonical.

## Directory model

```text
HealthOS/Constructor/Steward/
  memory/
    derived/
  settlements/
    active/
    completed/
    templates/
  prompts/
    generated/
    templates/
HealthOS/Constructor/Settler/
  territories/
  settlers/
```

`HealthOS/Constructor/Steward/memory/derived/` belongs to derived repository memory generated from official docs and validated repository state.

`HealthOS/Constructor/Steward/settlements/active/` holds active Settlement records when a bounded construction work unit is in progress.

`HealthOS/Constructor/Steward/settlements/completed/` will hold completed Settlement records after validation, review, and handoff recording.

`HealthOS/Constructor/Steward/settlements/templates/` holds scaffold schemas and templates for Settlement records.

`HealthOS/Constructor/Steward/prompts/generated/` holds generated prompts, validation reports, and PR drafts from deterministic Steward operations. Generated artifacts are derived artifacts, not canonical docs.

`HealthOS/Constructor/Steward/prompts/templates/` will hold prompt templates that preserve HealthOS invariants and non-claims.

`HealthOS/Constructor/Settler/territories/` holds the ST-011 Territory Registry. Territory records map docs, files, invariants, tests, maturity boundaries, validation expectations, known gaps, and forbidden moves.

`HealthOS/Constructor/Settler/settlers/` holds Settler profile records created in ST-012. Settler records define specialized engineering profiles without authority.

## Planned construction task sequence

- ST-010 — Construction Operating Model baseline
- ST-011 — Territory Registry (DONE): schema plus initial Territory records for Core, GOS, Session Runtime, MSR, AACI, Providers, apps, TypeScript runtimes, storage/data, regulatory/interoperability, operations/observability, construction-system, validation/CI, and documentation
- ST-012 — Settler Profile Registry (DONE 2026-05-04): `HealthOS/Constructor/Settler/settlers/` now populated with 9 profiles + README; example Settlement record created in ST-013
- ST-013 — Settlement Record Schema and templates (DONE 2026-05-04): SCHEMA.md, settlement-template.md, and st-012 example Settlement completed; settlement.schema.json patched for field coverage; ST-014 is next
- ST-014 — Deterministic Steward CLI inspect/next/list (DONE 2026-05-04): deterministic inspect/list/next CLI seam implemented in `@healthos/steward`; 6 commands now operational; ST-015 is next
- ST-015 — Prompt Generation Engine (DONE 2026-05-04): deterministic prompt assembly from Settlement + Territory + Settler records implemented; `generate-prompt <settlement-id>` writes 16-section PromptSpec to `HealthOS/Constructor/Steward/prompts/generated/`; ST-016 is next
- ST-016 — Settlement Validation and PR Review Draft Engine (DONE 2026-05-04): `validate-settlement <id>` and `pr-draft <id>` implemented in `@healthos/steward`; ValidationReport and ReviewDraft engines operational; exits 1 on any FAIL criterion (CI-compatible); no shell execution, no LLM, no merge authority; ST-017 is next
- ST-017 — Derived Memory Builder (DONE 2026-05-04): `build-memory` command writes 6 non-canonical derived snapshot files to `HealthOS/Constructor/Steward/memory/derived/` (INDEX.md, construction-status.md, territory-index.md, settler-index.md, settlement-index.md, handoff-snapshot.md); files are overwritten on each run; no LLM, no shell, no new npm deps; ST-018 is next
- ST-018 — healthos-forge-mcp surface over deterministic operations (DONE 2026-05-05): `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` created; 10 deterministic tools exposed via stdio MCP; `@healthos/steward` lib re-exports added; ST-019 is next
- ST-019 — Xcode/Codex/Claude integration instructions (DONE 2026-05-05): CLAUDE.md and tracking docs aligned with actual implemented state of ST-018; all 10 CLI commands documented in bash block; forge-mcp tool list corrected from stale planned names to actual steward_* names; ST-020 goal revised to APP-012; ST-021 is next
- ST-020 — Use Steward to generate APP-012 (CloudClinic) prompt (NEEDS-REVIEW / BLOCKED AS WRITTEN after ADR-0013): APP-012 is Stage implementation and is blocked until Core/GOS/runtime/Boundary/Custom readiness is met. Reframe ST-020 to generate a CloudClinic Custom / Boundary-readiness prompt, or wait until APP-012 unblock criteria are satisfied. APP-011 remains DONE as Boundary scaffold evidence.
- ST-021 — forge-mcp HTTP/Streamable HTTP transport (DONE 2026-05-05): `src/server-http.ts` added to `@healthos/forge-mcp`; same 10 tools exposed via StreamableHTTPServerTransport on http://127.0.0.1:3791/mcp; zero new npm deps; stdio transport unmodified; required for Managed Agents API compatibility; ST-022 is next
- ST-022 — Steward Coordinator Managed Agent definition (DONE 2026-05-05): `HealthOS/Constructor/ts/agent-infra/healthos-managed-agent/` created (`@healthos/managed-agent` 0.1.0); STEWARD_COORDINATOR_DEF with claude-opus-4-7, system prompt encoding doc-22 lifecycle, mcp_servers pointing to forge-mcp HTTP; idempotent create-agent script with --dry-run/--force; @anthropic-ai/sdk added; ST-023 is next
- ST-023 — session client workflows for construction lifecycle (DONE 2026-05-05): `session-client.ts` added to `@healthos/managed-agent`; four typed async workflow functions: discover, brief, validate, handoff; each creates a Managed Agents session against `agent.json` ID, streams response, returns typed result with `_disclaimer` field; `workflows.ts` barrel re-export; `index.ts` updated; no new npm deps; no CLI entry point; implemented seam maturity.

## Non-claims

- no autonomous multiagent execution yet
- no LLM calls yet
- no model routing yet
- no clinical authority
- no merge authority
- no production readiness
- no replacement of official docs
- no runtime MCP implementation

## Maturity

The construction operating model is a scaffolded contract.

Settler execution remains doctrine-only. Current deterministic `healthos-steward` behavior is an implemented repository-maintenance seam limited to documented CLI/library surfaces and must not be expanded by documentation claim.

`healthos-forge-mcp` is an implemented repository-maintenance MCP seam over deterministic `steward_*` operations. It is not a HealthOS runtime MCP server.

No construction component is production-hardened.

## ST-011 Territory Registry output

ST-011 creates the first structured Territory Registry under `HealthOS/Constructor/Settler/territories/`.

Each record is a construction-system domain contract with:

- repository-domain identity and maturity
- canonical docs
- primary, secondary, and forbidden paths
- invariants, allowed work, and forbidden work
- validation commands and known gaps
- expected future Settler IDs and related Territory IDs

Settler profiles reference Territory IDs to inherit scope boundaries, invariant posture, validation expectations, and forbidden moves.

Settlement records reference Territory IDs to define bounded work units and prevent scope drift.

Prompt generation reads Territory records alongside official docs and Settlement records to produce bounded implementation prompts.

Review/validation and HealthOS Forge MCP tooling use Territory records for deterministic repository-maintenance checks.

Territory records do not replace official docs, implement Settler execution, authorize Settlement completion, grant clinical authority, or authorize runtime behavior.
