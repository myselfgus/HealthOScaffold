import { readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { listResolvedSettlements } from "../lib/settlement-resolver.js";

export function runList(args: string[]): number {
  const subtype = args[0];
  switch (subtype) {
    case "territories":
      return listTerritories();
    case "settlers":
      return listSettlers();
    case "settlements":
      return listSettlements();
    default:
      process.stderr.write(
        `Error: unknown record type '${subtype ?? ""}'. Use: territories | settlers | settlements\n`
      );
      return 1;
  }
}

function listTerritories(): number {
  const dir = join(repoRoot, ".healthos-settler", "territories");
  let files: string[];
  try {
    files = readdirSync(dir)
      .filter((f) => f.endsWith(".json") && f !== "territory.schema.json")
      .sort();
  } catch {
    process.stderr.write(
      `Error: territories directory not found at ${dir}\n`
    );
    return 1;
  }
  if (files.length === 0) {
    process.stderr.write(`Error: no Territory records found in ${dir}\n`);
    return 1;
  }
  for (const file of files) {
    let raw: string;
    try {
      raw = readFileSync(join(dir, file), "utf-8");
    } catch {
      process.stderr.write(`Warning: could not read ${file}, skipping\n`);
      continue;
    }
    let record: { id?: string; name?: string; maturity?: string };
    try {
      record = JSON.parse(raw) as { id?: string; name?: string; maturity?: string };
    } catch {
      process.stderr.write(`Warning: ${file} has malformed JSON, skipping\n`);
      continue;
    }
    console.log(
      `id: ${record.id ?? "(none)"}  name: ${record.name ?? "(none)"}  maturity: ${record.maturity ?? "(none)"}`
    );
  }
  return 0;
}

function listSettlers(): number {
  const readmePath = join(repoRoot, ".healthos-settler", "settlers", "README.md");
  let text: string;
  try {
    text = readFileSync(readmePath, "utf-8");
  } catch {
    process.stderr.write(`Error: settlers directory or README not found\n`);
    return 1;
  }
  const lines = text.split("\n");
  const dataRows = lines.filter((l) => l.trimStart().startsWith("| ["));
  if (dataRows.length === 0) {
    return listSettlersFallback();
  }
  for (const row of dataRows) {
    const parts = row.split("|").map((p) => p.trim());
    // parts: ["", "[id](link)", "`territory`", "description", "maturity", ""]
    const linkMatch = parts[1]?.match(/^\[([^\]]+)\]/);
    const profileId = linkMatch ? linkMatch[1] : (parts[1] ?? "");
    const territoryId = (parts[2] ?? "").replace(/`/g, "").trim();
    const maturity = (parts[4] ?? "").trim();
    console.log(
      `profile-id: ${profileId}  territory-id: ${territoryId}  maturity: ${maturity}`
    );
  }
  return 0;
}

function listSettlersFallback(): number {
  const dir = join(repoRoot, ".healthos-settler", "settlers");
  try {
    const files = readdirSync(dir)
      .filter((f) => f.endsWith(".md") && f !== "README.md")
      .sort();
    for (const f of files) {
      console.log(f.replace(/\.md$/, ""));
    }
  } catch {
    process.stderr.write(`Error: could not list settlers directory\n`);
    return 1;
  }
  return 0;
}

function listSettlements(): number {
  const { active, completed } = listResolvedSettlements();
  const all = [...active, ...completed];
  if (all.length === 0) {
    console.log("No settlement records found.");
    return 0;
  }
  for (const settlement of all) {
    console.log(
      `${settlement.fileId}  [${settlement.statusDir}] canonical-id: ${settlement.canonicalId}`
    );
  }
  return 0;
}
