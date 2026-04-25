import Foundation
import HealthOSCore

public enum AACIGOSRuntimePath: String, Codable, Sendable, CaseIterable {
    case capture
    case transcription
    case contextRetrieval
    case composeSOAP
    case deriveReferral
    case derivePrescription

    public var defaultActorId: String {
        switch self {
        case .capture:
            return "aaci.capture"
        case .transcription:
            return "aaci.transcription"
        case .contextRetrieval:
            return "aaci.context"
        case .composeSOAP:
            return "aaci.draft-composer"
        case .deriveReferral:
            return "aaci.referral-draft"
        case .derivePrescription:
            return "aaci.prescription-draft"
        }
    }

    public var provenanceOperation: String {
        switch self {
        case .capture:
            return "gos.use.capture"
        case .transcription:
            return "gos.use.transcription"
        case .contextRetrieval:
            return "gos.use.context.retrieve"
        case .composeSOAP:
            return "gos.use.compose.soap"
        case .deriveReferral:
            return "gos.use.derive.referral"
        case .derivePrescription:
            return "gos.use.derive.prescription"
        }
    }
}

public enum AACIGOSProvenanceOperationResolver {
    public static let activation = "gos.activate"
    public static let activationFailed = "gos.activate.failed"
    public static let operationPrefix = "gos.use"

    public static func usageOperation(for runtimePath: AACIGOSRuntimePath) -> String {
        runtimePath.provenanceOperation
    }
}

public struct AACIGOSActorBindingLookup: Codable, Sendable {
    public let actorId: String
    public let semanticRole: String
    public let primitiveFamilies: [String]
    public let isBound: Bool
}

public struct AACIGOSMediationContext: Codable, Sendable {
    public let specId: String
    public let bundleId: String
    public let lifecycle: GOSLifecycleState
    public let runtimeKind: RuntimeKind
    public let workflowTitle: String
    public let actorId: String
    public let semanticRole: String
    public let primitiveFamilies: [String]
    public let draftOnly: Bool
    public let gateStillRequired: Bool
    public let coreGateRequired: Bool
    public let legalAuthorizing: Bool
    public let provenanceOperationPrefix: String
    public let resolvedProvenanceOperation: String?
    public let mediationSummaryBounded: String
    public let actorBound: Bool
    public let boundActorIds: [String]
    public let bindingCount: Int
    public let usedDefaultBindingPlan: Bool
    public let compilerWarningCount: Int

    public var payloadMetadata: [String: String] {
        [
            "gosSpecId": specId,
            "gosBundleId": bundleId,
            "gosLifecycle": lifecycle.rawValue,
            "gosWorkflowTitle": workflowTitle,
            "gosBindingPlanRuntimeKind": runtimeKind.rawValue,
            "gosBindingCount": String(bindingCount),
            "gosRuntimeActorId": actorId,
            "gosActorSemanticRole": semanticRole,
            "gosPrimitiveFamilies": primitiveFamilies.joined(separator: ","),
            "gosActorBound": String(actorBound),
            "gosDraftOutputBound": String(primitiveFamilies.contains(GOSBindingPrimitiveFamily.draftOutputSpec.rawValue)),
            "gosGateRequiredByBinding": String(gateStillRequired),
            "gosCoreGateRequired": String(coreGateRequired),
            "gosDraftOnly": String(draftOnly),
            "gosLegalAuthorizing": String(legalAuthorizing),
            "gosMediationOperationPrefix": provenanceOperationPrefix,
            "gosMediationOperation": resolvedProvenanceOperation ?? "",
            "gosReasoningBoundary": mediationSummaryBounded,
            "gosUsedDefaultBindingPlan": String(usedDefaultBindingPlan),
            "gosCompilerWarningCount": String(compilerWarningCount),
            "gosBoundActors": boundActorIds.joined(separator: ",")
        ]
    }
}

public enum AACIGOSRuntimeResolverError: Error, LocalizedError, Equatable, Sendable {
    case actorBindingMissing(actorId: String)

    public var errorDescription: String? {
        switch self {
        case let .actorBindingMissing(actorId):
            return "No GOS runtime binding is available for actor \(actorId)."
        }
    }
}

public enum AACIGOSRuntimeResolver {
    public static func runtimePath(for actorId: String) -> AACIGOSRuntimePath? {
        AACIGOSRuntimePath.allCases.first(where: { $0.defaultActorId == actorId })
    }

    public static func resolveActorBinding(
        actorId: String,
        runtimeView: AACIResolvedGOSRuntimeView?,
        required: Bool = false
    ) throws -> AACIGOSActorBindingLookup? {
        guard let runtimeView else { return nil }
        guard let actorView = runtimeView.actorView(for: actorId) else {
            if required {
                throw AACIGOSRuntimeResolverError.actorBindingMissing(actorId: actorId)
            }
            return AACIGOSActorBindingLookup(
                actorId: actorId,
                semanticRole: "unbound",
                primitiveFamilies: [],
                isBound: false
            )
        }
        return AACIGOSActorBindingLookup(
            actorId: actorId,
            semanticRole: actorView.semanticRole,
            primitiveFamilies: actorView.primitiveFamilies,
            isBound: true
        )
    }

    public static func resolveMediationContext(
        actorId: String,
        runtimePath: AACIGOSRuntimePath?,
        runtimeView: AACIResolvedGOSRuntimeView?
    ) -> AACIGOSMediationContext? {
        guard let runtimeView else { return nil }
        let actorBinding = (try? resolveActorBinding(actorId: actorId, runtimeView: runtimeView)) ?? nil
        let flags = runtimeView.mediationFlags(for: actorId)
        return AACIGOSMediationContext(
            specId: runtimeView.specId,
            bundleId: runtimeView.bundleId,
            lifecycle: runtimeView.lifecycle,
            runtimeKind: runtimeView.bindingPlanRuntimeKind,
            workflowTitle: runtimeView.workflowTitle,
            actorId: actorId,
            semanticRole: actorBinding?.semanticRole ?? "unbound",
            primitiveFamilies: actorBinding?.primitiveFamilies ?? [],
            draftOnly: flags.draftOnly,
            gateStillRequired: flags.requiresHumanGateByBinding,
            coreGateRequired: flags.coreGateRequired,
            legalAuthorizing: false,
            provenanceOperationPrefix: AACIGOSProvenanceOperationResolver.operationPrefix,
            resolvedProvenanceOperation: runtimePath.map(AACIGOSProvenanceOperationResolver.usageOperation),
            mediationSummaryBounded: runtimeView.runtimeBoundarySummary(for: actorId),
            actorBound: actorBinding?.isBound ?? false,
            boundActorIds: runtimeView.boundActorIds,
            bindingCount: runtimeView.bindingCount,
            usedDefaultBindingPlan: runtimeView.usedDefaultBindingPlan,
            compilerWarningCount: runtimeView.compilerWarningCount
        )
    }
}
