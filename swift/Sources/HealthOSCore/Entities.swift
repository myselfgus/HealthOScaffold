import Foundation

public struct Usuario: Codable, Sendable, Identifiable {
    public let id: UUID
    public let cpfHash: String
    public let civilToken: String
    public let active: Bool

    public init(id: UUID = UUID(), cpfHash: String, civilToken: String, active: Bool = true) {
        self.id = id
        self.cpfHash = cpfHash
        self.civilToken = civilToken
        self.active = active
    }
}

public struct Servico: Codable, Sendable, Identifiable {
    public let id: UUID
    public let nome: String
    public let tipo: String
    public let cnpjToken: String?

    public init(id: UUID = UUID(), nome: String, tipo: String, cnpjToken: String? = nil) {
        self.id = id
        self.nome = nome
        self.tipo = tipo
        self.cnpjToken = cnpjToken
    }
}

public struct SessaoTrabalho: Codable, Sendable, Identifiable {
    public let id: UUID
    public let kind: SessionKind
    public let serviceId: UUID
    public let professionalUserId: UUID
    public let patientUserId: UUID?
    public let habilitationId: UUID?
    public let tempoUsuarioInicio: Date

    public init(
        id: UUID = UUID(),
        kind: SessionKind,
        serviceId: UUID,
        professionalUserId: UUID,
        patientUserId: UUID? = nil,
        habilitationId: UUID? = nil,
        tempoUsuarioInicio: Date = .now
    ) {
        self.id = id
        self.kind = kind
        self.serviceId = serviceId
        self.professionalUserId = professionalUserId
        self.patientUserId = patientUserId
        self.habilitationId = habilitationId
        self.tempoUsuarioInicio = tempoUsuarioInicio
    }
}

public struct ArtifactDraft: Codable, Sendable, Identifiable {
    public let id: UUID
    public let sessionId: UUID
    public let kind: String
    public let status: DraftStatus
    public let payload: [String: String]
    public let sourceEventIds: [UUID]

    public init(
        id: UUID = UUID(),
        sessionId: UUID,
        kind: String,
        status: DraftStatus = .draft,
        payload: [String: String],
        sourceEventIds: [UUID] = []
    ) {
        self.id = id
        self.sessionId = sessionId
        self.kind = kind
        self.status = status
        self.payload = payload
        self.sourceEventIds = sourceEventIds
    }
}
