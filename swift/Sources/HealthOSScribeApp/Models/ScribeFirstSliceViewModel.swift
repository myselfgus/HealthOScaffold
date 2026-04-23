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
        case retrievalDegraded = "retrieval_degraded"
        case partialResults = "partial_results"
    }

    let smokeTestMode = ProcessInfo.processInfo.arguments.contains("--smoke-test")

    var professionalToken = ""
    var serviceName = ""
    var availablePatients: [Usuario] = []
    var selectedPatientID: UUID?
    var captureText = "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."

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

    var canStartSession: Bool {
        facade != nil && !isBusy && sessionId == nil
    }

    var canSelectPatient: Bool {
        !isBusy && sessionId != nil && selectedPatient != nil
    }

    var canSubmitCapture: Bool {
        !isBusy && sessionId != nil && !captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canRequestDraftPreview: Bool {
        !isBusy && sessionId != nil && !captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var canResolveGate: Bool {
        !isBusy && sessionId != nil && !captureText.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }

    var finalSummaryText: String {
        guard let state = bridgeState else {
            return "Sem artefato final ainda."
        }
        guard let summary = state.runSummary else {
            return "Fluxo ainda em preparação; gate não resolvido."
        }
        if let finalPath = summary.finalArtifactObjectPath {
            return "Aprovado com artefato final persistido em \(finalPath)"
        }
        return "Sem artefato final efetivado. Gate: \(state.gateState.rawValue)"
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

        beginAction("submitting seeded capture")
        let result = await facade.submitSessionCapture(
            SubmitSessionCaptureCommand(
                sessionId: sessionId,
                capture: SessionCaptureInput(rawText: captureText)
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
        print("draft_state=\(state.draftState.rawValue)")
        print("gate_state=\(state.gateState.rawValue)")
        print("retrieval_status=\(state.retrieval.status.rawValue)")
        print("retrieval_matches=\(state.retrieval.matchCount)")
        print("final=\(summary.finalArtifactObjectPath ?? "<not effectuated>")")
        print("issues=\(displayIssues)")
        return true
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

        switch disposition {
        case .completeSuccess, .partialSuccess:
            runtimeHealth = .healthy
            degradedMode = .none
        case .degraded:
            runtimeHealth = .degraded
            degradedMode = .retrievalDegraded
        case .governedDeny:
            runtimeHealth = .healthy
            degradedMode = .none
        case .operationalFailure:
            runtimeHealth = .failed
            degradedMode = .partialResults
        }

        if let state,
           state.retrieval.status == .degraded,
           state.retrieval.source != "pending-run" {
            degradedMode = .retrievalDegraded
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
}
