import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { parseSettlement } from "../lib/settlement-parser.js";
import { buildPrDraft } from "../lib/pr-draft-builder.js";

export function runPrDraft(args: string[]): number {
  const settlementId = args[0];
  if (!settlementId) {
    process.stderr.write(
      "Error: pr-draft requires a settlement ID.\n" +
        "Usage: healthos-steward pr-draft <settlement-id>\n"
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
    process.stderr.write(
      `Error: Settlement '${settlementId}' parse error: ${msg}\n`
    );
    return 1;
  }

  let draft: string;
  try {
    draft = buildPrDraft(settlement);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: PR draft generation failed: ${msg}\n`);
    return 1;
  }

  const outputDir = join(repoRoot, ".healthos-steward", "prompts", "generated");
  mkdirSync(outputDir, { recursive: true });

  const outputPath = join(outputDir, `${settlementId}-pr-draft.md`);
  try {
    writeFileSync(outputPath, draft, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${settlementId}-pr-draft.md`;
  console.log(`PR draft: ${relPath}`);
  return 0;
}
