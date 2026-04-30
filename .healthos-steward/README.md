# HealthOS Steward data

This folder stores repository-local **derived** operational state for Steward.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

Steward data indexes HealthOS engineering work in this repository; it does not define canonical truth.

## Canonical truth
Official docs remain canonical (`README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/execution/*`). Steward memory does not replace official docs.

## Current baseline contents

- session persistence: `.healthos-steward/memory/sessions/`
- derived memory/index material: `.healthos-steward/memory/`
- provider config scaffolds: `.healthos-steward/providers/`
- policies and prompts retained from earlier Steward phases where still relevant to repository continuity

**Automation memory** (committed to `origin/main` after each automation run):
- `.healthos-steward/memory/automations/daily-todo-tracker/` — daily TODO digests (`YYYY-MM-DD.md` + `latest.md`)
- `.healthos-steward/memory/automations/sync-work-plan/memory.md` — work plan sync log (truth table + changes per run)
- `.healthos-steward/memory/automations/update-claude-md/memory.md` — CLAUDE.md update log

These files are written by Claude Code automations and pushed to remote `main` after every run. They are derived memory — not canonical docs. Read `latest.md` for the most recent project status at a glance.

Current `healthos-steward` CLI baseline is limited to `status`, `runtime`, and `session`. Do not infer additional deterministic operations from files in this directory unless those operations are implemented in `ts/agent-infra/healthos-steward/`.

## Providers
- Base config scaffold: `.healthos-steward/providers/providers.example.json`
- Local override (gitignored): `.healthos-steward/providers/providers.local.json`
- Schema: `.healthos-steward/providers/providers.schema.json`

All providers are disabled by default and use dry-run posture unless you explicitly enable and configure credentials.

## Architectural direction
Current files describe a mixed historical state: some artifacts come from earlier Steward/provider experiments, while the active package baseline is now the hard-reset CLI plus session persistence seam.

Target direction is now documented in:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

The long-term model is Steward for Xcode: Xcode Intelligence as the Apple-controlled engineering runtime surface, with HealthOS contributing instructions, `healthos-mcp`, derived repository memory, and deterministic CLI operations. Provider config, if retained, is subordinate to that tooling posture rather than being the architectural center.

## Secrets policy
Never commit API keys/tokens. Use environment variables (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `XAI_API_KEY`).

## Logs
Runtime invocation logs are written to `runtime-data/steward/model-invocations.jsonl`.
