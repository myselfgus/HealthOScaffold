# Next agent handoff (2026-04-29)

## Current state

Repository is in controlled implementation/scaffold hardening. Governance contracts, Swift tests (246 passing), TS build, GOS tooling, and the Mental Space Runtime normalization stage are all in place. A full structural ontology and product-readiness analysis was performed on 2026-04-29 and produced a canonical priority-ordered work plan.

HealthOScaffold is the historical repository name and construction repository for HealthOS. Future agents must treat implemented architecture, contracts, runtimes, apps, tests, and docs here as HealthOS work unless explicitly marked experimental or deprecated; scaffold vocabulary describes maturity/foundation phase only.

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

**The priority order is:**

| Tier | What | Why |
|------|------|-----|
| **P0** | STR-001 → RT-MSR-001 → RT-MSR-002 → RT-MSR-003 | Activates the 400-patient validated clinical pipeline (ASL/VDLP/GEM) — highest clinical value, currently all stubs |
| **P1** | STR-002, STR-003, STR-004 (independent, can parallel) | Corrects product/build/agent ontology at the filesystem level; eliminates structural confusion |
| **P2** | STR-005, APP-011, APP-012 | Adds missing Sortio and CloudClinic Swift targets to the product graph |
| **P3** | RT-PROVIDER-001, RT-ASYNC-001, RT-RETRIEVAL-001 | Runtime hardening (real providers, SQL-backed executor, semantic retrieval) |
| **P4** | CI-001 | GitHub Actions CI integration |

## How to choose next task

1. Read `docs/execution/21-structural-ontology-and-product-readiness-plan.md` → Priority Grid.
2. Find highest-priority task with Status = `READY` and all prerequisites `DONE`.
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
- `HealthOSFirstSliceSupport` is a scaffold module, not a product concept. STR-004 renames it to `HealthOSSessionRuntime`.
- `Skill macOS/` TS scripts are reference implementations, not the active pipeline. STR-002 archives them.
- `ts/packages/` conflates PRODUCT, BUILD, and AGENT packages. STR-003 separates them.
- Sortio and CloudClinic have no Swift executable targets. STR-005 adds them.
- `HealthOSMentalSpace` depends only on `HealthOSCore`, blocking real Claude API calls. STR-001 fixes this.

## Native UI note

`docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` defines scaffold scope for macOS 26+ Liquid Glass app-shell work. Use `docs/execution/skills/native-macos-ui/SKILL.md` for UI work. Do not move Core law into SwiftUI.

## Mental Space Runtime note

`docs/architecture/49-mental-space-runtime.md` and `docs/execution/skills/mental-space-runtime-skill.md` are the canonical refs. P0 tasks implement ASL, VDLP, and GEM executors in order. Keep outputs derived/gated/app-safe/non-authorizing at all times.

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

The intended evolution is Steward for Xcode: Xcode Intelligence as the Apple-controlled engineering runtime surface, with HealthOS contributing instructions, `healthos-mcp`, derived repository memory, and an expanded deterministic CLI.

Settler model note: the Steward / Settler / Settlement / Territory model was added as doctrine-only in `docs/architecture/47-steward-settler-engineering-model.md`, with future implementation tracked in `docs/execution/19-settler-model-task-tracker.md`. Future work should use those docs and must not treat Settlers as clinical or runtime agents.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. The local Codex automation is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`; use it for PR-based review of Claude Code automations, scheduled-task definitions, Xcode/Steward instructions, and automation drift. Do not treat this as a new Steward authority category, merge authority, or clinical/runtime capability.

Repository-local roots now exist for the model:
- `.healthos-settler/` is a documentation-only root for future Settler profiles and Settlement records.
- `.healthos-territory/` is a documentation-only root for future Territory records.

These roots are subordinate to official docs and do not implement executable Settlers, a Settlement schema, a Territory loader, or `healthos-mcp`.
