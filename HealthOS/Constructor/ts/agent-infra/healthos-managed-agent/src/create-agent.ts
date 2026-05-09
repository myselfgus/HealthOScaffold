#!/usr/bin/env node
/**
 * Create or update the HealthOS Steward Coordinator agent via Anthropic Managed Agents API.
 *
 * Usage:
 *   node dist/create-agent.js            — create (if no agent.json) or show saved ID
 *   node dist/create-agent.js --force    — always update to current definition
 *   node dist/create-agent.js --dry-run  — validate config, no API calls
 *
 * Auth (checked in order):
 *   1. ANTHROPIC_API_KEY  — platform API key from console.anthropic.com (preferred)
 *   2. ANTHROPIC_AUTH_TOKEN — bearer token (Claude Code session token / claude.ai OAuth)
 *      Claude Code sessions expose a per-session bearer token; pass it via this env var.
 *      Note: Managed Agents beta access must be enabled for the associated account.
 *
 * Writes:   HealthOS/Constructor/Steward/managed-agent/agent.json (agent ID + version)
 *
 * Construction-system artifact. No clinical authority. No merge authority.
 */

import Anthropic from "@anthropic-ai/sdk";
import { readFileSync, writeFileSync, existsSync, mkdirSync } from "node:fs";
import { join, dirname } from "node:path";
import { fileURLToPath } from "node:url";
import { STEWARD_COORDINATOR_DEF, FORGE_MCP_URL } from "./agent-def.js";

const __dirname = dirname(fileURLToPath(import.meta.url));

function findRepoRoot(start: string): string {
  let current = start;
  for (let depth = 0; depth < 12; depth += 1) {
    if (
      existsSync(join(current, "AGENTS.md")) &&
      existsSync(join(current, "HealthOS", "Package.swift"))
    ) {
      return current;
    }
    const parent = dirname(current);
    if (parent === current) break;
    current = parent;
  }
  throw new Error("Unable to locate HealthOS repository root.");
}

const repoRoot = findRepoRoot(__dirname);
const agentStatePath = join(repoRoot, "HealthOS", "Constructor", "Steward", "managed-agent", "agent.json");

type AgentState = { id: string; version: number; name: string; createdAt: string; updatedAt: string };

function readAgentState(): AgentState | null {
  if (!existsSync(agentStatePath)) return null;
  try {
    return JSON.parse(readFileSync(agentStatePath, "utf-8")) as AgentState;
  } catch {
    return null;
  }
}

function writeAgentState(state: AgentState): void {
  mkdirSync(dirname(agentStatePath), { recursive: true });
  writeFileSync(agentStatePath, JSON.stringify(state, null, 2) + "\n", "utf-8");
}

const args = process.argv.slice(2);
const isDryRun = args.includes("--dry-run");
const isForce = args.includes("--force");

console.log("HealthOS Steward Coordinator — agent definition");
console.log(`  model:          ${STEWARD_COORDINATOR_DEF.model}`);
console.log(`  mcp_servers[0]: ${FORGE_MCP_URL}`);
console.log(`  tools:          ${STEWARD_COORDINATOR_DEF.tools.map((t) => t.type).join(", ")}`);
console.log("");

if (isDryRun) {
  console.log("[dry-run] Configuration valid. No API calls made.");
  console.log(
    "[dry-run] REMINDER: FORGE_MCP_URL must be a publicly-accessible URL for Managed Agents API."
  );
  process.exit(0);
}

const apiKey = process.env.ANTHROPIC_API_KEY;
const authToken = process.env.ANTHROPIC_AUTH_TOKEN;

if (!apiKey && !authToken) {
  console.error("Error: no auth credential found.");
  console.error("  Option 1 — platform API key:  export ANTHROPIC_API_KEY=sk-ant-...");
  console.error("  Option 2 — session bearer:    export ANTHROPIC_AUTH_TOKEN=<token>");
  console.error("  Option 3 — dry run only:      node dist/create-agent.js --dry-run");
  console.error("");
  console.error("Claude Code session token: Claude Code sessions generate a per-session");
  console.error("bearer token. Capture it and pass as ANTHROPIC_AUTH_TOKEN.");
  process.exit(1);
}

const client = apiKey
  ? new Anthropic({ apiKey })
  : new Anthropic({ authToken: authToken! });

console.log(`  auth mode:      ${apiKey ? "ANTHROPIC_API_KEY" : "ANTHROPIC_AUTH_TOKEN (bearer)"}`);
console.log("");

const existing = readAgentState();

if (existing && !isForce) {
  console.log(`Agent already registered.`);
  console.log(`  id:      ${existing.id}`);
  console.log(`  version: ${existing.version}`);
  console.log(`  name:    ${existing.name}`);
  console.log(`  updated: ${existing.updatedAt}`);
  console.log("");
  console.log("Run with --force to update the agent definition.");
  process.exit(0);
}

try {
  if (existing && isForce) {
    console.log(`Updating agent ${existing.id} (v${existing.version} → next)...`);
    // Omit name and model from update payload (only send mutable fields)
    const updated = await (client as any).beta.agents.update(existing.id, {
      version: existing.version,
      system: STEWARD_COORDINATOR_DEF.system,
      description: STEWARD_COORDINATOR_DEF.description,
      mcp_servers: STEWARD_COORDINATOR_DEF.mcp_servers,
      tools: STEWARD_COORDINATOR_DEF.tools,
    });
    const state: AgentState = {
      id: updated.id,
      version: updated.version,
      name: updated.name,
      createdAt: existing.createdAt,
      updatedAt: updated.updated_at ?? new Date().toISOString(),
    };
    writeAgentState(state);
    console.log(`Updated. New version: ${state.version}`);
    console.log(`State written to: HealthOS/Constructor/Steward/managed-agent/agent.json`);
  } else {
    console.log(`Creating agent "${STEWARD_COORDINATOR_DEF.name}"...`);
    const created = await (client as any).beta.agents.create({
      ...STEWARD_COORDINATOR_DEF,
      // Spread mutable fields — name and model are required at creation
    });
    const state: AgentState = {
      id: created.id,
      version: created.version,
      name: created.name,
      createdAt: created.created_at ?? new Date().toISOString(),
      updatedAt: created.updated_at ?? new Date().toISOString(),
    };
    writeAgentState(state);
    console.log(`Created.`);
    console.log(`  id:      ${state.id}`);
    console.log(`  version: ${state.version}`);
    console.log(`State written to: HealthOS/Constructor/Steward/managed-agent/agent.json`);
  }
} catch (err) {
  const msg = err instanceof Error ? err.message : String(err);
  console.error(`Error: ${msg}`);
  process.exit(1);
}
