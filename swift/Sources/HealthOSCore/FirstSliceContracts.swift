import Foundation

public enum CaptureMode: String, Codable, Sendable, CaseIterable {
    case seededText = "seeded_text"
    case localAudioFile = "local_audio_file"
}

public struct AudioCaptureReference: Codable, Sendable {
    public let filePath: String
    public let displayName: String
    public let importedAt: Date

    public init(filePath: String, displayName: String, importedAt: Date = .now) {
        self.filePath = filePath
        self.displayName = displayName
        self.importedAt = importedAt
    }

    public init(fileURL: URL, importedAt: Date = .now) {
        self.init(
            filePath: fileURL.path,
            displayName: fileURL.lastPathComponent,
            importedAt: importedAt
        )
    }

    public var fileURL: URL {
        URL(fileURLWithPath: filePath)
    }
}

public struct AudioCaptureArtifact: Codable, Sendable {
    public let reference: AudioCaptureReference
    public let storedRef: StorageObjectRef

    public init(reference: AudioCaptureReference, storedRef: StorageObjectRef) {
        self.reference = reference
        self.storedRef = storedRef
    }
}

public struct SessionCaptureInput: Codable, Sendable {
    public let mode: CaptureMode
    public let rawText: String?
    public let audioReference: AudioCaptureReference?
    public let capturedAt: Date

    public init(
        mode: CaptureMode,
        rawText: String? = nil,
        audioReference: AudioCaptureReference? = nil,
        capturedAt: Date = .now
    ) {
        self.mode = mode
        self.rawText = rawText
        self.audioReference = audioReference
        self.capturedAt = capturedAt
    }

    public init(rawText: String, capturedAt: Date = .now) {
        self.init(mode: .seededText, rawText: rawText, capturedAt: capturedAt)
    }

    public init(audioReference: AudioCaptureReference, capturedAt: Date = .now) {
        self.init(mode: .localAudioFile, audioReference: audioReference, capturedAt: capturedAt)
    }

    public var normalizedText: String? {
        rawText?
            .trimmingCharacters(in: .whitespacesAndNewlines)
            .nilIfEmpty
    }

    public var previewText: String {
        switch mode {
        case .seededText:
            return normalizedText ?? ""
        case .localAudioFile:
            return audioReference.map { "Local audio selected: \($0.displayName)" } ?? ""
        }
    }

    public var isUsable: Bool {
        switch mode {
        case .seededText:
            return normalizedText != nil
        case .localAudioFile:
            return audioReference != nil
        }
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

public enum TranscriptionStatus: String, Codable, Sendable {
    case pending
    case ready
    case degraded
    case unavailable
}

public struct TranscriptionInput: Codable, Sendable {
    public let captureMode: CaptureMode
    public let seededText: String?
    public let audioCapture: AudioCaptureArtifact?
    public let requestedAt: Date

    public init(
        captureMode: CaptureMode,
        seededText: String? = nil,
        audioCapture: AudioCaptureArtifact? = nil,
        requestedAt: Date = .now
    ) {
        self.captureMode = captureMode
        self.seededText = seededText
        self.audioCapture = audioCapture
        self.requestedAt = requestedAt
    }
}

public struct TranscriptionOutput: Codable, Sendable {
    public let status: TranscriptionStatus
    public let source: String
    public let transcriptText: String?
    public let transcriptRef: StorageObjectRef?
    public let audioCapture: AudioCaptureArtifact?
    public let issueMessage: String?

    public init(
        status: TranscriptionStatus,
        source: String,
        transcriptText: String? = nil,
        transcriptRef: StorageObjectRef? = nil,
        audioCapture: AudioCaptureArtifact? = nil,
        issueMessage: String? = nil
    ) {
        self.status = status
        self.source = source
        self.transcriptText = transcriptText
        self.transcriptRef = transcriptRef
        self.audioCapture = audioCapture
        self.issueMessage = issueMessage
    }

    public var workflowText: String {
        if let transcriptText = transcriptText?.trimmingCharacters(in: .whitespacesAndNewlines),
           !transcriptText.isEmpty {
            return transcriptText
        }

        switch status {
        case .pending:
            return "Local audio capture is pending transcription."
        case .ready:
            return ""
        case .degraded:
            return "Local audio capture stored; transcription degraded." + detailSuffix
        case .unavailable:
            return "Local audio capture stored; transcription unavailable." + detailSuffix
        }
    }

    private var detailSuffix: String {
        guard let issueMessage = issueMessage?.trimmingCharacters(in: .whitespacesAndNewlines),
              !issueMessage.isEmpty else {
            return ""
        }
        return " \(issueMessage)"
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
    public let captureMode: CaptureMode
    public let gateApproved: Bool
    public let audioCaptureObjectPath: String?
    public let transcriptObjectPath: String?
    public let transcriptionStatus: TranscriptionStatus
    public let transcriptionSource: String
    public let draftObjectPath: String
    public let finalArtifactObjectPath: String?
    public let retrievalMatchCount: Int
    public let retrievalSource: String
    public let retrievalFallbackEmpty: Bool
    public let eventCount: Int
    public let provenanceCount: Int

    public init(
        sessionId: UUID,
        captureMode: CaptureMode,
        gateApproved: Bool,
        audioCaptureObjectPath: String?,
        transcriptObjectPath: String?,
        transcriptionStatus: TranscriptionStatus,
        transcriptionSource: String,
        draftObjectPath: String,
        finalArtifactObjectPath: String?,
        retrievalMatchCount: Int,
        retrievalSource: String,
        retrievalFallbackEmpty: Bool,
        eventCount: Int,
        provenanceCount: Int
    ) {
        self.sessionId = sessionId
        self.captureMode = captureMode
        self.gateApproved = gateApproved
        self.audioCaptureObjectPath = audioCaptureObjectPath
        self.transcriptObjectPath = transcriptObjectPath
        self.transcriptionStatus = transcriptionStatus
        self.transcriptionSource = transcriptionSource
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
    case audioCapturePersisted = "audio.capture.persisted"
    case transcriptionProcessed = "transcription.processed"
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
    public let transcription: TranscriptionOutput
    public let retrieval: RetrievalContextPackage
    public let draft: DraftPackage
    public let gate: GateOutcomeSummary
    public let finalArtifactRef: StorageObjectRef?
    public let summary: SliceRunSummary
    public let provenanceRecords: [ProvenanceRecord]
    public let events: [SessionEventRecord]

    public init(
        session: SessaoTrabalho,
        transcription: TranscriptionOutput,
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

private extension String {
    var nilIfEmpty: String? {
        isEmpty ? nil : self
    }
}
