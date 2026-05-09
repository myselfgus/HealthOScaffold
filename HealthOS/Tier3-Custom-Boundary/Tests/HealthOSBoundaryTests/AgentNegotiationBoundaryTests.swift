import XCTest
import HealthOSBoundary

final class AgentNegotiationBoundaryTests: XCTestCase {
    func testA2AProjectionIsAppSafeAndNonAuthorizing() throws {
        let projection = try AgentProtocolBoundary.project(makeEnvelope(), to: .a2a)

        XCTAssertEqual(projection.protocolKind, .a2a)
        XCTAssertTrue(projection.streamAllowed)
        XCTAssertFalse(projection.legalAuthorizing)
        XCTAssertFalse(projection.exposesRawDirectIdentifiers)
        XCTAssertFalse(projection.exposesRawStorage)
        XCTAssertFalse(projection.exposesKeyMaterial)
        XCTAssertNil(projection.degradedState)
    }

    func testACPProjectionIsFutureAdapterAndStillAppSafe() throws {
        let projection = try AgentProtocolBoundary.project(makeEnvelope(protocolHints: [.healthosAACP]), to: .acp)

        XCTAssertEqual(projection.protocolKind, .acp)
        XCTAssertEqual(projection.degradedState, "acp-ui-adapter-future")
        XCTAssertFalse(projection.legalAuthorizing)
    }

    func testProtocolBoundaryRejectsUnsafeSafeRefs() {
        let envelope = makeEnvelope(safeSubjectRefs: ["cpf:12345678900"])

        XCTAssertThrowsError(try AgentProtocolBoundary.project(envelope, to: .a2a)) { error in
            XCTAssertEqual(
                error as? AgentProtocolBoundaryFailure,
                .unsafeProtocolProjection("unsafe-safe-ref")
            )
        }
    }

    func testProtocolBoundaryRejectsLegalAuthorizingProjection() {
        let projection = AgentProtocolProjection(
            protocolKind: .a2a,
            taskId: "task",
            fromAgentId: "agent.patient.1",
            toAgentId: "agent.professional.1",
            intent: .requestConsent,
            safeSubjectRefs: ["safe-patient-ref"],
            streamAllowed: true,
            degradedState: nil,
            legalAuthorizing: true
        )

        XCTAssertThrowsError(try AgentProtocolBoundary.validateAppSafeProjection(projection)) { error in
            XCTAssertEqual(error as? AgentProtocolBoundaryFailure, .unsupportedLegalAuthorization)
        }
    }

    private func makeEnvelope(
        safeSubjectRefs: [String] = ["safe-patient-ref"],
        protocolHints: [AgentProtocolKind] = [.healthosAACP, .a2a]
    ) -> AgentNegotiationEnvelope {
        let patientId = UUID()
        return AgentNegotiationEnvelope(
            taskRef: "task-agent-negotiation",
            fromAgentId: "agent.patient.1",
            toAgentId: "agent.professional.1",
            intent: .requestConsent,
            lawfulContext: [
                "actorRole": "patient-personal-agent",
                "scope": "agent-negotiation",
                "patientUserId": patientId.uuidString,
                "finalidade": "consent-negotiation",
                "sessionId": UUID().uuidString
            ],
            requestedDataLayers: [.governanceMetadata],
            safeSubjectRefs: safeSubjectRefs,
            providerPolicy: AgentProviderRoutingPolicy(deniedDataLayers: []),
            delegationPolicy: DelegationPolicy(allowsAsyncOfflineResponse: true),
            protocolHints: protocolHints
        )
    }
}
