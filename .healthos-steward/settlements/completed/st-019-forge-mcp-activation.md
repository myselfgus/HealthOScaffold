# Settlement Record: SETTLEMENT-20260505-forge-mcp-activation

> **Non-claims**: A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims. Settlement records are subordinate to official docs. They are engineering work unit documents.

---

## Identity

**id**: `SETTLEMENT-20260505-forge-mcp-activation`

**title**: `ST-019 Forge MCP Activation + inspect settler command`

**status**: `COMPLETE`

---

## Scope

**objective**:
Activate `healthos-forge-mcp` as a real stdio MCP server usable from Claude Code and Xcode by adding a `.mcp.json` configuration file at the repository root pointing to the built server. Also implement the missing `inspect settler <id>` standalone command in the `@healthos/steward` CLI, which currently only lists settlers via README parsing and lacks a dedicated inspect path. Both gaps were identified post-ST-018: the forge-mcp exists and builds, but no integration config registers it as an active MCP server for any assistant; and the steward CLI is missing the `inspect settler` subcommand that mirrors `inspect territory` and `inspect settlement`.

**territory**:
- `construction-system`

**settler-profile**:
- `settler-xcode-tooling`

**files-in-scope**:
- `.mcp.json` (new — repo root, registers forge-mcp as stdio MCP server)
- `ts/agent-infra/healthos-steward/src/commands/inspect.ts` (add `inspect settler <id>` branch)
- `ts/agent-infra/healthos-steward/src/index.ts` (CLI routing, ensure settler inspect is wired)
- `ts/agent-infra/healthos-forge-mcp/README.md` (new — minimal usage doc for the MCP server)
- `docs/execution/19-settler-model-task-tracker.md` (update ST-019 status to DONE)
- `docs/execution/02-status-and-tracking.md` (tracking update)

---

## Governance

**invariants**:
- `healthos-forge-mcp` must remain a repository-maintenance MCP server only — never described as a clinical, runtime, or Core law server.
- `.mcp.json` must point to the deterministic stdio entry point (`dist/server.js`) with the correct working directory; it must not require secrets, network access, or production infrastructure.
- `inspect settler <id>` must parse the same settler profile `.md` files as `list settlers`; it must not invent settler data or call any external system.
- No clinical tool names may appear in `.mcp.json` or in the forge-mcp tool registry; the mcp-local boundary violation remains a separate deferred cleanup task.
- All forge-mcp tools remain read-only and deterministic; this Settlement adds no new tools.

**restrictions**:
- Do not add or modify any Swift, SQL, or Python source files.
- Do not touch AACI, GOS, Core, session-runtime, or any clinical/runtime code.
- Do not register any clinical tool (`patient_context`, `service_context`, `session_drafts`) in `.mcp.json` or anywhere else.
- Do not claim production-readiness or regulatory compliance for any component.
- Do not add npm dependencies to any workspace package.
- Do not implement a test suite in this Settlement (deferred gap — record in residual-gaps).

**validation-commands**:
- `make ts-build`
- `cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect settler settler-xcode-tooling`
- `cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlers`
- `node ts/agent-infra/healthos-forge-mcp/dist/server.js` (must start without error, accept EOF to exit)
- `make validate-docs`

---

## Lifecycle

**done-criteria**:
- [x] `.mcp.json` exists at repo root, valid JSON, points to `ts/agent-infra/healthos-forge-mcp/dist/server.js` as a stdio MCP server named `healthos-forge-mcp`
- [x] `healthos-steward inspect settler <id>` command implemented and returns parsed settler profile data for all 9 settler IDs
- [x] `ts/agent-infra/healthos-forge-mcp/README.md` exists with at minimum: what the server is, how to build (`make ts-build`), how it's registered (`.mcp.json`), and the 10 tool names
- [x] `make ts-build` passes with zero errors
- [x] `docs/execution/19-settler-model-task-tracker.md` updated with ST-019 DONE + smoke evidence
- [x] `docs/execution/02-status-and-tracking.md` updated

**residual-gaps**:
- No test suite for `@healthos/steward` or `@healthos/forge-mcp` (deferred — no test infrastructure exists yet)
- `ts/agent-infra/mcp-local/` has clinical tool names (boundary violation) — deferred cleanup task
- Xcode Intelligence direct MCP integration not yet validated (blocked on Xcode Intelligence availability)
- No `pr-draft` automation connected to `.mcp.json` changes

**handoff**:
After this Settlement completes, Claude Code and any MCP-capable assistant in this repository will be able to call all 10 `healthos-forge-mcp` tools directly. The `inspect settler` command closes the last gap in the steward CLI inspect surface. Recommended next Settlement: ST-020 (Use Steward to generate APP-011 prompt) — which can now use the live forge-mcp tools via MCP instead of CLI only.

---

## Source docs

- `docs/execution/22-steward-construction-operating-model.md`
- `docs/architecture/45-healthos-xcode-agent.md`
- `docs/architecture/46-apple-sovereignty-architecture.md`
- `docs/architecture/47-steward-settler-engineering-model.md`
- `docs/execution/19-settler-model-task-tracker.md`
- `ts/agent-infra/healthos-forge-mcp/src/server.ts`
- `ts/agent-infra/healthos-steward/src/commands/inspect.ts`
- `.healthos-settler/settlers/README.md`
