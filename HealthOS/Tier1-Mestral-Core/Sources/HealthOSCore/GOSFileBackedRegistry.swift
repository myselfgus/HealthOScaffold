import Foundation

public actor FileBackedGOSBundleRegistry: GOSBundleRegistry, GOSBundleLoader {
    public let root: URL
    public let lifecyclePolicy: GOSLifecyclePolicy
    private let encoder: JSONEncoder
    private let decoder: JSONDecoder

    public init(root: URL, lifecyclePolicy: GOSLifecyclePolicy = .default) {
        self.root = root
        self.lifecyclePolicy = lifecyclePolicy
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
        do {
            return try decoder.decode(GOSRegistryEntry.self, from: data)
        } catch {
            throw GOSRegistryError.registryEntryDecodeFailure(specId: specId)
        }
    }

    public func register(_ manifest: GOSBundleManifest) async throws {
        try ensureDirectories(for: manifest.bundleId)
        try encoder.encode(manifest).write(to: manifestURL(bundleId: manifest.bundleId))

        let existing = try await lookup(specId: manifest.specId) ?? GOSRegistryEntry(specId: manifest.specId)
        let known = normalizedKnownBundleIds(existing.knownBundleIds + [manifest.bundleId])
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
        try appendAuditRecord(
            GOSLifecycleAuditRecord(
                specId: specId,
                bundleId: bundleId,
                action: .reviewSubmitted,
                actorId: reviewerId,
                actorRole: reviewerRole,
                rationale: rationale,
                fromState: manifest.lifecycleState,
                toState: manifest.lifecycleState
            )
        )
        let reviewRationale = rationale.trimmingCharacters(in: .whitespacesAndNewlines)
        var reviewPolicyFailures: [GOSPolicyFailure] = []
        if lifecyclePolicy.review.requireRationale, reviewRationale.isEmpty {
            reviewPolicyFailures.append(.rationaleMissing)
        }
        if lifecyclePolicy.review.compilerReportMustPass {
            let report = try loadCompilerReport(bundleId: bundleId, manifest: manifest)
            if !report.parseOK || !report.structuralOK || !report.crossReferenceOK {
                reviewPolicyFailures.append(.compilerReportInvalid)
            }
        }
        if !reviewPolicyFailures.isEmpty {
            try appendAuditRecord(
                GOSLifecycleAuditRecord(
                    specId: specId,
                    bundleId: bundleId,
                    action: .reviewDeniedPolicy,
                    actorId: reviewerId,
                    actorRole: reviewerRole,
                    rationale: "policy_failures=\(reviewPolicyFailures.map(\.rawValue).joined(separator: ","))",
                    fromState: manifest.lifecycleState,
                    toState: manifest.lifecycleState
                )
            )
            if reviewPolicyFailures.contains(.rationaleMissing) {
                throw GOSRegistryError.reviewRationaleRequired(bundleId: bundleId)
            }
            if reviewPolicyFailures.contains(.compilerReportInvalid) {
                throw GOSRegistryError.reviewCompilerReportInvalid(bundleId: bundleId)
            }
            throw GOSRegistryError.reviewPolicyNotSatisfied(bundleId: bundleId, failures: reviewPolicyFailures)
        }

        let reviewRecord = GOSBundleReviewRecord(
            specId: specId,
            bundleId: bundleId,
            reviewerId: reviewerId,
            reviewerRole: reviewerRole,
            rationale: reviewRationale
        )
        try encoder.encode(reviewRecord).write(to: reviewRecordURL(bundleId: bundleId))
        try appendReviewRecord(reviewRecord, bundleId: bundleId)

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
        let known = normalizedKnownBundleIds(existing.knownBundleIds + [bundleId])
        let updated = GOSRegistryEntry(specId: specId, activeBundleId: existing.activeBundleId, knownBundleIds: known)
        try encoder.encode(updated).write(to: registryFileURL(specId: specId))

        let auditRecord = GOSLifecycleAuditRecord(
            specId: specId,
            bundleId: bundleId,
            action: .reviewed,
            actorId: reviewerId,
            actorRole: reviewerRole,
            rationale: reviewRationale,
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
        rationale: String = "bundle promoted via HealthOSCLI",
        expectedPins: GOSActivationPins? = nil
    ) async throws -> GOSLifecycleAuditRecord {
        try await activateBundle(
            bundleId: bundleId,
            specId: specId,
            actorId: actorId,
            actorRole: actorRole,
            rationale: rationale,
            expectedPins: expectedPins
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
        guard let registry = try await lookup(specId: request.specId) else {
            throw GOSRegistryError.registryMissing(specId: request.specId)
        }
        let knownBundleIds = normalizedKnownBundleIds(registry.knownBundleIds)
        guard registry.specId == request.specId else {
            throw GOSRegistryError.registrySpecMismatch(expectedSpecId: request.specId, actualSpecId: registry.specId)
        }
        guard let activeBundleId = registry.activeBundleId else {
            var activeCandidates: [String] = []
            for bundleId in knownBundleIds {
                let manifest = try readManifest(bundleId: bundleId)
                if manifest.lifecycleState == .active {
                    activeCandidates.append(bundleId)
                }
            }
            if let singleActiveCandidate = activeCandidates.onlyElement {
                throw GOSRegistryError.registryMissingActivePointer(
                    specId: request.specId,
                    activeBundleId: singleActiveCandidate
                )
            }
            if !activeCandidates.isEmpty {
                throw GOSRegistryError.multipleActiveBundles(specId: request.specId, bundleIds: activeCandidates.sorted())
            }
            throw GOSRegistryError.bundleNotFound(bundleId: request.specId)
        }
        guard knownBundleIds.contains(activeBundleId) else {
            throw GOSRegistryError.registryBundleMissing(specId: request.specId, bundleId: activeBundleId)
        }

        var activeManifests: [String] = []
        for bundleId in knownBundleIds {
            let manifest = try readManifest(bundleId: bundleId)
            guard manifest.specId == request.specId else {
                throw GOSRegistryError.bundleSpecMismatch(
                    expectedSpecId: request.specId,
                    actualSpecId: manifest.specId,
                    bundleId: bundleId
                )
            }
            if manifest.lifecycleState == .active {
                activeManifests.append(bundleId)
            }
        }
        let activeSet = Set(activeManifests)
        if activeSet.count > 1 {
            throw GOSRegistryError.multipleActiveBundles(specId: request.specId, bundleIds: Array(activeSet).sorted())
        }
        if let discoveredActive = activeSet.first, discoveredActive != activeBundleId {
            throw GOSRegistryError.registryMissingActivePointer(specId: request.specId, activeBundleId: discoveredActive)
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
        rationale: String,
        expectedPins: GOSActivationPins? = nil
    ) async throws -> GOSActivationResult {
        let manifest = try readManifest(bundleId: bundleId)
        guard manifest.specId == specId else {
            throw GOSRegistryError.bundleSpecMismatch(expectedSpecId: specId, actualSpecId: manifest.specId, bundleId: bundleId)
        }
        guard manifest.lifecycleState == .reviewed || manifest.lifecycleState == .active else {
            throw GOSRegistryError.invalidBundleState(
                bundleId: bundleId,
                state: manifest.lifecycleState,
                expected: [.reviewed, .active]
            )
        }
        try appendAuditRecord(
            GOSLifecycleAuditRecord(
                specId: specId,
                bundleId: bundleId,
                action: .activationRequested,
                actorId: actorId,
                actorRole: actorRole,
                rationale: rationale,
                fromState: manifest.lifecycleState,
                toState: manifest.lifecycleState
            )
        )
        let normalizedRationale = rationale.trimmingCharacters(in: .whitespacesAndNewlines)
        let policyEvaluation = try evaluateActivationPolicy(
            bundleId: bundleId,
            specId: specId,
            actorId: actorId,
            manifest: manifest,
            expectedPins: expectedPins,
            rationale: normalizedRationale
        )
        if !policyEvaluation.failures.isEmpty {
            try appendAuditRecord(
                GOSLifecycleAuditRecord(
                    specId: specId,
                    bundleId: bundleId,
                    action: .activationDeniedPolicy,
                    actorId: actorId,
                    actorRole: actorRole,
                    rationale: "policy_failures=\(policyEvaluation.failures.map(\.rawValue).joined(separator: ","))",
                    fromState: manifest.lifecycleState,
                    toState: manifest.lifecycleState
                )
            )
            throw policyEvaluation.error
        }

        let existing = try await lookup(specId: specId) ?? GOSRegistryEntry(specId: specId)
        let known = normalizedKnownBundleIds(existing.knownBundleIds + [bundleId])
        if let existingActiveBundleId = existing.activeBundleId,
           !known.contains(existingActiveBundleId) {
            throw GOSRegistryError.invalidActivationState(
                specId: specId,
                detail: "active pointer \(existingActiveBundleId) is not present in known bundle ids"
            )
        }
        let discoveredActive = try discoverActiveBundleIds(specId: specId, knownBundleIds: known)
        let discoveredActiveSet = Set(discoveredActive)
        if discoveredActiveSet.count > 1 {
            throw GOSRegistryError.invalidActivationState(
                specId: specId,
                detail: "multiple active bundles discovered before activation: \(Array(discoveredActiveSet).sorted())"
            )
        }
        if let onlyActive = discoveredActiveSet.first,
           let existingActiveBundleId = existing.activeBundleId,
           onlyActive != existingActiveBundleId {
            throw GOSRegistryError.invalidActivationState(
                specId: specId,
                detail: "registry active pointer \(existingActiveBundleId) does not match active manifest \(onlyActive)"
            )
        }

        if let existingActiveBundleId = existing.activeBundleId,
           existingActiveBundleId != bundleId {
            let existingActiveManifest = try readManifest(bundleId: existingActiveBundleId)
            guard existingActiveManifest.specId == specId else {
                throw GOSRegistryError.bundleSpecMismatch(
                    expectedSpecId: specId,
                    actualSpecId: existingActiveManifest.specId,
                    bundleId: existingActiveBundleId
                )
            }
            if existingActiveManifest.lifecycleState == .active {
                try writeManifest(existingActiveManifest, replacingLifecycleWith: .superseded)
            }
        }

        try writeManifest(manifest, replacingLifecycleWith: .active)
        let updated = GOSRegistryEntry(specId: specId, activeBundleId: bundleId, knownBundleIds: known)
        try encoder.encode(updated).write(to: registryFileURL(specId: specId))
        let auditRecord = GOSLifecycleAuditRecord(
            specId: specId,
            bundleId: bundleId,
            action: .activated,
            actorId: actorId,
            actorRole: actorRole,
            rationale: normalizedRationale,
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

    private func reviewRecordsURL(bundleId: String) -> URL {
        bundleDirectoryURL(bundleId: bundleId).appending(path: "review-approvals.jsonl")
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

    private func readReviewRecords(bundleId: String) throws -> [GOSBundleReviewRecord] {
        let single = try? readReviewRecord(bundleId: bundleId)
        let jsonlURL = reviewRecordsURL(bundleId: bundleId)
        guard FileManager.default.fileExists(atPath: jsonlURL.path) else {
            return single.map { [$0] } ?? []
        }
        let lines = try String(contentsOf: jsonlURL, encoding: .utf8)
            .split(whereSeparator: \.isNewline)
        let decoded = try lines.map { line in
            do {
                return try decoder.decode(GOSBundleReviewRecord.self, from: Data(line.utf8))
            } catch {
                throw GOSRegistryError.reviewRecordsDecodeFailure(bundleId: bundleId)
            }
        }
        if let single {
            let hasSingle = decoded.contains(where: { $0.id == single.id })
            return hasSingle ? decoded : decoded + [single]
        }
        return decoded
    }

    private func appendReviewRecord(_ record: GOSBundleReviewRecord, bundleId: String) throws {
        let url = reviewRecordsURL(bundleId: bundleId)
        let lineEncoder = JSONEncoder()
        lineEncoder.outputFormatting = [.sortedKeys]
        lineEncoder.dateEncodingStrategy = .iso8601
        let data = try lineEncoder.encode(record)
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

    private func loadCompilerReport(bundleId: String, manifest: GOSBundleManifest) throws -> GOSCompilerReportRecord {
        let reportData = try loadRequiredJSONFile(
            bundleId: bundleId,
            relativePath: manifest.compilerReportPath ?? "compiler-report.json",
            missingCode: 22
        )
        return try decodeCompilerReport(bundleId: bundleId, from: reportData)
    }

    private func loadSourceProvenance(bundleId: String, manifest: GOSBundleManifest) throws -> GOSSourceProvenanceRecord {
        let provenanceData = try loadRequiredJSONFile(
            bundleId: bundleId,
            relativePath: manifest.sourceProvenancePath ?? "source-provenance.json",
            missingCode: 23
        )
        do {
            return try decoder.decode(GOSSourceProvenanceRecord.self, from: provenanceData)
        } catch {
            throw GOSRegistryError.sourceProvenanceDecodeFailure(bundleId: bundleId)
        }
    }

    private func compiledSpecHash(bundleId: String, manifest: GOSBundleManifest) throws -> String {
        let specData = try loadRequiredJSONFile(
            bundleId: bundleId,
            relativePath: manifest.specPath ?? "spec.json",
            missingCode: 21
        )
        return self.sha256Hex(for: specData)
    }

    private func sha256Hex(for data: Data) -> String {
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/env")
        process.arguments = ["shasum", "-a", "256"]
        let outputPipe = Pipe()
        let inputPipe = Pipe()
        process.standardOutput = outputPipe
        process.standardError = Pipe()
        process.standardInput = inputPipe

        do {
            try process.run()
            inputPipe.fileHandleForWriting.write(data)
            try inputPipe.fileHandleForWriting.close()
            process.waitUntilExit()
            let output = String(data: outputPipe.fileHandleForReading.readDataToEndOfFile(), encoding: .utf8) ?? ""
            return output.split(separator: " ").first.map(String.init) ?? "sha256-unavailable"
        } catch {
            return "sha256-unavailable"
        }
    }

    private func evaluateActivationPolicy(
        bundleId: String,
        specId: String,
        actorId: String,
        manifest: GOSBundleManifest,
        expectedPins: GOSActivationPins?,
        rationale: String
    ) throws -> (failures: [GOSPolicyFailure], error: GOSRegistryError) {
        var failures: [GOSPolicyFailure] = []
        if lifecyclePolicy.review.requireRationale, rationale.isEmpty {
            failures.append(.rationaleMissing)
        }
        let reviewRecords = try readReviewRecords(bundleId: bundleId)
        let uniqueReviewers = Set(reviewRecords.map(\.reviewerId))
        if manifest.lifecycleState == .reviewed {
            if uniqueReviewers.count < lifecyclePolicy.review.minimumApprovals {
                failures.append(.insufficientReviews)
            }
            if lifecyclePolicy.enforceSeparationOfDuties && uniqueReviewers.contains(actorId) {
                failures.append(.separationOfDutiesViolation)
            }
            if lifecyclePolicy.enforceSeparationOfDuties {
                let independentReviewers = uniqueReviewers.subtracting([actorId])
                if independentReviewers.count < lifecyclePolicy.review.minimumApprovals {
                    failures.append(.insufficientIndependentReviews)
                }
            }
        }
        if lifecyclePolicy.activationRequiresCompilerReportPass {
            let report = try loadCompilerReport(bundleId: bundleId, manifest: manifest)
            if !report.parseOK || !report.structuralOK || !report.crossReferenceOK {
                failures.append(.compilerReportInvalid)
            }
        }
        var pinMismatchError: GOSRegistryError?
        if let pins = expectedPins {
            let pinEvaluation = try evaluatePins(bundleId: bundleId, manifest: manifest, pins: pins)
            failures.append(contentsOf: pinEvaluation.failures)
            pinMismatchError = pinEvaluation.mismatchError
        } else if lifecyclePolicy.versionPinning.requirePins {
            failures.append(.requiredPinMissing)
        }

        if failures.contains(.separationOfDutiesViolation) {
            return (failures, .separationOfDutiesViolation(bundleId: bundleId, actorId: actorId))
        }
        if failures.contains(.insufficientIndependentReviews) {
            let independentCount = Set(reviewRecords.map(\.reviewerId)).subtracting([actorId]).count
            return (failures, .insufficientIndependentReviews(bundleId: bundleId, required: lifecyclePolicy.review.minimumApprovals, actual: independentCount))
        }
        if failures.contains(.insufficientReviews) {
            return (failures, .activationPolicyNotSatisfied(bundleId: bundleId, failures: failures))
        }
        if failures.contains(.rationaleMissing) {
            return (failures, .activationRationaleRequired(bundleId: bundleId))
        }
        if failures.contains(.compilerReportInvalid) {
            return (failures, .compilerReportInvalid(bundleId: bundleId))
        }
        if failures.contains(.requiredPinMissing) {
            return (failures, .activationPolicyNotSatisfied(bundleId: bundleId, failures: failures))
        }
        if let pinMismatchError {
            return (failures, pinMismatchError)
        }
        if failures.contains(.pinMismatch) {
            return (failures, .activationPolicyNotSatisfied(bundleId: bundleId, failures: failures))
        }
        return (failures, .activationPolicyNotSatisfied(bundleId: bundleId, failures: failures))
    }

    private func evaluatePins(
        bundleId: String,
        manifest: GOSBundleManifest,
        pins: GOSActivationPins
    ) throws -> (failures: [GOSPolicyFailure], mismatchError: GOSRegistryError?) {
        var failures: [GOSPolicyFailure] = []
        var mismatchError: GOSRegistryError?
        func evaluateField(_ field: String, expected: String?, actual: String) {
            guard let expected else {
                if lifecyclePolicy.versionPinning.requirePins {
                    failures.append(.requiredPinMissing)
                }
                return
            }
            if expected != actual {
                failures.append(.pinMismatch)
                if mismatchError == nil {
                    mismatchError = GOSRegistryError.activationPinMismatch(bundleId: bundleId, field: field, expected: expected, actual: actual)
                }
            }
        }

        evaluateField("spec_id", expected: pins.specId, actual: manifest.specId)
        evaluateField("spec_version", expected: pins.specVersion, actual: manifest.specVersion)
        evaluateField("bundle_version", expected: pins.bundleVersion, actual: manifest.bundleVersion)

        if lifecyclePolicy.versionPinning.requireCompilerVersionPin || pins.compilerVersion != nil {
            evaluateField("compiler_version", expected: pins.compilerVersion, actual: manifest.compilerVersion)
        }
        if lifecyclePolicy.versionPinning.requireSourceHashPin || pins.sourceSHA256 != nil {
            let provenance = try loadSourceProvenance(bundleId: bundleId, manifest: manifest)
            guard !provenance.sourceSHA256.isEmpty else {
                throw GOSRegistryError.sourceProvenanceMissingHash(bundleId: bundleId)
            }
            evaluateField("source_sha256", expected: pins.sourceSHA256, actual: provenance.sourceSHA256)
        }
        if lifecyclePolicy.versionPinning.requireCompiledSpecHashPin || pins.compiledSpecHash != nil {
            let actualSpecHash = try compiledSpecHash(bundleId: bundleId, manifest: manifest)
            evaluateField("compiled_spec_hash", expected: pins.compiledSpecHash, actual: actualSpecHash)
        }
        return (failures, mismatchError)
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
        try validateLifecycleTransition(bundleId: bundleId, from: manifest.lifecycleState, to: state)
        try writeManifest(manifest, replacingLifecycleWith: state, notes: note ?? manifest.notes)

        if clearActiveRegistryPointer {
            let registryURL = registryFileURL(specId: manifest.specId)
            if FileManager.default.fileExists(atPath: registryURL.path) {
                let registryData = try Data(contentsOf: registryURL)
                let registry = try decoder.decode(GOSRegistryEntry.self, from: registryData)
                let normalizedKnown = normalizedKnownBundleIds(registry.knownBundleIds + [bundleId])
                if registry.activeBundleId == bundleId {
                    let updatedRegistry = GOSRegistryEntry(
                        specId: registry.specId,
                        activeBundleId: nil,
                        knownBundleIds: normalizedKnown
                    )
                    try encoder.encode(updatedRegistry).write(to: registryURL)
                } else {
                    let updatedRegistry = GOSRegistryEntry(
                        specId: registry.specId,
                        activeBundleId: registry.activeBundleId,
                        knownBundleIds: normalizedKnown
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

    private func normalizedKnownBundleIds(_ bundleIds: [String]) -> [String] {
        Array(Set(bundleIds)).sorted()
    }

    private func discoverActiveBundleIds(specId: String, knownBundleIds: [String]) throws -> [String] {
        var activeBundleIds: [String] = []
        for knownBundleId in knownBundleIds {
            let knownManifest = try readManifest(bundleId: knownBundleId)
            guard knownManifest.specId == specId else {
                throw GOSRegistryError.bundleSpecMismatch(
                    expectedSpecId: specId,
                    actualSpecId: knownManifest.specId,
                    bundleId: knownBundleId
                )
            }
            if knownManifest.lifecycleState == .active {
                activeBundleIds.append(knownBundleId)
            }
        }
        return activeBundleIds.sorted()
    }

    private func validateLifecycleTransition(
        bundleId: String,
        from: GOSLifecycleState,
        to: GOSLifecycleState
    ) throws {
        if from == to { return }
        let allowed: [GOSLifecycleState]
        switch from {
        case .draft:
            allowed = [.reviewed, .revoked]
        case .reviewed:
            allowed = [.active, .revoked]
        case .active:
            allowed = [.deprecated, .revoked]
        case .deprecated:
            allowed = []
        case .superseded:
            allowed = []
        case .revoked:
            allowed = []
        }
        guard allowed.contains(to) else {
            throw GOSRegistryError.invalidLifecycleTransition(
                bundleId: bundleId,
                fromState: from,
                toState: to,
                allowedToStates: allowed
            )
        }
    }

    private func writeManifest(
        _ manifest: GOSBundleManifest,
        replacingLifecycleWith lifecycleState: GOSLifecycleState,
        notes: String? = nil
    ) throws {
        let updatedManifest = GOSBundleManifest(
            bundleId: manifest.bundleId,
            specId: manifest.specId,
            specVersion: manifest.specVersion,
            bundleVersion: manifest.bundleVersion,
            compilerVersion: manifest.compilerVersion,
            compiledAt: manifest.compiledAt,
            lifecycleState: lifecycleState,
            replacesBundleId: manifest.replacesBundleId,
            compilerReportPath: manifest.compilerReportPath,
            specPath: manifest.specPath,
            sourceProvenancePath: manifest.sourceProvenancePath,
            notes: notes ?? manifest.notes
        )
        try encoder.encode(updatedManifest).write(to: manifestURL(bundleId: manifest.bundleId))
    }
}

private extension Array {
    var onlyElement: Element? {
        count == 1 ? first : nil
    }
}
