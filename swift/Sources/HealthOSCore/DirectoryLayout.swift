import Foundation

public enum DirectoryLayout {
    public static func bootstrap(at root: URL) throws {
        try FileManager.default.createDirectory(at: root, withIntermediateDirectories: true)
        // TODO: expand to full canonical directory scaffold when connector false positives are no longer blocking this file.
    }

    public static func userRoot(root: URL, cpfHash: String) -> URL {
        root.appending(path: "users").appending(path: cpfHash)
    }

    public static func serviceRoot(root: URL, serviceId: UUID) -> URL {
        root.appending(path: "services").appending(path: serviceId.uuidString.lowercased())
    }
}
