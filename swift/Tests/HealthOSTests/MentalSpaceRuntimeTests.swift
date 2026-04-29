import XCTest
@testable import HealthOSCore
@testable import HealthOSAACI
@testable import HealthOSProviders
@testable import HealthOSFirstSliceSupport
@testable import HealthOSMentalSpace

final class MentalSpaceRuntimeTests: XCTestCase {
    func testPipelineOrderingBlocksDownstreamStagesUntilPrerequisitesExist() throws {
        let empty = MentalSpaceRunArtifacts()

        XCTAssertNoThrow(try MentalSpacePipelineValidator.validateCanRun(stage: .normalization, state: empty))
        XCTAssertThrowsError(try MentalSpacePipelineValidator.validateCanRun(stage: .asl, state: empty)) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .normalizedTranscriptRequired)
        }
        XCTAssertThrowsError(try MentalSpacePipelineValidator.validateCanRun(stage: .vdlp, state: empty)) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .aslRequired)
        }
        XCTAssertThrowsError(try MentalSpacePipelineValidator.validateCanRun(stage: .gem, state: empty)) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .vdlpRequired)
        }
    }

    func testMentalSpaceAsyncJobKindsUseExistingGovernedRuntimeSubstrate() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = AsyncJobDescriptor(
            kind: .mentalSpaceASL,
            requestedByActor: "mental-space.runtime",
            submissionSource: .system,
            lawfulContextRequirement: .none,
            dataLayersTouched: [.derivedArtifacts],
            inputRefs: ["normalized-transcript-ref"],
            idempotencyKey: "mental-space-asl-\(UUID().uuidString)",
            retryPolicy: .init(maxRetries: 1),
            idempotent: true
        )

        let enqueued = try await runtime.enqueue(job)
        let completed = try await runtime.runJob(id: enqueued.id, lawfulContext: nil) { _, _ in
            .completed(outputRefs: ["asl-artifact-ref"], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(completed.kind, .mentalSpaceASL)
        XCTAssertEqual(completed.state, .completed)
        let events = await runtime.observabilityEvents()
        XCTAssertTrue(events.contains { $0.kind == .completed && $0.jobKind == .mentalSpaceASL })
        XCTAssertTrue(events.allSatisfy { !$0.source.lowercased().contains("cpf") })
    }

    func testNormalizationWithOnlyAppleStubDegradesWithoutUsingStubOutput() async throws {
        let router = ProviderRouter()
        try await router.register(AppleFoundationProvider())
        let orchestrator = AACIOrchestrator(router: router)
        let result = await orchestrator.normalizeTranscript(
            MentalSpaceNormalizationRequest(
                transcriptText: "Paciente relata sono ruim.",
                sourceTranscriptRef: StorageObjectRef(
                    objectPath: "/tmp/transcript.bin",
                    contentHash: "hash",
                    layer: .operationalContent,
                    kind: "transcripts"
                ),
                lawfulContext: ["scope": "care-context", "finalidade": "care-context-retrieval"]
            )
        )

        XCTAssertEqual(result.status, .degraded)
        XCTAssertNil(result.normalizedText)
        XCTAssertEqual(result.providerExecution?.status, ProviderExecutionStatus.stubOnly.rawValue)
    }

    func testFirstSlicePersistsNormalizedTranscriptAsDerivedMentalSpaceArtifact() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let router = ProviderRouter()
        try await router.register(LocalNormalizerProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))

        let result = try await runner.run(
            input: makeSessionInput(text: " Paciente   relata sono ruim. ")
        )

        let normalized = try XCTUnwrap(result.mentalSpace.normalizedTranscript)
        let transcriptRef = try XCTUnwrap(result.transcription.transcriptRef)
        XCTAssertEqual(normalized.objectRef.layer, .derivedArtifacts)
        XCTAssertEqual(normalized.metadata.sourceTranscriptRef, transcriptRef.objectPath)
        XCTAssertEqual(normalized.metadata.inputHash, transcriptRef.contentHash)
        XCTAssertEqual(normalized.metadata.legalAuthorizing, false)
        XCTAssertEqual(normalized.metadata.gateStillRequired, true)
        XCTAssertEqual(result.summary.mentalSpaceNormalizationStatus, .ready)
        XCTAssertEqual(result.summary.mentalSpaceNormalizedTranscriptObjectPath, normalized.objectRef.objectPath)
        XCTAssertTrue(result.provenanceRecords.contains { $0.operation == "mental-space.normalize.transcript" })

        let artifactData = try Data(contentsOf: URL(fileURLWithPath: normalized.objectRef.objectPath))
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        let artifact = try decoder.decode(NormalizedTranscriptArtifact.self, from: artifactData)
        XCTAssertEqual(artifact.normalizedTranscript, "Paciente relata sono ruim.")
        XCTAssertEqual(artifact.sourceTranscriptObjectRef.objectPath, transcriptRef.objectPath)
    }

    func testScribeBridgeShowsMentalSpaceStatusWithoutRawArtifactPayload() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let router = ProviderRouter()
        try await router.register(LocalNormalizerProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let adapter = ScribeFirstSliceAdapter(runner: runner)

        let professional = Usuario(cpfHash: "prof-hash", civilToken: "prof-token")
        let patient = Usuario(cpfHash: "patient-hash", civilToken: "patient-token")
        let service = Servico(nome: "Servico", tipo: "clinica")

        let start = await adapter.startProfessionalSession(.init(professional: professional, service: service))
        let sessionId = try XCTUnwrap(start.state?.sessionId)
        _ = await adapter.selectPatient(.init(sessionId: sessionId, patient: patient))
        _ = await adapter.submitSessionCapture(.init(sessionId: sessionId, capture: .init(rawText: "Paciente relata dor.")))
        let resolved = await adapter.resolveGate(.init(sessionId: sessionId, approve: false))
        let state = try XCTUnwrap(resolved.state)

        let normalization = try XCTUnwrap(
            state.mentalSpaceRuntimeState.stages.first { $0.stage == .normalization }
        )
        XCTAssertEqual(normalization.status, .ready)
        XCTAssertFalse(state.mentalSpaceRuntimeState.legalAuthorizing)
        XCTAssertTrue(state.mentalSpaceRuntimeState.clinicianReviewRequired)
        XCTAssertFalse(state.mentalSpaceRuntimeState.summary.contains("Paciente relata dor."))
    }

    private func makeTempRoot() -> URL {
        URL(fileURLWithPath: NSTemporaryDirectory(), isDirectory: true)
            .appendingPathComponent("HealthOSMentalSpaceRuntimeTests-\(UUID().uuidString)", isDirectory: true)
    }

    private func makeSessionInput(text: String) -> FirstSliceSessionInput {
        FirstSliceSessionInput(
            professional: Usuario(cpfHash: "prof", civilToken: "prof"),
            patient: Usuario(cpfHash: "patient", civilToken: "patient"),
            service: Servico(nome: "svc", tipo: "ambulatory"),
            capture: SessionCaptureInput(rawText: text),
            gateApprove: false
        )
    }
}

private struct LocalNormalizerProvider: LanguageModelProvider {
    let providerName = "local-normalizer"
    let modelId: String? = "local-normalizer-v1"
    let modelVersion: String? = "1.0.0"
    let capabilityProfile = ProviderCapabilityProfile(
        providerId: "local-normalizer",
        providerKind: .appleNative,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.derivedArtifacts],
        allowsPHI: true,
        allowsIdentifiableData: false,
        requiresNetwork: false,
        latencyClass: .interactive,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: false
    )

    func generate(prompt: String, context: [String: String]) async throws -> String {
        XCTAssertEqual(context["task"], "mental-space-transcript-normalization")
        return prompt
            .split(whereSeparator: { $0.isWhitespace })
            .joined(separator: " ")
    }
}


extension MentalSpaceRuntimeTests {
    func testASLExecutorFailsOnEmptyInput() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: false))
        let executor = try ASLExecutor(router: router)
        await XCTAssertThrowsErrorAsync(try await executor.execute(patientId: "p", transcriptionText: "   ", sourceTranscriptRef: "ref", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? ASLExecutorError, .emptyTranscription)
        }
    }

    func testASLExecutorFailsWhenProviderIsStubOnly() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: true))
        let executor = try ASLExecutor(router: router)
        await XCTAssertThrowsErrorAsync(try await executor.execute(patientId: "p", transcriptionText: "texto", sourceTranscriptRef: "ref", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? ASLExecutorError, .providerUnavailable)
        }
    }

    func testASLExecutorReturnsArtifactAndProvenanceMarker() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: false))
        let executor = try ASLExecutor(router: router)
        let result = try await executor.execute(patientId: "p", transcriptionText: "texto clínico", sourceTranscriptRef: "src-ref", lawfulContext: ["finalidade": "care-context"])
        XCTAssertEqual(result.provenanceOperation, "mental-space.asl")
        XCTAssertEqual(result.artifact.metadata.stage, .asl)
        XCTAssertEqual(result.artifact.metadata.sourceTranscriptRef, "src-ref")
        XCTAssertFalse(result.artifact.metadata.legalAuthorizing)
        XCTAssertTrue(result.artifact.metadata.gateStillRequired)
        XCTAssertNotEqual(result.artifact.linguisticSummary, MockASLProvider.rawPayload)
    }

    func testASLPipelineRefusesWhenNormalizationMissing() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: false))
        let orchestrator = try MentalSpacePipelineOrchestrator(aslExecutor: ASLExecutor(router: router))
        await XCTAssertThrowsErrorAsync(try await orchestrator.runASL(patientId: "p", normalizedTranscriptText: "text", sourceTranscriptRef: "src", lawfulContext: [:], state: MentalSpaceRunArtifacts())) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .normalizedTranscriptRequired)
        }
    }
}

private struct MockASLProvider: LanguageModelProvider {
    static let rawPayload = "{\"sintese_interpretativa\":{\"perfil_linguistico_geral\":\"Resumo ASL\",\"achados_mais_salientes\":[\"Evidência A\",\"Evidência B\"]}}"
    let validJSON: Bool
    let isStub: Bool
    let providerName = "anthropic-claude"
    let modelId: String? = "claude-sonnet-4"
    let modelVersion: String? = "2025-05-14"

    var capabilityProfile: ProviderCapabilityProfile {
        ProviderCapabilityProfile(providerId: "anthropic-claude", providerKind: .remote, supportedTaskClasses: [.languageModel], allowedDataLayers: [.derivedArtifacts], allowsPHI: true, allowsIdentifiableData: false, requiresNetwork: true, latencyClass: .batch, supportsCostReporting: false, supportsProvenanceReporting: true, isStub: isStub)
    }

    func generate(prompt: String, context: [String : String]) async throws -> String {
        XCTAssertTrue(prompt.contains("Falante ID"))
        XCTAssertEqual(context["temperature"], "0")
        XCTAssertEqual(context["max_tokens"], "60000")
        XCTAssertEqual(context["anthropic-beta"], "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11")
        return validJSON ? Self.rawPayload : "not-json"
    }
}

private extension XCTestCase {
    func XCTAssertThrowsErrorAsync<T>(
        _ expression: @autoclosure () async throws -> T,
        _ errorHandler: (Error) -> Void = { _ in },
        file: StaticString = #filePath,
        line: UInt = #line
    ) async {
        do {
            _ = try await expression()
            XCTFail("Expected error to be thrown", file: file, line: line)
        } catch {
            errorHandler(error)
        }
    }
}


extension MentalSpaceRuntimeTests {
    func testVDLPExecutorFailsWhenASLMissing() async throws {
        let router = ProviderRouter()
        try await router.register(MockVDLPProvider(isStub: false))
        let executor = try VDLPExecutor(router: router)
        await XCTAssertThrowsErrorAsync(try await executor.execute(patientId: "p", aslData: Data(), patientSpeech: "fala", sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? VDLPExecutorError, .triadIncomplete)
        }
    }

    func testVDLPExecutorFailsOnEmptySpeech() async throws {
        let router = ProviderRouter()
        try await router.register(MockVDLPProvider(isStub: false))
        let executor = try VDLPExecutor(router: router)
        await XCTAssertThrowsErrorAsync(try await executor.execute(patientId: "p", aslData: Data(MockASLProvider.rawPayload.utf8), patientSpeech: "   ", sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? VDLPExecutorError, .emptyPatientSpeech)
        }
    }

    func testVDLPExecutorFailsWhenProviderIsStubOnly() async throws {
        let router = ProviderRouter()
        try await router.register(MockVDLPProvider(isStub: true))
        let executor = try VDLPExecutor(router: router)
        await XCTAssertThrowsErrorAsync(try await executor.execute(patientId: "p", aslData: Data(MockASLProvider.rawPayload.utf8), patientSpeech: "fala", sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? VDLPExecutorError, .providerUnavailable)
        }
    }

    func testVDLPExecutorReturnsArtifactWith15DimensionsAndProvenance() async throws {
        let router = ProviderRouter()
        try await router.register(MockVDLPProvider(isStub: false))
        let executor = try VDLPExecutor(router: router)
        let result = try await executor.execute(patientId: "p", aslData: Data(MockASLProvider.rawPayload.utf8), patientSpeech: "fala longa", sourceTranscriptRef: "src", lawfulContext: ["finalidade": "care-context"])
        XCTAssertEqual(result.provenanceOperation, "mental-space.vdlp")
        XCTAssertEqual(result.artifact.metadata.stage, .vdlp)
        XCTAssertEqual(result.artifact.dimensionRefs.count, 15)
        XCTAssertEqual(Set(result.artifact.dimensionRefs), Set((1...15).map { "v\($0)" }))
        XCTAssertFalse(result.artifact.metadata.legalAuthorizing)
        XCTAssertTrue(result.artifact.metadata.gateStillRequired)
        XCTAssertFalse(result.artifact.dimensionalSummary.contains("dimensoes_espaco_mental"))
    }

    func testVDLPPipelineRefusesWhenASLMissing() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: false))
        let aslExecutor = try ASLExecutor(router: router)
        let vdlpExecutor = try VDLPExecutor(router: router)
        let orchestrator = MentalSpacePipelineOrchestrator(aslExecutor: aslExecutor, vdlpExecutor: vdlpExecutor)
        await XCTAssertThrowsErrorAsync(try await orchestrator.runVDLP(patientId: "p", aslData: Data(MockASLProvider.rawPayload.utf8), patientSpeech: "fala", sourceTranscriptRef: "src", lawfulContext: [:], state: MentalSpaceRunArtifacts())) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .aslRequired)
        }
    }
}

private struct MockVDLPProvider: LanguageModelProvider {
    static let validPayload = "{\"dimensoes_espaco_mental\":{\"v1\":{\"score\":0.5}},\"perfil_dimensional_integrativo\":{\"sintese_global\":\"Resumo VDLP\",\"evidencias\":[\"E1\"]}}"

    let isStub: Bool
    let providerName = "anthropic-claude"
    let modelId: String? = "claude-sonnet-4"
    let modelVersion: String? = "2025-05-14"

    var capabilityProfile: ProviderCapabilityProfile {
        ProviderCapabilityProfile(providerId: "anthropic-claude", providerKind: .remote, supportedTaskClasses: [.languageModel], allowedDataLayers: [.derivedArtifacts], allowsPHI: true, allowsIdentifiableData: false, requiresNetwork: true, latencyClass: .batch, supportsCostReporting: false, supportsProvenanceReporting: true, isStub: isStub)
    }

    func generate(prompt: String, context: [String : String]) async throws -> String {
        XCTAssertEqual(context["temperature"], "0")
        XCTAssertEqual(context["max_tokens"], "60000")
        XCTAssertEqual(context["anthropic-beta"], "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11")
        XCTAssertTrue(prompt.contains("VDLP"))
        let dims = (1...15).reduce(into: [String: Any]()) { $0["v\($1)"] = ["score": 0.5] }
        let payload: [String: Any] = [
            "dimensoes_espaco_mental": dims,
            "perfil_dimensional_integrativo": ["sintese_global": "Resumo VDLP", "evidencias": ["E1", "E2"]]
        ]
        let data = try JSONSerialization.data(withJSONObject: payload)
        return String(decoding: data, as: UTF8.self)
    }
}


extension MentalSpaceRuntimeTests {
    func testGEMBuilderFailsWhenASLOrVDLPMissing() async throws {
        let router = ProviderRouter()
        try await router.register(MockGEMProvider(isStub: false))
        let builder = try GEMArtifactBuilder(router: router)
        await XCTAssertThrowsErrorAsync(try await builder.execute(patientId: "p", transcriptionText: "texto", aslData: Data(), vdlpData: Data(MockVDLPProvider.validPayload.utf8), sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? GEMArtifactBuilderError, .triadIncomplete(missing: "asl"))
        }
        await XCTAssertThrowsErrorAsync(try await builder.execute(patientId: "p", transcriptionText: "texto", aslData: Data(MockASLProvider.rawPayload.utf8), vdlpData: Data(), sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? GEMArtifactBuilderError, .triadIncomplete(missing: "vdlp"))
        }
    }

    func testGEMBuilderFailsOnEmptyTranscriptAndStubProvider() async throws {
        let router = ProviderRouter()
        try await router.register(MockGEMProvider(isStub: false))
        let builder = try GEMArtifactBuilder(router: router)
        await XCTAssertThrowsErrorAsync(try await builder.execute(patientId: "p", transcriptionText: " ", aslData: Data(MockASLProvider.rawPayload.utf8), vdlpData: Data(MockVDLPProvider.validPayload.utf8), sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? GEMArtifactBuilderError, .emptyTranscription)
        }

        let stubRouter = ProviderRouter()
        try await stubRouter.register(MockGEMProvider(isStub: true))
        let stubBuilder = try GEMArtifactBuilder(router: stubRouter)
        await XCTAssertThrowsErrorAsync(try await stubBuilder.execute(patientId: "p", transcriptionText: "texto", aslData: Data(MockASLProvider.rawPayload.utf8), vdlpData: Data(MockVDLPProvider.validPayload.utf8), sourceTranscriptRef: "src", lawfulContext: [:])) { error in
            XCTAssertEqual(error as? GEMArtifactBuilderError, .providerUnavailable)
        }
    }

    func testGEMBuilderReturnsArtifactWithFourLayersAndProvenance() async throws {
        let router = ProviderRouter()
        try await router.register(MockGEMProvider(isStub: false))
        let builder = try GEMArtifactBuilder(router: router)
        let result = try await builder.execute(patientId: "p", transcriptionText: "texto longo", aslData: Data(MockASLProvider.rawPayload.utf8), vdlpData: Data(MockVDLPProvider.validPayload.utf8), sourceTranscriptRef: "src", lawfulContext: ["finalidade": "care-context"])
        XCTAssertEqual(result.provenanceOperation, "mental-space.gem")
        XCTAssertEqual(result.artifact.layerRefs, ["aje", "ire", "e", "epe"])
        XCTAssertEqual(result.artifact.metadata.stage, .gem)
        XCTAssertFalse(result.artifact.metadata.legalAuthorizing)
        XCTAssertTrue(result.artifact.metadata.gateStillRequired)
    }

    func testGEMPipelineRefusesWhenVDLPMissing() async throws {
        let router = ProviderRouter()
        try await router.register(MockASLProvider(validJSON: true, isStub: false))
        try await router.register(MockVDLPProvider(isStub: false))
        try await router.register(MockGEMProvider(isStub: false))
        let orchestrator = try MentalSpacePipelineOrchestrator(aslExecutor: ASLExecutor(router: router), vdlpExecutor: VDLPExecutor(router: router), gemBuilder: GEMArtifactBuilder(router: router))
        await XCTAssertThrowsErrorAsync(try await orchestrator.runGEM(patientId: "p", normalizedTranscriptText: "text", aslData: Data(MockASLProvider.rawPayload.utf8), vdlpData: Data(MockVDLPProvider.validPayload.utf8), sourceTranscriptRef: "src", lawfulContext: [:], state: MentalSpaceRunArtifacts())) { error in
            XCTAssertEqual(error as? MentalSpacePipelineError, .vdlpRequired)
        }
    }
}

private struct MockGEMProvider: LanguageModelProvider {
    let isStub: Bool
    let providerName = "anthropic-claude"
    let modelId: String? = "claude-sonnet-4"
    let modelVersion: String? = "2025-05-14"

    var capabilityProfile: ProviderCapabilityProfile {
        ProviderCapabilityProfile(providerId: "anthropic-claude", providerKind: .remote, supportedTaskClasses: [.languageModel], allowedDataLayers: [.derivedArtifacts], allowsPHI: true, allowsIdentifiableData: false, requiresNetwork: true, latencyClass: .batch, supportsCostReporting: false, supportsProvenanceReporting: true, isStub: isStub)
    }

    func generate(prompt: String, context: [String : String]) async throws -> String {
        XCTAssertEqual(context["temperature"], "0.2")
        XCTAssertEqual(context["max_tokens"], "60000")
        XCTAssertEqual(context["anthropic-beta"], "prompt-caching-2024-07-31,extended-cache-ttl-2025-04-11")
        XCTAssertTrue(prompt.contains("GEM"))
        let payload: [String: Any] = ["gem": ["aje": [["n":"1"]], "ire": [["n":"2"]], "e": [["n":"3"]], "epe": [["n":"4"]]], "statistics": ["global_summary": "Resumo GEM"]]
        let data = try JSONSerialization.data(withJSONObject: payload)
        return String(decoding: data, as: UTF8.self)
    }
}
