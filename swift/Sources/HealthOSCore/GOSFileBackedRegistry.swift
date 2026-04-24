import Foundation

public enum GOSRuntimeScaffoldError: Error, Sendable {
    case notImplemented
}

public actor FileBackedGOSBundleRegistry: GOSBundleRegistry, GOSBundleLoader {
    public let root: URL

    public init(root: URL) {
        self.root = root
    }

    public func lookup(specId: String) async throws -> GOSRegistryEntry? {
        throw GOSRuntimeScaffoldError.notImplemented
    }

    public func register(_ manifest: GOSBundleManifest) async throws {
        throw GOSRuntimeScaffoldError.notImplemented
    }

    public func activate(bundleId: String, specId: String) async throws {
        throw GOSRuntimeScaffoldError.notImplemented
    }

    public func deprecate(bundleId: String, note: String?) async throws {
        throw GOSRuntimeScaffoldError.notImplemented
    }

    public func revoke(bundleId: String, note: String?) async throws {
        throw GOSRuntimeScaffoldError.notImplemented
    }

    public func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle {
        throw GOSRuntimeScaffoldError.notImplemented
    }
}
