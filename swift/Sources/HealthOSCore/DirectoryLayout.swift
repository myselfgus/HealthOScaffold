import Foundation

public enum DirectoryLayout {
    public static let userSubdirectories = [
        "identity",
        "identifiers",
        "memories",
        "artifacts",
        "drafts",
        "consent",
        "provenance",
        "reidentification",
        "sessions",
        "exports"
    ]

    public static let serviceSubdirectories = [
        "config",
        "members",
        "patients",
        "records",
        "drafts",
        "gates",
        "provenance",
        "analytics"
    ]

    public static let agentSubdirectories = [
        "state",
        "mailbox",
        "memory",
        "cache"
    ]

    public static func bootstrap(at root: URL) throws {
        let sharedDirectories = [
            "system",
            "users",
            "services",
            "agents",
            "runtimes/aaci",
            "runtimes/async",
            "runtimes/user-agent",
            "models/registry",
            "models/adapters",
            "models/evaluations",
            "models/datasets",
            "models/providers",
            "network/mesh",
            "network/certs",
            "network/policies",
            "backups",
            "logs"
        ]

        for relativePath in sharedDirectories {
            try createDirectory(root.appending(path: relativePath))
        }
    }

    public static func ensureUserTree(root: URL, cpfHash: String) throws {
        let base = userRoot(root: root, cpfHash: cpfHash)
        try createDirectory(base)
        for subdir in userSubdirectories {
            try createDirectory(base.appending(path: subdir))
        }
    }

    public static func ensureServiceTree(root: URL, serviceId: UUID) throws {
        let base = serviceRoot(root: root, serviceId: serviceId)
        try createDirectory(base)
        for subdir in serviceSubdirectories {
            try createDirectory(base.appending(path: subdir))
        }
    }

    public static func ensureAgentTree(root: URL, agentId: String) throws {
        let base = root.appending(path: "agents").appending(path: agentId)
        try createDirectory(base)
        for subdir in agentSubdirectories {
            try createDirectory(base.appending(path: subdir))
        }
    }

    public static func userRoot(root: URL, cpfHash: String) -> URL {
        root.appending(path: "users").appending(path: cpfHash)
    }

    public static func serviceRoot(root: URL, serviceId: UUID) -> URL {
        root.appending(path: "services").appending(path: serviceId.uuidString.lowercased())
    }

    private static func createDirectory(_ url: URL) throws {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true)
    }
}
