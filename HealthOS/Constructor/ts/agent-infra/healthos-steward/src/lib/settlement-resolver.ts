import { existsSync, readFileSync, readdirSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";
import { parseSettlement, type SettlementRecord } from "./settlement-parser.js";

export interface ResolvedSettlement {
  fileId: string;
  canonicalId: string;
  statusDir: "active" | "completed";
  path: string;
  record: SettlementRecord;
}

function settlementDirs(): Array<"active" | "completed"> {
  return ["active", "completed"];
}

function readSettlementFile(
  statusDir: "active" | "completed",
  fileId: string
): ResolvedSettlement {
  const path = join(
    repoRoot,
    "HealthOS/Constructor/Steward",
    "settlements",
    statusDir,
    `${fileId}.md`
  );
  const raw = readFileSync(path, "utf-8");
  const record = parseSettlement(raw);
  return { fileId, canonicalId: record.id, statusDir, path, record };
}

export function resolveSettlement(id: string): ResolvedSettlement | null {
  for (const statusDir of settlementDirs()) {
    const directPath = join(
      repoRoot,
      "HealthOS/Constructor/Steward",
      "settlements",
      statusDir,
      `${id}.md`
    );
    if (existsSync(directPath)) {
      return readSettlementFile(statusDir, id);
    }
  }

  for (const statusDir of settlementDirs()) {
    const dir = join(repoRoot, "HealthOS/Constructor/Steward", "settlements", statusDir);
    if (!existsSync(dir)) continue;
    const files = readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
    for (const file of files) {
      const fileId = file.replace(/\.md$/, "");
      try {
        const resolved = readSettlementFile(statusDir, fileId);
        if (resolved.canonicalId === id) return resolved;
      } catch {
        continue;
      }
    }
  }

  return null;
}

export function listResolvedSettlements(): {
  active: ResolvedSettlement[];
  completed: ResolvedSettlement[];
} {
  const active: ResolvedSettlement[] = [];
  const completed: ResolvedSettlement[] = [];
  for (const statusDir of settlementDirs()) {
    const dir = join(repoRoot, "HealthOS/Constructor/Steward", "settlements", statusDir);
    if (!existsSync(dir)) continue;
    const files = readdirSync(dir).filter((f) => f.endsWith(".md")).sort();
    for (const file of files) {
      const fileId = file.replace(/\.md$/, "");
      try {
        const resolved = readSettlementFile(statusDir, fileId);
        if (statusDir === "active") active.push(resolved);
        else completed.push(resolved);
      } catch {
        continue;
      }
    }
  }
  return { active, completed };
}
