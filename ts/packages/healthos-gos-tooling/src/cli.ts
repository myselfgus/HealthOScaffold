#!/usr/bin/env node
import { readFile, writeFile } from 'node:fs/promises';
import { basename, resolve } from 'node:path';
import { canonicalizeGOS, parseGOSAuthoringYAML } from './canonicalize.js';
import { validateGOS } from './validate.js';

async function main(): Promise<void> {
  const [command, inputPath, outputPath] = process.argv.slice(2);

  if (!command || !inputPath || (command === 'compile' && !outputPath)) {
    console.error('Usage: healthos-gos <validate|compile> <input.yaml> [output.json]');
    process.exit(1);
  }

  const source = await readFile(resolve(inputPath), 'utf8');
  const authoring = parseGOSAuthoringYAML(source);
  const { spec, report } = canonicalizeGOS(authoring);
  const validation = validateGOS(spec);

  if (command === 'validate') {
    console.log(JSON.stringify({ input: basename(inputPath), report, validation }, null, 2));
    process.exit(validation.ok ? 0 : 2);
  }

  if (command === 'compile') {
    if (!validation.ok) {
      console.error(JSON.stringify({ input: basename(inputPath), report, validation }, null, 2));
      process.exit(2);
    }

    await writeFile(resolve(outputPath), JSON.stringify(spec, null, 2) + '\n', 'utf8');
    console.log(JSON.stringify({ input: basename(inputPath), output: basename(outputPath), report, validation }, null, 2));
    return;
  }

  console.error(`Unknown command: ${command}`);
  process.exit(1);
}

void main();
