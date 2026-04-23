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

            let result = try await runner.run(
                professional: professional,
                patient: patient,
                service: service,
                captureText: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana.",
                approve: true
            )

            print("HealthOS first slice complete")
            print("session=\(result.session.id.uuidString)")
            print("transcript=\(result.transcriptRef.objectPath)")
            print("draft=\(result.draftRef.objectPath)")
            print("gate=\(result.gateResolution.resolution.rawValue)")
            if let finalRef = result.finalArtifactRef {
                print("final=\(finalRef.objectPath)")
            } else {
                print("final=<not effectuated>")
            }
            print("provenance_count=\(result.provenanceRecords.count)")
            print("event_count=\(result.events.count)")
        } catch {
            FileHandle.standardError.write(Data("HealthOSCLI failed: \(error)\n".utf8))
            exit(1)
        }
    }
}
