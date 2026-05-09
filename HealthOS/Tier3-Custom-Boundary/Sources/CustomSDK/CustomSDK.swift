import Foundation
import HealthOSCore

public struct StageCustom: Codable, Equatable, Sendable {
    public var stageId: String
    public var displayName: String
    public var role: String
    public var consumedSurfaces: [StageConsumedSurface]
    public var capabilities: [StageCapability]
    public var prohibitions: [StageProhibition]
    public var degradationPolicy: StageDegradationPolicy
    public var validationRequirements: [StageValidationRequirement]
    public var maturity: StageCustomMaturity

    public init(
        stageId: String,
        displayName: String,
        role: String,
        consumedSurfaces: [StageConsumedSurface],
        capabilities: [StageCapability],
        prohibitions: [StageProhibition],
        degradationPolicy: StageDegradationPolicy,
        validationRequirements: [StageValidationRequirement],
        maturity: StageCustomMaturity
    ) {
        self.stageId = stageId
        self.displayName = displayName
        self.role = role
        self.consumedSurfaces = consumedSurfaces
        self.capabilities = capabilities
        self.prohibitions = prohibitions
        self.degradationPolicy = degradationPolicy
        self.validationRequirements = validationRequirements
        self.maturity = maturity
    }
}

public struct StageConsumedSurface: Codable, Equatable, Sendable {
    public var identifier: String
    public var boundaryModule: String
    public var required: Bool

    public init(identifier: String, boundaryModule: String = "HealthOSBoundary", required: Bool = true) {
        self.identifier = identifier
        self.boundaryModule = boundaryModule
        self.required = required
    }
}

public struct StageCapability: Codable, Equatable, Sendable {
    public var identifier: String
    public var description: String

    public init(identifier: String, description: String) {
        self.identifier = identifier
        self.description = description
    }
}

public struct StageProhibition: Codable, Equatable, Sendable {
    public var identifier: String
    public var description: String

    public init(identifier: String, description: String) {
        self.identifier = identifier
        self.description = description
    }
}

public struct StageDegradationPolicy: Codable, Equatable, Sendable {
    public var unavailableStateRequired: Bool
    public var mayPersistStubOutput: Bool
    public var description: String

    public init(
        unavailableStateRequired: Bool = true,
        mayPersistStubOutput: Bool = false,
        description: String
    ) {
        self.unavailableStateRequired = unavailableStateRequired
        self.mayPersistStubOutput = mayPersistStubOutput
        self.description = description
    }
}

public struct StageValidationRequirement: Codable, Equatable, Sendable {
    public var command: String
    public var purpose: String

    public init(command: String, purpose: String) {
        self.command = command
        self.purpose = purpose
    }
}

public enum StageCustomMaturity: String, Codable, Sendable {
    case draft
    case needsReview = "needs-review"
    case accepted
}

public enum StageCustomCompliance {
    public static func validate(_ custom: StageCustom) -> [String] {
        var issues: [String] = []
        if custom.stageId.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
            issues.append("stageId is required")
        }
        if custom.consumedSurfaces.isEmpty {
            issues.append("at least one Boundary-consumed surface is required")
        }
        if custom.validationRequirements.isEmpty {
            issues.append("at least one validation requirement is required")
        }
        if custom.degradationPolicy.mayPersistStubOutput {
            issues.append("Stages must not persist stub output as real output")
        }
        return issues
    }
}
