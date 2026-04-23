import Foundation
import Observation
import HealthOSCore
import HealthOSFirstSliceSupport

@MainActor
@Observable
final class ScribeFirstSliceViewModel {
    enum SessionSurfaceState: String {
        case idle
        case opening
        case active
        case degraded
        case closed
        case failed
    }

    enum RuntimeSurfaceHealth: String {
        case unknown
        case healthy
        case degraded
        case failed
    }

    enum DegradedMode: String {
        case none
        case transcriptionDegraded = "transcription_degraded"
        case retrievalDegraded = "retrieval_degraded"
        case partialResults = "partial_results"
    }

    let smokeTestMode = ProcessInfo.processInfo.arguments.contains("--smoke-test")
        || ProcessInfo.processInfo.arguments.contains("--smoke-test-audio")
    let audioSmokeTestMode = ProcessInfo.processInfo.arguments.contains("--smoke-test-audio")

    var professionalToken = ""
    var serviceName = ""
    var availablePatients: [Usuario] = []
    var selectedPatientID: UUID?
    var captureMode: CaptureMode = .seededText
    var captureText = "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."
    var selectedAudioCapture: AudioCaptureReference?
    var isImportingAudio = false

    var sessionState: SessionSurfaceState = .idle
    var runtimeHealth: RuntimeSurfaceHealth = .unknown
    var degradedMode: DegradedMode = .none
    var lastDisposition: HealthOSCommandDisposition?
    var issues: [HealthOSIssue] = []
    var sessionId: UUID?
    var bridgeState: ScribeSessionBridgeState?
    var lastAction = "bootstrap pending"
    var isBusy = false
    var didLoad = false

    @ObservationIgnored
    private var facade: (any ScribeFirstSliceFacade)?

    @ObservationIgnored
    private var professional: Usuario?

    @ObservationIgnored
    private var service: Servico?

    var selectedPatient: Usuario? {
        availablePatients.first { $0.id == selectedPatientID }
    }

    var captureInputReady: Bool {
        switch captureMode {
        case .seededText:
            return !captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
        case .localAudioFile:
            return selectedAudioCapture != nil
        }
    }

    var canStartSession: Bool {
        facade != nil && !isBusy && sessionId == nil
    }

    var canSelectPatient: Bool {
        !isBusy && sessionId != nil && selectedPatient != nil
    }

    var canSubmitCapture: Bool {
        !isBusy && sessionId != nil && captureInputReady
    }

    var canRequestDraftPreview: Bool {
        !isBusy && sessionId != nil && captureInputReady
    }

    var canResolveGate: Bool {
        !isBusy && sessionId != nil && captureInputReady
    }

    var selectedAudioLabel: String {
        selectedAudioCapture?.displayName ?? "Nenhum arquivo de audio selecionado."
    }

    var transcriptionStatusText: String {
        bridgeState?.transcription.status.rawValue ?? "pending"
    }

    var transcriptionSourceText: String {
        bridgeState?.transcription.source ?? "not-started"
    }

    var finalSummaryText: String {
        guard let state = bridgeState else {
            return "Sem documento final ainda."
        }
        let summary = state.finalDocument.summary
        if let finalPath = state.finalDocument.objectPath {
            return "\(summary) Caminho: \(finalPath)"
        }
        return summary
    }

    var gateReviewSummaryText: String {
        guard let gateReview = bridgeState?.gateReview else {
            return "Nenhuma revisão de gate visível ainda."
        }

        return [
            "state: \(gateReview.state.rawValue)",
            "review_type: \(gateReview.requiredReviewType?.rawValue ?? "none")",
            "target: \(gateReview.finalizationTarget?.rawValue ?? "none")",
            "action: \(gateReview.requestedAction ?? "none")",
            "resolver_role: \(gateReview.resolverRole ?? "pending")",
            "reviewed_at: \(gateReview.reviewedAt?.formatted(date: .numeric, time: .standard) ?? "pending")",
            gateReview.rationaleNote ?? "sem rationale explicita"
        ]
        .joined(separator: "\n")
    }

    func loadIfNeeded() async {
        guard !didLoad else { return }

        beginAction("bootstrapping demo environment")
        do {
            let environment = try await ScribeFirstSliceDemoBootstrap.makeEnvironment()
            professionalToken = environment.professional.civilToken
            serviceName = environment.service.nome
            availablePatients = environment.patients
            selectedPatientID = environment.patients.first?.id
            facade = environment.facade
            professional = environment.professional
            service = environment.service
            runtimeHealth = .healthy
            lastAction = "environment ready"
            didLoad = true
            issues = []
        } catch {
            recordBootstrapFailure(error)
        }

        isBusy = false
    }

    func startSession() async {
        guard let facade else {
            recordMissingFacade(message: "Scribe bridge is unavailable before session start.")
            return
        }

        beginAction("starting professional session")
        sessionState = .opening
        let result = await facade.startProfessionalSession(
            StartProfessionalSessionCommand(
                professional: currentProfessional,
                service: currentService
            )
        )
        consumeResult(
            disposition: result.disposition,
            state: result.state,
            issues: result.issues,
            successAction: "professional session opened"
        )
    }

    func selectPatient() async {
        guard let facade else {
            recordMissingFacade(message: "Scribe bridge is unavailable before patient selection.")
            return
        }
        guard let sessionId, let patient = selectedPatient else {
            issues = [
                .init(
                    code: .patientMissing,
                    message: "Selecione um paciente pseudonimizado antes de continuar.",
                    failureKind: .state
                )
            ]
            return
        }

        beginAction("selecting patient")
        let result = await facade.selectPatient(
            SelectPatientCommand(sessionId: sessionId, patient: patient)
        )
        consumeResult(
            disposition: result.disposition,
            state: result.state,
            issues: result.issues,
            successAction: "patient context selected"
        )
    }

    func submitCapture() async {
        guard let facade else {
            recordMissingFacade(message: "Scribe bridge is unavailable before capture submission.")
            return
        }
        guard let sessionId else {
            issues = [
                .init(
                    code: .sessionNotFound,
                    message: "Inicie uma sessão antes de submeter captura.",
                    failureKind: .state
                )
            ]
            return
        }

        guard let capture = currentCaptureInput() else {
            issues = [
                .init(
                    code: .captureIncomplete,
                    message: "Escolha texto seeded ou um arquivo de audio local antes de submeter a captura.",
                    failureKind: .validation
                )
            ]
            return
        }

        beginAction(capture.mode == .seededText ? "submitting seeded capture" : "submitting local audio capture")
        let result = await facade.submitSessionCapture(
            SubmitSessionCaptureCommand(
                sessionId: sessionId,
                capture: capture
            )
        )
        consumeResult(
            disposition: result.disposition,
            state: result.state,
            issues: result.issues,
            successAction: "capture accepted"
        )
    }

    func requestDraftPreview() async {
        guard let facade else {
            recordMissingFacade(message: "Scribe bridge is unavailable before draft preview.")
            return
        }
        guard let sessionId else {
            issues = [
                .init(
                    code: .sessionNotFound,
                    message: "Inicie uma sessão antes de pedir preview de draft.",
                    failureKind: .state
                )
            ]
            return
        }

        beginAction("requesting draft preview")
        let result = await facade.requestDraftRefresh(
            RequestDraftRefreshCommand(sessionId: sessionId)
        )
        consumeResult(
            disposition: result.disposition,
            state: result.state,
            issues: result.issues,
            successAction: "draft preview updated"
        )
    }

    func resolveGate(approve: Bool) async {
        guard let facade else {
            recordMissingFacade(message: "Scribe bridge is unavailable before gate resolution.")
            return
        }
        guard let sessionId else {
            issues = [
                .init(
                    code: .sessionNotFound,
                    message: "Inicie uma sessão antes de resolver o gate.",
                    failureKind: .state
                )
            ]
            return
        }

        beginAction(approve ? "approving gate" : "rejecting gate")
        let result = await facade.resolveGate(
            ResolveGateCommand(sessionId: sessionId, approve: approve)
        )
        consumeResult(
            disposition: result.disposition,
            state: result.state,
            issues: result.issues,
            successAction: approve ? "gate approved" : "gate rejected"
        )
    }

    func runSmokeTest() async -> Bool {
        await loadIfNeeded()
        guard didLoad else { return false }

        configureSmokeCaptureIfNeeded()

        await startSession()
        if sessionId == nil { return false }

        await selectPatient()
        await submitCapture()
        await requestDraftPreview()
        await resolveGate(approve: true)

        guard let state = bridgeState, let summary = state.runSummary else {
            print("HealthOSScribeApp smoke test failed")
            print(displayIssues)
            return false
        }

        print("HealthOSScribeApp smoke test complete")
        print("session=\(state.sessionId.uuidString)")
        print("capture_mode=\(state.captureMode?.rawValue ?? "none")")
        print("transcription_status=\(state.transcription.status.rawValue)")
        print("draft_state=\(state.draftState.rawValue)")
        print("gate_state=\(state.gateState.rawValue)")
        print("gate_review=\(state.gateReview.state.rawValue)")
        print("retrieval_status=\(state.retrieval.status.rawValue)")
        print("retrieval_matches=\(state.retrieval.matchCount)")
        print("retrieval_summary=\(state.retrieval.summary)")
        print("final_document_state=\(state.finalDocument.state.rawValue)")
        print("final_document=\(summary.finalDocumentObjectPath ?? "<not effectuated>")")
        print("issues=\(displayIssues)")
        return true
    }

    func handleAudioSelection(_ result: Result<URL, Error>) {
        switch result {
        case .success(let url):
            selectedAudioCapture = AudioCaptureReference(fileURL: url)
            captureMode = .localAudioFile
            issues = []
            lastAction = "local audio selected"
        case .failure(let error):
            issues = [
                .init(
                    code: .captureAudioFileUnreadable,
                    message: "Nao foi possivel selecionar o arquivo de audio local: \(error.localizedDescription)",
                    failureKind: .dependency
                )
            ]
            lastAction = "audio selection failed"
        }
    }

    var displayIssues: String {
        if issues.isEmpty {
            return "none"
        }

        return issues.map { issue in
            let failure = issue.failureKind.map { " [failure=\($0.rawValue)]" } ?? ""
            return "\(issue.code.rawValue):\(issue.message)\(failure)"
        }
        .joined(separator: " | ")
    }

    private var currentProfessional: Usuario {
        professional ?? Usuario(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            cpfHash: "prof-cpf-hash-demo",
            civilToken: professionalToken.isEmpty ? "prof-civil-token-demo" : professionalToken
        )
    }

    private var currentService: Servico {
        service ?? Servico(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!,
            nome: serviceName.isEmpty ? "CloudClinic Demo Service" : serviceName,
            tipo: "ambulatory"
        )
    }

    private func beginAction(_ action: String) {
        isBusy = true
        lastAction = action
        issues = []
    }

    private func consumeResult(
        disposition: HealthOSCommandDisposition,
        state: ScribeSessionBridgeState?,
        issues: [HealthOSIssue],
        successAction: String
    ) {
        lastDisposition = disposition
        self.issues = issues
        if let state {
            bridgeState = state
            sessionId = state.sessionId
        }

        if state?.runSummary != nil {
            sessionState = .closed
        } else {
            switch disposition {
            case .completeSuccess, .partialSuccess, .governedDeny:
                sessionState = .active
            case .degraded:
                sessionState = .degraded
            case .operationalFailure:
                sessionState = .failed
            }
        }

        if disposition == .operationalFailure {
            runtimeHealth = .failed
            degradedMode = .partialResults
        } else if state?.transcription.status == .degraded || state?.transcription.status == .unavailable {
            runtimeHealth = .degraded
            degradedMode = .transcriptionDegraded
        } else if state?.retrieval.status == .degraded || disposition == .degraded {
            runtimeHealth = .degraded
            degradedMode = .retrievalDegraded
        } else if state?.retrieval.status == .partial || state?.retrieval.status == .empty || disposition == .partialSuccess {
            runtimeHealth = .healthy
            degradedMode = .partialResults
        } else {
            runtimeHealth = .healthy
            degradedMode = .none
        }

        lastAction = issues.isEmpty ? successAction : "\(successAction) with issues"
        isBusy = false
    }

    private func recordBootstrapFailure(_ error: Error) {
        sessionState = .failed
        runtimeHealth = .failed
        degradedMode = .partialResults
        issues = [
            .init(
                code: .spineExecutionFailed,
                message: "Scribe demo bootstrap failed: \(error.localizedDescription)",
                failureKind: .dependency
            )
        ]
        lastAction = "bootstrap failed"
        isBusy = false
    }

    private func recordMissingFacade(message: String) {
        sessionState = .failed
        runtimeHealth = .failed
        degradedMode = .partialResults
        issues = [
            .init(
                code: .spineExecutionFailed,
                message: message,
                failureKind: .dependency
            )
        ]
        lastAction = "bridge unavailable"
        isBusy = false
    }

    private func currentCaptureInput() -> SessionCaptureInput? {
        switch captureMode {
        case .seededText:
            let text = captureText.trimmingCharacters(in: .whitespacesAndNewlines)
            guard !text.isEmpty else { return nil }
            return SessionCaptureInput(rawText: text)
        case .localAudioFile:
            guard let selectedAudioCapture else { return nil }
            return SessionCaptureInput(audioReference: selectedAudioCapture)
        }
    }

    private func configureSmokeCaptureIfNeeded() {
        guard audioSmokeTestMode else { return }
        guard let smokeAudioURL = Self.defaultSmokeAudioURL() else {
            issues = [
                .init(
                    code: .captureAudioFileMissing,
                    message: "No system audio fixture was found for the local audio smoke test.",
                    failureKind: .dependency
                )
            ]
            return
        }

        captureMode = .localAudioFile
        selectedAudioCapture = AudioCaptureReference(fileURL: smokeAudioURL)
    }

    private static func defaultSmokeAudioURL(fileManager: FileManager = .default) -> URL? {
        let candidates = [
            "/System/Library/Sounds/Glass.aiff",
            "/System/Library/Sounds/Funk.aiff",
            "/System/Library/Sounds/Ping.aiff"
        ]

        return candidates
            .map { URL(fileURLWithPath: $0) }
            .first { fileManager.fileExists(atPath: $0.path) }
    }
}
