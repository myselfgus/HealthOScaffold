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

            let router = ProviderRouter()
            await router.register(AppleFoundationProvider())
            let orchestrator = AACIOrchestrator(router: router)

            let session = SessaoTrabalho(
                kind: .encounter,
                serviceId: UUID(),
                professionalUserId: UUID(),
                patientUserId: UUID()
            )
            let message = await orchestrator.startSession(session)
            print(message)

            let draft = await orchestrator.composeSOAPDraft(
                session: session,
                transcript: "Paciente relata dor de cabeça e insônia.",
                context: ["Consulta prévia há 10 dias", "Sem alergias registradas"]
            )
            print("Draft kind: \(draft.kind) status: \(draft.status.rawValue)")
        } catch {
            FileHandle.standardError.write(Data("HealthOSCLI failed: \(error)\n".utf8))
            exit(1)
        }
    }
}
