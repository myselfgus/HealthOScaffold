#!/usr/bin/env node
import { createServer, type IncomingMessage, type ServerResponse } from "node:http";
import { McpServer } from "@modelcontextprotocol/sdk/server/mcp.js";
import { StreamableHTTPServerTransport } from "@modelcontextprotocol/sdk/server/streamableHttp.js";
import { registerTools } from "./tools.js";

const PORT = Number(process.env.FORGE_MCP_PORT ?? 3791);

async function readBodyJson(req: IncomingMessage): Promise<unknown> {
  return new Promise((resolve, reject) => {
    const chunks: Buffer[] = [];
    req.on("data", (c: Buffer) => chunks.push(c));
    req.on("end", () => {
      const raw = Buffer.concat(chunks).toString("utf-8").trim();
      if (!raw) { resolve(undefined); return; }
      try { resolve(JSON.parse(raw)); } catch (e) { reject(e); }
    });
    req.on("error", reject);
  });
}

// Stateless: new McpServer + transport per request — all forge-mcp tools are
// deterministic read/write ops with no cross-request session state.
const httpServer = createServer(async (req: IncomingMessage, res: ServerResponse) => {
  if (req.url !== "/mcp") {
    res.writeHead(404, { "Content-Type": "text/plain" });
    res.end("Not found");
    return;
  }
  try {
    const mcpServer = new McpServer({ name: "healthos-forge-mcp", version: "0.1.0" });
    registerTools(mcpServer);
    const transport = new StreamableHTTPServerTransport({ sessionIdGenerator: undefined });
    await mcpServer.connect(transport);
    const body = req.method === "POST" ? await readBodyJson(req) : undefined;
    await transport.handleRequest(req, res, body);
    res.on("finish", () => { mcpServer.close().catch(() => {}); });
  } catch (err) {
    const msg = err instanceof Error ? err.message : String(err);
    if (!res.headersSent) {
      res.writeHead(500, { "Content-Type": "text/plain" });
      res.end(`forge-mcp error: ${msg}`);
    }
  }
});

httpServer.listen(PORT, "127.0.0.1", () => {
  process.stderr.write(`healthos-forge-mcp: HTTP server on http://127.0.0.1:${PORT}/mcp\n`);
});
