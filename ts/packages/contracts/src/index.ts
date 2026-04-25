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

export type BackupScope =
  | "system"
  | "service"
  | "user-export"
  | "audit-provenance"
  | "model-provider-registry"
  | "gos-bundle-registry";

export type IntegrityStatus = "pending" | "verified" | "failed";

export type EncryptionScaffoldStatus = "scaffolded" | "required" | "notImplemented";

export type RetentionClass = "operational" | "legal" | "regulatory" | "user-portable";

export type RestoreEligibility = "allowed" | "policy-restricted" | "denied";

export interface BackupObjectEntry {
  objectRef: { objectPath: string; contentHash: string; layer: "direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping"; kind: string };
  expectedHash: string;
  provenanceRefs: string[];
  auditRefs: string[];
}

export interface BackupManifest {
  backupId: string;
  createdAt: string;
  createdBy: string;
  nodeId?: string;
  serviceId?: string;
  userId?: string;
  scope: BackupScope;
  includedLayers: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  excludedLayers: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  objectEntries: BackupObjectEntry[];
  schemaVersion: string;
  storageVersion: string;
  encryptionStatus: EncryptionScaffoldStatus;
  integrityStatus: IntegrityStatus;
  retentionClass: RetentionClass;
  restoreEligibility: RestoreEligibility;
  includesDirectIdentifiers: boolean;
  includesReidentificationMapping: boolean;
}

export type RestoreConflictPolicy = "fail-if-exists" | "overwrite" | "skip-existing";
export type RestoreProvenanceMode = "preserve" | "preserve-or-gap-record";
export type LifecycleRestoreHandling = "preserve" | "do-not-reactivate-revoked";

export interface RestorePlan {
  restoreId: string;
  sourceBackupId: string;
  requestedBy: string;
  lawfulContextRequired: boolean;
  lawfulContext?: Record<string, string>;
  targetRoot: string;
  targetNodeId?: string;
  targetServiceId?: string;
  targetUserId?: string;
  dryRun: boolean;
  conflictPolicy?: RestoreConflictPolicy;
  expectedObjectHashes: Record<string, string>;
  validatedObjectHashes: Record<string, string>;
  restoredLayers: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  excludedLayers: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  provenanceMode: RestoreProvenanceMode;
  auditMode: RestoreProvenanceMode;
  reidentificationHandlingExplicit: boolean;
  directIdentifierPolicyElevated: boolean;
  lifecycleHandling: LifecycleRestoreHandling;
  includesFinalDocuments: boolean;
  preservesGateLineage: boolean;
}

export interface RetentionPolicy {
  retentionClass: RetentionClass;
  minimumRetentionDays: number;
  legalHold: boolean;
  serviceRetentionObligation: boolean;
  userVisibilityEligible: boolean;
  userExportEligible: boolean;
  deletionEligible: boolean;
  anonymizationEligible: boolean;
  archivalEligible: boolean;
}

export interface RetentionDecision {
  id: string;
  requestedBy: string;
  rationale: string;
  policy: RetentionPolicy;
  provenanceRef?: string;
  auditRef?: string;
}

export type ExportKind = "patient-user" | "service-operational" | "audit" | "provenance" | "regulatory-scaffold";

export interface ExportRequest {
  id: string;
  kind: ExportKind;
  requestedBy: string;
  viaCoreMediation: boolean;
  ownerUserId?: string;
  ownerServiceId?: string;
  lawfulContext?: Record<string, string>;
  includeDirectIdentifiers: boolean;
  includeReidentificationMapping: boolean;
  directIdentifierPolicyElevated: boolean;
  redactionStatus: string;
}

export interface ExportPackageManifest {
  exportId: string;
  requestId: string;
  objectRefs: { objectPath: string; contentHash: string; layer: "direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping"; kind: string }[];
  objectHashes: Record<string, string>;
  redactionStatus: string;
  lawfulContextSnapshot: Record<string, string>;
}

export interface DisasterRecoveryPlan {
  id: string;
  name: string;
  rpoMinutes: number;
  rtoMinutes: number;
}

export interface DRReadinessReport {
  id: string;
  planId: string;
  backupPresent: boolean;
  restoreDryRunPassed: boolean;
  integrityPassed: boolean;
  schemaCompatible: boolean;
  nodeFabricCompatible: boolean;
  auditProvenanceContinuous: boolean;
  sensitiveLayerHandlingPassed: boolean;
}

export type BackupGovernanceEventKind =
  | "backup.created"
  | "backup.failed"
  | "backup.integrity_verified"
  | "restore.requested"
  | "restore.validated"
  | "restore.executed"
  | "restore.failed"
  | "export.requested"
  | "export.created"
  | "export.denied"
  | "retention.decision"
  | "retention.hold.applied"
  | "dr.dry_run.completed"
  | "dr.readiness.failed";

export type RegulatoryAuditStatus =
  | "requested"
  | "validated"
  | "denied"
  | "approved"
  | "package_prepared"
  | "delivered_externally_placeholder"
  | "closed";

export type EmergencyAccessStatus =
  | "requested"
  | "granted"
  | "denied"
  | "expired"
  | "revoked"
  | "post_review_required"
  | "post_review_completed";

export type RegulatoryAuthorityKind =
  | "internal-compliance"
  | "judicial-order"
  | "public-health-authority"
  | "regulator"
  | "other-lawful-authority";

export type SignatureProviderKind = "none" | "local-scaffold" | "qualified-provider-placeholder";

export type DocumentLegalSignatureStatus =
  | "unsigned"
  | "signature_requested"
  | "signed_unverified"
  | "verified_qualified_placeholder"
  | "invalid"
  | "unsupported";

export interface RegulatoryAuditScope {
  operations: string[];
  includeProvenance: boolean;
  includeAuditTrail: boolean;
}

export interface RegulatoryAuditRequest {
  id: string;
  authorityKind: RegulatoryAuthorityKind;
  legalBasis: string;
  rationale: string;
  requestedScope: RegulatoryAuditScope;
  requestedDataLayers: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  serviceId: string;
  patientUserId?: string;
  requestedByActor: string;
  approvedByActor?: string;
  timeWindowStart: string;
  timeWindowEnd: string;
  lawfulContext: Record<string, string>;
  exportPackageRefs: string[];
  auditRefs: string[];
  provenanceRefs: string[];
  viaCoreMediation: boolean;
  status: RegulatoryAuditStatus;
}

export interface EmergencyAccessRequest {
  id: string;
  actorId: string;
  actorRole: string;
  patientUserId: string;
  serviceId: string;
  emergencyRationale: string;
  requestedScope: string[];
  requestedDurationMinutes: number;
  requestedBySource: "operator" | "system" | "app" | "aaci" | "gos";
  lawfulContext: Record<string, string>;
  status: EmergencyAccessStatus;
}

export interface DigitalSignatureRequest {
  id: string;
  documentRef: { objectPath: string; contentHash: string; layer: "direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping"; kind: string };
  documentHash: string;
  sourceDraftId: string;
  gateRequestId: string;
  gateResolutionId: string;
  gateApproved: boolean;
  signerUserId: string;
  signerProfessionalRecordId?: string;
  signatureProviderKind: SignatureProviderKind;
  certificateRefPlaceholder?: string;
  requestedAt: string;
  signedAt?: string;
  verificationStatus: string;
  legalStatus: DocumentLegalSignatureStatus;
  provenanceRefs: string[];
}

export type RegulatoryGovernanceEventKind =
  | "regulatory.audit.requested"
  | "regulatory.audit.denied"
  | "regulatory.audit.package_prepared"
  | "emergency_access.requested"
  | "emergency_access.granted"
  | "emergency_access.expired"
  | "emergency_access.revoked"
  | "emergency_access.post_review_required"
  | "retention.visibility_decision"
  | "signature.requested"
  | "signature.completed_placeholder"
  | "signature.verification_failed"
  | "interoperability.package_prepared"
  | "interoperability.validation_failed";

export type UserAgentCapability =
  | "explain-own-data"
  | "summarize-own-data"
  | "retrieve-own-context"
  | "list-consents"
  | "inspect-access-audit"
  | "prepare-export-request"
  | "organize-own-artifacts"
  | "ask-administrative-clarification"
  | "diagnose"
  | "prescribe"
  | "issue-referral"
  | "finalize-record"
  | "sign-document"
  | "grant-professional-habilitation"
  | "alter-legal-retention"
  | "access-reidentification-map"
  | "bypass-consent-audit";

export interface UserAgentScope {
  userId: string;
  cpfHashRef: string;
  actorId: string;
  runtimeId: string;
  dataLayersAllowed: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  dataLayersDenied: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  allowDirectIdentifiersFlowExplicit: boolean;
  allowReidentificationFlowExplicit: boolean;
}

export interface UserAgentRequest {
  requestId: string;
  scope: UserAgentScope;
  requestedCapability: UserAgentCapability;
  lawfulContext: Record<string, string>;
  sessionRef?: string;
  contextRef?: string;
  provenanceRefs: string[];
  auditRefs: string[];
}

export type UserAgentDataDisposition = "informational-user-facing" | "clinical-act";

export interface UserAgentResponse {
  requestId: string;
  disposition: UserAgentDataDisposition;
  message: string;
  provenanceRefs: string[];
  auditRefs: string[];
}

export interface PatientConsentView {
  consentId: string;
  finalidade: string;
  scopeSummary: string[];
  validityStart: string;
  validityEnd?: string;
  revoked: boolean;
  revokedAt?: string;
  retentionObligationApplies: boolean;
}

export interface ConsentRevocationRequest {
  requestId: string;
  patientUserId: string;
  consentId: string;
  finalidade: string;
  scopeSummary: string[];
  rationale: string;
  lawfulContext: Record<string, string>;
  retentionAcknowledged: boolean;
  finalDocumentImmutabilityAcknowledged: boolean;
  provenanceRef?: string;
  auditRef?: string;
}

export interface PatientAuditQuery {
  patientUserId: string;
  lawfulContext: Record<string, string>;
  includeEmergencyMarker: boolean;
  includeRegulatoryMarker: boolean;
}

export interface AccessAuditEventView {
  id: string;
  patientUserId: string;
  actorRole: string;
  actorDisplay: string;
  timestamp: string;
  finalidade: string;
  serviceRef?: string;
  dataLayer: "direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping";
  operation: string;
  provenanceRef?: string;
  auditRef?: string;
  emergencyAccess: boolean;
  regulatoryAccess: boolean;
  redactionStatus: string;
  secretsRedacted: boolean;
}

export interface PatientAccessAuditView {
  query: PatientAuditQuery;
  events: AccessAuditEventView[];
}

export interface PatientExportRequestSurface {
  requestId: string;
  ownerUserId: string;
  lawfulContext: Record<string, string>;
  scope: ("direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping")[];
  redactionPolicy: string;
  includeDirectIdentifiers: boolean;
  directIdentifierPolicyElevated: boolean;
  includeReidentificationMapping: boolean;
}

export interface PatientExportStatusView {
  requestId: string;
  status: string;
  packageManifest?: ExportPackageManifest;
  appSafeStatusDetail: string;
  storagePathExposed: boolean;
}

export interface DataVisibilityRetentionItem {
  id: string;
  patientUserId: string;
  dataLayer: "direct-identifiers" | "operational-content" | "governance-metadata" | "derived-artifacts" | "reidentification-mapping";
  visibleToPatient: boolean;
  hiddenByPolicy: boolean;
  retainedByServiceObligation: boolean;
  exportEligible: boolean;
  deletionEligible: boolean;
  anonymizationEligible: boolean;
  legalHold: boolean;
  patientRequestedRestriction: boolean;
}

export interface SortioDashboardSummary {
  userId: string;
  consentSummaryCount: number;
  auditSummaryCount: number;
  exportPendingCount: number;
  userAgentState: string;
}

export interface SortioConsentSummary {
  active: number;
  revoked: number;
  expiringSoon: number;
}

export interface SortioAccessAuditSummary {
  totalEvents: number;
  emergencyEvents: number;
  regulatoryEvents: number;
}

export interface SortioExportSummary {
  pending: number;
  completed: number;
  denied: number;
}

export interface SortioUserAgentInteractionEnvelope {
  request: UserAgentRequest;
  response: UserAgentResponse;
}

export interface SortioDataVisibilitySummary {
  visibleItems: number;
  retainedButHiddenItems: number;
  legalHoldItems: number;
}

export interface SortioNotificationObligationsSummary {
  pendingPatientNotifications: number;
  pendingPostEmergencyReview: number;
  pendingExportNotifications: number;
}
