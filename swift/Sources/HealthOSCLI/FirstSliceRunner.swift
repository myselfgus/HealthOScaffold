import Foundation
import HealthOSCore
import HealthOSProviders
import HealthOSAACI

actor FirstSliceRunner {
    private let root: URL
    private let habilitationService: SimpleHabilitationService
    private let consentService: SimpleConsentService
    private let gateService: SimpleGateService
    private let storage: FileBackedStorageService
    private let provenance: FileBackedProvenanceLedger
    private let orchestrator: AACIOrchestrator
    private let retrieval: BoundedContextRetrievalService
    private let recordIndex: FileBackedRecordIndex

    init(root: URL, orchestrator: AACIOrchestrator) {
        self.root = root
        self.habilitationService = SimpleHabilitationService()
        self.consentService = SimpleConsentService()
        self.gateService = SimpleGateService()
        self.storage = FileBackedStorageService(root: root)
        self.provenance = FileBackedProvenanceLedger(root: root)
        self.orchestrator = orchestrator
        self.recordIndex = FileBackedRecordIndex(root: root)
        self.retrieval = BoundedContextRetrievalService(index: self.recordIndex)
    }

    func run(input: FirstSliceSessionInput) async throws -> FirstSliceRunResult {
        let professional = input.professional
        let patient = input.patient
        let service = input.service

        let habilitation = try await habilitationService.validate(professional: professional, service: service)
        let consent = try await consentService.validate(patient: patient, finalidade: "care-context-retrieval")

        let session = SessaoTrabalho(
            kind: .encounter,
            serviceId: service.id,
            professionalUserId: professional.id,
            patientUserId: patient.id,
            habilitationId: habilitation.id
        )

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
                    attributes: ["captureKind": input.capture.kind.rawValue]
                )
            )
        )

        let transcriptText = "[transcribed] \(input.capture.rawText)"
        let transcriptData = Data(transcriptText.utf8)
        let lawfulContext: [String: String] = [
            "actorRole": "professional-agent",
            "scope": "care-context",
            "serviceId": service.id.uuidString,
            "patientUserId": patient.id.uuidString,
            "habilitationId": habilitation.id.uuidString,
            "finalidade": consent.finalidade,
            "sessionId": session.id.uuidString
        ]
        let transcriptRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "transcripts",
                layer: .operationalContent,
                content: transcriptData,
                metadata: ["sessionId": session.id.uuidString, "patientUserId": patient.id.uuidString]
            )
        )
        try await storage.audit(objectRef: transcriptRef, action: "write-transcript", actorId: professional.id.uuidString, metadata: lawfulContext)
        let transcription = TranscriptionResult(transcriptText: transcriptText, transcriptRef: transcriptRef)
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .transcriptGenerated,
                payload: FirstSliceSessionEventPayload(
                    summary: "Transcript persisted.",
                    attributes: ["objectPath": transcription.transcriptRef.objectPath]
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.transcription",
                operation: "transcript.generate",
                providerName: "native-speech-stub",
                modelName: "stub",
                modelVersion: "v1",
                outputHash: transcription.transcriptRef.contentHash,
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        try await seedDemoRecordIndexIfNeeded(serviceId: service.id, patientUserId: patient.id)

        let retrievalQuery = RetrievalQuery(
            serviceId: service.id,
            patientUserId: patient.id,
            finalidade: consent.finalidade,
            terms: retrievalTerms(from: transcriptText),
            allowedKinds: [.encounterSummary, .allergy, .observation],
            maxMatches: 4,
            recencyDays: 365
        )
        let boundedResult = try await retrieval.retrieve(query: retrievalQuery, lawfulContext: lawfulContext)
        let contextItems = boundedResult.matches.map(\.summary)
        let retrieval = RetrievalContextPackage(
            finalidade: consent.finalidade,
            contextItems: contextItems,
            boundedResult: boundedResult
        )
        events.append(
            SessionEventRecord(
                sessionId: session.id,
                kind: .contextRetrieved,
                payload: FirstSliceSessionEventPayload(
                    summary: boundedResult.isFallbackEmpty ? "No bounded context matches found." : "Bounded context retrieved.",
                    attributes: [
                        "count": String(retrieval.contextItems.count),
                        "source": boundedResult.source,
                        "fallbackEmpty": String(boundedResult.isFallbackEmpty)
                    ]
                )
            )
        )
        try await appendProvenance(
            .init(
                actorId: "aaci.context",
                operation: "context.retrieve",
                providerName: boundedResult.source,
                promptVersion: "care-context-retrieval-v2",
                timestamp: .now
            ),
            to: &provenanceRecords
        )

        let draftModel = await orchestrator.composeSOAPDraft(session: session, transcript: transcription.transcriptText, context: retrieval.contextItems)
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
        let gateResolution = await gateService.resolve(gateRequest, resolverUserId: professional.id, approve: input.gateApprove)
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
                    metadata: ["sessionId": session.id.uuidString, "sourceDraftId": draft.draft.id.uuidString]
                )
            )
            if let finalArtifactRef {
                try await storage.audit(objectRef: finalArtifactRef, action: "write-final-artifact", actorId: professional.id.uuidString, metadata: lawfulContext)
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
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "gate-requests", layer: .governanceMetadata, content: gateRequestData, metadata: ["sessionId": session.id.uuidString]))
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "gate-resolutions", layer: .governanceMetadata, content: gateResolutionData, metadata: ["sessionId": session.id.uuidString]))

        let eventsData = try JSONEncoder.healthOS.encode(events)
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "session-events", layer: .governanceMetadata, content: eventsData, metadata: ["sessionId": session.id.uuidString]))

        return FirstSliceRunResult(
            session: session,
            transcription: transcription,
            retrieval: retrieval,
            draft: draft,
            gate: gate,
            finalArtifactRef: finalArtifactRef,
            summary: SliceRunSummary(
                sessionId: session.id,
                gateApproved: gate.approved,
                transcriptObjectPath: transcription.transcriptRef.objectPath,
                draftObjectPath: draft.draftRef.objectPath,
                finalArtifactObjectPath: finalArtifactRef?.objectPath,
                retrievalMatchCount: retrieval.boundedResult.matches.count,
                retrievalSource: retrieval.boundedResult.source,
                retrievalFallbackEmpty: retrieval.boundedResult.isFallbackEmpty,
                eventCount: events.count,
                provenanceCount: provenanceRecords.count
            ),
            provenanceRecords: provenanceRecords,
            events: events
        )
    }

    private func appendProvenance(_ record: ProvenanceRecord, to records: inout [ProvenanceRecord]) async throws {
        records.append(record)
        try await provenance.append(record)
    }

    private func retrievalTerms(from text: String) -> [String] {
        let separators = CharacterSet.alphanumerics.inverted
        return text
            .lowercased()
            .components(separatedBy: separators)
            .filter { $0.count >= 4 }
    }

    private func seedDemoRecordIndexIfNeeded(serviceId: UUID, patientUserId: UUID) async throws {
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
                    occurredAt: baseDate
                ),
                sourceRef: "service-records/encounters/e1"
            ),
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000002")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .allergy,
                snippet: PatientRecordSnippet(
                    summary: "Sem alergias medicamentosas registradas no serviço.",
                    tags: ["alergia", "seguranca"],
                    occurredAt: baseDate.addingTimeInterval(3600)
                ),
                sourceRef: "service-records/allergies/a1"
            ),
            RecordIndexEntry(
                id: UUID(uuidString: "10000000-0000-0000-0000-000000000003")!,
                serviceId: serviceId,
                patientUserId: patientUserId,
                snippetKind: .observation,
                snippet: PatientRecordSnippet(
                    summary: "Paciente relata piora de insônia na última semana, com despertares frequentes.",
                    tags: ["insonia", "sono", "sintoma"],
                    occurredAt: baseDate.addingTimeInterval(7200)
                ),
                sourceRef: "service-records/observations/o1"
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
