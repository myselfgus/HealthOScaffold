import Foundation
import HealthOSCore
import HealthOSFirstSliceSupport

@main
struct HealthOSCLI {
    static func main() async {
        do {
            let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
            let environment = try await ScribeFirstSliceDemoBootstrap.makeEnvironment()
            guard let patient = environment.patients.first else {
                throw CLIError.invalidState("Demo bootstrap did not provide a patient.")
            }

            let start = await environment.facade.startProfessionalSession(
                StartProfessionalSessionCommand(
                    professional: environment.professional,
                    service: environment.service
                )
            )
            guard let startedState = start.state else {
                throw CLIError.invalidState("Session start failed: \(describeIssues(start.issues))")
            }

            let selection = await environment.facade.selectPatient(
                SelectPatientCommand(sessionId: startedState.sessionId, patient: patient)
            )
            guard selection.state != nil else {
                throw CLIError.invalidState("Patient selection failed: \(describeIssues(selection.issues))")
            }

            let capture = await environment.facade.submitSessionCapture(
                SubmitSessionCaptureCommand(
                    sessionId: startedState.sessionId,
                    capture: makeCaptureInput(from: arguments)
                )
            )
            guard capture.state != nil else {
                throw CLIError.invalidState("Capture submission failed: \(describeIssues(capture.issues))")
            }

            let draftRefresh = await environment.facade.requestDraftRefresh(
                RequestDraftRefreshCommand(sessionId: startedState.sessionId)
            )
            if !draftRefresh.issues.isEmpty {
                print("draft_refresh_disposition=\(draftRefresh.disposition.rawValue)")
                print("draft_refresh_issues=\(describeIssues(draftRefresh.issues))")
            }

            let gateResult = await environment.facade.resolveGate(
                ResolveGateCommand(sessionId: startedState.sessionId, approve: true)
            )
            guard let bridgeState = gateResult.state, let summary = bridgeState.runSummary else {
                throw CLIError.invalidState("Gate resolution failed: \(describeIssues(gateResult.issues))")
            }

            print("HealthOS first slice complete")
            print("session=\(bridgeState.sessionId.uuidString)")
            print("capture_mode=\(summary.captureMode.rawValue)")
            if let audioPath = summary.audioCaptureObjectPath {
                print("audio_capture=\(audioPath)")
            }
            print("transcription_status=\(summary.transcriptionStatus.rawValue)")
            print("transcription_source=\(summary.transcriptionSource)")
            print("transcript=\(summary.transcriptObjectPath ?? "<not available>")")
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
            print("retrieval_summary=\(bridgeState.retrieval.summary)")
            print("retrieval_fallback_empty=\(summary.retrievalFallbackEmpty)")
            print("provenance_count=\(summary.provenanceCount)")
            print("event_count=\(summary.eventCount)")
            print("gate_resolution_disposition=\(gateResult.disposition.rawValue)")
        } catch {
            FileHandle.standardError.write(Data("HealthOSCLI failed: \(error)\n".utf8))
            exit(1)
        }
    }

    private static func describeIssues(_ issues: [HealthOSIssue]) -> String {
        issues.map { issue in
            let failure = issue.failureKind.map { " [failure=\($0.rawValue)]" } ?? ""
            return "\(issue.code.rawValue):\(issue.message)\(failure)"
        }.joined(separator: " | ")
    }

    private static func makeCaptureInput(from arguments: [String]) -> SessionCaptureInput {
        if let audioPath = value(for: "--audio-file", in: arguments) {
            return SessionCaptureInput(
                audioReference: AudioCaptureReference(
                    filePath: audioPath,
                    displayName: URL(fileURLWithPath: audioPath).lastPathComponent
                )
            )
        }

        return SessionCaptureInput(
            rawText: "Paciente relata dor de cabeça, insônia e piora do sono há uma semana."
        )
    }

    private static func value(for flag: String, in arguments: [String]) -> String? {
        guard let index = arguments.firstIndex(of: flag) else { return nil }
        let valueIndex = arguments.index(after: index)
        guard valueIndex < arguments.endIndex else { return nil }
        return arguments[valueIndex]
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
