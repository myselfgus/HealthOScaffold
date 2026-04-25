import Foundation
import HealthOSCore
import HealthOSProviders
import HealthOSAACI

public actor FirstSliceRunner {
    private let root: URL
    private let habilitationService: SimpleHabilitationService
    private let consentService: SimpleConsentService
    private let gateService: SimpleGateService
    private let storage: FileBackedStorageService
    private let provenance: FileBackedProvenanceLedger
    private let orchestrator: AACIOrchestrator
    private let retrieval: BoundedContextRetrievalService
    private let recordIndex: FileBackedRecordIndex
    private let contextAssembler: ClinicalContextAssembler
    private let gosLoader: FileBackedGOSBundleRegistry

    public init(root: URL, orchestrator: AACIOrchestrator) {
        self.root = root
        self.habilitationService = SimpleHabilitationService()
        self.consentService = SimpleConsentService()
        self.gateService = SimpleGateService()
        self.storage = FileBackedStorageService(root: root)
        self.provenance = FileBackedProvenanceLedger(root: root)
        self.orchestrator = orchestrator
        self.recordIndex = FileBackedRecordIndex(root: root)
        self.retrieval = BoundedContextRetrievalService(index: self.recordIndex)
        self.contextAssembler = ClinicalContextAssembler()
        self.gosLoader = FileBackedGOSBundleRegistry(root: root)
    }

    public func run(input: FirstSliceSessionInput) async throws -> FirstSliceRunResult {
        let professional = input.professional
        let patient = input.patient
        let service = input.service

        try validateCapture(input.capture)

        let habilitation = try await habilitationService.validate(professional: professional, service: service)
        let consent = try await consentService.validate(patient: patient, finalidade: "care-context-retrieval")

        let session = SessaoTrabalho(
            kind: .encounter,
            serviceId: service.id,
            professionalUserId: professional.id,
            patientUserId: patient.id,
            habilitationId: habilitation.id
        )

        let lawfulContext: [String: String] = [
            "actorRole": "professional-agent",
            "scope": "care-context",
            "serviceId": service.id.uuidString,
            "patientUserId": patient.id.uuidString,
            "habilitationId": habilitation.id.uuidString,
            "finalidade": consent.finalidade,
            "sessionId": session.id.uuidString
        ]

        var events: [SessionEventRecord] = []
        var provenanceRecords: [ProvenanceRecord] = []

        try await appendProvenance(
            .init(
                actorId: "first-slice",
                operation: "session.start",
                promptVersion: "v1",
                timestamp: .now
            ),
            to: &provenanceRecords
        )
        try await appendProvenance(
            .init(
                actorId: professional.id.uuidString,
                operation: "habilitation.validate",
                timestamp: .now
            ),
            to: &provenanceRecords
        )
        try await appendProvenance(
            .init(
                actorId: professional.id.uuidString,
                operation: "consent.validate",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let _ = await orchestrator.startSession(session)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .sessionStarted,
                payload: FirstSliceSessionEventPayload(
                    summary: "Session opened for first slice flow.",
                    attributes: ["serviceId": service.id.uuidString]
                )
            )
        )
        let gosRuntimeView = try await activateGOSIfAvailable(to: &provenanceRecords)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .captureReceived,
                payload: FirstSliceSessionEventPayload(
                    summary: "Capture input accepted.",
                    attributes: captureReceivedEventAttributes(
                        capture: input.capture,
                        runtimeView: gosRuntimeView
                    )
                )
            )
        )

        let audioCapture = try await persistAudioCaptureIfNeeded(
            from: input.capture,
            sessionId: session.id,
            serviceId: service.id,
            patientUserId: patient.id,
            actorId: professional.id.uuidString,
            lawfulContext: lawfulContext,
            runtimeView: gosRuntimeView
        )
        if let audioCapture {
            events.append(
                SessionEventRecord(
                    sessionId: session.id,
                    kind: .audioCapturePersisted,
                    payload: FirstSliceSessionEventPayload(
                        summary: "Local audio capture persisted.",
                        attributes: audioCaptureEventAttributes(
                            audioCapture: audioCapture,
                            runtimeView: gosRuntimeView
                        )
                    )
                )
            )
            try await appendProvenance(
                .init(
                    actorId: "aaci.capture",
                    operation: "capture.audio.persist",
                    promptVersion: gosPromptVersion(prefix: "capture-audio-v1", runtimeView: gosRuntimeView),
                    outputHash: audioCapture.storedRef.contentHash,
                    timestamp: .now
                ),
                to: &provenanceRecords
            )
        }

        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .capture,
            actorId: "aaci.capture",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )

        let transcriptionInput = TranscriptionInput(
            captureMode: input.capture.mode,
            seededText: input.capture.normalizedText,
            audioCapture: audioCapture
        )
        var transcription = await orchestrator.transcribe(transcriptionInput)
        let normalizedTranscriptionText = transcription.transcriptText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
        if transcription.status == .ready,
           normalizedTranscriptionText?.isEmpty != false {
            transcription = TranscriptionOutput(
                status: .degraded,
                source: transcription.source,
                audioCapture: transcription.audioCapture,
                issueMessage: "Transcription provider reported ready but produced no transcript text.",
                providerExecution: transcription.providerExecution
            )
        }

        if let transcriptText = normalizedTranscriptionText,
           !transcriptText.isEmpty {
            let transcriptRef = try await persistTranscript(
                transcriptText,
                sessionId: session.id,
                serviceId: service.id,
                patientUserId: patient.id,
                actorId: professional.id.uuidString,
                lawfulContext: lawfulContext,
                runtimeView: gosRuntimeView
            )
            transcription = TranscriptionOutput(
                status: transcription.status == .ready ? .ready : .degraded,
                source: transcription.source,
                transcriptText: transcriptText,
                transcriptRef: transcriptRef,
                audioCapture: transcription.audioCapture,
                issueMessage: transcription.issueMessage,
                providerExecution: transcription.providerExecution
            )
        }

        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .transcription,
            actorId: "aaci.transcription",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .transcriptionProcessed,
                payload: FirstSliceSessionEventPayload(
                    summary: transcriptionEventSummary(for: transcription),
                    attributes: transcriptionEventAttributes(
                        for: transcription,
                        runtimeView: gosRuntimeView
                    )
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.transcription",
                operation: "transcription.process",
                providerName: transcription.providerExecution?.providerId ?? transcription.source,
                modelName: transcription.providerExecution?.isStub == true ? "stub" : transcription.providerExecution?.modelId,
                modelVersion: transcription.providerExecution?.modelVersion,
                promptVersion: gosPromptVersion(prefix: "transcription-v1", runtimeView: gosRuntimeView),
                inputHash: transcription.audioCapture?.storedRef.contentHash,
                outputHash: transcription.transcriptRef?.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let languageModelDecision = await orchestrator.languageModelSelection(
            taskClass: .languageModel,
            dataLayer: .derivedArtifacts,
            lawfulContext: lawfulContext,
            finalidade: consent.finalidade
        )

        try await seedDemoRecordIndexIfNeeded(serviceId: service.id, patientUserId: patient.id)

        let retrievalTerms = retrievalTerms(from: transcription.transcriptText)
        let retrievalIntent = retrievalIntent(from: retrievalTerms)
        let retrievalQuery = RetrievalQuery(
            serviceId: service.id,
            patientUserId: patient.id,
            finalidade: consent.finalidade,
            terms: retrievalTerms,
            intent: retrievalIntent,
            allowedKinds: allowedRecordKinds(for: retrievalIntent),
            maxMatches: 4,
            recencyDays: 365
        )
        let governedQuery = try GovernedRetrievalQuery(
            actorId: professional.id.uuidString,
            actorRole: lawfulContext["actorRole"] ?? "professional-agent",
            serviceId: service.id,
            patientUserId: patient.id,
            sessionId: session.id,
            finalidade: consent.finalidade,
            lawfulContext: lawfulContext,
            allowedDataLayers: [.operationalContent],
            mode: .lexical,
            providerRequirement: .init(requiresEmbeddingProvider: false),
            maxResults: 4,
            provenanceRequired: true,
            lexicalQuery: retrievalQuery
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "retrieval.request",
                providerName: "core-retrieval-governance",
                promptVersion: "retrieval-governance-v1",
                timestamp: .now
            ),
            to: &provenanceRecords
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "retrieval.policy.evaluate",
                providerName: governedQuery.mode.rawValue,
                promptVersion: "retrieval-governance-v1",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let governedResult = try await retrieval.retrieve(governedQuery: governedQuery)
        if governedResult.mode == .lexical, governedResult.failure == .semanticProviderUnavailable {
            try await appendProvenance(
                .init(
                    actorId: "aaci.context",
                    operation: "retrieval.lexical.fallback",
                    providerName: "file-backed-record-index",
                    promptVersion: "retrieval-governance-v1",
                    timestamp: .now
                ),
                to: &provenanceRecords
            )
        }
        let boundedResult = governedResult.boundedResult ?? BoundedRetrievalResult(
            query: retrievalQuery,
            matches: [],
            source: "file-backed-record-index:unavailable",
            quality: .degraded,
            notice: governedResult.failure?.localizedDescription ?? "retrieval unavailable",
            isFallbackEmpty: true
        )
        let retrieval = contextAssembler.assemble(
            finalidade: consent.finalidade,
            transcription: transcription,
            boundedResult: boundedResult
        )
        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .contextRetrieval,
            actorId: "aaci.context",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .contextRetrieved,
                payload: FirstSliceSessionEventPayload(
                    summary: retrievalEventSummary(retrieval),
                    attributes: retrievalEventAttributes(
                        retrieval: retrieval,
                        boundedResult: boundedResult,
                        retrievalIntent: retrievalIntent,
                        transcription: transcription,
                        runtimeView: gosRuntimeView
                    )
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "context.retrieve",
                providerName: boundedResult.source,
                promptVersion: gosRuntimeView == nil ? "care-context-retrieval-v3" : "care-context-retrieval-v3+gos",
                timestamp: .now
            ),
            to: &provenanceRecords
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "context.package.assemble",
                providerName: "clinical-context-assembler",
                promptVersion: "context-assembly-v1",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let composedSOAPDraft = await orchestrator.composeSOAPDraft(
            session: session,
            transcription: transcription,
            context: retrieval
        )
        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .composeSOAP,
            actorId: "aaci.draft-composer",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )
        let draftDocument = composedSOAPDraft
        let draftData = try JSONEncoder.healthOS.encode(draftDocument)
        let draftRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "drafts-soap",
                layer: .derivedArtifacts,
                content: draftData,
                metadata: soapDraftMetadata(
                    sessionId: session.id,
                    draftId: draftDocument.draft.id,
                    draftStatus: draftDocument.draft.status,
                    runtimeView: gosRuntimeView
                ),
                lawfulContext: lawfulContext
            )
        )
        try await storage.audit(objectRef: draftRef, action: "write-draft", actorId: professional.id.uuidString, metadata: lawfulContext)
        try await appendStorageLawProvenance(
            actorId: professional.id.uuidString,
            writeObjectRef: draftRef,
            auditAction: "write-draft",
            to: &provenanceRecords
        )
        let draft = DraftPackage(soapDraft: draftDocument, draftRef: draftRef)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .draftComposed,
                payload: FirstSliceSessionEventPayload(
                    summary: "SOAP draft composed and persisted.",
                    attributes: soapDraftEventAttributes(draft: draft, runtimeView: gosRuntimeView)
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.draft-composer",
                operation: "draft.compose.soap",
                providerName: providerId(from: languageModelDecision),
                modelName: providerModelName(from: languageModelDecision),
                modelVersion: providerModelVersion(from: languageModelDecision),
                promptVersion: gosPromptVersion(prefix: "soap-v2", runtimeView: gosRuntimeView),
                outputHash: draft.draftRef.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let composedReferralDraft = await orchestrator.composeReferralDraft(
            session: session,
            transcription: transcription,
            context: retrieval,
            sourceSOAPDraft: draftDocument,
            sourceSOAPDraftRef: draftRef
        )
        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .deriveReferral,
            actorId: "aaci.referral-draft",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )
        let referralDraftDocument = composedReferralDraft
        let referralDraftData = try JSONEncoder.healthOS.encode(referralDraftDocument)
        let referralDraftRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "drafts-referral",
                layer: .derivedArtifacts,
                content: referralDraftData,
                metadata: derivedDraftMetadata(
                    sessionId: session.id,
                    draftId: referralDraftDocument.draft.id,
                    sourceSOAPDraftId: draft.draft.id,
                    draftStatus: referralDraftDocument.draft.status,
                    readyForFutureGate: referralDraftDocument.readyForFutureGate,
                    runtimeView: gosRuntimeView,
                    actorId: "aaci.referral-draft"
                ),
                lawfulContext: lawfulContext
            )
        )
        try await storage.audit(
            objectRef: referralDraftRef,
            action: "write-referral-draft",
            actorId: professional.id.uuidString,
            metadata: lawfulContext
        )
        try await appendStorageLawProvenance(
            actorId: professional.id.uuidString,
            writeObjectRef: referralDraftRef,
            auditAction: "write-referral-draft",
            to: &provenanceRecords
        )
        let referralDraft = ReferralDraftPackage(
            document: referralDraftDocument,
            draftRef: referralDraftRef
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .referralDraftComposed,
                payload: FirstSliceSessionEventPayload(
                    summary: "Referral draft composed and persisted as a draft-only derivative.",
                    attributes: referralDraftEventAttributes(
                        referralDraft: referralDraft,
                        sourceSOAPDraftId: draft.draft.id,
                        runtimeView: gosRuntimeView
                    )
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.referral-draft",
                operation: "draft.compose.referral",
                providerName: providerId(from: languageModelDecision),
                modelName: providerModelName(from: languageModelDecision),
                modelVersion: providerModelVersion(from: languageModelDecision),
                promptVersion: gosPromptVersion(prefix: "referral-draft-v1", runtimeView: gosRuntimeView),
                outputHash: referralDraftRef.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let composedPrescriptionDraft = await orchestrator.composePrescriptionDraft(
            session: session,
            transcription: transcription,
            context: retrieval,
            sourceSOAPDraft: draftDocument,
            sourceSOAPDraftRef: draftRef
        )
        try await appendGOSUsageProvenanceIfActive(
            runtimePath: .derivePrescription,
            actorId: "aaci.prescription-draft",
            runtimeView: gosRuntimeView,
            to: &provenanceRecords
        )
        let prescriptionDraftDocument = composedPrescriptionDraft
        let prescriptionDraftData = try JSONEncoder.healthOS.encode(prescriptionDraftDocument)
        let prescriptionDraftRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "drafts-prescription",
                layer: .derivedArtifacts,
                content: prescriptionDraftData,
                metadata: derivedDraftMetadata(
                    sessionId: session.id,
                    draftId: prescriptionDraftDocument.draft.id,
                    sourceSOAPDraftId: draft.draft.id,
                    draftStatus: prescriptionDraftDocument.draft.status,
                    readyForFutureGate: prescriptionDraftDocument.readyForFutureGate,
                    runtimeView: gosRuntimeView,
                    actorId: "aaci.prescription-draft"
                ),
                lawfulContext: lawfulContext
            )
        )
        try await storage.audit(
            objectRef: prescriptionDraftRef,
            action: "write-prescription-draft",
            actorId: professional.id.uuidString,
            metadata: lawfulContext
        )
        try await appendStorageLawProvenance(
            actorId: professional.id.uuidString,
            writeObjectRef: prescriptionDraftRef,
            auditAction: "write-prescription-draft",
            to: &provenanceRecords
        )
        let prescriptionDraft = PrescriptionDraftPackage(
            document: prescriptionDraftDocument,
            draftRef: prescriptionDraftRef
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .prescriptionDraftComposed,
                payload: FirstSliceSessionEventPayload(
                    summary: "Prescription draft composed and persisted as a draft-only derivative.",
                    attributes: prescriptionDraftEventAttributes(
                        prescriptionDraft: prescriptionDraft,
                        sourceSOAPDraftId: draft.draft.id,
                        runtimeView: gosRuntimeView
                    )
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.prescription-draft",
                operation: "draft.compose.prescription",
                providerName: providerId(from: languageModelDecision),
                modelName: providerModelName(from: languageModelDecision),
                modelVersion: providerModelVersion(from: languageModelDecision),
                promptVersion: gosPromptVersion(prefix: "prescription-draft-v1", runtimeView: gosRuntimeView),
                outputHash: prescriptionDraftRef.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let gateRequest = await gateService.createRequest(for: draft.draft)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .gateRequested,
                payload: FirstSliceSessionEventPayload(
                    summary: "Gate requested for draft.",
                    attributes: [
                        "gateRequestId": gateRequest.id.uuidString,
                        "reviewType": gateRequest.requiredReviewType.rawValue,
                        "target": gateRequest.finalizationTarget.rawValue
                    ]
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: professional.id.uuidString,
                operation: "gate.request",
                timestamp: .now
            ),
            to: &provenanceRecords
        )
        let gateResolution = await gateService.resolve(
            gateRequest,
            resolverUserId: professional.id,
            approve: input.gateApprove
        )
        let reviewedDraftStatus: DraftStatus
        switch gateResolution.resolution {
        case .approved:
            reviewedDraftStatus = .approved
        case .rejected:
            reviewedDraftStatus = .rejected
        case .cancelled:
            reviewedDraftStatus = .superseded
        }
        let gate = GateOutcomeSummary(
            request: gateRequest,
            resolution: gateResolution,
            reviewedDraftStatus: reviewedDraftStatus,
            approved: gateResolution.resolution == .approved
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .gateResolved,
                payload: FirstSliceSessionEventPayload(
                    summary: "Gate resolved by professional.",
                    attributes: [
                        "resolution": gate.resolution.resolution.rawValue,
                        "reviewedDraftStatus": gate.reviewedDraftStatus.rawValue
                    ]
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: professional.id.uuidString,
                operation: "gate.resolve",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let finalDocument: FinalDocumentPackage?
        if gate.approved {
            try FirstSliceInvariantEnforcer.ensureSOAPDraftCanFinalize(
                draft: draft.draft,
                gate: gate
            )
            let finalizedAt = Date()
            let finalPayload = FinalizedSOAPDocument(
                sessionId: session.id,
                kind: gate.request.finalizationTarget,
                status: .finalized,
                sections: draft.soapDraft.sections,
                source: FinalDocumentSourceLink(
                    sourceDraftId: draft.draft.id,
                    sourceDraftKind: draft.draft.kind,
                    sourceDraftStatus: gate.reviewedDraftStatus,
                    sourceDraftObjectPath: draft.draftRef.objectPath,
                    gateRequestId: gate.request.id,
                    gateResolutionId: gate.resolution.id
                ),
                finalization: DocumentFinalizationMetadata(
                    finalizedAt: finalizedAt,
                    finalizerUserId: professional.id,
                    finalizerRole: gate.resolution.resolverRole,
                    reviewType: gate.request.requiredReviewType,
                    gateResolution: gate.resolution.resolution
                ),
                summary: "SOAP finalized after explicit professional gate approval."
            )
            let finalData = try JSONEncoder.healthOS.encode(finalPayload)
            let finalDocumentRef = try await storage.put(
                StoragePutRequest(
                    owner: .servico(serviceId: service.id),
                    kind: "documents-soap-final",
                    layer: .operationalContent,
                    content: finalData,
                    metadata: [
                        "sessionId": session.id.uuidString,
                        "patientUserId": patient.id.uuidString,
                        "finalidade": consent.finalidade,
                        "provenanceOperation": "document.finalize.soap",
                        "sourceDraftId": draft.draft.id.uuidString,
                        "gateRequestId": gate.request.id.uuidString,
                        "gateResolutionId": gate.resolution.id.uuidString,
                        "finalDocumentId": finalPayload.id.uuidString
                    ],
                    lawfulContext: lawfulContext
                )
            )
            try await storage.audit(
                objectRef: finalDocumentRef,
                action: "write-final-document",
                actorId: professional.id.uuidString,
                metadata: lawfulContext
            )
            try await appendStorageLawProvenance(
                actorId: professional.id.uuidString,
                writeObjectRef: finalDocumentRef,
                auditAction: "write-final-document",
                to: &provenanceRecords
            )
            events.append(
                SessionEventRecord(
                    sessionId: session.id,
                    kind: .finalDocumentPersisted,
                    payload: FirstSliceSessionEventPayload(
                        summary: "Final SOAP document persisted after gate approval.",
                        attributes: [
                            "objectPath": finalDocumentRef.objectPath,
                            "finalDocumentId": finalPayload.id.uuidString
                        ]
                    )
                )
            )
            try await appendProvenance(
                .init(
                    actorId: professional.id.uuidString,
                    operation: "document.finalize.soap",
                    outputHash: finalDocumentRef.contentHash,
                    timestamp: finalizedAt
                ),
                to: &provenanceRecords
            )
            finalDocument = FinalDocumentPackage(
                document: finalPayload,
                documentRef: finalDocumentRef
            )
        } else {
            finalDocument = nil
        }

        let gateRequestData = try JSONEncoder.healthOS.encode(gate.request)
        let gateResolutionData = try JSONEncoder.healthOS.encode(gate.resolution)
        _ = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "gate-requests",
                layer: .governanceMetadata,
                content: gateRequestData,
                metadata: [
                    "sessionId": session.id.uuidString,
                    "governanceActorId": professional.id.uuidString
                ],
                lawfulContext: lawfulContext
            )
        )
        _ = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "gate-resolutions",
                layer: .governanceMetadata,
                content: gateResolutionData,
                metadata: [
                    "sessionId": session.id.uuidString,
                    "governanceActorId": professional.id.uuidString
                ],
                lawfulContext: lawfulContext
            )
        )

        let eventsData = try JSONEncoder.healthOS.encode(events)
        _ = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "session-events",
                layer: .governanceMetadata,
                content: eventsData,
                metadata: [
                    "sessionId": session.id.uuidString,
                    "governanceActorId": professional.id.uuidString
                ],
                lawfulContext: lawfulContext
            )
        )

        return FirstSliceRunResult(
            session: session,
            transcription: transcription,
            retrieval: retrieval,
            draft: draft,
            referralDraft: referralDraft,
            prescriptionDraft: prescriptionDraft,
            gate: gate,
            finalDocument: finalDocument,
            summary: SliceRunSummary(
                sessionId: session.id,
                captureMode: input.capture.mode,
                gateApproved: gate.approved,
                gateResolution: gate.resolution.resolution,
                gateReviewedAt: gate.resolution.reviewedAt,
                gateReviewType: gate.request.requiredReviewType,
                finalizationTarget: gate.request.finalizationTarget,
                audioCaptureObjectPath: transcription.audioCapture?.storedRef.objectPath,
                transcriptObjectPath: transcription.transcriptRef?.objectPath,
                transcriptionStatus: transcription.status,
                transcriptionSource: transcription.source,
                draftObjectPath: draft.draftRef.objectPath,
                reviewedDraftStatus: gate.reviewedDraftStatus,
                referralDraftStatus: referralDraft.draft.status,
                referralDraftObjectPath: referralDraft.draftRef.objectPath,
                referralDraftSummary: referralDraft.document.noteSummary,
                prescriptionDraftStatus: prescriptionDraft.draft.status,
                prescriptionDraftObjectPath: prescriptionDraft.draftRef.objectPath,
                prescriptionDraftSummary: prescriptionDraft.document.noteSummary,
                finalDocumentStatus: finalDocument?.document.status,
                finalDocumentObjectPath: finalDocument?.documentRef.objectPath,
                finalDocumentSummary: finalDocument?.document.summary,
                retrievalMatchCount: retrieval.supportingMatches.count,
                retrievalSource: retrieval.boundedResult.source,
                retrievalContextStatus: retrieval.status,
                retrievalContextSummary: retrieval.summary,
                retrievalFallbackEmpty: retrieval.boundedResult.isFallbackEmpty,
                eventCount: events.count,
                provenanceCount: provenanceRecords.count
            ),
            provenanceRecords: provenanceRecords,
            events: events
        )
    }

    private func appendProvenance(
        _ record: ProvenanceRecord,
        to records: inout [ProvenanceRecord]
    ) async throws {
        records.append(record)
        try await provenance.append(record)
    }

    private func validateCapture(_ capture: SessionCaptureInput) throws {
        guard capture.isUsable else {
            throw FirstSliceError.invalidCaptureInput("missing text or audio reference")
        }
    }

    private func activateGOSIfAvailable(
        to records: inout [ProvenanceRecord]
    ) async throws -> AACIResolvedGOSRuntimeView? {
        do {
            let activation = try await orchestrator.activateGOS(specId: "aaci.first-slice", loader: gosLoader)
            guard let runtimeView = await orchestrator.activeGOSRuntimeView() else {
                throw FirstSliceError.gosActivationInvariantViolation(
                    "AACI reported GOS activation without a resolved runtime view"
                )
            }
            try await appendProvenance(
                .init(
                    actorId: "aaci.gos",
                    operation: AACIGOSProvenanceOperationResolver.activation,
                    providerName: "file-backed-registry",
                    modelName: runtimeView.specId,
                    modelVersion: runtimeView.bundleId,
                    promptVersion: runtimeView.usedDefaultBindingPlan ? "default-binding-plan" : "bundle-binding-plan",
                    timestamp: .now
                ),
                to: &records
            )
            _ = activation
            return runtimeView
        } catch {
            let failureDescriptor: String
            if let typed = error as? GOSLoadTypedError {
                failureDescriptor = "typed:\(typed.failure.rawValue)"
            } else {
                failureDescriptor = String(describing: error)
            }
            try await appendProvenance(
                .init(
                    actorId: "aaci.gos",
                    operation: AACIGOSProvenanceOperationResolver.activationFailed,
                    providerName: "file-backed-registry",
                    modelName: "aaci.first-slice",
                    promptVersion: failureDescriptor,
                    timestamp: .now
                ),
                to: &records
            )
            return nil
        }
    }

    private func appendGOSUsageProvenanceIfActive(
        runtimePath: AACIGOSRuntimePath,
        actorId: String,
        runtimeView: AACIResolvedGOSRuntimeView?,
        to records: inout [ProvenanceRecord]
    ) async throws {
        guard let runtimeView else { return }
        try await appendProvenance(
            .init(
                actorId: actorId,
                operation: AACIGOSProvenanceOperationResolver.usageOperation(for: runtimePath),
                providerName: "aaci-runtime",
                modelName: runtimeView.specId,
                modelVersion: runtimeView.bundleId,
                promptVersion: runtimeView.usedDefaultBindingPlan ? "default-binding-plan" : "bundle-binding-plan",
                timestamp: .now
            ),
            to: &records
        )
    }

    private func appendStorageLawProvenance(
        actorId: String,
        writeObjectRef: StorageObjectRef,
        auditAction: String,
        to records: inout [ProvenanceRecord]
    ) async throws {
        try await appendProvenance(
            .init(
                actorId: actorId,
                operation: "storage.write",
                outputHash: writeObjectRef.contentHash,
                timestamp: .now
            ),
            to: &records
        )
        try await appendProvenance(
            .init(
                actorId: actorId,
                operation: "storage.audit",
                promptVersion: auditAction,
                outputHash: writeObjectRef.contentHash,
                timestamp: .now
            ),
            to: &records
        )
    }

    private func gosPromptVersion(prefix: String, runtimeView: AACIResolvedGOSRuntimeView?) -> String {
        guard let runtimeView else { return prefix }
        return prefix + "+gos:" + runtimeView.specId
    }

    private func soapDraftMetadata(
        sessionId: UUID,
        draftId: UUID,
        draftStatus: DraftStatus,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
            "sessionId": sessionId.uuidString,
            "draftId": draftId.uuidString,
            "draftStatus": draftStatus.rawValue,
            "provenanceOperation": "draft.compose.soap"
            ],
            actorId: "aaci.draft-composer",
            runtimeView: runtimeView
        )
    }

    private func derivedDraftMetadata(
        sessionId: UUID,
        draftId: UUID,
        sourceSOAPDraftId: UUID,
        draftStatus: DraftStatus,
        readyForFutureGate: Bool,
        runtimeView: AACIResolvedGOSRuntimeView?,
        actorId: String
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
            "sessionId": sessionId.uuidString,
            "draftId": draftId.uuidString,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString,
            "draftStatus": draftStatus.rawValue,
            "readyForFutureGate": String(readyForFutureGate),
            "provenanceOperation": actorId == "aaci.referral-draft" ? "draft.compose.referral" : "draft.compose.prescription"
            ],
            actorId: actorId,
            runtimeView: runtimeView
        )
    }

    private func soapDraftEventAttributes(
        draft: DraftPackage,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
            "draftId": draft.draft.id.uuidString,
            "draftStatus": draft.draft.status.rawValue,
            "contextStatus": draft.soapDraft.contextStatus.rawValue
            ],
            actorId: "aaci.draft-composer",
            runtimeView: runtimeView
        )
    }

    private func referralDraftEventAttributes(
        referralDraft: ReferralDraftPackage,
        sourceSOAPDraftId: UUID,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
            "draftId": referralDraft.draft.id.uuidString,
            "draftStatus": referralDraft.draft.status.rawValue,
            "specialtyTarget": referralDraft.document.specialtyTarget,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString
            ],
            actorId: "aaci.referral-draft",
            runtimeView: runtimeView
        )
    }

    private func prescriptionDraftEventAttributes(
        prescriptionDraft: PrescriptionDraftPackage,
        sourceSOAPDraftId: UUID,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
            "draftId": prescriptionDraft.draft.id.uuidString,
            "draftStatus": prescriptionDraft.draft.status.rawValue,
            "medicationSuggestion": prescriptionDraft.document.medicationSuggestion,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString
            ],
            actorId: "aaci.prescription-draft",
            runtimeView: runtimeView
        )
    }

    private func gosRuntimeMetadata(
        base: [String: String],
        actorId: String,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        let runtimePath = AACIGOSRuntimeResolver.runtimePath(for: actorId)
        guard let mediationContext = AACIGOSRuntimeResolver.resolveMediationContext(
            actorId: actorId,
            runtimePath: runtimePath,
            runtimeView: runtimeView
        ) else {
            return base
        }
        return base.merging(mediationContext.payloadMetadata) { current, _ in current }
    }

    private func captureReceivedEventAttributes(
        capture: SessionCaptureInput,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
                "captureMode": capture.mode.rawValue
            ],
            actorId: "aaci.capture",
            runtimeView: runtimeView
        )
    }

    private func audioCaptureEventAttributes(
        audioCapture: AudioCaptureArtifact,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
                "objectPath": audioCapture.storedRef.objectPath,
                "displayName": audioCapture.reference.displayName
            ],
            actorId: "aaci.capture",
            runtimeView: runtimeView
        )
    }

    private func persistAudioCaptureIfNeeded(
        from capture: SessionCaptureInput,
        sessionId: UUID,
        serviceId: UUID,
        patientUserId: UUID,
        actorId: String,
        lawfulContext: [String: String],
        runtimeView: AACIResolvedGOSRuntimeView?
    ) async throws -> AudioCaptureArtifact? {
        guard capture.mode == .localAudioFile else { return nil }
        guard let audioReference = capture.audioReference else {
            throw FirstSliceError.invalidCaptureInput("audio mode requires a local audio reference")
        }

        let fileURL = audioReference.fileURL
        guard FileManager.default.fileExists(atPath: fileURL.path) else {
            throw FirstSliceError.audioCaptureFileMissing(fileURL.path)
        }

        let audioData: Data
        do {
            audioData = try Data(contentsOf: fileURL)
        } catch {
            throw FirstSliceError.audioCaptureFileUnreadable(fileURL.path)
        }

        let storedRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: serviceId),
                kind: "capture-audio",
                layer: .operationalContent,
                content: audioData,
                metadata: gosRuntimeMetadata(
                    base: [
                    "sessionId": sessionId.uuidString,
                    "patientUserId": patientUserId.uuidString,
                    "displayName": audioReference.displayName,
                    "finalidade": lawfulContext["finalidade"] ?? "care-context-retrieval"
                    ],
                    actorId: "aaci.capture",
                    runtimeView: runtimeView
                ),
                lawfulContext: lawfulContext
            )
        )
        try await storage.audit(
            objectRef: storedRef,
            action: "write-audio-capture",
            actorId: actorId,
            metadata: lawfulContext
        )
        return AudioCaptureArtifact(reference: audioReference, storedRef: storedRef)
    }

    private func persistTranscript(
        _ transcriptText: String,
        sessionId: UUID,
        serviceId: UUID,
        patientUserId: UUID,
        actorId: String,
        lawfulContext: [String: String],
        runtimeView: AACIResolvedGOSRuntimeView?
    ) async throws -> StorageObjectRef {
        let transcriptData = Data(transcriptText.utf8)
        let transcriptRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: serviceId),
                kind: "transcripts",
                layer: .operationalContent,
                content: transcriptData,
                metadata: gosRuntimeMetadata(
                    base: [
                    "sessionId": sessionId.uuidString,
                    "patientUserId": patientUserId.uuidString,
                    "finalidade": lawfulContext["finalidade"] ?? "care-context-retrieval"
                    ],
                    actorId: "aaci.transcription",
                    runtimeView: runtimeView
                ),
                lawfulContext: lawfulContext
            )
        )
        try await storage.audit(
            objectRef: transcriptRef,
            action: "write-transcript",
            actorId: actorId,
            metadata: lawfulContext
        )
        return transcriptRef
    }

    private func transcriptionEventSummary(for transcription: TranscriptionOutput) -> String {
        switch transcription.status {
        case .ready:
            return "Transcript generated and persisted."
        case .pending:
            return "Transcription remains pending."
        case .degraded:
            return "Transcription completed in degraded mode."
        case .unavailable:
            return "Transcription was unavailable for the current capture."
        }
    }

    private func transcriptionEventAttributes(
        for transcription: TranscriptionOutput,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        var attributes = gosRuntimeMetadata(
            base: [
            "status": transcription.status.rawValue,
            "source": transcription.source
            ],
            actorId: "aaci.transcription",
            runtimeView: runtimeView
        )
        if let transcriptRef = transcription.transcriptRef {
            attributes["objectPath"] = transcriptRef.objectPath
        }
        if let audioCapture = transcription.audioCapture {
            attributes["audioObjectPath"] = audioCapture.storedRef.objectPath
            attributes["audioDisplayName"] = audioCapture.reference.displayName
        }
        if let issueMessage = transcription.issueMessage {
            attributes["issue"] = issueMessage
        }
        return attributes
    }

    private func retrievalEventSummary(_ retrieval: RetrievalContextPackage) -> String {
        switch retrieval.status {
        case .degraded:
            return "Bounded context retrieval degraded; no clinically reliable package was assembled."
        case .empty:
            return "Bounded context retrieval completed with no supporting matches."
        case .partial:
            return "Bounded context retrieval produced a partial local context package."
        case .ready:
            return "Bounded context retrieval produced a structured local context package."
        }
    }

    private func retrievalEventAttributes(
        retrieval: RetrievalContextPackage,
        boundedResult: BoundedRetrievalResult,
        retrievalIntent: RetrievalIntent,
        transcription: TranscriptionOutput,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> [String: String] {
        gosRuntimeMetadata(
            base: [
                "count": String(retrieval.supportingMatches.count),
                "source": boundedResult.source,
                "quality": boundedResult.quality.rawValue,
                "contextStatus": retrieval.status.rawValue,
                "intent": retrievalIntent.rawValue,
                "fallbackEmpty": String(boundedResult.isFallbackEmpty),
                "transcriptionStatus": transcription.status.rawValue
            ],
            actorId: "aaci.context",
            runtimeView: runtimeView
        )
    }

    private func retrievalTerms(from text: String?) -> [String] {
        guard let text else { return [] }
        let separators = CharacterSet.alphanumerics.inverted
        let stopwords: Set<String> = [
            "paciente", "relata", "ultima", "ultimas", "semana", "semanas",
            "desde", "com", "sem", "uma", "duas", "dias"
        ]
        return Array(Set(text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .components(separatedBy: separators)
            .filter { $0.count >= 3 && !stopwords.contains($0) }))
            .sorted()
    }

    private func retrievalIntent(from terms: [String]) -> RetrievalIntent {
        let termSet = Set(terms)
        if termSet.contains(where: { ["alergia", "seguranca"].contains($0) }) {
            return .allergySafety
        }
        if termSet.contains(where: { ["medicacao", "medicamento", "remedio"].contains($0) }) {
            return .medicationReview
        }
        if termSet.contains(where: { ["sono", "insonia", "dormir"].contains($0) }) {
            return .sleepReview
        }
        if termSet.contains(where: { ["cefaleia", "dor", "sintoma"].contains($0) }) {
            return .symptomReview
        }
        return .generalContext
    }

    private func allowedRecordKinds(for intent: RetrievalIntent) -> [RecordSnippetKind] {
        switch intent {
        case .allergySafety:
            return [.allergy, .encounterSummary]
        case .medicationReview:
            return [.medication, .encounterSummary, .observation]
        case .sleepReview, .symptomReview:
            return [.encounterSummary, .observation, .allergy]
        case .generalContext:
            return [.encounterSummary, .observation, .allergy, .medication]
        }
    }

    private func providerId(from decision: ProviderRoutingDecision) -> String {
        switch decision {
        case .selected(let selection), .degradedFallback(let selection, _), .stubOnly(let selection, _):
            return selection.providerId
        case .deniedByPolicy:
            return "denied-by-policy"
        case .unavailable:
            return "unavailable"
        }
    }

    private func providerModelName(from decision: ProviderRoutingDecision) -> String? {
        switch decision {
        case .selected(let selection):
            return selection.isStub ? "stub" : selection.modelId
        case .degradedFallback(let selection, _):
            return selection.isStub ? "stub" : selection.modelId
        case .stubOnly:
            return "stub"
        case .deniedByPolicy, .unavailable:
            return nil
        }
    }

    private func providerModelVersion(from decision: ProviderRoutingDecision) -> String? {
        switch decision {
        case .selected(let selection), .degradedFallback(let selection, _), .stubOnly(let selection, _):
            return selection.modelVersion
        case .deniedByPolicy, .unavailable:
            return nil
        }
    }

    private func seedDemoRecordIndexIfNeeded(
        serviceId: UUID,
        patientUserId: UUID
    ) async throws {
        let existing = try await recordIndex.entries(
            serviceId: serviceId,
            patientUserId: patientUserId,
            lawfulContext: [
                "actorRole": "system-seed",
                "scope": "care-context",
                "finalidade": "care-context-retrieval",
                "habilitationId": UUID().uuidString,
                "patientUserId": patientUserId.uuidString
            ]
        )
        guard existing.isEmpty else { return }

        let iso = ISO8601DateFormatter()
        let baseDate = iso.date(from: "2026-04-10T09:00:00Z") ?? .now
        let entries = [
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000001")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .encounterSummary,
                snippet: PatientRecordSnippet(
                    summary: "Consulta prévia por cefaleia persistente, com melhora parcial após hidratação e ajuste do sono.",
                    tags: ["cefaleia", "sono", "ambulatorial"],
                    occurredAt: baseDate,
                    category: .symptom,
                    relevanceHint: .recentPriority,
                    flags: [.symptomRelated, .sleepRelated]
                ),
                sourceRef: "service-records/encounters/e1",
                sourceKind: .encounterRecord
            ),
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .allergy,
                snippet: PatientRecordSnippet(
                    summary: "Sem alergias medicamentosas registradas no serviço.",
                    tags: ["alergia", "seguranca"],
                    occurredAt: baseDate.addingTimeInterval(3600),
                    category: .allergy,
                    relevanceHint: .safetyCritical,
                    flags: [.allergyRelated]
                ),
                sourceRef: "service-records/allergies/a1",
                sourceKind: .allergyRecord
            ),
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000004")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .medication,
                snippet: PatientRecordSnippet(
                    summary: "Uso intermitente de melatonina para higiene do sono, sem eventos adversos reportados.",
                    tags: ["medicacao", "sono"],
                    occurredAt: baseDate.addingTimeInterval(5400),
                    category: .medication,
                    relevanceHint: .background,
                    flags: [.medicationRelated, .sleepRelated]
                ),
                sourceRef: "service-records/medications/m1",
                sourceKind: .medicationRecord
            ),
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .observation,
                snippet: PatientRecordSnippet(
                    summary: "Paciente relata piora de insônia na última semana, com despertares frequentes.",
                    tags: ["insonia", "sono", "sintoma"],
                    occurredAt: baseDate.addingTimeInterval(7200),
                    category: .sleep,
                    relevanceHint: .recentPriority,
                    flags: [.recent, .sleepRelated, .symptomRelated]
                ),
                sourceRef: "service-records/observations/o1",
                sourceKind: .observationRecord
            )
        ]
        try await recordIndex.replaceEntries(serviceId: serviceId, entries: entries)
    }
}

private extension JSONEncoder {
    static var healthOS: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        encoder.dateEncodingStrategy = .iso8601
        return encoder
    }
}
