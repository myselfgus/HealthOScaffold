#!/usr/bin/env node
import { runStewardCommand, type StewardCommand } from "./index.js";

const cmd = process.argv[2] as StewardCommand | undefined;

if (!cmd) {
  console.error(
    "Usage: healthos-steward <status|runtime|session|list|inspect|next|generate-prompt|validate-settlement|pr-draft|build-memory|validate-construction-system>"
  );
  process.exit(1);
}

const args = process.argv.slice(3);
process.exit(runStewardCommand(cmd, args));
