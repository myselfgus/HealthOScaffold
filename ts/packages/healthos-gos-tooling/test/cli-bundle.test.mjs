import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
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

test('bundle command fails when cross-reference validation fails', async () => {
  const outputDir = await mkdtemp(join(tmpdir(), 'healthos-gos-bundle-fail-'));
  const invalidSourcePath = resolve(outputDir, 'invalid-cross-reference.yaml');
  const invalidSource = `spec_id: invalid.bundle.cross.reference
spec_family: workflow
version: 0.1.0
metadata:
  title: Invalid Cross Reference
  status: draft
  authoring_form: yaml
signal_specs: []
slot_specs: []
derivation_specs: []
task_specs: []
tool_binding_specs: []
draft_output_specs:
  - draft_output_id: soap
    draft_kind: soap
    status: draft_only
    requires_gate: true
guard_specs: []
deadline_specs: []
evidence_hook_specs:
  - hook_id: draft-evidence
    phase: draft_output
    capture: [provenance]
human_gate_requirement_specs:
  - gate_requirement_id: gate-1
    target_ref: missing-draft
    review_type: professional_approval
escalation_specs: []
scope_requirement_specs: []
`;
  await writeFile(invalidSourcePath, invalidSource, 'utf8');

  const cliPath = resolve(process.cwd(), 'dist/cli.js');
  const result = spawnSync(process.execPath, [cliPath, 'bundle', invalidSourcePath, outputDir], {
    cwd: process.cwd(),
    encoding: 'utf8',
  });

  assert.equal(result.status, 2);
  const stderrPayload = JSON.parse(result.stderr);
  assert.equal(stderrPayload.report.cross_reference_ok, false);
});
