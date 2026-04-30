# 44) HealthOS Project Steward Agent (engineering scaffold)

> **Status (as of 2026-04-28):** Historical reference. This document describes the Project Steward scaffold before the architectural realignment defined in `docs/architecture/45-healthos-xcode-agent.md` and `docs/architecture/46-apple-sovereignty-architecture.md`. The current target treats Xcode Intelligence as the native engineering-agent runtime surface and reduces HealthOS-specific contribution to instructions, an MCP server, derived repository memory, and a deterministic CLI. This document is preserved to retain the engineering reasoning that produced the simplified target. Do not implement net-new functionality from this document; consult docs 45 and 17 for current direction.

## Purpose

HealthOS Project Steward is an **engineering tool** in this repository. It is not a clinical runtime, not AACI, not a user agent, and not a law engine.

This document describes the current engineering scaffold/runtime that exists today for the HealthOS construction repository. "Scaffold" here describes maturity of the tool, not a separate product identity.

Target evolution beyond this scaffold is defined in:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

It exists to:
- maintain a versioned operational memory index
- inspect repository status and required docs presence
- scaffold next-task planning from official execution docs
- scaffold PR review checklists using invariant policy
- generate handoff and prompt context for external tools (Codex/Claude Code/ChatGPT)
- execute local validation harness (`make validate-all`)

It supports engineering continuity for HealthOS work in this repository; it is not part of HealthOS Core law and must not treat HealthOScaffold as separate from HealthOS.

## What it is not

Project Steward does **not**:
- access real health data
- decide Core law
- perform clinical acts
- claim autonomous PR review/approval/merge
- require external secrets or GitHub token in this scaffold round

## Location and stack

- implementation: `ts/agent-infra/healthos-steward/`
- persistent memory/policies/prompts: `.healthos-steward/`
- runtime model: deterministic core + optional LLM-backed agent runtime

TypeScript was selected because the repo already has a TS workspace with existing CLI/tooling patterns (`@healthos/gos-tooling`).

## Commands (scaffold round)

```bash
healthos-steward status
healthos-steward scan
healthos-steward next-task
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

This provider layer should now be treated as a transitional scaffold, not the long-term architectural center. The target design moves repository intelligence into an agent runtime with conversation surfaces, tools, sessions, and model backends.

Safety constraints:
- no provider required for deterministic commands
- provider configs disabled by default
- credentials only via env vars
- invocation logs omit secrets and keep hashes
- GitHub writes remain explicit (`--post-comment`)
- PR review comment posting uses real provider output only; no placeholder comment is posted on provider failure.

## Provider error taxonomy (April 2026 hardening)

`StewardLLMResponse.errorKind` is a typed union covering the operator-actionable categories observed across OpenAI/Anthropic/xAI:

| category | errorKind | trigger |
|---|---|---|
| policy / configuration | `networkDenied`, `missingSecret`, `providerDisabled`, `misconfigured`, `unsupported`, `localCommandDenied` | failed pre-flight checks before any HTTP call |
| transport | `networkUnavailable`, `timeout`, `httpError` | DNS/TLS/socket failures, `AbortSignal.timeout` deadlines, status codes outside the documented HTTP categories below |
| HTTP semantic | `auth` (401/403), `rateLimited` (429), `badRequest` (400/422 and other 4xx), `notFound` (404), `serverError` (5xx) | provider returned a non-2xx response |
| payload / parsing | `parseError`, `payloadEmpty` | response body was not valid JSON, or returned 200 OK without any extractable assistant text |
| catch-all | `unknown` | thrown error did not match any known shape; preserves the original message for diagnostics |

When a provider returns a non-2xx response, the adapter prefers the human-readable message from the provider body (`error.message` for OpenAI/xAI; nested `error.message` for Anthropic) over a generic status label, so operator logs surface what the provider actually said.

## PR review comment format (April 2026 hardening)

Steward-authored PR comments now carry a fixed header and footer assembled from `formatStewardReviewComment` so a human reviewer can verify provenance without reading log files:

- HTML marker `<!-- healthos-steward review -->` for greppable detection of Steward-authored comments
- provider id and kind, model, generation timestamp, PR ref, and policy versions (`invariant-policy.yaml`, `pr-review-rubric.yaml`)
- explicit footer reasserting non-authority: the comment is a draft review and does not approve, merge, or replace human gate resolution

`formatStewardReviewComment` throws on empty body — the steward never posts placeholder text under any code path.
