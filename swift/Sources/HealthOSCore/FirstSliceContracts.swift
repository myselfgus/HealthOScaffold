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

public struct ProviderExecutionMetadata: Codable, Sendable, Equatable {
    public let providerId: String
    public let providerKind: String
    public let taskClass: String
    public let status: String
    public let modelId: String?
    public let modelVersion: String?
    public let isStub: Bool
    public let reason: String?

    public init(
        providerId: String,
        providerKind: String,
        taskClass: String,
        status: String,
        modelId: String? = nil,
        modelVersion: String? = nil,
        isStub: Bool,
        reason: String? = nil
    ) {
        self.providerId = providerId
        self.providerKind = providerKind
        self.taskClass = taskClass
        self.status = status
        self.modelId = modelId
        self.modelVersion = modelVersion
        self.isStub = isStub
        self.reason = reason
    }
}

public struct TranscriptionOutput: Codable, Sendable {
    public let status: TranscriptionStatus
    public let source: String
    public let transcriptText: String?
    public let transcriptRef: StorageObjectRef?
    public let audioCapture: AudioCaptureArtifact?
    public let issueMessage: String?
    public let providerExecution: ProviderExecutionMetadata?

    public init(
        status: TranscriptionStatus,
        source: String,
        transcriptText: String? = nil,
        transcriptRef: StorageObjectRef? = nil,
        audioCapture: AudioCaptureArtifact? = nil,
        issueMessage: String? = nil,
        providerExecution: ProviderExecutionMetadata? = nil
    ) {
        self.status = status
        self.source = source
        self.transcriptText = transcriptText
        self.transcriptRef = transcriptRef
        self.audioCapture = audioCapture
        self.issueMessage = issueMessage
        self.providerExecution = providerExecution
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

public enum RecordClinicalCategory: String, Codable, Sendable, CaseIterable {
    case encounterContext = "encounter_context"
    case symptom
    case sleep
    case medication
    case allergy
    case operational
}

public enum RecordSourceKind: String, Codable, Sendable, CaseIterable {
    case encounterRecord = "encounter_record"
    case observationRecord = "observation_record"
    case medicationRecord = "medication_record"
    case allergyRecord = "allergy_record"
    case serviceIndex = "service_index"
}

public enum RetrievalRelevanceHint: String, Codable, Sendable, CaseIterable {
    case background
    case recentPriority = "recent_priority"
    case safetyCritical = "safety_critical"
}

public enum RetrievalSignalFlag: String, Codable, Sendable, CaseIterable {
    case recent
    case medicationRelated = "medication_related"
    case sleepRelated = "sleep_related"
    case symptomRelated = "symptom_related"
    case allergyRelated = "allergy_related"
}

public enum RetrievalIntent: String, Codable, Sendable {
    case generalContext = "general_context"
    case symptomReview = "symptom_review"
    case sleepReview = "sleep_review"
    case medicationReview = "medication_review"
    case allergySafety = "allergy_safety"
}

public enum RetrievalResultQuality: String, Codable, Sendable {
    case strong
    case limited
    case empty
    case degraded
}

public enum RetrievalContextStatus: String, Codable, Sendable {
    case ready
    case partial
    case empty
    case degraded
}

public struct RetrievalScoreBreakdown: Codable, Sendable {
    public let lexicalScore: Int
    public let tagScore: Int
    public let recencyScore: Int
    public let categoryBoost: Int
    public let intentBoost: Int
    public let relevanceHintBoost: Int
    public let totalScore: Int

    public init(
        lexicalScore: Int,
        tagScore: Int,
        recencyScore: Int,
        categoryBoost: Int,
        intentBoost: Int,
        relevanceHintBoost: Int,
        totalScore: Int
    ) {
        self.lexicalScore = lexicalScore
        self.tagScore = tagScore
        self.recencyScore = recencyScore
        self.categoryBoost = categoryBoost
        self.intentBoost = intentBoost
        self.relevanceHintBoost = relevanceHintBoost
        self.totalScore = totalScore
    }
}

public struct RetrievalContextHighlight: Codable, Sendable, Identifiable {
    public let id: UUID
    public let headline: String
    public let summary: String
    public let sourceRef: String
    public let category: RecordClinicalCategory
    public let whyRelevant: String

    public init(
        id: UUID,
        headline: String,
        summary: String,
        sourceRef: String,
        category: RecordClinicalCategory,
        whyRelevant: String
    ) {
        self.id = id
        self.headline = headline
        self.summary = summary
        self.sourceRef = sourceRef
        self.category = category
        self.whyRelevant = whyRelevant
    }
}

public struct RetrievalProvenanceHint: Codable, Sendable {
    public let label: String
    public let value: String

    public init(label: String, value: String) {
        self.label = label
        self.value = value
    }
}

public struct RetrievalContextPackage: Codable, Sendable {
    public let finalidade: String
    public let status: RetrievalContextStatus
    public let summary: String
    public let highlights: [RetrievalContextHighlight]
    public let supportingMatches: [RetrievalMatch]
    public let provenanceHints: [RetrievalProvenanceHint]
    public let notice: String?
    public let boundedResult: BoundedRetrievalResult

    public init(
        finalidade: String,
        status: RetrievalContextStatus,
        summary: String,
        highlights: [RetrievalContextHighlight],
        supportingMatches: [RetrievalMatch],
        provenanceHints: [RetrievalProvenanceHint],
        notice: String? = nil,
        boundedResult: BoundedRetrievalResult
    ) {
        self.finalidade = finalidade
        self.status = status
        self.summary = summary
        self.highlights = highlights
        self.supportingMatches = supportingMatches
        self.provenanceHints = provenanceHints
        self.notice = notice
        self.boundedResult = boundedResult
    }

    public var contextItems: [String] {
        if !highlights.isEmpty {
            return highlights.map(\.summary)
        }
        return supportingMatches.map(\.summary)
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
    public let category: RecordClinicalCategory
    public let relevanceHint: RetrievalRelevanceHint
    public let flags: [RetrievalSignalFlag]

    public init(
        summary: String,
        tags: [String],
        occurredAt: Date,
        category: RecordClinicalCategory = .encounterContext,
        relevanceHint: RetrievalRelevanceHint = .background,
        flags: [RetrievalSignalFlag] = []
    ) {
        self.summary = summary
        self.tags = tags
        self.occurredAt = occurredAt
        self.category = category
        self.relevanceHint = relevanceHint
        self.flags = flags
    }

    enum CodingKeys: String, CodingKey {
        case summary
        case tags
        case occurredAt
        case category
        case relevanceHint
        case flags
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let summary = try container.decode(String.self, forKey: .summary)
        let tags = try container.decode([String].self, forKey: .tags)
        let occurredAt = try container.decode(Date.self, forKey: .occurredAt)
        let inferredCategory = inferRecordClinicalCategory(summary: summary, tags: tags)

        self.summary = summary
        self.tags = tags
        self.occurredAt = occurredAt
        self.category = try container.decodeIfPresent(RecordClinicalCategory.self, forKey: .category)
            ?? inferredCategory
        self.relevanceHint = try container.decodeIfPresent(RetrievalRelevanceHint.self, forKey: .relevanceHint)
            ?? inferRetrievalRelevanceHint(summary: summary, tags: tags, category: inferredCategory)
        self.flags = try container.decodeIfPresent([RetrievalSignalFlag].self, forKey: .flags)
            ?? inferRetrievalSignalFlags(summary: summary, tags: tags, occurredAt: occurredAt)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(summary, forKey: .summary)
        try container.encode(tags, forKey: .tags)
        try container.encode(occurredAt, forKey: .occurredAt)
        try container.encode(category, forKey: .category)
        try container.encode(relevanceHint, forKey: .relevanceHint)
        try container.encode(flags, forKey: .flags)
    }
}

public struct RecordIndexEntry: Codable, Sendable, Identifiable {
    public let id: UUID
    public let serviceId: UUID
    public let patientUserId: UUID
    public let snippetKind: RecordSnippetKind
    public let snippet: PatientRecordSnippet
    public let sourceRef: String
    public let sourceKind: RecordSourceKind

    public init(
        id: UUID = UUID(),
        serviceId: UUID,
        patientUserId: UUID,
        snippetKind: RecordSnippetKind,
        snippet: PatientRecordSnippet,
        sourceRef: String,
        sourceKind: RecordSourceKind? = nil
    ) {
        self.id = id
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.snippetKind = snippetKind
        self.snippet = snippet
        self.sourceRef = sourceRef
        self.sourceKind = sourceKind ?? inferRecordSourceKind(for: snippetKind)
    }

    enum CodingKeys: String, CodingKey {
        case id
        case serviceId
        case patientUserId
        case snippetKind
        case snippet
        case sourceRef
        case sourceKind
    }

    public init(from decoder: any Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let id = try container.decode(UUID.self, forKey: .id)
        let serviceId = try container.decode(UUID.self, forKey: .serviceId)
        let patientUserId = try container.decode(UUID.self, forKey: .patientUserId)
        let snippetKind = try container.decode(RecordSnippetKind.self, forKey: .snippetKind)
        let snippet = try container.decode(PatientRecordSnippet.self, forKey: .snippet)
        let sourceRef = try container.decode(String.self, forKey: .sourceRef)

        self.id = id
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.snippetKind = snippetKind
        self.snippet = snippet
        self.sourceRef = sourceRef
        self.sourceKind = try container.decodeIfPresent(RecordSourceKind.self, forKey: .sourceKind)
            ?? inferRecordSourceKind(for: snippetKind)
    }

    public func encode(to encoder: any Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(serviceId, forKey: .serviceId)
        try container.encode(patientUserId, forKey: .patientUserId)
        try container.encode(snippetKind, forKey: .snippetKind)
        try container.encode(snippet, forKey: .snippet)
        try container.encode(sourceRef, forKey: .sourceRef)
        try container.encode(sourceKind, forKey: .sourceKind)
    }
}

public struct RetrievalQuery: Codable, Sendable {
    public let serviceId: UUID
    public let patientUserId: UUID
    public let finalidade: String
    public let terms: [String]
    public let intent: RetrievalIntent
    public let allowedKinds: [RecordSnippetKind]
    public let maxMatches: Int
    public let recencyDays: Int?

    public init(
        serviceId: UUID,
        patientUserId: UUID,
        finalidade: String,
        terms: [String],
        intent: RetrievalIntent = .generalContext,
        allowedKinds: [RecordSnippetKind] = RecordSnippetKind.allCases,
        maxMatches: Int = 5,
        recencyDays: Int? = 365
    ) {
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.finalidade = finalidade
        self.terms = terms
        self.intent = intent
        self.allowedKinds = allowedKinds
        self.maxMatches = maxMatches
        self.recencyDays = recencyDays
    }
}

public struct RetrievalMatch: Codable, Sendable, Identifiable {
    public let id: UUID
    public let snippetKind: RecordSnippetKind
    public let category: RecordClinicalCategory
    public let sourceKind: RecordSourceKind
    public let relevanceHint: RetrievalRelevanceHint
    public let flags: [RetrievalSignalFlag]
    public let summary: String
    public let sourceRef: String
    public let score: Int
    public let matchedTerms: [String]
    public let matchedTags: [String]
    public let occurredAt: Date
    public let scoreBreakdown: RetrievalScoreBreakdown

    public init(
        id: UUID,
        snippetKind: RecordSnippetKind,
        category: RecordClinicalCategory,
        sourceKind: RecordSourceKind,
        relevanceHint: RetrievalRelevanceHint,
        flags: [RetrievalSignalFlag],
        summary: String,
        sourceRef: String,
        score: Int,
        matchedTerms: [String],
        matchedTags: [String],
        occurredAt: Date,
        scoreBreakdown: RetrievalScoreBreakdown
    ) {
        self.id = id
        self.snippetKind = snippetKind
        self.category = category
        self.sourceKind = sourceKind
        self.relevanceHint = relevanceHint
        self.flags = flags
        self.summary = summary
        self.sourceRef = sourceRef
        self.score = score
        self.matchedTerms = matchedTerms
        self.matchedTags = matchedTags
        self.occurredAt = occurredAt
        self.scoreBreakdown = scoreBreakdown
    }
}

public struct BoundedRetrievalResult: Codable, Sendable {
    public let query: RetrievalQuery
    public let matches: [RetrievalMatch]
    public let source: String
    public let quality: RetrievalResultQuality
    public let notice: String?
    public let isFallbackEmpty: Bool

    public init(
        query: RetrievalQuery,
        matches: [RetrievalMatch],
        source: String,
        quality: RetrievalResultQuality,
        notice: String? = nil,
        isFallbackEmpty: Bool
    ) {
        self.query = query
        self.matches = matches
        self.source = source
        self.quality = quality
        self.notice = notice
        self.isFallbackEmpty = isFallbackEmpty
    }
}

public struct SOAPNoteSections: Codable, Sendable {
    public let subjective: String
    public let objective: String
    public let assessment: String
    public let plan: String

    public init(
        subjective: String,
        objective: String,
        assessment: String,
        plan: String
    ) {
        self.subjective = subjective
        self.objective = objective
        self.assessment = assessment
        self.plan = plan
    }

    public var previewText: String {
        [
            "S: \(subjective)",
            "O: \(objective)",
            "A: \(assessment)",
            "P: \(plan)"
        ]
        .joined(separator: "\n")
    }

    public var payload: [String: String] {
        [
            "subjective": subjective,
            "objective": objective,
            "assessment": assessment,
            "plan": plan
        ]
    }
}

public struct SOAPDraftDocument: Codable, Sendable {
    public let draft: ArtifactDraft
    public let sections: SOAPNoteSections
    public let contextStatus: RetrievalContextStatus
    public let contextSummary: String
    public let noteSummary: String

    public init(
        draft: ArtifactDraft,
        sections: SOAPNoteSections,
        contextStatus: RetrievalContextStatus,
        contextSummary: String,
        noteSummary: String
    ) {
        self.draft = draft
        self.sections = sections
        self.contextStatus = contextStatus
        self.contextSummary = contextSummary
        self.noteSummary = noteSummary
    }
}

public struct DraftPackage: Codable, Sendable {
    public let soapDraft: SOAPDraftDocument
    public let draftRef: StorageObjectRef

    public init(soapDraft: SOAPDraftDocument, draftRef: StorageObjectRef) {
        self.soapDraft = soapDraft
        self.draftRef = draftRef
    }

    public var draft: ArtifactDraft {
        soapDraft.draft
    }
}

public struct DerivedDraftSpineLink: Codable, Sendable {
    public let sourceSessionId: UUID
    public let sourceSOAPDraftId: UUID
    public let sourceSOAPDraftStatus: DraftStatus
    public let sourceSOAPDraftObjectPath: String
    public let sourceContextStatus: RetrievalContextStatus
    public let sourceContextSummary: String

    public init(
        sourceSessionId: UUID,
        sourceSOAPDraftId: UUID,
        sourceSOAPDraftStatus: DraftStatus,
        sourceSOAPDraftObjectPath: String,
        sourceContextStatus: RetrievalContextStatus,
        sourceContextSummary: String
    ) {
        self.sourceSessionId = sourceSessionId
        self.sourceSOAPDraftId = sourceSOAPDraftId
        self.sourceSOAPDraftStatus = sourceSOAPDraftStatus
        self.sourceSOAPDraftObjectPath = sourceSOAPDraftObjectPath
        self.sourceContextStatus = sourceContextStatus
        self.sourceContextSummary = sourceContextSummary
    }
}

public struct ReferralDraftDocument: Codable, Sendable {
    public let draft: ArtifactDraft
    public let specialtyTarget: String
    public let reason: String
    public let contextSummary: String
    public let noteSummary: String
    public let readyForFutureGate: Bool
    public let draftOnlyNote: String
    public let spineLink: DerivedDraftSpineLink

    public init(
        draft: ArtifactDraft,
        specialtyTarget: String,
        reason: String,
        contextSummary: String,
        noteSummary: String,
        readyForFutureGate: Bool,
        draftOnlyNote: String,
        spineLink: DerivedDraftSpineLink
    ) {
        self.draft = draft
        self.specialtyTarget = specialtyTarget
        self.reason = reason
        self.contextSummary = contextSummary
        self.noteSummary = noteSummary
        self.readyForFutureGate = readyForFutureGate
        self.draftOnlyNote = draftOnlyNote
        self.spineLink = spineLink
    }

    public var previewText: String {
        [
            "target: \(specialtyTarget)",
            "reason: \(reason)",
            "summary: \(noteSummary)",
            "context: \(contextSummary)",
            draftOnlyNote
        ]
        .joined(separator: "\n")
    }
}

public struct ReferralDraftPackage: Codable, Sendable {
    public let document: ReferralDraftDocument
    public let draftRef: StorageObjectRef

    public init(document: ReferralDraftDocument, draftRef: StorageObjectRef) {
        self.document = document
        self.draftRef = draftRef
    }

    public var draft: ArtifactDraft {
        document.draft
    }
}

public struct PrescriptionDraftDocument: Codable, Sendable {
    public let draft: ArtifactDraft
    public let medicationSuggestion: String
    public let instructionsDraft: String
    public let rationale: String
    public let contextSummary: String
    public let noteSummary: String
    public let readyForFutureGate: Bool
    public let draftOnlyNote: String
    public let spineLink: DerivedDraftSpineLink

    public init(
        draft: ArtifactDraft,
        medicationSuggestion: String,
        instructionsDraft: String,
        rationale: String,
        contextSummary: String,
        noteSummary: String,
        readyForFutureGate: Bool,
        draftOnlyNote: String,
        spineLink: DerivedDraftSpineLink
    ) {
        self.draft = draft
        self.medicationSuggestion = medicationSuggestion
        self.instructionsDraft = instructionsDraft
        self.rationale = rationale
        self.contextSummary = contextSummary
        self.noteSummary = noteSummary
        self.readyForFutureGate = readyForFutureGate
        self.draftOnlyNote = draftOnlyNote
        self.spineLink = spineLink
    }

    public var previewText: String {
        [
            "suggestion: \(medicationSuggestion)",
            "instructions: \(instructionsDraft)",
            "rationale: \(rationale)",
            "context: \(contextSummary)",
            draftOnlyNote
        ]
        .joined(separator: "\n")
    }
}

public struct PrescriptionDraftPackage: Codable, Sendable {
    public let document: PrescriptionDraftDocument
    public let draftRef: StorageObjectRef

    public init(document: PrescriptionDraftDocument, draftRef: StorageObjectRef) {
        self.document = document
        self.draftRef = draftRef
    }

    public var draft: ArtifactDraft {
        document.draft
    }
}

public struct FinalDocumentSourceLink: Codable, Sendable {
    public let sourceDraftId: UUID
    public let sourceDraftKind: DraftKind
    public let sourceDraftStatus: DraftStatus
    public let sourceDraftObjectPath: String
    public let gateRequestId: UUID
    public let gateResolutionId: UUID

    public init(
        sourceDraftId: UUID,
        sourceDraftKind: DraftKind,
        sourceDraftStatus: DraftStatus,
        sourceDraftObjectPath: String,
        gateRequestId: UUID,
        gateResolutionId: UUID
    ) {
        self.sourceDraftId = sourceDraftId
        self.sourceDraftKind = sourceDraftKind
        self.sourceDraftStatus = sourceDraftStatus
        self.sourceDraftObjectPath = sourceDraftObjectPath
        self.gateRequestId = gateRequestId
        self.gateResolutionId = gateResolutionId
    }
}

public struct DocumentFinalizationMetadata: Codable, Sendable {
    public let finalizedAt: Date
    public let finalizerUserId: UUID
    public let finalizerRole: String
    public let reviewType: GateReviewType
    public let gateResolution: GateResolutionKind

    public init(
        finalizedAt: Date,
        finalizerUserId: UUID,
        finalizerRole: String,
        reviewType: GateReviewType,
        gateResolution: GateResolutionKind
    ) {
        self.finalizedAt = finalizedAt
        self.finalizerUserId = finalizerUserId
        self.finalizerRole = finalizerRole
        self.reviewType = reviewType
        self.gateResolution = gateResolution
    }
}

public struct FinalizedSOAPDocument: Codable, Sendable {
    public let id: UUID
    public let sessionId: UUID
    public let kind: FinalDocumentKind
    public let status: FinalDocumentStatus
    public let sections: SOAPNoteSections
    public let source: FinalDocumentSourceLink
    public let finalization: DocumentFinalizationMetadata
    public let summary: String

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        kind: FinalDocumentKind,
        status: FinalDocumentStatus,
        sections: SOAPNoteSections,
        source: FinalDocumentSourceLink,
        finalization: DocumentFinalizationMetadata,
        summary: String
    ) {
        self.id = id
        self.sessionId = sessionId
        self.kind = kind
        self.status = status
        self.sections = sections
        self.source = source
        self.finalization = finalization
        self.summary = summary
    }
}

public struct FinalDocumentPackage: Codable, Sendable {
    public let document: FinalizedSOAPDocument
    public let documentRef: StorageObjectRef

    public init(document: FinalizedSOAPDocument, documentRef: StorageObjectRef) {
        self.document = document
        self.documentRef = documentRef
    }
}

public struct GateOutcomeSummary: Codable, Sendable {
    public let request: GateRequest
    public let resolution: GateResolution
    public let reviewedDraftStatus: DraftStatus
    public let approved: Bool

    public init(
        request: GateRequest,
        resolution: GateResolution,
        reviewedDraftStatus: DraftStatus,
        approved: Bool
    ) {
        self.request = request
        self.resolution = resolution
        self.reviewedDraftStatus = reviewedDraftStatus
        self.approved = approved
    }
}

public struct SliceRunSummary: Codable, Sendable {
    public let sessionId: UUID
    public let captureMode: CaptureMode
    public let gateApproved: Bool
    public let gateResolution: GateResolutionKind
    public let gateReviewedAt: Date
    public let gateReviewType: GateReviewType
    public let finalizationTarget: FinalDocumentKind
    public let audioCaptureObjectPath: String?
    public let transcriptObjectPath: String?
    public let transcriptionStatus: TranscriptionStatus
    public let transcriptionSource: String
    public let draftObjectPath: String
    public let reviewedDraftStatus: DraftStatus
    public let referralDraftStatus: DraftStatus
    public let referralDraftObjectPath: String
    public let referralDraftSummary: String
    public let prescriptionDraftStatus: DraftStatus
    public let prescriptionDraftObjectPath: String
    public let prescriptionDraftSummary: String
    public let finalDocumentStatus: FinalDocumentStatus?
    public let finalDocumentObjectPath: String?
    public let finalDocumentSummary: String?
    public let retrievalMatchCount: Int
    public let retrievalSource: String
    public let retrievalContextStatus: RetrievalContextStatus
    public let retrievalContextSummary: String
    public let retrievalFallbackEmpty: Bool
    public let eventCount: Int
    public let provenanceCount: Int

    public init(
        sessionId: UUID,
        captureMode: CaptureMode,
        gateApproved: Bool,
        gateResolution: GateResolutionKind,
        gateReviewedAt: Date,
        gateReviewType: GateReviewType,
        finalizationTarget: FinalDocumentKind,
        audioCaptureObjectPath: String?,
        transcriptObjectPath: String?,
        transcriptionStatus: TranscriptionStatus,
        transcriptionSource: String,
        draftObjectPath: String,
        reviewedDraftStatus: DraftStatus,
        referralDraftStatus: DraftStatus,
        referralDraftObjectPath: String,
        referralDraftSummary: String,
        prescriptionDraftStatus: DraftStatus,
        prescriptionDraftObjectPath: String,
        prescriptionDraftSummary: String,
        finalDocumentStatus: FinalDocumentStatus?,
        finalDocumentObjectPath: String?,
        finalDocumentSummary: String?,
        retrievalMatchCount: Int,
        retrievalSource: String,
        retrievalContextStatus: RetrievalContextStatus,
        retrievalContextSummary: String,
        retrievalFallbackEmpty: Bool,
        eventCount: Int,
        provenanceCount: Int
    ) {
        self.sessionId = sessionId
        self.captureMode = captureMode
        self.gateApproved = gateApproved
        self.gateResolution = gateResolution
        self.gateReviewedAt = gateReviewedAt
        self.gateReviewType = gateReviewType
        self.finalizationTarget = finalizationTarget
        self.audioCaptureObjectPath = audioCaptureObjectPath
        self.transcriptObjectPath = transcriptObjectPath
        self.transcriptionStatus = transcriptionStatus
        self.transcriptionSource = transcriptionSource
        self.draftObjectPath = draftObjectPath
        self.reviewedDraftStatus = reviewedDraftStatus
        self.referralDraftStatus = referralDraftStatus
        self.referralDraftObjectPath = referralDraftObjectPath
        self.referralDraftSummary = referralDraftSummary
        self.prescriptionDraftStatus = prescriptionDraftStatus
        self.prescriptionDraftObjectPath = prescriptionDraftObjectPath
        self.prescriptionDraftSummary = prescriptionDraftSummary
        self.finalDocumentStatus = finalDocumentStatus
        self.finalDocumentObjectPath = finalDocumentObjectPath
        self.finalDocumentSummary = finalDocumentSummary
        self.retrievalMatchCount = retrievalMatchCount
        self.retrievalSource = retrievalSource
        self.retrievalContextStatus = retrievalContextStatus
        self.retrievalContextSummary = retrievalContextSummary
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
    case referralDraftComposed = "draft.referral.composed"
    case prescriptionDraftComposed = "draft.prescription.composed"
    case gateRequested = "gate.requested"
    case gateResolved = "gate.resolved"
    case finalDocumentPersisted = "final.document.persisted"
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
    public let referralDraft: ReferralDraftPackage
    public let prescriptionDraft: PrescriptionDraftPackage
    public let gate: GateOutcomeSummary
    public let finalDocument: FinalDocumentPackage?
    public let summary: SliceRunSummary
    public let provenanceRecords: [ProvenanceRecord]
    public let events: [SessionEventRecord]

    public init(
        session: SessaoTrabalho,
        transcription: TranscriptionOutput,
        retrieval: RetrievalContextPackage,
        draft: DraftPackage,
        referralDraft: ReferralDraftPackage,
        prescriptionDraft: PrescriptionDraftPackage,
        gate: GateOutcomeSummary,
        finalDocument: FinalDocumentPackage?,
        summary: SliceRunSummary,
        provenanceRecords: [ProvenanceRecord],
        events: [SessionEventRecord]
    ) {
        self.session = session
        self.transcription = transcription
        self.retrieval = retrieval
        self.draft = draft
        self.referralDraft = referralDraft
        self.prescriptionDraft = prescriptionDraft
        self.gate = gate
        self.finalDocument = finalDocument
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

private func inferRecordClinicalCategory(summary: String, tags: [String]) -> RecordClinicalCategory {
    let tokens = Set(normalizedRetrievalTokens(in: [summary] + tags))
    if tokens.contains(where: { ["alergia", "seguranca"].contains($0) }) {
        return .allergy
    }
    if tokens.contains(where: { ["medicacao", "medicamento", "remedio"].contains($0) }) {
        return .medication
    }
    if tokens.contains(where: { ["sono", "insonia", "dormir"].contains($0) }) {
        return .sleep
    }
    if tokens.contains(where: { ["sintoma", "cefaleia", "dor"].contains($0) }) {
        return .symptom
    }
    return .encounterContext
}

private func inferRetrievalRelevanceHint(
    summary: String,
    tags: [String],
    category: RecordClinicalCategory
) -> RetrievalRelevanceHint {
    let tokens = Set(normalizedRetrievalTokens(in: [summary] + tags))
    if category == .allergy || tokens.contains("seguranca") {
        return .safetyCritical
    }
    if tokens.contains(where: { ["recente", "ultima", "semana", "hoje"].contains($0) }) {
        return .recentPriority
    }
    return .background
}

private func inferRetrievalSignalFlags(
    summary: String,
    tags: [String],
    occurredAt: Date
) -> [RetrievalSignalFlag] {
    let tokens = Set(normalizedRetrievalTokens(in: [summary] + tags))
    var flags: Set<RetrievalSignalFlag> = []

    if tokens.contains(where: { ["sono", "insonia", "dormir"].contains($0) }) {
        flags.insert(.sleepRelated)
    }
    if tokens.contains(where: { ["sintoma", "cefaleia", "dor"].contains($0) }) {
        flags.insert(.symptomRelated)
    }
    if tokens.contains(where: { ["medicacao", "medicamento", "remedio"].contains($0) }) {
        flags.insert(.medicationRelated)
    }
    if tokens.contains(where: { ["alergia", "seguranca"].contains($0) }) {
        flags.insert(.allergyRelated)
    }
    if Calendar.current.dateComponents([.day], from: occurredAt, to: .now).day ?? .max <= 30 {
        flags.insert(.recent)
    }

    return flags.sorted { $0.rawValue < $1.rawValue }
}

private func inferRecordSourceKind(for snippetKind: RecordSnippetKind) -> RecordSourceKind {
    switch snippetKind {
    case .encounterSummary:
        return .encounterRecord
    case .allergy:
        return .allergyRecord
    case .medication:
        return .medicationRecord
    case .observation:
        return .observationRecord
    }
}

private func normalizedRetrievalTokens(in values: [String]) -> [String] {
    let separators = CharacterSet.alphanumerics.inverted
    return values
        .flatMap {
            $0.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                .components(separatedBy: separators)
        }
        .filter { $0.count >= 3 }
        .map { $0.lowercased() }
}
