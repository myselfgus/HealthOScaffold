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
