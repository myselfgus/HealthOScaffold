# Skill — Steward

Use this skill when implementing or modifying Steward and its extension surfaces (`healthos-steward`, `healthos-mcp`, `.healthos-steward/`).

Historical/descriptive name for this skill domain: Project Steward Agent.

Treat HealthOScaffold as the HealthOS construction repository. Use scaffold terminology only for maturity, not project identity.

## Canonical naming

- `Steward`: canonical name of the engineering agent.
- `healthos-steward`: CLI, package, and repository-local state root.
- `Steward for Xcode`: Xcode-integration posture for Steward.
- `healthos-mcp`: repository-maintenance MCP server for Steward.
- `.healthos-steward/`: derived memory, sessions, handoffs, policies, and state.
- Codex: external executor that may support Steward-scoped Xcode-facing repository maintenance by proposing PRs for automation and instruction drift.

Use `HealthOS Xcode Agent` and `Xcode Agent` only as historical/descriptive references.

## Scope

- `ts/packages/healthos-steward/`
- `.healthos-steward/`
- `CLAUDE.md` and `AGENTS.md` (Steward sections)
- `docs/architecture/44-project-steward-agent.md` (historical reference only)
- `docs/architecture/45-healthos-xcode-agent.md` (Steward for Xcode target architecture)
- `docs/architecture/46-apple-sovereignty-architecture.md` (Apple sovereignty thesis)
- `docs/execution/17-healthos-xcode-agent-migration-plan.md` (migration plan)
- `.claude/automations/` and `.claude/scheduled_tasks.json` when the work touches Claude Code automation drift

## Required reads

1. `README.md` (Steward section)
2. `AGENTS.md` (Steward sections)
3. `CLAUDE.md` (Steward sections)
4. `docs/execution/02-status-and-tracking.md`
5. `docs/execution/14-final-gap-register.md`
6. `docs/architecture/45-healthos-xcode-agent.md`
7. `docs/architecture/46-apple-sovereignty-architecture.md`
8. `docs/execution/17-healthos-xcode-agent-migration-plan.md`

## Invariants to preserve

- Steward is an engineering tool. It is not a clinical runtime, not AACI, not GOS, not Core law.
- Steward must never move Core law into the engineering-agent layer.
- Official docs are source of truth; Steward memory is a derived index, never canonical.
- Steward must report integration readiness honestly (available / authenticated / fail-closed).
- Steward must not require secrets or tokens for baseline deterministic commands.
- Steward must not describe HealthOScaffold as separate from HealthOS.
- `healthos-mcp` is the repository-maintenance MCP server only. It must not be described as a clinical automation server, AACI tool server, GOS runtime server, or Core law server.
- Future Core-governed runtime MCP servers for clinical/operational automation are a separate family. Do not collapse them into `healthos-mcp`.
- External executors such as Codex may propose PRs for Steward-scoped Xcode-facing maintenance surfaces, but they are not internal Steward providers and have no merge, clinical/runtime, or Core-law authority.

## healthos-mcp boundary

`healthos-mcp` exposes typed repository-maintenance operations: `validate-all`, `validate-docs`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, `generate-pr-review-draft`, and others.

It is used by Steward for Xcode, Xcode Intelligence where available, CI tools, or external coding assistants. It is outside the HealthOS clinical/runtime hierarchy.

If HealthOS later uses MCP servers for clinical, operational, or runtime automation, those are separate Core-governed runtime MCP servers governed by HealthOS Core invariants (lawfulContext, consent, habilitation, finality, storage layer policy, provenance, audit, gate). They are not `healthos-mcp`.

`healthos-mcp` maturity: doctrine-only (WS-2 implementation pending).

## Minimum validation for Steward changes

Current hard-reset baseline:
```bash
cd ts && npm run build --workspace @healthos/steward
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd ts && npx --yes --workspace @healthos/steward healthos-steward session
make validate-docs
make validate-all
```

For WS-2 healthos-mcp changes (when implemented):
```bash
cd ts && npm run build --workspace healthos-mcp
# verify typed operations return correct output and typed errors
# verify no secrets in logs, no clinical payloads in operations
make validate-docs
```

## Done criteria

- commands run with deterministic output and fail-closed behavior
- memory/policies/state are versioned and parseable
- `docs/`, tracking, and TODO updates are included in same work unit
- no false maturity or fake integration claims
- no collapse of healthos-mcp into clinical/runtime domain
- Steward posture: non-clinical, non-constitutional, non-authorizing
