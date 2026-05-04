import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export function runInspect(args: string[]): number {
  const subtype = args[0];
  const id = args[1];
  if (!subtype || !id) {
    process.stderr.write(
      "Error: inspect requires <type> and <id>. Usage: healthos-steward inspect <type> <id>\n"
    );
    return 1;
  }
  switch (subtype) {
    case "territory":
      return inspectTerritory(id);
    case "settler":
      return inspectSettler(id);
    case "settlement":
      return inspectSettlement(id);
    default:
      process.stderr.write(
        `Error: unknown record type '${subtype}'. Use: territory | settler | settlement\n`
      );
      return 1;
  }
}

interface TerritoryRecord {
  id?: string;
  name?: string;
  maturity?: string;
  canonicalDocs?: string[];
  knownGaps?: string[];
}

function readJson(filePath: string): unknown | null {
  try {
    return JSON.parse(readFileSync(filePath, "utf-8"));
  } catch {
    return null;
  }
}

function inspectTerritory(id: string): number {
  const path = join(repoRoot, ".healthos-settler", "territories", `${id}.json`);
  if (!existsSync(path)) {
    process.stderr.write(`Error: Territory '${id}' not found.\n`);
    return 1;
  }
  const raw = readJson(path);
  if (raw === null) {
    process.stderr.write(`Error: Territory '${id}' has malformed JSON.\n`);
    return 1;
  }
  const record = raw as TerritoryRecord;
  console.log(`Territory: ${record.id ?? id}`);
  console.log(`Name: ${record.name ?? "(none)"}`);
  console.log(`Maturity: ${record.maturity ?? "(none)"}`);
  const docs = record.canonicalDocs ?? [];
  if (docs.length > 0) {
    console.log("Canonical docs:");
    for (const doc of docs) {
      console.log(`  ${doc}`);
    }
  } else {
    console.log("Canonical docs: (none)");
  }
  console.log(`Known gaps: ${record.knownGaps?.length ?? 0} gap(s)`);
  return 0;
}

function inspectSettler(id: string): number {
  const path = join(repoRoot, ".healthos-settler", "settlers", `${id}.md`);
  if (!existsSync(path)) {
    process.stderr.write(`Error: Settler '${id}' not found.\n`);
    return 1;
  }
  const lines = readFileSync(path, "utf-8").split("\n");
  let territory = "(not found)";
  let maturity = "(not found)";
  let invariantCount = 0;
  let forbiddenCount = 0;
  let section = "";
  for (const line of lines) {
    const trimmed = line.trim();
    if (trimmed.startsWith("## ")) {
      section = trimmed.slice(3).toLowerCase();
      continue;
    }
    if (section === "territory-id" && territory === "(not found)") {
      const m = trimmed.match(/^`([^`]+)`$/);
      if (m) territory = m[1];
    }
    if (section === "maturity" && maturity === "(not found)") {
      const m = trimmed.match(/^`([^`]+)`$/);
      if (m) maturity = m[1];
    }
    if (section === "invariants" && /^\d+\.\s/.test(trimmed)) {
      invariantCount++;
    }
    if (section === "forbidden-moves" && /^\d+\.\s/.test(trimmed)) {
      forbiddenCount++;
    }
  }
  console.log(`Settler: ${id}`);
  console.log(`Territory: ${territory}`);
  console.log(`Maturity: ${maturity}`);
  console.log(`Invariants: ${invariantCount}`);
  console.log(`Forbidden moves: ${forbiddenCount}`);
  return 0;
}

function inspectSettlement(id: string): number {
  const activePath = join(
    repoRoot,
    ".healthos-steward",
    "settlements",
    "active",
    `${id}.md`
  );
  const completedPath = join(
    repoRoot,
    ".healthos-steward",
    "settlements",
    "completed",
    `${id}.md`
  );
  let filePath: string;
  let label: string;
  if (existsSync(activePath)) {
    filePath = activePath;
    label = "active";
  } else if (existsSync(completedPath)) {
    filePath = completedPath;
    label = "completed";
  } else {
    process.stderr.write(`Error: Settlement '${id}' not found.\n`);
    return 1;
  }
  const lines = readFileSync(filePath, "utf-8").split("\n");
  console.log(`Settlement: ${id}  [${label}]`);
  const preview = lines.slice(0, 30);
  for (const line of preview) {
    console.log(line);
  }
  return 0;
}
