import test from 'node:test';
import assert from 'node:assert/strict';
import { readFile } from 'node:fs/promises';
import { resolve } from 'node:path';
import { compileGOSAuthoringSource } from '../dist/compiler.js';

test('compiles canonical first-slice authoring spec', async () => {
  const sourcePath = resolve(process.cwd(), '../../../gos/specs/aaci.first-slice.gos.yaml');
  const source = await readFile(sourcePath, 'utf8');

  const compiled = await compileGOSAuthoringSource(source, 'aaci.first-slice.gos.yaml');

  assert.equal(compiled.spec.spec_id, 'aaci.first-slice');
  assert.equal(compiled.report.parse_ok, true);
  assert.equal(compiled.report.structural_ok, true);
  assert.equal(compiled.report.cross_reference_ok, true);
  assert.ok(compiled.sourceProvenance.source_sha256.length > 10);
});

test('fails cross-reference validation when gate target does not exist', async () => {
  const source = `spec_id: invalid.gos
spec_family: workflow
version: 0.1.0
metadata:
  title: Invalid
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
  - gate_requirement_id: missing-target
    target_ref: unknown_draft
    review_type: professional_approval
escalation_specs: []
scope_requirement_specs: []
`;

  const compiled = await compileGOSAuthoringSource(source, 'invalid.yaml');

  assert.equal(compiled.report.structural_ok, true);
  assert.equal(compiled.report.cross_reference_ok, false);
  assert.ok((compiled.report.cross_reference_issues ?? []).length > 0);
});

test('fails invariant when draft requires gate without matching human gate requirement', async () => {
  const source = `spec_id: invalid.gate.requirement
spec_family: workflow
version: 0.1.0
metadata:
  title: Invalid Gate Requirement
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
human_gate_requirement_specs: []
escalation_specs: []
scope_requirement_specs: []
`;

  const compiled = await compileGOSAuthoringSource(source, 'invalid-gate-requirement.yaml');
  const issues = compiled.report.cross_reference_issues ?? [];

  assert.equal(compiled.report.structural_ok, true);
  assert.equal(compiled.report.cross_reference_ok, false);
  assert.ok(issues.some((item) => item.code === 'gos.invariant.missing_gate_requirement'));
});

test('fails evidence-hook completeness when tasks exist without task evidence hook', async () => {
  const source = `spec_id: invalid.missing.task.evidence
spec_family: workflow
version: 0.1.0
metadata:
  title: Invalid Missing Task Evidence
  status: draft
  authoring_form: yaml
signal_specs: []
slot_specs: []
derivation_specs: []
task_specs:
  - task_id: extract
    task_class: extract
    inputs: []
    outputs: [output_a]
tool_binding_specs: []
draft_output_specs: []
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

  const compiled = await compileGOSAuthoringSource(source, 'invalid-missing-task-evidence.yaml');
  const issues = compiled.report.cross_reference_issues ?? [];

  assert.equal(compiled.report.cross_reference_ok, false);
  assert.ok(issues.some((item) => item.code === 'gos.evidence.task_phase_missing'));
});
