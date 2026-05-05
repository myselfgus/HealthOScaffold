import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export interface TrackerTask {
  id: string;
  title: string;
  status: string;
}

export function readAllTrackerTasks(): TrackerTask[] {
  const trackerPath = join(
    repoRoot,
    "docs",
    "execution",
    "19-settler-model-task-tracker.md"
  );
  if (!existsSync(trackerPath)) {
    throw new Error(
      "Tracker not found at docs/execution/19-settler-model-task-tracker.md"
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
      let status = "UNKNOWN";
      let j = i + 1;
      while (j < lines.length && !/^### /.test(lines[j])) {
        const l = lines[j].trim();
        if (l.startsWith("Status: DONE")) {
          status = "DONE";
          break;
        } else if (l.startsWith("Status: IN-PROGRESS")) {
          status = "IN-PROGRESS";
          break;
        } else if (l.startsWith("Status: BLOCKED")) {
          status = "BLOCKED";
          break;
        } else if (l.startsWith("Status: TODO")) {
          status = "TODO";
          break;
        }
        j++;
      }
      tasks.push({ id, title, status });
    }
    i++;
  }
  return tasks;
}
