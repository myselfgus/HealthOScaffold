# healthos-forge-mcp

`@healthos/forge-mcp` is the repository-maintenance MCP server for HealthOS Steward. It is a deterministic stdio JSON-RPC MCP server that exposes 10 read/write tools wrapping `@healthos/steward` library functions. It exists outside the HealthOS clinical/runtime hierarchy — it is not a HealthOS runtime MCP server, Core law server, AACI tool server, or GOS runtime server.

> **healthos-forge-mcp is outside the HealthOS clinical/runtime hierarchy. It is not a HealthOS runtime MCP server.**

---

## Build instructions

`dist/` is not committed. You must build before first use:

```bash
make ts-build
```

Or build only this package:

```bash
cd ts && npm run build --workspace @healthos/forge-mcp
```

---

## Tools

| Tool | Description |
|:---|:---|
| `steward_next_task` | Returns the next TODO task in the ST construction sequence |
| `steward_scan_status` | Returns full ST task list with DONE/TODO statuses |
| `steward_get_handoff` | Returns the current engineering handoff document (first 60 lines) |
| `steward_list_territories` | Lists all Territory records (id, name, maturity) |
| `steward_inspect_territory` | Returns full Territory record for a given ID |
| `steward_list_settlers` | Lists all Settler profile records (profileId, territoryId, maturity) |
| `steward_list_settlements` | Lists all active and completed Settlement records |
| `steward_validate_settlement` | Validates a Settlement's done-criteria against filesystem evidence |
| `steward_generate_prompt` | Generates a 16-section PromptSpec from a Settlement record |
| `steward_build_memory` | Builds 6 derived memory snapshots in `.healthos-steward/memory/derived/` |

All tools are deterministic (no LLM calls, no network requests, no shell execution). Tools with an `id` argument accept a Zod-validated `string` (min length 1).

---

## MCP client configuration

### a) Claude Desktop (`claude_desktop_config.json`)

```json
{
  "mcpServers": {
    "healthos-forge": {
      "command": "node",
      "args": ["/Users/healthOS/HealthOScaffold/ts/agent-infra/healthos-forge-mcp/dist/server.js"]
    }
  }
}
```

Replace the path with the absolute path to `dist/server.js` in your clone.

### b) Generic stdio MCP client

```
command: node /path/to/HealthOScaffold/ts/agent-infra/healthos-forge-mcp/dist/server.js
```

The server communicates over stdin/stdout using the MCP JSON-RPC protocol.

### c) Via npx (workspace)

Build first, then:

```bash
make ts-build
cd ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp
```

---

## Non-canonical disclaimer

`healthos-forge-mcp` is outside the HealthOS clinical/runtime hierarchy. It is not a HealthOS runtime MCP server. Every tool response includes a `_non_canonical` field:

```
"Repository-maintenance tool response. No clinical authority, merge authority, or production-readiness claim."
```

Do not cite tool responses as clinical evidence, official HealthOS documentation, or production-readiness confirmation.

---

## Notes

- `dist/` is not committed — clients must run `make ts-build` before first use.
- No resources or prompts capability — tools only.
- mcp-local clinical tool names (`patient_context`, `service_context`, `session_drafts`) are absent — they belong to a separate cleanup task and must not be added here.
