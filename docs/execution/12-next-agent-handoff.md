# Next agent handoff (2026-04-29)

## Current state

Repository is in controlled implementation/scaffold hardening. Governance contracts, Swift tests, TS build, GOS tooling, transcript normalization in `HealthOSSessionRuntime`, and the MSR stage contracts are all in place. A full structural ontology and product-readiness analysis was performed on 2026-04-29 and produced a canonical priority-ordered work plan.

HealthOScaffold is the historical repository name and construction repository for HealthOS. Future agents must treat implemented architecture, contracts, runtimes, apps, tests, and docs here as HealthOS work unless explicitly marked experimental or deprecated; scaffold vocabulary describes maturity/foundation phase only.

## README visual entrypoint note

DOC-README-VISUAL-PRESENTATION-001 added a compact README orientation lens for new agents, including clinical/runtime hierarchy versus construction tooling and explicit evidence/maturity reading language.

The work unit also generated an editable HealthOS visual overview PPTX outside the commit because the repository does not yet have a clear `docs/assets/presentations/` versioning pattern. Future documentation work can decide whether to create a durable versioned asset path such as `docs/assets/presentations/healthos-visual-overview.pptx`; do not link to a non-versioned deck from canonical docs.

## Construction-system track

ST-010 started the construction-system track by adding `docs/execution/22-steward-construction-operating-model.md` and the initial `.healthos-settler/` / `.healthos-steward/` construction skeletons.

ST-011 created the Territory Registry under `.healthos-settler/territories/`, including `territory.schema.json` and initial Territory records for repository domains. Territory records are construction metadata only and remain subordinate to official docs.

ST-011B created the product technical specification baseline at `docs/product/01-healthos-technical-product-specification.md`. Future construction and product tasks should read this product baseline together with canonical architecture and execution docs when generating scoped work units.

Future construction-system work should read doc 22 before creating Settler profiles, Settlement templates, prompt generation, PR review drafts, derived memory builders, or `healthos-forge-mcp` surfaces. Product queue work still reads doc 21. APP-012 is no longer READY as app implementation; it is blocked until platform/runtime surfaces, App Integration Boundary, and CloudClinic App Charter readiness are satisfied. Independent construction-system work may proceed, but app-prompt generation for blocked app wiring must be reframed as charter/boundary-readiness work.

## CRITICAL: Read the master plan first

**Before selecting any task, read:**

```
docs/execution/21-structural-ontology-and-product-readiness-plan.md
```

This document is the authoritative priority-ordered work plan as of 2026-04-29. It supersedes the ordering in individual TODO files. It contains:

- A priority grid (P0 → P4) with task IDs, status, prerequisites, and branch names
- Full task specs with exact files to touch, implementation notes, and definitions of done
- The canonical Git + PR workflow every task must follow
- Ontology invariants that must never be violated

**The product/repo priority order after the 2026-05-07 app-layer boundary audit is:**

| Tier | What | Why |
|------|------|-----|
| **P0/P1 completed** | STR-001, RT-MSR-001, RT-MSR-002, RT-MSR-003, STR-002, STR-003, STR-004 | MSR provider-backed stages and structural cleanup are already landed; do not reselect them from stale TODO text |
| **Tier 1 READY** | CI-001, RT-ASYNC-001, RT-RETRIEVAL-001 | Platform/runtime surfaces and validation gates must advance before new app wiring |
| **Tier 2 / 3 needs-review** | CloudClinic service/runtime mediated surface + App Integration Boundary | Define the exact stable facade/envelope/app-safe view before APP-012 |
| **Tier 4 needs-review** | CloudClinic App Charter | Complete app role, consumed surfaces, degraded behavior, data exposure, validation |
| **Tier 5 BLOCKED** | APP-012 | App implementation/wiring blocked until tiers 1-4 are DONE or explicitly accepted |
| **Tier 6 parallel** | Independent construction-system work | May run in parallel; ST-020 must be reframed if it targets APP-012 implementation |

Current status details:
- RT-PROVIDER-001 is DONE.
- APP-011 is DONE.
- CI-001, RT-ASYNC-001, and RT-RETRIEVAL-001 are READY Tier 1 platform/runtime foundation tasks.
- APP-012 is BLOCKED as Tier 5 app implementation.
- ST-020 is needs-review/blocked as written because it targets generating an APP-012 implementation prompt before APP-012 is unblocked.
- APP-008, CL-006, DS-007, OPS-003, RT-008, and AACI-009 were reconciled as completed in the TODO trackers during the 2026-05-01 local / 2026-05-02 UTC audit.

## How to choose next task

1. Read `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → Priority Grid.
2. Find highest-priority task with Status = `READY` and all prerequisites `DONE`; after the app-layer boundary audit, that means CI-001, RT-ASYNC-001, or RT-RETRIEVAL-001 before any new app wiring.
3. Read that task's full spec in doc 21 (branch name, files, DoD, validation, git workflow).
4. Use the deterministic Steward baseline for repository state context:
   `cd ts && npx --yes --workspace @healthos/steward healthos-steward status`
5. Validate all prerequisites before writing any code.
6. Load the matching skill from `docs/execution/skills/` if one exists.

## Do not touch without explicit reason

- constitutional wording that separates Core vs GOS vs AACI vs apps
- fail-closed guards around lawfulContext / consent / habilitation / gate / finalization
- append-only provenance assumptions
- `HealthOSCore` sovereignty — nothing in P0–P4 moves consent/habilitation/gate law out of Core

## Repository structure notes (from 2026-04-29 analysis)

- Swift Package: `swift/Package.swift` targets macOS 26.0, Swift tools 6.2. Canonical Apple build graph.
- Xcode workspace: `HealthOS.xcworkspace` → points to `swift/Package.swift`. Not a replacement for TS/Python tooling.
- `HealthOSSessionRuntime` is a scaffold module, not a product concept. STR-004 renames it to `HealthOSSessionRuntime`.
- `Skill macOS/` TS scripts are reference implementations, not the active pipeline. STR-002 archives them.
- `ts/packages/` conflates PRODUCT, BUILD, and AGENT packages. STR-003 separates them.
- Veridia and CloudClinic now have minimal Swift executable scaffold targets. APP-011 and APP-012 wire existing boundary contracts into smoke-testable session paths. APP-013 established Veridia as the canonical patient app name on 2026-05-04. Use Veridia in all future prompts/docs and avoid legacy patient-app naming.
- Veridia is the patient health identity app. Do not use "patient sovereignty interface" as the primary definition.
- `HealthOSMSR` depends on `HealthOSCore` and `HealthOSProviders`; transcript normalization is owned by `HealthOSSessionRuntime`.

## Native UI note

`docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` defines scaffold scope for macOS 26+ Liquid Glass app-shell work. Use `docs/execution/skills/native-macos-ui/SKILL.md` for UI work. Do not move Core law into SwiftUI.

## MSR note

`docs/architecture/49-mental-space-runtime.md` and `docs/execution/skills/mental-space-runtime-skill.md` are the canonical refs. `MSR` is now the official sigla for Mental Space Runtime, and transcript normalization belongs to `HealthOSSessionRuntime`, not to MSR. Keep outputs derived/gated/app-safe/non-authorizing at all times.

## Validation command baseline

```bash
make swift-build
make swift-test
make ts-build
make ts-test
make python-check
make validate-docs
make validate-schemas
make validate-contracts
make validate-all
make smoke-cli
make smoke-scribe
```

## Branch / PR discipline

- one coherent work chunk per commit
- update `02-status-and-tracking.md` + relevant TODO in same work unit
- do not close TODO without evidence

## Absolute honesty rules

- no fictitious examples/demo stories
- no production-ready claims
- no false claims for provider/signature/interoperability/semantic retrieval
- no wording that treats HealthOScaffold as a separate product or points to another HealthOS repository
- explicitly record residual gaps/failures

## Steward follow-up

Current `healthos-steward` baseline is intentionally narrow: `status`, `runtime`, and `session` only. Treat it as a repository-local continuity and session-persistence seam, not as a complete deterministic operations surface.

Use these docs as the target source of truth for future steward work:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

The intended evolution is Steward for Xcode: Xcode Intelligence as the Apple-controlled engineering runtime surface, with HealthOS contributing instructions, `healthos-forge-mcp`, derived repository memory, and an expanded deterministic CLI.

Settler model note: the Steward / Settler / Settlement / Territory model was added as doctrine-only in `docs/architecture/47-steward-settler-engineering-model.md`, with future implementation tracked in `docs/execution/19-settler-model-task-tracker.md`. Future work should use those docs and must not treat Settlers as clinical or runtime agents.

Construction operating model note: `docs/execution/22-steward-construction-operating-model.md` now defines the lifecycle, directories, ST-010 through ST-020 sequence, and non-claims for operationalizing Steward construction work. The Territory Registry exists; the next construction-system task is ST-012 — Create Settler Profile Registry.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. The local Codex automation is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`; use it for PR-based review of Claude Code automations, scheduled-task definitions, Xcode/Steward instructions, and automation drift. Do not treat this as a new Steward authority category, merge authority, or clinical/runtime capability.

Repository-local roots now exist for the model:
- `.healthos-settler/` is a documentation-only root for Territory Registry records and future Settler profiles.
- `.healthos-territory/` is a prior documentation-only root for historical Territory scaffold references.

These roots are subordinate to official docs and do not implement executable Settlers, Settlement instances, a Territory loader, or `healthos-forge-mcp`.

## ST-011A runtime taxonomy + Forge MCP naming note (2026-05-01)

- Prose concept names are: Core, GOS, Session Runtime, AACI, MSR, Providers, Async Runtime, User-Agent Runtime, and Service Runtime.
- Implementation/module/package names remain: `HealthOSCore`, `HealthOSSessionRuntime`, `HealthOSAACI`, `HealthOSMSR`, `HealthOSProviders`, `runtime-async`, `runtime-user-agent`, `service-runtime`.
- Session Runtime owns transcript normalization and session orchestration; MSR owns `ASL -> VDLP -> GEM` after normalized transcript input.
- Service Runtime is a TypeScript service/operations workflow runtime and remains distinct from Session Runtime and Async Runtime.
- HealthOS Forge MCP (`healthos-forge-mcp`) is the canonical repository-maintenance MCP tooling name.
- Future HealthOS runtime MCP servers remain separate Core-governed systems.

## TODO audit note (2026-05-01 local / 2026-05-02 UTC)

Do not reopen stale READY entries for APP-008, CL-006, DS-007, OPS-003, RT-008, AACI-009, STR-001, RT-MSR-001, RT-MSR-002, RT-MSR-003, or RT-PROVIDER-001 without new contradictory evidence. The current TODO files have been corrected to remove those completed items from READY.
