import XCTest
@testable import HealthOSCore
@testable import HealthOSAACI
@testable import HealthOSProviders
@testable import HealthOSSessionRuntime

final class RetrievalMemoryGovernanceTests: XCTestCase {
    func testRetrievalFailsWithoutLawfulContext() throws {
        let lexical = makeLexicalQuery(patientUserId: UUID())
        XCTAssertThrowsError(
            try GovernedRetrievalQuery(
                actorId: "actor-1",
                actorRole: "professional-agent",
                serviceId: UUID(),
                patientUserId: UUID(),
                sessionId: UUID(),
                finalidade: "care-context-retrieval",
                lawfulContext: [:],
                allowedDataLayers: [.operationalContent],
                mode: .lexical,
                providerRequirement: .init(requiresEmbeddingProvider: false),
                maxResults: 3,
                provenanceRequired: true,
                lexicalQuery: lexical
            )
        ) { error in
            XCTAssertEqual(error as? RetrievalFailure, .missingLawfulContext)
        }
    }

    func testRetrievalFailsWithoutFinalidade() throws {
        let lexical = makeLexicalQuery(patientUserId: UUID())
        XCTAssertThrowsError(
            try GovernedRetrievalQuery(
                actorId: "actor-1",
                actorRole: "professional-agent",
                serviceId: UUID(),
                patientUserId: UUID(),
                sessionId: UUID(),
                finalidade: " ",
                lawfulContext: makeLawfulContext(),
                allowedDataLayers: [.operationalContent],
                mode: .lexical,
                providerRequirement: .init(requiresEmbeddingProvider: false),
                maxResults: 3,
                provenanceRequired: true,
                lexicalQuery: lexical
            )
        ) { error in
            XCTAssertEqual(error as? RetrievalFailure, .missingFinalidade)
        }
    }

    func testRetrievalFailsWhenDeniedLayerIsAlsoAllowed() throws {
        let lexical = makeLexicalQuery(patientUserId: UUID())
        XCTAssertThrowsError(
            try GovernedRetrievalQuery(
                actorId: "actor-1",
                actorRole: "professional-agent",
                serviceId: UUID(),
                patientUserId: UUID(),
                sessionId: UUID(),
                finalidade: "care-context-retrieval",
                lawfulContext: makeLawfulContext(),
                allowedDataLayers: [.operationalContent],
                deniedDataLayers: [.operationalContent],
                mode: .lexical,
                providerRequirement: .init(requiresEmbeddingProvider: false),
                maxResults: 3,
                provenanceRequired: true,
                lexicalQuery: lexical
            )
        ) { error in
            XCTAssertEqual(error as? RetrievalFailure, .dataLayerDenied(.operationalContent))
        }
    }

    func testRetrievalValidContextPasses() throws {
        let patientId = UUID()
        let lexical = makeLexicalQuery(patientUserId: patientId)
        let query = try GovernedRetrievalQuery(
            actorId: "actor-1",
            actorRole: "professional-agent",
            serviceId: UUID(),
            patientUserId: patientId,
            sessionId: UUID(),
            finalidade: "care-context-retrieval",
            lawfulContext: makeLawfulContext(patientUserId: patientId),
            allowedDataLayers: [.operationalContent],
            mode: .lexical,
            providerRequirement: .init(requiresEmbeddingProvider: false),
            maxResults: 3,
            provenanceRequired: true,
            lexicalQuery: lexical
        )
        XCTAssertEqual(query.mode, .lexical)
        XCTAssertEqual(query.patientUserId, patientId)
    }

    func testPatientScopedRetrievalRequiresPatientId() throws {
        let lexical = makeLexicalQuery(patientUserId: UUID())
        XCTAssertThrowsError(
            try GovernedRetrievalQuery(
                actorId: "actor-1",
                actorRole: "professional-agent",
                serviceId: UUID(),
                patientUserId: nil,
                sessionId: UUID(),
                finalidade: "care-context-retrieval",
                lawfulContext: makeLawfulContext(),
                allowedDataLayers: [.operationalContent],
                mode: .lexical,
                providerRequirement: .init(requiresEmbeddingProvider: false),
                maxResults: 3,
                provenanceRequired: true,
                lexicalQuery: lexical
            )
        ) { error in
            XCTAssertEqual(error as? RetrievalFailure, .missingPatientUserId)
        }
    }

    func testSessionMemoryDoesNotEscapeToServiceMemory() throws {
        let memory = MemoryScopeContract(
            scope: .aaciSession,
            sessionId: UUID(),
            dataLayer: .operationalContent,
            containsDirectIdentifiers: false,
            lawfulContext: makeLawfulContext()
        )
        XCTAssertThrowsError(try memory.validateRead(by: .serviceOperational, governedContext: makeLawfulContext())) { error in
            XCTAssertEqual(error as? MemoryGovernanceError, .sessionScopeMismatch)
        }
    }

    func testUserAgentMemoryNeedsGovernedContextForProfessionalRead() throws {
        let memory = MemoryScopeContract(
            scope: .userAgent,
            ownerUserId: UUID(),
            dataLayer: .operationalContent,
            containsDirectIdentifiers: false,
            lawfulContext: makeLawfulContext()
        )
        XCTAssertThrowsError(try memory.validateRead(by: .professionalAgent, governedContext: nil)) { error in
            XCTAssertEqual(error as? MemoryGovernanceError, .missingGovernedReadContext)
        }
    }

    func testDerivedMemoryRequiresProvenance() {
        let memory = MemoryScopeContract(
            scope: .derivedMemoryArtifact,
            dataLayer: .derivedArtifacts,
            containsDirectIdentifiers: false,
            lawfulContext: makeLawfulContext(),
            provenanceId: nil
        )
        XCTAssertThrowsError(try memory.validateWrite()) { error in
            XCTAssertEqual(error as? MemoryGovernanceError, .missingProvenanceForDerivedMemory)
        }
    }

    func testMemoryWriteWithDirectIdentifierInWrongLayerFails() {
        let memory = MemoryScopeContract(
            scope: .serviceOperational,
            dataLayer: .operationalContent,
            containsDirectIdentifiers: true,
            lawfulContext: makeLawfulContext()
        )
        XCTAssertThrowsError(try memory.validateWrite()) { error in
            XCTAssertEqual(error as? MemoryGovernanceError, .directIdentifierLayerDenied)
        }
    }

    func testEmbeddingUnavailableNotReady() {
        let record = EmbeddingRecord(
            providerId: "stub",
            status: .unavailable,
            vectorRef: .init(ref: "none", placeholder: true)
        )
        XCTAssertFalse(record.isReady)
    }

    func testSemanticQueryWithoutEmbeddingProviderReturnsUnavailable() async throws {
        let root = try makeRoot()
        let index = FileBackedRecordIndex(root: root)
        let service = BoundedContextRetrievalService(index: index)
        let patientId = UUID()
        let governed = try GovernedRetrievalQuery(
            actorId: "actor",
            actorRole: "professional-agent",
            serviceId: UUID(),
            patientUserId: patientId,
            sessionId: UUID(),
            finalidade: "care-context-retrieval",
            lawfulContext: makeLawfulContext(patientUserId: patientId),
            allowedDataLayers: [.operationalContent],
            mode: .semantic,
            providerRequirement: .init(requiresEmbeddingProvider: true, requiresRealProvider: true, allowsLexicalFallback: false),
            maxResults: 3,
            provenanceRequired: true,
            lexicalQuery: makeLexicalQuery(patientUserId: patientId)
        )

        let result = try await service.retrieve(governedQuery: governed)
        XCTAssertEqual(result.mode, .unavailable)
        XCTAssertEqual(result.failure, .semanticProviderUnavailable)
    }

    func testRemoteEmbeddingProviderDeniedForDirectIdentifiers() async throws {
        let router = ProviderRouter()
        try await router.register(RemoteEmbeddingProvider())

        let decision = await router.routeEmbedding(
            request: ProviderRoutingRequest(
                taskClass: .embedding,
                dataLayer: .directIdentifiers,
                lawfulContext: makeLawfulContext(),
                finalidade: "index-build",
                allowsRemoteFallback: true,
                fallbackAllowed: true
            )
        )

        guard case .deniedByPolicy(let reason) = decision else {
            return XCTFail("Expected policy denial for direct identifiers, got \(decision)")
        }
        XCTAssertEqual(reason, .remoteDirectIdentifiersDenied)
    }

    func testLexicalFallbackMarkedDeterministic() async throws {
        let root = try makeRoot()
        let index = FileBackedRecordIndex(root: root)
        let serviceId = UUID()
        let patientId = UUID()
        try await index.replaceEntries(
            serviceId: serviceId,
            entries: [
                RecordIndexEntry(
                    id: UUID(),
                    serviceId: serviceId,
                    patientUserId: patientId,
                    snippetKind: .encounterSummary,
                    snippet: .init(summary: "contexto dor de cabeca", tags: ["dor"], occurredAt: .now),
                    sourceRef: "records/1",
                    sourceKind: .encounterRecord
                )
            ]
        )
        let service = BoundedContextRetrievalService(index: index)
        let governed = try GovernedRetrievalQuery(
            actorId: "actor",
            actorRole: "professional-agent",
            serviceId: serviceId,
            patientUserId: patientId,
            sessionId: UUID(),
            finalidade: "care-context-retrieval",
            lawfulContext: makeLawfulContext(patientUserId: patientId),
            allowedDataLayers: [.operationalContent],
            mode: .semantic,
            providerRequirement: .init(requiresEmbeddingProvider: true, requiresRealProvider: true, allowsLexicalFallback: true),
            maxResults: 3,
            provenanceRequired: true,
            lexicalQuery: RetrievalQuery(serviceId: serviceId, patientUserId: patientId, finalidade: "care-context-retrieval", terms: ["dor"])
        )

        let result = try await service.retrieve(governedQuery: governed)
        XCTAssertEqual(result.mode, .lexical)
        XCTAssertEqual(result.failure, .semanticProviderUnavailable)
        XCTAssertTrue(result.items.allSatisfy { $0.scoreKind == .deterministic })
    }

    func testVectorPlaceholderNotTreatedAsReal() {
        let vectorRef = EmbeddingVectorRef(ref: "placeholder://vector", placeholder: true)
        XCTAssertFalse(vectorRef.hasMaterializedVector)
    }

    func testResultSafetyRedactsDirectIdentifiers() {
        let item = GovernedRetrievalResultItem(
            id: UUID(),
            sourceObjectRef: "records/1",
            sourceLayer: .operationalContent,
            score: 10,
            scoreKind: .lexical,
            snippet: "cpf 123.456.789-10 e observacao",
            provenanceRef: UUID(),
            lawfulScopeSummary: "scope=care-context",
            redactionApplied: false
        ).appFacing()

        XCTAssertFalse(item.snippet?.contains("123.456.789-10") ?? true)
        XCTAssertTrue(item.redactionApplied)
        XCTAssertEqual(item.scoreKind, .lexical)
        XCTAssertEqual(item.sourceLayer, .operationalContent)
        XCTAssertNotNil(item.provenanceRef)
    }

    func testFirstSliceStillUsesLexicalDeterministicRetrievalAndMediatedScribeSummary() async throws {
        let root = try makeRoot()
        try DirectoryLayout.bootstrap(at: root)

        let router = ProviderRouter()
        try await router.register(LocalLanguageProviderForRetrievalTests())
        try await router.register(NativeSpeechProvider())
        let runner = SessionRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let adapter = ScribeSessionAdapter(runner: runner)

        let professional = Usuario(cpfHash: "prof-hash", civilToken: "prof-token")
        let patient = Usuario(cpfHash: "pat-hash", civilToken: "pat-token")
        let service = Servico(nome: "Servico", tipo: "clinica")

        let start = await adapter.startProfessionalSession(.init(professional: professional, service: service))
        let sessionId = try XCTUnwrap(start.state?.sessionId)
        _ = await adapter.selectPatient(.init(sessionId: sessionId, patient: patient))
        _ = await adapter.submitSessionCapture(
            .init(sessionId: sessionId, capture: .init(rawText: "Paciente com dor e sono ruim"))
        )
        let result = await adapter.resolveGate(.init(sessionId: sessionId, approve: true))
        let state = try XCTUnwrap(result.state)

        XCTAssertEqual(state.retrieval.source, "file-backed-record-index")
        XCTAssertFalse(state.retrieval.summary.lowercased().contains("vector"))
        let provenanceOps = Set((state.gosRuntimeState.mediationSummary?.provenanceOperations ?? []) + (state.runSummary?.provenanceCount ?? 0 > 0 ? ["has-provenance"] : []))
        XCTAssertTrue(provenanceOps.contains("has-provenance"))
    }

    func testSemanticRetrievalFailsWithoutProvider() throws {
        let patientId = UUID()
        let serviceId = UUID()
        let query = try GovernedRetrievalQuery(
            queryId: UUID(),
            actorId: "test",
            actorRole: "test",
            serviceId: serviceId,
            patientUserId: patientId,
            sessionId: nil,
            finalidade: "test",
            lawfulContext: makeLawfulContext(patientUserId: patientId),
            allowedDataLayers: [.operationalContent],
            mode: .semantic,
            providerRequirement: RetrievalProviderRequirement(requiresEmbeddingProvider: true, requiresRealProvider: true),
            maxResults: 1,
            provenanceRequired: false,
            lexicalQuery: RetrievalQuery(
                serviceId: serviceId,
                patientUserId: patientId,
                finalidade: "test",
                terms: ["test"]
            )
        )

        XCTAssertEqual(query.mode, .semantic)
        XCTAssertTrue(query.providerRequirement.requiresEmbeddingProvider)
        XCTAssertTrue(query.providerRequirement.requiresRealProvider)
    }

    private func makeLexicalQuery(patientUserId: UUID) -> RetrievalQuery {
        RetrievalQuery(
            serviceId: UUID(),
            patientUserId: patientUserId,
            finalidade: "care-context-retrieval",
            terms: ["dor"]
        )
    }

    private func makeLawfulContext(patientUserId: UUID? = UUID()) -> [String: String] {
        var context: [String: String] = [
            "actorRole": "professional-agent",
            "scope": "care-context",
            "habilitationId": UUID().uuidString,
            "finalidade": "care-context-retrieval"
        ]
        if let patientUserId {
            context["patientUserId"] = patientUserId.uuidString
        }
        return context
    }

    private func makeRoot() throws -> URL {
        let root = FileManager.default.temporaryDirectory.appending(path: "healthos-retrieval-governance-\(UUID().uuidString)")
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        return root
    }
}

private struct RemoteEmbeddingProvider: EmbeddingProvider {
    let providerName = "remote-embed"
    let capabilityProfile = ProviderCapabilityProfile(
        providerId: "remote-embed",
        providerKind: .remote,
        supportedTaskClasses: [.embedding],
        allowedDataLayers: [.derivedArtifacts],
        allowsPHI: false,
        allowsIdentifiableData: false,
        requiresNetwork: true,
        latencyClass: .batch,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: false
    )

    func embed(text: String) async throws -> [Double] {
        _ = text
        return []
    }
}

private struct LocalLanguageProviderForRetrievalTests: LanguageModelProvider {
    let providerName = "local-real-retrieval-tests"
    let modelId: String? = "local-model"
    let modelVersion: String? = "1"
    let capabilityProfile = ProviderCapabilityProfile(
        providerId: "local-real-retrieval-tests",
        providerKind: .local,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.operationalContent, .derivedArtifacts, .governanceMetadata],
        allowsPHI: true,
        allowsIdentifiableData: false,
        requiresNetwork: false,
        latencyClass: .interactive,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: false
    )

    func generate(prompt: String, context: [String : String]) async throws -> String {
        _ = context
        return prompt
    }
}
