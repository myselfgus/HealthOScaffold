import { readFileSync, existsSync } from "node:fs";
import { join } from "node:path";
import { repoRoot } from "../repo-root.js";

export function runNext(): number {
  const trackerPath = join(
    repoRoot,
    "docs",
    "execution",
    "19-settler-model-task-tracker.md"
  );
  if (!existsSync(trackerPath)) {
    process.stderr.write(
      "Error: tracker not found at docs/execution/19-settler-model-task-tracker.md\n"
    );
    return 1;
  }
  const lines = readFileSync(trackerPath, "utf-8").split("\n");
  let i = 0;
  while (i < lines.length) {
    const line = lines[i];
    if (/^### ST-/.test(line)) {
      const header = line.replace(/^### /, "").trim();
      let isTodo = false;
      const goalLines: string[] = [];
      let inGoal = false;
      let j = i + 1;
      while (j < lines.length && !/^### ST-/.test(lines[j])) {
        const l = lines[j].trim();
        if (l === "Status: TODO.") {
          isTodo = true;
        }
        if (l === "Goal:") {
          inGoal = true;
        } else if (inGoal && l.startsWith("- ") && goalLines.length < 3) {
          goalLines.push(l);
        }
        j++;
      }
      if (isTodo) {
        console.log(`Next task: ${header}`);
        console.log("Status: TODO");
        if (goalLines.length > 0) {
          console.log("Goal summary:");
          for (const gl of goalLines) {
            console.log(`  ${gl}`);
          }
        }
        return 0;
      }
    }
    i++;
  }
  console.log("All tracked ST tasks are DONE.");
  return 0;
}
