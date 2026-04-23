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

    public func composeReferralDraft(
        session: SessaoTrabalho,
        transcription: TranscriptionOutput,
        context: RetrievalContextPackage,
        sourceSOAPDraft: SOAPDraftDocument,
        sourceSOAPDraftRef: StorageObjectRef
    ) async -> ReferralDraftDocument {
        let heuristics = makeDerivedDraftHeuristics(transcription: transcription, context: context)
        let specialtyTarget = referralSpecialtyTarget(from: heuristics)
        let reason = referralReason(from: heuristics)
        let noteSummary: String
        if heuristics.limitedSignal {
            noteSummary = "Referral draft estruturado com sinal clinico bounded limitado; especialidade e urgencia seguem dependentes de revisao humana."
        } else {
            noteSummary = "Referral draft estruturado a partir do mesmo spine documental do SOAP, pronto apenas para futura revisao humana."
        }
        let draftOnlyNote = "Draft only. Este encaminhamento nao foi emitido nem efetivado; permanece apenas como rascunho ligado ao spine da sessao."
        let spineLink = DerivedDraftSpineLink(
            sourceSessionId: session.id,
            sourceSOAPDraftId: sourceSOAPDraft.draft.id,
            sourceSOAPDraftStatus: sourceSOAPDraft.draft.status,
            sourceSOAPDraftObjectPath: sourceSOAPDraftRef.objectPath,
            sourceContextStatus: context.status,
            sourceContextSummary: context.summary
        )
        let draft = ArtifactDraft(
            sessionId: session.id,
            kind: .referral,
            status: .draft,
            author: DraftAuthorIdentity(
                actorId: "aaci.referral-draft",
                semanticRole: "referral-draft-composer"
            ),
            payload: [
                "specialtyTarget": specialtyTarget,
                "reason": reason,
                "contextSummary": context.summary,
                "noteSummary": noteSummary,
                "draftOnlyNote": draftOnlyNote,
                "sourceSOAPDraftId": sourceSOAPDraft.draft.id.uuidString
            ]
        )
        return ReferralDraftDocument(
            draft: draft,
            specialtyTarget: specialtyTarget,
            reason: reason,
            contextSummary: context.summary,
            noteSummary: noteSummary,
            readyForFutureGate: true,
            draftOnlyNote: draftOnlyNote,
            spineLink: spineLink
        )
    }

    public func composePrescriptionDraft(
        session: SessaoTrabalho,
        transcription: TranscriptionOutput,
        context: RetrievalContextPackage,
        sourceSOAPDraft: SOAPDraftDocument,
        sourceSOAPDraftRef: StorageObjectRef
    ) async -> PrescriptionDraftDocument {
        let heuristics = makeDerivedDraftHeuristics(transcription: transcription, context: context)
        let medicationSuggestion = prescriptionMedicationSuggestion(from: heuristics)
        let instructionsDraft = prescriptionInstructions(from: heuristics)
        let rationale = prescriptionRationale(from: heuristics, context: context)
        let noteSummary: String
        if heuristics.limitedSignal {
            noteSummary = "Prescription draft mantido em texto livre e com baixa especificidade por sinal bounded insuficiente."
        } else {
            noteSummary = "Prescription draft em texto livre estruturado a partir do mesmo spine da sessao, sem constituir prescricao efetiva."
        }
        let draftOnlyNote = "Draft only. Esta sugestao medicamentosa nao equivale a prescricao emitida; dose, agente e efetivacao continuam dependentes de revisao humana."
        let spineLink = DerivedDraftSpineLink(
            sourceSessionId: session.id,
            sourceSOAPDraftId: sourceSOAPDraft.draft.id,
            sourceSOAPDraftStatus: sourceSOAPDraft.draft.status,
            sourceSOAPDraftObjectPath: sourceSOAPDraftRef.objectPath,
            sourceContextStatus: context.status,
            sourceContextSummary: context.summary
        )
        let draft = ArtifactDraft(
            sessionId: session.id,
            kind: .prescription,
            status: .draft,
            author: DraftAuthorIdentity(
                actorId: "aaci.prescription-draft",
                semanticRole: "prescription-draft-composer"
            ),
            payload: [
                "medicationSuggestion": medicationSuggestion,
                "instructionsDraft": instructionsDraft,
                "rationale": rationale,
                "contextSummary": context.summary,
                "noteSummary": noteSummary,
                "draftOnlyNote": draftOnlyNote,
                "sourceSOAPDraftId": sourceSOAPDraft.draft.id.uuidString
            ]
        )
        return PrescriptionDraftDocument(
            draft: draft,
            medicationSuggestion: medicationSuggestion,
            instructionsDraft: instructionsDraft,
            rationale: rationale,
            contextSummary: context.summary,
            noteSummary: noteSummary,
            readyForFutureGate: true,
            draftOnlyNote: draftOnlyNote,
            spineLink: spineLink
        )
    }

    private func makeDerivedDraftHeuristics(
        transcription: TranscriptionOutput,
        context: RetrievalContextPackage
    ) -> DerivedDraftHeuristics {
        let sourceValues =
            [transcription.workflowText, context.summary]
            + context.highlights.map(\.summary)
            + context.supportingMatches.map(\.summary)
        let tokens = Set(normalizedTokens(in: sourceValues))
        let categories = Set(context.highlights.map(\.category) + context.supportingMatches.map(\.category))
        return DerivedDraftHeuristics(
            tokens: tokens,
            categories: categories,
            contextStatus: context.status
        )
    }

    private func referralSpecialtyTarget(from heuristics: DerivedDraftHeuristics) -> String {
        if heuristics.hasSleepSignal && heuristics.hasSymptomSignal {
            return "Neurologia / Medicina do Sono"
        }
        if heuristics.hasSleepSignal {
            return "Medicina do Sono"
        }
        if heuristics.hasSymptomSignal {
            return "Neurologia"
        }
        if heuristics.hasAllergySignal {
            return "Alergologia"
        }
        if heuristics.hasMedicationSignal {
            return "Revisao clinica da medicacao"
        }
        return "Especialidade a definir em revisao profissional"
    }

    private func referralReason(from heuristics: DerivedDraftHeuristics) -> String {
        if heuristics.limitedSignal {
            return "Contexto bounded insuficiente para um encaminhamento mais especifico; revisar necessidade e destino clinico manualmente."
        }
        if heuristics.hasSleepSignal && heuristics.hasSymptomSignal {
            return "Persistencia de sintomas com componente de sono associado no encontro atual e no contexto local bounded."
        }
        if heuristics.hasSleepSignal {
            return "Queixa de piora do sono/insônia com suporte no contexto local bounded."
        }
        if heuristics.hasSymptomSignal {
            return "Sintomas ativos relatados no encontro com necessidade potencial de avaliacao especializada."
        }
        if heuristics.hasAllergySignal {
            return "Revisao especializada sugerida por sinal de seguranca/alergia no contexto local bounded."
        }
        return "Rascunho organizacional preparado a partir do mesmo spine da sessao; destino clinico depende de revisao humana."
    }

    private func prescriptionMedicationSuggestion(from heuristics: DerivedDraftHeuristics) -> String {
        if heuristics.limitedSignal {
            return "Sugestao medicamentosa a definir em revisao profissional."
        }
        if heuristics.mentionsMelatonin || heuristics.hasSleepSignal {
            return "Melatonina em texto livre (confirmar agente, dose e adequacao em revisao profissional)."
        }
        if heuristics.hasSymptomSignal {
            return "Medicacao sintomatica para cefaleia/dor em texto livre (confirmar agente e dose em revisao profissional)."
        }
        if heuristics.hasMedicationSignal {
            return "Revisar medicacao atual antes de qualquer nova prescricao."
        }
        return "Sugestao livre de medicacao somente para revisao humana."
    }

    private func prescriptionInstructions(from heuristics: DerivedDraftHeuristics) -> String {
        if heuristics.limitedSignal {
            return "Sem posologia efetiva nesta onda; instrucoes finais dependem de revisao humana."
        }
        if heuristics.mentionsMelatonin || heuristics.hasSleepSignal {
            return "Uso noturno em texto livre; posologia e duracao a definir em revisao profissional."
        }
        if heuristics.hasSymptomSignal {
            return "Uso sintomatico em texto livre; agente, dose e limites dependem de revisao profissional."
        }
        return "Instrucoes nao efetivas; somente base para futura revisao humana."
    }

    private func prescriptionRationale(
        from heuristics: DerivedDraftHeuristics,
        context: RetrievalContextPackage
    ) -> String {
        if heuristics.limitedSignal {
            return "O spine atual nao reuniu sinal suficiente para uma sugestao medicamentosa mais especifica."
        }
        if heuristics.mentionsMelatonin {
            return "O contexto local bounded ja menciona melatonina e sintomas de sono, entao o draft preserva essa pista sem efetivar uma prescricao."
        }
        if heuristics.hasSleepSignal {
            return "A queixa de sono aparece tanto na captura quanto no contexto bounded, justificando uma sugestao livre para revisao humana."
        }
        if heuristics.hasSymptomSignal {
            return "O encontro atual trouxe sintoma ativo; o draft organiza apenas uma sugestao livre de controle sintomatico, sem prescricao efetiva."
        }
        return "Draft estruturado a partir do mesmo contexto bounded: \(context.summary)"
    }
}

private struct DerivedDraftHeuristics {
    let tokens: Set<String>
    let categories: Set<RecordClinicalCategory>
    let contextStatus: RetrievalContextStatus

    var hasSleepSignal: Bool {
        categories.contains(.sleep)
            || tokens.contains(where: { ["sono", "insonia", "dormir", "melatonina"].contains($0) })
    }

    var hasSymptomSignal: Bool {
        categories.contains(.symptom)
            || tokens.contains(where: { ["cefaleia", "dor", "sintoma", "enxaqueca"].contains($0) })
    }

    var hasMedicationSignal: Bool {
        categories.contains(.medication)
            || tokens.contains(where: { ["medicacao", "medicamento", "remedio", "melatonina"].contains($0) })
    }

    var hasAllergySignal: Bool {
        categories.contains(.allergy)
            || tokens.contains(where: { ["alergia", "seguranca"].contains($0) })
    }

    var mentionsMelatonin: Bool {
        tokens.contains("melatonina")
    }

    var limitedSignal: Bool {
        switch contextStatus {
        case .degraded, .empty:
            return true
        case .partial, .ready:
            return tokens.isEmpty
        }
    }
}

private func normalizedTokens(in values: [String]) -> [String] {
    let separators = CharacterSet.alphanumerics.inverted
    return values
        .flatMap {
            $0.folding(options: [.diacriticInsensitive, .caseInsensitive], locale: .current)
                .components(separatedBy: separators)
        }
        .filter { $0.count >= 3 }
        .map { $0.lowercased() }
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
