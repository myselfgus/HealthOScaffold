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
                promptVersion: "care-context-retrieval-v3",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let draftModel = await orchestrator.composeSOAPDraft(
            session: session,
            transcription: transcription,
            context: retrieval
        )
        let draftData = try JSONEncoder.healthOS.encode(draftModel)
        let draftRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "drafts-soap",
                layer: .derivedArtifacts,
                content: draftData,
                metadata: ["sessionId": session.id.uuidString, "draftId": draftModel.id.uuidString]
            )
        )
        try await storage.audit(objectRef: draftRef, action: "write-draft", actorId: professional.id.uuidString, metadata: lawfulContext)
        let draft = DraftPackage(draft: draftModel, draftRef: draftRef)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .draftComposed,
                payload: FirstSliceSessionEventPayload(
                    summary: "SOAP draft composed and persisted.",
                    attributes: ["draftId": draft.draft.id.uuidString]
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
                promptVersion: "soap-v1",
                outputHash: draft.draftRef.contentHash,
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
                    attributes: ["gateRequestId": gateRequest.id.uuidString]
                )
            )
        )
        let gateResolution = await gateService.resolve(
            gateRequest,
            resolverUserId: professional.id,
            approve: input.gateApprove
        )
        let gate = GateOutcomeSummary(
            request: gateRequest,
            resolution: gateResolution,
            approved: gateResolution.resolution == .approved
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .gateResolved,
                payload: FirstSliceSessionEventPayload(
                    summary: "Gate resolved by professional.",
                    attributes: ["resolution": gate.resolution.resolution.rawValue]
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

        let finalArtifactRef: StorageObjectRef?
        if gate.approved {
            let finalPayload = FinalArtifactPayload(
                sessionId: session.id,
                sourceDraftId: draft.draft.id,
                status: .effective,
                subjective: draft.draft.payload["subjective"] ?? "",
                objective: draft.draft.payload["objective"] ?? "",
                assessment: draft.draft.payload["assessment"] ?? "",
                plan: draft.draft.payload["plan"] ?? ""
            )
            let finalData = try JSONEncoder.healthOS.encode(finalPayload)
            finalArtifactRef = try await storage.put(
                StoragePutRequest(
                    owner: .servico(serviceId: service.id),
                    kind: "soap-final",
                    layer: .operationalContent,
                    content: finalData,
                    metadata: [
                        "sessionId": session.id.uuidString,
                        "sourceDraftId": draft.draft.id.uuidString
                    ]
                )
            )
            if let finalArtifactRef {
                try await storage.audit(
                    objectRef: finalArtifactRef,
                    action: "write-final-artifact",
                    actorId: professional.id.uuidString,
                    metadata: lawfulContext
                )
                events.append(
                    SessionEventRecord(
                        sessionId: session.id,
                        kind: .finalArtifactPersisted,
                        payload: FirstSliceSessionEventPayload(
                            summary: "Final artifact persisted after gate approval.",
                            attributes: ["objectPath": finalArtifactRef.objectPath]
                        )
                    )
                )
                try await appendProvenance(
                    .init(
                        actorId: professional.id.uuidString,
                        operation: "artifact.effectuate.soap",
                        outputHash: finalArtifactRef.contentHash,
                        timestamp: .now
                    ),
                    to: &provenanceRecords
                )
            }
        } else {
            finalArtifactRef = nil
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
            gate: gate,
            finalArtifactRef: finalArtifactRef,
            summary: SliceRunSummary(
                sessionId: session.id,
                captureMode: input.capture.mode,
                gateApproved: gate.approved,
                audioCaptureObjectPath: transcription.audioCapture?.storedRef.objectPath,
                transcriptObjectPath: transcription.transcriptRef?.objectPath,
                transcriptionStatus: transcription.status,
                transcriptionSource: transcription.source,
                draftObjectPath: draft.draftRef.objectPath,
                finalArtifactObjectPath: finalArtifactRef?.objectPath,
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
