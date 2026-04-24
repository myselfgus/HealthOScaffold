import test from 'node:test';
import assert from 'node:assert/strict';
import { mkdtemp, readFile, writeFile } from 'node:fs/promises';
import { tmpdir } from 'node:os';
import { resolve, join } from 'node:path';
import { spawnSync } from 'node:child_process';

function runCli(args) {
  const cliPath = resolve(process.cwd(), 'dist/cli.js');
  return spawnSync(process.execPath, [cliPath, ...args], {
    cwd: process.cwd(),
    encoding: 'utf8',
  });
}

test('validate command passes for canonical first-slice authoring spec', () => {
  const sourcePath = resolve(process.cwd(), '../../../gos/specs/aaci.first-slice.gos.yaml');
  const result = runCli(['validate', sourcePath]);

  assert.equal(result.status, 0, result.stderr || result.stdout);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.report.structural_ok, true);
  assert.equal(payload.report.cross_reference_ok, true);
});

test('compile command emits compiled spec for canonical first-slice authoring spec', async () => {
  const sourcePath = resolve(process.cwd(), '../../../gos/specs/aaci.first-slice.gos.yaml');
  const outputDir = await mkdtemp(join(tmpdir(), 'healthos-gos-compile-'));
  const outputPath = resolve(outputDir, 'compiled-spec.json');
  const result = runCli(['compile', sourcePath, outputPath]);

  assert.equal(result.status, 0, result.stderr || result.stdout);

  const compiledSpec = JSON.parse(await readFile(outputPath, 'utf8'));
  assert.equal(compiledSpec.spec_id, 'aaci.first-slice');
  assert.equal(compiledSpec.metadata.compiled_form, 'json');
});

test('validate command fails when draft output exists without draft-output evidence hook', async () => {
  const outputDir = await mkdtemp(join(tmpdir(), 'healthos-gos-validate-fail-'));
  const invalidSourcePath = resolve(outputDir, 'invalid-missing-draft-evidence.yaml');
  const invalidSource = `spec_id: invalid.missing.draft.evidence
spec_family: workflow
version: 0.1.0
metadata:
  title: Invalid Missing Draft Evidence
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
guard_specs: []
deadline_specs: []
evidence_hook_specs:
  - hook_id: input-evidence
    phase: input
    capture: [provenance]
human_gate_requirement_specs: []
escalation_specs: []
scope_requirement_specs: []
`;
  await writeFile(invalidSourcePath, invalidSource, 'utf8');
  const result = runCli(['validate', invalidSourcePath]);

  assert.equal(result.status, 2);
  const payload = JSON.parse(result.stdout);
  assert.equal(payload.report.cross_reference_ok, false);
  assert.ok((payload.report.cross_reference_issues ?? []).some((item) => item.code === 'gos.evidence.draft_output_phase_missing'));
});
