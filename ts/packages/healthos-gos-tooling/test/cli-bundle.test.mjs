import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile } from 'node:fs/promises';
import { existsSync } from 'node:fs';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { spawnSync } from 'node:child_process';

test('bundle command emits canonical lifecycle artifacts', async () => {
  const sourcePath = resolve(process.cwd(), '../../../gos/specs/aaci.first-slice.gos.yaml');
  const outputDir = await mkdtemp(join(tmpdir(), 'healthos-gos-bundle-'));
  const cliPath = resolve(process.cwd(), 'dist/cli.js');

  const result = spawnSync(process.execPath, [cliPath, 'bundle', sourcePath, outputDir], {
    cwd: process.cwd(),
    encoding: 'utf8',
  });

  assert.equal(result.status, 0, result.stderr || result.stdout);

  const stdout = JSON.parse(result.stdout);
  const bundleDir = stdout.output_dir;

  assert.ok(bundleDir);
  assert.ok(existsSync(resolve(bundleDir, 'manifest.json')));
  assert.ok(existsSync(resolve(bundleDir, 'spec.json')));
  assert.ok(existsSync(resolve(bundleDir, 'compiler-report.json')));
  assert.ok(existsSync(resolve(bundleDir, 'source-provenance.json')));

  const manifest = JSON.parse(await readFile(resolve(bundleDir, 'manifest.json'), 'utf8'));
  assert.equal(manifest.spec_id, 'aaci.first-slice');
  assert.equal(manifest.lifecycle_state, 'draft');
  assert.equal(manifest.spec_path, 'spec.json');
  assert.equal(manifest.compiler_report_path, 'compiler-report.json');
  assert.equal(manifest.source_provenance_path, 'source-provenance.json');
});
