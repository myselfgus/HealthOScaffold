import Foundation

public enum StorageLayer: String, Codable, Sendable {
    case directIdentifiers = "direct-identifiers"
    case operationalContent = "operational-content"
    case governanceMetadata = "governance-metadata"
    case derivedArtifacts = "derived-artifacts"
    case reidentificationMapping = "reidentification-mapping"
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

    public init(owner: StorageOwner, kind: String, layer: StorageLayer, content: Data, metadata: [String: String] = [:]) {
        self.owner = owner
        self.kind = kind
        self.layer = layer
        self.content = content
        self.metadata = metadata
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
