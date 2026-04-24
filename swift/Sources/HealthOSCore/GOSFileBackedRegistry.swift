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
        try appendAuditRecord(
            GOSLifecycleAuditRecord(
                specId: manifest.specId,
                bundleId: manifest.bundleId,
                action: .registered,
                actorId: "system.registry",
                actorRole: "system",
                rationale: "bundle registered in file-backed registry",
                toState: manifest.lifecycleState
            )
        )
    }

    public func review(
        bundleId: String,
        specId: String,
        reviewerId: String,
        reviewerRole: String,
        rationale: String
    ) async throws -> GOSBundleReviewRecord {
        try await reviewBundle(
            bundleId: bundleId,
            specId: specId,
            reviewerId: reviewerId,
            reviewerRole: reviewerRole,
            rationale: rationale
        ).reviewRecord
    }

    public func reviewBundle(
        bundleId: String,
        specId: String,
        reviewerId: String,
        reviewerRole: String,
        rationale: String
    ) async throws -> GOSReviewResult {
        let manifest = try readManifest(bundleId: bundleId)
        guard manifest.specId == specId else {
            throw GOSRegistryError.bundleSpecMismatch(expectedSpecId: specId, actualSpecId: manifest.specId, bundleId: bundleId)
        }
        guard manifest.lifecycleState == .draft || manifest.lifecycleState == .reviewed else {
            throw GOSRegistryError.reviewRejectedForLifecycle(bundleId: bundleId, lifecycleState: manifest.lifecycleState)
        }

        let reviewRecord = GOSBundleReviewRecord(
            specId: specId,
            bundleId: bundleId,
            reviewerId: reviewerId,
            reviewerRole: reviewerRole,
            rationale: rationale
        )
        try encoder.encode(reviewRecord).write(to: reviewRecordURL(bundleId: bundleId))

        let reviewedManifest = GOSBundleManifest(
            bundleId: manifest.bundleId,
            specId: manifest.specId,
            specVersion: manifest.specVersion,
            bundleVersion: manifest.bundleVersion,
            compilerVersion: manifest.compilerVersion,
            compiledAt: manifest.compiledAt,
            lifecycleState: .reviewed,
            replacesBundleId: manifest.replacesBundleId,
            compilerReportPath: manifest.compilerReportPath,
            specPath: manifest.specPath,
            sourceProvenancePath: manifest.sourceProvenancePath,
            notes: manifest.notes
        )
        try encoder.encode(reviewedManifest).write(to: manifestURL(bundleId: bundleId))

        let existing = try await lookup(specId: specId) ?? GOSRegistryEntry(specId: specId)
        let known = Array(Set(existing.knownBundleIds + [bundleId])).sorted()
        let updated = GOSRegistryEntry(specId: specId, activeBundleId: existing.activeBundleId, knownBundleIds: known)
        try encoder.encode(updated).write(to: registryFileURL(specId: specId))

        let auditRecord = GOSLifecycleAuditRecord(
            specId: specId,
            bundleId: bundleId,
            action: .reviewed,
            actorId: reviewerId,
            actorRole: reviewerRole,
            rationale: rationale,
            fromState: manifest.lifecycleState,
            toState: .reviewed,
            recordedAt: reviewRecord.reviewedAt
        )
        try appendAuditRecord(auditRecord)

        return GOSReviewResult(reviewRecord: reviewRecord, lifecycleAuditRecord: auditRecord)
    }

    public func activate(bundleId: String, specId: String) async throws {
        _ = try await activateBundle(
            bundleId: bundleId,
            specId: specId,
            actorId: "system.registry",
            actorRole: "system",
            rationale: "bundle activated by registry"
        )
    }

    @discardableResult
    public func promoteReviewedBundle(
        bundleId: String,
        specId: String,
        actorId: String = NSUserName(),
        actorRole: String = "operator",
        rationale: String = "bundle promoted via HealthOSCLI"
    ) async throws -> GOSLifecycleAuditRecord {
        try await activateBundle(
            bundleId: bundleId,
            specId: specId,
            actorId: actorId,
            actorRole: actorRole,
            rationale: rationale
        ).lifecycleAuditRecord
    }

    public func deprecate(bundleId: String, note: String?) async throws {
        try updateLifecycle(
            bundleId: bundleId,
            state: .deprecated,
            note: note,
            clearActiveRegistryPointer: true,
            auditAction: .deprecated
        )
    }

    public func revoke(bundleId: String, note: String?) async throws {
        try updateLifecycle(
            bundleId: bundleId,
            state: .revoked,
            note: note,
            clearActiveRegistryPointer: true,
            auditAction: .revoked
        )
    }

    public func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle {
        guard let registry = try await lookup(specId: request.specId), let activeBundleId = registry.activeBundleId else {
            throw GOSRegistryError.bundleNotFound(bundleId: request.specId)
        }
        guard registry.specId == request.specId else {
            throw GOSRegistryError.registrySpecMismatch(expectedSpecId: request.specId, actualSpecId: registry.specId)
        }
        guard registry.knownBundleIds.contains(activeBundleId) else {
            throw GOSRegistryError.registryBundleMissing(specId: request.specId, bundleId: activeBundleId)
        }

        let manifest = try readManifest(bundleId: activeBundleId)
        guard manifest.bundleId == activeBundleId, manifest.specId == request.specId else {
            throw GOSRegistryError.bundleSpecMismatch(expectedSpecId: request.specId, actualSpecId: manifest.specId, bundleId: activeBundleId)
        }
        guard manifest.lifecycleState != .revoked else {
            throw GOSRegistryError.bundleRevoked(bundleId: activeBundleId)
        }
        guard manifest.lifecycleState != .deprecated else {
            throw GOSRegistryError.bundleDeprecated(bundleId: activeBundleId)
        }
        guard request.acceptedLifecycleStates.contains(manifest.lifecycleState) else {
            throw GOSRegistryError.lifecycleStateNotAccepted(
                bundleId: activeBundleId,
                state: manifest.lifecycleState,
                accepted: request.acceptedLifecycleStates
            )
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

        let compilerReport = try decodeCompilerReport(bundleId: activeBundleId, from: reportData)
        guard compilerReport.parseOK, compilerReport.structuralOK, compilerReport.crossReferenceOK else {
            throw GOSRegistryError.compilerReportInvalid(bundleId: activeBundleId)
        }
        let metadata = try extractMetadata(from: specData)
        let bindingPlanURL = bundleDirectoryURL(bundleId: activeBundleId).appending(path: "runtime-binding-plan.json")
        let bindingPlan: GOSRuntimeBindingPlan?
        if FileManager.default.fileExists(atPath: bindingPlanURL.path) {
            let loaded = try decoder.decode(GOSRuntimeBindingPlan.self, from: Data(contentsOf: bindingPlanURL))
            guard loaded.specId == request.specId, loaded.runtimeKind == request.runtimeKind else {
                throw GOSRegistryError.runtimeBindingPlanInvalid(
                    bundleId: activeBundleId,
                    expectedSpecId: request.specId,
                    expectedRuntimeKind: request.runtimeKind
                )
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

    public func activateBundle(
        bundleId: String,
        specId: String,
        actorId: String,
        actorRole: String,
        rationale: String
    ) async throws -> GOSActivationResult {
        let manifest = try readManifest(bundleId: bundleId)
        guard manifest.specId == specId else {
            throw GOSRegistryError.bundleSpecMismatch(expectedSpecId: specId, actualSpecId: manifest.specId, bundleId: bundleId)
        }
        guard manifest.lifecycleState == .reviewed || manifest.lifecycleState == .active else {
            throw GOSRegistryError.activationRequiresReviewedOrActive(bundleId: bundleId, lifecycleState: manifest.lifecycleState)
        }
        if manifest.lifecycleState == .reviewed {
            _ = try readReviewRecord(bundleId: bundleId)
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
        let auditRecord = GOSLifecycleAuditRecord(
            specId: specId,
            bundleId: bundleId,
            action: .activated,
            actorId: actorId,
            actorRole: actorRole,
            rationale: rationale,
            fromState: manifest.lifecycleState,
            toState: .active
        )
        try appendAuditRecord(auditRecord)
        return GOSActivationResult(
            specId: specId,
            bundleId: bundleId,
            fromState: manifest.lifecycleState,
            toState: .active,
            lifecycleAuditRecord: auditRecord
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

    private func reviewRecordURL(bundleId: String) -> URL {
        bundleDirectoryURL(bundleId: bundleId).appending(path: "review-approval.json")
    }

    private func manifestURL(bundleId: String) -> URL {
        bundleDirectoryURL(bundleId: bundleId).appending(path: "manifest.json")
    }

    private func auditLogURL() -> URL {
        root.appending(path: "system").appending(path: "gos").appending(path: "audit.jsonl")
    }

    private func readManifest(bundleId: String) throws -> GOSBundleManifest {
        let url = manifestURL(bundleId: bundleId)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw GOSRegistryError.manifestMissing(bundleId: bundleId)
        }
        let data = try Data(contentsOf: url)
        do {
            return try decoder.decode(GOSBundleManifest.self, from: data)
        } catch {
            throw GOSRegistryError.manifestDecodeFailure(bundleId: bundleId)
        }
    }

    private func decodeCompilerReport(bundleId: String, from data: Data) throws -> GOSCompilerReportRecord {
        do {
            let reportDecoder = JSONDecoder()
            return try reportDecoder.decode(GOSCompilerReportRecord.self, from: data)
        } catch {
            throw GOSRegistryError.compilerReportDecodeFailure(bundleId: bundleId)
        }
    }

    private func readReviewRecord(bundleId: String) throws -> GOSBundleReviewRecord {
        let url = reviewRecordURL(bundleId: bundleId)
        guard FileManager.default.fileExists(atPath: url.path) else {
            throw GOSRegistryError.activationRequiresReviewRecord(bundleId: bundleId)
        }
        do {
            return try decoder.decode(GOSBundleReviewRecord.self, from: Data(contentsOf: url))
        } catch {
            throw GOSRegistryError.reviewRecordDecodeFailure(bundleId: bundleId)
        }
    }

    private func loadRequiredJSONFile(
        bundleId: String,
        relativePath: String,
        missingCode: Int
    ) throws -> Data {
        let url = bundleDirectoryURL(bundleId: bundleId).appending(path: relativePath)
        guard FileManager.default.fileExists(atPath: url.path) else {
            switch missingCode {
            case 21:
                throw GOSRegistryError.specMissing(bundleId: bundleId, path: relativePath)
            case 22:
                throw GOSRegistryError.compilerReportMissing(bundleId: bundleId, path: relativePath)
            case 23:
                throw GOSRegistryError.sourceProvenanceMissing(bundleId: bundleId, path: relativePath)
            default:
                throw GOSRegistryError.bundleNotFound(bundleId: bundleId)
            }
        }
        return try Data(contentsOf: url)
    }

    private func updateLifecycle(
        bundleId: String,
        state: GOSLifecycleState,
        note: String?,
        clearActiveRegistryPointer: Bool,
        auditAction: GOSLifecycleAuditAction
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

        if clearActiveRegistryPointer {
            let registryURL = registryFileURL(specId: manifest.specId)
            if FileManager.default.fileExists(atPath: registryURL.path) {
                let registryData = try Data(contentsOf: registryURL)
                let registry = try decoder.decode(GOSRegistryEntry.self, from: registryData)
                if registry.activeBundleId == bundleId {
                    let updatedRegistry = GOSRegistryEntry(
                        specId: registry.specId,
                        activeBundleId: nil,
                        knownBundleIds: registry.knownBundleIds
                    )
                    try encoder.encode(updatedRegistry).write(to: registryURL)
                }
            }
        }

        try appendAuditRecord(
            GOSLifecycleAuditRecord(
                specId: manifest.specId,
                bundleId: bundleId,
                action: auditAction,
                actorId: "system.registry",
                actorRole: "system",
                rationale: note,
                fromState: manifest.lifecycleState,
                toState: state
            )
        )
    }

    private func extractMetadata(from compiledSpecJSON: Data) throws -> GOSMetadata {
        let raw = try JSONSerialization.jsonObject(with: compiledSpecJSON)
        guard let root = raw as? [String: Any], let metadata = root["metadata"] as? [String: Any] else {
            throw GOSRegistryError.metadataMissing(bundleId: "compiled-spec")
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

    private func appendAuditRecord(_ record: GOSLifecycleAuditRecord) throws {
        let url = auditLogURL()
        try FileManager.default.createDirectory(at: url.deletingLastPathComponent(), withIntermediateDirectories: true)
        let auditEncoder = JSONEncoder()
        auditEncoder.outputFormatting = [.sortedKeys]
        auditEncoder.dateEncodingStrategy = .iso8601
        let data = try auditEncoder.encode(record)
        if FileManager.default.fileExists(atPath: url.path) {
            let handle = try FileHandle(forWritingTo: url)
            defer { try? handle.close() }
            try handle.seekToEnd()
            handle.write(data)
            handle.write(Data("\n".utf8))
        } else {
            try (data + Data("\n".utf8)).write(to: url)
        }
    }
}
