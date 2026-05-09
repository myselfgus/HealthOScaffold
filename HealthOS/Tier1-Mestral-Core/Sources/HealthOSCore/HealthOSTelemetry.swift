import OSLog

public enum HealthOSTelemetry {
    public static let subsystem = "org.healthos.scaffold"

    public enum Category: String, Sendable {
        case coreValidation = "core.validation"
        case sessionRuntime = "runtime.session"
        case mentalSpaceRuntime = "runtime.msr"
        case providers = "runtime.providers"
        case validationGates = "validation.gates"
    }

    public static func logger(_ category: Category) -> Logger {
        Logger(subsystem: subsystem, category: category.rawValue)
    }

    public static func signposter(_ category: Category) -> OSSignposter {
        OSSignposter(subsystem: subsystem, category: category.rawValue)
    }
}
