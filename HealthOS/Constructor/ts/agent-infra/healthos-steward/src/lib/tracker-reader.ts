import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export interface TrackerTask {
  id: string;
  title: string;
  status: string;
  rawStatus: string;
}

function normalizeStatus(rawStatus: string): string {
  const upper = rawStatus.toUpperCase();
  if (upper.includes("NEEDS-REVIEW") && upper.includes("BLOCKED AS WRITTEN")) {
    return "BLOCKED_AS_WRITTEN";
  }
  if (upper.includes("NEEDS-REVIEW")) return "NEEDS-REVIEW";
  if (upper.includes("IN-PROGRESS")) return "IN-PROGRESS";
  if (upper.includes("BLOCKED")) return "BLOCKED";
  if (upper.includes("TODO")) return "TODO";
  if (upper.includes("DONE")) return "DONE";
  return "UNKNOWN";
}

export function readAllTrackerTasks(): TrackerTask[] {
  const trackerPath = join(
    repoRoot,
    "HealthOS",
    "Shared",
    "docs",
    "execution",
    "19-settler-model-task-tracker.md"
  );
  if (!existsSync(trackerPath)) {
    throw new Error(
      "Tracker not found at HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md"
    );
  }
  const lines = readFileSync(trackerPath, "utf-8").split("\n");
  const tasks: TrackerTask[] = [];
  let i = 0;
  while (i < lines.length) {
    const headerMatch = lines[i].match(/^### (ST-\d+) — (.+)$/);
    if (headerMatch) {
      const id = headerMatch[1];
      const title = headerMatch[2].trim();
      let rawStatus = "";
      let status = "UNKNOWN";
      let j = i + 1;
      while (j < lines.length && !/^### /.test(lines[j])) {
        const l = lines[j].trim();
        if (l.startsWith("Status:")) {
          rawStatus = l.replace(/^Status:\s*/, "").trim();
          status = normalizeStatus(rawStatus);
          break;
        }
        j++;
      }
      tasks.push({ id, title, status, rawStatus });
    }
    i++;
  }
  return tasks;
}
