# Settler Profile: settler-xcode-tooling

This profile narrows a Settler's attention to the Construction System territory of the HealthOS repository. This territory covers Steward, Settlers, Settlements, Territories, HealthOS Forge MCP doctrine, deterministic CLI infrastructure, Xcode tooling integration posture, Claude Code automations, and repository-local construction roots. This Settler maintains engineering tooling discipline without ever making construction tooling a clinical or runtime authority.

---

## territory-id

`construction-system`

References Territory record: `.healthos-settler/territories/construction-system.json`

---

## profile-id

`settler-xcode-tooling`

---

## description

Settler for Steward, healthos-forge-mcp, and Xcode tooling streams. Responsible for maintaining the construction operating model, deterministic Steward CLI surface, Claude Code automation definitions, Xcode-integration posture instructions, and HealthOS Forge MCP doctrine. Ensures that construction tooling never acquires clinical authority, merge authority, or runtime scope.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `docs/architecture/45-healthos-xcode-agent.md` — Steward for Xcode, Xcode Intelligence integration posture, tool runtime contracts
2. `docs/architecture/46-apple-sovereignty-architecture.md` — Apple sovereignty boundary and Xcode Intelligence scope
3. `docs/architecture/47-steward-settler-engineering-model.md` — canonical Steward/Settler/Settlement/Territory/Forge MCP architecture
4. `docs/execution/17-healthos-xcode-agent-migration-plan.md` — Xcode agent migration plan and workstream definitions
5. `docs/execution/19-settler-model-task-tracker.md` — ST construction sequence tracker
6. `docs/execution/22-steward-construction-operating-model.md` — construction operating model baseline
7. `docs/execution/skills/project-steward-skill.md` — project Steward engineering skill reference
8. `CLAUDE.md` — Claude Code operating instructions and healthos-forge-mcp boundary doctrine

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `.healthos-settler/` — Settler profile registry, territory registry, and future settlement records
- `.healthos-steward/` — Steward derived memory, sessions, prompts, and automation state
- `ts/agent-infra/healthos-steward/` — deterministic Steward CLI source
- `ts/agent-infra/healthos-forge-mcp/` — HealthOS Forge MCP stdio server (ST-018)
- `.claude/` — Claude Code automation definitions and settings
- `AGENTS.md` — agent instruction surface
- `CLAUDE.md` — Claude Code instruction surface (read carefully before proposing changes)
- `docs/execution/19-settler-model-task-tracker.md` — ST construction tracker
- `docs/execution/22-steward-construction-operating-model.md` — construction operating model

Forbidden paths (must not propose writes here):

- `swift/Sources/HealthOSCore/`
- `swift/Sources/HealthOSAACI/`
- `swift/Sources/HealthOSSessionRuntime/`
- `swift/Sources/HealthOSMSR/`
- `swift/Sources/HealthOSProviders/`
- `swift/Sources/HealthOSScribeApp/`
- `swift/Sources/HealthOSVeridiaApp/`
- `swift/Sources/HealthOSCloudClinicApp/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. Steward, Settlers, Settlements, Territories, and HealthOS Forge MCP are outside the HealthOS clinical/runtime hierarchy. They are never Core, GOS, AACI, or app actors.
2. `healthos-forge-mcp` is the canonical name for the repository-maintenance MCP. The deprecated name `healthos-mcp` must not be used.
3. Construction tooling has no merge authority, clinical authority, Core-law authority, or autonomous execution authority.
4. Official docs remain canonical. Construction records (derived memory, territory records, settler profiles) are subordinate navigation aids.
5. Claude Code automations and scheduled tasks must not auto-merge, auto-edit clinical code, or auto-edit automation surfaces without a PR review.
6. HealthOS Forge MCP and prompt generation capabilities must not be described as implemented before implementation is validated.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Claiming Xcode Intelligence integration is complete before independent verification exists.
2. Making `healthos-forge-mcp` a clinical automation server, AACI tool server, GOS runtime server, or Core law server.
3. Granting Steward, Settlers, or any construction component merge authority or autonomous execution authority.
4. Using the deprecated `healthos-mcp` name as canonical in any new documentation or record.
5. Allowing external executors (Codex, Claude Code, or other coding assistants) to auto-edit automation surfaces without a PR review workflow.
6. Describing prompt generation, PR review engine, Settlement CLI, or Forge MCP as implemented before source and smoke evidence confirms it.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make ts-build
make validate-docs
git diff --check
```

For JSON Territory and Settler records:
```bash
python3 -m json.tool .healthos-settler/territories/territory.schema.json >/dev/null
for f in .healthos-settler/territories/*.json; do python3 -m json.tool "$f" >/dev/null && echo "OK: $f" || echo "FAIL: $f"; done
```

For Steward CLI source changes:
```bash
make ts-build
make ts-test
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
```

Full gate:
```bash
make validate-all
```

---

## maturity

`scaffolded contract`

The construction system has a scaffolded contract: the construction operating model doc, territory registry, and (after ST-012) settler profile registry exist as documentation scaffolds. No Settler execution runtime, Forge MCP implementation, or prompt generation engine is implemented. This Settler profile is doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated ST construction tracker entry in `docs/execution/19-settler-model-task-tracker.md`.
3. Updated construction operating model entry in `docs/execution/22-steward-construction-operating-model.md` if the ST sequence changed.
4. Verification evidence that `make ts-build` and `make validate-docs` pass (or precise failure recorded if pre-existing).
5. Territory and Settler JSON record integrity confirmed (no accidental corruption).
6. No false implementation claims: only validated, smoke-tested CLI behavior may be described as implemented.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement HealthOS Forge MCP, Settler execution, Settlement lifecycle, or prompt generation. It does not make the construction system a HealthOS runtime component or clinical authority. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical.
