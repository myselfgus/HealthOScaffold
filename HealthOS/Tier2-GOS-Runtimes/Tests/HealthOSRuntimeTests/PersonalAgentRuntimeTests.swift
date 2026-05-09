import XCTest
import HealthOSCore
import HealthOSProviders
@testable import HealthOSUserAgentRuntime

final class PersonalAgentRuntimeTests: XCTestCase {
    func testPersonalAgentRuntimeStartsPatientAndProfessionalSessions() async throws {
        let runtime = PersonalAgentRuntime()

        let patientSession = try await runtime.start(descriptor: makeDescriptor(kind: .patientPersonal, principalKind: .patient, agentId: "agent.patient.1"))
        let professionalSession = try await runtime.start(descriptor: makeDescriptor(kind: .professionalPersonal, principalKind: .professional, agentId: "agent.professional.1"))

        XCTAssertEqual(patientSession.agentKind, .patientPersonal)
        XCTAssertEqual(professionalSession.agentKind, .professionalPersonal)
        XCTAssertEqual(patientSession.lifecycleState, .active)
        XCTAssertTrue(patientSession.offlineResponseAllowed)
    }

    func testPersonalAgentRuntimeRejectsNonPersonalAgentDescriptor() async {
        let runtime = PersonalAgentRuntime()
        let descriptor = makeDescriptor(kind: .consentGovernance, principalKind: .coreGovernance, agentId: "agent.consent.1")

        await XCTAssertThrowsErrorAsync(try await runtime.start(descriptor: descriptor)) { error in
            XCTAssertEqual(error as? PersonalAgentRuntimeFailure, .nonPersonalAgent(.consentGovernance))
        }
    }

    func testPersonalAgentRuntimeMediatesEnvelopeWithoutBecomingLegalAuthority() async throws {
        let runtime = PersonalAgentRuntime(providerRouter: ProviderRouter())
        let descriptor = makeDescriptor(kind: .patientPersonal, principalKind: .patient, agentId: "agent.patient.1")
        let session = try await runtime.start(descriptor: descriptor)

        let response = try await runtime.handle(makeEnvelope(from: descriptor.agentId, to: "agent.consent.1"), sessionId: session.sessionId)

        XCTAssertEqual(response.disposition, .informationalUserFacing)
        XCTAssertFalse(response.legalAuthorizing)
        XCTAssertTrue(response.providerDecision.contains("unavailable"))
        XCTAssertNotNil(response.degradedState)
    }

    func testPersonalAgentRuntimeQueuesOfflineResponseOnlyWhenPolicyAllows() async throws {
        let runtime = PersonalAgentRuntime()
        let descriptor = makeDescriptor(kind: .patientPersonal, principalKind: .patient, agentId: "agent.patient.1")
        let session = try await runtime.start(descriptor: descriptor)

        let queued = try await runtime.enqueueOfflineResponse(makeEnvelope(from: descriptor.agentId, to: "agent.consent.1"), sessionId: session.sessionId)

        XCTAssertEqual(queued.status, "queued-for-policy-mediated-dispatch")
        XCTAssertEqual(queued.agentId, descriptor.agentId)
        XCTAssertEqual(queued.safeSubjectRefs, ["safe-patient-ref"])
    }

    func testPersonalAgentRuntimeRejectsAutonomousClinicalIntent() async throws {
        let runtime = PersonalAgentRuntime()
        let descriptor = makeDescriptor(
            kind: .patientPersonal,
            principalKind: .patient,
            agentId: "agent.patient.1",
            allowedIntents: [.diagnose]
        )
        let session = try await runtime.start(descriptor: descriptor)

        await XCTAssertThrowsErrorAsync(
            try await runtime.handle(self.makeEnvelope(from: descriptor.agentId, to: "agent.core.1", intent: .diagnose), sessionId: session.sessionId)
        ) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .autonomousClinicalOrRegulatoryActDenied(.diagnose))
        }
    }

    private func makeDescriptor(
        kind: GovernedAIAgentKind,
        principalKind: AgentPrincipalKind,
        agentId: AgentID,
        allowedIntents: [AgentNegotiationIntent] = [.educate, .requestConsent, .requestAccess]
    ) -> GovernedAIAgentDescriptor {
        let principal = AgentPrincipalRef(principalKind: principalKind, safeRef: "safe-\(principalKind.rawValue)-ref")
        let mandate = AgentMandate(
            title: "personal-agent-runtime-test",
            principal: principal,
            allowedIntents: allowedIntents,
            allowedDataLayers: [.governanceMetadata, .derivedArtifacts],
            deniedDataLayers: [.directIdentifiers, .reidentificationMapping],
            lawfulContextRequirements: .init(requirePatientUserId: principalKind == .patient)
        )
        return GovernedAIAgentDescriptor(
            agentId: agentId,
            kind: kind,
            representedPrincipal: principal,
            mandate: mandate,
            memoryScope: AgentMemoryScope(
                ownerAgentId: agentId,
                allowedStores: [.preferenceProfile, .consentHistory, .professionalContext],
                allowedDataLayers: [.governanceMetadata, .derivedArtifacts],
                retentionPolicyRef: "retention.policy.personal-agent",
                mayPersistDerivedPreference: true
            ),
            toolGrants: [
                AgentToolGrant(
                    toolId: "agent-negotiation-tool",
                    grantedCapabilities: ["consent:request", "access:request"],
                    allowedDataLayers: [.governanceMetadata]
                )
            ],
            delegationPolicy: DelegationPolicy(allowsAsyncOfflineResponse: true),
            boundary: AgentBoundary(
                reads: ["safe-ref"],
                writes: ["governance-metadata"],
                invokes: ["agent:negotiate"],
                governanceChecks: ["lawfulContext", "consent", "habilitation"],
                forbiddenFinalizations: ["diagnose", "prescribe", "finalize-record", "sign-document"]
            ),
            protocolKinds: [.healthosAACP, .a2a]
        )
    }

    private func makeEnvelope(
        from: AgentID,
        to: AgentID,
        intent: AgentNegotiationIntent = .requestConsent
    ) -> AgentNegotiationEnvelope {
        let patientId = UUID()
        return AgentNegotiationEnvelope(
            fromAgentId: from,
            toAgentId: to,
            intent: intent,
            lawfulContext: [
                "actorRole": "patient-personal-agent",
                "scope": "agent-negotiation",
                "patientUserId": patientId.uuidString,
                "finalidade": "consent-negotiation",
                "sessionId": UUID().uuidString
            ],
            requestedDataLayers: [.governanceMetadata],
            safeSubjectRefs: ["safe-patient-ref"],
            providerPolicy: AgentProviderRoutingPolicy(deniedDataLayers: []),
            delegationPolicy: DelegationPolicy(allowsAsyncOfflineResponse: true),
            protocolHints: [.healthosAACP, .a2a]
        )
    }

    private func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure @escaping () async throws -> T,
        _ validation: (Error) -> Void
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected async expression to throw")
        } catch {
            validation(error)
        }
    }
}
