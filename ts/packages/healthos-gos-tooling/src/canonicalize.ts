import { parseDocument } from 'yaml';
import type {
  GOSAuthoringDocument,
  GOSCanonicalSpec,
  GOSCompilerReport,
  GOSCompilerWarning,
} from './types.js';

function normalizeStringArray(values?: string[]): string[] | undefined {
  if (!values) return undefined;
  const normalized = values.map((value) => value.trim()).filter(Boolean);
  return normalized.length > 0 ? normalized : undefined;
}

function sortById<T>(items: T[], key: keyof T): T[] {
  return [...items].sort((left, right) => String(left[key]).localeCompare(String(right[key])));
}

export function parseGOSAuthoringYAML(source: string): GOSAuthoringDocument {
  const document = parseDocument(source);
  const parsed = document.toJS();
  if (!parsed || typeof parsed !== 'object' || Array.isArray(parsed)) {
    throw new Error('GOS authoring document must parse into an object.');
  }
  return parsed as GOSAuthoringDocument;
}

export function canonicalizeGOS(authoring: GOSAuthoringDocument): { spec: GOSCanonicalSpec; report: GOSCompilerReport } {
  const warnings: GOSCompilerWarning[] = [];

  const spec: GOSCanonicalSpec = {
    ...authoring,
    metadata: {
      title: authoring.metadata.title.trim(),
      description: authoring.metadata.description?.trim(),
      status: authoring.metadata.status,
      authoring_form: authoring.metadata.authoring_form,
      compiled_form: 'json',
      tags: normalizeStringArray(authoring.metadata.tags),
      jurisdictions: normalizeStringArray(authoring.metadata.jurisdictions),
      service_types: normalizeStringArray(authoring.metadata.service_types),
      runtime_modes: normalizeStringArray(authoring.metadata.runtime_modes),
      source_references: authoring.metadata.source_references?.map((reference) => ({
        ...reference,
        kind: reference.kind.trim(),
        reference: reference.reference.trim(),
        version: reference.version?.trim(),
        effective_from: reference.effective_from,
        effective_to: reference.effective_to,
      })),
    },
    spec_id: authoring.spec_id.trim(),
    version: authoring.version.trim(),
    signal_specs: sortById(authoring.signal_specs ?? [], 'signal_id'),
    slot_specs: sortById(authoring.slot_specs ?? [], 'slot_id'),
    derivation_specs: sortById(authoring.derivation_specs ?? [], 'derivation_id'),
    task_specs: sortById(authoring.task_specs ?? [], 'task_id'),
    tool_binding_specs: sortById(authoring.tool_binding_specs ?? [], 'binding_id'),
    draft_output_specs: sortById(authoring.draft_output_specs ?? [], 'draft_output_id'),
    guard_specs: sortById(authoring.guard_specs ?? [], 'guard_id'),
    deadline_specs: sortById(authoring.deadline_specs ?? [], 'deadline_id'),
    evidence_hook_specs: sortById(authoring.evidence_hook_specs ?? [], 'hook_id'),
    human_gate_requirement_specs: sortById(authoring.human_gate_requirement_specs ?? [], 'gate_requirement_id'),
    escalation_specs: sortById(authoring.escalation_specs ?? [], 'escalation_id'),
    scope_requirement_specs: sortById(authoring.scope_requirement_specs ?? [], 'scope_requirement_id'),
  };

  if (spec.draft_output_specs.length === 0) {
    warnings.push({
      code: 'gos.no_draft_outputs',
      message: 'No draft output specs are declared. This may be valid, but many operational specs prepare at least one draft or structured output.',
    });
  }

  if (spec.human_gate_requirement_specs.length === 0 && spec.draft_output_specs.some((draft) => draft.requires_gate)) {
    warnings.push({
      code: 'gos.missing_human_gate_requirement',
      message: 'At least one draft output marks requires_gate=true, but no explicit human gate requirement spec was declared.',
    });
  }

  return {
    spec,
    report: {
      parse_ok: true,
      structural_ok: true,
      cross_reference_ok: false,
      warnings,
    },
  };
}
