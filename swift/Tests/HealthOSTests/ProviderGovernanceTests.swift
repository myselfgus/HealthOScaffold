import XCTest
@testable import HealthOSProviders
@testable import HealthOSAACI
@testable import HealthOSCore

final class ProviderGovernanceTests: XCTestCase {
    func testProviderWithoutCapabilityProfileIsRejected() async throws {
        let router = ProviderRouter()
        let invalid = InvalidCapabilityLanguageProvider(
            providerName: "invalid-provider",
            capabilityProfile: ProviderCapabilityProfile(
                providerId: "",
                providerKind: .local,
                supportedTaskClasses: [],
                allowedDataLayers: [],
                allowsPHI: false,
                allowsIdentifiableData: false,
                requiresNetwork: false,
                latencyClass: .interactive,
                supportsCostReporting: false,
                supportsProvenanceReporting: true,
                isStub: true
            )
        )

        await XCTAssertThrowsErrorAsync(try await router.register(invalid)) { error in
            XCTAssertEqual(error as? ProviderCapabilityValidationError, .missingProviderId)
        }
    }

    func testProviderLocalCompatibleTaskIsSelected() async throws {
        let router = ProviderRouter()
        try await router.register(LocalRealLanguageProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .derivedArtifacts,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: false,
                fallbackAllowed: true
            )
        )

        guard case .selected(let selected) = decision else {
            return XCTFail("Expected selected local provider, got \(decision)")
        }
        XCTAssertEqual(selected.providerId, "local-real")
        XCTAssertFalse(selected.isStub)
    }

    func testProviderIncompatibleTaskIsRejected() async throws {
        let router = ProviderRouter()
        try await router.register(LocalRealLanguageProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .speechToText,
                dataLayer: .derivedArtifacts,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: false,
                fallbackAllowed: true
            )
        )

        guard case .deniedByPolicy(let reason) = decision else {
            return XCTFail("Expected task-not-supported denial, got \(decision)")
        }
        XCTAssertEqual(reason, .taskNotSupported)
    }

    func testProviderStubIsMarkedStubOnly() async throws {
        let router = ProviderRouter()
        try await router.register(AppleFoundationProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .derivedArtifacts,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: false,
                fallbackAllowed: true
            )
        )

        guard case .stubOnly(let selection, let reason) = decision else {
            return XCTFail("Expected stub-only result, got \(decision)")
        }
        XCTAssertTrue(selection.isStub)
        XCTAssertEqual(reason, .noRealProviderAvailable)
    }

    func testRoutingSelectsLocalWhenAvailable() async throws {
        let router = ProviderRouter()
        try await router.register(LocalRealLanguageProvider())
        try await router.register(RemoteRealLanguageProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .derivedArtifacts,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: true,
                allowsRemoteForOperationalSensitiveContent: true,
                fallbackAllowed: true,
                preferLocal: true
            )
        )

        guard case .selected(let selection) = decision else {
            return XCTFail("Expected local selected, got \(decision)")
        }
        XCTAssertEqual(selection.providerId, "local-real")
    }

    func testRoutingDeniesRemoteForDirectIdentifiers() async throws {
        let router = ProviderRouter()
        try await router.register(RemoteRealLanguageProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .directIdentifiers,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: true,
                fallbackAllowed: true
            )
        )

        guard case .deniedByPolicy(let reason) = decision else {
            return XCTFail("Expected policy denial, got \(decision)")
        }
        XCTAssertEqual(reason, .remoteDirectIdentifiersDenied)
    }

    func testRoutingDeniesRemoteForReidentificationMapping() async throws {
        let router = ProviderRouter()
        try await router.register(RemoteRealLanguageProvider())

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .reidentificationMapping,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: true,
                fallbackAllowed: true
            )
        )

        guard case .deniedByPolicy(let reason) = decision else {
            return XCTFail("Expected policy denial, got \(decision)")
        }
        XCTAssertEqual(reason, .remoteReidentificationDenied)
    }

    func testRoutingReturnsTypedUnavailableWhenNoProviderSatisfiesPolicy() async throws {
        let router = ProviderRouter()

        let decision = await router.routeLanguage(
            request: ProviderRoutingRequest(
                taskClass: .languageModel,
                dataLayer: .derivedArtifacts,
                lawfulContext: ["scope": "test"],
                finalidade: "unit-test",
                allowsRemoteFallback: false,
                fallbackAllowed: false
            )
        )

        guard case .unavailable(let reason) = decision else {
            return XCTFail("Expected unavailable typed result, got \(decision)")
        }
        XCTAssertEqual(reason, .noProviderAvailable)
    }

    func testRemoteFallbackGuardFailClosedWithoutPolicy() async throws {
        let provider = RemoteFallbackProvider()
        await XCTAssertThrowsErrorAsync(
            try await provider.guardedGenerate(
                prompt: "safe",
                context: [:],
                routingRequest: ProviderRoutingRequest(
                    taskClass: .languageModel,
                    dataLayer: .derivedArtifacts,
                    lawfulContext: ["scope": "test"],
                    finalidade: "unit-test",
                    allowsRemoteFallback: false,
                    fallbackAllowed: true
                )
            )
        ) { error in
            XCTAssertEqual(error as? RemoteFallbackGuardError, .missingExplicitPolicy)
        }
    }

    func testAudioWithoutRealSTTDoesNotGenerateFakeTranscript() async throws {
        let router = ProviderRouter()
        try await router.register(NativeSpeechProvider())
        let orchestrator = AACIOrchestrator(router: router)
        let output = await orchestrator.transcribe(
            TranscriptionInput(
                captureMode: .localAudioFile,
                audioCapture: AudioCaptureArtifact(
                    reference: AudioCaptureReference(filePath: "/tmp/audio.wav", displayName: "audio.wav"),
                    storedRef: StorageObjectRef(
                        objectPath: "tmp/audio.wav",
                        contentHash: "abc",
                        layer: .operationalContent,
                        kind: "audio"
                    )
                )
            )
        )

        XCTAssertEqual(output.status.rawValue, TranscriptionStatus.degraded.rawValue)
        XCTAssertNil(output.transcriptText)
        XCTAssertEqual(output.providerExecution?.status, ProviderExecutionStatus.stubOnly.rawValue)
        XCTAssertEqual(output.providerExecution?.isStub, true)
    }

    func testSeededTextNotMarkedAsAudioTranscription() async throws {
        let orchestrator = AACIOrchestrator(router: ProviderRouter())
        let output = await orchestrator.transcribe(
            TranscriptionInput(captureMode: .seededText, seededText: "texto sem audio")
        )

        XCTAssertEqual(output.status.rawValue, TranscriptionStatus.ready.rawValue)
        XCTAssertEqual(output.source, "seeded-text")
        XCTAssertEqual(output.providerExecution?.providerId, "seeded-text")
        XCTAssertEqual(output.providerExecution?.reason, "input-seeded-text")
    }

    func testModelDraftCannotPromoteWithoutEvaluation() async throws {
        let registry = ModelRegistry()
        await registry.register(
            ModelRegistryEntry(
                modelId: "model-a",
                providerId: "local-real",
                modelName: "Local Test Model",
                modelVersion: "1.0.0",
                taskClass: .languageModel,
                providerKind: .local,
                status: .draft,
                evaluationRefs: [],
                adapterRefs: [],
                dataGovernanceClass: "operational",
                provenanceRequirements: ["provider_id", "task_class"]
            )
        )

        await XCTAssertThrowsErrorAsync(try await registry.promote(modelId: "model-a", notes: "missing eval")) { error in
            XCTAssertEqual(error as? ModelRegistryError, .draftPromotionRequiresEvaluation)
        }
    }

    func testRevokedModelCannotBeSelected() async throws {
        let registry = ModelRegistry()
        await registry.register(
            ModelRegistryEntry(
                modelId: "model-b",
                providerId: "remote-real",
                modelName: "Remote Model",
                modelVersion: "1.0.0",
                taskClass: .languageModel,
                providerKind: .remote,
                status: .revoked,
                evaluationRefs: ["eval-1"],
                adapterRefs: [],
                dataGovernanceClass: "governed",
                provenanceRequirements: ["provider_id", "task_class"]
            )
        )

        await XCTAssertThrowsErrorAsync(try await registry.select(taskClass: .languageModel)) { error in
            XCTAssertEqual(error as? ModelRegistryError, .revokedModelNotSelectable)
        }
    }

    func testDeprecatedModelNotSelectedByDefaultAndPromotedSelectable() async throws {
        let registry = ModelRegistry()
        await registry.register(
            ModelRegistryEntry(
                modelId: "model-c",
                providerId: "local-real",
                modelName: "Deprecated",
                modelVersion: "1.0.0",
                taskClass: .languageModel,
                providerKind: .local,
                status: .deprecated,
                evaluationRefs: ["eval-1"],
                adapterRefs: [],
                dataGovernanceClass: "operational",
                provenanceRequirements: ["provider_id"]
            )
        )
        await registry.register(
            ModelRegistryEntry(
                modelId: "model-d",
                providerId: "local-real",
                modelName: "Promoted",
                modelVersion: "2.0.0",
                taskClass: .languageModel,
                providerKind: .local,
                status: .promoted,
                evaluationRefs: ["eval-2"],
                adapterRefs: [],
                dataGovernanceClass: "operational",
                provenanceRequirements: ["provider_id"]
            )
        )

        let selected = try await registry.select(taskClass: .languageModel)
        XCTAssertEqual(selected.modelId, "model-d")
    }

    func testTrainingJobWithoutDatasetVersionFails() async throws {
        let registry = FineTuningGovernanceRegistry()
        await XCTAssertThrowsErrorAsync(
            try await registry.stageTrainingJob(jobId: "job-1", datasetVersion: nil, baseModelId: "base")
        ) { error in
            XCTAssertEqual(error as? FineTuningGovernanceError, .datasetVersionRequired)
        }
    }

    func testAdapterPromotionWithoutEvaluationFails() async throws {
        let registry = FineTuningGovernanceRegistry()
        await registry.registerAdapter(.init(adapterId: "adapter-a", jobId: "job-a"))
        await XCTAssertThrowsErrorAsync(
            try await registry.promoteAdapter(adapterId: "adapter-a", evaluationId: nil)
        ) { error in
            XCTAssertEqual(error as? FineTuningGovernanceError, .evaluationRequiredForPromotion)
        }
    }

    func testRollbackPreservesPreviousAdapterReference() async throws {
        let registry = FineTuningGovernanceRegistry()
        await registry.registerAdapter(.init(adapterId: "adapter-prev", jobId: "job-prev"))
        await registry.registerAdapter(.init(adapterId: "adapter-new", jobId: "job-new", parentAdapterId: "adapter-prev"))
        await registry.registerEvaluation(.init(evaluationId: "eval-new", adapterId: "adapter-new", notes: "ok"))

        _ = try await registry.promoteAdapter(adapterId: "adapter-new", evaluationId: "eval-new")
        let rollback = try await registry.rollback(to: "adapter-prev", note: "revert")

        XCTAssertEqual(rollback.fromAdapterId, "adapter-new")
        XCTAssertEqual(rollback.toAdapterId, "adapter-prev")
        let current = await registry.currentPromotedAdapterId()
        XCTAssertEqual(current, "adapter-prev")
    }

    func testOnlineInferenceDoesNotCreateTrainingJob() async throws {
        let router = ProviderRouter()
        try await router.register(AppleFoundationProvider())
        let orchestrator = AACIOrchestrator(router: router)
        let output = await orchestrator.transcribe(
            TranscriptionInput(captureMode: .seededText, seededText: "sem treino")
        )

        XCTAssertEqual(output.status.rawValue, TranscriptionStatus.ready.rawValue)
        let tuningRegistry = FineTuningGovernanceRegistry()
        let current = await tuningRegistry.currentPromotedAdapterId()
        XCTAssertNil(current)
    }
}

private struct LocalRealLanguageProvider: LanguageModelProvider {
    let providerName: String = "local-real"
    let modelId: String? = "local-model"
    let modelVersion: String? = "1.0.0"
    let capabilityProfile: ProviderCapabilityProfile = .init(
        providerId: "local-real",
        providerKind: .local,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.operationalContent, .derivedArtifacts],
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

private struct RemoteRealLanguageProvider: LanguageModelProvider {
    let providerName: String = "remote-real"
    let modelId: String? = "remote-model"
    let modelVersion: String? = "1.0.0"
    let capabilityProfile: ProviderCapabilityProfile = .init(
        providerId: "remote-real",
        providerKind: .remote,
        supportedTaskClasses: [.languageModel],
        allowedDataLayers: [.derivedArtifacts],
        allowsPHI: false,
        allowsIdentifiableData: false,
        requiresNetwork: true,
        latencyClass: .batch,
        supportsCostReporting: false,
        supportsProvenanceReporting: true,
        isStub: false
    )

    func generate(prompt: String, context: [String : String]) async throws -> String {
        _ = context
        return prompt
    }
}

private func XCTAssertThrowsErrorAsync<T>(
    _ expression: @autoclosure () async throws -> T,
    _ message: @autoclosure () -> String = "",
    file: StaticString = #filePath,
    line: UInt = #line,
    _ errorHandler: (Error) -> Void = { _ in }
) async {
    do {
        _ = try await expression()
        XCTFail(message(), file: file, line: line)
    } catch {
        errorHandler(error)
    }
}
