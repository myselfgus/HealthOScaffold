# HealthOS Project Steward data

This folder stores **derived** operational memory, policies, prompts, and provider config for the engineering steward.

## Canonical truth
Official docs remain canonical (`README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/execution/*`). Steward memory does not replace official docs.

## Providers
- Base config: `.healthos-steward/providers/providers.example.json`
- Local override (gitignored): `.healthos-steward/providers/providers.local.json`
- Schema: `.healthos-steward/providers/providers.schema.json`

All providers are disabled by default and use dry-run posture unless you explicitly enable and configure credentials.

## Architectural direction
Current steward/provider files describe the scaffold that exists today.

Target direction is now documented in:
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/execution/17-healthos-xcode-agent-migration-plan.md`

The long-term model is an agent runtime with conversation surfaces, tools, sessions, and model backends. Provider config becomes subordinate to that runtime instead of being the central system abstraction.

## Secrets policy
Never commit API keys/tokens. Use environment variables (`OPENAI_API_KEY`, `ANTHROPIC_API_KEY`, `XAI_API_KEY`).

## Logs
Runtime invocation logs are written to `runtime-data/steward/model-invocations.jsonl`.
