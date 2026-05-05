# Steward Construction Operating Model

## Canonical statement

Steward is the construction coordinator for the HealthOS repository.

Settlers are specialized engineering profiles.

Settlements are bounded work units.

Territories are repository domains.

This construction system exists to generate prompts, validate work, preserve memory, and maintain handoffs.

It is outside the HealthOS clinical/runtime hierarchy. Steward, Settlers, Settlements, Territories, `healthos-steward`, and `healthos-forge-mcp` do not become HealthOS Core, GOS, AACI, app runtimes, clinical actors, or authority surfaces.

## Why this exists now

P0/P1/P2 structural cleanup made the repository ontology clearer: Mental Space Runtime has a named runtime boundary, legacy material has been archived, agent infrastructure has been separated from product packages, session runtime vocabulary has been corrected, and Sortio/CloudClinic now have honest scaffold executable targets.

Manual prompt generation is now becoming the bottleneck. The repository can continue to execute APP/RT/STR tasks manually, but repeated hand-authored prompts make scope, invariants, validation, and residual-gap recording harder to keep consistent.

The repository needs deterministic construction tooling before more product work relies on Steward. Steward should eventually generate prompts like those used for STR, RT, and APP tasks, but only from official docs and bounded Settlement records.

## Relationship to doc 21

`docs/execution/21-structural-ontology-and-product-readiness-plan.md` remains the canonical product task queue until superseded.

This document defines how construction work is organized.

ST tasks are construction-system tasks.

APP, RT, STR, and CI tasks remain product/repo tasks.

Steward will eventually read doc 21 to generate Settlements. Until that capability exists and is validated, agents must keep reading doc 21 directly for product task selection.
For product-definition grounding, Steward and Settlers must also consult `docs/product/01-healthos-technical-product-specification.md` as the consolidated technical product baseline, while keeping architecture doctrine and execution governance canonical.

## Operational primitives

Steward: canonical engineering coordinator for the HealthOS construction repository. Steward frames work, reads official docs, selects or proposes Settlements, chooses Settler profiles, requests validation, reviews scope, and records handoffs. Steward is non-clinical, non-constitutional, non-authorizing, and has no merge authority.

Settler: specialized engineering profile assigned to a Territory. A Settler narrows attention to a repository domain, its docs, files, invariants, tests, and forbidden moves. A Settler never holds clinical authority, Core law authority, merge authority, or autonomous execution authority.

Settlement: bounded construction work unit. A Settlement records the objective, task id, status, priority, Territories, Settlers, source docs, files in scope, forbidden files, invariants, allowed changes, forbidden changes, validation commands, done criteria, residual gaps, and handoff requirements.

Territory: repository domain with docs, files, invariants, tests, maturity, known gaps, and validation expectations. Territories are navigation and scoping records, not canonical law.

PromptSpec: derived prompt instruction record generated from official docs, Settlement records, and templates. A PromptSpec must preserve HealthOS invariants, non-claims, scope limits, validation requirements, and residual-gap expectations.

ReviewDraft: derived review material for a Settlement or PR. A ReviewDraft may summarize scope, validation evidence, invariant checks, and residual gaps. It is not an approval, merge authorization, clinical judgment, or canonical doc.

DerivedMemory: repository-local derived memory under `.healthos-steward/memory/`. DerivedMemory accelerates navigation and handoff but never replaces official docs.

healthos-forge-mcp: future repository-maintenance MCP for Steward and Settlers. It may expose typed repository operations such as validation, status scanning, handoff retrieval, invariant checks, doc drift checks, next-task inspection, and PR review draft generation. It is not a HealthOS runtime MCP server.

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

`generate-prompt` means a future prompt generation engine creates a bounded PromptSpec from official docs, Settlement records, and templates. In ST-010 this remains a planned capability only.

`execute` means an implementer performs only the scoped work without widening product/runtime behavior.

`validate` means required commands run and failures are fixed if caused by the Settlement or recorded precisely if unrelated.

`review` means the output is checked against scope, invariants, maturity claims, non-claims, validation evidence, and residual gaps.

`record` means tracking docs, handoff notes, Settlement records, and derived memory are updated without making derived memory canonical.

## Directory model

```text
.healthos-steward/
  memory/
    derived/
  settlements/
    active/
    completed/
    templates/
  prompts/
    generated/
    templates/
.healthos-settler/
  territories/
  settlers/
```

`.healthos-steward/memory/derived/` belongs to derived repository memory generated from official docs and validated repository state.

`.healthos-steward/settlements/active/` will hold active Settlement records once the deterministic workflow exists.

`.healthos-steward/settlements/completed/` will hold completed Settlement records after validation, review, and handoff recording.

`.healthos-steward/settlements/templates/` holds scaffold schemas and templates for future Settlement records.

`.healthos-steward/prompts/generated/` will hold generated prompts from future Steward prompt generation. Generated prompts are derived artifacts, not canonical docs.

`.healthos-steward/prompts/templates/` will hold prompt templates that preserve HealthOS invariants and non-claims.

`.healthos-settler/territories/` holds the ST-011 Territory Registry. Territory records map docs, files, invariants, tests, maturity boundaries, validation expectations, known gaps, and forbidden moves.

`.healthos-settler/settlers/` holds Settler profile records created in ST-012. Settler records define specialized engineering profiles without authority.

## Planned construction task sequence

- ST-010 — Construction Operating Model baseline
- ST-011 — Territory Registry (DONE): schema plus initial Territory records for Core, GOS, Session Runtime, MSR, AACI, Providers, apps, TypeScript runtimes, storage/data, regulatory/interoperability, operations/observability, construction-system, validation/CI, and documentation
- ST-012 — Settler Profile Registry (DONE 2026-05-04): `.healthos-settler/settlers/` now populated with 9 profiles + README; example Settlement record created in ST-013
- ST-013 — Settlement Record Schema and templates (DONE 2026-05-04): SCHEMA.md, settlement-template.md, and st-012 example Settlement completed; settlement.schema.json patched for field coverage; ST-014 is next
- ST-014 — Deterministic Steward CLI inspect/next/list (DONE 2026-05-04): deterministic inspect/list/next CLI seam implemented in `@healthos/steward`; 6 commands now operational; ST-015 is next
- ST-015 — Prompt Generation Engine (DONE 2026-05-04): deterministic prompt assembly from Settlement + Territory + Settler records implemented; `generate-prompt <settlement-id>` writes 16-section PromptSpec to `.healthos-steward/prompts/generated/`; ST-016 is next
- ST-016 — Settlement Validation and PR Review Draft Engine (DONE 2026-05-04): `validate-settlement <id>` and `pr-draft <id>` implemented in `@healthos/steward`; ValidationReport and ReviewDraft engines operational; exits 1 on any FAIL criterion (CI-compatible); no shell execution, no LLM, no merge authority; ST-017 is next
- ST-017 — Derived Memory Builder (DONE 2026-05-04): `build-memory` command writes 6 non-canonical derived snapshot files to `.healthos-steward/memory/derived/` (INDEX.md, construction-status.md, territory-index.md, settler-index.md, settlement-index.md, handoff-snapshot.md); files are overwritten on each run; no LLM, no shell, no new npm deps; ST-018 is next
- ST-018 — healthos-forge-mcp surface over deterministic operations
- ST-019 — Xcode/Codex/Claude integration instructions
- ST-020 — Use Steward to generate APP-011 prompt

## Non-claims

- no autonomous multiagent execution yet
- no MCP server yet
- no LLM calls yet
- no model routing yet
- no clinical authority
- no merge authority
- no production readiness
- no replacement of official docs
- no runtime MCP implementation

## Maturity

The construction operating model is a scaffolded contract.

Steward/Settler execution remains doctrine-only or scaffolded contract, depending on existing code. Current deterministic `healthos-steward` behavior remains limited to implemented CLI surfaces and must not be expanded by documentation claim.

`healthos-forge-mcp` remains doctrine-only or scaffold.

No construction component is production-hardened.

## ST-011 Territory Registry output

ST-011 creates the first structured Territory Registry under `.healthos-settler/territories/`.

Each record is a construction-system domain contract with:

- repository-domain identity and maturity
- canonical docs
- primary, secondary, and forbidden paths
- invariants, allowed work, and forbidden work
- validation commands and known gaps
- expected future Settler IDs and related Territory IDs

Future Settler profiles will reference Territory IDs to inherit scope boundaries, invariant posture, validation expectations, and forbidden moves.

Future Settlement records will reference Territory IDs to define bounded work units and prevent scope drift.

Future prompt generation will read Territory records alongside official docs and Settlement records to produce bounded implementation prompts.

Future review/validation and HealthOS Forge MCP tooling may use Territory records for deterministic repository-maintenance checks.

Territory records do not replace official docs, implement Settlers, create Settlement instances, implement prompt generation, implement `healthos-forge-mcp`, or authorize runtime behavior.
