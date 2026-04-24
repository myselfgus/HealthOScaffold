#if canImport(SwiftUI)
import Darwin
import SwiftUI

@main
struct HealthOSScribeApp: App {
    @State private var model = ScribeFirstSliceViewModel()

    var body: some Scene {
        WindowGroup("Scribe First Slice") {
            ScribeFirstSliceView(model: model)
                .task {
                    await model.loadIfNeeded()
                    if model.smokeTestMode {
                        let success = await model.runSmokeTest()
                        fflush(stdout)
                        exit(success ? 0 : 1)
                    }
                }
        }
    }
}
#else
import Foundation
import HealthOSCore
import HealthOSFirstSliceSupport

@main
struct HealthOSScribeApp {
    static func main() async {
        guard ProcessInfo.processInfo.arguments.contains("--smoke-test")
            || ProcessInfo.processInfo.arguments.contains("--smoke-test-audio")
        else {
            print("HealthOSScribeApp requires macOS/SwiftUI for interactive mode.")
            return
        }

        do {
            let environment = try await ScribeFirstSliceDemoBootstrap.makeEnvironment()
            guard let patient = environment.patients.first else {
                throw SmokeError.invalidState("No demo patient available.")
            }
            let start = await environment.facade.startProfessionalSession(
                StartProfessionalSessionCommand(
                    professional: environment.professional,
                    service: environment.service
                )
            )
            guard let startedState = start.state else {
                throw SmokeError.invalidState("Session start failed: \(start.issues)")
            }
            let selection = await environment.facade.selectPatient(
                SelectPatientCommand(sessionId: startedState.sessionId, patient: patient)
            )
            guard selection.state != nil else {
                throw SmokeError.invalidState("Patient selection failed: \(selection.issues)")
            }
            let capture = await environment.facade.submitSessionCapture(
                SubmitSessionCaptureCommand(sessionId: startedState.sessionId, capture: SessionCaptureInput(rawText: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."))
            )
            guard capture.state != nil else {
                throw SmokeError.invalidState("Capture submission failed: \(capture.issues)")
            }
            let resolved = await environment.facade.resolveGate(
                ResolveGateCommand(sessionId: startedState.sessionId, approve: true)
            )
            guard resolved.state != nil else {
                throw SmokeError.invalidState("Gate resolution failed: \(resolved.issues)")
            }
            print("HealthOSScribeApp smoke test passed (headless fallback).")
            exit(0)
        } catch {
            FileHandle.standardError.write(Data("HealthOSScribeApp smoke test failed: \(error)\n".utf8))
            exit(1)
        }
    }
}

private enum SmokeError: LocalizedError {
    case invalidState(String)

    var errorDescription: String? {
        switch self {
        case .invalidState(let message):
            return message
        }
    }
}
#endif
