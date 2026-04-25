import Foundation
import HealthOSCore
import HealthOSAACI
import HealthOSProviders

public struct ScribeFirstSliceDemoEnvironment: Sendable {
    public let root: URL
    public let professional: Usuario
    public let patients: [Usuario]
    public let service: Servico
    public let facade: any ScribeFirstSliceFacade

    public init(
        root: URL,
        professional: Usuario,
        patients: [Usuario],
        service: Servico,
        facade: any ScribeFirstSliceFacade
    ) {
        self.root = root
        self.professional = professional
        self.patients = patients
        self.service = service
        self.facade = facade
    }
}

public enum ScribeFirstSliceDemoBootstrapError: LocalizedError {
    case repositoryRootNotFound(String)

    public var errorDescription: String? {
        switch self {
        case .repositoryRootNotFound(let path):
            return "Could not resolve the HealthOScaffold repository root from \(path)."
        }
    }
}

public enum ScribeFirstSliceDemoBootstrap {
    public static func makeEnvironment(
        fileManager: FileManager = .default
    ) async throws -> ScribeFirstSliceDemoEnvironment {
        let repositoryRoot = try resolveRepositoryRoot(fileManager: fileManager)
        let root = repositoryRoot
            .appending(path: "runtime-data/Users/Shared/HealthOS")
            .standardizedFileURL

        try DirectoryLayout.bootstrap(at: root)

        let professional = Usuario(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000010")!,
            cpfHash: "prof-cpf-hash-demo",
            civilToken: "prof-civil-token-demo"
        )
        let patients = [
            Usuario(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000020")!,
                cpfHash: "patient-cpf-hash-demo-a",
                civilToken: "patient-civil-token-a"
            ),
            Usuario(
                id: UUID(uuidString: "00000000-0000-0000-0000-000000000021")!,
                cpfHash: "patient-cpf-hash-demo-b",
                civilToken: "patient-civil-token-b"
            )
        ]
        let service = Servico(
            id: UUID(uuidString: "00000000-0000-0000-0000-000000000100")!,
            nome: "CloudClinic Demo Service",
            tipo: "ambulatory"
        )

        try DirectoryLayout.ensureUserTree(root: root, cpfHash: professional.cpfHash)
        for patient in patients {
            try DirectoryLayout.ensureUserTree(root: root, cpfHash: patient.cpfHash)
        }
        try DirectoryLayout.ensureServiceTree(root: root, serviceId: service.id)
        try DirectoryLayout.ensureAgentTree(root: root, agentId: "aaci.capture")

        let router = ProviderRouter()
        try await router.register(AppleFoundationProvider())
        try await router.register(NativeSpeechProvider())
        let orchestrator = AACIOrchestrator(router: router)
        let runner = FirstSliceRunner(root: root, orchestrator: orchestrator)
        let facade = ScribeFirstSliceAdapter(runner: runner)

        return ScribeFirstSliceDemoEnvironment(
            root: root,
            professional: professional,
            patients: patients,
            service: service,
            facade: facade
        )
    }

    private static func resolveRepositoryRoot(fileManager: FileManager) throws -> URL {
        var candidate = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true)
            .standardizedFileURL

        for _ in 0..<5 {
            if fileManager.fileExists(atPath: candidate.appending(path: "swift/Package.swift").path) {
                return candidate
            }

            if candidate.lastPathComponent == "swift",
               fileManager.fileExists(atPath: candidate.appending(path: "Package.swift").path) {
                let parent = candidate.deletingLastPathComponent()
                if fileManager.fileExists(atPath: parent.appending(path: "README.md").path) {
                    return parent.standardizedFileURL
                }
            }

            let parent = candidate.deletingLastPathComponent()
            guard parent.path != candidate.path else { break }
            candidate = parent
        }

        throw ScribeFirstSliceDemoBootstrapError.repositoryRootNotFound(
            fileManager.currentDirectoryPath
        )
    }
}
