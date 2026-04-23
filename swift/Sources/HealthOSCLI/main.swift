import Foundation
import Dispatch
import HealthOSCore
import HealthOSProviders
import HealthOSAACI

func runHealthOSCLI() async -> Int32 {
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

        let sessionInput = FirstSliceSessionInput(
            professional: professional,
            patient: patient,
            service: service,
            capture: SessionCaptureInput(
                rawText: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."
            ),
            gateApprove: true
        )
        let bridgeState = try await scribeBridge.startSession(input: sessionInput)

        print("HealthOS first slice complete")
        print("session=\(bridgeState.sessionId.uuidString)")
        print("transcript=\(bridgeState.runSummary.transcriptObjectPath)")
        print("draft=\(bridgeState.runSummary.draftObjectPath)")
        print("gate=\(bridgeState.gateState.rawValue)")
        if let finalPath = bridgeState.runSummary.finalArtifactObjectPath {
            print("final=\(finalPath)")
        } else {
            print("final=<not effectuated>")
        }
        print("provenance_count=\(bridgeState.runSummary.provenanceCount)")
        print("event_count=\(bridgeState.runSummary.eventCount)")
        print("scribe_gate_state=\(bridgeState.gateState.rawValue)")
        return 0
    } catch {
        FileHandle.standardError.write(Data("HealthOSCLI failed: \(error)\n".utf8))
        return 1
    }
}

Task {
    let code = await runHealthOSCLI()
    exit(code)
}
dispatchMain()
