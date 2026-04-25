import Foundation

public struct DeidentificationMap: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let userId: UUID
    public let directIdentifierKind: String
    public let token: String
    public let encryptedValueRef: String
    public let createdAt: Date

    public init(
        id: UUID = UUID(),
        userId: UUID,
        directIdentifierKind: String,
        token: String,
        encryptedValueRef: String,
        createdAt: Date = .now
    ) {
        self.id = id
        self.userId = userId
        self.directIdentifierKind = directIdentifierKind
        self.token = token
        self.encryptedValueRef = encryptedValueRef
        self.createdAt = createdAt
    }
}

public struct ReidentificationRequest: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let mapId: UUID
    public let requesterActorId: String
    public let finalidade: String
    public let rationale: String
    public let lawfulContext: [String: String]
    public let requestedAt: Date

    public init(
        id: UUID = UUID(),
        mapId: UUID,
        requesterActorId: String,
        finalidade: String,
        rationale: String,
        lawfulContext: [String: String],
        requestedAt: Date = .now
    ) {
        self.id = id
        self.mapId = mapId
        self.requesterActorId = requesterActorId
        self.finalidade = finalidade
        self.rationale = rationale
        self.lawfulContext = lawfulContext
        self.requestedAt = requestedAt
    }
}

public struct ReidentificationResolution: Codable, Sendable, Identifiable, Equatable {
    public let id: UUID
    public let requestId: UUID
    public let resolverActorId: String
    public let approved: Bool
    public let rationale: String
    public let resolvedAt: Date

    public init(
        id: UUID = UUID(),
        requestId: UUID,
        resolverActorId: String,
        approved: Bool,
        rationale: String,
        resolvedAt: Date = .now
    ) {
        self.id = id
        self.requestId = requestId
        self.resolverActorId = resolverActorId
        self.approved = approved
        self.rationale = rationale
        self.resolvedAt = resolvedAt
    }
}

public struct ReidentificationAuditEntry: Codable, Sendable, Identifiable, Equatable {
    public enum Action: String, Codable, Sendable {
        case request
        case requestDenied
        case resolution
        case resolutionDenied
    }

    public let id: UUID
    public let requestId: UUID?
    public let action: Action
    public let actorId: String
    public let detail: String
    public let lawfulContext: [String: String]
    public let timestamp: Date

    public init(
        id: UUID = UUID(),
        requestId: UUID?,
        action: Action,
        actorId: String,
        detail: String,
        lawfulContext: [String: String],
        timestamp: Date = .now
    ) {
        self.id = id
        self.requestId = requestId
        self.action = action
        self.actorId = actorId
        self.detail = detail
        self.lawfulContext = lawfulContext
        self.timestamp = timestamp
    }
}

public actor ReidentificationGovernanceService {
    private var requests: [UUID: ReidentificationRequest] = [:]
    private var resolutions: [UUID: ReidentificationResolution] = [:]
    private let provenance: FileBackedProvenanceLedger?

    public init(provenance: FileBackedProvenanceLedger? = nil) {
        self.provenance = provenance
    }

    public func submitRequest(_ request: ReidentificationRequest) async throws -> ReidentificationAuditEntry {
        guard !request.rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoreLawError.invalidLawfulContext("Reidentification rationale is required")
        }
        guard !request.finalidade.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoreLawError.missingFinality
        }
        let context = try LawfulContextValidator.validate(
            request.lawfulContext,
            requirements: .init(
                requireServiceId: true,
                requirePatientUserId: true,
                requireHabilitationId: true,
                requireFinalidade: true,
                requireSessionId: true
            )
        )
        guard context.scope == "reidentification-governance" else {
            throw CoreLawError.missingReidentificationScope
        }

        requests[request.id] = request
        let audit = ReidentificationAuditEntry(
            requestId: request.id,
            action: .request,
            actorId: request.requesterActorId,
            detail: request.rationale,
            lawfulContext: request.lawfulContext
        )
        try await appendProvenance(
            actorId: request.requesterActorId,
            operation: "reidentification.request",
            detail: request.rationale
        )
        return audit
    }

    public func resolveRequest(_ resolution: ReidentificationResolution, lawfulContext: [String: String]) async throws -> ReidentificationAuditEntry {
        guard requests[resolution.requestId] != nil else {
            throw CoreLawError.invalidLawfulContext("Reidentification resolution requires an existing request")
        }
        let context = try LawfulContextValidator.validate(
            lawfulContext,
            requirements: .init(requireFinalidade: true, requireSessionId: true)
        )
        guard context.scope == "reidentification-governance" else {
            throw CoreLawError.missingReidentificationScope
        }
        guard !resolution.rationale.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty else {
            throw CoreLawError.invalidLawfulContext("Reidentification resolution rationale is required")
        }

        resolutions[resolution.requestId] = resolution
        let action: ReidentificationAuditEntry.Action = resolution.approved ? .resolution : .resolutionDenied
        let audit = ReidentificationAuditEntry(
            requestId: resolution.requestId,
            action: action,
            actorId: resolution.resolverActorId,
            detail: resolution.rationale,
            lawfulContext: lawfulContext
        )
        try await appendProvenance(
            actorId: resolution.resolverActorId,
            operation: "reidentification.resolve",
            detail: resolution.rationale
        )
        return audit
    }

    public func resolution(for requestId: UUID) -> ReidentificationResolution? {
        resolutions[requestId]
    }

    private func appendProvenance(actorId: String, operation: String, detail: String) async throws {
        guard let provenance else { return }
        try await provenance.append(
            .init(
                actorId: actorId,
                operation: operation,
                promptVersion: detail
            )
        )
    }
}
