import { runList } from "./commands/list.js";
import { runInspect } from "./commands/inspect.js";
import { runNext } from "./commands/next.js";

export type StewardCommand =
  | "status"
  | "runtime"
  | "session"
  | "list"
  | "inspect"
  | "next";

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
    default:
      return 1;
  }
}
