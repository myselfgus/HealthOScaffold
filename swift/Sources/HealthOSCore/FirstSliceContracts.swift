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
    public let boundedResult: BoundedRetrievalResult

    public init(finalidade: String, contextItems: [String], boundedResult: BoundedRetrievalResult) {
        self.finalidade = finalidade
        self.contextItems = contextItems
        self.boundedResult = boundedResult
    }
}

public enum RecordSnippetKind: String, Codable, Sendable, CaseIterable {
    case encounterSummary = "encounter-summary"
    case allergy = "allergy"
    case medication = "medication"
    case observation = "observation"
}

public struct PatientRecordSnippet: Codable, Sendable {
    public let summary: String
    public let tags: [String]
    public let occurredAt: Date

    public init(summary: String, tags: [String], occurredAt: Date) {
        self.summary = summary
        self.tags = tags
        self.occurredAt = occurredAt
    }
}

public struct RecordIndexEntry: Codable, Sendable, Identifiable {
    public let id: UUID
    public let serviceId: UUID
    public let patientUserId: UUID
    public let snippetKind: RecordSnippetKind
    public let snippet: PatientRecordSnippet
    public let sourceRef: String

    public init(
        id: UUID = UUID(),
        serviceId: UUID,
        patientUserId: UUID,
        snippetKind: RecordSnippetKind,
        snippet: PatientRecordSnippet,
        sourceRef: String
    ) {
        self.id = id
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.snippetKind = snippetKind
        self.snippet = snippet
        self.sourceRef = sourceRef
    }
}

public struct RetrievalQuery: Codable, Sendable {
    public let serviceId: UUID
    public let patientUserId: UUID
    public let finalidade: String
    public let terms: [String]
    public let allowedKinds: [RecordSnippetKind]
    public let maxMatches: Int
    public let recencyDays: Int?

    public init(
        serviceId: UUID,
        patientUserId: UUID,
        finalidade: String,
        terms: [String],
        allowedKinds: [RecordSnippetKind] = RecordSnippetKind.allCases,
        maxMatches: Int = 5,
        recencyDays: Int? = 365
    ) {
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.finalidade = finalidade
        self.terms = terms
        self.allowedKinds = allowedKinds
        self.maxMatches = maxMatches
        self.recencyDays = recencyDays
    }
}

public struct RetrievalMatch: Codable, Sendable, Identifiable {
    public let id: UUID
    public let snippetKind: RecordSnippetKind
    public let summary: String
    public let sourceRef: String
    public let score: Int
    public let matchedTerms: [String]
    public let occurredAt: Date

    public init(
        id: UUID,
        snippetKind: RecordSnippetKind,
        summary: String,
        sourceRef: String,
        score: Int,
        matchedTerms: [String],
        occurredAt: Date
    ) {
        self.id = id
        self.snippetKind = snippetKind
        self.summary = summary
        self.sourceRef = sourceRef
        self.score = score
        self.matchedTerms = matchedTerms
        self.occurredAt = occurredAt
    }
}

public struct BoundedRetrievalResult: Codable, Sendable {
    public let query: RetrievalQuery
    public let matches: [RetrievalMatch]
    public let source: String
    public let isFallbackEmpty: Bool

    public init(query: RetrievalQuery, matches: [RetrievalMatch], source: String, isFallbackEmpty: Bool) {
        self.query = query
        self.matches = matches
        self.source = source
        self.isFallbackEmpty = isFallbackEmpty
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

public enum FinalArtifactStatus: String, Codable, Sendable {
    case effective
}

public struct FinalArtifactPayload: Codable, Sendable {
    public let sessionId: UUID
    public let sourceDraftId: UUID
    public let status: FinalArtifactStatus
    public let subjective: String
    public let objective: String
    public let assessment: String
    public let plan: String

    public init(
        sessionId: UUID,
        sourceDraftId: UUID,
        status: FinalArtifactStatus,
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
    public let retrievalMatchCount: Int
    public let retrievalSource: String
    public let retrievalFallbackEmpty: Bool
    public let eventCount: Int
    public let provenanceCount: Int

    public init(
        sessionId: UUID,
        gateApproved: Bool,
        transcriptObjectPath: String,
        draftObjectPath: String,
        finalArtifactObjectPath: String?,
        retrievalMatchCount: Int,
        retrievalSource: String,
        retrievalFallbackEmpty: Bool,
        eventCount: Int,
        provenanceCount: Int
    ) {
        self.sessionId = sessionId
        self.gateApproved = gateApproved
        self.transcriptObjectPath = transcriptObjectPath
        self.draftObjectPath = draftObjectPath
        self.finalArtifactObjectPath = finalArtifactObjectPath
        self.retrievalMatchCount = retrievalMatchCount
        self.retrievalSource = retrievalSource
        self.retrievalFallbackEmpty = retrievalFallbackEmpty
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
    case finalArtifactPersisted = "final.artifact.persisted"
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
