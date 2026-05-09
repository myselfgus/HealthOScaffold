import XCTest
@testable import HealthOSCore

final class GovernedAIAgentTests: XCTestCase {
    func testCatalogIncludesPersonalInternalProviderAndBoundaryAgents() {
        XCTAssertTrue(GovernedAIAgentCatalog.personalAgents.contains(.patientPersonal))
        XCTAssertTrue(GovernedAIAgentCatalog.personalAgents.contains(.professionalPersonal))
        XCTAssertTrue(GovernedAIAgentCatalog.coreGovernanceAgents.contains(.consentGovernance))
        XCTAssertTrue(GovernedAIAgentCatalog.coreGovernanceAgents.contains(.custodyAccess))
        XCTAssertTrue(GovernedAIAgentCatalog.runtimeAgents.contains(.aaci))
        XCTAssertTrue(GovernedAIAgentCatalog.runtimeAgents.contains(.msr))
        XCTAssertTrue(GovernedAIAgentCatalog.providerModelAgents.contains(.providerRouter))
        XCTAssertTrue(GovernedAIAgentCatalog.boundaryProtocolAgents.contains(.agentProtocolBoundary))
    }

    func testAgentDescriptorSeparatesAgentIdentityFromModelProviderPolicy() throws {
        let descriptor = makeDescriptor(kind: .patientPersonal, principalKind: .patient)

        XCTAssertEqual(descriptor.agentId.rawValue, "agent.patient.1")
        XCTAssertEqual(descriptor.kind.runtimeKind, .userAgent)
        XCTAssertTrue(descriptor.providerPolicy.preferAppleSiliconLocal)
        XCTAssertFalse(descriptor.providerPolicy.allowsExternalProvider)
        XCTAssertNoThrow(try GovernedAIAgentValidator.validateDescriptor(descriptor))
    }

    func testProfessionalPersonalAgentRequiresProfessionalPrincipal() {
        let descriptor = makeDescriptor(kind: .professionalPersonal, principalKind: .patient)

        XCTAssertThrowsError(try GovernedAIAgentValidator.validateDescriptor(descriptor)) { error in
            XCTAssertEqual(
                error as? GovernedAIAgentFailure,
                .principalKindMismatch(expected: .professional, actual: .patient)
            )
        }
    }

    func testNegotiationRejectsRawDirectIdentifierReidentificationRawStorageAndKeyMaterial() {
        XCTAssertThrowsError(
            try GovernedAIAgentValidator.validateNegotiationEnvelope(makeEnvelope(containsRawDirectIdentifier: true))
        ) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .directIdentifierDenied)
        }

        XCTAssertThrowsError(
            try GovernedAIAgentValidator.validateNegotiationEnvelope(makeEnvelope(containsReidentificationMapping: true))
        ) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .reidentificationDenied)
        }

        XCTAssertThrowsError(
            try GovernedAIAgentValidator.validateNegotiationEnvelope(makeEnvelope(containsRawStoragePath: true))
        ) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .rawStorageDenied)
        }

        XCTAssertThrowsError(
            try GovernedAIAgentValidator.validateNegotiationEnvelope(makeEnvelope(containsKeyMaterial: true))
        ) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .keyMaterialDenied)
        }
    }

    func testExternalProviderRoutingRequiresExplicitPolicy() {
        let policy = AgentProviderRoutingPolicy(
            allowedProviderKinds: [.remote],
            allowsExternalProvider: false,
            allowedDataLayers: [.derivedArtifacts],
            deniedDataLayers: []
        )
        let envelope = makeEnvelope(requestedDataLayers: [.derivedArtifacts], providerPolicy: policy)

        XCTAssertThrowsError(try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope)) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .externalProviderPolicyMissing)
        }
    }

    func testAutonomousClinicalAndRegulatoryIntentIsDeniedEvenWhenMandateListsIt() {
        let mandate = makeMandate(allowedIntents: [.diagnose])
        let envelope = makeEnvelope(intent: .diagnose)

        XCTAssertThrowsError(try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope, mandate: mandate)) { error in
            XCTAssertEqual(error as? GovernedAIAgentFailure, .autonomousClinicalOrRegulatoryActDenied(.diagnose))
        }
    }

    func testAgentEnvelopeCanCarryCustodyAndEphemeralRefsWithoutKeyMaterial() throws {
        let envelope = makeEnvelope(
            ephemeralGrantRef: EphemeralAccessGrantRef(
                grantSafeRef: "grant-safe-ref",
                authorizedDataLayers: [.governanceMetadata],
                expiresAt: Date().addingTimeInterval(60)
            ),
            custodyControlRef: CustodyControlRef(
                custodyHandleRef: "custody-handle-ref",
                custodyPolicyRef: "custody-policy-ref"
            )
        )

        XCTAssertNoThrow(try GovernedAIAgentValidator.validateNegotiationEnvelope(envelope))
    }

    private func makeDescriptor(
        kind: GovernedAIAgentKind,
        principalKind: AgentPrincipalKind
    ) -> GovernedAIAgentDescriptor {
        let agentId = AgentID("agent.patient.1")
        let principal = AgentPrincipalRef(principalKind: principalKind, safeRef: "safe-principal-ref")
        let mandate = makeMandate(principal: principal)
        return GovernedAIAgentDescriptor(
            agentId: agentId,
            kind: kind,
            representedPrincipal: principal,
            mandate: mandate,
            memoryScope: AgentMemoryScope(
                ownerAgentId: agentId,
                allowedStores: [.preferenceProfile, .consentHistory],
                allowedDataLayers: [.governanceMetadata, .derivedArtifacts],
                retentionPolicyRef: "retention.policy.agent",
                mayPersistDerivedPreference: true
            ),
            toolGrants: [
                AgentToolGrant(
                    toolId: "consent-request-tool",
                    grantedCapabilities: ["consent:request"],
                    allowedDataLayers: [.governanceMetadata]
                )
            ],
            delegationPolicy: DelegationPolicy(allowsAsyncOfflineResponse: true),
            boundary: AgentBoundary(
                reads: ["safe-ref"],
                writes: ["governance-metadata"],
                invokes: ["consent:request"],
                governanceChecks: ["lawfulContext"],
                forbiddenFinalizations: ["diagnose", "prescribe", "finalize-record", "sign-document"]
            ),
            protocolKinds: [.healthosAACP, .a2a]
        )
    }

    private func makeMandate(
        principal: AgentPrincipalRef = AgentPrincipalRef(principalKind: .patient, safeRef: "safe-principal-ref"),
        allowedIntents: [AgentNegotiationIntent] = [.educate, .requestConsent, .requestAccess]
    ) -> AgentMandate {
        AgentMandate(
            title: "personal-agent-mandate",
            principal: principal,
            allowedIntents: allowedIntents,
            allowedDataLayers: [.governanceMetadata, .derivedArtifacts],
            deniedDataLayers: [.directIdentifiers, .reidentificationMapping],
            lawfulContextRequirements: .init(requirePatientUserId: true)
        )
    }

    private func makeEnvelope(
        intent: AgentNegotiationIntent = .requestConsent,
        requestedDataLayers: [StorageLayer] = [.governanceMetadata],
        providerPolicy: AgentProviderRoutingPolicy = .init(deniedDataLayers: []),
        ephemeralGrantRef: EphemeralAccessGrantRef? = nil,
        custodyControlRef: CustodyControlRef? = nil,
        containsRawDirectIdentifier: Bool = false,
        containsReidentificationMapping: Bool = false,
        containsRawStoragePath: Bool = false,
        containsKeyMaterial: Bool = false
    ) -> AgentNegotiationEnvelope {
        let patientId = UUID()
        return AgentNegotiationEnvelope(
            fromAgentId: "agent.patient.1",
            toAgentId: "agent.consent.1",
            intent: intent,
            lawfulContext: lawfulContext(patientId: patientId),
            requestedDataLayers: requestedDataLayers,
            safeSubjectRefs: ["safe-patient-ref"],
            providerPolicy: providerPolicy,
            delegationPolicy: DelegationPolicy(allowsAsyncOfflineResponse: true),
            custodyControlRef: custodyControlRef,
            ephemeralGrantRef: ephemeralGrantRef,
            protocolHints: [.healthosAACP, .a2a],
            containsRawDirectIdentifier: containsRawDirectIdentifier,
            containsReidentificationMapping: containsReidentificationMapping,
            containsRawStoragePath: containsRawStoragePath,
            containsKeyMaterial: containsKeyMaterial
        )
    }

    private func lawfulContext(patientId: UUID) -> [String: String] {
        [
            "actorRole": "patient-personal-agent",
            "scope": "agent-negotiation",
            "patientUserId": patientId.uuidString,
            "finalidade": "consent-negotiation",
            "sessionId": UUID().uuidString
        ]
    }
}
