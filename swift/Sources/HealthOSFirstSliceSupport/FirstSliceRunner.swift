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
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .captureReceived,
                payload: FirstSliceSessionEventPayload(
                    summary: "Capture input accepted.",
                    attributes: ["captureMode": input.capture.mode.rawValue]
                )
            )
        )

        let audioCapture = try await persistAudioCaptureIfNeeded(
            from: input.capture,
            sessionId: session.id,
            serviceId: service.id,
            patientUserId: patient.id,
            actorId: professional.id.uuidString,
            lawfulContext: lawfulContext
        )
        if let audioCapture {
            events.append(
                SessionEventRecord(
                    sessionId: session.id,
                    kind: .audioCapturePersisted,
                    payload: FirstSliceSessionEventPayload(
                        summary: "Local audio capture persisted.",
                        attributes: [
                            "objectPath": audioCapture.storedRef.objectPath,
                            "displayName": audioCapture.reference.displayName
                        ]
                    )
                )
            )
            try await appendProvenance(
                .init(
                    actorId: "aaci.capture",
                    operation: "capture.audio.persist",
                    outputHash: audioCapture.storedRef.contentHash,
                    timestamp: .now
                ),
                to: &provenanceRecords
            )
        }

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
                issueMessage: "Transcription provider reported ready but produced no transcript text."
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
                lawfulContext: lawfulContext
            )
            transcription = TranscriptionOutput(
                status: transcription.status == .ready ? .ready : .degraded,
                source: transcription.source,
                transcriptText: transcriptText,
                transcriptRef: transcriptRef,
                audioCapture: transcription.audioCapture,
                issueMessage: transcription.issueMessage
            )
        }

        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .transcriptionProcessed,
                payload: FirstSliceSessionEventPayload(
                    summary: transcriptionEventSummary(for: transcription),
                    attributes: transcriptionEventAttributes(for: transcription)
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.transcription",
                operation: "transcription.process",
                providerName: transcription.source,
                modelName: transcription.source == "seeded-text" ? nil : "stub",
                modelVersion: "v1",
                inputHash: transcription.audioCapture?.storedRef.contentHash,
                outputHash: transcription.transcriptRef?.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let gosActivation = try await activateGOSIfAvailable(to: &provenanceRecords)

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
        let boundedResult = try await retrieval.retrieve(query: retrievalQuery, lawfulContext: lawfulContext)
        let retrieval = contextAssembler.assemble(
            finalidade: consent.finalidade,
            transcription: transcription,
            boundedResult: boundedResult
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .contextRetrieved,
                payload: FirstSliceSessionEventPayload(
                    summary: retrievalEventSummary(retrieval),
                    attributes: [
                        "count": String(retrieval.supportingMatches.count),
                        "source": boundedResult.source,
                        "quality": boundedResult.quality.rawValue,
                        "contextStatus": retrieval.status.rawValue,
                        "intent": retrievalIntent.rawValue,
                        "fallbackEmpty": String(boundedResult.isFallbackEmpty),
                        "transcriptionStatus": transcription.status.rawValue
                    ]
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "context.retrieve",
                providerName: boundedResult.source,
                promptVersion: gosActivation == nil ? "care-context-retrieval-v3" : "care-context-retrieval-v3+gos",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let composedSOAPDraft = await orchestrator.composeSOAPDraft(
            session: session,
            transcription: transcription,
            context: retrieval
        )
        let draftDocument = mediateSOAPDraftIfNeeded(composedSOAPDraft, activation: gosActivation)
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
                    activation: gosActivation
                )
            )
        )
        try await storage.audit(objectRef: draftRef, action: "write-draft", actorId: professional.id.uuidString, metadata: lawfulContext)
        let draft = DraftPackage(soapDraft: draftDocument, draftRef: draftRef)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .draftComposed,
                payload: FirstSliceSessionEventPayload(
                    summary: "SOAP draft composed and persisted.",
                    attributes: soapDraftEventAttributes(draft: draft, activation: gosActivation)
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.draft-composer",
                operation: "draft.compose.soap",
                providerName: "apple-foundation",
                modelName: "stub",
                modelVersion: "v1",
                promptVersion: gosPromptVersion(prefix: "soap-v2", activation: gosActivation),
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
        let referralDraftDocument = mediateReferralDraftIfNeeded(composedReferralDraft, activation: gosActivation)
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
                    activation: gosActivation
                )
            )
        )
        try await storage.audit(
            objectRef: referralDraftRef,
            action: "write-referral-draft",
            actorId: professional.id.uuidString,
            metadata: lawfulContext
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
                    attributes: referralDraftEventAttributes(referralDraft: referralDraft, sourceSOAPDraftId: draft.draft.id, activation: gosActivation)
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.referral-draft",
                operation: "draft.compose.referral",
                providerName: "apple-foundation",
                modelName: "stub",
                modelVersion: "v1",
                promptVersion: gosPromptVersion(prefix: "referral-draft-v1", activation: gosActivation),
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
        let prescriptionDraftDocument = mediatePrescriptionDraftIfNeeded(composedPrescriptionDraft, activation: gosActivation)
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
                    activation: gosActivation
                )
            )
        )
        try await storage.audit(
            objectRef: prescriptionDraftRef,
            action: "write-prescription-draft",
            actorId: professional.id.uuidString,
            metadata: lawfulContext
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
                    attributes: prescriptionDraftEventAttributes(prescriptionDraft: prescriptionDraft, sourceSOAPDraftId: draft.draft.id, activation: gosActivation)
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.prescription-draft",
                operation: "draft.compose.prescription",
                providerName: "apple-foundation",
                modelName: "stub",
                modelVersion: "v1",
                promptVersion: gosPromptVersion(prefix: "prescription-draft-v1", activation: gosActivation),
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
                        "sourceDraftId": draft.draft.id.uuidString,
                        "gateRequestId": gate.request.id.uuidString,
                        "gateResolutionId": gate.resolution.id.uuidString,
                        "finalDocumentId": finalPayload.id.uuidString
                    ]
                )
            )
            try await storage.audit(
                objectRef: finalDocumentRef,
                action: "write-final-document",
                actorId: professional.id.uuidString,
                metadata: lawfulContext
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
                metadata: ["sessionId": session.id.uuidString]
            )
        )
        _ = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "gate-resolutions",
                layer: .governanceMetadata,
                content: gateResolutionData,
                metadata: ["sessionId": session.id.uuidString]
            )
        )

        let eventsData = try JSONEncoder.healthOS.encode(events)
        _ = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "session-events",
                layer: .governanceMetadata,
                content: eventsData,
                metadata: ["sessionId": session.id.uuidString]
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
    ) async throws -> AACIGOSActivationSummary? {
        do {
            let activation = try await orchestrator.activateGOS(specId: "aaci.first-slice", loader: gosLoader)
            try await appendProvenance(
                .init(
                    actorId: "aaci.gos",
                    operation: "gos.activate",
                    providerName: "file-backed-registry",
                    modelName: activation.specId,
                    modelVersion: activation.bundleId,
                    promptVersion: activation.usedDefaultBindingPlan ? "default-binding-plan" : "bundle-binding-plan",
                    timestamp: .now
                ),
                to: &records
            )
            return activation
        } catch {
            try await appendProvenance(
                .init(
                    actorId: "aaci.gos",
                    operation: "gos.activate.failed",
                    providerName: "file-backed-registry",
                    modelName: "aaci.first-slice",
                    promptVersion: String(describing: error),
                    timestamp: .now
                ),
                to: &records
            )
            return nil
        }
    }

    private func mediateSOAPDraftIfNeeded(
        _ document: SOAPDraftDocument,
        activation: AACIGOSActivationSummary?
    ) -> SOAPDraftDocument {
        _ = activation
        return document
    }

    private func mediateReferralDraftIfNeeded(
        _ document: ReferralDraftDocument,
        activation: AACIGOSActivationSummary?
    ) -> ReferralDraftDocument {
        _ = activation
        return document
    }

    private func mediatePrescriptionDraftIfNeeded(
        _ document: PrescriptionDraftDocument,
        activation: AACIGOSActivationSummary?
    ) -> PrescriptionDraftDocument {
        _ = activation
        return document
    }

    private func gosPromptVersion(prefix: String, activation: AACIGOSActivationSummary?) -> String {
        guard let activation else { return prefix }
        return prefix + "+gos:" + activation.specId
    }

    private func soapDraftMetadata(
        sessionId: UUID,
        draftId: UUID,
        draftStatus: DraftStatus,
        activation: AACIGOSActivationSummary?
    ) -> [String: String] {
        var metadata: [String: String] = [
            "sessionId": sessionId.uuidString,
            "draftId": draftId.uuidString,
            "draftStatus": draftStatus.rawValue
        ]
        if let activation {
            metadata["gosSpecId"] = activation.specId
            metadata["gosBundleId"] = activation.bundleId
            metadata["gosUsedDefaultBindingPlan"] = String(activation.usedDefaultBindingPlan)
        }
        return metadata
    }

    private func derivedDraftMetadata(
        sessionId: UUID,
        draftId: UUID,
        sourceSOAPDraftId: UUID,
        draftStatus: DraftStatus,
        readyForFutureGate: Bool,
        activation: AACIGOSActivationSummary?
    ) -> [String: String] {
        var metadata: [String: String] = [
            "sessionId": sessionId.uuidString,
            "draftId": draftId.uuidString,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString,
            "draftStatus": draftStatus.rawValue,
            "readyForFutureGate": String(readyForFutureGate)
        ]
        if let activation {
            metadata["gosSpecId"] = activation.specId
            metadata["gosBundleId"] = activation.bundleId
            metadata["gosUsedDefaultBindingPlan"] = String(activation.usedDefaultBindingPlan)
        }
        return metadata
    }

    private func soapDraftEventAttributes(
        draft: DraftPackage,
        activation: AACIGOSActivationSummary?
    ) -> [String: String] {
        var attributes: [String: String] = [
            "draftId": draft.draft.id.uuidString,
            "draftStatus": draft.draft.status.rawValue,
            "contextStatus": draft.soapDraft.contextStatus.rawValue
        ]
        if let activation {
            attributes["gosSpecId"] = activation.specId
            attributes["gosBundleId"] = activation.bundleId
        }
        return attributes
    }

    private func referralDraftEventAttributes(
        referralDraft: ReferralDraftPackage,
        sourceSOAPDraftId: UUID,
        activation: AACIGOSActivationSummary?
    ) -> [String: String] {
        var attributes: [String: String] = [
            "draftId": referralDraft.draft.id.uuidString,
            "draftStatus": referralDraft.draft.status.rawValue,
            "specialtyTarget": referralDraft.document.specialtyTarget,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString
        ]
        if let activation {
            attributes["gosSpecId"] = activation.specId
            attributes["gosBundleId"] = activation.bundleId
        }
        return attributes
    }

    private func prescriptionDraftEventAttributes(
        prescriptionDraft: PrescriptionDraftPackage,
        sourceSOAPDraftId: UUID,
        activation: AACIGOSActivationSummary?
    ) -> [String: String] {
        var attributes: [String: String] = [
            "draftId": prescriptionDraft.draft.id.uuidString,
            "draftStatus": prescriptionDraft.draft.status.rawValue,
            "medicationSuggestion": prescriptionDraft.document.medicationSuggestion,
            "sourceSOAPDraftId": sourceSOAPDraftId.uuidString
        ]
        if let activation {
            attributes["gosSpecId"] = activation.specId
            attributes["gosBundleId"] = activation.bundleId
        }
        return attributes
    }

    private func persistAudioCaptureIfNeeded(
        from capture: SessionCaptureInput,
        sessionId: UUID,
        serviceId: UUID,
        patientUserId: UUID,
        actorId: String,
        lawfulContext: [String: String]
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
                metadata: [
                    "sessionId": sessionId.uuidString,
                    "patientUserId": patientUserId.uuidString,
                    "displayName": audioReference.displayName
                ]
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
        lawfulContext: [String: String]
    ) async throws -> StorageObjectRef {
        let transcriptData = Data(transcriptText.utf8)
        let transcriptRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: serviceId),
                kind: "transcripts",
                layer: .operationalContent,
                content: transcriptData,
                metadata: [
                    "sessionId": sessionId.uuidString,
                    "patientUserId": patientUserId.uuidString
                ]
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

    private func transcriptionEventAttributes(for transcription: TranscriptionOutput) -> [String: String] {
        var attributes: [String: String] = [
            "status": transcription.status.rawValue,
            "source": transcription.source
        ]
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
                "habilitationId": "seed",
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
