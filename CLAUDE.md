# CLAUDE.md

Guidance for coding agents working in the HealthOScaffold repository.

## Repository identity and scaffold vocabulary

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. It is not a separate product from HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are HealthOS work unless explicitly marked experimental or deprecated.

Use "scaffold" only to describe maturity or bootstrap/foundation phase, never to imply that this repository sits outside HealthOS or that another HealthOS must be built elsewhere.

## Constitutional identity (never collapse)

- **HealthOS is the whole platform**.
- **Core is constitutional law**: consent, habilitation, finalidade, storage law, provenance, gate, finality, and audit.
- **AACI is one runtime inside HealthOS**.
- **GOS is subordinate to Core law** (operational mediation, never constitutional authority).
- **Runtimes execute and mediate work under Core/GOS**: Session Runtime, AACI, MSR, Async Runtime, User-Agent Runtime, and Service Runtime.
- **Boundary is the HealthOS-owned consumption frontier**: facades, envelopes, safe refs, mediated state, degraded state, commands/results, and consumable surfaces.
- **Stages are governed application consumers inside HealthOS**. Scribe, Veridia, CloudClinic, and future first-party or third-party applications are Stages; they never define constitutional law or the HealthOS ontology.
- **Custom is the Core-law-governed definition of a Stage**: capabilities, limits, consumed surfaces, actors, degradation behavior, validation, and prohibitions. Custom is not a separate HealthOS hierarchy tier.
- **Construction System is outside the clinical/runtime hierarchy**. Steward, Settlers, Territories, Settlements, and HealthOS Forge MCP construct, register, validate, and propose work; they are not Core, GOS, Runtime, Boundary, Stage, clinical authority, or merge authority.
- This repository contains HealthOS components at scaffold/foundation maturity, **not production-ready**, **not a full EHR**, and **not a real regulatory/provider integration**.

## Required reading order before coding

1. `README.md`
2. `HealthOS/Shared/docs/execution/README.md`
3. `HealthOS/Shared/docs/execution/00-master-plan.md`
4. `HealthOS/Shared/docs/execution/01-agent-operating-protocol.md`
5. `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
6. `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`
7. `HealthOS/Shared/docs/execution/10-invariant-matrix.md`
8. `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
9. `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
10. `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`
11. `HealthOS/Shared/docs/execution/14-final-gap-register.md`
12. `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md`
13. `HealthOS/Shared/docs/execution/16-next-10-actions-plan.md`
14. `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md` — living plan for open documentation tasks (auto-synced)
15. `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` — canonical priority-ordered task selection plan; **read before selecting any implementation task**
16. `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` — technical product specification baseline; read before generating construction or product work units
17. relevant `HealthOS/Shared/docs/execution/todo/*.md`
18. relevant `HealthOS/Shared/docs/architecture/*.md`
19. matching `HealthOS/Shared/docs/execution/skills/*.md` (HealthOS domain skills)
20. if touching Swift/SwiftUI/Xcode/Apple platform code: matching `HealthOS/Shared/docs/execution/skills/<name>/SKILL.md` (macOS skills — see `HealthOS/Shared/docs/execution/skills/README.md` for index)

Before accepting any task, classify it by the HealthOS hierarchy or the external construction class and record the classification in the work unit:
- **Tier 1 — Core:** Core law, validation harness, storage law, CI, and platform surfaces that Stages may later consume.
- **Tier 2 — GOS / Runtimes:** GOS, Session Runtime, AACI, MSR, providers, Async Runtime, User-Agent Runtime, and Service Runtime.
- **Tier 3 — Boundary:** facades, envelopes, app-safe views, safe refs, command/result envelopes, mediated state, degraded state, and consumable surfaces.
- **Tier 4 — Stage:** Scribe, Veridia, CloudClinic, or any future governed application consumer.
- **External — Construction System:** Steward, Settler, Territory, Settlement, HealthOS Forge MCP, prompt/validation/derived-memory tooling. This is not a HealthOS clinical/runtime tier.

Stage work advances only after the mediated surface it consumes is implemented and stable, not merely contracted, and after the relevant Custom is complete. If a Stage task depends on an absent or unstable Tier 1-3 surface, mark it `BLOCKED` with the objective unblock criterion instead of building provisional Stage scaffold. If Custom evidence is incomplete, mark it `needs-review`.

Task selection order:
1. `READY` task in current phase
2. `BLOCKER` task
3. documentation/contract task that unblocks coding
4. validation for just-finished work

After each work unit, update:
- `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
- corresponding file in `HealthOS/Shared/docs/execution/todo/`

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
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- consumed by `HealthOSCLI` and the separate `Scribe` Stage package

Reference ordering:
habilitation validate → consent validate → session start → capture → transcript provenance → retrieval provenance → SOAP draft provenance → gate request → gate resolve → final artifact (only if approved) + provenance.

## MSR and transcript normalization workflow

Transcript normalization is owned by `HealthOSSessionRuntime`, not by MSR. The session pipeline is:
capture/transcription → transcript normalization → MSR (`ASL -> VDLP -> GEM`).

For v1, normalization may use the local Apple Foundation Models adapter when compiled in and available for the current locale. Remote fallback remains denied unless future policy explicitly changes this. Stub-only or unavailable providers must produce explicit degraded state and must not persist stub output as a real normalized transcript.

When touching transcript normalization, MSR, or provider behavior, read `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md` and validate at minimum with:
```bash
cd HealthOS && swift build
cd HealthOS && swift test
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
make smoke-veridia
make smoke-cloudclinic
```

Recently confirmed direct smoke commands:
```bash
cd HealthOS && swift run HealthOSCLI
cd HealthOS && swift run HealthOSCLI --reject-gate
cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test
cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test-audio
cd HealthOS/Tier4-Stages-Cast/Veridia && swift run Veridia --smoke-test
cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift run CloudClinic --smoke-test
```

For GOS bundle lifecycle smoke, use the minimal operator-facing CLI path and keep reviewer/operator identity explicit:
```bash
cd HealthOS && swift run HealthOSCLI --gos-review-bundle <bundle-id> --gos-spec-id <spec-id> --reviewer-id <id> --review-rationale "<reason>"
cd HealthOS && swift run HealthOSCLI --gos-promote-bundle <bundle-id> --gos-spec-id <spec-id> --activator-id <id> --activation-rationale "<reason>"
```

Workflow notes from recent repository use:
- Before implementation work, `git fetch origin --prune`, confirm `main` equals `origin/main`, then create a fresh task branch.
- Serialize SwiftPM validation commands; concurrent Swift builds/runs can contend on `.build` locks.
- For documentation-only work, run `make validate-docs` and `git diff --check`; if a broader gate fails, record the exact failing gate instead of weakening the validation claim.
- `make validate-docs` checks documentation/reference consistency; it does not prove that claimed CLI commands or package source paths exist. Verify executable command claims with the package source and a smoke run, or add a short TODO instead of documenting them as delivered.
- Open `HealthOS/Package.swift` in Xcode for committed shared schemes under `HealthOS/.swiftpm/xcode/xcshareddata/xcschemes/`; the schemes carry smoke-test launch arguments disabled by default and Release profile actions for Instruments.
- Keep `HealthOS/Constructor/` and `HealthOS/Support/` explicitly visible in Xcode workspace navigation. They are outside the clinical/runtime hierarchy, but they contain required AI organization, Steward/Settler/Forge MCP, provider support, ops, Python, and ML tooling.
- Shared schemes must cover Core, runtimes, Boundary, providers, Construction System, Support, Stage package smokes, All, and profile-oriented Core/runtime/provider/validation-gate flows. Test plans live under `HealthOS/Xcode/TestPlans/` by layer.
- Create ML, Core ML, and MLX work under `HealthOS/Support/ML/` is scaffold/governed tooling only. Do not run `swift HealthOS/Support/ML/transcript-normalizer/TrainTranscriptNormalizer.swift` against real patient data or document any produced `.mlmodel` as loadable until `ModelGovernance` approval and provenance are implemented.

## Cross-language contract discipline

When ontology/contracts change, align in the same work unit:
- JSON Schemas (`HealthOS/Tier1-Mestral-Core/Schemas/`)
- Swift contracts (`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` etc.)
- TypeScript contracts (`HealthOS/Constructor/ts/packages/contracts/src/index.ts`)
- SQL shape (`HealthOS/Tier1-Mestral-Core/SQL/migrations/001_init.sql`) when relevant

## Commit discipline

- one coherent work chunk per commit
- docs + contracts + tests together when they govern same change
- do not leave tracking stale after code/doc updates


## Steward usage (engineering continuity)

Steward is the canonical engineering agent for this repository. `healthos-steward` is the CLI, package, and repository-local state root.

- CLI and package: `HealthOS/Constructor/ts/agent-infra/healthos-steward/`
- Derived memory, sessions, handoffs, policies, state: `HealthOS/Constructor/Steward/`
- Territory Registry: `HealthOS/Constructor/Settler/territories/`
- Construction operating model: `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`

Steward for Xcode is the Xcode-integration posture for Steward. Steward for Xcode integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface, while HealthOS contributes instructions, `healthos-forge-mcp`, derived repository memory, and deterministic CLI operations. See `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` and `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md`.

Do not treat Steward memory as canonical truth; official docs are canonical. Steward memory is a derived index.

Current deterministic baseline:

TypeScript package outputs are not committed. Before invoking Steward, Forge MCP, or Managed Agent package bins from a fresh checkout, run `make ts-build`. For targeted package rebuilds:

```bash
cd HealthOS/Constructor/ts && npm run build --workspace @healthos/forge-mcp
cd HealthOS/Constructor/ts && npm run build --workspace @healthos/managed-agent
cd HealthOS/Constructor/ts && npm run build --workspace @healthos/steward
```

```bash
make ts-build
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward status
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward session
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list territories
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list settlers
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list settlements
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect territory <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect settler <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect settlement <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward next
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward generate-prompt <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward validate-settlement <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward pr-draft <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward build-memory
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward validate-construction-system
```

Eleven `healthos-steward` CLI commands are implemented as of ST-017/FORGE-MCP-V2 plus the construction-system validation hardening: `status`, `runtime`, `session` (scaffold placeholders); `list <territories|settlers|settlements>`, `inspect <territory|settler|settlement> <id>`, and `next` (deterministic read-only registry inspection, implemented in `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/commands/`); `generate-prompt <settlement-id>` (deterministic PromptSpec assembler — reads Settlement, Territory JSON, and Settler profile records; writes 16-section PromptSpec Markdown to `HealthOS/Constructor/Steward/prompts/generated/`; no LLM calls, no new npm deps, fail-closed); `validate-settlement <settlement-id>` (deterministic ValidationReport — checks done-criteria against filesystem evidence using PASS/FAIL/UNVERIFIED heuristic, lists validation-commands as manual steps; exits 1 on any FAIL; no shell execution, no LLM); `pr-draft <settlement-id>` (deterministic ReviewDraft — generates PR body Markdown from Settlement fields; always exits 0 on success); `build-memory` (deterministic DerivedMemory builder — reads ST tracker, Territory JSON records, Settler README, Settlement .md files, and handoff doc; writes 6 non-canonical snapshot files to `HealthOS/Constructor/Steward/memory/derived/`; overwritten on each run; no LLM, no shell, no new npm deps, fail-tolerant per-file); and `validate-construction-system` (deterministic construction-system truth check). The `list`/`inspect`/`next` commands read Territory JSON records, Settler profile .md files, Settlement .md records, and the ST tracker using Node built-ins only — no model calls, no writes, no new npm dependencies. Do not describe `scan-status`, `validate-docs`, `validate-all`, `check-invariants`, `check-doc-drift`, or other target repository-maintenance operations as delivered CLI behavior until implemented and locally smoked.

Codex, Claude Code, and other external coding assistants are external executors operating on this repository. They are not internal Steward providers.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. Keep this role limited to reviewing and proposing PRs for repository-maintenance automation guidance, Xcode/Steward instructions, and automation drift. Do not create a new Steward authority category, grant merge authority, or treat Codex as an internal Steward provider.

The local Codex automation for this posture is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`. It should propose branch/PR updates for drift; it must not merge automatically or edit clinical/runtime code outside an explicitly scoped task.

## Steward and healthos-forge-mcp boundary

`healthos-forge-mcp` is the repository-maintenance MCP server for Steward. It is implemented at `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` (maturity: implemented seam, ST-018/FORGE-MCP-V2, 2026-05-05). It exposes 10 deterministic repository-maintenance tools over stdio and, as of ST-021, over Streamable HTTP for Managed Agents compatibility: `steward_next_task`, `steward_scan_status`, `steward_get_handoff`, `steward_list_territories`, `steward_inspect_territory`, `steward_list_settlers`, `steward_list_settlements`, `steward_validate_settlement`, `steward_generate_prompt`, `steward_build_memory`.

```bash
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp-http
cd HealthOS/Constructor/ts && FORGE_MCP_PORT=3791 npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp-http
```

The HTTP server binds `127.0.0.1:${FORGE_MCP_PORT:-3791}/mcp`. Managed Agents API use requires a publicly reachable tunnel URL set through `FORGE_MCP_URL`; do not document localhost as sufficient for a remote Managed Agent connection.

`healthos-forge-mcp` is outside the HealthOS clinical/runtime hierarchy. It is used by Steward for Xcode, Xcode Intelligence where available, CI tools, or external coding assistants operating on this repository. It must never be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.

If HealthOS later uses MCP servers internally for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers. They must obey HealthOS Core invariants: lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-forge-mcp`. Do not collapse these two MCP families. It remains separate from future HealthOS runtime MCP servers.

Steward provider safety:
- Provider usage is optional and must remain fail-closed.
- Never commit provider local config with secrets.
- PR review posting is never default; requires explicit operator flag.
- PR review posting only sends real provider output; placeholder/error text is never posted.

For the Steward Coordinator Managed Agent seam (`@healthos/managed-agent`, ST-022/ST-023):

```bash
cd HealthOS/Constructor/ts && npm run create-agent:dry-run --workspace @healthos/managed-agent
cd HealthOS/Constructor/ts && npm run create-agent --workspace @healthos/managed-agent
cd HealthOS/Constructor/ts && npm run create-agent:force --workspace @healthos/managed-agent
```

Live create/update requires `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` and writes `HealthOS/Constructor/Steward/managed-agent/agent.json`. The typed session workflows are `discover`, `brief`, `validate`, and `handoff`; they are human-triggered construction lifecycle helpers, not a CLI, cron runner, autonomous executor, clinical/runtime surface, or merge authority.

## JAE Apple substrate rules

HealthOS is a Juridical Application Engine. Apple frameworks are substrate capabilities mediated by HealthOS, not direct Stage authority. See `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md` before adding Apple-native storage, sync, inference, worker, archive, network, or CI substrate behavior.

- Stages request capabilities through Custom/Boundary.
- Stages must not directly import Tier 2 runtime modules.
- SwiftData and CloudKit are projection/sync only, never canonical custody.
- FoundationModels/Core ML/NaturalLanguage must go through `HealthOSProviders` / `ProviderRouter`.
- XPC/ServiceManagement are isolated runtime infrastructure, not app-owned authority.
- Network is governed mesh transport, not arbitrary propagation.
- AppleArchive/CryptoKit create integrity/evidence, not legal finality.

## Repository Maintenance Automations

No Claude Code scheduled tasks are configured for this repository. The retired `.claude/automations/` directory and `.claude/scheduled_tasks.json` registry are intentionally absent to avoid duplicate cron ownership.

Grouped Codex automations own the active maintenance posture:

| Automation group | Cadence | Mode | Function |
| :--- | :--- | :--- | :--- |
| `HealthOScaffold Agent Guidance Maintenance` | Weekly, Tuesday 10:00 | worktree, PR-only | Reviews AGENTS/CLAUDE/README, Steward/Xcode docs, and automation guidance drift |
| `HealthOScaffold Status Digest` | Monday/Wednesday/Friday 08:30 | worktree, read-only | Reports READY/BLOCKED/DONE evidence, tracker inconsistencies, gaps, and next actions |
| `HealthOScaffold Dependency and SDK Drift` | Weekly, Thursday 11:00 | worktree, read-only | Reports manifest, lockfile, SDK, and toolchain drift |
| `HealthOScaffold Retrospective Skill Map` | Every two weeks, Friday 10:00 | worktree, read-only | Suggests concrete skills to deepen from PR/review/commit evidence |

Document-changing automation must use branch/PR handoff, never direct push to `main`. Historical derived logs under `HealthOS/Constructor/Steward/memory/automations/` are not scheduler definitions.

## Prompt architecture template

Any AI coding agent (Codex, Claude Code, Xcode Intelligence, or any LLM) generating an implementation prompt for a HealthOS work unit **must** follow the master prompt architecture template at:

`HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md`

The template defines the required prompt structure, task classification rules, canonical nomenclature, boundary preservation rules, maturity language, validation command library, tracking update rules, Git workflow rules, and self-validation checklist.

Use the **short form** from the template when generating prompts in conversation. Use the **full form** when acting as a formal prompt architect agent.

Key rules enforced by the template:
- Every generated prompt must be atomic, bounded, and governance-preserving.
- No prompt may allow broad refactors, production-readiness claims, clinical authority, or `healthos-mcp` as canonical MCP name.
- Use `healthos-forge-mcp` / HealthOS Forge MCP for repository-maintenance MCP.
- Use `HealthOSSessionRuntime` as the Swift module name; "Session Runtime" as the concept.
- Never use `HealthOSFirstSliceSupport`.
