import type { GOSCanonicalSpec, GOSValidationResult } from './types.js';

function collectDeclaredRefs(spec: GOSCanonicalSpec): Set<string> {
  return new Set<string>([
    ...spec.signal_specs.map((item) => item.signal_id),
    ...spec.slot_specs.map((item) => item.slot_id),
    ...spec.derivation_specs.map((item) => item.derivation_id),
    ...spec.derivation_specs.flatMap((item) => item.outputs),
    ...spec.task_specs.map((item) => item.task_id),
    ...spec.task_specs.flatMap((item) => item.outputs),
    ...spec.draft_output_specs.map((item) => item.draft_output_id),
    ...spec.guard_specs.map((item) => item.guard_id),
    ...spec.deadline_specs.map((item) => item.deadline_id),
    ...spec.evidence_hook_specs.map((item) => item.hook_id),
    ...spec.human_gate_requirement_specs.map((item) => item.gate_requirement_id),
    ...spec.escalation_specs.map((item) => item.escalation_id),
    ...spec.scope_requirement_specs.map((item) => item.scope_requirement_id),
  ]);
}

export function validateGOS(spec: GOSCanonicalSpec): GOSValidationResult {
  const problems: Array<{ code: string; message: string; path?: string }> = [];
  const refs = collectDeclaredRefs(spec);
  const taskIds = new Set(spec.task_specs.map((task) => task.task_id));
  const gateTargetRefs = new Set(spec.human_gate_requirement_specs.map((item) => item.target_ref));
  const evidencePhases = new Set(spec.evidence_hook_specs.map((item) => item.phase));

  for (const slot of spec.slot_specs) {
    for (const signalId of slot.source_signal_ids ?? []) {
      if (!refs.has(signalId)) {
        problems.push({
          code: 'gos.ref.slot_source_missing',
          message: `Slot ${slot.slot_id} references missing signal/source id ${signalId}.`,
          path: `/slot_specs/${slot.slot_id}`,
        });
      }
    }
  }

  for (const derivation of spec.derivation_specs) {
    for (const input of derivation.inputs) {
      if (!refs.has(input)) {
        problems.push({
          code: 'gos.ref.derivation_input_missing',
          message: `Derivation ${derivation.derivation_id} references missing input ${input}.`,
          path: `/derivation_specs/${derivation.derivation_id}`,
        });
      }
    }
  }

  for (const task of spec.task_specs) {
    for (const input of task.inputs) {
      if (!refs.has(input)) {
        problems.push({
          code: 'gos.ref.task_input_missing',
          message: `Task ${task.task_id} references missing input ${input}.`,
          path: `/task_specs/${task.task_id}`,
        });
      }
    }
    for (const precondition of task.preconditions ?? []) {
      if (!refs.has(precondition)) {
        problems.push({
          code: 'gos.ref.task_precondition_missing',
          message: `Task ${task.task_id} references missing precondition ${precondition}.`,
          path: `/task_specs/${task.task_id}`,
        });
      }
    }
  }

  for (const binding of spec.tool_binding_specs) {
    if (!taskIds.has(binding.task_id)) {
      problems.push({
        code: 'gos.ref.tool_binding_task_missing',
        message: `Tool binding ${binding.binding_id} references missing task ${binding.task_id}.`,
        path: `/tool_binding_specs/${binding.binding_id}`,
      });
    }
  }

  for (const draft of spec.draft_output_specs) {
    for (const sourceTaskId of draft.source_task_ids ?? []) {
      if (!taskIds.has(sourceTaskId)) {
        problems.push({
          code: 'gos.ref.draft_source_task_missing',
          message: `Draft output ${draft.draft_output_id} references missing source task ${sourceTaskId}.`,
          path: `/draft_output_specs/${draft.draft_output_id}`,
        });
      }
    }
    if (draft.requires_gate && !gateTargetRefs.has(draft.draft_output_id)) {
      problems.push({
        code: 'gos.invariant.missing_gate_requirement',
        message: `Draft output ${draft.draft_output_id} requires gate but no matching human gate requirement target was declared.`,
        path: `/draft_output_specs/${draft.draft_output_id}`,
      });
    }
  }

  for (const deadline of spec.deadline_specs) {
    if (!refs.has(deadline.target_ref)) {
      problems.push({
        code: 'gos.ref.deadline_target_missing',
        message: `Deadline ${deadline.deadline_id} references missing target ${deadline.target_ref}.`,
        path: `/deadline_specs/${deadline.deadline_id}`,
      });
    }
  }

  for (const gate of spec.human_gate_requirement_specs) {
    if (!refs.has(gate.target_ref)) {
      problems.push({
        code: 'gos.ref.gate_target_missing',
        message: `Human gate requirement ${gate.gate_requirement_id} references missing target ${gate.target_ref}.`,
        path: `/human_gate_requirement_specs/${gate.gate_requirement_id}`,
      });
    }
  }

  for (const escalation of spec.escalation_specs) {
    if (!refs.has(escalation.trigger_ref)) {
      problems.push({
        code: 'gos.ref.escalation_trigger_missing',
        message: `Escalation ${escalation.escalation_id} references missing trigger ${escalation.trigger_ref}.`,
        path: `/escalation_specs/${escalation.escalation_id}`,
      });
    }
  }

  if (spec.task_specs.length > 0 && !evidencePhases.has('task')) {
    problems.push({
      code: 'gos.evidence.task_phase_missing',
      message: 'At least one task spec exists, but no evidence hook captures task-phase execution.',
      path: '/evidence_hook_specs',
    });
  }

  if (spec.draft_output_specs.length > 0 && !evidencePhases.has('draft_output')) {
    problems.push({
      code: 'gos.evidence.draft_output_phase_missing',
      message: 'At least one draft output spec exists, but no evidence hook captures draft-output phase execution.',
      path: '/evidence_hook_specs',
    });
  }

  return {
    ok: problems.length === 0,
    issues: problems,
  };
}
