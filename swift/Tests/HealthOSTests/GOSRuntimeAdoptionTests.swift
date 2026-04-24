import Foundation
import HealthOSCore
import HealthOSAACI
import HealthOSProviders
import HealthOSFirstSliceSupport

#if canImport(XCTest)
import XCTest

final class GOSRuntimeAdoptionTests: XCTestCase {
    func testAACIComposeDraftsIncludeResolvedGOSMetadata() async throws {
        let orchestrator = AACIOrchestrator(router: ProviderRouter())
        let loader = InMemoryBundleLoader(bundle: makeBundle(bindingPlan: makeCustomBindingPlan()))

        _ = try await orchestrator.activateGOS(specId: "aaci.first-slice", loader: loader)
        let runtimeView = await orchestrator.activeGOSRuntimeView()

        XCTAssertEqual(runtimeView?.specId, "aaci.first-slice")
        XCTAssertEqual(runtimeView?.bundleId, "aaci-first-slice-test-bundle")
        XCTAssertEqual(runtimeView?.actorView(for: "aaci.draft-composer")?.semanticRole, "soap-runtime-composer")
        XCTAssertEqual(
            runtimeView?.primitiveFamilies(for: "aaci.draft-composer") ?? [],
            ["draft_output_spec", "task_spec"]
        )
        XCTAssertEqual(runtimeView?.usedDefaultBindingPlan, false)

        let session = SessaoTrabalho(
            kind: .encounter,
            serviceId: UUID(),
            professionalUserId: UUID(),
            patientUserId: UUID(),
            habilitationId: UUID()
        )
        let context = makeContext()
        let transcription = TranscriptionOutput(status: .ready, source: "seeded-text", transcriptText: "dor e insonia")

        let soap = await orchestrator.composeSOAPDraft(session: session, transcription: transcription, context: context)
        XCTAssertEqual(soap.draft.payload["gosRuntimeActorId"], "aaci.draft-composer")
        XCTAssertEqual(soap.draft.payload["gosPrimitiveFamilies"], "draft_output_spec,task_spec")
        XCTAssertEqual(soap.draft.payload["gosUsedDefaultBindingPlan"], "false")
        XCTAssertTrue(soap.noteSummary.contains("aaci.draft-composer is bound to primitive families [draft_output_spec, task_spec]"))

        let sourceRef = StorageObjectRef(
            objectPath: "services/demo/soap.json",
            contentHash: "hash",
            layer: .derivedArtifacts,
            kind: "drafts-soap"
        )

        let referral = await orchestrator.composeReferralDraft(
            session: session,
            transcription: transcription,
            context: context,
            sourceSOAPDraft: soap,
            sourceSOAPDraftRef: sourceRef
        )
        XCTAssertEqual(referral.draft.payload["gosRuntimeActorId"], "aaci.referral-draft")
        XCTAssertEqual(referral.draft.payload["gosPrimitiveFamilies"], "draft_output_spec,human_gate_requirement_spec")
        XCTAssertTrue((referral.draft.payload["gosReasoningBoundary"] ?? "").contains("aaci.referral-draft"))

        let prescription = await orchestrator.composePrescriptionDraft(
            session: session,
            transcription: transcription,
            context: context,
            sourceSOAPDraft: soap,
            sourceSOAPDraftRef: sourceRef
        )
        XCTAssertEqual(prescription.draft.payload["gosRuntimeActorId"], "aaci.prescription-draft")
        XCTAssertEqual(prescription.draft.payload["gosPrimitiveFamilies"], "draft_output_spec,human_gate_requirement_spec,task_spec")
    }

    func testFirstSliceRecordsDistinctGOSUsageProvenanceWhenBundleIsActive() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try Data(bundle.compiledSpecJSON).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/spec.json"))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(bundle.compilerReport).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/compiler-report.json"))
        try "{\"source_sha256\":\"abc\"}".data(using: .utf8)!.write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/source-provenance.json"))
        try encoder.encode(bundle.runtimeBindingPlan).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/runtime-binding-plan.json"))
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))

        let input = FirstSliceSessionInput(
            professional: Usuario(cpfHash: "prof", civilToken: "prof"),
            patient: Usuario(cpfHash: "patient", civilToken: "patient"),
            service: Servico(nome: "svc", tipo: "ambulatory"),
            capture: SessionCaptureInput(rawText: "Paciente com dor de cabeca e insonia."),
            gateApprove: false
        )

        let result = try await runner.run(input: input)
        let operations = Set(result.provenanceRecords.map(\.operation))
        let draftUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.compose.soap" })
        let referralUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.compose.referral" })
        let prescriptionUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.compose.prescription" })
        let soapEvent = try XCTUnwrap(result.events.first { $0.kind == .draftComposed })
        let referralEvent = try XCTUnwrap(result.events.first { $0.kind == .referralDraftComposed })
        let prescriptionEvent = try XCTUnwrap(result.events.first { $0.kind == .prescriptionDraftComposed })

        XCTAssertTrue(operations.contains("gos.activate"))
        XCTAssertTrue(operations.contains("gos.use.compose.soap"))
        XCTAssertTrue(operations.contains("gos.use.compose.referral"))
        XCTAssertTrue(operations.contains("gos.use.compose.prescription"))
        XCTAssertEqual(draftUsage.actorId, "aaci.draft-composer")
        XCTAssertEqual(referralUsage.actorId, "aaci.referral-draft")
        XCTAssertEqual(prescriptionUsage.actorId, "aaci.prescription-draft")
        XCTAssertEqual(soapEvent.payload.attributes["gosRuntimeActorId"], "aaci.draft-composer")
        XCTAssertEqual(referralEvent.payload.attributes["gosRuntimeActorId"], "aaci.referral-draft")
        XCTAssertEqual(prescriptionEvent.payload.attributes["gosRuntimeActorId"], "aaci.prescription-draft")
        XCTAssertTrue((soapEvent.payload.attributes["gosReasoningBoundary"] ?? "").contains("draft-only under human gate"))
    }

    func testRegistryPromotionHelperPromotesReviewedBundleToActive() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        var bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        bundle = GOSCompiledBundle(
            manifest: GOSBundleManifest(
                bundleId: bundle.manifest.bundleId,
                specId: bundle.manifest.specId,
                specVersion: bundle.manifest.specVersion,
                bundleVersion: bundle.manifest.bundleVersion,
                compilerVersion: bundle.manifest.compilerVersion,
                compiledAt: bundle.manifest.compiledAt,
                lifecycleState: .reviewed,
                compilerReportPath: bundle.manifest.compilerReportPath,
                specPath: bundle.manifest.specPath,
                sourceProvenancePath: bundle.manifest.sourceProvenancePath
            ),
            metadata: bundle.metadata,
            compilerReport: bundle.compilerReport,
            runtimeBindingPlan: bundle.runtimeBindingPlan,
            compiledSpecJSON: bundle.compiledSpecJSON
        )

        try await registry.register(bundle.manifest)
        try await registry.promoteReviewedBundle(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try Data(bundle.compiledSpecJSON).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/spec.json"))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(bundle.compilerReport).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/compiler-report.json"))
        try "{\"source_sha256\":\"abc\"}".data(using: .utf8)!.write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/source-provenance.json"))

        let loaded = try await registry.loadBundle(GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active]))
        XCTAssertEqual(loaded.manifest.lifecycleState, .active)
    }

    func testRegistryLoaderRejectsMismatchedRuntimeBindingPlan() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))

        try await registry.register(bundle.manifest)
        try Data(bundle.compiledSpecJSON).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/spec.json"))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(bundle.compilerReport).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/compiler-report.json"))
        try "{\"source_sha256\":\"abc\"}".data(using: .utf8)!.write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/source-provenance.json"))
        try encoder.encode(GOSRuntimeBindingPlan(specId: "wrong.spec", runtimeKind: .aaci, bindings: [])).write(
            to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/runtime-binding-plan.json")
        )
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected mismatched runtime binding plan to fail bundle loading.")
        } catch {
            let nsError = error as NSError
            XCTAssertEqual(nsError.domain, GOSLoaderFailure.bundleValidationFailure.rawValue)
        }
    }

    private func makeTempRoot() -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "healthos-tests-\(UUID().uuidString)")
        try? FileManager.default.removeItem(at: url)
        return url
    }

    private func makeContext() -> RetrievalContextPackage {
        let query = RetrievalQuery(serviceId: UUID(), patientUserId: UUID(), finalidade: "care-context-retrieval", terms: ["dor"])
        let bounded = BoundedRetrievalResult(query: query, matches: [], source: "local-index", quality: .limited, isFallbackEmpty: false)
        return RetrievalContextPackage(
            finalidade: "care-context-retrieval",
            status: .partial,
            summary: "Resumo bounded.",
            highlights: [],
            supportingMatches: [],
            provenanceHints: [],
            boundedResult: bounded
        )
    }

    private func makeBundle(bindingPlan: GOSRuntimeBindingPlan) -> GOSCompiledBundle {
        let bundleId = "aaci-first-slice-test-bundle"
        let manifest = GOSBundleManifest(
            bundleId: bundleId,
            specId: "aaci.first-slice",
            specVersion: "0.1.0",
            bundleVersion: "1",
            compilerVersion: "0.1.0",
            compiledAt: .now,
            lifecycleState: .active,
            compilerReportPath: "compiler-report.json",
            specPath: "spec.json",
            sourceProvenancePath: "source-provenance.json"
        )
        let metadata = GOSMetadata(
            title: "AACI First Slice Governed Workflow",
            status: .active,
            authoringForm: "yaml",
            compiledForm: "json"
        )
        let report = GOSCompilerReportRecord(parseOK: true, structuralOK: true, crossReferenceOK: true)
        let specJSON = "{\"metadata\":{\"title\":\"AACI First Slice Governed Workflow\",\"status\":\"active\",\"authoring_form\":\"yaml\",\"compiled_form\":\"json\"}}".data(using: .utf8)!
        return GOSCompiledBundle(
            manifest: manifest,
            metadata: metadata,
            compilerReport: report,
            runtimeBindingPlan: bindingPlan,
            compiledSpecJSON: specJSON
        )
    }

    private func makeCustomBindingPlan() -> GOSRuntimeBindingPlan {
        GOSRuntimeBindingPlan(
            specId: "aaci.first-slice",
            runtimeKind: .aaci,
            bindings: [
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.draft-composer",
                    semanticRole: "soap-runtime-composer",
                    primitiveFamilies: [.taskSpec, .draftOutputSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.referral-draft",
                    semanticRole: "referral-runtime-composer",
                    primitiveFamilies: [.draftOutputSpec, .humanGateRequirementSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.prescription-draft",
                    semanticRole: "prescription-runtime-composer",
                    primitiveFamilies: [.taskSpec, .draftOutputSpec, .humanGateRequirementSpec]
                )
            ]
        )
    }
}

private struct InMemoryBundleLoader: GOSBundleLoader {
    let bundle: GOSCompiledBundle

    func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle {
        _ = request
        return bundle
    }
}
#endif
