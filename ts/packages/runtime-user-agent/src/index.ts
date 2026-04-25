import type {
  UserAgentRequest,
  UserAgentResponse,
  UserAgentCapability,
  UserAgentDataDisposition,
} from "@healthos/contracts";

const PROHIBITED_CAPABILITIES: UserAgentCapability[] = [
  "diagnose",
  "prescribe",
  "issue-referral",
  "finalize-record",
  "sign-document",
  "grant-professional-habilitation",
  "alter-legal-retention",
  "access-reidentification-map",
  "bypass-consent-audit",
];

export interface UserAgentSession {
  userId: string;
  cpfHash: string;
  mode: "self-service";
}

export class UserAgentRuntime {
  async start(session: UserAgentSession): Promise<void> {
    console.log("[runtime-user-agent] start", session.userId);
  }

  handle(request: UserAgentRequest): UserAgentResponse {
    this.validate(request);
    const disposition: UserAgentDataDisposition = "informational-user-facing";
    return {
      requestId: request.requestId,
      disposition,
      message: `Handled capability ${request.requestedCapability} in user-governed informational mode.`,
      provenanceRefs: request.provenanceRefs,
      auditRefs: request.auditRefs,
    };
  }

  private validate(request: UserAgentRequest): void {
    if (PROHIBITED_CAPABILITIES.includes(request.requestedCapability)) {
      throw new Error(`prohibited capability: ${request.requestedCapability}`);
    }
    if (!request.lawfulContext || Object.keys(request.lawfulContext).length === 0) {
      throw new Error("missing lawfulContext");
    }
    if (request.scope.dataLayersAllowed.includes("reidentification-mapping") && !request.scope.allowReidentificationFlowExplicit) {
      throw new Error("reidentification mapping denied by default");
    }
    if (request.scope.dataLayersAllowed.includes("direct-identifiers") && !request.scope.allowDirectIdentifiersFlowExplicit) {
      throw new Error("direct identifier access requires explicit policy");
    }
  }
}
