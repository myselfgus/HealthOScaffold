import Foundation
import HealthOSCore
import HealthOSProviders

public actor AACIOrchestrator {
    private let router: ProviderRouter

    public init(router: ProviderRouter) {
        self.router = router
    }

    public func startSession(_ session: SessaoTrabalho) async -> String {
        let decision = await router.route(taskKind: "session-start")
        return "AACI session \(session.id.uuidString) started via \(decision.providerName)"
    }

    public func transcribe(_ input: TranscriptionInput) async -> TranscriptionOutput {
        switch input.captureMode {
        case .seededText:
            return TranscriptionOutput(
                status: .ready,
                source: "seeded-text",
                transcriptText: input.seededText,
                audioCapture: input.audioCapture
            )
        case .localAudioFile:
            guard let audioCapture = input.audioCapture else {
                return TranscriptionOutput(
                    status: .unavailable,
                    source: "local-audio",
                    issueMessage: "No local audio artifact was available for transcription."
                )
            }
            guard let provider = await router.speechProvider(taskKind: "transcription") else {
                return TranscriptionOutput(
                    status: .unavailable,
                    source: "none",
                    audioCapture: audioCapture,
                    issueMessage: "No local speech provider is registered for the current first-slice environment."
                )
            }

            do {
                let result = try await provider.transcribe(audioURL: audioCapture.reference.fileURL)
                return TranscriptionOutput(
                    status: result.status,
                    source: provider.providerName,
                    transcriptText: result.transcriptText,
                    audioCapture: audioCapture,
                    issueMessage: result.message
                )
            } catch {
                return TranscriptionOutput(
                    status: .degraded,
                    source: provider.providerName,
                    audioCapture: audioCapture,
                    issueMessage: "Local transcription failed: \(error.localizedDescription)"
                )
            }
        }
    }

    public func composeSOAPDraft(
        session: SessaoTrabalho,
        transcription: TranscriptionOutput,
        context: RetrievalContextPackage
    ) async -> SOAPDraftDocument {
        let objective: String
        if context.highlights.isEmpty {
            objective = context.summary
        } else {
            let highlightLines = context.highlights.map { highlight in
                "\(highlight.headline): \(highlight.summary)"
            }
            objective = ([context.summary] + highlightLines).joined(separator: "\n")
        }

        let assessment: String
        switch (transcription.status, context.status) {
        case (.ready, .ready):
            assessment = "Draft assembled with bounded local context; professional review remains required."
        case (_, .degraded):
            assessment = "Draft assembled with degraded bounded context; confirm history directly before any clinical effect."
        case (_, .empty):
            assessment = "Draft assembled without supporting bounded context matches; confirm history directly before any clinical effect."
        case (_, .partial):
            assessment = "Draft assembled with partial bounded context; additional chart review may still be needed."
        case (.degraded, _), (.unavailable, _), (.pending, _):
            assessment = "Draft assembled with explicit transcription degradation; professional review remains required."
        }
        let sections = SOAPNoteSections(
            subjective: transcription.workflowText,
            objective: objective,
            assessment: assessment,
            plan: "TODO"
        )
        let draft = ArtifactDraft(
            sessionId: session.id,
            kind: .soap,
            status: .awaitingGate,
            author: DraftAuthorIdentity(
                actorId: "aaci.draft-composer",
                semanticRole: "draft-composer"
            ),
            payload: sections.payload
        )
        return SOAPDraftDocument(
            draft: draft,
            sections: sections,
            contextStatus: context.status,
            contextSummary: context.summary,
            noteSummary: assessment
        )
    }
}

private func makeBoundary(
    reads: [String],
    writes: [String],
    invokes: [String] = [],
    governanceChecks: [String] = [],
    forbiddenFinalizations: [String] = ["health-act:finalize"]
) -> AgentBoundary {
    AgentBoundary(
        reads: reads,
        writes: writes,
        invokes: invokes,
        governanceChecks: governanceChecks,
        forbiddenFinalizations: forbiddenFinalizations
    )
}

public struct CaptureAgent: HealthAgent {
    public let actorId = "aaci.capture"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "capture-normalizer"
    public let permissions = ["session:read", "capture:write"]
    public let boundaryDescription = "Receives active-session input and emits normalized capture events"
    public let boundary = makeBoundary(reads: ["session-input"], writes: ["capture-events"])
    public let allowedInputKinds = ["session.input", "session.audio.ref"]
    public let emittedOutputKinds = ["capture.event", "audio.ref"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct TranscriptionAgent: HealthAgent {
    public let actorId = "aaci.transcription"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "speech-to-text"
    public let permissions = ["capture:read", "transcript:write"]
    public let boundaryDescription = "Receives audio references and emits transcript fragments"
    public let boundary = makeBoundary(reads: ["audio.ref"], writes: ["transcript.fragment"])
    public let allowedInputKinds = ["audio.ref"]
    public let emittedOutputKinds = ["transcript.fragment", "transcript.artifact.ref"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct IntentionAgent: HealthAgent {
    public let actorId = "aaci.intention"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "operational-intent-classifier"
    public let permissions = ["transcript:read", "intent:write"]
    public let boundaryDescription = "Classifies bounded session material into operational intent labels"
    public let boundary = makeBoundary(reads: ["transcript.fragment", "capture.event"], writes: ["intent.label"])
    public let allowedInputKinds = ["transcript.fragment", "capture.event"]
    public let emittedOutputKinds = ["intent.label", "routing.suggestion"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct ContextRetrievalAgent: HealthAgent {
    public let actorId = "aaci.context"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "bounded-context-retriever"
    public let permissions = ["patient:context:read", "consent:check", "habilitation:check"]
    public let boundaryDescription = "Retrieves bounded patient/service context under lawful session conditions"
    public let boundary = makeBoundary(
        reads: ["patient.context.index", "service.context.index"],
        writes: ["retrieval.summary", "record.ref"],
        governanceChecks: ["consent", "habilitation", "finality"]
    )
    public let allowedInputKinds = ["context.request"]
    public let emittedOutputKinds = ["retrieval.summary", "record.ref"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct DraftComposerAgent: HealthAgent {
    public let actorId = "aaci.draft-composer"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "draft-composer"
    public let permissions = ["draft:write", "transcript:read", "context:read"]
    public let boundaryDescription = "Composes structured drafts from bounded session/context materials"
    public let boundary = makeBoundary(reads: ["transcript.fragment", "retrieval.summary", "intent.label"], writes: ["draft.artifact"])
    public let allowedInputKinds = ["transcript.fragment", "retrieval.summary", "intent.label"]
    public let emittedOutputKinds = ["draft.soap", "draft.note"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct TaskExtractionAgent: HealthAgent {
    public let actorId = "aaci.task-extraction"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "operational-task-extractor"
    public let permissions = ["session:read", "task:write"]
    public let boundaryDescription = "Extracts follow-up tasks and pending operational items"
    public let boundary = makeBoundary(reads: ["session.material", "draft.artifact"], writes: ["task.list"])
    public let allowedInputKinds = ["session.material", "draft.artifact"]
    public let emittedOutputKinds = ["task.list"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct ReferralDraftAgent: HealthAgent {
    public let actorId = "aaci.referral-draft"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "referral-draft-composer"
    public let permissions = ["draft:write", "context:read"]
    public let boundaryDescription = "Structures referral drafts from bounded inputs"
    public let boundary = makeBoundary(reads: ["retrieval.summary", "intent.label", "session.material"], writes: ["draft.referral"])
    public let allowedInputKinds = ["retrieval.summary", "intent.label", "session.material"]
    public let emittedOutputKinds = ["draft.referral"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct PrescriptionDraftAgent: HealthAgent {
    public let actorId = "aaci.prescription-draft"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "prescription-draft-composer"
    public let permissions = ["draft:write", "context:read"]
    public let boundaryDescription = "Structures prescription drafts from bounded inputs"
    public let boundary = makeBoundary(reads: ["retrieval.summary", "intent.label", "session.material"], writes: ["draft.prescription"])
    public let allowedInputKinds = ["retrieval.summary", "intent.label", "session.material"]
    public let emittedOutputKinds = ["draft.prescription"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct NoteOrganizerAgent: HealthAgent {
    public let actorId = "aaci.note-organizer"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "note-organizer"
    public let permissions = ["draft:read", "draft:write"]
    public let boundaryDescription = "Reorganizes note material into clearer structured forms"
    public let boundary = makeBoundary(reads: ["draft.note", "session.material"], writes: ["draft.note"])
    public let allowedInputKinds = ["draft.note", "session.material"]
    public let emittedOutputKinds = ["draft.note"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}

public struct RecordLocatorAgent: HealthAgent {
    public let actorId = "aaci.record-locator"
    public let runtimeKind: RuntimeKind = .aaci
    public let semanticRole = "record-locator"
    public let permissions = ["record:index:read", "consent:check", "habilitation:check"]
    public let boundaryDescription = "Locates candidate records and object references for bounded queries"
    public let boundary = makeBoundary(
        reads: ["record.index"],
        writes: ["record.ref"],
        governanceChecks: ["consent", "habilitation"]
    )
    public let allowedInputKinds = ["record.query"]
    public let emittedOutputKinds = ["record.ref"]

    public init() {}
    public func receive(_ message: AgentMessage) async throws {}
}
