import { readFileSync, writeFileSync, mkdirSync, readdirSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { readTerritory, type TerritoryRecord } from "../lib/territory-reader.js";
import { type SettlerRecord } from "../lib/settler-reader.js";
import { parseSettlement } from "../lib/settlement-parser.js";
import { readAllTrackerTasks, type TrackerTask } from "../lib/tracker-reader.js";
import {
  buildIndex,
  buildConstructionStatus,
  buildTerritoryIndex,
  buildSettlerIndex,
  buildSettlementIndex,
  buildHandoffSnapshot,
} from "../lib/memory-builder.js";

export function runBuildMemory(_args: string[]): number {
  const derivedDir = join(repoRoot, "HealthOS/Constructor/Steward", "memory", "derived");
  try {
    mkdirSync(derivedDir, { recursive: true });
  } catch (e: unknown) {
    process.stderr.write(
      `Error: could not create derived memory directory: ${e instanceof Error ? e.message : String(e)}\n`
    );
    return 1;
  }

  const date = new Date().toISOString().slice(0, 10);
  const results: string[] = [];
  const warnings: string[] = [];

  // Step 1: construction-status.md
  let tasks: TrackerTask[] = [];
  try {
    tasks = readAllTrackerTasks();
    const content = buildConstructionStatus(tasks, date);
    writeFileSync(join(derivedDir, "construction-status.md"), content, "utf-8");
    results.push("construction-status.md");
  } catch (e: unknown) {
    warnings.push(
      `construction-status.md: ${e instanceof Error ? e.message : String(e)}`
    );
  }

  // Step 2: territory-index.md
  try {
    const terrDir = join(repoRoot, "HealthOS/Constructor/Settler", "territories");
    const files = readdirSync(terrDir)
      .filter((f) => f.endsWith(".json") && f !== "territory.schema.json")
      .sort();
    const territories: TerritoryRecord[] = [];
    for (const file of files) {
      const id = file.replace(/\.json$/, "");
      try {
        territories.push(readTerritory(id));
      } catch (e: unknown) {
        warnings.push(
          `territory ${id}: ${e instanceof Error ? e.message : String(e)}`
        );
      }
    }
    const content = buildTerritoryIndex(territories, date);
    writeFileSync(join(derivedDir, "territory-index.md"), content, "utf-8");
    results.push("territory-index.md");
  } catch (e: unknown) {
    warnings.push(
      `territory-index.md: ${e instanceof Error ? e.message : String(e)}`
    );
  }

  // Step 3: settler-index.md
  try {
    const readmePath = join(repoRoot, "HealthOS/Constructor/Settler", "settlers", "README.md");
    const text = readFileSync(readmePath, "utf-8");
    const lines = text.split("\n");
    const dataRows = lines.filter((l) => l.trimStart().startsWith("| ["));
    const settlers: SettlerRecord[] = dataRows.map((row) => {
      const parts = row.split("|").map((p) => p.trim());
      const linkMatch = parts[1]?.match(/^\[([^\]]+)\]/);
      const id = linkMatch ? linkMatch[1] : (parts[1] ?? "");
      const territoryId = (parts[2] ?? "").replace(/`/g, "").trim();
      const maturity = (parts[4] ?? "").trim();
      return { id, territoryId, maturity, invariants: [], forbiddenMoves: [] };
    });
    const content = buildSettlerIndex(settlers, date);
    writeFileSync(join(derivedDir, "settler-index.md"), content, "utf-8");
    results.push("settler-index.md");
  } catch (e: unknown) {
    warnings.push(
      `settler-index.md: ${e instanceof Error ? e.message : String(e)}`
    );
  }

  // Step 4: settlement-index.md
  try {
    const baseDir = join(repoRoot, "HealthOS/Constructor/Steward", "settlements");
    const activeEntries: Array<{ id: string; title: string; status: string }> = [];
    const completedEntries: Array<{ id: string; title: string; status: string }> = [];
    for (const [subdir, arr] of [
      ["active", activeEntries],
      ["completed", completedEntries],
    ] as [string, typeof activeEntries][]) {
      const dir = join(baseDir, subdir);
      if (!existsSync(dir)) continue;
      let files: string[];
      try {
        files = readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
      } catch {
        continue;
      }
      for (const file of files) {
        const stem = file.replace(/\.md$/, "");
        try {
          const raw = readFileSync(join(dir, file), "utf-8");
          const rec = parseSettlement(raw);
          arr.push({ id: rec.id, title: rec.title, status: rec.status });
        } catch {
          warnings.push(`settlement ${stem}: parse error, using filename as id`);
          arr.push({ id: stem, title: stem, status: "UNKNOWN" });
        }
      }
    }
    const content = buildSettlementIndex(activeEntries, completedEntries, date);
    writeFileSync(join(derivedDir, "settlement-index.md"), content, "utf-8");
    results.push("settlement-index.md");
  } catch (e: unknown) {
    warnings.push(
      `settlement-index.md: ${e instanceof Error ? e.message : String(e)}`
    );
  }

  // Step 5: handoff-snapshot.md
  try {
    let handoffRaw = "(handoff doc not found)";
    const handoffPath = join(repoRoot, "HealthOS", "Shared", "docs", "execution", "12-next-agent-handoff.md");
    if (existsSync(handoffPath)) {
      handoffRaw = readFileSync(handoffPath, "utf-8");
    } else {
      warnings.push("handoff-snapshot.md: handoff doc not found, using placeholder");
    }
    const content = buildHandoffSnapshot(handoffRaw, tasks, date);
    writeFileSync(join(derivedDir, "handoff-snapshot.md"), content, "utf-8");
    results.push("handoff-snapshot.md");
  } catch (e: unknown) {
    warnings.push(
      `handoff-snapshot.md: ${e instanceof Error ? e.message : String(e)}`
    );
  }

  // Step 6: INDEX.md (last)
  let indexContent = buildIndex(results, date);
  if (warnings.length > 0) {
    indexContent += "\n## Warnings\n\n";
    for (const w of warnings) {
      indexContent += `- ${w}\n`;
    }
  }
  writeFileSync(join(derivedDir, "INDEX.md"), indexContent, "utf-8");

  console.log(
    `Built ${results.length + 1} derived memory files to HealthOS/Constructor/Steward/memory/derived/`
  );
  console.log(
    `Files: INDEX.md, ${results.join(", ")}`
  );
  if (warnings.length > 0) {
    console.log(`Warnings (${warnings.length}):`);
    for (const w of warnings) {
      console.log(`  - ${w}`);
    }
  }
  return 0;
}
