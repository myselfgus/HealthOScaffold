#!/usr/bin/env node
import { runStewardCLI } from './steward.js';

const args = process.argv.slice(2);
const exitCode = await runStewardCLI(args);
process.exit(exitCode);
