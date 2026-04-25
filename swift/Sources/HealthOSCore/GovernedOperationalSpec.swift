import Foundation

public enum GOSSpecFamily: String, Codable, Sendable {
    case workflow
    case policy
    case document
    case serviceRule = "service_rule"
    case operationalBundle = "operational_bundle"
}

public enum GOSLifecycleState: String, Codable, Sendable {
    case draft
    case reviewed
    case active
    case deprecated
    case superseded
    case revoked
}

public enum GOSBindingPrimitiveFamily: String, Codable, Sendable {
    case signalSpec = "signal_spec"
    case slotSpec = "slot_spec"
    case derivationSpec = "derivation_spec"
    case taskSpec = "task_spec"
    case toolBindingSpec = "tool_binding_spec"
    case draftOutputSpec = "draft_output_spec"
    case guardSpec = "guard_spec"
    case deadlineSpec = "deadline_spec"
    case evidenceHookSpec = "evidence_hook_spec"
    case humanGateRequirementSpec = "human_gate_requirement_spec"
    case escalationSpec = "escalation_spec"
    case scopeRequirementSpec = "scope_requirement_spec"
}

public enum GOSLoaderFailure: String, Codable, Sendable {
    case bundleNotFound = "bundle_not_found"
    case bundleInactive = "bundle_inactive"
    case bundleRevoked = "bundle_revoked"
    case bundleIntegrityFailure = "bundle_integrity_failure"
    case bundleValidationFailure = "bundle_validation_failure"
    case bundleRegistryFailure = "bundle_registry_failure"
}

public enum GOSRegistryError: Error, Sendable {
    case registryMissing(specId: String)
    case registryEntryDecodeFailure(specId: String)
    case bundleNotFound(bundleId: String)
    case manifestMissing(bundleId: String)
    case specMissing(bundleId: String, path: String)
    case compilerReportMissing(bundleId: String, path: String)
    case sourceProvenanceMissing(bundleId: String, path: String)
    case registryBundleMissing(specId: String, bundleId: String)
    case registrySpecMismatch(expectedSpecId: String, actualSpecId: String)
    case bundleSpecMismatch(expectedSpecId: String, actualSpecId: String, bundleId: String)
    case activationRequiresReviewedOrActive(bundleId: String, lifecycleState: GOSLifecycleState)
    case activationRequiresReviewRecord(bundleId: String)
    case bundleRevoked(bundleId: String)
    case bundleDeprecated(bundleId: String)
    case lifecycleStateNotAccepted(bundleId: String, state: GOSLifecycleState, accepted: [GOSLifecycleState])
    case compilerReportInvalid(bundleId: String)
    case runtimeBindingPlanInvalid(bundleId: String, expectedSpecId: String, expectedRuntimeKind: RuntimeKind)
    case metadataMissing(bundleId: String)
    case manifestDecodeFailure(bundleId: String)
    case compilerReportDecodeFailure(bundleId: String)
    case reviewRecordDecodeFailure(bundleId: String)
    case reviewRecordsDecodeFailure(bundleId: String)
    case reviewRejectedForLifecycle(bundleId: String, lifecycleState: GOSLifecycleState)
    case reviewPolicyNotSatisfied(bundleId: String, failures: [GOSPolicyFailure])
    case activationPolicyNotSatisfied(bundleId: String, failures: [GOSPolicyFailure])
    case reviewRationaleRequired(bundleId: String)
    case activationRationaleRequired(bundleId: String)
    case insufficientIndependentReviews(bundleId: String, required: Int, actual: Int)
    case separationOfDutiesViolation(bundleId: String, actorId: String)
    case reviewCompilerReportInvalid(bundleId: String)
    case activationPinMismatch(bundleId: String, field: String, expected: String, actual: String)
    case sourceProvenanceDecodeFailure(bundleId: String)
    case sourceProvenanceMissingHash(bundleId: String)
    case registryMissingActivePointer(specId: String, activeBundleId: String)
    case multipleActiveBundles(specId: String, bundleIds: [String])
    case invalidLifecycleTransition(bundleId: String, fromState: GOSLifecycleState, toState: GOSLifecycleState, allowedToStates: [GOSLifecycleState])
    case invalidActivationState(specId: String, detail: String)
    case invalidBundleState(bundleId: String, state: GOSLifecycleState, expected: [GOSLifecycleState])
}

public struct GOSLoadTypedError: Error, Sendable {
    public let failure: GOSLoaderFailure
    public let registryError: GOSRegistryError?
    public let message: String

    public init(
        failure: GOSLoaderFailure,
        registryError: GOSRegistryError? = nil,
        message: String
    ) {
        self.failure = failure
        self.registryError = registryError
        self.message = message
    }
}

public extension GOSRegistryError {
    var loaderFailure: GOSLoaderFailure {
        switch self {
        case .bundleNotFound,
             .manifestMissing,
             .specMissing,
             .compilerReportMissing,
             .sourceProvenanceMissing,
             .registryBundleMissing,
             .registryMissingActivePointer:
            return .bundleNotFound
        case .bundleRevoked,
             .bundleDeprecated,
             .lifecycleStateNotAccepted:
            return .bundleInactive
        case .compilerReportInvalid,
             .reviewCompilerReportInvalid,
             .runtimeBindingPlanInvalid,
             .metadataMissing,
             .manifestDecodeFailure,
             .compilerReportDecodeFailure,
             .reviewRecordDecodeFailure,
             .reviewRecordsDecodeFailure,
             .sourceProvenanceDecodeFailure,
             .sourceProvenanceMissingHash:
            return .bundleValidationFailure
        case .registryMissing,
             .registryEntryDecodeFailure,
             .registrySpecMismatch,
             .bundleSpecMismatch,
             .multipleActiveBundles:
            return .bundleRegistryFailure
        case .activationRequiresReviewedOrActive,
             .activationRequiresReviewRecord,
             .reviewRejectedForLifecycle,
             .reviewPolicyNotSatisfied,
             .activationPolicyNotSatisfied,
             .reviewRationaleRequired,
             .activationRationaleRequired,
             .insufficientIndependentReviews,
             .separationOfDutiesViolation,
             .activationPinMismatch,
             .invalidLifecycleTransition,
             .invalidActivationState,
             .invalidBundleState:
            return .bundleIntegrityFailure
        }
    }
}

public struct GOSSourceReference: Codable, Sendable {
    public let kind: String
    public let reference: String
    public let version: String?

    public init(kind: String, reference: String, version: String? = nil) {
        self.kind = kind
        self.reference = reference
        self.version = version
    }
}

public struct GOSMetadata: Codable, Sendable {
    public let title: String
    public let description: String?
    public let status: GOSLifecycleState
    public let authoringForm: String
    public let compiledForm: String?
    public let sourceReferences: [GOSSourceReference]
    public let tags: [String]

    public init(
        title: String,
        description: String? = nil,
        status: GOSLifecycleState,
        authoringForm: String,
        compiledForm: String? = nil,
        sourceReferences: [GOSSourceReference] = [],
        tags: [String] = []
    ) {
        self.title = title
        self.description = description
        self.status = status
        self.authoringForm = authoringForm
        self.compiledForm = compiledForm
        self.sourceReferences = sourceReferences
        self.tags = tags
    }
}

public struct GOSPrimitiveBinding: Codable, Sendable {
    public let runtimeKind: RuntimeKind
    public let actorId: String
    public let semanticRole: String
    public let primitiveFamilies: [GOSBindingPrimitiveFamily]

    public init(
        runtimeKind: RuntimeKind,
        actorId: String,
        semanticRole: String,
        primitiveFamilies: [GOSBindingPrimitiveFamily]
    ) {
        self.runtimeKind = runtimeKind
        self.actorId = actorId
        self.semanticRole = semanticRole
        self.primitiveFamilies = primitiveFamilies
    }

    enum CodingKeys: String, CodingKey {
        case runtimeKind = "runtime_kind"
        case actorId = "actor_id"
        case semanticRole = "semantic_role"
        case primitiveFamilies = "primitive_families"
    }
}

public struct GOSRuntimeBindingPlan: Codable, Sendable {
    public let specId: String
    public let runtimeKind: RuntimeKind
    public let bindings: [GOSPrimitiveBinding]

    public init(specId: String, runtimeKind: RuntimeKind, bindings: [GOSPrimitiveBinding]) {
        self.specId = specId
        self.runtimeKind = runtimeKind
        self.bindings = bindings
    }

    enum CodingKeys: String, CodingKey {
        case specId = "spec_id"
        case runtimeKind = "runtime_kind"
        case bindings
    }
}

public struct GOSBundleManifest: Codable, Sendable {
    public let bundleId: String
    public let specId: String
    public let specVersion: String
    public let bundleVersion: String
    public let compilerVersion: String
    public let compiledAt: Date?
    public let lifecycleState: GOSLifecycleState
    public let replacesBundleId: String?
    public let compilerReportPath: String?
    public let specPath: String?
    public let sourceProvenancePath: String?
    public let notes: String?

    public init(
        bundleId: String,
        specId: String,
        specVersion: String,
        bundleVersion: String,
        compilerVersion: String,
        compiledAt: Date? = nil,
        lifecycleState: GOSLifecycleState,
        replacesBundleId: String? = nil,
        compilerReportPath: String? = nil,
        specPath: String? = nil,
        sourceProvenancePath: String? = nil,
        notes: String? = nil
    ) {
        self.bundleId = bundleId
        self.specId = specId
        self.specVersion = specVersion
        self.bundleVersion = bundleVersion
        self.compilerVersion = compilerVersion
        self.compiledAt = compiledAt
        self.lifecycleState = lifecycleState
        self.replacesBundleId = replacesBundleId
        self.compilerReportPath = compilerReportPath
        self.specPath = specPath
        self.sourceProvenancePath = sourceProvenancePath
        self.notes = notes
    }

    enum CodingKeys: String, CodingKey {
        case bundleId = "bundle_id"
        case specId = "spec_id"
        case specVersion = "spec_version"
        case bundleVersion = "bundle_version"
        case compilerVersion = "compiler_version"
        case compiledAt = "compiled_at"
        case lifecycleState = "lifecycle_state"
        case replacesBundleId = "replaces_bundle_id"
        case compilerReportPath = "compiler_report_path"
        case specPath = "spec_path"
        case sourceProvenancePath = "source_provenance_path"
        case notes
    }
}

public struct GOSCompilerWarningRecord: Codable, Sendable {
    public let code: String
    public let message: String

    public init(code: String, message: String) {
        self.code = code
        self.message = message
    }
}

public struct GOSCompilerReportRecord: Codable, Sendable {
    public let parseOK: Bool
    public let structuralOK: Bool
    public let crossReferenceOK: Bool
    public let warnings: [GOSCompilerWarningRecord]

    public init(
        parseOK: Bool,
        structuralOK: Bool,
        crossReferenceOK: Bool,
        warnings: [GOSCompilerWarningRecord] = []
    ) {
        self.parseOK = parseOK
        self.structuralOK = structuralOK
        self.crossReferenceOK = crossReferenceOK
        self.warnings = warnings
    }

    enum CodingKeys: String, CodingKey {
        case parseOK = "parse_ok"
        case structuralOK = "structural_ok"
        case crossReferenceOK = "cross_reference_ok"
        case warnings
    }
}

public struct GOSCompiledBundle: Codable, Sendable {
    public let manifest: GOSBundleManifest
    public let metadata: GOSMetadata
    public let compilerReport: GOSCompilerReportRecord
    public let runtimeBindingPlan: GOSRuntimeBindingPlan?
    public let compiledSpecJSON: Data

    public init(
        manifest: GOSBundleManifest,
        metadata: GOSMetadata,
        compilerReport: GOSCompilerReportRecord,
        runtimeBindingPlan: GOSRuntimeBindingPlan? = nil,
        compiledSpecJSON: Data
    ) {
        self.manifest = manifest
        self.metadata = metadata
        self.compilerReport = compilerReport
        self.runtimeBindingPlan = runtimeBindingPlan
        self.compiledSpecJSON = compiledSpecJSON
    }
}

public struct GOSLoadRequest: Codable, Sendable {
    public let specId: String
    public let runtimeKind: RuntimeKind
    public let acceptedLifecycleStates: [GOSLifecycleState]

    public init(
        specId: String,
        runtimeKind: RuntimeKind,
        acceptedLifecycleStates: [GOSLifecycleState] = [.active]
    ) {
        self.specId = specId
        self.runtimeKind = runtimeKind
        self.acceptedLifecycleStates = acceptedLifecycleStates
    }

    enum CodingKeys: String, CodingKey {
        case specId = "spec_id"
        case runtimeKind = "runtime_kind"
        case acceptedLifecycleStates = "accepted_lifecycle_states"
    }
}

public struct GOSRegistryEntry: Codable, Sendable {
    public let specId: String
    public let activeBundleId: String?
    public let knownBundleIds: [String]

    public init(specId: String, activeBundleId: String? = nil, knownBundleIds: [String] = []) {
        self.specId = specId
        self.activeBundleId = activeBundleId
        self.knownBundleIds = knownBundleIds
    }

    enum CodingKeys: String, CodingKey {
        case specId = "spec_id"
        case activeBundleId = "active_bundle_id"
        case knownBundleIds = "known_bundle_ids"
    }
}

public struct GOSBundleReviewRecord: Codable, Sendable, Identifiable {
    public let id: UUID
    public let specId: String
    public let bundleId: String
    public let reviewerId: String
    public let reviewerRole: String
    public let rationale: String
    public let reviewedAt: Date

    public init(
        id: UUID = UUID(),
        specId: String,
        bundleId: String,
        reviewerId: String,
        reviewerRole: String,
        rationale: String,
        reviewedAt: Date = .now
    ) {
        self.id = id
        self.specId = specId
        self.bundleId = bundleId
        self.reviewerId = reviewerId
        self.reviewerRole = reviewerRole
        self.rationale = rationale
        self.reviewedAt = reviewedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case specId = "spec_id"
        case bundleId = "bundle_id"
        case reviewerId = "reviewer_id"
        case reviewerRole = "reviewer_role"
        case rationale
        case reviewedAt = "reviewed_at"
    }
}

public struct GOSSourceProvenanceRecord: Codable, Sendable {
    public let sourceSHA256: String
    public let sourceReference: String?

    public init(sourceSHA256: String, sourceReference: String? = nil) {
        self.sourceSHA256 = sourceSHA256
        self.sourceReference = sourceReference
    }

    enum CodingKeys: String, CodingKey {
        case sourceSHA256 = "source_sha256"
        case sourceReference = "source_reference"
    }
}

public struct GOSVersionPinningPolicy: Codable, Sendable {
    public let requirePins: Bool
    public let requireSourceHashPin: Bool
    public let requireCompiledSpecHashPin: Bool
    public let requireCompilerVersionPin: Bool

    public init(
        requirePins: Bool = false,
        requireSourceHashPin: Bool = false,
        requireCompiledSpecHashPin: Bool = false,
        requireCompilerVersionPin: Bool = false
    ) {
        self.requirePins = requirePins
        self.requireSourceHashPin = requireSourceHashPin
        self.requireCompiledSpecHashPin = requireCompiledSpecHashPin
        self.requireCompilerVersionPin = requireCompilerVersionPin
    }
}

public struct GOSReviewPolicy: Codable, Sendable {
    public let minimumApprovals: Int
    public let requireRationale: Bool
    public let compilerReportMustPass: Bool

    public init(
        minimumApprovals: Int = 1,
        requireRationale: Bool = true,
        compilerReportMustPass: Bool = true
    ) {
        self.minimumApprovals = max(1, minimumApprovals)
        self.requireRationale = requireRationale
        self.compilerReportMustPass = compilerReportMustPass
    }
}

public struct GOSLifecyclePolicy: Codable, Sendable {
    public let review: GOSReviewPolicy
    public let enforceSeparationOfDuties: Bool
    public let activationRequiresCompilerReportPass: Bool
    public let versionPinning: GOSVersionPinningPolicy

    public init(
        review: GOSReviewPolicy = GOSReviewPolicy(),
        enforceSeparationOfDuties: Bool = false,
        activationRequiresCompilerReportPass: Bool = true,
        versionPinning: GOSVersionPinningPolicy = GOSVersionPinningPolicy()
    ) {
        self.review = review
        self.enforceSeparationOfDuties = enforceSeparationOfDuties
        self.activationRequiresCompilerReportPass = activationRequiresCompilerReportPass
        self.versionPinning = versionPinning
    }

    public static let `default` = GOSLifecyclePolicy()
}

public struct GOSActivationPins: Codable, Sendable {
    public let specId: String?
    public let specVersion: String?
    public let bundleVersion: String?
    public let sourceSHA256: String?
    public let compilerVersion: String?
    public let compiledSpecHash: String?

    public init(
        specId: String? = nil,
        specVersion: String? = nil,
        bundleVersion: String? = nil,
        sourceSHA256: String? = nil,
        compilerVersion: String? = nil,
        compiledSpecHash: String? = nil
    ) {
        self.specId = specId
        self.specVersion = specVersion
        self.bundleVersion = bundleVersion
        self.sourceSHA256 = sourceSHA256
        self.compilerVersion = compilerVersion
        self.compiledSpecHash = compiledSpecHash
    }

    enum CodingKeys: String, CodingKey {
        case specId = "spec_id"
        case specVersion = "spec_version"
        case bundleVersion = "bundle_version"
        case sourceSHA256 = "source_sha256"
        case compilerVersion = "compiler_version"
        case compiledSpecHash = "compiled_spec_hash"
    }
}

public enum GOSPolicyFailure: String, Codable, Sendable {
    case rationaleMissing = "rationale_missing"
    case compilerReportInvalid = "compiler_report_invalid"
    case insufficientReviews = "insufficient_reviews"
    case insufficientIndependentReviews = "insufficient_independent_reviews"
    case separationOfDutiesViolation = "separation_of_duties_violation"
    case pinMismatch = "pin_mismatch"
    case requiredPinMissing = "required_pin_missing"
}

public enum GOSLifecycleAuditAction: String, Codable, Sendable {
    case registered
    case reviewSubmitted = "review_submitted"
    case reviewDeniedPolicy = "review_denied_policy"
    case reviewed
    case activationRequested = "activation_requested"
    case activationDeniedPolicy = "activation_denied_policy"
    case activated
    case deprecated
    case revoked
}

public struct GOSLifecycleAuditRecord: Codable, Sendable, Identifiable {
    public let id: UUID
    public let specId: String
    public let bundleId: String
    public let action: GOSLifecycleAuditAction
    public let actorId: String
    public let actorRole: String
    public let rationale: String?
    public let fromState: GOSLifecycleState?
    public let toState: GOSLifecycleState
    public let recordedAt: Date

    public init(
        id: UUID = UUID(),
        specId: String,
        bundleId: String,
        action: GOSLifecycleAuditAction,
        actorId: String,
        actorRole: String,
        rationale: String? = nil,
        fromState: GOSLifecycleState? = nil,
        toState: GOSLifecycleState,
        recordedAt: Date = .now
    ) {
        self.id = id
        self.specId = specId
        self.bundleId = bundleId
        self.action = action
        self.actorId = actorId
        self.actorRole = actorRole
        self.rationale = rationale
        self.fromState = fromState
        self.toState = toState
        self.recordedAt = recordedAt
    }

    enum CodingKeys: String, CodingKey {
        case id
        case specId = "spec_id"
        case bundleId = "bundle_id"
        case action
        case actorId = "actor_id"
        case actorRole = "actor_role"
        case rationale
        case fromState = "from_state"
        case toState = "to_state"
        case recordedAt = "recorded_at"
    }
}

public struct GOSReviewResult: Codable, Sendable {
    public let reviewRecord: GOSBundleReviewRecord
    public let lifecycleAuditRecord: GOSLifecycleAuditRecord

    public init(reviewRecord: GOSBundleReviewRecord, lifecycleAuditRecord: GOSLifecycleAuditRecord) {
        self.reviewRecord = reviewRecord
        self.lifecycleAuditRecord = lifecycleAuditRecord
    }
}

public struct GOSActivationResult: Codable, Sendable {
    public let specId: String
    public let bundleId: String
    public let fromState: GOSLifecycleState
    public let toState: GOSLifecycleState
    public let lifecycleAuditRecord: GOSLifecycleAuditRecord

    public init(
        specId: String,
        bundleId: String,
        fromState: GOSLifecycleState,
        toState: GOSLifecycleState,
        lifecycleAuditRecord: GOSLifecycleAuditRecord
    ) {
        self.specId = specId
        self.bundleId = bundleId
        self.fromState = fromState
        self.toState = toState
        self.lifecycleAuditRecord = lifecycleAuditRecord
    }
}

public protocol GOSBundleLoader: Sendable {
    func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle
}

public protocol GOSBundleRegistry: Sendable {
    func lookup(specId: String) async throws -> GOSRegistryEntry?
    func register(_ manifest: GOSBundleManifest) async throws
    func review(bundleId: String, specId: String, reviewerId: String, reviewerRole: String, rationale: String) async throws -> GOSBundleReviewRecord
    func activate(bundleId: String, specId: String) async throws
    func deprecate(bundleId: String, note: String?) async throws
    func revoke(bundleId: String, note: String?) async throws
}
