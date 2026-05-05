import Foundation

// Minimal Veridia session boundary adapter.
// Wires UserSovereigntyContracts.swift governance validators to an executable session seam.
// Equivalent to ScribeSessionAdapter for the patient identity/governance domain.
// Validates via UserAgentGovernanceValidator and VeridiaBoundaryValidator.
// Records veridia.session.start and veridia.session.end provenance in-memory (scaffold posture).
// Does not own Core law. Does not perform clinical operations.
public actor VeridiaSessionAdapter: VeridiaSessionFacade {
    private struct ActiveSession {
        let request: VeridiaSessionStartRequest
        let startProvenanceRef: UUID
        let startAuditRef: UUID
    }

    private var sessions: [UUID: ActiveSession] = [:]

    public init() {}

    public func startSession(_ request: VeridiaSessionStartRequest) async -> VeridiaSessionResult {
        let scope = UserAgentScope(
            userId: request.userId,
            cpfHashRef: request.cpfHashRef,
            actorId: request.actorId,
            runtimeId: request.runtimeId,
            dataLayersAllowed: [.operationalContent, .governanceMetadata],
            dataLayersDenied: [.reidentificationMapping]
        )
        let agentRequest = UserAgentRequest(
            scope: scope,
            requestedCapability: .retrieveOwnContext,
            lawfulContext: request.lawfulContext
        )

        do {
            _ = try UserAgentGovernanceValidator.validateRequest(agentRequest)
        } catch let failure as UserAgentFailure {
            return VeridiaSessionResult(
                sessionId: request.requestId,
                disposition: .governedDeny,
                issueMessage: failure.errorDescription
            )
        } catch {
            return VeridiaSessionResult(
                sessionId: request.requestId,
                disposition: .validationFailure,
                issueMessage: error.localizedDescription
            )
        }

        do {
            try VeridiaBoundaryValidator.validateAppSafePayload(
                rawCPF: nil,
                rawStoragePath: nil,
                capability: .retrieveOwnContext
            )
        } catch let failure as VeridiaBoundaryFailure {
            return VeridiaSessionResult(
                sessionId: request.requestId,
                disposition: .governedDeny,
                issueMessage: failure.errorDescription
            )
        } catch {
            return VeridiaSessionResult(
                sessionId: request.requestId,
                disposition: .validationFailure,
                issueMessage: error.localizedDescription
            )
        }

        let sessionId = UUID()
        let startRecord = ProvenanceRecord(
            actorId: request.actorId,
            operation: "veridia.session.start"
        )
        let auditRef = UUID()
        sessions[sessionId] = ActiveSession(
            request: request,
            startProvenanceRef: startRecord.id,
            startAuditRef: auditRef
        )

        return VeridiaSessionResult(
            sessionId: sessionId,
            disposition: .sessionStarted,
            provenanceRef: startRecord.id,
            auditRef: auditRef
        )
    }

    public func endSession(sessionId: UUID, lawfulContext: [String: String]) async -> VeridiaSessionResult {
        guard sessions[sessionId] != nil else {
            return VeridiaSessionResult(
                sessionId: sessionId,
                disposition: .validationFailure,
                issueMessage: "No active Veridia session for the given sessionId."
            )
        }

        sessions.removeValue(forKey: sessionId)

        let endRecord = ProvenanceRecord(operation: "veridia.session.end")
        let auditRef = UUID()

        return VeridiaSessionResult(
            sessionId: sessionId,
            disposition: .sessionEnded,
            provenanceRef: endRecord.id,
            auditRef: auditRef
        )
    }
}
