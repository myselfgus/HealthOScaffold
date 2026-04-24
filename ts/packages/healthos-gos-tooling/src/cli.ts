#!/usr/bin/env node
import { mkdir, readFile, writeFile } from 'node:fs/promises';
import { basename, resolve } from 'node:path';
import { compileGOSAuthoringSource, GOS_COMPILER_VERSION } from './compiler.js';

async function main(): Promise<void> {
  const [command, inputPath, outputPath] = process.argv.slice(2);

  if (!command || !inputPath || ((command === 'compile' || command === 'bundle') && !outputPath)) {
    console.error('Usage: healthos-gos <validate|compile|bundle> <input.yaml> [output.json|output-dir]');
    process.exit(1);
  }

  const source = await readFile(resolve(inputPath), 'utf8');
  const compiled = await compileGOSAuthoringSource(source, basename(inputPath));
  const success = compiled.report.structural_ok && compiled.report.cross_reference_ok;

  if (command === 'validate') {
    console.log(JSON.stringify({ input: basename(inputPath), report: compiled.report }, null, 2));
    process.exit(success ? 0 : 2);
  }

  if (command === 'compile') {
    if (!success) {
      console.error(JSON.stringify({ input: basename(inputPath), report: compiled.report }, null, 2));
      process.exit(2);
    }

    await writeFile(resolve(outputPath), JSON.stringify(compiled.spec, null, 2) + '\n', 'utf8');
    console.log(JSON.stringify({ input: basename(inputPath), output: basename(outputPath), report: compiled.report }, null, 2));
    return;
  }

  if (command === 'bundle') {
    if (!success) {
      console.error(JSON.stringify({ input: basename(inputPath), report: compiled.report }, null, 2));
      process.exit(2);
    }

    const bundleId = `${compiled.spec.spec_id}--${compiled.spec.version}--${compiled.sourceProvenance.source_sha256.slice(0, 12)}`;
    const bundleDir = resolve(outputPath, bundleId);
    await mkdir(bundleDir, { recursive: true });

    const manifest = {
      bundle_id: bundleId,
      spec_id: compiled.spec.spec_id,
      spec_version: compiled.spec.version,
      bundle_version: '1',
      compiler_version: GOS_COMPILER_VERSION,
      compiled_at: new Date().toISOString(),
      lifecycle_state: 'draft',
      compiler_report_path: 'compiler-report.json',
      spec_path: 'spec.json',
      source_provenance_path: 'source-provenance.json',
    };

    await writeFile(resolve(bundleDir, 'manifest.json'), JSON.stringify(manifest, null, 2) + '\n', 'utf8');
    await writeFile(resolve(bundleDir, 'spec.json'), JSON.stringify(compiled.spec, null, 2) + '\n', 'utf8');
    await writeFile(resolve(bundleDir, 'compiler-report.json'), JSON.stringify(compiled.report, null, 2) + '\n', 'utf8');
    await writeFile(resolve(bundleDir, 'source-provenance.json'), JSON.stringify(compiled.sourceProvenance, null, 2) + '\n', 'utf8');

    console.log(JSON.stringify({ input: basename(inputPath), bundle_id: bundleId, output_dir: bundleDir, report: compiled.report }, null, 2));
    return;
  }

  console.error(`Unknown command: ${command}`);
  process.exit(1);
}

void main();
