import Foundation

public enum FirstSliceError: Error, LocalizedError, Sendable {
    case inactiveProfessionalUser
    case inactivePatientUser
    case invalidService
    case missingLawfulContext(String)
    case storageIntegrityFailure(String)

    public var errorDescription: String? {
        switch self {
        case .inactiveProfessionalUser:
            return "Professional user is inactive."
        case .inactivePatientUser:
            return "Patient user is inactive."
        case .invalidService:
            return "Service is invalid for this operation."
        case .missingLawfulContext(let key):
            return "Missing lawful context key: \(key)."
        case .storageIntegrityFailure(let path):
            return "Stored object failed integrity verification at path: \(path)."
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
            requestedAction: "effectuate-soap-note",
            requiredRole: "professional",
            requiresSignature: true
        )
    }

    public func resolve(_ request: GateRequest, resolverUserId: UUID, approve: Bool) -> GateResolution {
        GateResolution(
            gateRequestId: request.id,
            resolverUserId: resolverUserId,
            resolution: approve ? .approved : .rejected,
            note: approve ? "Approved by professional gate." : "Rejected by professional gate."
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
