import Foundation
import HealthOSCore
import HealthOSProviders
import HealthOSAACI

@main
struct HealthOSCLI {
    static func main() async {
        do {
            let root = URL(fileURLWithPath: FileManager.default.currentDirectoryPath)
                .appending(path: "../runtime-data/Users/Shared/HealthOS")
                .standardized
            try DirectoryLayout.bootstrap(at: root)

            let professional = Usuario(cpfHash: "prof-cpf-hash", civilToken: "prof-civil-token")
            let patient = Usuario(cpfHash: "patient-cpf-hash", civilToken: "patient-civil-token")
            let service = Servico(nome: "CloudClinic Demo Service", tipo: "ambulatory")

            try DirectoryLayout.ensureUserTree(root: root, cpfHash: professional.cpfHash)
            try DirectoryLayout.ensureUserTree(root: root, cpfHash: patient.cpfHash)
            try DirectoryLayout.ensureServiceTree(root: root, serviceId: service.id)
            try DirectoryLayout.ensureAgentTree(root: root, agentId: "aaci.capture")

            let router = ProviderRouter()
            await router.register(AppleFoundationProvider())
            let orchestrator = AACIOrchestrator(router: router)
            let runner = FirstSliceRunner(root: root, orchestrator: orchestrator)
            let scribeBridge = ScribeFirstSliceAdapter(runner: runner)

            let start = await scribeBridge.startProfessionalSession(
                StartProfessionalSessionCommand(professional: professional, service: service)
            )
            guard let startedState = start.state else {
                throw CLIError.invalidState("Session start failed: \(describeIssues(start.issues))")
            }

            let selection = await scribeBridge.selectPatient(
                SelectPatientCommand(sessionId: startedState.sessionId, patient: patient)
            )
            guard selection.state != nil else {
                throw CLIError.invalidState("Patient selection failed: \(describeIssues(selection.issues))")
            }

            let capture = await scribeBridge.submitSessionCapture(
                SubmitSessionCaptureCommand(
                    sessionId: startedState.sessionId,
                    capture: SessionCaptureInput(
                        rawText: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."
                    )
                )
            )
            guard capture.state != nil else {
                throw CLIError.invalidState("Capture submission failed: \(describeIssues(capture.issues))")
            }

            let draftRefresh = await scribeBridge.requestDraftRefresh(
                RequestDraftRefreshCommand(sessionId: startedState.sessionId)
            )
            if !draftRefresh.issues.isEmpty {
                print("draft_refresh_disposition=\(draftRefresh.disposition.rawValue)")
                print("draft_refresh_issues=\(describeIssues(draftRefresh.issues))")
            }

            let gateResult = await scribeBridge.resolveGate(
                ResolveGateCommand(sessionId: startedState.sessionId, approve: true)
            )
            guard let bridgeState = gateResult.state, let summary = bridgeState.runSummary else {
                throw CLIError.invalidState("Gate resolution failed: \(describeIssues(gateResult.issues))")
            }

            print("HealthOS first slice complete")
            print("session=\(bridgeState.sessionId.uuidString)")
            print("transcript=\(summary.transcriptObjectPath)")
            print("draft=\(summary.draftObjectPath)")
            print("gate=\(bridgeState.gateState.rawValue)")
            if let finalPath = summary.finalArtifactObjectPath {
                print("final=\(finalPath)")
            } else {
                print("final=<not effectuated>")
            }
            print("retrieval_source=\(bridgeState.retrieval.source)")
            print("retrieval_matches=\(bridgeState.retrieval.matchCount)")
            print("retrieval_status=\(bridgeState.retrieval.status.rawValue)")
            print("retrieval_fallback_empty=\(summary.retrievalFallbackEmpty)")
            print("provenance_count=\(summary.provenanceCount)")
            print("event_count=\(summary.eventCount)")
            print("gate_resolution_disposition=\(gateResult.disposition.rawValue)")
        } catch {
            FileHandle.standardError.write(Data("HealthOSCLI failed: \(error)\n".utf8))
            exit(1)
        }
    }

    private static func describeIssues(_ issues: [FirstSliceCommandIssue]) -> String {
        issues.map { "\($0.code):\($0.message)" }.joined(separator: " | ")
    }
}

private enum CLIError: LocalizedError {
    case invalidState(String)

    var errorDescription: String? {
        switch self {
        case .invalidState(let message):
            return message
        }
    }
}
