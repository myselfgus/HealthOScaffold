import { readFileSync, existsSync, readdirSync, writeFileSync, mkdirSync } from "node:fs";
import { join, dirname, resolve } from "node:path";
import { fileURLToPath } from "node:url";
import type { Tool } from "@modelcontextprotocol/sdk/types.js";
import {
  readAllTrackerTasks,
  readTerritory,
  readSettler,
  parseSettlement,
  assemblePromptSpec,
  buildIndex,
  buildConstructionStatus,
  buildTerritoryIndex,
  buildSettlerIndex,
  buildSettlementIndex,
  buildHandoffSnapshot,
} from "@healthos/steward";
import type {
  TrackerTask,
  TerritoryRecord,
  SettlerRecord,
  CriterionResult,
} from "@healthos/steward";

// repoRoot resolved locally — same 4-level depth as steward (ts/agent-infra/<pkg>/dist/ → repo root)
const __filename = fileURLToPath(import.meta.url);
const __dirname = dirname(__filename);
const repoRoot = resolve(__dirname, "../../../../");

const NON_CANONICAL =
  "Repository-maintenance tool response. No clinical authority, merge authority, or production-readiness claim.";

// Criterion classification logic mirrored from validate-settlement command
const SHELL_TOKENS = ["make ", "swift run", "npm run", "cd ", "npx "];
const PATH_REGEX = /(?:^|[\s`'"])(\.[/\w.-]+|[\w-]+\/[\w./-]+)/;

function classifyCriterion(criterion: string): CriterionResult {
  for (const token of SHELL_TOKENS) {
    if (criterion.includes(token)) {
      return { criterion, result: "UNVERIFIED" };
    }
  }
  const match = PATH_REGEX.exec(criterion);
  if (match && match[1]) {
    const token = match[1];
    const absolutePath = join(repoRoot, token);
    const exists = existsSync(absolutePath);
    return { criterion, result: exists ? "PASS" : "FAIL", path: token };
  }
  return { criterion, result: "UNVERIFIED" };
}

// Tool handlers

function handleNextTask(): Record<string, unknown> {
  const tasks = readAllTrackerTasks();
  const next = tasks.find((t) => t.status === "TODO");
  if (!next) {
    return { error: "No TODO tasks found", _non_canonical: NON_CANONICAL };
  }
  return {
    id: next.id,
    title: next.title,
    status: next.status,
    note: "first TODO in ST sequence",
    _non_canonical: NON_CANONICAL,
  };
}

function handleScanStatus(): Record<string, unknown> {
  const tasks = readAllTrackerTasks();
  const doneCount = tasks.filter((t) => t.status === "DONE").length;
  return {
    tasks,
    summary: `${doneCount} of ${tasks.length} DONE`,
    _non_canonical: NON_CANONICAL,
  };
}

function handleGetHandoff(): Record<string, unknown> {
  const handoffPath = join(repoRoot, "docs", "execution", "12-next-agent-handoff.md");
  if (!existsSync(handoffPath)) {
    return { error: "Handoff doc not found", _non_canonical: NON_CANONICAL };
  }
  const content = readFileSync(handoffPath, "utf-8").split("\n").slice(0, 60).join("\n");
  return {
    content,
    source: "docs/execution/12-next-agent-handoff.md",
    _non_canonical: NON_CANONICAL,
  };
}

function handleListTerritories(): Record<string, unknown> {
  const terrDir = join(repoRoot, ".healthos-settler", "territories");
  const files = readdirSync(terrDir)
    .filter((f) => f.endsWith(".json") && f !== "territory.schema.json")
    .sort();
  const territories: Array<{ id: string; name: string; maturity: string }> = [];
  for (const file of files) {
    const id = file.replace(/\.json$/, "");
    try {
      const rec = readTerritory(id);
      territories.push({ id: rec.id, name: rec.name, maturity: rec.maturity });
    } catch {
      // skip malformed records
    }
  }
  return { territories, _non_canonical: NON_CANONICAL };
}

function handleInspectTerritory(id: string): Record<string, unknown> {
  try {
    const rec = readTerritory(id);
    return { ...rec, _non_canonical: NON_CANONICAL };
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { error: `Territory '${id}' not found: ${msg}`, _non_canonical: NON_CANONICAL };
  }
}

function handleListSettlers(): Record<string, unknown> {
  const readmePath = join(repoRoot, ".healthos-settler", "settlers", "README.md");
  if (!existsSync(readmePath)) {
    return { error: "Settlers README.md not found", _non_canonical: NON_CANONICAL };
  }
  const text = readFileSync(readmePath, "utf-8");
  const dataRows = text.split("\n").filter((l) => l.trimStart().startsWith("| ["));
  const settlers = dataRows.map((row) => {
    const parts = row.split("|").map((p) => p.trim());
    const linkMatch = parts[1]?.match(/^\[([^\]]+)\]/);
    const profileId = linkMatch ? linkMatch[1] : (parts[1] ?? "");
    const territoryId = (parts[2] ?? "").replace(/`/g, "").trim();
    const maturity = (parts[4] ?? "").trim();
    return { profileId, territoryId, maturity };
  });
  return { settlers, _non_canonical: NON_CANONICAL };
}

function handleListSettlements(): Record<string, unknown> {
  const baseDir = join(repoRoot, ".healthos-steward", "settlements");
  const active: Array<{ id: string; title: string; status: string }> = [];
  const completed: Array<{ id: string; title: string; status: string }> = [];
  for (const [subdir, arr] of [
    ["active", active],
    ["completed", completed],
  ] as [string, typeof active][]) {
    const dir = join(baseDir, subdir);
    if (!existsSync(dir)) continue;
    let files: string[];
    try {
      files = readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
    } catch {
      continue;
    }
    for (const file of files) {
      const stem = file.replace(/\.md$/, "");
      try {
        const raw = readFileSync(join(dir, file), "utf-8");
        const rec = parseSettlement(raw);
        arr.push({ id: rec.id, title: rec.title, status: rec.status });
      } catch {
        arr.push({ id: stem, title: stem, status: "UNKNOWN" });
      }
    }
  }
  return { active, completed, _non_canonical: NON_CANONICAL };
}

function handleValidateSettlement(id: string): Record<string, unknown> {
  const activePath = join(repoRoot, ".healthos-steward", "settlements", "active", `${id}.md`);
  const completedPath = join(repoRoot, ".healthos-steward", "settlements", "completed", `${id}.md`);
  let settlementPath: string;
  if (existsSync(activePath)) {
    settlementPath = activePath;
  } else if (existsSync(completedPath)) {
    settlementPath = completedPath;
  } else {
    return {
      error: `Settlement '${id}' not found in active/ or completed/`,
      _non_canonical: NON_CANONICAL,
    };
  }
  let settlement;
  try {
    const raw = readFileSync(settlementPath, "utf-8");
    settlement = parseSettlement(raw);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { error: `Parse error: ${msg}`, _non_canonical: NON_CANONICAL };
  }
  const criterionResults: CriterionResult[] = settlement.doneCriteria.map(classifyCriterion);
  const passCount = criterionResults.filter((r) => r.result === "PASS").length;
  const failCount = criterionResults.filter((r) => r.result === "FAIL").length;
  const unverifiedCount = criterionResults.filter((r) => r.result === "UNVERIFIED").length;
  return {
    id,
    criterionResults,
    summary: `${passCount} PASS, ${failCount} FAIL, ${unverifiedCount} UNVERIFIED`,
    hasFail: failCount > 0,
    _non_canonical: NON_CANONICAL,
  };
}

function handleGeneratePrompt(id: string): Record<string, unknown> {
  const activePath = join(repoRoot, ".healthos-steward", "settlements", "active", `${id}.md`);
  const completedPath = join(repoRoot, ".healthos-steward", "settlements", "completed", `${id}.md`);
  let settlementPath: string;
  if (existsSync(activePath)) {
    settlementPath = activePath;
  } else if (existsSync(completedPath)) {
    settlementPath = completedPath;
  } else {
    return {
      error: `Settlement '${id}' not found in active/ or completed/`,
      _non_canonical: NON_CANONICAL,
    };
  }
  let settlement;
  try {
    const raw = readFileSync(settlementPath, "utf-8");
    settlement = parseSettlement(raw);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { error: `Parse error: ${msg}`, _non_canonical: NON_CANONICAL };
  }
  const territories: TerritoryRecord[] = [];
  for (const territoryId of settlement.territoryIds) {
    try {
      territories.push(readTerritory(territoryId));
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return { error: `Territory error: ${msg}`, _non_canonical: NON_CANONICAL };
    }
  }
  const settlers: SettlerRecord[] = [];
  for (const settlerId of settlement.settlerIds) {
    try {
      settlers.push(readSettler(settlerId));
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      return { error: `Settler error: ${msg}`, _non_canonical: NON_CANONICAL };
    }
  }
  let promptSpec: string;
  try {
    promptSpec = assemblePromptSpec({ settlement, territories, settlers });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    return { error: `Prompt assembly failed: ${msg}`, _non_canonical: NON_CANONICAL };
  }
  const outputDir = join(repoRoot, ".healthos-steward", "prompts", "generated");
  mkdirSync(outputDir, { recursive: true });
  const outputPath = join(outputDir, `${id}.md`);
  writeFileSync(outputPath, promptSpec, "utf-8");
  const relPath = `.healthos-steward/prompts/generated/${id}.md`;
  const sectionsCount = (promptSpec.match(/<[a-z_]+>/g) ?? []).length;
  return { outputPath: relPath, sectionsCount, _non_canonical: NON_CANONICAL };
}

function handleBuildMemory(): Record<string, unknown> {
  const derivedDir = join(repoRoot, ".healthos-steward", "memory", "derived");
  mkdirSync(derivedDir, { recursive: true });
  const date = new Date().toISOString().slice(0, 10);
  const results: string[] = [];
  const warnings: string[] = [];

  // construction-status.md
  let tasks: TrackerTask[] = [];
  try {
    tasks = readAllTrackerTasks();
    const content = buildConstructionStatus(tasks, date);
    writeFileSync(join(derivedDir, "construction-status.md"), content, "utf-8");
    results.push("construction-status.md");
  } catch (e) {
    warnings.push(`construction-status.md: ${e instanceof Error ? e.message : String(e)}`);
  }

  // territory-index.md
  try {
    const terrDir = join(repoRoot, ".healthos-settler", "territories");
    const files = readdirSync(terrDir)
      .filter((f) => f.endsWith(".json") && f !== "territory.schema.json")
      .sort();
    const territories: TerritoryRecord[] = [];
    for (const file of files) {
      const id = file.replace(/\.json$/, "");
      try {
        territories.push(readTerritory(id));
      } catch (e) {
        warnings.push(`territory ${id}: ${e instanceof Error ? e.message : String(e)}`);
      }
    }
    const content = buildTerritoryIndex(territories, date);
    writeFileSync(join(derivedDir, "territory-index.md"), content, "utf-8");
    results.push("territory-index.md");
  } catch (e) {
    warnings.push(`territory-index.md: ${e instanceof Error ? e.message : String(e)}`);
  }

  // settler-index.md
  try {
    const readmePath = join(repoRoot, ".healthos-settler", "settlers", "README.md");
    const text = readFileSync(readmePath, "utf-8");
    const dataRows = text.split("\n").filter((l) => l.trimStart().startsWith("| ["));
    const settlers: SettlerRecord[] = dataRows.map((row) => {
      const parts = row.split("|").map((p) => p.trim());
      const linkMatch = parts[1]?.match(/^\[([^\]]+)\]/);
      const id = linkMatch ? linkMatch[1] : (parts[1] ?? "");
      const territoryId = (parts[2] ?? "").replace(/`/g, "").trim();
      const maturity = (parts[4] ?? "").trim();
      return { id, territoryId, maturity, invariants: [], forbiddenMoves: [] };
    });
    const content = buildSettlerIndex(settlers, date);
    writeFileSync(join(derivedDir, "settler-index.md"), content, "utf-8");
    results.push("settler-index.md");
  } catch (e) {
    warnings.push(`settler-index.md: ${e instanceof Error ? e.message : String(e)}`);
  }

  // settlement-index.md
  try {
    const baseDir = join(repoRoot, ".healthos-steward", "settlements");
    const activeEntries: Array<{ id: string; title: string; status: string }> = [];
    const completedEntries: Array<{ id: string; title: string; status: string }> = [];
    for (const [subdir, arr] of [
      ["active", activeEntries],
      ["completed", completedEntries],
    ] as [string, typeof activeEntries][]) {
      const dir = join(baseDir, subdir);
      if (!existsSync(dir)) continue;
      let files: string[];
      try {
        files = readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
      } catch {
        continue;
      }
      for (const file of files) {
        const stem = file.replace(/\.md$/, "");
        try {
          const raw = readFileSync(join(dir, file), "utf-8");
          const rec = parseSettlement(raw);
          arr.push({ id: rec.id, title: rec.title, status: rec.status });
        } catch {
          warnings.push(`settlement ${stem}: parse error, using filename as id`);
          arr.push({ id: stem, title: stem, status: "UNKNOWN" });
        }
      }
    }
    const content = buildSettlementIndex(activeEntries, completedEntries, date);
    writeFileSync(join(derivedDir, "settlement-index.md"), content, "utf-8");
    results.push("settlement-index.md");
  } catch (e) {
    warnings.push(`settlement-index.md: ${e instanceof Error ? e.message : String(e)}`);
  }

  // handoff-snapshot.md
  try {
    let handoffRaw = "(handoff doc not found)";
    const handoffPath = join(repoRoot, "docs", "execution", "12-next-agent-handoff.md");
    if (existsSync(handoffPath)) {
      handoffRaw = readFileSync(handoffPath, "utf-8");
    } else {
      warnings.push("handoff-snapshot.md: handoff doc not found, using placeholder");
    }
    const content = buildHandoffSnapshot(handoffRaw, tasks, date);
    writeFileSync(join(derivedDir, "handoff-snapshot.md"), content, "utf-8");
    results.push("handoff-snapshot.md");
  } catch (e) {
    warnings.push(`handoff-snapshot.md: ${e instanceof Error ? e.message : String(e)}`);
  }

  // INDEX.md (last)
  let indexContent = buildIndex(results, date);
  if (warnings.length > 0) {
    indexContent += "\n## Warnings\n\n";
    for (const w of warnings) {
      indexContent += `- ${w}\n`;
    }
  }
  writeFileSync(join(derivedDir, "INDEX.md"), indexContent, "utf-8");
  results.push("INDEX.md");

  return { filesWritten: results, warnings, _non_canonical: NON_CANONICAL };
}

// Tool definitions (for tools/list)
export const TOOLS: Tool[] = [
  {
    name: "steward_next_task",
    description: "Returns the next TODO construction task from the ST tracker",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_scan_status",
    description: "Returns full ST construction task sequence with statuses",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_get_handoff",
    description: "Returns the current agent handoff document content",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_list_territories",
    description: "Lists all Territory records in the registry",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_inspect_territory",
    description: "Returns full details of a Territory record",
    inputSchema: {
      type: "object",
      properties: {
        id: { type: "string", description: "Territory ID e.g. 'core', 'gos'" },
      },
      required: ["id"],
    },
  },
  {
    name: "steward_list_settlers",
    description: "Lists all Settler profile records",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_list_settlements",
    description: "Lists all active and completed Settlement records",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
  {
    name: "steward_validate_settlement",
    description: "Validates a Settlement's done-criteria against filesystem evidence",
    inputSchema: {
      type: "object",
      properties: {
        id: {
          type: "string",
          description: "Settlement ID e.g. 'st-012-settler-profile-registry'",
        },
      },
      required: ["id"],
    },
  },
  {
    name: "steward_generate_prompt",
    description: "Generates a PromptSpec from a Settlement record",
    inputSchema: {
      type: "object",
      properties: {
        id: { type: "string", description: "Settlement ID" },
      },
      required: ["id"],
    },
  },
  {
    name: "steward_build_memory",
    description: "Builds derived memory snapshots from current repository state",
    inputSchema: { type: "object", properties: {}, required: [] as string[] },
  },
];

// Tool dispatcher
export async function callTool(
  name: string,
  args: Record<string, unknown>
): Promise<Record<string, unknown>> {
  switch (name) {
    case "steward_next_task":
      return handleNextTask();
    case "steward_scan_status":
      return handleScanStatus();
    case "steward_get_handoff":
      return handleGetHandoff();
    case "steward_list_territories":
      return handleListTerritories();
    case "steward_inspect_territory":
      return handleInspectTerritory(args.id as string);
    case "steward_list_settlers":
      return handleListSettlers();
    case "steward_list_settlements":
      return handleListSettlements();
    case "steward_validate_settlement":
      return handleValidateSettlement(args.id as string);
    case "steward_generate_prompt":
      return handleGeneratePrompt(args.id as string);
    case "steward_build_memory":
      return handleBuildMemory();
    default:
      return { error: `Unknown tool: ${name}`, _non_canonical: NON_CANONICAL };
  }
}
