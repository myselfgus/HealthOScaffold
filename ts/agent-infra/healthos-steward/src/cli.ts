#!/usr/bin/env node
import { runStewardCommand, type StewardCommand } from "./index.js";

const cmd = process.argv[2] as StewardCommand | undefined;

if (!cmd) {
  console.error("Usage: healthos-steward <status|runtime|session>");
  process.exit(1);
}

process.exit(runStewardCommand(cmd));
