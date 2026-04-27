import Foundation

public enum StorageLayer: String, Codable, Sendable {
    case directIdentifiers = "direct-identifiers"
    case operationalContent = "operational-content"
    case governanceMetadata = "governance-metadata"
    case derivedArtifacts = "derived-artifacts"
    case reidentificationMapping = "reidentification-mapping"

    public var containsDirectIdentifiers: Bool {
        switch self {
        case .directIdentifiers, .reidentificationMapping:
            return true
        case .operationalContent, .governanceMetadata, .derivedArtifacts:
            return false
        }
    }

    public var requiresGovernedContextOnWrite: Bool {
        switch self {
        case .directIdentifiers, .governanceMetadata, .reidentificationMapping:
            return true
        case .operationalContent, .derivedArtifacts:
            return false
        }
    }
}

public enum StorageOwner: Sendable {
    case usuario(cpfHash: String)
    case servico(serviceId: UUID)
}

public struct StoragePutRequest: Sendable {
    public let owner: StorageOwner
    public let kind: String
    public let layer: StorageLayer
    public let content: Data
    public let metadata: [String: String]
    public let lawfulContext: [String: String]?

    public init(
        owner: StorageOwner,
        kind: String,
        layer: StorageLayer,
        content: Data,
        metadata: [String: String] = [:],
        lawfulContext: [String: String]? = nil
    ) {
        self.owner = owner
        self.kind = kind
        self.layer = layer
        self.content = content
        self.metadata = metadata
        self.lawfulContext = lawfulContext
    }
}

public struct StorageObjectRef: Codable, Sendable {
    public let objectPath: String
    public let contentHash: String
    public let layer: StorageLayer
    public let kind: String

    public init(objectPath: String, contentHash: String, layer: StorageLayer, kind: String) {
        self.objectPath = objectPath
        self.contentHash = contentHash
        self.layer = layer
        self.kind = kind
    }
}

public protocol StorageService: Sendable {
    func put(_ request: StoragePutRequest) async throws -> StorageObjectRef
    func get(_ objectRef: StorageObjectRef, lawfulContext: [String: String]) async throws -> Data
    func list(owner: StorageOwner, filters: [String: String], lawfulContext: [String: String]) async throws -> [StorageObjectRef]
    func audit(objectRef: StorageObjectRef, action: String, actorId: String, metadata: [String: String]) async throws
}

public struct StorageLayerValidationResult: Sendable, Equatable {
    public let layer: StorageLayer
    public let lawfulContext: CoreLawfulContext?
    public let metadataValidated: Bool

    public init(layer: StorageLayer, lawfulContext: CoreLawfulContext?, metadataValidated: Bool) {
        self.layer = layer
        self.lawfulContext = lawfulContext
        self.metadataValidated = metadataValidated
    }
}

public enum StorageLayerFailure: Error, LocalizedError, Sendable, Equatable {
    case missingLawfulContext(StorageLayer)
    case unauthorizedLayerAccess(StorageLayer)
    case contextValidationFailed(String)

    public var errorDescription: String? {
        switch self {
        case .missingLawfulContext(let layer):
            return "Storage layer \(layer.rawValue) requires lawfulContext."
        case .unauthorizedLayerAccess(let layer):
            return "Access to storage layer \(layer.rawValue) is unauthorized."
        case .contextValidationFailed(let msg):
            return "Lawful context validation failed: \(msg)"
        }
    }
}

public struct StorageLayerValidator {
    public static func validate(layer: StorageLayer, lawfulContext: [String: String]?) throws {
        if layer.requiresGovernedContextOnWrite {
            guard let context = lawfulContext, !context.isEmpty else {
                throw StorageLayerFailure.missingLawfulContext(layer)
            }
            do {
                _ = try LawfulContextValidator.validate(context, requirements: .init(requirePatientUserId: true, requireFinalidade: true))
            } catch {
                throw StorageLayerFailure.contextValidationFailed(error.localizedDescription)
            }
        }
    }
}
