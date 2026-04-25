import Foundation

public enum GovernedRetrievalMode: String, Codable, Sendable {
    case lexical
    case semantic
    case hybrid
    case unavailable
}

public enum RetrievalScoreKind: String, Codable, Sendable {
    case lexical
    case semantic
    case hybrid
    case deterministic
    case stub
}

public enum RetrievalFailure: Error, LocalizedError, Sendable, Equatable {
    case missingLawfulContext
    case missingFinalidade
    case missingPatientUserId
    case dataLayerDenied(StorageLayer)
    case semanticProviderUnavailable

    public var errorDescription: String? {
        switch self {
        case .missingLawfulContext:
            return "Sensitive retrieval requires lawfulContext."
        case .missingFinalidade:
            return "Retrieval finalidade is required."
        case .missingPatientUserId:
            return "Patient-scoped retrieval requires patientUserId."
        case .dataLayerDenied(let layer):
            return "Retrieval cannot access denied data layer \(layer.rawValue)."
        case .semanticProviderUnavailable:
            return "Semantic retrieval requested but no compatible embedding provider is available."
        }
    }
}

public struct RetrievalProviderRequirement: Codable, Sendable, Equatable {
    public let requiresEmbeddingProvider: Bool
    public let requiresRealProvider: Bool
    public let allowsLexicalFallback: Bool

    public init(
        requiresEmbeddingProvider: Bool,
        requiresRealProvider: Bool = false,
        allowsLexicalFallback: Bool = true
    ) {
        self.requiresEmbeddingProvider = requiresEmbeddingProvider
        self.requiresRealProvider = requiresRealProvider
        self.allowsLexicalFallback = allowsLexicalFallback
    }
}

public struct GovernedRetrievalQuery: Codable, Sendable {
    public let queryId: UUID
    public let actorId: String
    public let actorRole: String
    public let serviceId: UUID?
    public let patientUserId: UUID?
    public let sessionId: UUID?
    public let finalidade: String
    public let lawfulContext: [String: String]
    public let allowedDataLayers: Set<StorageLayer>
    public let deniedDataLayers: Set<StorageLayer>
    public let mode: GovernedRetrievalMode
    public let providerRequirement: RetrievalProviderRequirement
    public let maxResults: Int
    public let provenanceRequired: Bool
    public let lexicalQuery: RetrievalQuery

    public init(
        queryId: UUID = UUID(),
        actorId: String,
        actorRole: String,
        serviceId: UUID?,
        patientUserId: UUID?,
        sessionId: UUID?,
        finalidade: String,
        lawfulContext: [String: String],
        allowedDataLayers: Set<StorageLayer>,
        deniedDataLayers: Set<StorageLayer> = [],
        mode: GovernedRetrievalMode,
        providerRequirement: RetrievalProviderRequirement,
        maxResults: Int,
        provenanceRequired: Bool,
        lexicalQuery: RetrievalQuery
    ) throws {
        guard !lawfulContext.isEmpty else {
            throw RetrievalFailure.missingLawfulContext
        }
        guard !finalidade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw RetrievalFailure.missingFinalidade
        }
        if (allowedDataLayers.contains(.operationalContent) || allowedDataLayers.contains(.derivedArtifacts)),
           patientUserId == nil {
            throw RetrievalFailure.missingPatientUserId
        }
        if let denied = deniedDataLayers.first(where: { allowedDataLayers.contains($0) }) {
            throw RetrievalFailure.dataLayerDenied(denied)
        }

        self.queryId = queryId
        self.actorId = actorId
        self.actorRole = actorRole
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.sessionId = sessionId
        self.finalidade = finalidade
        self.lawfulContext = lawfulContext
        self.allowedDataLayers = allowedDataLayers
        self.deniedDataLayers = deniedDataLayers
        self.mode = mode
        self.providerRequirement = providerRequirement
        self.maxResults = maxResults
        self.provenanceRequired = provenanceRequired
        self.lexicalQuery = lexicalQuery
    }
}

public enum EmbeddingStatus: String, Codable, Sendable {
    case pending
    case ready
    case degraded
    case unavailable
    case revoked
}

public struct EmbeddingVectorRef: Codable, Sendable, Equatable {
    public let ref: String
    public let placeholder: Bool

    public init(ref: String, placeholder: Bool) {
        self.ref = ref
        self.placeholder = placeholder
    }

    public var hasMaterializedVector: Bool {
        !placeholder
    }
}

public struct EmbeddingRecord: Codable, Sendable, Equatable {
    public let id: UUID
    public let providerId: String
    public let modelId: String?
    public let modelVersion: String?
    public let status: EmbeddingStatus
    public let vectorRef: EmbeddingVectorRef?
    public let generatedAt: Date?
    public let provenanceId: UUID?

    public init(
        id: UUID = UUID(),
        providerId: String,
        modelId: String? = nil,
        modelVersion: String? = nil,
        status: EmbeddingStatus,
        vectorRef: EmbeddingVectorRef? = nil,
        generatedAt: Date? = nil,
        provenanceId: UUID? = nil
    ) {
        self.id = id
        self.providerId = providerId
        self.modelId = modelId
        self.modelVersion = modelVersion
        self.status = status
        self.vectorRef = vectorRef
        self.generatedAt = generatedAt
        self.provenanceId = provenanceId
    }

    public var isReady: Bool {
        status == .ready && (vectorRef?.hasMaterializedVector == true)
    }
}

public struct SemanticIndexEntry: Codable, Sendable, Equatable {
    public let id: UUID
    public let sourceObjectRef: String
    public let sourceLayer: StorageLayer
    public let sourceHash: String
    public let lawfulFinalidade: String
    public let lawfulContextScope: String
    public let dataGovernanceClass: String
    public let embedding: EmbeddingRecord
    public let indexProvenanceId: UUID?

    public init(
        id: UUID = UUID(),
        sourceObjectRef: String,
        sourceLayer: StorageLayer,
        sourceHash: String,
        lawfulFinalidade: String,
        lawfulContextScope: String,
        dataGovernanceClass: String,
        embedding: EmbeddingRecord,
        indexProvenanceId: UUID? = nil
    ) {
        self.id = id
        self.sourceObjectRef = sourceObjectRef
        self.sourceLayer = sourceLayer
        self.sourceHash = sourceHash
        self.lawfulFinalidade = lawfulFinalidade
        self.lawfulContextScope = lawfulContextScope
        self.dataGovernanceClass = dataGovernanceClass
        self.embedding = embedding
        self.indexProvenanceId = indexProvenanceId
    }
}

public struct IndexBuildJob: Codable, Sendable, Equatable {
    public let id: UUID
    public let requestedAt: Date
    public let requestedByActorId: String
    public let lawfulContext: [String: String]
    public let finalidade: String

    public init(
        id: UUID = UUID(),
        requestedAt: Date = .now,
        requestedByActorId: String,
        lawfulContext: [String: String],
        finalidade: String
    ) {
        self.id = id
        self.requestedAt = requestedAt
        self.requestedByActorId = requestedByActorId
        self.lawfulContext = lawfulContext
        self.finalidade = finalidade
    }
}

public enum MemoryScopeKind: String, Codable, Sendable {
    case userAgent = "user-agent"
    case professionalAgent = "professional-agent"
    case aaciSession = "aaci-session"
    case serviceOperational = "service-operational"
    case system
    case derivedMemoryArtifact = "derived-memory-artifact"
}

public enum MemoryGovernanceError: Error, LocalizedError, Sendable, Equatable {
    case sessionScopeMismatch
    case missingGovernedReadContext
    case missingProvenanceForDerivedMemory
    case directIdentifierLayerDenied

    public var errorDescription: String? {
        switch self {
        case .sessionScopeMismatch:
            return "Session memory cannot escape into another memory scope."
        case .missingGovernedReadContext:
            return "Cross-scope memory read requires governed context."
        case .missingProvenanceForDerivedMemory:
            return "Derived memory artifacts require provenance linkage."
        case .directIdentifierLayerDenied:
            return "Direct identifiers are not allowed in this memory layer by default."
        }
    }
}

public struct MemoryScopeContract: Codable, Sendable, Equatable {
    public let memoryId: UUID
    public let scope: MemoryScopeKind
    public let ownerUserId: UUID?
    public let ownerServiceId: UUID?
    public let sessionId: UUID?
    public let dataLayer: StorageLayer
    public let containsDirectIdentifiers: Bool
    public let lawfulContext: [String: String]
    public let provenanceId: UUID?

    public init(
        memoryId: UUID = UUID(),
        scope: MemoryScopeKind,
        ownerUserId: UUID? = nil,
        ownerServiceId: UUID? = nil,
        sessionId: UUID? = nil,
        dataLayer: StorageLayer,
        containsDirectIdentifiers: Bool,
        lawfulContext: [String: String],
        provenanceId: UUID? = nil
    ) {
        self.memoryId = memoryId
        self.scope = scope
        self.ownerUserId = ownerUserId
        self.ownerServiceId = ownerServiceId
        self.sessionId = sessionId
        self.dataLayer = dataLayer
        self.containsDirectIdentifiers = containsDirectIdentifiers
        self.lawfulContext = lawfulContext
        self.provenanceId = provenanceId
    }

    public func validateWrite() throws {
        if containsDirectIdentifiers && dataLayer != .directIdentifiers {
            throw MemoryGovernanceError.directIdentifierLayerDenied
        }
        if scope == .derivedMemoryArtifact && provenanceId == nil {
            throw MemoryGovernanceError.missingProvenanceForDerivedMemory
        }
    }

    public func validateRead(by readerScope: MemoryScopeKind, governedContext: [String: String]?) throws {
        if scope == .aaciSession, readerScope == .serviceOperational {
            throw MemoryGovernanceError.sessionScopeMismatch
        }
        if scope == .userAgent, readerScope == .professionalAgent,
           (governedContext ?? [:]).isEmpty {
            throw MemoryGovernanceError.missingGovernedReadContext
        }
    }
}

public struct GovernedRetrievalResultItem: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let sourceObjectRef: String
    public let sourceLayer: StorageLayer
    public let score: Int
    public let scoreKind: RetrievalScoreKind
    public let snippet: String?
    public let provenanceRef: UUID?
    public let lawfulScopeSummary: String
    public let redactionApplied: Bool

    public init(
        id: UUID,
        sourceObjectRef: String,
        sourceLayer: StorageLayer,
        score: Int,
        scoreKind: RetrievalScoreKind,
        snippet: String?,
        provenanceRef: UUID?,
        lawfulScopeSummary: String,
        redactionApplied: Bool
    ) {
        self.id = id
        self.sourceObjectRef = sourceObjectRef
        self.sourceLayer = sourceLayer
        self.score = score
        self.scoreKind = scoreKind
        self.snippet = snippet
        self.provenanceRef = provenanceRef
        self.lawfulScopeSummary = lawfulScopeSummary
        self.redactionApplied = redactionApplied
    }

    public func appFacing() -> GovernedRetrievalResultItem {
        let source = snippet ?? ""
        let redacted = source.replacingOccurrences(
            of: #"\b\d{3}\.\d{3}\.\d{3}-\d{2}\b|\b\d{11}\b"#,
            with: "[redacted]",
            options: .regularExpression
        )
        return .init(
            id: id,
            sourceObjectRef: sourceObjectRef,
            sourceLayer: sourceLayer,
            score: score,
            scoreKind: scoreKind,
            snippet: redacted,
            provenanceRef: provenanceRef,
            lawfulScopeSummary: lawfulScopeSummary,
            redactionApplied: redacted != source || redactionApplied
        )
    }
}

public struct GovernedRetrievalResult: Sendable {
    public let queryId: UUID
    public let mode: GovernedRetrievalMode
    public let items: [GovernedRetrievalResultItem]
    public let boundedResult: BoundedRetrievalResult?
    public let failure: RetrievalFailure?

    public init(
        queryId: UUID,
        mode: GovernedRetrievalMode,
        items: [GovernedRetrievalResultItem],
        boundedResult: BoundedRetrievalResult?,
        failure: RetrievalFailure?
    ) {
        self.queryId = queryId
        self.mode = mode
        self.items = items
        self.boundedResult = boundedResult
        self.failure = failure
    }
}

public struct EmbeddingProviderAvailability: Sendable, Equatable {
    public let compatible: Bool
    public let isStub: Bool

    public init(compatible: Bool, isStub: Bool) {
        self.compatible = compatible
        self.isStub = isStub
    }

    public static let unavailable = EmbeddingProviderAvailability(compatible: false, isStub: false)
}

public extension BoundedContextRetrievalService {
    func retrieve(
        governedQuery: GovernedRetrievalQuery,
        embeddingAvailability: EmbeddingProviderAvailability = .unavailable
    ) async throws -> GovernedRetrievalResult {
        switch governedQuery.mode {
        case .lexical:
            return try await lexicalResult(governedQuery: governedQuery)
        case .semantic, .hybrid:
            guard embeddingAvailability.compatible, !governedQuery.providerRequirement.requiresRealProvider || !embeddingAvailability.isStub else {
                if governedQuery.providerRequirement.allowsLexicalFallback {
                    let lexical = try await lexicalResult(governedQuery: governedQuery)
                    return GovernedRetrievalResult(
                        queryId: governedQuery.queryId,
                        mode: .lexical,
                        items: lexical.items,
                        boundedResult: lexical.boundedResult,
                        failure: .semanticProviderUnavailable
                    )
                }
                return GovernedRetrievalResult(
                    queryId: governedQuery.queryId,
                    mode: .unavailable,
                    items: [],
                    boundedResult: nil,
                    failure: .semanticProviderUnavailable
                )
            }
            return try await lexicalResult(governedQuery: governedQuery)
        case .unavailable:
            return .init(queryId: governedQuery.queryId, mode: .unavailable, items: [], boundedResult: nil, failure: .semanticProviderUnavailable)
        }
    }

    private func lexicalResult(governedQuery: GovernedRetrievalQuery) async throws -> GovernedRetrievalResult {
        let bounded = try await retrieve(query: governedQuery.lexicalQuery, lawfulContext: governedQuery.lawfulContext)
        let items = bounded.matches.map {
            GovernedRetrievalResultItem(
                id: $0.id,
                sourceObjectRef: $0.sourceRef,
                sourceLayer: .operationalContent,
                score: $0.score,
                scoreKind: .deterministic,
                snippet: $0.summary,
                provenanceRef: nil,
                lawfulScopeSummary: "scope=\(governedQuery.lawfulContext["scope"] ?? "unknown"); finalidade=\(governedQuery.finalidade)",
                redactionApplied: false
            )
            .appFacing()
        }
        return .init(queryId: governedQuery.queryId, mode: .lexical, items: items, boundedResult: bounded, failure: nil)
    }
}
