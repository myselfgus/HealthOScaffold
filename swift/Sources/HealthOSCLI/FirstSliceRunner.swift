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

    init(root: URL, orchestrator: AACIOrchestrator) {
        self.root = root
        self.habilitationService = SimpleHabilitationService()
        self.consentService = SimpleConsentService()
        self.gateService = SimpleGateService()
        self.storage = FileBackedStorageService(root: root)
        self.provenance = FileBackedProvenanceLedger(root: root)
        self.orchestrator = orchestrator
    }

    func run(
        professional: Usuario,
        patient: Usuario,
        service: Servico,
        captureText: String,
        approve: Bool
    ) async throws -> FirstSliceRunResult {
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

        let sessionStartRecord = ProvenanceRecord(
            actorId: "first-slice",
            operation: "session.start",
            promptVersion: "v1",
            timestamp: .now
        )
        provenanceRecords.append(sessionStartRecord)
        try provenance.append(sessionStartRecord)

        let _ = await orchestrator.startSession(session)
        events.append(SessionEventRecord(sessionId: session.id, kind: "session.started", payload: ["serviceId": service.id.uuidString]))

        let transcriptText = "[transcribed] \(captureText)"
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
        events.append(SessionEventRecord(sessionId: session.id, kind: "transcript.generated", payload: ["objectPath": transcriptRef.objectPath]))
        let transcriptionRecord = ProvenanceRecord(
            actorId: "aaci.transcription",
            operation: "transcript.generate",
            providerName: "native-speech-stub",
            modelName: "stub",
            modelVersion: "v1",
            outputHash: transcriptRef.contentHash,
            timestamp: .now
        )
        provenanceRecords.append(transcriptionRecord)
        try provenance.append(transcriptionRecord)

        let contextItems = [
            "Consulta prévia há 10 dias por cefaleia persistente.",
            "Sem alergias registradas.",
            "Paciente relata piora do sono na última semana."
        ]
        events.append(SessionEventRecord(sessionId: session.id, kind: "context.retrieved", payload: ["count": String(contextItems.count)]))
        let retrievalRecord = ProvenanceRecord(
            actorId: "aaci.context",
            operation: "context.retrieve",
            promptVersion: "care-context-retrieval-v1",
            timestamp: .now
        )
        provenanceRecords.append(retrievalRecord)
        try provenance.append(retrievalRecord)

        let draft = await orchestrator.composeSOAPDraft(session: session, transcript: transcriptText, context: contextItems)
        let draftData = try JSONEncoder.healthOS.encode(draft)
        let draftRef = try await storage.put(
            StoragePutRequest(
                owner: .servico(serviceId: service.id),
                kind: "drafts-soap",
                layer: .derivedArtifacts,
                content: draftData,
                metadata: ["sessionId": session.id.uuidString, "draftId": draft.id.uuidString]
            )
        )
        try await storage.audit(objectRef: draftRef, action: "write-draft", actorId: professional.id.uuidString, metadata: lawfulContext)
        events.append(SessionEventRecord(sessionId: session.id, kind: "draft.created", payload: ["draftId": draft.id.uuidString]))
        let draftRecord = ProvenanceRecord(
            actorId: "aaci.draft-composer",
            operation: "draft.compose.soap",
            providerName: "apple-foundation",
            modelName: "stub",
            modelVersion: "v1",
            promptVersion: "soap-v1",
            outputHash: draftRef.contentHash,
            timestamp: .now
        )
        provenanceRecords.append(draftRecord)
        try provenance.append(draftRecord)

        let gateRequest = await gateService.createRequest(for: draft)
        events.append(SessionEventRecord(sessionId: session.id, kind: "gate.requested", payload: ["gateRequestId": gateRequest.id.uuidString]))
        let gateResolution = await gateService.resolve(gateRequest, resolverUserId: professional.id, approve: approve)
        events.append(SessionEventRecord(sessionId: session.id, kind: "gate.resolved", payload: ["resolution": gateResolution.resolution.rawValue]))
        let gateRecord = ProvenanceRecord(
            actorId: professional.id.uuidString,
            operation: "gate.resolve",
            timestamp: .now
        )
        provenanceRecords.append(gateRecord)
        try provenance.append(gateRecord)

        let finalArtifactRef: StorageObjectRef?
        if gateResolution.resolution == .approved {
            let finalPayload = [
                "sessionId": session.id.uuidString,
                "soapDraftId": draft.id.uuidString,
                "status": "effective",
                "subjective": draft.payload["subjective"] ?? "",
                "objective": draft.payload["objective"] ?? "",
                "assessment": draft.payload["assessment"] ?? "",
                "plan": draft.payload["plan"] ?? ""
            ]
            let finalData = try JSONEncoder.healthOS.encode(finalPayload)
            finalArtifactRef = try await storage.put(
                StoragePutRequest(
                    owner: .servico(serviceId: service.id),
                    kind: "soap-final",
                    layer: .operationalContent,
                    content: finalData,
                    metadata: ["sessionId": session.id.uuidString, "sourceDraftId": draft.id.uuidString]
                )
            )
            if let finalArtifactRef {
                try await storage.audit(objectRef: finalArtifactRef, action: "write-final-artifact", actorId: professional.id.uuidString, metadata: lawfulContext)
                let finalRecord = ProvenanceRecord(
                    actorId: professional.id.uuidString,
                    operation: "artifact.effectuate.soap",
                    outputHash: finalArtifactRef.contentHash,
                    timestamp: .now
                )
                provenanceRecords.append(finalRecord)
                try provenance.append(finalRecord)
            }
        } else {
            finalArtifactRef = nil
        }

        let gateRequestData = try JSONEncoder.healthOS.encode(gateRequest)
        let gateResolutionData = try JSONEncoder.healthOS.encode(gateResolution)
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "gate-requests", layer: .governanceMetadata, content: gateRequestData, metadata: ["sessionId": session.id.uuidString]))
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "gate-resolutions", layer: .governanceMetadata, content: gateResolutionData, metadata: ["sessionId": session.id.uuidString]))

        let eventsData = try JSONEncoder.healthOS.encode(events)
        _ = try await storage.put(StoragePutRequest(owner: .servico(serviceId: service.id), kind: "session-events", layer: .governanceMetadata, content: eventsData, metadata: ["sessionId": session.id.uuidString]))

        return FirstSliceRunResult(
            session: session,
            transcriptRef: transcriptRef,
            draftRef: draftRef,
            finalArtifactRef: finalArtifactRef,
            gateRequest: gateRequest,
            gateResolution: gateResolution,
            provenanceRecords: provenanceRecords,
            events: events
        )
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
