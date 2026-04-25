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
        XCTAssertEqual(runtimeView?.lifecycle, .active)
        XCTAssertEqual(runtimeView?.bindingPlanRuntimeKind, .aaci)
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
        XCTAssertEqual(soap.draft.payload["gosLifecycle"], "active")
        XCTAssertEqual(soap.draft.payload["gosBindingPlanRuntimeKind"], "aaci")
        XCTAssertEqual(soap.draft.payload["gosActorBound"], "true")
        XCTAssertEqual(soap.draft.payload["gosDraftOutputBound"], "true")
        XCTAssertEqual(soap.draft.payload["gosGateRequiredByBinding"], "true")
        XCTAssertEqual(soap.draft.payload["gosCoreGateRequired"], "true")
        XCTAssertEqual(soap.draft.payload["gosDraftOnly"], "true")
        XCTAssertEqual(soap.draft.payload["gosUsedDefaultBindingPlan"], "false")
        XCTAssertEqual(soap.draft.payload["gosBindingCount"], "3")
        XCTAssertEqual(soap.draft.payload["gosCompilerWarningCount"], "0")
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
        XCTAssertEqual(referral.draft.payload["gosGateRequiredByBinding"], "true")
        XCTAssertEqual(referral.draft.payload["gosCoreGateRequired"], "true")
        XCTAssertTrue(referral.noteSummary.contains("Human gate remains mandatory"))
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
        XCTAssertEqual(prescription.draft.payload["gosGateRequiredByBinding"], "true")
        XCTAssertEqual(prescription.draft.payload["gosCoreGateRequired"], "true")
        XCTAssertTrue(prescription.noteSummary.contains("Human gate remains mandatory"))
    }

    func testAACIComposeDraftsWithoutActiveBundleKeepsDraftOnlyAndNoGOSMetadata() async throws {
        let orchestrator = AACIOrchestrator(router: ProviderRouter())
        let session = SessaoTrabalho(
            kind: .encounter,
            serviceId: UUID(),
            professionalUserId: UUID(),
            patientUserId: UUID(),
            habilitationId: UUID()
        )
        let context = makeContext()
        let transcription = TranscriptionOutput(status: .ready, source: "seeded-text", transcriptText: "cefaleia")
        let soap = await orchestrator.composeSOAPDraft(session: session, transcription: transcription, context: context)
        XCTAssertNil(soap.draft.payload["gosSpecId"])
        XCTAssertNil(soap.draft.payload["gosRuntimeActorId"])
        XCTAssertEqual(soap.draft.status, .awaitingGate)
        XCTAssertFalse(soap.noteSummary.contains("Human gate remains mandatory"))
    }

    func testFirstSliceRecordsDistinctGOSUsageProvenanceWhenBundleIsActive() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
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
        let transcriptionUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.transcription" })
        let contextUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.context.retrieve" })
        let draftUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.compose.soap" })
        let referralUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.derive.referral" })
        let prescriptionUsage = try XCTUnwrap(result.provenanceRecords.first { $0.operation == "gos.use.derive.prescription" })
        let captureEvent = try XCTUnwrap(result.events.first { $0.kind == .captureReceived })
        let transcriptionEvent = try XCTUnwrap(result.events.first { $0.kind == .transcriptionProcessed })
        let contextEvent = try XCTUnwrap(result.events.first { $0.kind == .contextRetrieved })
        let soapEvent = try XCTUnwrap(result.events.first { $0.kind == .draftComposed })
        let referralEvent = try XCTUnwrap(result.events.first { $0.kind == .referralDraftComposed })
        let prescriptionEvent = try XCTUnwrap(result.events.first { $0.kind == .prescriptionDraftComposed })
        let transcriptMetadata = try readStorageMetadata(for: try XCTUnwrap(result.transcription.transcriptRef).objectPath)

        XCTAssertTrue(operations.contains("gos.activate"))
        XCTAssertTrue(operations.contains("gos.use.transcription"))
        XCTAssertTrue(operations.contains("gos.use.context.retrieve"))
        XCTAssertTrue(operations.contains("gos.use.compose.soap"))
        XCTAssertTrue(operations.contains("gos.use.derive.referral"))
        XCTAssertTrue(operations.contains("gos.use.derive.prescription"))
        XCTAssertEqual(transcriptionUsage.actorId, "aaci.transcription")
        XCTAssertEqual(contextUsage.actorId, "aaci.context")
        XCTAssertEqual(draftUsage.actorId, "aaci.draft-composer")
        XCTAssertEqual(referralUsage.actorId, "aaci.referral-draft")
        XCTAssertEqual(prescriptionUsage.actorId, "aaci.prescription-draft")
        XCTAssertEqual(captureEvent.payload.attributes["gosRuntimeActorId"], "aaci.capture")
        XCTAssertEqual(transcriptionEvent.payload.attributes["gosRuntimeActorId"], "aaci.transcription")
        XCTAssertEqual(contextEvent.payload.attributes["gosRuntimeActorId"], "aaci.context")
        XCTAssertEqual(transcriptMetadata["gosRuntimeActorId"], "aaci.transcription")
        XCTAssertEqual(soapEvent.payload.attributes["gosRuntimeActorId"], "aaci.draft-composer")
        XCTAssertEqual(referralEvent.payload.attributes["gosRuntimeActorId"], "aaci.referral-draft")
        XCTAssertEqual(prescriptionEvent.payload.attributes["gosRuntimeActorId"], "aaci.prescription-draft")
        XCTAssertTrue((soapEvent.payload.attributes["gosReasoningBoundary"] ?? "").contains("draft-only under human gate"))
    }

    func testFirstSliceWithActiveGOSKeepsDraftOnlyUntilHumanGateApproval() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let result = try await runner.run(
            input: makeSessionInput(gateApprove: false, text: "Paciente com insonia e cefaleia.")
        )
        let operations = Set(result.provenanceRecords.map(\.operation))

        XCTAssertTrue(operations.contains("gos.activate"))
        XCTAssertTrue(operations.contains("draft.compose.soap"))
        XCTAssertTrue(operations.contains("draft.compose.referral"))
        XCTAssertTrue(operations.contains("draft.compose.prescription"))
        XCTAssertTrue(operations.contains("gate.request"))
        XCTAssertTrue(operations.contains("gate.resolve"))
        XCTAssertFalse(operations.contains("document.finalize.soap"))
        XCTAssertFalse(result.gate.approved)
        XCTAssertNil(result.finalDocument)
        XCTAssertEqual(result.draft.draft.status, .awaitingGate)
        XCTAssertEqual(result.referralDraft.draft.status, .draft)
        XCTAssertEqual(result.prescriptionDraft.draft.status, .draft)
    }

    func testFirstSliceWithActiveGOSFinalizesOnlyAfterApprovedHumanGate() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let result = try await runner.run(
            input: makeSessionInput(gateApprove: true, text: "Paciente com insonia e dor.")
        )
        let operations = Set(result.provenanceRecords.map(\.operation))

        XCTAssertTrue(result.gate.approved)
        XCTAssertNotNil(result.finalDocument)
        XCTAssertTrue(operations.contains("gos.activate"))
        XCTAssertTrue(operations.contains("gate.request"))
        XCTAssertTrue(operations.contains("gate.resolve"))
        XCTAssertTrue(operations.contains("document.finalize.soap"))
        XCTAssertEqual(result.summary.finalDocumentStatus, .finalized)
    }

    func testFinalizationGuardRejectsDraftFinalizationWithoutApprovedGate() throws {
        let draft = ArtifactDraft(
            sessionId: UUID(),
            kind: .soap,
            status: .awaitingGate,
            author: DraftAuthorIdentity(actorId: "aaci.draft-composer", semanticRole: "draft-composer"),
            payload: ["summary": "draft"]
        )
        let request = GateRequest(
            draftId: draft.id,
            requestedAction: "finalize-soap-note",
            requiredRole: "professional",
            requiredReviewType: .professionalDocumentReview,
            finalizationTarget: .soapNote,
            requiresSignature: true
        )
        let rejected = GateResolution(
            gateRequestId: request.id,
            resolverUserId: UUID(),
            resolverRole: "professional",
            resolution: .rejected
        )
        let gate = GateOutcomeSummary(
            request: request,
            resolution: rejected,
            reviewedDraftStatus: .rejected,
            approved: false
        )

        XCTAssertThrowsError(try FirstSliceInvariantEnforcer.ensureSOAPDraftCanFinalize(draft: draft, gate: gate)) { error in
            guard case let FirstSliceError.missingGateApproval(draftId, resolution) = error else {
                XCTFail("Expected missingGateApproval, got \(error)")
                return
            }
            XCTAssertEqual(draftId, draft.id)
            XCTAssertEqual(resolution, .rejected)
        }
    }

    func testFirstSliceApprovedGateMaintainsOrderedGOSGateAndFinalizationProvenance() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let result = try await runner.run(
            input: makeSessionInput(gateApprove: true, text: "Paciente com dor e fadiga.")
        )
        let operations = result.provenanceRecords.map(\.operation)

        let activationIndex = try XCTUnwrap(operations.firstIndex(of: "gos.activate"))
        let composeSOAPIndex = try XCTUnwrap(operations.firstIndex(of: "draft.compose.soap"))
        let composeReferralIndex = try XCTUnwrap(operations.firstIndex(of: "draft.compose.referral"))
        let composePrescriptionIndex = try XCTUnwrap(operations.firstIndex(of: "draft.compose.prescription"))
        let gateRequestIndex = try XCTUnwrap(operations.firstIndex(of: "gate.request"))
        let gateResolveIndex = try XCTUnwrap(operations.firstIndex(of: "gate.resolve"))
        let finalizeIndex = try XCTUnwrap(operations.firstIndex(of: "document.finalize.soap"))

        XCTAssertLessThan(activationIndex, composeSOAPIndex)
        XCTAssertLessThan(composeSOAPIndex, gateRequestIndex)
        XCTAssertLessThan(composeReferralIndex, gateRequestIndex)
        XCTAssertLessThan(composePrescriptionIndex, gateRequestIndex)
        XCTAssertLessThan(gateRequestIndex, gateResolveIndex)
        XCTAssertLessThan(gateResolveIndex, finalizeIndex)
    }

    func testFirstSliceWithActiveGOSDoesNotBypassCoreConsentOrHabilitationChecks() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))

        do {
            _ = try await runner.run(
                input: FirstSliceSessionInput(
                    professional: Usuario(cpfHash: "prof", civilToken: "prof", active: false),
                    patient: Usuario(cpfHash: "patient", civilToken: "patient"),
                    service: Servico(nome: "svc", tipo: "ambulatory"),
                    capture: SessionCaptureInput(rawText: "Sem bypass de habilitacao."),
                    gateApprove: true
                )
            )
            XCTFail("Expected inactive professional to fail before GOS-mediated runtime work.")
        } catch {
            guard case FirstSliceError.inactiveProfessionalUser = error else {
                XCTFail("Expected inactiveProfessionalUser, got \(error)")
                return
            }
        }

        do {
            _ = try await runner.run(
                input: FirstSliceSessionInput(
                    professional: Usuario(cpfHash: "prof", civilToken: "prof"),
                    patient: Usuario(cpfHash: "patient", civilToken: "patient", active: false),
                    service: Servico(nome: "svc", tipo: "ambulatory"),
                    capture: SessionCaptureInput(rawText: "Sem bypass de consentimento."),
                    gateApprove: true
                )
            )
            XCTFail("Expected inactive patient to fail before GOS-mediated runtime work.")
        } catch {
            guard case FirstSliceError.inactivePatientUser = error else {
                XCTFail("Expected inactivePatientUser, got \(error)")
                return
            }
        }
    }

    func testScribeBridgeStateDoesNotExposeRawGOSSpecJSON() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let adapter = ScribeFirstSliceAdapter(runner: runner)
        let professional = Usuario(cpfHash: "prof", civilToken: "prof")
        let service = Servico(nome: "svc", tipo: "ambulatory")
        let patient = Usuario(cpfHash: "patient", civilToken: "patient")

        let start = await adapter.startProfessionalSession(.init(professional: professional, service: service))
        let sessionId = try XCTUnwrap(start.state?.sessionId)
        _ = await adapter.selectPatient(.init(sessionId: sessionId, patient: patient))
        _ = await adapter.submitSessionCapture(
            .init(
                sessionId: sessionId,
                capture: SessionCaptureInput(rawText: "Paciente relata insonia persistente.")
            )
        )
        let resolved = await adapter.resolveGate(.init(sessionId: sessionId, approve: false))
        let state = try XCTUnwrap(resolved.state)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        let payload = try encoder.encode(state)
        let jsonString = String(decoding: payload, as: UTF8.self)

        XCTAssertTrue(jsonString.contains("\"runSummary\""))
        XCTAssertTrue(jsonString.contains("\"gosRuntimeState\""))
        XCTAssertTrue(jsonString.contains("\"gateState\""))
        XCTAssertFalse(jsonString.contains("\"gosSpec\""))
        XCTAssertFalse(jsonString.contains("\"compiledSpecJSON\""))
        XCTAssertFalse(jsonString.contains("\"compiledSpec\""))
        XCTAssertFalse(jsonString.contains("\"runtimeBindingPlan\""))
        XCTAssertEqual(state.gosRuntimeState.lifecycle, .active)
        XCTAssertEqual(state.gosRuntimeState.specId, "aaci.first-slice")
        XCTAssertEqual(state.gosRuntimeState.bundleId, bundle.manifest.bundleId)
        XCTAssertEqual(state.gosRuntimeState.bindingPlanSource, .bundleProvided)
        XCTAssertEqual(state.gosRuntimeState.gateStillRequired, true)
        XCTAssertEqual(state.gosRuntimeState.draftOnly, true)
        XCTAssertEqual(state.gosRuntimeState.legalAuthorizing, false)
        XCTAssertEqual(state.gosRuntimeState.provenanceFacingOnly, true)
        XCTAssertEqual(state.gosRuntimeState.informationalOnly, true)
        XCTAssertTrue(state.gosRuntimeState.mediationSummary?.provenanceOperations.contains("gos.use.compose.soap") == true)
        XCTAssertNotNil(state.gosRuntimeState.mediationSummary)
    }

    func testScribeBridgeStateWithoutActiveGOSExposesOnlyInactiveRuntimeSurface() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        if let entry = try await registry.lookup(specId: "aaci.first-slice"),
           let activeBundleId = entry.activeBundleId {
            try await registry.deprecate(bundleId: activeBundleId, note: "test inactive gos runtime bridge surface")
        }

        let router = ProviderRouter()
        await router.register(AppleFoundationProvider())
        await router.register(NativeSpeechProvider())
        let runner = FirstSliceRunner(root: root, orchestrator: AACIOrchestrator(router: router))
        let adapter = ScribeFirstSliceAdapter(runner: runner)
        let professional = Usuario(cpfHash: "prof", civilToken: "prof")
        let service = Servico(nome: "svc", tipo: "ambulatory")
        let patient = Usuario(cpfHash: "patient", civilToken: "patient")

        let start = await adapter.startProfessionalSession(.init(professional: professional, service: service))
        let sessionId = try XCTUnwrap(start.state?.sessionId)
        _ = await adapter.selectPatient(.init(sessionId: sessionId, patient: patient))
        _ = await adapter.submitSessionCapture(
            .init(
                sessionId: sessionId,
                capture: SessionCaptureInput(rawText: "Paciente com contexto sem GOS ativo.")
            )
        )
        let resolved = await adapter.resolveGate(.init(sessionId: sessionId, approve: false))
        let state = try XCTUnwrap(resolved.state)

        XCTAssertEqual(state.gosRuntimeState.lifecycle, .inactive)
        XCTAssertNil(state.gosRuntimeState.specId)
        XCTAssertNil(state.gosRuntimeState.bundleId)
        XCTAssertNil(state.gosRuntimeState.bindingPlanSource)
        XCTAssertNil(state.gosRuntimeState.mediationSummary)
        XCTAssertEqual(state.gosRuntimeState.gateStillRequired, true)
        XCTAssertEqual(state.gosRuntimeState.draftOnly, true)
        XCTAssertEqual(state.gosRuntimeState.legalAuthorizing, false)
        XCTAssertEqual(state.gosRuntimeState.provenanceFacingOnly, true)
        XCTAssertEqual(state.gosRuntimeState.informationalOnly, true)
    }

    func testRegistryReviewAndPromotionRecordApprovalAndAudit() async throws {
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
                lifecycleState: .draft,
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
        try installBundleFiles(bundle, at: root)
        let reviewRecord = try await registry.review(
            bundleId: bundle.manifest.bundleId,
            specId: bundle.manifest.specId,
            reviewerId: "reviewer-1",
            reviewerRole: "operator",
            rationale: "reviewed for activation"
        )
        let activationAudit = try await registry.promoteReviewedBundle(
            bundleId: bundle.manifest.bundleId,
            specId: bundle.manifest.specId,
            actorId: "operator-1",
            actorRole: "operator",
            rationale: "activate reviewed bundle"
        )

        let loaded = try await registry.loadBundle(GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active]))
        let reviewDecoder = JSONDecoder()
        reviewDecoder.dateDecodingStrategy = .iso8601
        let persistedReviewRecord = try reviewDecoder.decode(
            GOSBundleReviewRecord.self,
            from: Data(contentsOf: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/review-approval.json"))
        )
        let auditRecords = try readAuditRecords(at: root)
        let manifestJSON = try readJSONObject(at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/manifest.json"))
        let registryJSON = try readJSONObject(at: root.appending(path: "system/gos/registry/\(bundle.manifest.specId).json"))
        let reviewJSON = try readJSONObject(at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/review-approval.json"))
        let activationAuditJSON = try readJSONObject(
            at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/manifest.json")
        )

        XCTAssertEqual(reviewRecord.reviewerId, "reviewer-1")
        XCTAssertEqual(reviewRecord.rationale, "reviewed for activation")
        XCTAssertEqual(persistedReviewRecord.id, reviewRecord.id)
        XCTAssertEqual(activationAudit.actorId, "operator-1")
        XCTAssertEqual(loaded.manifest.lifecycleState, .active)
        XCTAssertTrue(auditRecords.contains { $0.action == .reviewed && $0.bundleId == bundle.manifest.bundleId })
        XCTAssertTrue(auditRecords.contains { $0.action == .activated && $0.bundleId == bundle.manifest.bundleId && $0.actorId == "operator-1" })
        XCTAssertNotNil(manifestJSON["bundle_id"])
        XCTAssertNotNil(manifestJSON["lifecycle_state"])
        XCTAssertNotNil(registryJSON["active_bundle_id"])
        XCTAssertNotNil(registryJSON["known_bundle_ids"])
        XCTAssertNotNil(reviewJSON["reviewer_id"])
        XCTAssertNotNil(reviewJSON["reviewed_at"])
        XCTAssertNotNil(activationAuditJSON["bundle_id"])
        XCTAssertNotNil(activationAuditJSON["lifecycle_state"])
    }

    func testRegistryLoaderRejectsMismatchedRuntimeBindingPlan() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"))

        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
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
            guard case let GOSRegistryError.runtimeBindingPlanInvalid(bundleId, expectedSpecId, expectedRuntimeKind) = error else {
                XCTFail("Expected runtimeBindingPlanInvalid, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(expectedSpecId, "aaci.first-slice")
            XCTAssertEqual(expectedRuntimeKind, .aaci)
        }
    }

    func testRegistryRegistersAndLoadsActiveBundleWithValidArtifacts() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)

        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let lookedUpEntry = try await registry.lookup(specId: bundle.manifest.specId)
        let entry = try XCTUnwrap(lookedUpEntry)
        XCTAssertEqual(entry.specId, bundle.manifest.specId)
        XCTAssertTrue(entry.knownBundleIds.contains(bundle.manifest.bundleId))

        let loaded = try await registry.loadBundle(
            GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
        )
        XCTAssertEqual(loaded.manifest.bundleId, bundle.manifest.bundleId)
        XCTAssertEqual(loaded.manifest.lifecycleState, .active)
    }

    func testActivationRejectsDraftBundle() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .draft)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)

        do {
            try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
            XCTFail("Expected draft activation to fail.")
        } catch {
            guard case let GOSRegistryError.invalidBundleState(bundleId, lifecycleState, expectedStates) = error else {
                XCTFail("Expected invalidBundleState, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(lifecycleState, .draft)
            XCTAssertEqual(expectedStates, [.reviewed, .active])
        }
    }

    func testActivationRejectsRegistryWhenCompetingActiveBundlesExist() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let first = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        let second = makeBundle(
            bundleId: "aaci-first-slice-test-bundle-alt",
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .active
        )

        try await registry.register(first.manifest)
        try installBundleFiles(first, at: root)
        try await registry.register(second.manifest)
        try installBundleFiles(second, at: root)
        let forcedEntry = GOSRegistryEntry(
            specId: "aaci.first-slice",
            activeBundleId: first.manifest.bundleId,
            knownBundleIds: [first.manifest.bundleId, second.manifest.bundleId]
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(forcedEntry).write(to: root.appending(path: "system/gos/registry/aaci.first-slice.json"))

        do {
            try await registry.activate(bundleId: second.manifest.bundleId, specId: second.manifest.specId)
            XCTFail("Expected invalid activation state with competing active bundles.")
        } catch {
            guard case let GOSRegistryError.invalidActivationState(specId, detail) = error else {
                XCTFail("Expected invalidActivationState, got \(error)")
                return
            }
            XCTAssertEqual(specId, "aaci.first-slice")
            XCTAssertTrue(detail.contains("multiple active bundles"))
        }
    }

    func testLoaderRejectsRevokedBundle() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        var bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .draft)
        bundle = GOSCompiledBundle(
            manifest: GOSBundleManifest(
                bundleId: bundle.manifest.bundleId,
                specId: bundle.manifest.specId,
                specVersion: bundle.manifest.specVersion,
                bundleVersion: bundle.manifest.bundleVersion,
                compilerVersion: bundle.manifest.compilerVersion,
                compiledAt: bundle.manifest.compiledAt,
                lifecycleState: .draft,
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
        try installBundleFiles(bundle, at: root)
        _ = try await registry.review(
            bundleId: bundle.manifest.bundleId,
            specId: bundle.manifest.specId,
            reviewerId: "reviewer-1",
            reviewerRole: "operator",
            rationale: "review before revoke"
        )
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try await registry.revoke(bundleId: bundle.manifest.bundleId, note: "revoked for test")
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let forcedEntry = GOSRegistryEntry(
            specId: bundle.manifest.specId,
            activeBundleId: bundle.manifest.bundleId,
            knownBundleIds: [bundle.manifest.bundleId]
        )
        try encoder.encode(forcedEntry).write(to: root.appending(path: "system/gos/registry/\(bundle.manifest.specId).json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected revoked bundle load to fail.")
        } catch {
            guard case let GOSRegistryError.bundleRevoked(bundleId) = error else {
                XCTFail("Expected bundleRevoked, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
        }
    }

    func testRevokeClearsActivePointerForActiveBundle() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        try await registry.revoke(bundleId: bundle.manifest.bundleId, note: "critical issue")
        let lookedUpEntry = try await registry.lookup(specId: bundle.manifest.specId)
        let entry = try XCTUnwrap(lookedUpEntry)
        XCTAssertNil(entry.activeBundleId)
        XCTAssertTrue(entry.knownBundleIds.contains(bundle.manifest.bundleId))
    }

    func testRevokeNonActivePreservesKnownBundlesAndActivePointer() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let activeBundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        let reviewedBundle = makeBundle(
            bundleId: "aaci-first-slice-reviewed-bundle",
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .reviewed
        )
        try await registry.register(activeBundle.manifest)
        try installBundleFiles(activeBundle, at: root)
        try await registry.activate(bundleId: activeBundle.manifest.bundleId, specId: activeBundle.manifest.specId)
        try await registry.register(reviewedBundle.manifest)
        try installBundleFiles(reviewedBundle, at: root)

        try await registry.revoke(bundleId: reviewedBundle.manifest.bundleId, note: "withdrawn after review")
        let lookedUpEntry = try await registry.lookup(specId: activeBundle.manifest.specId)
        let entry = try XCTUnwrap(lookedUpEntry)
        XCTAssertEqual(entry.activeBundleId, activeBundle.manifest.bundleId)
        XCTAssertTrue(entry.knownBundleIds.contains(activeBundle.manifest.bundleId))
        XCTAssertTrue(entry.knownBundleIds.contains(reviewedBundle.manifest.bundleId))
    }

    func testLoadFailsWhenActiveRegistryPointerReferencesUnknownBundle() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let forcedEntry = GOSRegistryEntry(
            specId: bundle.manifest.specId,
            activeBundleId: "missing-bundle-id",
            knownBundleIds: [bundle.manifest.bundleId]
        )
        try encoder.encode(forcedEntry).write(to: root.appending(path: "system/gos/registry/\(bundle.manifest.specId).json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail for unknown active bundle pointer.")
        } catch {
            guard case let GOSRegistryError.registryBundleMissing(specId, bundleId) = error else {
                XCTFail("Expected registryBundleMissing, got \(error)")
                return
            }
            XCTAssertEqual(specId, bundle.manifest.specId)
            XCTAssertEqual(bundleId, "missing-bundle-id")
        }
    }

    func testLoadFailsWhenRegistryIsMissingForSpec() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail when registry entry does not exist.")
        } catch {
            guard case let GOSRegistryError.registryMissing(specId) = error else {
                XCTFail("Expected registryMissing, got \(error)")
                return
            }
            XCTAssertEqual(specId, "aaci.first-slice")
        }
    }

    func testAACIActivationMapsRegistryFailureToTypedLoaderError() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let orchestrator = AACIOrchestrator(router: ProviderRouter())

        do {
            _ = try await orchestrator.activateGOS(specId: "aaci.first-slice", loader: registry)
            XCTFail("Expected activation to fail when registry is missing.")
        } catch let error as GOSLoadTypedError {
            XCTAssertEqual(error.failure, .bundleRegistryFailure)
            guard case .registryMissing(let specId)? = error.registryError else {
                XCTFail("Expected typed loader error to preserve registryMissing underlying error.")
                return
            }
            XCTAssertEqual(specId, "aaci.first-slice")
        } catch {
            XCTFail("Expected GOSLoadTypedError, got \(error)")
        }
    }

    func testLoadFailsWhenRegistryEntryIsCorrupted() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let registryURL = root.appending(path: "system/gos/registry/aaci.first-slice.json")
        try FileManager.default.createDirectory(at: registryURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try "{invalid-json".data(using: .utf8)!.write(to: registryURL)

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail when registry entry is corrupted.")
        } catch {
            guard case let GOSRegistryError.registryEntryDecodeFailure(specId) = error else {
                XCTFail("Expected registryEntryDecodeFailure, got \(error)")
                return
            }
            XCTAssertEqual(specId, "aaci.first-slice")
        }
    }

    func testLoadFailsWhenRegistryPointerIsMissingButSingleActiveBundleExists() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let inconsistentEntry = GOSRegistryEntry(
            specId: bundle.manifest.specId,
            activeBundleId: nil,
            knownBundleIds: [bundle.manifest.bundleId]
        )
        try encoder.encode(inconsistentEntry).write(to: root.appending(path: "system/gos/registry/\(bundle.manifest.specId).json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected missing active pointer to fail when an active known bundle exists.")
        } catch {
            guard case let GOSRegistryError.registryMissingActivePointer(specId, activeBundleId) = error else {
                XCTFail("Expected registryMissingActivePointer, got \(error)")
                return
            }
            XCTAssertEqual(specId, bundle.manifest.specId)
            XCTAssertEqual(activeBundleId, bundle.manifest.bundleId)
        }
    }

    func testLoadFailsWhenMultipleKnownBundlesAreActive() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let activeBundleA = makeBundle(
            bundleId: "aaci-first-slice-active-a",
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .active
        )
        let activeBundleB = makeBundle(
            bundleId: "aaci-first-slice-active-b",
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .active
        )
        try await registry.register(activeBundleA.manifest)
        try installBundleFiles(activeBundleA, at: root)
        try await registry.register(activeBundleB.manifest)
        try installBundleFiles(activeBundleB, at: root)

        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        let forcedEntry = GOSRegistryEntry(
            specId: "aaci.first-slice",
            activeBundleId: activeBundleA.manifest.bundleId,
            knownBundleIds: [activeBundleA.manifest.bundleId, activeBundleB.manifest.bundleId]
        )
        try encoder.encode(forcedEntry).write(to: root.appending(path: "system/gos/registry/aaci.first-slice.json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: "aaci.first-slice", runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected multiple active bundles to fail deterministic load.")
        } catch {
            guard case let GOSRegistryError.multipleActiveBundles(specId, bundleIds) = error else {
                XCTFail("Expected multipleActiveBundles, got \(error)")
                return
            }
            XCTAssertEqual(specId, "aaci.first-slice")
            XCTAssertEqual(Set(bundleIds), Set([activeBundleA.manifest.bundleId, activeBundleB.manifest.bundleId]))
        }
    }

    func testActivationFailsWhenManifestIsMissing() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)

        do {
            try await registry.activate(bundleId: "missing-bundle", specId: "aaci.first-slice")
            XCTFail("Expected activation to fail when manifest is missing.")
        } catch {
            guard case let GOSRegistryError.manifestMissing(bundleId) = error else {
                XCTFail("Expected manifestMissing, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, "missing-bundle")
        }
    }

    func testLoadFailsWhenSpecArtifactIsMissing() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try FileManager.default.removeItem(at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/spec.json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail when spec artifact is missing.")
        } catch {
            guard case let GOSRegistryError.specMissing(bundleId, path) = error else {
                XCTFail("Expected specMissing, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(path, "spec.json")
        }
    }

    func testLoadFailsWhenCompilerReportArtifactIsMissing() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try FileManager.default.removeItem(
            at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/compiler-report.json")
        )

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail when compiler report artifact is missing.")
        } catch {
            guard case let GOSRegistryError.compilerReportMissing(bundleId, path) = error else {
                XCTFail("Expected compilerReportMissing, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(path, "compiler-report.json")
        }
    }

    func testLoadFailsWhenSourceProvenanceArtifactIsMissing() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try FileManager.default.removeItem(
            at: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/source-provenance.json")
        )

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected load to fail when source provenance artifact is missing.")
        } catch {
            guard case let GOSRegistryError.sourceProvenanceMissing(bundleId, path) = error else {
                XCTFail("Expected sourceProvenanceMissing, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(path, "source-provenance.json")
        }
    }

    func testDeprecateClearsActivePointerWhenBundleWasActive() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        try await registry.deprecate(bundleId: bundle.manifest.bundleId, note: "deprecated for replacement")
        let lookedUpEntry = try await registry.lookup(specId: bundle.manifest.specId)
        let entry = try XCTUnwrap(lookedUpEntry)
        XCTAssertNil(entry.activeBundleId)
        XCTAssertTrue(entry.knownBundleIds.contains(bundle.manifest.bundleId))
    }

    func testLoadRejectsDeprecatedBundleWhenActiveIsRequired() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .reviewed
        )
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        let reviewRecord = GOSBundleReviewRecord(
            specId: bundle.manifest.specId,
            bundleId: bundle.manifest.bundleId,
            reviewerId: "reviewer-1",
            reviewerRole: "operator",
            rationale: "allow activation before deprecate test"
        )
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        try encoder.encode(reviewRecord).write(
            to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/review-approval.json")
        )

        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)
        try await registry.deprecate(bundleId: bundle.manifest.bundleId, note: "deprecated for replacement")
        let forcedEntry = GOSRegistryEntry(
            specId: bundle.manifest.specId,
            activeBundleId: bundle.manifest.bundleId,
            knownBundleIds: [bundle.manifest.bundleId]
        )
        try encoder.encode(forcedEntry).write(to: root.appending(path: "system/gos/registry/\(bundle.manifest.specId).json"))

        do {
            _ = try await registry.loadBundle(
                GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
            )
            XCTFail("Expected deprecated bundle load to fail when active lifecycle is required.")
        } catch {
            guard case let GOSRegistryError.bundleDeprecated(bundleId) = error else {
                XCTFail("Expected bundleDeprecated, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
        }
    }

    func testDeprecateNonActivePreservesKnownBundlesAndActivePointer() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let activeBundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        let reviewedBundle = makeBundle(
            bundleId: "aaci-first-slice-reviewed-to-deprecate",
            bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"),
            lifecycleState: .reviewed
        )
        try await registry.register(activeBundle.manifest)
        try installBundleFiles(activeBundle, at: root)
        try await registry.activate(bundleId: activeBundle.manifest.bundleId, specId: activeBundle.manifest.specId)
        try await registry.register(reviewedBundle.manifest)
        try installBundleFiles(reviewedBundle, at: root)

        do {
            try await registry.deprecate(bundleId: reviewedBundle.manifest.bundleId, note: "invalid transition should not mutate history")
            XCTFail("Expected reviewed -> deprecated to be denied.")
        } catch {
            guard case GOSRegistryError.invalidLifecycleTransition = error else {
                XCTFail("Expected invalidLifecycleTransition, got \(error)")
                return
            }
        }

        let lookedUpEntry = try await registry.lookup(specId: activeBundle.manifest.specId)
        let entry = try XCTUnwrap(lookedUpEntry)
        XCTAssertEqual(entry.activeBundleId, activeBundle.manifest.bundleId)
        XCTAssertTrue(entry.knownBundleIds.contains(activeBundle.manifest.bundleId))
        XCTAssertTrue(entry.knownBundleIds.contains(reviewedBundle.manifest.bundleId))
    }

    func testDeprecateRejectsInvalidTransitionFromReviewed() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        let bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .reviewed)
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)

        do {
            try await registry.deprecate(bundleId: bundle.manifest.bundleId, note: "invalid transition")
            XCTFail("Expected reviewed -> deprecated to be denied.")
        } catch {
            guard case let GOSRegistryError.invalidLifecycleTransition(bundleId, fromState, toState, _) = error else {
                XCTFail("Expected invalidLifecycleTransition, got \(error)")
                return
            }
            XCTAssertEqual(bundleId, bundle.manifest.bundleId)
            XCTAssertEqual(fromState, .reviewed)
            XCTAssertEqual(toState, .deprecated)
        }
    }

    func testLoadAndActivationUseDefaultBindingPlanWhenBundlePlanFileIsMissing() async throws {
        let root = makeTempRoot()
        try DirectoryLayout.bootstrap(at: root)
        let registry = FileBackedGOSBundleRegistry(root: root)
        var bundle = makeBundle(bindingPlan: AACIGOSBindings.defaultBindingPlan(specId: "aaci.first-slice"), lifecycleState: .active)
        bundle = GOSCompiledBundle(
            manifest: bundle.manifest,
            metadata: bundle.metadata,
            compilerReport: bundle.compilerReport,
            runtimeBindingPlan: nil,
            compiledSpecJSON: bundle.compiledSpecJSON
        )
        try await registry.register(bundle.manifest)
        try installBundleFiles(bundle, at: root)
        try await registry.activate(bundleId: bundle.manifest.bundleId, specId: bundle.manifest.specId)

        let loaded = try await registry.loadBundle(
            GOSLoadRequest(specId: bundle.manifest.specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active])
        )
        XCTAssertNil(loaded.runtimeBindingPlan)

        let orchestrator = AACIOrchestrator(router: ProviderRouter())
        let activation = try await orchestrator.activateGOS(specId: bundle.manifest.specId, loader: registry)
        XCTAssertTrue(activation.usedDefaultBindingPlan)
        XCTAssertGreaterThan(activation.bindingCount, 0)
    }

    private func makeTempRoot() -> URL {
        let url = FileManager.default.temporaryDirectory.appending(path: "healthos-tests-\(UUID().uuidString)")
        try? FileManager.default.removeItem(at: url)
        return url
    }

    private func makeSessionInput(gateApprove: Bool, text: String) -> FirstSliceSessionInput {
        FirstSliceSessionInput(
            professional: Usuario(cpfHash: "prof", civilToken: "prof"),
            patient: Usuario(cpfHash: "patient", civilToken: "patient"),
            service: Servico(nome: "svc", tipo: "ambulatory"),
            capture: SessionCaptureInput(rawText: text),
            gateApprove: gateApprove
        )
    }

    private func installBundleFiles(_ bundle: GOSCompiledBundle, at root: URL) throws {
        try Data(bundle.compiledSpecJSON).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/spec.json"))
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        try encoder.encode(bundle.compilerReport).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/compiler-report.json"))
        try "{\"source_sha256\":\"abc\"}".data(using: .utf8)!.write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/source-provenance.json"))
        if let runtimeBindingPlan = bundle.runtimeBindingPlan {
            try encoder.encode(runtimeBindingPlan).write(to: root.appending(path: "system/gos/bundles/\(bundle.manifest.bundleId)/runtime-binding-plan.json"))
        }
    }

    private func readStorageMetadata(for objectPath: String) throws -> [String: String] {
        let metadataURL = URL(fileURLWithPath: objectPath + ".meta.json")
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: metadataURL))
        let root = try XCTUnwrap(object as? [String: Any])
        return try XCTUnwrap(root["metadata"] as? [String: String])
    }

    private func readAuditRecords(at root: URL) throws -> [GOSLifecycleAuditRecord] {
        let auditURL = root.appending(path: "system/gos/audit.jsonl")
        let lines = try String(contentsOf: auditURL, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .iso8601
        return try lines.map { line in
            try decoder.decode(GOSLifecycleAuditRecord.self, from: Data(line.utf8))
        }
    }

    private func readJSONObject(at url: URL) throws -> [String: Any] {
        let object = try JSONSerialization.jsonObject(with: Data(contentsOf: url))
        return try XCTUnwrap(object as? [String: Any])
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

    private func makeBundle(
        bundleId: String = "aaci-first-slice-test-bundle",
        bindingPlan: GOSRuntimeBindingPlan,
        lifecycleState: GOSLifecycleState = .active
    ) -> GOSCompiledBundle {
        let manifest = GOSBundleManifest(
            bundleId: bundleId,
            specId: "aaci.first-slice",
            specVersion: "0.1.0",
            bundleVersion: "1",
            compilerVersion: "0.1.0",
            compiledAt: .now,
            lifecycleState: lifecycleState,
            compilerReportPath: "compiler-report.json",
            specPath: "spec.json",
            sourceProvenancePath: "source-provenance.json"
        )
        let metadata = GOSMetadata(
            title: "AACI First Slice Governed Workflow",
            status: lifecycleState,
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
