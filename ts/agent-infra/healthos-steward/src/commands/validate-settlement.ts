import { writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { resolveSettlement } from "../lib/settlement-resolver.js";
import { classifySettlementCriteria } from "../lib/settlement-validation.js";
import {
  buildValidationReport,
  CriterionResult,
  FileCheckResult,
  ValidationEvidence,
} from "../lib/validation-report-builder.js";

export function runValidateSettlement(args: string[]): number {
  const settlementId = args[0];
  if (!settlementId) {
    process.stderr.write(
      "Error: validate-settlement requires a settlement ID.\n" +
        "Usage: healthos-steward validate-settlement <settlement-id>\n"
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

  const criterionResults: CriterionResult[] = classifySettlementCriteria(
    settlement.doneCriteria,
    repoRoot
  );

  const fileCheckResults: FileCheckResult[] = settlement.filesInScope.map(
    (path) => ({ path, exists: existsSync(join(repoRoot, path)) })
  );

  const evidence: ValidationEvidence = { criterionResults, fileCheckResults };

  let report: string;
  try {
    report = buildValidationReport(settlement, evidence);
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: report generation failed: ${msg}\n`);
    return 1;
  }

  const outputDir = join(repoRoot, ".healthos-steward", "prompts", "generated");
  mkdirSync(outputDir, { recursive: true });

  const outputPath = join(outputDir, `${resolved.fileId}-validation.md`);
  try {
    writeFileSync(outputPath, report, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${resolved.fileId}-validation.md`;
  console.log(`Validation report: ${relPath}`);

  const passCount = criterionResults.filter((r) => r.result === "PASS").length;
  const failCount = criterionResults.filter((r) => r.result === "FAIL").length;
  const unverifiedCount = criterionResults.filter(
    (r) => r.result === "UNVERIFIED"
  ).length;
  console.log(
    `Results: ${passCount} PASS, ${failCount} FAIL, ${unverifiedCount} UNVERIFIED`
  );

  return failCount > 0 ? 1 : 0;
}
