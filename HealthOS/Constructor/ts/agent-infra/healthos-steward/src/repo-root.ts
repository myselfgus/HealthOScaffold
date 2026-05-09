import { existsSync } from "node:fs";
import { fileURLToPath } from "node:url";
import { dirname, resolve } from "node:path";

const __dirname = dirname(fileURLToPath(import.meta.url));

function findRepoRoot(start: string): string {
  let current = start;
  for (let depth = 0; depth < 12; depth += 1) {
    if (
      existsSync(resolve(current, "AGENTS.md")) &&
      existsSync(resolve(current, "HealthOS", "Package.swift"))
    ) {
      return current;
    }
    const parent = resolve(current, "..");
    if (parent === current) {
      break;
    }
    current = parent;
  }
  throw new Error("Unable to locate HealthOS repository root");
}

export const repoRoot = findRepoRoot(__dirname);
