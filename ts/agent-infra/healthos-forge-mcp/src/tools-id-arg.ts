// @ts-nocheck
// TypeScript type checking intentionally disabled for this file.
//
// Root cause: McpServer.registerTool() with any Zod inputSchema causes TS2589
// ("Type instantiation is excessively deep") in MCP SDK 1.29.0 + Zod 4.x.
// The error fires at multiple points inside multi-line call expressions
// (call site, callback signature, return type), making per-line @ts-ignore
// insufficient. The underlying cause is ShapeOutput<{id:ZodString}> triggering
// the SDK's dual-compat conditional type: SchemaOutput<S> = S extends
// z3.ZodTypeAny ? z3.infer<S> : S extends z4.$ZodType ? z4.output<S> : never.
// TypeScript's instantiation depth limit of 100 is exceeded during inference.
//
// Correctness guarantees despite @ts-nocheck:
//   - handler contracts are fully typed in handlers.ts
//   - all callbacks carry explicit ({ id }: { id: string }) parameter annotations
//   - Zod validates inputs at runtime before handlers are called
//   - ok() result shape is structurally compatible with CallToolResult
//
// Remove @ts-nocheck when MCP SDK resolves the z3/z4 compat depth issue.
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { z } from "zod/v3";
import {
  handleInspectTerritory,
  handleValidateSettlement,
  handleGeneratePrompt,
} from "./handlers.js";

function ok(content: string, isError?: boolean) {
  const r: { content: Array<{ type: "text"; text: string }>; isError?: boolean } = {
    content: [{ type: "text", text: content }],
  };
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
    async ({ id }: { id: string }) => {
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
    async ({ id }: { id: string }) => {
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
    async ({ id }: { id: string }) => {
      const r = handleGeneratePrompt(id);
      return ok(r.content, r.isError);
    }
  );
}
