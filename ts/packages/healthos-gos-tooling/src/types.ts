export type GOSSpecFamily =
  | 'workflow'
  | 'policy'
  | 'document'
  | 'service_rule'
  | 'operational_bundle';

export type GOSStatus = 'draft' | 'reviewed' | 'active' | 'deprecated';

export type StringMap = Record<string, string>;

export interface GOSSourceReference {
  kind: string;
  reference: string;
  version?: string;
  effective_from?: string;
  effective_to?: string;
}

export interface GOSMetadata {
  title: string;
  description?: string;
  status: GOSStatus;
  authoring_form: 'yaml' | 'json' | 'other_declarative';
  compiled_form?: 'json';
  notes?: string;
  source_references?: GOSSourceReference[];
  jurisdictions?: string[];
  service_types?: string[];
  runtime_modes?: string[];
  tags?: string[];
}

export interface GOSSignalSpec {
  signal_id: string;
  kind: string;
  source_class: 'transcript' | 'audio_ref' | 'device_stream' | 'record_ref' | 'service_event' | 'user_input' | 'other';
  required?: boolean;
  notes?: string;
  metadata?: StringMap;
}

export interface GOSSlotSpec {
  slot_id: string;
  data_type: string;
  required: boolean;
  source_signal_ids?: string[];
  fallback_behavior?: 'ask' | 'reuse_recent' | 'degrade_honestly' | 'skip_if_optional';
  metadata?: StringMap;
}

export interface GOSDerivationSpec {
  derivation_id: string;
  inputs: string[];
  outputs: string[];
  method_kind: 'deterministic' | 'bounded_reasoning' | 'calculated' | 'classifier';
  requires_human_review?: boolean;
  metadata?: StringMap;
}

export interface GOSTaskSpec {
  task_id: string;
  task_class: 'extract' | 'derive' | 'retrieve' | 'compose' | 'structure' | 'summarize' | 'admin_action' | 'prepare_draft' | 'other';
  inputs: string[];
  outputs: string[];
  preconditions?: string[];
  degraded_behavior?: 'return_partial' | 'return_empty' | 'escalate' | 'stop';
  metadata?: StringMap;
}

export interface GOSToolBindingSpec {
  binding_id: string;
  task_id: string;
  tool_class: 'language_model' | 'speech_to_text' | 'retrieval' | 'formatter' | 'storage' | 'timer' | 'other';
  binding_strategy?: 'required' | 'preferred' | 'fallback' | 'runtime_selected';
  metadata?: StringMap;
}

export interface GOSDraftOutputSpec {
  draft_output_id: string;
  draft_kind: string;
  status: 'draft_only';
  source_task_ids?: string[];
  requires_gate?: boolean;
  metadata?: StringMap;
}

export interface GOSGuardSpec {
  guard_id: string;
  guard_class: 'predictive' | 'consistency' | 'quality' | 'risk' | 'escalation_gate';
  trigger: string;
  action?: 'suggest' | 'mark_degraded' | 'escalate' | 'stop';
  metadata?: StringMap;
}

export interface GOSDeadlineSpec {
  deadline_id: string;
  target_ref: string;
  target_duration: string;
  miss_behavior?: 'escalate' | 'mark_degraded' | 'notify' | 'stop';
  metadata?: StringMap;
}

export interface GOSEvidenceHookSpec {
  hook_id: string;
  phase: 'input' | 'derivation' | 'task' | 'draft_output' | 'gate_needed' | 'escalation';
  capture: Array<'provenance' | 'audit_entry' | 'input_hash' | 'output_hash' | 'runtime_state' | 'summary'>;
  metadata?: StringMap;
}

export interface GOSHumanGateRequirementSpec {
  gate_requirement_id: string;
  target_ref: string;
  review_type: string;
  required_role?: string;
  metadata?: StringMap;
}

export interface GOSEscalationSpec {
  escalation_id: string;
  trigger_ref: string;
  escalation_action: 'notify_human' | 'raise_priority' | 'mark_degraded' | 'stop_task_chain';
  metadata?: StringMap;
}

export interface GOSScopeRequirementSpec {
  scope_requirement_id: string;
  scope_kind: 'consent' | 'habilitation' | 'service_context' | 'finality' | 'session_context' | 'actor_role';
  expectation: string;
  failure_disposition?: 'governed_deny' | 'operational_failure' | 'degraded';
  metadata?: StringMap;
}

export interface GOSAuthoringDocument {
  spec_id: string;
  spec_family: GOSSpecFamily;
  version: string;
  metadata: GOSMetadata;
  signal_specs: GOSSignalSpec[];
  slot_specs: GOSSlotSpec[];
  derivation_specs: GOSDerivationSpec[];
  task_specs: GOSTaskSpec[];
  tool_binding_specs: GOSToolBindingSpec[];
  draft_output_specs: GOSDraftOutputSpec[];
  guard_specs: GOSGuardSpec[];
  deadline_specs: GOSDeadlineSpec[];
  evidence_hook_specs: GOSEvidenceHookSpec[];
  human_gate_requirement_specs: GOSHumanGateRequirementSpec[];
  escalation_specs: GOSEscalationSpec[];
  scope_requirement_specs: GOSScopeRequirementSpec[];
}

export interface GOSCanonicalSpec extends GOSAuthoringDocument {
  metadata: GOSMetadata & { compiled_form: 'json' };
}

export interface GOSValidationIssue {
  code: string;
  message: string;
  path?: string;
}

export interface GOSCompilerWarning {
  code: string;
  message: string;
}

export interface GOSSourceProvenance {
  source_sha256: string;
  source_reference?: string;
}

export interface GOSCompilerReport {
  parse_ok: boolean;
  structural_ok: boolean;
  cross_reference_ok: boolean;
  warnings: GOSCompilerWarning[];
  structural_issues?: GOSValidationIssue[];
  cross_reference_issues?: GOSValidationIssue[];
  source_provenance?: GOSSourceProvenance;
}

export interface GOSValidationResult {
  ok: boolean;
  issues: GOSValidationIssue[];
}

export interface GOSBundleManifest {
  bundle_id: string;
  spec_id: string;
  spec_version: string;
  bundle_version: string;
  compiler_version: string;
  compiled_at: string;
  lifecycle_state: 'draft' | 'reviewed' | 'active' | 'deprecated' | 'superseded' | 'revoked';
  replaces_bundle_id?: string;
  compiler_report_path: string;
  spec_path: string;
  source_provenance_path: string;
  notes?: string;
}

export interface GOSCompiledBundle {
  manifest: GOSBundleManifest;
  spec: GOSCanonicalSpec;
  compiler_report: GOSCompilerReport;
  source_provenance: GOSSourceProvenance;
}
