import Foundation

public struct ProvenanceRecord: Codable, Sendable, Identifiable {
    public let id: UUID
    public let actorId: String?
    public let operation: String
    public let providerName: String?
    public let modelName: String?
    public let modelVersion: String?
    public let promptVersion: String?
    public let inputHash: String?
    public let outputHash: String?
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        actorId: String? = nil,
        operation: String,
        providerName: String? = nil,
        modelName: String? = nil,
        modelVersion: String? = nil,
        promptVersion: String? = nil,
        inputHash: String? = nil,
        outputHash: String? = nil,
        timestamp: Date = .now
    ) {
        self.id = id
        self.actorId = actorId
        self.operation = operation
        self.providerName = providerName
        self.modelName = modelName
        self.modelVersion = modelVersion
        self.promptVersion = promptVersion
        self.inputHash = inputHash
        self.outputHash = outputHash
        self.timestamp = timestamp
    }
}
