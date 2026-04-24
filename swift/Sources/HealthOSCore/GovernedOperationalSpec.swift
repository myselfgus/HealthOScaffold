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
}

public protocol GOSBundleLoader: Sendable {
    func loadBundle(_ request: GOSLoadRequest) async throws -> GOSCompiledBundle
}

public protocol GOSBundleRegistry: Sendable {
    func lookup(specId: String) async throws -> GOSRegistryEntry?
    func register(_ manifest: GOSBundleManifest) async throws
    func activate(bundleId: String, specId: String) async throws
    func deprecate(bundleId: String, note: String?) async throws
    func revoke(bundleId: String, note: String?) async throws
}
