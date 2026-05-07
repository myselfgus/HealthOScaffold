import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { resolveSettlement } from "../lib/settlement-resolver.js";
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

  const resolved = resolveSettlement(settlementId);
  if (!resolved) {
    process.stderr.write(
      `Error: Settlement '${settlementId}' not found in active/ or completed/\n`
    );
    return 1;
  }
  const settlement = resolved.record;

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

  const outputPath = join(outputDir, `${resolved.fileId}.md`);
  try {
    writeFileSync(outputPath, promptSpec, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${resolved.fileId}.md`;
  console.log(`Generated: ${relPath}`);
  return 0;
}
