import Foundation
import HealthOSCore

public struct AACIResolvedGOSActorView: Codable, Sendable {
    public let actorId: String
    public let semanticRole: String
    public let primitiveFamilies: [String]

    init(binding: GOSPrimitiveBinding) {
        self.actorId = binding.actorId
        self.semanticRole = binding.semanticRole
        self.primitiveFamilies = binding.primitiveFamilies.map(\.rawValue).sorted()
    }
}

public struct AACIResolvedGOSRuntimeView: Codable, Sendable {
    public let specId: String
    public let bundleId: String
    public let workflowTitle: String
    public let usedDefaultBindingPlan: Bool
    public let bindingCount: Int
    public let compilerWarningCount: Int
    public let boundActors: [AACIResolvedGOSActorView]
    private let bindingsByActorId: [String: AACIResolvedGOSActorView]

    init(summary: AACIGOSActivationSummary, metadataTitle: String, bindingPlan: GOSRuntimeBindingPlan) {
        let boundActors = bindingPlan.bindings
            .map(AACIResolvedGOSActorView.init(binding:))
            .sorted { lhs, rhs in
                lhs.actorId < rhs.actorId
            }

        self.specId = summary.specId
        self.bundleId = summary.bundleId
        self.workflowTitle = metadataTitle
        self.usedDefaultBindingPlan = summary.usedDefaultBindingPlan
        self.bindingCount = summary.bindingCount
        self.compilerWarningCount = summary.compilerWarningCount
        self.boundActors = boundActors
        self.bindingsByActorId = Dictionary(uniqueKeysWithValues: boundActors.map { ($0.actorId, $0) })
    }

    public var mediationLabel: String {
        workflowTitle + " [" + specId + "]"
    }

    public var boundActorIds: [String] {
        boundActors.map(\.actorId)
    }

    public var payloadMetadata: [String: String] {
        [
            "gosSpecId": specId,
            "gosBundleId": bundleId,
            "gosWorkflowTitle": workflowTitle,
            "gosUsedDefaultBindingPlan": String(usedDefaultBindingPlan),
            "gosBindingCount": String(bindingCount),
            "gosCompilerWarningCount": String(compilerWarningCount),
            "gosBoundActors": boundActorIds.joined(separator: ",")
        ]
    }

    public func mediationText(base: String, actorId: String) -> String {
        base + " " + runtimeBoundarySummary(for: actorId)
    }

    public func metadataForRuntimePath(actorId: String) -> [String: String] {
        var metadata = payloadMetadata
        metadata["gosRuntimeActorId"] = actorId
        metadata["gosPrimitiveFamilies"] = primitiveFamilies(for: actorId).joined(separator: ",")
        metadata["gosReasoningBoundary"] = runtimeBoundarySummary(for: actorId)
        return metadata
    }

    public func metadataForDraftPath(actorId: String) -> [String: String] {
        metadataForRuntimePath(actorId: actorId)
    }

    public func runtimeBoundarySummary(for actorId: String) -> String {
        let families = primitiveFamilies(for: actorId)
        guard !families.isEmpty else {
            return "Governed workflow \(specId) bundle \(bundleId) active; runtime boundary for \(actorId) is unresolved and remains draft-only under human gate."
        }

        return "Governed workflow \(specId) bundle \(bundleId) active; \(actorId) is bound to primitive families [\(families.joined(separator: ", "))] and remains draft-only under human gate."
    }

    public func actorView(for actorId: String) -> AACIResolvedGOSActorView? {
        bindingsByActorId[actorId]
    }

    public func primitiveFamilies(for actorId: String) -> [String] {
        bindingsByActorId[actorId]?.primitiveFamilies ?? []
    }
}

struct AACIActiveGOSRuntime: Sendable {
    let summary: AACIGOSActivationSummary
    let metadataTitle: String
    let metadataDescription: String?
    let bindingPlan: GOSRuntimeBindingPlan
    let resolvedView: AACIResolvedGOSRuntimeView

    init(
        summary: AACIGOSActivationSummary,
        metadataTitle: String,
        metadataDescription: String?,
        bindingPlan: GOSRuntimeBindingPlan
    ) {
        self.summary = summary
        self.metadataTitle = metadataTitle
        self.metadataDescription = metadataDescription
        self.bindingPlan = bindingPlan
        self.resolvedView = AACIResolvedGOSRuntimeView(
            summary: summary,
            metadataTitle: metadataTitle,
            bindingPlan: bindingPlan
        )
    }

    var mediationLabel: String {
        resolvedView.mediationLabel
    }

    var payloadMetadata: [String: String] {
        resolvedView.payloadMetadata
    }
}
