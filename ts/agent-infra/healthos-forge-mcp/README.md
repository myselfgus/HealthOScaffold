# healthos-forge-mcp

Repository-maintenance MCP server for HealthOS Steward. Exposes deterministic, read-only tools for inspecting the HealthOS construction repository state (territories, settlers, settlements, tasks, derived memory, prompt generation).

This is not a clinical server, runtime server, or Core law server. It has no merge authority and no clinical authority.

## Build

```bash
make ts-build
```

The built entry point is `dist/server.js` (relative to this package).

## Registration

`healthos-forge-mcp` is registered as a stdio MCP server at the repository root via `.mcp.json`:

```json
{
  "mcpServers": {
    "healthos-forge-mcp": {
      "command": "node",
      "args": ["ts/agent-infra/healthos-forge-mcp/dist/server.js"]
    }
  }
}
```

Claude Code, Xcode Intelligence (where available), and any MCP-capable assistant opened at the repository root will pick this up automatically after `make ts-build`.

## Tools (10)

| Tool | Description |
|---|---|
| `steward_next_task` | Returns the next TODO task from the ST tracker |
| `steward_scan_status` | Returns task counts by status from the ST tracker |
| `steward_get_handoff` | Returns the current agent handoff document |
| `steward_list_territories` | Lists all Territory records from `.healthos-settler/territories/` |
| `steward_inspect_territory` | Returns full details for a single Territory by ID |
| `steward_list_settlers` | Lists all Settler profiles from `.healthos-settler/settlers/` |
| `steward_list_settlements` | Lists all Settlements (active + completed) |
| `steward_validate_settlement` | Validates done-criteria for a Settlement by ID |
| `steward_generate_prompt` | Generates a PromptSpec Markdown for a Settlement |
| `steward_build_memory` | Builds derived memory snapshots under `.healthos-steward/memory/derived/` |

All tools are deterministic and read-only (except `steward_generate_prompt` and `steward_build_memory`, which write derived artifacts under `.healthos-steward/`). No tool calls LLMs, executes shell commands, or touches clinical/runtime code.

## Maturity

`implemented seam` — ST-018 (2026-05-05). Registered for active use via `.mcp.json` — ST-019 (2026-05-05).
