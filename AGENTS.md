# AGENTS.md

Guidance for coding agents working in the HealthOScaffold repository.

## Repository identity and scaffold vocabulary

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. It is not a separate product from HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are HealthOS work unless explicitly marked experimental or deprecated.

Use "scaffold" only to describe maturity or bootstrap/foundation phase, never to imply that this repository sits outside HealthOS or that another HealthOS must be built elsewhere.

## Constitutional identity (never collapse)

- **HealthOS is the whole platform**.
- **AACI is one runtime inside HealthOS**.
- **GOS is subordinate to Core law** (operational mediation, never constitutional authority).
- **Scribe/Veridia/CloudClinic are initial reference app/interfaces** consuming mediated surfaces, not law engines or the definition of HealthOS.
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
14. relevant `docs/execution/todo/*.md`
15. relevant `docs/architecture/*.md`
16. matching `docs/execution/skills/*.md` (HealthOS domain skills)
17. if touching Swift/SwiftUI/Xcode/Apple platform code: matching `docs/execution/skills/<name>/SKILL.md` (macOS skills — see `docs/execution/skills/README.md` for index)

Before accepting any task, classify it by layer and record the classification in the work unit:
- **Tier 1 — Platform/Core:** Core law, validation harness, storage law, CI, platform surfaces that apps may later consume.
- **Tier 2 — Runtime/Mediation:** Session Runtime, AACI, GOS, MSR, providers, Async Runtime, User-Agent Runtime, Service Runtime.
- **Tier 3 — App Integration Boundary:** facades, envelopes, app-safe views, safe refs, command/result envelopes, mediated state.
- **Tier 4 — App Charter:** app role, users, mediated surfaces, boundaries, degraded states, validation expectations.
- **Tier 5 — App Implementation:** Scribe, Veridia, CloudClinic, or future app wiring/UI.
- **Tier 6 — Construction System:** Steward, Settler, Territory, Settlement, HealthOS Forge MCP, prompt/validation/derived-memory tooling.

App wiring advances only after the mediated surface it consumes is implemented and stable, not merely contracted, and after the relevant App Charter is complete. If a Tier 5 task depends on an absent or unstable Tier 1-3 surface, mark it `BLOCKED` with the objective unblock criterion instead of building provisional app scaffold. If evidence is ambiguous, mark `needs-review`.

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

Smoke path (when validating runnable flow):
```bash
make smoke-cli
make smoke-scribe
make smoke-veridia
make smoke-cloudclinic
```

Recently confirmed direct smoke commands:
```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSCLI --reject-gate
cd swift && swift run HealthOSScribeApp --smoke-test
cd swift && swift run HealthOSScribeApp --smoke-test-audio
cd swift && swift run HealthOSVeridiaApp --smoke-test
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

Territory records are construction metadata only. Use them to narrow repository domain, files, invariants, forbidden moves, and validation expectations for Steward/Settler/Settlement work; do not treat them as official docs, HealthOS runtime behavior, clinical authority, prompt generation, Settler execution, Settlement instances, or `healthos-forge-mcp` implementation.

Current deterministic baseline:
```bash
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
cd ts && npx --yes --workspace @healthos/steward healthos-steward validate-settlement <settlement-id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward pr-draft <settlement-id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward build-memory
```

Treat those as the implemented `healthos-steward` CLI commands as of ST-017/FORGE-MCP-V2. Do not describe `scan-status`, `validate-docs`, `validate-all`, `check-invariants`, `check-doc-drift`, or other target repository-maintenance operations as delivered CLI behavior until implemented and locally smoked.

For repository-maintenance MCP access, `@healthos/forge-mcp` exposes the same 10 deterministic `steward_*` tools over stdio and, as of ST-021, over Streamable HTTP for Managed Agents compatibility:
```bash
cd ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp
cd ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp-http
cd ts && FORGE_MCP_PORT=3791 npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp-http
```

The HTTP server binds `127.0.0.1:${FORGE_MCP_PORT:-3791}/mcp`. Managed Agents API use requires a publicly reachable tunnel URL set through `FORGE_MCP_URL`; do not document localhost as sufficient for a remote Managed Agent connection.

For the Steward Coordinator Managed Agent seam (`@healthos/managed-agent`, ST-022/ST-023):
```bash
cd ts && npm run create-agent:dry-run --workspace @healthos/managed-agent
cd ts && npm run create-agent --workspace @healthos/managed-agent
cd ts && npm run create-agent:force --workspace @healthos/managed-agent
```

Live create/update requires `ANTHROPIC_API_KEY` or `ANTHROPIC_AUTH_TOKEN` and writes `.healthos-steward/managed-agent/agent.json`. The typed session workflows are `discover`, `brief`, `validate`, and `handoff`; they are human-triggered construction lifecycle helpers, not a CLI, cron runner, autonomous executor, clinical/runtime surface, or merge authority.

Codex, Claude Code, and other external coding assistants are external executors operating on this repository. They are not internal Steward providers.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. Keep this role limited to reviewing and proposing PRs for Claude Code automations, scheduled-task definitions, Xcode/Steward instructions, and automation drift. Do not create a new Steward authority category, grant merge authority, or treat Codex as an internal Steward provider.

The local Codex automation for this posture is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`. It should propose branch/PR updates for drift; it must not merge automatically or edit clinical/runtime code outside an explicitly scoped task.

## Steward and healthos-forge-mcp boundary

`healthos-forge-mcp` is the repository-maintenance MCP server for Steward. It is implemented as a stdio MCP server at `ts/agent-infra/healthos-forge-mcp/` (maturity: implemented seam, ST-018/FORGE-MCP-V2, 2026-05-05). It exposes 10 deterministic repository-maintenance tools: `steward_next_task`, `steward_scan_status`, `steward_get_handoff`, `steward_list_territories`, `steward_inspect_territory`, `steward_list_settlers`, `steward_list_settlements`, `steward_validate_settlement`, `steward_generate_prompt`, `steward_build_memory`.

`healthos-forge-mcp` is outside the HealthOS clinical/runtime hierarchy. It is used by Steward for Xcode, Xcode Intelligence where available, CI tools, or external coding assistants operating on this repository. It must never be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.

If HealthOS later uses MCP servers internally for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers. They must obey HealthOS Core invariants: lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-forge-mcp`. Do not collapse these two MCP families.

Steward provider safety:
- Provider usage is optional and must remain fail-closed.
- Never commit provider local config with secrets.
- PR review posting is never default; requires explicit operator flag.
- PR review posting only sends real provider output; placeholder/error text is never posted.
