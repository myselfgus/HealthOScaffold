import { existsSync } from "node:fs";
import { join } from "node:path";
import type { CriterionResult } from "./validation-report-builder.js";

const SHELL_TOKENS = ["make ", "swift run", "npm run", "cd ", "npx "];
const PATH_REGEX = /(?:^|[\s`'"])(\.[/\w.-]+|[\w-]+\/[\w./-]+)/;

export function classifyCriterion(
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

export function classifySettlementCriteria(
  criteria: string[],
  repoRootPath: string
): CriterionResult[] {
  return criteria.map((criterion) => classifyCriterion(criterion, repoRootPath));
}
