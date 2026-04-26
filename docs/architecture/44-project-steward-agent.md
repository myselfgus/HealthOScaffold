# 44) HealthOS Project Steward Agent (engineering scaffold)

## Purpose

HealthOS Project Steward is an **engineering tool** in this repository. It is not a clinical runtime, not AACI, not a user agent, and not a law engine.

It exists to:
- maintain a versioned operational memory index
- inspect repository status and required docs presence
- scaffold next-task planning from official execution docs
- scaffold PR review checklists using invariant policy
- generate handoff and prompt context for external tools (Codex/Claude Code/ChatGPT)
- execute local validation harness (`make validate-all`)

## What it is not

Project Steward does **not**:
- access real health data
- decide Core law
- perform clinical acts
- claim autonomous PR review/approval/merge
- require external secrets or GitHub token in this scaffold round

## Location and stack

- implementation: `ts/packages/healthos-steward/`
- persistent memory/policies/prompts: `.healthos-steward/`
- runtime model: deterministic core + optional LLM-backed agent runtime

TypeScript was selected because the repo already has a TS workspace with existing CLI/tooling patterns (`@healthos/gos-tooling`).

## Commands (scaffold round)

```bash
healthos-steward status
healthos-steward scan
healthos-steward prompt codex-next
healthos-steward validate [--dry-run]
healthos-steward review-pr --pr <number> [--repo <owner/repo>]
healthos-steward agent plan-next --provider <id> --allow-network [--dry-run]
healthos-steward agent review-pr --pr <number> --provider <id> --allow-network [--dry-run] [--post-comment]
healthos-steward memory show [--file <memory-file>]
healthos-steward memory update --file <memory-file> --json '{"k":"v"}'
healthos-steward prompt codex-next
healthos-steward handoff
```

Behavior honesty constraints:
- GitHub commands require authenticated `gh` CLI .
- if `gh` is unavailable/not authenticated, commands fail with explicit setup guidance.
- agent runtime requires explicit provider + --allow-network; deterministic core works without provider.
- memory is explicitly a derived operational index; official docs remain source of truth.

## Persistent memory structure

```text
.healthos-steward/
  memory/
  policies/
  prompts/
```

Memory constraints:
- no secrets/tokens
- no clinical payloads
- no direct identifiers
- declare stale/derived state when applicable

## Official doc precedence

Project Steward must read/reference:
- `README.md`, `AGENTS.md`, `CLAUDE.md`
- execution tracking/maturity/gap/finalization docs
- `docs/execution/todo/*`
- `docs/execution/skills/*`

Official docs are canonical. Steward memory never replaces them.

## Current GitHub integration status

Implemented in this round:
- PR metadata/checks/comments read via authenticated `gh` CLI
- PR/issue comment write-through commands

Delivery status for Project Steward GitHub integration:
- complete for authenticated CLI ingestion/comment workflows in this repository scope

## Provider orchestration extension (April 2026)

Steward now includes a model-agnostic provider layer for optional OpenAI/Anthropic/xAI/disabled (with local-command only as deprecated compatibility) execution with dry-run-safe defaults.

Safety constraints:
- no provider required for deterministic commands
- provider configs disabled by default
- credentials only via env vars
- invocation logs omit secrets and keep hashes
- GitHub writes remain explicit (`--post-comment`)
