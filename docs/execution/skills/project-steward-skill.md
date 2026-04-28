# Skill — Project Steward Agent

Use this skill when implementing or modifying the repository engineering steward (`healthos-steward`).

Treat HealthOScaffold as the HealthOS construction repository. Use scaffold terminology only for maturity, not project identity.

## Scope

- `ts/packages/healthos-steward/`
- `.healthos-steward/`
- docs that define steward behavior and constraints

## Required reads

1. `README.md`
2. `AGENTS.md`
3. `CLAUDE.md`
4. `docs/execution/02-status-and-tracking.md`
5. `docs/execution/14-final-gap-register.md`
6. `docs/execution/15-scaffold-finalization-plan.md`
7. `docs/architecture/44-project-steward-agent.md`

## Invariants to preserve

- Project Steward is an engineering tool, not clinical runtime.
- It cannot move Core law into app/runtime/GOS.
- It must keep official docs as source of truth and memory as derived index.
- It must report integration readiness honestly (available/authenticated/fail-closed).
- It cannot require secrets/tokens for baseline commands.
- It must not describe HealthOScaffold as separate from HealthOS.

## Minimum validation for steward changes

```bash
cd ts && npm run build --workspace @healthos/steward
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward next-task
cd ts && npx --yes --workspace @healthos/steward healthos-steward prompt codex-next
cd ts && npx --yes --workspace @healthos/steward healthos-steward review-pr --pr <n> --repo <owner/repo>
cd ts && npx --yes --workspace @healthos/steward healthos-steward agent plan-next --provider <id> --allow-network --dry-run
cd ts && npx --yes --workspace @healthos/steward healthos-steward agent review-diff --provider <id> --allow-network --dry-run
make validate-all
```

## Done criteria

- commands run with deterministic output
- memory/policies/prompts are versioned and parseable
- docs/tracking/todo updates are included in same work unit
- no false maturity or fake integration claims

## Provider-aware extension checks

When touching steward provider orchestration, validate:
- `providers list/check/explain`
- `next-task` deterministic path (non-provider)
- `agent plan-next --dry-run --allow-network --provider <id>`
- `review-pr --dry-run` with diff payload generation
- no secret leakage in logs/config
