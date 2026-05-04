import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { parseSettlement } from "../lib/settlement-parser.js";
import { readTerritory } from "../lib/territory-reader.js";
import { readSettler } from "../lib/settler-reader.js";
import { assemblePromptSpec } from "../lib/prompt-assembler.js";

export function runGeneratePrompt(args: string[]): number {
  const settlementId = args[0];
  if (!settlementId) {
    process.stderr.write(
      "Error: generate-prompt requires a settlement ID.\n" +
        "Usage: healthos-steward generate-prompt <settlement-id>\n"
    );
    return 1;
  }

  const activePath = join(
    repoRoot,
    ".healthos-steward",
    "settlements",
    "active",
    `${settlementId}.md`
  );
  const completedPath = join(
    repoRoot,
    ".healthos-steward",
    "settlements",
    "completed",
    `${settlementId}.md`
  );

  let settlementPath: string;
  if (existsSync(activePath)) {
    settlementPath = activePath;
  } else if (existsSync(completedPath)) {
    settlementPath = completedPath;
  } else {
    process.stderr.write(
      `Error: Settlement '${settlementId}' not found in active/ or completed/\n`
    );
    return 1;
  }

  let rawMarkdown: string;
  try {
    rawMarkdown = readFileSync(settlementPath, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not read settlement file: ${msg}\n`);
    return 1;
  }

  let settlement;
  try {
    settlement = parseSettlement(rawMarkdown);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: Settlement '${settlementId}' is ${msg}\n`);
    return 1;
  }

  const territories = [];
  for (const territoryId of settlement.territoryIds) {
    try {
      territories.push(readTerritory(territoryId));
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      process.stderr.write(`Error: ${msg}\n`);
      return 1;
    }
  }

  const settlers = [];
  for (const settlerId of settlement.settlerIds) {
    try {
      settlers.push(readSettler(settlerId));
    } catch (e) {
      const msg = e instanceof Error ? e.message : String(e);
      process.stderr.write(`Error: ${msg}\n`);
      return 1;
    }
  }

  let promptSpec: string;
  try {
    promptSpec = assemblePromptSpec({ settlement, territories, settlers });
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: prompt assembly failed: ${msg}\n`);
    return 1;
  }

  const outputDir = join(repoRoot, ".healthos-steward", "prompts", "generated");
  mkdirSync(outputDir, { recursive: true });

  const outputPath = join(outputDir, `${settlementId}.md`);
  try {
    writeFileSync(outputPath, promptSpec, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${settlementId}.md`;
  console.log(`Generated: ${relPath}`);
  return 0;
}
