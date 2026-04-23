import Foundation

public enum FirstSliceError: Error, LocalizedError, Sendable {
    case inactiveProfessionalUser
    case inactivePatientUser
    case invalidService
    case invalidCaptureInput(String)
    case audioCaptureFileMissing(String)
    case audioCaptureFileUnreadable(String)
    case missingLawfulContext(String)
    case storageIntegrityFailure(String)
    case retrievalScopeViolation

    public var errorDescription: String? {
        switch self {
        case .inactiveProfessionalUser:
            return "Professional user is inactive."
        case .inactivePatientUser:
            return "Patient user is inactive."
        case .invalidService:
            return "Service is invalid for this operation."
        case .invalidCaptureInput(let detail):
            return "Capture input is invalid: \(detail)."
        case .audioCaptureFileMissing(let path):
            return "Audio capture file is missing at path: \(path)."
        case .audioCaptureFileUnreadable(let path):
            return "Audio capture file could not be read at path: \(path)."
        case .missingLawfulContext(let key):
            return "Missing lawful context key: \(key)."
        case .storageIntegrityFailure(let path):
            return "Stored object failed integrity verification at path: \(path)."
        case .retrievalScopeViolation:
            return "Retrieval query exceeds lawful session scope."
        }
    }
}

public struct HabilitationContext: Codable, Sendable {
    public let id: UUID
    public let professionalUserId: UUID
    public let serviceId: UUID
    public let openedAt: Date

    public init(id: UUID = UUID(), professionalUserId: UUID, serviceId: UUID, openedAt: Date = .now) {
        self.id = id
        self.professionalUserId = professionalUserId
        self.serviceId = serviceId
        self.openedAt = openedAt
    }
}

public struct ConsentContext: Codable, Sendable {
    public let patientUserId: UUID
    public let finalidade: String
    public let grantedAt: Date

    public init(patientUserId: UUID, finalidade: String, grantedAt: Date = .now) {
        self.patientUserId = patientUserId
        self.finalidade = finalidade
        self.grantedAt = grantedAt
    }
}

public actor SimpleHabilitationService {
    public init() {}

    public func validate(professional: Usuario, service: Servico) throws -> HabilitationContext {
        guard professional.active else { throw FirstSliceError.inactiveProfessionalUser }
        guard !service.nome.isEmpty else { throw FirstSliceError.invalidService }
        return HabilitationContext(professionalUserId: professional.id, serviceId: service.id)
    }
}

public actor SimpleConsentService {
    public init() {}

    public func validate(patient: Usuario, finalidade: String) throws -> ConsentContext {
        guard patient.active else { throw FirstSliceError.inactivePatientUser }
        return ConsentContext(patientUserId: patient.id, finalidade: finalidade)
    }
}

public actor SimpleGateService {
    public init() {}

    public func createRequest(for draft: ArtifactDraft) -> GateRequest {
        GateRequest(
            draftId: draft.id,
            requestedAction: "finalize-soap-note",
            requiredRole: "professional",
            requiredReviewType: .professionalDocumentReview,
            finalizationTarget: .soapNote,
            requiresSignature: true,
            rationaleNote: "Professional review is required before a SOAP draft becomes an effective document."
        )
    }

    public func resolve(_ request: GateRequest, resolverUserId: UUID, approve: Bool) -> GateResolution {
        GateResolution(
            gateRequestId: request.id,
            resolverUserId: resolverUserId,
            resolverRole: request.requiredRole,
            resolution: approve ? .approved : .rejected,
            rationaleNote: approve
                ? "Professional review approved document finalization."
                : "Professional review rejected document finalization."
        )
    }
}

public actor FileBackedStorageService: StorageService {
    private let root: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(root: URL) {
        self.root = root
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func put(_ request: StoragePutRequest) async throws -> StorageObjectRef {
        let base = try ownerBaseURL(for: request.owner)
        let directory = base.appending(path: request.kind)
        try FileManager.default.createDirectory(at: directory, withIntermediateDirectories: true)

        let filename = "\(UUID().uuidString.lowercased()).bin"
        let objectURL = directory.appending(path: filename)
        let hash = Self.sha256Hex(for: request.content)
        try request.content.write(to: objectURL)

        let objectRef = StorageObjectRef(
            objectPath: objectURL.path,
            contentHash: hash,
            layer: request.layer,
            kind: request.kind
        )

        let metaURL = objectURL.appendingPathExtension("meta.json")
        let metadata = StorageMetadata(objectRef: objectRef, metadata: request.metadata)
        try encoder.encode(metadata).write(to: metaURL)
        return objectRef
    }

    public func get(_ objectRef: StorageObjectRef, lawfulContext: [String : String]) async throws -> Data {
        try requireLawfulContext(lawfulContext)
        let objectURL = URL(fileURLWithPath: objectRef.objectPath)
        let data = try Data(contentsOf: objectURL)
        let computedHash = Self.sha256Hex(for: data)
        guard computedHash == objectRef.contentHash else {
            throw FirstSliceError.storageIntegrityFailure(objectRef.objectPath)
        }
        return data
    }

    public func list(owner: StorageOwner, filters: [String : String], lawfulContext: [String : String]) async throws -> [StorageObjectRef] {
        try requireLawfulContext(lawfulContext)
        let base = try ownerBaseURL(for: owner)
        guard FileManager.default.fileExists(atPath: base.path) else { return [] }

        var results: [StorageObjectRef] = []
        let enumerator = FileManager.default.enumerator(at: base, includingPropertiesForKeys: nil)
        while let fileURL = enumerator?.nextObject() as? URL {
            guard fileURL.lastPathComponent.hasSuffix(".meta.json") else { continue }
            let data = try Data(contentsOf: fileURL)
            let metadata = try decoder.decode(StorageMetadata.self, from: data)
            if let kind = filters["kind"], metadata.objectRef.kind != kind {
                continue
            }
            results.append(metadata.objectRef)
        }
        return results.sorted { $0.objectPath < $1.objectPath }
    }

    public func audit(objectRef: StorageObjectRef, action: String, actorId: String, metadata: [String : String]) async throws {
        let auditURL = root.appending(path: "logs").appending(path: "storage-audit.jsonl")
        try FileManager.default.createDirectory(at: auditURL.deletingLastPathComponent(), withIntermediateDirectories: true)

        let entry = StorageAuditEntry(objectPath: objectRef.objectPath, action: action, actorId: actorId, metadata: metadata)
        let encoded = try encoder.encode(entry)
        try appendLine(encoded, to: auditURL)
    }

    private func ownerBaseURL(for owner: StorageOwner) throws -> URL {
        switch owner {
        case .usuario(let cpfHash):
            try DirectoryLayout.ensureUserTree(root: root, cpfHash: cpfHash)
            return DirectoryLayout.userRoot(root: root, cpfHash: cpfHash).appending(path: "artifacts")
        case .servico(let serviceId):
            try DirectoryLayout.ensureServiceTree(root: root, serviceId: serviceId)
            return DirectoryLayout.serviceRoot(root: root, serviceId: serviceId).appending(path: "records")
        }
    }

    private func requireLawfulContext(_ lawfulContext: [String: String]) throws {
        for key in ["actorRole", "scope"] {
            guard lawfulContext[key] != nil else {
                throw FirstSliceError.missingLawfulContext(key)
            }
        }
    }

    private func appendLine(_ data: Data, to url: URL) throws {
        if FileManager.default.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            handle.write(data)
            handle.write(Data("\n".utf8))
        } else {
            try (data + Data("\n".utf8)).write(to: url)
        }
    }

    private struct StorageMetadata: Codable {
        let objectRef: StorageObjectRef
        let metadata: [String: String]
    }

    private struct StorageAuditEntry: Codable {
        let objectPath: String
        let action: String
        let actorId: String
        let metadata: [String: String]
        let timestamp: Date = .now
    }

    private static func sha256Hex(for data: Data) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/shasum")
        process.arguments = ["-a", "256"]

        let input = Pipe()
        let output = Pipe()
        process.standardInput = input
        process.standardOutput = output

        do {
            try process.run()
            input.fileHandleForWriting.write(data)
            try input.fileHandleForWriting.close()
            process.waitUntilExit()
            let digestData = output.fileHandleForReading.readDataToEndOfFile()
            let raw = String(decoding: digestData, as: UTF8.self)
            return raw.split(separator: " ").first.map(String.init) ?? "sha256-unavailable"
        } catch {
            return "sha256-unavailable"
        }
    }
}

public actor FileBackedProvenanceLedger {
    private let root: URL
    private let encoder: JSONEncoder

    public init(root: URL) {
        self.root = root
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
    }

    public func append(_ record: ProvenanceRecord) throws {
        let url = root.appending(path: "system").appending(path: "provenance.jsonl")
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let data = try encoder.encode(record)
        if FileManager.default.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            handle.write(data)
            handle.write(Data("\n".utf8))
        } else {
            try (data + Data("\n".utf8)).write(to: url)
        }
    }
}

public actor FileBackedRecordIndex {
    private let root: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(root: URL) {
        self.root = root
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
    }

    public func replaceEntries(serviceId: UUID, entries: [RecordIndexEntry]) throws {
        let fileURL = indexFileURL(serviceId: serviceId)
        var existing: [RecordIndexEntry] = []
        if FileManager.default.fileExists(atPath: fileURL.path) {
            let data = try Data(contentsOf: fileURL)
            existing = (try? decoder.decode([RecordIndexEntry].self, from: data)) ?? []
        }

        let replacementKeys = Set(entries.map { CompositeKey(serviceId: $0.serviceId, patientUserId: $0.patientUserId, id: $0.id) })
        existing.removeAll { replacementKeys.contains(CompositeKey(serviceId: $0.serviceId, patientUserId: $0.patientUserId, id: $0.id)) }
        existing.append(contentsOf: entries)
        existing.sort {
            if $0.serviceId != $1.serviceId { return $0.serviceId.uuidString < $1.serviceId.uuidString }
            if $0.patientUserId != $1.patientUserId { return $0.patientUserId.uuidString < $1.patientUserId.uuidString }
            if $0.snippet.occurredAt != $1.snippet.occurredAt { return $0.snippet.occurredAt > $1.snippet.occurredAt }
            return $0.id.uuidString < $1.id.uuidString
        }

        try FileManager.default.createDirectory(at: fileURL.deletingLastPathComponent(), withIntermediateDirectories: true)
        try encoder.encode(existing).write(to: fileURL)
    }

    public func entries(
        serviceId: UUID,
        patientUserId: UUID,
        lawfulContext: [String: String]
    ) throws -> [RecordIndexEntry] {
        try requireLawfulContext(lawfulContext, patientUserId: patientUserId)
        let fileURL = indexFileURL(serviceId: serviceId)
        guard FileManager.default.fileExists(atPath: fileURL.path) else { return [] }
        let data = try Data(contentsOf: fileURL)
        let all = try decoder.decode([RecordIndexEntry].self, from: data)
        return all
            .filter { $0.serviceId == serviceId && $0.patientUserId == patientUserId }
            .sorted {
                if $0.snippet.occurredAt != $1.snippet.occurredAt {
                    return $0.snippet.occurredAt > $1.snippet.occurredAt
                }
                return $0.id.uuidString < $1.id.uuidString
            }
    }

    private func indexFileURL(serviceId: UUID) -> URL {
        DirectoryLayout.serviceRoot(root: root, serviceId: serviceId)
            .appending(path: "records")
            .appending(path: "patient-record-index.json")
    }

    private func requireLawfulContext(_ lawfulContext: [String: String], patientUserId: UUID) throws {
        for key in ["actorRole", "scope", "finalidade", "habilitationId", "patientUserId"] {
            guard lawfulContext[key] != nil else { throw FirstSliceError.missingLawfulContext(key) }
        }
        guard lawfulContext["patientUserId"] == patientUserId.uuidString else {
            throw FirstSliceError.retrievalScopeViolation
        }
    }

    private struct CompositeKey: Hashable {
        let serviceId: UUID
        let patientUserId: UUID
        let id: UUID
    }
}

public actor BoundedContextRetrievalService {
    private let index: FileBackedRecordIndex

    public init(index: FileBackedRecordIndex) {
        self.index = index
    }

    public func retrieve(query: RetrievalQuery, lawfulContext: [String: String]) async throws -> BoundedRetrievalResult {
        let entries = try await index.entries(serviceId: query.serviceId, patientUserId: query.patientUserId, lawfulContext: lawfulContext)
        let now = Date()
        let normalizedTerms = Array(Set(query.terms.flatMap(tokenize))).sorted()
        let recencyFloor: Date? = query.recencyDays.map { Calendar.current.date(byAdding: .day, value: -$0, to: now) ?? .distantPast }

        guard !normalizedTerms.isEmpty else {
            return BoundedRetrievalResult(
                query: query,
                matches: [],
                source: "file-backed-record-index:no-query-terms",
                quality: .degraded,
                notice: "Current bounded retrieval query had no searchable terms after local normalization.",
                isFallbackEmpty: true
            )
        }

        let scored: [RetrievalMatch] = entries.compactMap { entry in
            scoreMatch(
                entry,
                query: query,
                normalizedTerms: normalizedTerms,
                recencyFloor: recencyFloor,
                now: now
            )
        }
        .sorted {
            if $0.score != $1.score { return $0.score > $1.score }
            if $0.occurredAt != $1.occurredAt { return $0.occurredAt > $1.occurredAt }
            return $0.id.uuidString < $1.id.uuidString
        }

        let matches = Array(scored.prefix(max(query.maxMatches, 0)))
        return BoundedRetrievalResult(
            query: query,
            matches: matches,
            source: "file-backed-record-index",
            quality: retrievalQuality(for: matches),
            notice: retrievalNotice(for: matches),
            isFallbackEmpty: matches.isEmpty
        )
    }

    private func scoreMatch(
        _ entry: RecordIndexEntry,
        query: RetrievalQuery,
        normalizedTerms: [String],
        recencyFloor: Date?,
        now: Date
    ) -> RetrievalMatch? {
        guard query.allowedKinds.contains(entry.snippetKind) else { return nil }
        if let recencyFloor, entry.snippet.occurredAt < recencyFloor { return nil }

        let summaryTokens = Set(tokenize(entry.snippet.summary))
        let tagTokens = Set(entry.snippet.tags.flatMap(tokenize))
        let matchedTerms = normalizedTerms.filter { summaryTokens.contains($0) }.sorted()
        let matchedTags = normalizedTerms.filter { tagTokens.contains($0) }.sorted()

        let lexicalScore = matchedTerms.count * 4
        let tagScore = matchedTags.count * 3
        let recencyScore = recencyBoost(for: entry.snippet.occurredAt, now: now)
        let categoryBoost = categoryBoost(for: entry.snippet.category, intent: query.intent)
        let intentBoost = intentBoost(for: entry, intent: query.intent)
        let relevanceHintBoost = relevanceHintBoost(for: entry.snippet.relevanceHint)
        let totalScore = lexicalScore
            + tagScore
            + recencyScore
            + categoryBoost
            + intentBoost
            + relevanceHintBoost

        let hasDirectMatch = !matchedTerms.isEmpty || !matchedTags.isEmpty
        let hasIntentSupport = query.intent != .generalContext && (categoryBoost + intentBoost + relevanceHintBoost + recencyScore) >= 5
        guard hasDirectMatch || hasIntentSupport else { return nil }

        let scoreBreakdown = RetrievalScoreBreakdown(
            lexicalScore: lexicalScore,
            tagScore: tagScore,
            recencyScore: recencyScore,
            categoryBoost: categoryBoost,
            intentBoost: intentBoost,
            relevanceHintBoost: relevanceHintBoost,
            totalScore: totalScore
        )

        return RetrievalMatch(
            id: entry.id,
            snippetKind: entry.snippetKind,
            category: entry.snippet.category,
            sourceKind: entry.sourceKind,
            relevanceHint: entry.snippet.relevanceHint,
            flags: entry.snippet.flags,
            summary: entry.snippet.summary,
            sourceRef: entry.sourceRef,
            score: totalScore,
            matchedTerms: matchedTerms,
            matchedTags: matchedTags,
            occurredAt: entry.snippet.occurredAt,
            scoreBreakdown: scoreBreakdown
        )
    }

    private func recencyBoost(for occurredAt: Date, now: Date) -> Int {
        let ageDays = Calendar.current.dateComponents([.day], from: occurredAt, to: now).day ?? .max
        switch ageDays {
        case ...7:
            return 3
        case ...30:
            return 2
        case ...120:
            return 1
        default:
            return 0
        }
    }

    private func categoryBoost(for category: RecordClinicalCategory, intent: RetrievalIntent) -> Int {
        switch (intent, category) {
        case (.sleepReview, .sleep):
            return 4
        case (.symptomReview, .symptom):
            return 4
        case (.medicationReview, .medication):
            return 4
        case (.allergySafety, .allergy):
            return 5
        case (.generalContext, .encounterContext):
            return 2
        case (.generalContext, .symptom), (.generalContext, .sleep):
            return 1
        default:
            return 0
        }
    }

    private func intentBoost(for entry: RecordIndexEntry, intent: RetrievalIntent) -> Int {
        switch intent {
        case .generalContext:
            var boost = entry.snippet.flags.contains(.recent) ? 1 : 0
            if entry.snippetKind == .encounterSummary {
                boost += 1
            }
            return boost
        case .symptomReview:
            var boost = entry.snippet.flags.contains(.symptomRelated) ? 2 : 0
            if entry.snippetKind == .observation || entry.snippetKind == .encounterSummary {
                boost += 1
            }
            return boost
        case .sleepReview:
            var boost = entry.snippet.flags.contains(.sleepRelated) ? 3 : 0
            if entry.snippetKind == .observation {
                boost += 1
            }
            return boost
        case .medicationReview:
            var boost = entry.snippet.flags.contains(.medicationRelated) ? 2 : 0
            if entry.snippetKind == .medication {
                boost += 2
            }
            return boost
        case .allergySafety:
            var boost = entry.snippet.flags.contains(.allergyRelated) ? 2 : 0
            if entry.snippetKind == .allergy {
                boost += 3
            }
            return boost
        }
    }

    private func relevanceHintBoost(for hint: RetrievalRelevanceHint) -> Int {
        switch hint {
        case .background:
            return 0
        case .recentPriority:
            return 2
        case .safetyCritical:
            return 3
        }
    }

    private func retrievalQuality(for matches: [RetrievalMatch]) -> RetrievalResultQuality {
        guard let topMatch = matches.first else { return .empty }
        if matches.count == 1 || topMatch.score < 8 || topMatch.scoreBreakdown.lexicalScore == 0 {
            return .limited
        }
        return .strong
    }

    private func retrievalNotice(for matches: [RetrievalMatch]) -> String? {
        guard let topMatch = matches.first else {
            return "No bounded records matched the current local query."
        }
        if matches.count == 1 || topMatch.scoreBreakdown.lexicalScore == 0 {
            return "Bounded context is available, but support is clinically narrow for the current query."
        }
        return nil
    }

    private func tokenize(_ text: String) -> [String] {
        let separators = CharacterSet.alphanumerics.inverted
        return text
            .folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
            .lowercased()
            .components(separatedBy: separators)
            .filter { $0.count >= 3 }
    }
}

public struct ClinicalContextAssembler: Sendable {
    public init() {}

    public func assemble(
        finalidade: String,
        transcription: TranscriptionOutput,
        boundedResult: BoundedRetrievalResult
    ) -> RetrievalContextPackage {
        let status = contextStatus(for: boundedResult)
        let supportingMatches = boundedResult.matches
        let highlights = Array(supportingMatches.prefix(3)).map { highlight(for: $0, intent: boundedResult.query.intent) }
        let provenanceHints = [
            RetrievalProvenanceHint(label: "retrieval-source", value: boundedResult.source),
            RetrievalProvenanceHint(label: "finalidade", value: finalidade),
            RetrievalProvenanceHint(label: "intent", value: boundedResult.query.intent.rawValue)
        ]

        return RetrievalContextPackage(
            finalidade: finalidade,
            status: status,
            summary: summary(
                status: status,
                matches: supportingMatches,
                intent: boundedResult.query.intent
            ),
            highlights: highlights,
            supportingMatches: supportingMatches,
            provenanceHints: provenanceHints,
            notice: contextNotice(
                status: status,
                transcription: transcription,
                boundedResult: boundedResult
            ),
            boundedResult: boundedResult
        )
    }

    private func contextStatus(for boundedResult: BoundedRetrievalResult) -> RetrievalContextStatus {
        switch boundedResult.quality {
        case .strong:
            return .ready
        case .limited:
            return .partial
        case .empty:
            return .empty
        case .degraded:
            return .degraded
        }
    }

    private func summary(
        status: RetrievalContextStatus,
        matches: [RetrievalMatch],
        intent: RetrievalIntent
    ) -> String {
        switch status {
        case .degraded:
            return "Contexto bounded degradado: a captura atual nao gerou termos suficientes para montar contexto clinico-operacional confiavel."
        case .empty:
            return "Nenhum contexto clinico-operacional bounded foi localizado para a finalidade atual."
        case .partial:
            return "Contexto local parcial: \(matches.count) registro(s) bounded com foco em \(focusSummary(from: matches, intent: intent))."
        case .ready:
            let recentSuffix = matches.contains { $0.flags.contains(.recent) }
                ? " Ha suporte recente entre os itens priorizados."
                : ""
            return "Contexto local destacou \(matches.count) registro(s) de suporte com foco em \(focusSummary(from: matches, intent: intent)).\(recentSuffix)"
        }
    }

    private func contextNotice(
        status: RetrievalContextStatus,
        transcription: TranscriptionOutput,
        boundedResult: BoundedRetrievalResult
    ) -> String? {
        if status == .degraded, transcription.status != .ready {
            return "Retrieval permaneceu bounded e nao expandiu escopo apesar da degradacao de transcription."
        }
        return boundedResult.notice
    }

    private func highlight(for match: RetrievalMatch, intent: RetrievalIntent) -> RetrievalContextHighlight {
        RetrievalContextHighlight(
            id: match.id,
            headline: headline(for: match),
            summary: match.summary,
            sourceRef: match.sourceRef,
            category: match.category,
            whyRelevant: whyRelevant(for: match, intent: intent)
        )
    }

    private func headline(for match: RetrievalMatch) -> String {
        let category = categoryLabel(match.category)
        if match.flags.contains(.recent) {
            return "\(category) recente"
        }
        return category
    }

    private func whyRelevant(for match: RetrievalMatch, intent: RetrievalIntent) -> String {
        var reasons: [String] = []
        if !match.matchedTerms.isEmpty {
            reasons.append("termos: \(match.matchedTerms.joined(separator: ", "))")
        }
        if !match.matchedTags.isEmpty {
            reasons.append("tags: \(match.matchedTags.joined(separator: ", "))")
        }
        if match.flags.contains(.recent) {
            reasons.append("recencia local")
        }
        if match.categoryBoostRelevant(to: intent) {
            reasons.append("alinhado ao intent \(intent.rawValue)")
        }
        return reasons.isEmpty ? "match bounded pelo indice local" : reasons.joined(separator: " | ")
    }

    private func focusSummary(from matches: [RetrievalMatch], intent: RetrievalIntent) -> String {
        let categories = Array(Set(matches.map(\.category))).sorted { $0.rawValue < $1.rawValue }
        if categories.isEmpty {
            return focusLabel(for: intent)
        }
        let labels = categories.prefix(2).map(categoryLabel)
        return labels.joined(separator: " e ")
    }

    private func focusLabel(for intent: RetrievalIntent) -> String {
        switch intent {
        case .generalContext:
            return "historico clinico-operacional"
        case .symptomReview:
            return "sintomas e observacoes"
        case .sleepReview:
            return "sono e sintomas associados"
        case .medicationReview:
            return "medicacao em uso"
        case .allergySafety:
            return "alergias e seguranca"
        }
    }

    private func categoryLabel(_ category: RecordClinicalCategory) -> String {
        switch category {
        case .encounterContext:
            return "Historico de encontro"
        case .symptom:
            return "Sintoma"
        case .sleep:
            return "Sono"
        case .medication:
            return "Medicacao"
        case .allergy:
            return "Alergia"
        case .operational:
            return "Operacional"
        }
    }
}

private extension RetrievalMatch {
    func categoryBoostRelevant(to intent: RetrievalIntent) -> Bool {
        switch (intent, category) {
        case (.generalContext, _):
            return true
        case (.symptomReview, .symptom),
             (.sleepReview, .sleep),
             (.medicationReview, .medication),
             (.allergySafety, .allergy):
            return true
        default:
            return false
        }
    }
}
