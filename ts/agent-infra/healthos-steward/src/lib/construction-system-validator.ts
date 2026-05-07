import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { listResolvedSettlements, resolveSettlement } from "./settlement-resolver.js";
import { readAllTrackerTasks } from "./tracker-reader.js";

export interface ConstructionValidationCheck {
  name: string;
  result: "PASS" | "FAIL";
  detail: string;
}

const EXPECTED_FORGE_TOOLS = [
  "steward_next_task",
  "steward_scan_status",
  "steward_get_handoff",
  "steward_list_territories",
  "steward_inspect_territory",
  "steward_list_settlers",
  "steward_list_settlements",
  "steward_validate_settlement",
  "steward_generate_prompt",
  "steward_build_memory",
];

const LIVE_DOCS = [
  "docs/execution/19-settler-model-task-tracker.md",
  "docs/execution/22-steward-construction-operating-model.md",
  ".healthos-settler/settlers/settler-xcode-tooling.md",
  ".healthos-settler/settlers/README.md",
  ".healthos-settler/territories/construction-system.json",
  ".healthos-steward/settlements/README.md",
  ".healthos-steward/prompts/generated/README.md",
  ".healthos-steward/prompts/prompt-architecture-template.md",
];

function pass(name: string, detail: string): ConstructionValidationCheck {
  return { name, result: "PASS", detail };
}

function fail(name: string, detail: string): ConstructionValidationCheck {
  return { name, result: "FAIL", detail };
}

function readRel(path: string): string {
  return readFileSync(join(repoRoot, path), "utf-8");
}

function validateSettlementRoundTrip(): ConstructionValidationCheck {
  const settlements = listResolvedSettlements();
  const all = [...settlements.active, ...settlements.completed];
  const failures: string[] = [];
  for (const settlement of all) {
    if (!resolveSettlement(settlement.fileId)) {
      failures.push(`${settlement.fileId} did not resolve by fileId`);
    }
    if (!resolveSettlement(settlement.canonicalId)) {
      failures.push(`${settlement.canonicalId} did not resolve by canonicalId`);
    }
  }
  return failures.length === 0
    ? pass("settlement-round-trip", `${all.length} settlement(s) resolve by fileId and canonicalId`)
    : fail("settlement-round-trip", failures.join("; "));
}

function validateTerritoryIds(): ConstructionValidationCheck {
  const dir = join(repoRoot, ".healthos-settler", "territories");
  const ids = readdirSync(dir)
    .filter((f) => f.endsWith(".json") && f !== "territory.schema.json")
    .map((f) => f.replace(/\.json$/, ""))
    .sort();
  const joined = ids.join(", ");
  const schemaText = readRel(".healthos-settler/settlements/SCHEMA.md");
  const templateText = readRel(".healthos-steward/settlements/templates/settlement-template.md");
  if (schemaText.includes("typescript-runtimes") || templateText.includes("typescript-runtimes")) {
    return fail("territory-id-naming", "found stale territory id `typescript-runtimes`; use `type-script-runtimes`");
  }
  return ids.includes("type-script-runtimes")
    ? pass("territory-id-naming", `territory ids ok (${joined})`)
    : fail("territory-id-naming", "`type-script-runtimes` territory record missing");
}

function validateTrackerStatuses(): ConstructionValidationCheck {
  const tasks = readAllTrackerTasks();
  const unknown = tasks.filter((task) => task.rawStatus && task.status === "UNKNOWN");
  return unknown.length === 0
    ? pass("tracker-statuses", `${tasks.length} ST task status entries parsed`)
    : fail("tracker-statuses", unknown.map((t) => `${t.id}: ${t.rawStatus}`).join("; "));
}

function validateForgeTools(): ConstructionValidationCheck {
  const toolsText = readRel("ts/agent-infra/healthos-forge-mcp/src/tools.ts");
  const idArgText = readRel("ts/agent-infra/healthos-forge-mcp/src/tools-id-arg.ts");
  const missing = EXPECTED_FORGE_TOOLS.filter(
    (tool) => !toolsText.includes(`"${tool}"`) && !idArgText.includes(`"${tool}"`)
  );
  return missing.length === 0
    ? pass("forge-tool-list", `${EXPECTED_FORGE_TOOLS.length} expected forge tools found`)
    : fail("forge-tool-list", `missing tools: ${missing.join(", ")}`);
}

function validateNoStaleLiveClaims(): ConstructionValidationCheck {
  const stalePatterns = [
    "No `healthos-forge-mcp` server is implemented",
    "Forge MCP implementation, or prompt generation engine is implemented",
    "ST-018 healthos-forge-mcp: doctrine-only, not implemented",
    "Generated prompts will be written here by future Steward prompt generation",
    "When the HealthOS Forge MCP (`healthos-forge-mcp`) is implemented",
  ];
  const hits: string[] = [];
  for (const rel of LIVE_DOCS) {
    if (!existsSync(join(repoRoot, rel))) continue;
    const text = readRel(rel);
    for (const pattern of stalePatterns) {
      if (text.includes(pattern)) hits.push(`${rel}: ${pattern}`);
    }
  }
  return hits.length === 0
    ? pass("stale-live-claims", "no stale live Construction System claims found")
    : fail("stale-live-claims", hits.join("; "));
}

function validateDerivedNonCanonical(): ConstructionValidationCheck {
  const dirs = [
    ".healthos-steward/memory/derived",
    ".healthos-steward/prompts/generated",
  ];
  const missing: string[] = [];
  for (const dir of dirs) {
    const abs = join(repoRoot, dir);
    if (!existsSync(abs)) continue;
    const files = readdirSync(abs).filter((f) => f.endsWith(".md"));
    for (const file of files) {
      const rel = `${dir}/${file}`;
      const text = readRel(rel);
      if (!/non-canonical|not canonical/i.test(text)) missing.push(rel);
    }
  }
  return missing.length === 0
    ? pass("derived-non-canonical", "derived/generated markdown files carry non-canonical language")
    : fail("derived-non-canonical", `missing non-canonical language: ${missing.join(", ")}`);
}

export function validateConstructionSystem(): ConstructionValidationCheck[] {
  return [
    validateSettlementRoundTrip(),
    validateTerritoryIds(),
    validateTrackerStatuses(),
    validateForgeTools(),
    validateNoStaleLiveClaims(),
    validateDerivedNonCanonical(),
  ];
}
