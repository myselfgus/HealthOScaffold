# CLAUDE.md

Guidance for coding agents working in the HealthOScaffold repository.

## Repository identity and scaffold vocabulary

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. It is not a separate product from HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are HealthOS work unless explicitly marked experimental or deprecated.

Use "scaffold" only to describe maturity or bootstrap/foundation phase, never to imply that this repository sits outside HealthOS or that another HealthOS must be built elsewhere.

## Constitutional identity (never collapse)

- **HealthOS is the whole platform**.
- **AACI is one runtime inside HealthOS**.
- **GOS is subordinate to Core law** (operational mediation, never constitutional authority).
- **Scribe/Sortio/CloudClinic are app/interfaces** consuming mediated surfaces, not law engines.
- This repository contains HealthOS components at scaffold/foundation maturity, **not production-ready**, **not a full EHR**, and **not a real regulatory/provider integration**.

## Required reading order before coding

1. `README.md`
2. `docs/execution/README.md`
3. `docs/execution/00-master-plan.md`
4. `docs/execution/01-agent-operating-protocol.md`
5. `docs/execution/02-status-and-tracking.md`
6. `docs/execution/06-scaffold-coverage-matrix.md`
7. `docs/execution/10-invariant-matrix.md`
8. `docs/execution/11-current-maturity-map.md`
9. `docs/execution/12-next-agent-handoff.md`
10. `docs/execution/13-scaffold-release-candidate-criteria.md`
11. `docs/execution/14-final-gap-register.md`
12. `docs/execution/15-scaffold-finalization-plan.md`
13. `docs/execution/16-next-10-actions-plan.md`
14. `docs/execution/20-documental-todos-work-plan.md` — living plan for open documentation tasks (auto-synced)
15. `docs/execution/21-structural-ontology-and-product-readiness-plan.md` — canonical priority-ordered task selection plan; **read before selecting any implementation task**
16. `docs/product/01-healthos-technical-product-specification.md` — technical product specification baseline; read before generating construction or product work units
17. relevant `docs/execution/todo/*.md`
18. relevant `docs/architecture/*.md`
19. matching `docs/execution/skills/*.md` (HealthOS domain skills)
20. if touching Swift/SwiftUI/Xcode/Apple platform code: matching `docs/execution/skills/<name>/SKILL.md` (macOS skills — see `docs/execution/skills/README.md` for index)

Task selection order:
1. `READY` task in current phase
2. `BLOCKER` task
3. documentation/contract task that unblocks coding
4. validation for just-finished work

After each work unit, update:
- `docs/execution/02-status-and-tracking.md`
- corresponding file in `docs/execution/todo/`

## Absolute execution restrictions

Never:
- invent fictitious clinical stories/examples or demo narratives
- treat scaffolded/stubbed behavior as real provider, signature, interoperability, or semantic retrieval
- move consent/habilitation/gate/finality/provenance/storage law into AACI/GOS/apps
- expose raw direct identifiers in app-facing surfaces
- declare production readiness

Always:
- keep claims honest about maturity
- preserve fail-closed governance behavior
- record unresolved contradiction/gap explicitly instead of coding around it

## Canonical first-slice reference

Primary executable slice orchestration lives in:
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- consumed by `HealthOSCLI` and the minimal `HealthOSScribeApp`

Reference ordering:
habilitation validate → consent validate → session start → capture → transcript provenance → retrieval provenance → SOAP draft provenance → gate request → gate resolve → final artifact (only if approved) + provenance.

## MSR and transcript normalization workflow

Transcript normalization is owned by `HealthOSSessionRuntime`, not by MSR. The session pipeline is:
capture/transcription → transcript normalization → MSR (`ASL -> VDLP -> GEM`).

For v1, normalization may use the local Apple Foundation Models adapter when compiled in and available for the current locale. Remote fallback remains denied unless future policy explicitly changes this. Stub-only or unavailable providers must produce explicit degraded state and must not persist stub output as a real normalized transcript.

When touching transcript normalization, MSR, or provider behavior, read `docs/architecture/49-mental-space-runtime.md` and validate at minimum with:
```bash
cd swift && swift build
cd swift && swift test
```

## Real command baseline

```bash
make bootstrap
make swift-build
make swift-test
make ts-build
make ts-test
make python-check
make validate-docs
make validate-schemas
make validate-contracts
make validate-all
```

Additional real Makefile targets:
```bash
make python-compile
make swift-smoke
make sql-print
```

Smoke path (when validating runnable flow):
```bash
make smoke-cli
make smoke-scribe
make smoke-sortio
make smoke-cloudclinic
```

Recently confirmed direct smoke commands:
```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSCLI --reject-gate
cd swift && swift run HealthOSScribeApp --smoke-test
cd swift && swift run HealthOSScribeApp --smoke-test-audio
cd swift && swift run HealthOSSortioApp --smoke-test
cd swift && swift run HealthOSCloudClinicApp --smoke-test
```

For GOS bundle lifecycle smoke, use the minimal operator-facing CLI path and keep reviewer/operator identity explicit:
```bash
cd swift && swift run HealthOSCLI --gos-review-bundle <bundle-id> --gos-spec-id <spec-id> --reviewer-id <id> --review-rationale "<reason>"
cd swift && swift run HealthOSCLI --gos-promote-bundle <bundle-id> --gos-spec-id <spec-id> --activator-id <id> --activation-rationale "<reason>"
```

Workflow notes from recent repository use:
- Before implementation work, `git fetch origin --prune`, confirm `main` equals `origin/main`, then create a fresh task branch.
- Serialize SwiftPM validation commands; concurrent Swift builds/runs can contend on `.build` locks.
- For documentation-only work, run `make validate-docs` and `git diff --check`; if a broader gate fails, record the exact failing gate instead of weakening the validation claim.
- `make validate-docs` checks documentation/reference consistency; it does not prove that claimed CLI commands or package source paths exist. Verify executable command claims with the package source and a smoke run, or add a short TODO instead of documenting them as delivered.

## Cross-language contract discipline

When ontology/contracts change, align in the same work unit:
- JSON Schemas (`schemas/`)
- Swift contracts (`swift/Sources/HealthOSCore/` etc.)
- TypeScript contracts (`ts/packages/contracts/src/index.ts`)
- SQL shape (`sql/migrations/001_init.sql`) when relevant

## Commit discipline

- one coherent work chunk per commit
- docs + contracts + tests together when they govern same change
- do not leave tracking stale after code/doc updates


## Steward usage (engineering continuity)

Steward is the canonical engineering agent for this repository. `healthos-steward` is the CLI, package, and repository-local state root.

- CLI and package: `ts/agent-infra/healthos-steward/`
- Derived memory, sessions, handoffs, policies, state: `.healthos-steward/`
- Territory Registry: `.healthos-settler/territories/`
- Construction operating model: `docs/execution/22-steward-construction-operating-model.md`

Steward for Xcode is the Xcode-integration posture for Steward. Steward for Xcode integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface, while HealthOS contributes instructions, `healthos-forge-mcp`, derived repository memory, and deterministic CLI operations. See `docs/architecture/45-healthos-xcode-agent.md` and `docs/architecture/46-apple-sovereignty-architecture.md`.

Do not treat Steward memory as canonical truth; official docs are canonical. Steward memory is a derived index.

Current deterministic baseline (hard-reset posture):

`dist/` is not committed. Run `make ts-build` once before invoking the CLI.

```bash
make ts-build
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd ts && npx --yes --workspace @healthos/steward healthos-steward session
cd ts && npx --yes --workspace @healthos/steward healthos-steward list territories
cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlers
cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlements
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect territory <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect settler <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect settlement <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward next
cd ts && npx --yes --workspace @healthos/steward healthos-steward generate-prompt <settlement-id>
```

Nine `healthos-steward` CLI commands are implemented as of ST-016 (2026-05-04): `status`, `runtime`, `session` (scaffold placeholders); `list <territories|settlers|settlements>`, `inspect <territory|settler|settlement> <id>`, and `next` (deterministic read-only registry inspection, implemented in `ts/agent-infra/healthos-steward/src/commands/`); `generate-prompt <settlement-id>` (deterministic PromptSpec assembler — reads Settlement, Territory JSON, and Settler profile records; writes 16-section PromptSpec Markdown to `.healthos-steward/prompts/generated/`; no LLM calls, no new npm deps, fail-closed); `validate-settlement <settlement-id>` (deterministic ValidationReport — checks done-criteria against filesystem evidence using PASS/FAIL/UNVERIFIED heuristic, lists validation-commands as manual steps; exits 1 on any FAIL; no shell execution, no LLM); and `pr-draft <settlement-id>` (deterministic ReviewDraft — generates PR body Markdown from Settlement fields; always exits 0 on success). The `list`/`inspect`/`next` commands read Territory JSON records, Settler profile .md files, Settlement .md records, and the ST tracker using Node built-ins only — no model calls, no writes, no new npm dependencies. Do not describe `scan-status`, `validate-docs`, `validate-all`, or other repository-maintenance operations as delivered CLI behavior until implemented.

Codex, Claude Code, and other external coding assistants are external executors operating on this repository. They are not internal Steward providers.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. Keep this role limited to reviewing and proposing PRs for Claude Code automations, scheduled-task definitions, Xcode/Steward instructions, and automation drift. Do not create a new Steward authority category, grant merge authority, or treat Codex as an internal Steward provider.

The local Codex automation for this posture is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`. It should propose branch/PR updates for drift; it must not merge automatically or edit clinical/runtime code outside an explicitly scoped task.

## Steward and healthos-forge-mcp boundary

`healthos-forge-mcp` is the repository-maintenance MCP server for Steward. It exposes typed operations for maintaining the HealthOS construction repository: `validate-all`, `validate-docs`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, `generate-pr-review-draft`, and others.

`healthos-forge-mcp` is outside the HealthOS clinical/runtime hierarchy. It is used by Steward for Xcode, Xcode Intelligence where available, CI tools, or external coding assistants operating on this repository. It must never be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.

If HealthOS later uses MCP servers internally for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers. They must obey HealthOS Core invariants: lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-forge-mcp`. Do not collapse these two MCP families.

`healthos-forge-mcp` is doctrine-only in this work unit. It is not yet implemented.

Steward provider safety:
- Provider usage is optional and must remain fail-closed.
- Never commit provider local config with secrets.
- PR review posting is never default; requires explicit operator flag.
- PR review posting only sends real provider output; placeholder/error text is never posted.

## Claude Code Automations

Three durable Claude Code automations maintain repository state automatically. All push to `origin/main` after each run, including the memory file even on no-change runs.

| Automation | Schedule | Definition | Function |
| :--- | :--- | :--- | :--- |
| `daily-todo-tracker` | Daily 08:07 | `.claude/automations/daily-todo-tracker.md` | Digest of all TODO/READY/BLOCKED tasks by domain |
| `sync-work-plan` | Mon/Wed/Fri 08:47 | `.claude/automations/sync-work-plan.md` | Keeps `20-documental-todos-work-plan.md` live and synced |
| `update-claude-md` | Mon 09:03 | `.claude/automations/update-claude-md.md` | Reviews CLAUDE.md for stale commands or missing docs |

Latest digest: `.healthos-steward/memory/automations/daily-todo-tracker/latest.md`

Companion Codex automation: `$CODEX_HOME/automations/steward-xcode-facing-maintenance/` reviews Steward-scoped Xcode-facing automation and instruction drift and should publish changes by branch/PR.

## Prompt architecture template

Any AI coding agent (Codex, Claude Code, Xcode Intelligence, or any LLM) generating an implementation prompt for a HealthOS work unit **must** follow the master prompt architecture template at:

`.healthos-steward/prompts/prompt-architecture-template.md`

The template defines the required prompt structure, task classification rules, canonical nomenclature, boundary preservation rules, maturity language, validation command library, tracking update rules, Git workflow rules, and self-validation checklist.

Use the **short form** from the template when generating prompts in conversation. Use the **full form** when acting as a formal prompt architect agent.

Key rules enforced by the template:
- Every generated prompt must be atomic, bounded, and governance-preserving.
- No prompt may allow broad refactors, production-readiness claims, clinical authority, or `healthos-mcp` as canonical MCP name.
- Use `healthos-forge-mcp` / HealthOS Forge MCP for repository-maintenance MCP.
- Use `HealthOSSessionRuntime` as the Swift module name; "Session Runtime" as the concept.
- Never use `HealthOSFirstSliceSupport`.
