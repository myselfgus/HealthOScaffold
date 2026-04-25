export type RuntimeKind = "aaci" | "async" | "user-agent";

export type RuntimeLifecycleState =
  | "booting"
  | "ready"
  | "active"
  | "paused"
  | "terminating"
  | "terminated"
  | "failed";

export type RuntimeFailureKind =
  | "configuration_failure"
  | "dependency_failure"
  | "authorization_failure"
  | "integrity_failure"
  | "transport_failure"
  | "timeout_failure"
  | "internal_failure";

export interface SessionWork {
  id: string;
  kind: "encounter" | "chart_review" | "document_close" | "post_visit" | "pre_briefing" | "admin_block" | "handoff";
  serviceId: string;
  professionalUserId: string;
  patientUserId?: string;
  habilitationId?: string;
}

export interface AgentMessage {
  from: string;
  to: string;
  kind: string;
  payload: Record<string, unknown>;
  correlationId?: string;
}

export interface AgentBoundary {
  reads: string[];
  writes: string[];
  invokes: string[];
  governanceChecks: string[];
  forbiddenFinalizations: string[];
}

export interface AgentDescriptor {
  actorId: string;
  runtimeKind: RuntimeKind;
  semanticRole: string;
  permissions: string[];
  boundaryDescription: string;
  boundary: AgentBoundary;
  allowedInputKinds: string[];
  emittedOutputKinds: string[];
}

export interface RuntimeStatus {
  runtimeKind: RuntimeKind;
  state: RuntimeLifecycleState;
  failureKind?: RuntimeFailureKind;
  message?: string;
}

export type DraftKind =
  | "soap"
  | "prescription"
  | "referral"
  | "note"
  | "retrieval_summary"
  | "admin_task_list";

export type DraftStatus = "draft" | "awaiting_gate" | "approved" | "rejected" | "superseded";

export type GateRequestStatus = "pending" | "approved" | "rejected" | "cancelled";

export type GateReviewType = "professional_document_review";

export type FinalDocumentKind = "soap_note";

export type FinalDocumentStatus = "finalized";

export interface DraftAuthorIdentity {
  actorId: string;
  semanticRole: string;
}

export interface ArtifactDraft {
  id: string;
  sessionId: string;
  kind: DraftKind;
  status: DraftStatus;
  createdAt: string;
  author: DraftAuthorIdentity;
  payload: Record<string, string>;
  sourceEventIds?: string[];
}

export interface GateRequest {
  id: string;
  draftId: string;
  requestedAction: string;
  requiredRole: string;
  requiredReviewType: GateReviewType;
  finalizationTarget: FinalDocumentKind;
  requiresSignature: boolean;
  rationaleNote?: string | null;
  status: GateRequestStatus;
  requestedAt: string;
}

export interface GateResolution {
  id: string;
  gateRequestId: string;
  resolverUserId: string;
  resolverRole: string;
  resolution: "approved" | "rejected" | "cancelled";
  rationaleNote?: string | null;
  reviewedAt: string;
}

export interface SOAPNoteSections {
  subjective: string;
  objective: string;
  assessment: string;
  plan: string;
}

export interface SOAPDraftDocument {
  draft: ArtifactDraft;
  sections: SOAPNoteSections;
  contextStatus: "ready" | "partial" | "empty" | "degraded";
  contextSummary: string;
  noteSummary: string;
}

export interface DerivedDraftSpineLink {
  sourceSessionId: string;
  sourceSOAPDraftId: string;
  sourceSOAPDraftStatus: DraftStatus;
  sourceSOAPDraftObjectPath: string;
  sourceContextStatus: "ready" | "partial" | "empty" | "degraded";
  sourceContextSummary: string;
}

export interface ReferralDraftDocument {
  draft: ArtifactDraft;
  specialtyTarget: string;
  reason: string;
  contextSummary: string;
  noteSummary: string;
  readyForFutureGate: boolean;
  draftOnlyNote: string;
  spineLink: DerivedDraftSpineLink;
}

export interface PrescriptionDraftDocument {
  draft: ArtifactDraft;
  medicationSuggestion: string;
  instructionsDraft: string;
  rationale: string;
  contextSummary: string;
  noteSummary: string;
  readyForFutureGate: boolean;
  draftOnlyNote: string;
  spineLink: DerivedDraftSpineLink;
}

export interface FinalDocumentSourceLink {
  sourceDraftId: string;
  sourceDraftKind: DraftKind;
  sourceDraftStatus: DraftStatus;
  sourceDraftObjectPath: string;
  gateRequestId: string;
  gateResolutionId: string;
}

export interface DocumentFinalizationMetadata {
  finalizedAt: string;
  finalizerUserId: string;
  finalizerRole: string;
  reviewType: GateReviewType;
  gateResolution: "approved" | "rejected" | "cancelled";
}

export interface FinalizedSOAPDocument {
  id: string;
  sessionId: string;
  kind: FinalDocumentKind;
  status: FinalDocumentStatus;
  sections: SOAPNoteSections;
  source: FinalDocumentSourceLink;
  finalization: DocumentFinalizationMetadata;
  summary: string;
}

export type AsyncJobState =
  | "pending"
  | "leased"
  | "running"
  | "completed"
  | "failed"
  | "retry_scheduled"
  | "cancelled"
  | "dead_letter";

export type AsyncJobPriority = "low" | "normal" | "high" | "critical";

export type AsyncJobKind =
  | "indexing"
  | "embedding_generation"
  | "retrieval_index_maintenance"
  | "provenance_enrichment"
  | "audit_export"
  | "backup"
  | "restore_validation"
  | "provider_evaluation"
  | "fine_tuning_offline"
  | "lifecycle_maintenance"
  | "agent_mailbox_dispatch"
  | "maintenance";

export type AsyncJobFailureKind =
  | "policy_denied"
  | "validation_failed"
  | "dependency_failure"
  | "timeout"
  | "transport_failure"
  | "internal_failure"
  | "cancelled";

export type JobSubmissionSource = "operator" | "system" | "aaci" | "app" | "gos";

export interface AsyncJobLawfulContextRequirement {
  requireLawfulContext: boolean;
  requireFinalidade: boolean;
  requireConsent: boolean;
  requireHabilitation: boolean;
  requirePatientContext: boolean;
  requireServiceContext: boolean;
}

export interface AsyncJobRetryPolicy {
  maxRetries: number;
  baseDelaySeconds: number;
  backoff: "fixed" | "exponential";
  automaticRetryAllowed: boolean;
}

export interface AsyncJobDescriptor {
  id: string;
  kind: AsyncJobKind;
  requestedByActor: string;
  submissionSource: JobSubmissionSource;
  lawfulContextRequirement: AsyncJobLawfulContextRequirement;
  dataLayersTouched: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  inputRefs: string[];
  outputRefs: string[];
  idempotencyKey: string;
  priority: AsyncJobPriority;
  createdAt: string;
  scheduledAt?: string;
  startedAt?: string;
  completedAt?: string;
  failedAt?: string;
  retryCount: number;
  retryPolicy: AsyncJobRetryPolicy;
  state: AsyncJobState;
  provenanceRefs: string[];
  auditRefs: string[];
  idempotent: boolean;
  allowsRemoteProvider: boolean;
}

export interface AsyncJobFailure {
  kind: AsyncJobFailureKind;
  message: string;
  at: string;
}

export interface AsyncJobAttemptRecord {
  attempt: number;
  startedAt: string;
  finishedAt: string;
  failure?: AsyncJobFailure;
  provenanceRef?: string;
  auditRef?: string;
}

export interface AsyncJobExecutionRecord {
  jobId: string;
  attempts: AsyncJobAttemptRecord[];
  lastFailure?: AsyncJobFailure;
}

export type AsyncJobEventKind =
  | "job.enqueued"
  | "job.started"
  | "job.completed"
  | "job.failed"
  | "job.retry_scheduled"
  | "job.dead_lettered"
  | "job.cancelled"
  | "job.policy_denied"
  | "job.idempotency_reused";

export interface AsyncJobObservabilityEvent {
  id: string;
  kind: AsyncJobEventKind;
  jobId: string;
  jobKind: AsyncJobKind;
  state: AsyncJobState;
  source: string;
  timestamp: string;
  failureKind?: AsyncJobFailureKind;
  provenanceRef?: string;
}

export interface AsyncJobHealthSummary {
  pending: number;
  running: number;
  retryScheduled: number;
  failed: number;
  deadLetter: number;
}
