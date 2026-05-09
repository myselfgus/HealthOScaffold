import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import {
  handleNextTask,
  handleScanStatus,
  handleGetHandoff,
  handleListTerritories,
  handleListSettlers,
  handleListSettlements,
  handleBuildMemory,
} from "./handlers.js";
import { ID_ARG_TOOL_NAMES, registerIdArgTools } from "./tools-id-arg.js";

export const NO_ARG_TOOL_NAMES = [
  "steward_next_task",
  "steward_scan_status",
  "steward_get_handoff",
  "steward_list_territories",
  "steward_list_settlers",
  "steward_list_settlements",
  "steward_build_memory",
] as const;

export const FORGE_MCP_TOOL_NAMES = [
  ...NO_ARG_TOOL_NAMES,
  ...ID_ARG_TOOL_NAMES,
] as const;

// Minimal inline result builder — avoids importing CallToolResult (which involves
// deep Zod inference from the SDK types) and keeps this module's type context lean.
function ok(content: string, isError?: boolean) {
  const r: { content: Array<{ type: "text"; text: string }>; isError?: boolean } = {
    content: [{ type: "text", text: content }],
  };
  if (isError) r.isError = true;
  return r;
}

function registerNoArgTools(server: McpServer): void {
  server.registerTool(
    "steward_next_task",
    {
      description:
        "Returns the next TODO task in the ST construction sequence. Reads HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md and returns the first task with status TODO. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleNextTask();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_scan_status",
    {
      description:
        "Returns the full ST construction task sequence with statuses (DONE/TODO). Reads the settler model task tracker and returns all tasks with a DONE/TODO summary. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleScanStatus();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_get_handoff",
    {
      description:
        "Returns the current engineering handoff document (HealthOS/Shared/docs/execution/12-next-agent-handoff.md), first 60 lines. Use this to understand the current work-in-progress context before selecting a task. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleGetHandoff();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_list_territories",
    {
      description:
        "Lists all Territory records in the registry (HealthOS/Constructor/Settler/territories/). Returns id, name, and maturity for each territory. Use steward_inspect_territory for full detail. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleListTerritories();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_list_settlers",
    {
      description:
        "Lists all Settler profile records (HealthOS/Constructor/Settler/settlers/). Returns profileId, territoryId, and maturity for each profile. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleListSettlers();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_list_settlements",
    {
      description:
        "Lists all active and completed Settlement records (HealthOS/Constructor/Steward/settlements/). Returns id, title, and status for each. Use steward_validate_settlement to check a specific settlement. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleListSettlements();
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_build_memory",
    {
      description:
        "Builds 6 derived memory snapshot files in HealthOS/Constructor/Steward/memory/derived/: INDEX.md, construction-status.md, territory-index.md, settler-index.md, settlement-index.md, handoff-snapshot.md. Non-canonical — do not cite as evidence. Repository-maintenance tool. No clinical authority.",
    },
    async () => {
      const r = handleBuildMemory();
      return ok(r.content, r.isError);
    }
  );
}

export function registerTools(server: McpServer): void {
  registerNoArgTools(server);
  registerIdArgTools(server);
}
