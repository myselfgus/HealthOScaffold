import Foundation

public actor FileBackedGOSBundleRegistry: GOSBundleRegistry, GOSBundleLoader {
    public let root: URL
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(root: URL) {
        self.root = root
        self.encoder = JSONEncoder()
        self.encoder.outputFormatting = [.prettyPrinted, .sortedKeys]
        self.encoder.dateEncodingStrategy = .iso8601
        self.decoder = JSONDecoder()
        self.decoder.dateDecodingStrategy = .iso8601
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
    }

    public func lookup(specId: String) async throws -> GOSRegistryEntry? {
        let url = registryFileURL(specId: specId)
        guard FileManager.default.fileExists(atPath: url.path) else { return nil }
        let data = try Data(contentsOf: url)
        return try decoder.decode(GOSRegistryEntry.self, from: data)
    }

    public func register(_ manifest: GOSBundleManifest) async throws {
        try ensureDirectories(for: manifest.bundleId)
        try encoder.encode(manifest).write(to: manifestURL(bundleId: manifest.bundleId))

        let existing = try await lookup(specId: manifest.specId) ?? GOSRegistryEntry(specId: manifest.specId)
        let known = Array(Set(existing.knownBundleIds + [manifest.bundleId])).sorted()
        let updated = GOSRegistryEntry(specId: manifest.specId, activeBundleId: existing.activeBundleId, knownBundleIds: known)
        try encoder.encode(updated).write(to: registryFileURL(specId: manifest.specId))
    }

    public func activate(bundleId: String, specId: String) async throws {
        let manifest = try readManifest(bundleId: bundleId)
        guard manifest.specId == specId else {
            throw NSError(domain: GOSLoaderFailure.bundleRegistryFailure.rawValue, code: 9)
        }
        guard manifest.lifecycleState == .reviewed || manifest.lifecycleState == .active else {
            throw NSError(domain: GOSLoaderFailure.bundleInactive.rawValue, code: 10)
        }

        let updatedManifest = GOSBundleManifest(
            bundleId: manifest.bundleId,
            specId: manifest.specId,
            specVersion: manifest.specVersion,
            bundleVersion: manifest.bundleVersion,
            compilerVersion: manifest.compilerVersion,
            compiledAt: manifest.compiledAt,
            lifecycleState: .active,
            replacesBundleId: manifest.replacesBundleId,
            compilerReportPath: manifest.compilerReportPath,
            specPath: manifest.specPath,
            sourceProvenancePath: manifest.sourceProvenancePath,
            notes: manifest.notes
        )
        try encoder.encode(updatedManifest).write(to: manifestURL(bundleId: bundleId))

        let existing = try await lookup(specId: specId) ?? GOSRegistryEntry(specId: specId)
        let known = Array(Set(existing.knownBundleIds + [bundleId])).sorted()
        let updated = GOSRegistryEntry(specId: specId, activeBundleId: bundleId, knownBundleIds: known)
        try encoder.encode(updated).write(to: registryFileURL(specId: specId))
    }

    public func deprecate(bundleId: String, note: String?) async throws {
        try updateLifecycle(bundleId: bundleId, state: .deprecated, note: note, clearActiveRegistryPointer: true)
    }

    public func revoke(bundleId: String, note: String?) async throws {
        try updateLifecycle(bundleId: bundleId, state: .revoked, note: note, clearActiveRegistryPointer: true)
    }

    public func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle {
        guard let registry = try await lookup(specId: request.specId), let activeBundleId = registry.activeBundleId else {
            throw NSError(domain: GOSLoaderFailure.bundleNotFound.rawValue, code: 1)
        }
        guard registry.specId == request.specId else {
            throw NSError(domain: GOSLoaderFailure.bundleRegistryFailure.rawValue, code: 11)
        }
        guard registry.knownBundleIds.contains(activeBundleId) else {
            throw NSError(domain: GOSLoaderFailure.bundleRegistryFailure.rawValue, code: 12)
        }

        let manifest = try readManifest(bundleId: activeBundleId)
        guard manifest.bundleId == activeBundleId, manifest.specId == request.specId else {
            throw NSError(domain: GOSLoaderFailure.bundleRegistryFailure.rawValue, code: 13)
        }
        guard manifest.lifecycleState != .revoked else {
            throw NSError(domain: GOSLoaderFailure.bundleRevoked.rawValue, code: 2)
        }
        guard request.acceptedLifecycleStates.contains(manifest.lifecycleState) else {
            throw NSError(domain: GOSLoaderFailure.bundleInactive.rawValue, code: 3)
        }

        let specData = try loadRequiredJSONFile(
            bundleId: activeBundleId,
            relativePath: manifest.specPath ?? "spec.json",
            missingCode: 21
        )
        let reportData = try loadRequiredJSONFile(
            bundleId: activeBundleId,
            relativePath: manifest.compilerReportPath ?? "compiler-report.json",
            missingCode: 22
        )
        _ = try loadRequiredJSONFile(
            bundleId: activeBundleId,
            relativePath: manifest.sourceProvenancePath ?? "source-provenance.json",
            missingCode: 23
        )

        let compilerReport = try decodeCompilerReport(from: reportData)
        guard compilerReport.parseOK, compilerReport.structuralOK, compilerReport.crossReferenceOK else {
            throw NSError(domain: GOSLoaderFailure.bundleValidationFailure.rawValue, code: 24)
        }
        let metadata = try extractMetadata(from: specData)
        let bindingPlanURL = bundleDirectoryURL(bundleId: activeBundleId).appending(path: "runtime-binding-plan.json")
        let bindingPlan: GOSRuntimeBindingPlan?
        if FileManager.default.fileExists(atPath: bindingPlanURL.path) {
            let loaded = try decoder.decode(GOSRuntimeBindingPlan.self, from: Data(contentsOf: bindingPlanURL))
            guard loaded.specId == request.specId, loaded.runtimeKind == request.runtimeKind else {
                throw NSError(domain: GOSLoaderFailure.bundleValidationFailure.rawValue, code: 25)
            }
            bindingPlan = loaded
        } else {
            bindingPlan = nil
        }

        return GOSCompiledBundle(
            manifest: manifest,
            metadata: metadata,
            compilerReport: compilerReport,
            runtimeBindingPlan: bindingPlan,
            compiledSpecJSON: specData
        )
    }

    private func ensureDirectories(for bundleId: String) throws {
        try FileManager.default.createDirectory(at: registryDirectoryURL(), withIntermediateDirectories: true)
        try FileManager.default.createDirectory(at: bundleDirectoryURL(bundleId: bundleId), withIntermediateDirectories: true)
    }

    private func registryDirectoryURL() -> URL {
        root.appending(path: "system").appending(path: "gos").appending(path: "registry")
    }

    private func registryFileURL(specId: String) -> URL {
        registryDirectoryURL().appending(path: "\(specId).json")
    }

    private func bundleDirectoryURL(bundleId: String) -> URL {
        root.appending(path: "system").appending(path: "gos").appending(path: "bundles").appending(path: bundleId)
    }

    private func manifestURL(bundleId: String) -> URL {
        bundleDirectoryURL(bundleId: bundleId).appending(path: "manifest.json")
    }

    private func readManifest(bundleId: String) throws -> GOSBundleManifest {
        let url = manifestURL(bundleId: bundleId)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: GOSLoaderFailure.bundleNotFound.rawValue, code: 5)
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(GOSBundleManifest.self, from: data)
        } catch {
            throw NSError(domain: GOSLoaderFailure.bundleValidationFailure.rawValue, code: 6)
        }
    }

    private func decodeCompilerReport(from data: Data) throws -> GOSCompilerReportRecord {
        do {
            let reportDecoder = JSONDecoder()
            return try reportDecoder.decode(GOSCompilerReportRecord.self, from: data)
        } catch {
            throw NSError(domain: GOSLoaderFailure.bundleValidationFailure.rawValue, code: 7)
        }
    }

    private func loadRequiredJSONFile(
        bundleId: String,
        relativePath: String,
        missingCode: Int
    ) throws -> Data {
        let url = bundleDirectoryURL(bundleId: bundleId).appending(path: relativePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw NSError(domain: GOSLoaderFailure.bundleIntegrityFailure.rawValue, code: missingCode)
        }
        return try Data(contentsOf: url)
    }

    private func updateLifecycle(
        bundleId: String,
        state: GOSLifecycleState,
        note: String?,
        clearActiveRegistryPointer: Bool
    ) throws {
        let manifest = try readManifest(bundleId: bundleId)
        let updated = GOSBundleManifest(
            bundleId: manifest.bundleId,
            specId: manifest.specId,
            specVersion: manifest.specVersion,
            bundleVersion: manifest.bundleVersion,
            compilerVersion: manifest.compilerVersion,
            compiledAt: manifest.compiledAt,
            lifecycleState: state,
            replacesBundleId: manifest.replacesBundleId,
            compilerReportPath: manifest.compilerReportPath,
            specPath: manifest.specPath,
            sourceProvenancePath: manifest.sourceProvenancePath,
            notes: note ?? manifest.notes
        )
        try encoder.encode(updated).write(to: manifestURL(bundleId: bundleId))

        guard clearActiveRegistryPointer else { return }
        let registryURL = registryFileURL(specId: manifest.specId)
        guard FileManager.default.fileExists(atPath: registryURL.path) else { return }
        let registryData = try Data(contentsOf: registryURL)
        let registry = try decoder.decode(GOSRegistryEntry.self, from: registryData)
        guard registry.activeBundleId == bundleId else { return }
        let updatedRegistry = GOSRegistryEntry(
            specId: registry.specId,
            activeBundleId: nil,
            knownBundleIds: registry.knownBundleIds
        )
        try encoder.encode(updatedRegistry).write(to: registryURL)
    }

    private func extractMetadata(from compiledSpecJSON: Data) throws -> GOSMetadata {
        let raw = try JSONSerialization.jsonObject(with: compiledSpecJSON)
        guard let root = raw as? [String: Any], let metadata = root["metadata"] as? [String: Any] else {
            throw NSError(domain: GOSLoaderFailure.bundleValidationFailure.rawValue, code: 4)
        }

        let title = metadata["title"] as? String ?? "Untitled GOS Bundle"
        let description = metadata["description"] as? String
        let status = GOSLifecycleState(rawValue: metadata["status"] as? String ?? GOSLifecycleState.draft.rawValue) ?? .draft
        let authoringForm = metadata["authoring_form"] as? String ?? "yaml"
        let compiledForm = metadata["compiled_form"] as? String
        let tags = metadata["tags"] as? [String] ?? []
        let sourceReferences = (metadata["source_references"] as? [[String: Any]] ?? []).compactMap { item -> GOSSourceReference? in
            guard let kind = item["kind"] as? String, let reference = item["reference"] as? String else { return nil }
            return GOSSourceReference(kind: kind, reference: reference, version: item["version"] as? String)
        }

        return GOSMetadata(
            title: title,
            description: description,
            status: status,
            authoringForm: authoringForm,
            compiledForm: compiledForm,
            sourceReferences: sourceReferences,
            tags: tags
        )
    }
}
