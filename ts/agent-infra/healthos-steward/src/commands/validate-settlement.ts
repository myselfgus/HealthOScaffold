import { readFileSync, writeFileSync, mkdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { parseSettlement } from "../lib/settlement-parser.js";
import {
  buildValidationReport,
  CriterionResult,
  FileCheckResult,
  ValidationEvidence,
} from "../lib/validation-report-builder.js";

const SHELL_TOKENS = ["make ", "swift run", "npm run", "cd ", "npx "];
const PATH_REGEX = /(?:^|[\s`'"])(\.[/\w.-]+|[\w-]+\/[\w./-]+)/;

function classifyCriterion(
  criterion: string,
  repoRootPath: string
): CriterionResult {
  for (const token of SHELL_TOKENS) {
    if (criterion.includes(token)) {
      return { criterion, result: "UNVERIFIED" };
    }
  }

  const match = PATH_REGEX.exec(criterion);
  if (match && match[1]) {
    const token = match[1];
    const absolutePath = join(repoRootPath, token);
    const exists = existsSync(absolutePath);
    return { criterion, result: exists ? "PASS" : "FAIL", path: token };
  }

  return { criterion, result: "UNVERIFIED" };
}

export function runValidateSettlement(args: string[]): number {
  const settlementId = args[0];
  if (!settlementId) {
    process.stderr.write(
      "Error: validate-settlement requires a settlement ID.\n" +
        "Usage: healthos-steward validate-settlement <settlement-id>\n"
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

  const criterionResults: CriterionResult[] = settlement.doneCriteria.map(
    (criterion) => classifyCriterion(criterion, repoRoot)
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

  const outputPath = join(outputDir, `${settlementId}-validation.md`);
  try {
    writeFileSync(outputPath, report, "utf-8");
  } catch (e) {
    const msg = e instanceof Error ? e.message : String(e);
    process.stderr.write(`Error: could not write output file: ${msg}\n`);
    return 1;
  }

  const relPath = `.healthos-steward/prompts/generated/${settlementId}-validation.md`;
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
