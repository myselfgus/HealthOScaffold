# healthos-forge-mcp

`@healthos/forge-mcp` is the repository-maintenance MCP server for HealthOS Steward. It is a deterministic stdio JSON-RPC MCP server that exposes 10 read/write tools wrapping `@healthos/steward` library functions. It exists outside the HealthOS clinical/runtime hierarchy — it is not a HealthOS runtime MCP server, Core law server, AACI tool server, or GOS runtime server.

> **healthos-forge-mcp is outside the HealthOS clinical/runtime hierarchy. It is not a HealthOS runtime MCP server.**

---

## Build instructions

`dist/` is built automatically by npm's `prepare` lifecycle when you run `npm install` in the workspace:

```bash
cd ts && npm install
```

This builds all workspace packages including `@healthos/forge-mcp`. For a targeted rebuild:

```bash
make ts-build
```

Or rebuild only this package:

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

This server exposes **tools only** by design. Resources and prompts MCP capabilities are out of scope for the repository-maintenance surface.

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

Replace the path with the absolute path to `dist/server.js` in your clone. After adding this config, `cd ts && npm install` will ensure `dist/server.js` is present.

### b) Generic stdio MCP client

```
command: node /path/to/HealthOScaffold/ts/agent-infra/healthos-forge-mcp/dist/server.js
```

The server communicates over stdin/stdout using the MCP JSON-RPC protocol.

### c) Via npx (workspace)

```bash
cd ts && npm install
cd ts && npx --yes --workspace @healthos/forge-mcp healthos-forge-mcp
```

`npm install` runs `prepare` which builds `dist/` automatically — no separate build step needed.

---

## Non-canonical disclaimer

`healthos-forge-mcp` is outside the HealthOS clinical/runtime hierarchy. It is not a HealthOS runtime MCP server. Every tool response includes a `_non_canonical` field:

```
"Repository-maintenance tool response. No clinical authority, merge authority, or production-readiness claim."
```

Do not cite tool responses as clinical evidence, official HealthOS documentation, or production-readiness confirmation.

---

## Known limitations

### TypeScript TS2589 in `src/tools-id-arg.ts`

`McpServer.registerTool()` with Zod `inputSchema` causes TypeScript error TS2589 ("Type instantiation is excessively deep") in MCP SDK 1.29.0 + Zod 4.x. The depth limit fires at multiple points within the multi-line call expression, making per-line suppression insufficient. The file uses `// @ts-nocheck` as the narrowest available workaround.

Correctness guarantees:
- Business logic lives in `handlers.ts` (fully type-checked)
- All callbacks carry explicit `({ id }: { id: string })` parameter annotations
- Zod validates inputs at runtime before any handler is called

Remove `// @ts-nocheck` when MCP SDK resolves the z3/z4 compat depth issue (track against SDK releases > 1.29.0).

### Tools only — no resources or prompts

This server exposes tools only, by design. The repository-maintenance surface has no use case for MCP resources or prompts capabilities.

### `dist/` not committed to git

Compiled output is excluded from version control (standard for TypeScript packages). Running `cd ts && npm install` is sufficient to build `dist/` via the `prepare` lifecycle script.
