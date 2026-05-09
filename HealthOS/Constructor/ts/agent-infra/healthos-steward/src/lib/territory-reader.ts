import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export interface TerritoryRecord {
  id: string;
  name: string;
  maturity: string;
  invariants: string[];
  canonicalDocs: string[];
  validationCommands: string[];
  knownGaps: string[];
}

interface RawTerritory {
  id?: string;
  name?: string;
  maturity?: string;
  invariants?: string[];
  canonicalDocs?: string[];
  validationCommands?: string[];
  knownGaps?: string[];
}

export function readTerritory(id: string): TerritoryRecord {
  const filePath = join(repoRoot, "HealthOS/Constructor/Settler", "territories", `${id}.json`);
  if (!existsSync(filePath)) {
    throw new Error(`Territory '${id}' not found`);
  }
  let raw: RawTerritory;
  try {
    raw = JSON.parse(readFileSync(filePath, "utf-8")) as RawTerritory;
  } catch {
    throw new Error(`Territory '${id}' has malformed JSON`);
  }
  return {
    id: raw.id ?? id,
    name: raw.name ?? "",
    maturity: raw.maturity ?? "",
    invariants: raw.invariants ?? [],
    canonicalDocs: raw.canonicalDocs ?? [],
    validationCommands: raw.validationCommands ?? [],
    knownGaps: raw.knownGaps ?? [],
  };
}
