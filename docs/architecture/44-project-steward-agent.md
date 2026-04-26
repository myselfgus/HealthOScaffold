# 44) HealthOS Project Steward Agent (engineering scaffold)

## Purpose

HealthOS Project Steward is an **engineering tool** in this repository. It is not a clinical runtime, not AACI, not a user agent, and not a law engine.

It exists to:
- maintain a versioned operational memory index
- inspect repository status and required docs presence
- scaffold next-task planning from official execution docs
- scaffold PR review checklists using invariant policy
- generate handoff and prompt context for Codex/Claude/ChatGPT
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
- runtime model: local TypeScript CLI, no external LLM API calls

TypeScript was selected because the repo already has a TS workspace with existing CLI/tooling patterns (`@healthos/gos-tooling`).

## Commands (scaffold round)

```bash
healthos-steward status
healthos-steward scan
healthos-steward next-task
healthos-steward validate [--dry-run]
healthos-steward review-pr --pr <number>
healthos-steward memory show [--file <memory-file>]
healthos-steward memory update --file <memory-file> --json '{"k":"v"}'
healthos-steward prompt codex-next
healthos-steward handoff
```

Behavior honesty constraints:
- `review-pr` prints `github integration not configured` in this round.
- no command pretends autonomous reasoning beyond deterministic local generation.
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

## Future integrations (explicit gap)

Out of scope for this round:
- real GitHub API/CLI diff and checks ingestion
- issue/PR comment write-back
- CI/MCP runtime coupling

These are future hardening items after scaffold constitution is stable.
