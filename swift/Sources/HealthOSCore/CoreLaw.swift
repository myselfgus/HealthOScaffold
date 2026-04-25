import Foundation

public enum CoreLawError: Error, LocalizedError, Sendable, Equatable {
    case missingActorRole
    case missingScope
    case missingFinality
    case missingHabilitation
    case missingPatientContext
    case missingServiceContext
    case missingProfessionalContext
    case missingSessionContext
    case invalidLawfulContext(String)
    case consentRequired(String)
    case habilitationRequired(String)
    case gateApprovalRequired(String)
    case regulatedFinalizationDenied(String)

    public var errorDescription: String? {
        switch self {
        case .missingActorRole:
            return "Missing lawful context actorRole."
        case .missingScope:
            return "Missing lawful context scope."
        case .missingFinality:
            return "Missing lawful context finalidade."
        case .missingHabilitation:
            return "Missing lawful context habilitationId."
        case .missingPatientContext:
            return "Missing lawful context patientUserId."
        case .missingServiceContext:
            return "Missing lawful context serviceId."
        case .missingProfessionalContext:
            return "Missing lawful context professionalUserId."
        case .missingSessionContext:
            return "Missing lawful context sessionId."
        case .invalidLawfulContext(let detail):
            return "Invalid lawful context: \(detail)."
        case .consentRequired(let detail):
            return "Consent required: \(detail)."
        case .habilitationRequired(let detail):
            return "Habilitation required: \(detail)."
        case .gateApprovalRequired(let detail):
            return "Gate approval required: \(detail)."
        case .regulatedFinalizationDenied(let detail):
            return "Regulated finalization denied: \(detail)."
        }
    }
}

public struct CoreLawfulContext: Sendable, Equatable {
    public let actorRole: String
    public let scope: String
    public let serviceId: UUID?
    public let patientUserId: UUID?
    public let professionalUserId: UUID?
    public let habilitationId: UUID?
    public let finalidade: String?
    public let sessionId: UUID?
    public let origin: String?
    public let operation: String?
    public let raw: [String: String]

    public init(
        actorRole: String,
        scope: String,
        serviceId: UUID? = nil,
        patientUserId: UUID? = nil,
        professionalUserId: UUID? = nil,
        habilitationId: UUID? = nil,
        finalidade: String? = nil,
        sessionId: UUID? = nil,
        origin: String? = nil,
        operation: String? = nil,
        raw: [String: String]
    ) {
        self.actorRole = actorRole
        self.scope = scope
        self.serviceId = serviceId
        self.patientUserId = patientUserId
        self.professionalUserId = professionalUserId
        self.habilitationId = habilitationId
        self.finalidade = finalidade
        self.sessionId = sessionId
        self.origin = origin
        self.operation = operation
        self.raw = raw
    }
}

public struct LawfulContextRequirement: Sendable, Equatable {
    public let requireServiceId: Bool
    public let requirePatientUserId: Bool
    public let requireProfessionalUserId: Bool
    public let requireHabilitationId: Bool
    public let requireFinalidade: Bool
    public let requireSessionId: Bool

    public init(
        requireServiceId: Bool = false,
        requirePatientUserId: Bool = false,
        requireProfessionalUserId: Bool = false,
        requireHabilitationId: Bool = false,
        requireFinalidade: Bool = false,
        requireSessionId: Bool = false
    ) {
        self.requireServiceId = requireServiceId
        self.requirePatientUserId = requirePatientUserId
        self.requireProfessionalUserId = requireProfessionalUserId
        self.requireHabilitationId = requireHabilitationId
        self.requireFinalidade = requireFinalidade
        self.requireSessionId = requireSessionId
    }
}

public enum LawfulContextValidator {
    public static func validate(
        _ map: [String: String],
        requirements: LawfulContextRequirement = .init()
    ) throws -> CoreLawfulContext {
        let actorRole = try requiredNonEmpty("actorRole", in: map, missing: .missingActorRole)
        let scope = try requiredNonEmpty("scope", in: map, missing: .missingScope)
        let finalidade = try optionalNonEmpty("finalidade", in: map, missing: .missingFinality, required: requirements.requireFinalidade)
        let serviceId = try optionalUUID("serviceId", in: map, required: requirements.requireServiceId, missing: .missingServiceContext)
        let patientUserId = try optionalUUID("patientUserId", in: map, required: requirements.requirePatientUserId, missing: .missingPatientContext)
        let professionalUserId = try optionalUUID("professionalUserId", in: map, required: requirements.requireProfessionalUserId, missing: .missingProfessionalContext)
        let habilitationId = try optionalUUID("habilitationId", in: map, required: requirements.requireHabilitationId, missing: .missingHabilitation)
        let sessionId = try optionalUUID("sessionId", in: map, required: requirements.requireSessionId, missing: .missingSessionContext)

        return CoreLawfulContext(
            actorRole: actorRole,
            scope: scope,
            serviceId: serviceId,
            patientUserId: patientUserId,
            professionalUserId: professionalUserId,
            habilitationId: habilitationId,
            finalidade: finalidade,
            sessionId: sessionId,
            origin: map["origin"],
            operation: map["operation"],
            raw: map
        )
    }

    private static func requiredNonEmpty(
        _ key: String,
        in map: [String: String],
        missing: CoreLawError
    ) throws -> String {
        guard let value = map[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !value.isEmpty else {
            throw missing
        }
        return value
    }

    private static func optionalNonEmpty(
        _ key: String,
        in map: [String: String],
        missing: CoreLawError,
        required: Bool
    ) throws -> String? {
        guard let raw = map[key] else {
            if required { throw missing }
            return nil
        }
        let value = raw.trimmingCharacters(in: .whitespacesAndNewlines)
        if value.isEmpty {
            if required { throw missing }
            return nil
        }
        return value
    }

    private static func optionalUUID(
        _ key: String,
        in map: [String: String],
        required: Bool,
        missing: CoreLawError
    ) throws -> UUID? {
        guard let raw = map[key]?.trimmingCharacters(in: .whitespacesAndNewlines),
              !raw.isEmpty else {
            if required { throw missing }
            return nil
        }
        guard let value = UUID(uuidString: raw) else {
            throw CoreLawError.invalidLawfulContext("Field \(key) is not a valid UUID")
        }
        return value
    }
}
