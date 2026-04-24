import Foundation
import HealthOSCore

public struct AACIGOSActivationSummary: Codable, Sendable {
    public let specId: String
    public let bundleId: String
    public let lifecycleState: GOSLifecycleState
    public let bindingCount: Int
    public let actorIds: [String]
    public let usedDefaultBindingPlan: Bool
    public let compilerWarningCount: Int

    public init(
        specId: String,
        bundleId: String,
        lifecycleState: GOSLifecycleState,
        bindingCount: Int,
        actorIds: [String],
        usedDefaultBindingPlan: Bool,
        compilerWarningCount: Int
    ) {
        self.specId = specId
        self.bundleId = bundleId
        self.lifecycleState = lifecycleState
        self.bindingCount = bindingCount
        self.actorIds = actorIds
        self.usedDefaultBindingPlan = usedDefaultBindingPlan
        self.compilerWarningCount = compilerWarningCount
    }
}

public extension AACIOrchestrator {
    func activateGOS(specId: String, loader: any GOSBundleLoader) async throws -> AACIGOSActivationSummary {
        let bundle = try await loader.loadBundle(GOSLoadRequest(specId: specId, runtimeKind: .aaci, acceptedLifecycleStates: [.active]))
        let bindingPlan = bundle.runtimeBindingPlan ?? AACIGOSBindings.defaultBindingPlan(specId: specId)
        let usedDefaultBindingPlan = bundle.runtimeBindingPlan == nil

        let summary = AACIGOSActivationSummary(
            specId: bundle.manifest.specId,
            bundleId: bundle.manifest.bundleId,
            lifecycleState: bundle.manifest.lifecycleState,
            bindingCount: bindingPlan.bindings.count,
            actorIds: bindingPlan.bindings.map(\.actorId).sorted(),
            usedDefaultBindingPlan: usedDefaultBindingPlan,
            compilerWarningCount: bundle.compilerReport.warnings.count
        )

        installActiveGOSRuntime(
            AACIActiveGOSRuntime(
                summary: summary,
                metadataTitle: bundle.metadata.title,
                metadataDescription: bundle.metadata.description,
                bindingPlan: bindingPlan
            )
        )

        return summary
    }
}
