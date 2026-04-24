import Foundation
import HealthOSCore

public enum AACIGOSBindings {
    public static func defaultBindingPlan(specId: String) -> GOSRuntimeBindingPlan {
        GOSRuntimeBindingPlan(
            specId: specId,
            runtimeKind: .aaci,
            bindings: [
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.capture",
                    semanticRole: "capture-normalizer",
                    primitiveFamilies: [.signalSpec, .slotSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.transcription",
                    semanticRole: "speech-to-text",
                    primitiveFamilies: [.signalSpec, .taskSpec, .guardSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.intention",
                    semanticRole: "operational-intent-classifier",
                    primitiveFamilies: [.slotSpec, .derivationSpec, .taskSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.context",
                    semanticRole: "bounded-context-retriever",
                    primitiveFamilies: [.slotSpec, .derivationSpec, .taskSpec, .guardSpec, .scopeRequirementSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.draft-composer",
                    semanticRole: "draft-composer",
                    primitiveFamilies: [.slotSpec, .derivationSpec, .taskSpec, .draftOutputSpec, .humanGateRequirementSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.task-extraction",
                    semanticRole: "operational-task-extractor",
                    primitiveFamilies: [.slotSpec, .taskSpec, .deadlineSpec, .escalationSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.referral-draft",
                    semanticRole: "referral-draft-composer",
                    primitiveFamilies: [.slotSpec, .derivationSpec, .taskSpec, .draftOutputSpec, .humanGateRequirementSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.prescription-draft",
                    semanticRole: "prescription-draft-composer",
                    primitiveFamilies: [.slotSpec, .derivationSpec, .taskSpec, .draftOutputSpec, .humanGateRequirementSpec, .evidenceHookSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.note-organizer",
                    semanticRole: "note-organizer",
                    primitiveFamilies: [.slotSpec, .taskSpec, .draftOutputSpec]
                ),
                GOSPrimitiveBinding(
                    runtimeKind: .aaci,
                    actorId: "aaci.record-locator",
                    semanticRole: "record-locator",
                    primitiveFamilies: [.taskSpec, .scopeRequirementSpec, .evidenceHookSpec]
                )
            ]
        )
    }
}
