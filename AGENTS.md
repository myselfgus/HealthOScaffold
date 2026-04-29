# AGENTS.md

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
14. relevant `docs/execution/todo/*.md`
15. relevant `docs/architecture/*.md`
16. matching `docs/execution/skills/*.md` (HealthOS domain skills)
17. if touching Swift/SwiftUI/Xcode/Apple platform code: matching `docs/execution/skills/<name>/SKILL.md` (macOS skills — see `docs/execution/skills/README.md` for index)

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
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- consumed by `HealthOSCLI` and the minimal `HealthOSScribeApp`

Reference ordering:
habilitation validate → consent validate → session start → capture → transcript provenance → retrieval provenance → SOAP draft provenance → gate request → gate resolve → final artifact (only if approved) + provenance.

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
```

Recently confirmed direct smoke commands:
```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSCLI --reject-gate
cd swift && swift run HealthOSScribeApp --smoke-test
cd swift && swift run HealthOSScribeApp --smoke-test-audio
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

- CLI and package: `ts/packages/healthos-steward/`
- Derived memory, sessions, handoffs, policies, state: `.healthos-steward/`

Steward for Xcode is the Xcode-integration posture for Steward. Steward for Xcode integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface, while HealthOS contributes instructions, `healthos-mcp`, derived repository memory, and deterministic CLI operations. See `docs/architecture/45-healthos-xcode-agent.md` and `docs/architecture/46-apple-sovereignty-architecture.md`.

Do not treat Steward memory as canonical truth; official docs are canonical. Steward memory is a derived index.

Current deterministic baseline (hard-reset posture):
```bash
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd ts && npx --yes --workspace @healthos/steward healthos-steward session
```

Codex, Claude Code, and other external coding assistants are external executors operating on this repository. They are not internal Steward providers.

Codex may support Steward-scoped Xcode-facing repository maintenance as an external executor. Keep this role limited to reviewing and proposing PRs for Claude Code automations, scheduled-task definitions, Xcode/Steward instructions, and automation drift. Do not create a new Steward authority category, grant merge authority, or treat Codex as an internal Steward provider.

The local Codex automation for this posture is `$CODEX_HOME/automations/steward-xcode-facing-maintenance/`. It should propose branch/PR updates for drift; it must not merge automatically or edit clinical/runtime code outside an explicitly scoped task.

## Steward and healthos-mcp boundary

`healthos-mcp` is the repository-maintenance MCP server for Steward. It exposes typed operations for maintaining the HealthOS construction repository: `validate-all`, `validate-docs`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, `generate-pr-review-draft`, and others.

`healthos-mcp` is outside the HealthOS clinical/runtime hierarchy. It is used by Steward for Xcode, Xcode Intelligence where available, CI tools, or external coding assistants operating on this repository. It must never be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.

If HealthOS later uses MCP servers internally for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers. They must obey HealthOS Core invariants: lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, and gate. They are not `healthos-mcp`. Do not collapse these two MCP families.

`healthos-mcp` is doctrine-only in this work unit. It is not yet implemented.

Steward provider safety:
- Provider usage is optional and must remain fail-closed.
- Never commit provider local config with secrets.
- PR review posting is never default; requires explicit operator flag.
- PR review posting only sends real provider output; placeholder/error text is never posted.
