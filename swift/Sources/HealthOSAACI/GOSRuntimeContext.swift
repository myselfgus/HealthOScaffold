import Foundation
import HealthOSCore

struct AACIActiveGOSRuntime: Sendable {
    let summary: AACIGOSActivationSummary
    let metadataTitle: String
    let metadataDescription: String?
    let bindingPlan: GOSRuntimeBindingPlan

    var mediationLabel: String {
        metadataTitle + " [" + summary.specId + "]"
    }

    var payloadMetadata: [String: String] {
        [
            "gosSpecId": summary.specId,
            "gosBundleId": summary.bundleId,
            "gosWorkflowTitle": metadataTitle,
            "gosUsedDefaultBindingPlan": String(summary.usedDefaultBindingPlan)
        ]
    }
}
