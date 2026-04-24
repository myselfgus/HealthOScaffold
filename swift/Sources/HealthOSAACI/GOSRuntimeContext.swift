import Foundation
import HealthOSCore

struct AACIResolvedGOSRuntimeView: Sendable {
    let specId: String
    let bundleId: String
    let workflowTitle: String
    let usedDefaultBindingPlan: Bool
    private let bindingsByActorId: [String: GOSPrimitiveBinding]

    init(summary: AACIGOSActivationSummary, metadataTitle: String, bindingPlan: GOSRuntimeBindingPlan) {
        self.specId = summary.specId
        self.bundleId = summary.bundleId
        self.workflowTitle = metadataTitle
        self.usedDefaultBindingPlan = summary.usedDefaultBindingPlan
        self.bindingsByActorId = Dictionary(uniqueKeysWithValues: bindingPlan.bindings.map { ($0.actorId, $0) })
    }

    var mediationLabel: String {
        workflowTitle + " [" + specId + "]"
    }

    var boundActorIds: [String] {
        bindingsByActorId.keys.sorted()
    }

    var payloadMetadata: [String: String] {
        [
            "gosSpecId": specId,
            "gosBundleId": bundleId,
            "gosWorkflowTitle": workflowTitle,
            "gosUsedDefaultBindingPlan": String(usedDefaultBindingPlan),
            "gosBoundActors": boundActorIds.joined(separator: ",")
        ]
    }

    func mediationText(base: String, actorId: String) -> String {
        base + " " + runtimeBoundarySummary(for: actorId)
    }

    func metadataForDraftPath(actorId: String) -> [String: String] {
        var metadata = payloadMetadata
        metadata["gosRuntimeActorId"] = actorId
        metadata["gosPrimitiveFamilies"] = primitiveFamilies(for: actorId).joined(separator: ",")
        metadata["gosReasoningBoundary"] = runtimeBoundarySummary(for: actorId)
        return metadata
    }

    func runtimeBoundarySummary(for actorId: String) -> String {
        let families = primitiveFamilies(for: actorId)
        guard !families.isEmpty else {
            return "Governed workflow \(specId) bundle \(bundleId) active; runtime boundary for \(actorId) is unresolved and remains draft-only under human gate."
        }

        return "Governed workflow \(specId) bundle \(bundleId) active; \(actorId) is bound to primitive families [\(families.joined(separator: ", "))] and remains draft-only under human gate."
    }

    func primitiveFamilies(for actorId: String) -> [String] {
        guard let binding = bindingsByActorId[actorId] else { return [] }
        return binding.primitiveFamilies.map(\.rawValue).sorted()
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
