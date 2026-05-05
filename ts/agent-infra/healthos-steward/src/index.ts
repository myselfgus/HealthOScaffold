import { runList } from "./commands/list.js";
import { runInspect } from "./commands/inspect.js";
import { runNext } from "./commands/next.js";
import { runGeneratePrompt } from "./commands/generate-prompt.js";
import { runValidateSettlement } from "./commands/validate-settlement.js";
import { runPrDraft } from "./commands/pr-draft.js";
import { runBuildMemory } from "./commands/build-memory.js";

export type StewardCommand =
  | "status"
  | "runtime"
  | "session"
  | "list"
  | "inspect"
  | "next"
  | "generate-prompt"
  | "validate-settlement"
  | "pr-draft"
  | "build-memory";

export function runStewardCommand(
  command: StewardCommand,
  args: string[]
): number {
  switch (command) {
    case "status":
      console.log("healthos-steward scaffold baseline: status available");
      return 0;
    case "runtime":
      console.log("healthos-steward scaffold baseline: runtime available");
      return 0;
    case "session":
      console.log("healthos-steward scaffold baseline: session available");
      return 0;
    case "list":
      return runList(args);
    case "inspect":
      return runInspect(args);
    case "next":
      return runNext();
    case "generate-prompt":
      return runGeneratePrompt(args);
    case "validate-settlement":
      return runValidateSettlement(args);
    case "pr-draft":
      return runPrDraft(args);
    case "build-memory":
      return runBuildMemory(args);
    default:
      return 1;
  }
}

// Lib exports for forge-mcp consumption
export type { TrackerTask } from "./lib/tracker-reader.js";
export { readAllTrackerTasks } from "./lib/tracker-reader.js";
export type { TerritoryRecord } from "./lib/territory-reader.js";
export { readTerritory } from "./lib/territory-reader.js";
export type { SettlerRecord } from "./lib/settler-reader.js";
export { readSettler } from "./lib/settler-reader.js";
export type { SettlementRecord } from "./lib/settlement-parser.js";
export { parseSettlement } from "./lib/settlement-parser.js";
export { repoRoot } from "./repo-root.js";
export { assemblePromptSpec } from "./lib/prompt-assembler.js";
export type { AssemblyInput } from "./lib/prompt-assembler.js";
export {
  buildIndex,
  buildConstructionStatus,
  buildTerritoryIndex,
  buildSettlerIndex,
  buildSettlementIndex,
  buildHandoffSnapshot,
} from "./lib/memory-builder.js";
export type {
  CriterionResult,
  FileCheckResult,
  ValidationEvidence,
} from "./lib/validation-report-builder.js";
export { buildValidationReport } from "./lib/validation-report-builder.js";
