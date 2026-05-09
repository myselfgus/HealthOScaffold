import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export interface SettlerRecord {
  id: string;
  territoryId: string;
  maturity: string;
  invariants: string[];
  forbiddenMoves: string[];
}

type SettlerSection =
  | "territory-id"
  | "profile-id"
  | "maturity"
  | "invariants"
  | "forbidden-moves"
  | "other"
  | null;

export function readSettler(id: string): SettlerRecord {
  const filePath = join(repoRoot, "HealthOS/Constructor/Settler", "settlers", `${id}.md`);
  if (!existsSync(filePath)) {
    throw new Error(`Settler '${id}' not found`);
  }
  const lines = readFileSync(filePath, "utf-8").split("\n");

  let territoryId = "";
  let maturity = "";
  const invariants: string[] = [];
  const forbiddenMoves: string[] = [];

  let currentSection: SettlerSection = null;

  for (const line of lines) {
    const trimmed = line.trim();

    // Section header detection
    if (trimmed.startsWith("## ")) {
      const sectionName = trimmed.slice(3).toLowerCase().trim();
      if (sectionName === "territory-id") currentSection = "territory-id";
      else if (sectionName === "profile-id") currentSection = "profile-id";
      else if (sectionName === "maturity") currentSection = "maturity";
      else if (sectionName === "invariants") currentSection = "invariants";
      else if (sectionName === "forbidden-moves") currentSection = "forbidden-moves";
      else currentSection = "other";
      continue;
    }

    if (!currentSection || trimmed === "" || trimmed.startsWith("<!--")) continue;

    if (currentSection === "territory-id" && !territoryId) {
      const m = trimmed.match(/^`([^`]+)`/);
      if (m) territoryId = m[1];
      continue;
    }

    if (currentSection === "maturity" && !maturity) {
      const m = trimmed.match(/^`([^`]+)`/);
      if (m) maturity = m[1];
      continue;
    }

    if (currentSection === "invariants") {
      const numbered = trimmed.match(/^\d+\.\s+(.+)$/);
      if (numbered) { invariants.push(numbered[1].trim()); continue; }
      const bullet = trimmed.match(/^-\s+(.+)$/);
      if (bullet) { invariants.push(bullet[1].trim()); continue; }
    }

    if (currentSection === "forbidden-moves") {
      const numbered = trimmed.match(/^\d+\.\s+(.+)$/);
      if (numbered) { forbiddenMoves.push(numbered[1].trim()); continue; }
      const bullet = trimmed.match(/^-\s+(.+)$/);
      if (bullet) { forbiddenMoves.push(bullet[1].trim()); continue; }
    }
  }

  return { id, territoryId, maturity, invariants, forbiddenMoves };
}
