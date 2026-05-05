// @ts-nocheck
// TypeScript type checking is intentionally disabled for this module.
// Reason: McpServer.registerTool() with Zod inputSchema causes TS2589 ("Type instantiation
// is excessively deep") when Zod 4.x is installed with the MCP SDK 1.29.0 dual-compat
// type union (AnySchema = z3.ZodTypeAny | z4.$ZodType). This is a TypeScript tooling
// limitation, not a runtime issue — Zod validates inputs correctly at runtime.
// The handler contracts in handlers.ts (fully type-checked) enforce correctness.
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod";
import {
  handleInspectTerritory,
  handleValidateSettlement,
  handleGeneratePrompt,
} from "./handlers.js";

function ok(content, isError) {
  const r = { content: [{ type: "text", text: content }] };
  if (isError) r.isError = true;
  return r;
}

export function registerIdArgTools(server: McpServer): void {
  server.registerTool(
    "steward_inspect_territory",
    {
      description:
        "Returns the full Territory record for the given ID, including canonical docs, primary/secondary paths, invariants, allowed work, forbidden work, validation commands, and known gaps. Repository-maintenance tool. No clinical authority.",
      inputSchema: {
        id: z
          .string()
          .min(1)
          .describe(
            "Territory ID — e.g. 'core', 'gos', 'session-runtime', 'msr', 'aaci', 'construction-system'"
          ),
      },
    },
    async ({ id }) => {
      const r = handleInspectTerritory(id);
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_validate_settlement",
    {
      description:
        "Validates a Settlement's done-criteria against filesystem evidence. Each criterion is classified as PASS (file exists), FAIL (file missing), or UNVERIFIED (shell command or unresolvable path). Exits with hasFail: true if any FAIL found. No shell execution, no LLM. Repository-maintenance tool. No clinical authority.",
      inputSchema: {
        id: z
          .string()
          .min(1)
          .describe("Settlement ID — e.g. 'st-012-settler-profile-registry'"),
      },
    },
    async ({ id }) => {
      const r = handleValidateSettlement(id);
      return ok(r.content, r.isError);
    }
  );

  server.registerTool(
    "steward_generate_prompt",
    {
      description:
        "Generates a 16-section PromptSpec Markdown from a Settlement record, its Territory records, and Settler profiles. Writes output to .healthos-steward/prompts/generated/<id>.md. No LLM calls. Repository-maintenance tool. No clinical authority.",
      inputSchema: {
        id: z
          .string()
          .min(1)
          .describe("Settlement ID — e.g. 'st-012-settler-profile-registry'"),
      },
    },
    async ({ id }) => {
      const r = handleGeneratePrompt(id);
      return ok(r.content, r.isError);
    }
  );
}
