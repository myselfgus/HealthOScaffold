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

export interface GateRequest {
  id: string;
  draftId: string;
  requestedAction: string;
  requiredRole: string;
  requiresSignature: boolean;
  status: "pending" | "approved" | "rejected" | "cancelled";
}
