import { writeFileSync, mkdirSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { buildPrDraft } from "../lib/pr-draft-builder.js";
import { resolveSettlement } from "../lib/settlement-resolver.js";

export function runPrDraft(args: string[]): number {
  const settlementId = args[0];
  if (!settlementId) {
    process.stderr.write(
      "Error: pr-draft requires a settlement ID.\n" +
        "Usage: healthos-steward pr-draft <settlement-id>\n"
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

  const outputPath = join(outputDir, `${resolved.fileId}-pr-draft.md`);
  try {
    writeFileSync(outputPath, draft, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${resolved.fileId}-pr-draft.md`;
  console.log(`PR draft: ${relPath}`);
  return 0;
}
