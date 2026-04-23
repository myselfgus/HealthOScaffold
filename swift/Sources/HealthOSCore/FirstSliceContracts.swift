import Foundation

public enum CaptureInputKind: String, Codable, Sendable {
    case seededText = "seeded_text"
}

public struct SessionCaptureInput: Codable, Sendable {
    public let kind: CaptureInputKind
    public let rawText: String
    public let capturedAt: Date

    public init(kind: CaptureInputKind = .seededText, rawText: String, capturedAt: Date = .now) {
        self.kind = kind
        self.rawText = rawText
        self.capturedAt = capturedAt
    }
}

public struct FirstSliceSessionInput: Codable, Sendable {
    public let professional: Usuario
    public let patient: Usuario
    public let service: Servico
    public let capture: SessionCaptureInput
    public let gateApprove: Bool

    public init(
        professional: Usuario,
        patient: Usuario,
        service: Servico,
        capture: SessionCaptureInput,
        gateApprove: Bool
    ) {
        self.professional = professional
        self.patient = patient
        self.service = service
        self.capture = capture
        self.gateApprove = gateApprove
    }
}

public struct TranscriptionResult: Codable, Sendable {
    public let transcriptText: String
    public let transcriptRef: StorageObjectRef

    public init(transcriptText: String, transcriptRef: StorageObjectRef) {
        self.transcriptText = transcriptText
        self.transcriptRef = transcriptRef
    }
}

public struct RetrievalContextPackage: Codable, Sendable {
    public let finalidade: String
    public let contextItems: [String]

    public init(finalidade: String, contextItems: [String]) {
        self.finalidade = finalidade
        self.contextItems = contextItems
    }
}

public struct DraftPackage: Codable, Sendable {
    public let draft: ArtifactDraft
    public let draftRef: StorageObjectRef

    public init(draft: ArtifactDraft, draftRef: StorageObjectRef) {
        self.draft = draft
        self.draftRef = draftRef
    }
}

public struct FinalArtifactPayload: Codable, Sendable {
    public let sessionId: UUID
    public let sourceDraftId: UUID
    public let status: String
    public let subjective: String
    public let objective: String
    public let assessment: String
    public let plan: String

    public init(
        sessionId: UUID,
        sourceDraftId: UUID,
        status: String,
        subjective: String,
        objective: String,
        assessment: String,
        plan: String
    ) {
        self.sessionId = sessionId
        self.sourceDraftId = sourceDraftId
        self.status = status
        self.subjective = subjective
        self.objective = objective
        self.assessment = assessment
        self.plan = plan
    }
}

public struct GateOutcomeSummary: Codable, Sendable {
    public let request: GateRequest
    public let resolution: GateResolution
    public let approved: Bool

    public init(request: GateRequest, resolution: GateResolution, approved: Bool) {
        self.request = request
        self.resolution = resolution
        self.approved = approved
    }
}

public struct SliceRunSummary: Codable, Sendable {
    public let sessionId: UUID
    public let gateApproved: Bool
    public let transcriptObjectPath: String
    public let draftObjectPath: String
    public let finalArtifactObjectPath: String?
    public let eventCount: Int
    public let provenanceCount: Int

    public init(
        sessionId: UUID,
        gateApproved: Bool,
        transcriptObjectPath: String,
        draftObjectPath: String,
        finalArtifactObjectPath: String?,
        eventCount: Int,
        provenanceCount: Int
    ) {
        self.sessionId = sessionId
        self.gateApproved = gateApproved
        self.transcriptObjectPath = transcriptObjectPath
        self.draftObjectPath = draftObjectPath
        self.finalArtifactObjectPath = finalArtifactObjectPath
        self.eventCount = eventCount
        self.provenanceCount = provenanceCount
    }
}

public enum FirstSliceSessionEventKind: String, Codable, Sendable {
    case sessionStarted = "session.started"
    case captureReceived = "capture.received"
    case transcriptGenerated = "transcript.generated"
    case contextRetrieved = "context.retrieved"
    case draftComposed = "draft.composed"
    case gateRequested = "gate.requested"
    case gateResolved = "gate.resolved"
    case finalArtifactPersisted = "final-artifact.persisted"
}

public struct FirstSliceSessionEventPayload: Codable, Sendable {
    public let summary: String
    public let attributes: [String: String]

    public init(summary: String, attributes: [String: String] = [:]) {
        self.summary = summary
        self.attributes = attributes
    }
}

public struct SessionEventRecord: Codable, Sendable, Identifiable {
    public let id: UUID
    public let sessionId: UUID
    public let kind: FirstSliceSessionEventKind
    public let payload: FirstSliceSessionEventPayload
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        kind: FirstSliceSessionEventKind,
        payload: FirstSliceSessionEventPayload,
        createdAt: Date = .now
    ) {
        self.id = id
        self.sessionId = sessionId
        self.kind = kind
        self.payload = payload
        self.createdAt = createdAt
    }
}

public struct FirstSliceRunResult: Codable, Sendable {
    public let session: SessaoTrabalho
    public let transcription: TranscriptionResult
    public let retrieval: RetrievalContextPackage
    public let draft: DraftPackage
    public let gate: GateOutcomeSummary
    public let finalArtifactRef: StorageObjectRef?
    public let summary: SliceRunSummary
    public let provenanceRecords: [ProvenanceRecord]
    public let events: [SessionEventRecord]

    public init(
        session: SessaoTrabalho,
        transcription: TranscriptionResult,
        retrieval: RetrievalContextPackage,
        draft: DraftPackage,
        gate: GateOutcomeSummary,
        finalArtifactRef: StorageObjectRef?,
        summary: SliceRunSummary,
        provenanceRecords: [ProvenanceRecord],
        events: [SessionEventRecord]
    ) {
        self.session = session
        self.transcription = transcription
        self.retrieval = retrieval
        self.draft = draft
        self.gate = gate
        self.finalArtifactRef = finalArtifactRef
        self.summary = summary
        self.provenanceRecords = provenanceRecords
        self.events = events
    }
}
