import Foundation
import HealthOSCore
import HealthOSFirstSliceSupport

@main
struct HealthOSCLI {
    static func main() async {
        do {
            let arguments = Array(ProcessInfo.processInfo.arguments.dropFirst())
            if let bundleId = value(for: "--gos-review-bundle", in: arguments) {
                let specId = value(for: "--gos-spec-id", in: arguments) ?? "aaci.first-slice"
                let reviewerId = value(for: "--reviewer-id", in: arguments) ?? NSUserName()
                let reviewerRole = value(for: "--reviewer-role", in: arguments) ?? "operator"
                let rationale = value(for: "--review-rationale", in: arguments) ?? "bundle reviewed via HealthOSCLI"
                let root = try resolveRuntimeRoot()
                let registry = FileBackedGOSBundleRegistry(root: root)
                let reviewRecord = try await registry.review(
                    bundleId: bundleId,
                    specId: specId,
                    reviewerId: reviewerId,
                    reviewerRole: reviewerRole,
                    rationale: rationale
                )
                print("gos_bundle_reviewed=true")
                print("gos_spec_id=\(specId)")
                print("gos_bundle_id=\(bundleId)")
                print("gos_review_record_id=\(reviewRecord.id.uuidString)")
                print("gos_reviewer_id=\(reviewRecord.reviewerId)")
                print("gos_reviewer_role=\(reviewRecord.reviewerRole)")
                return
            }
            if let bundleId = value(for: "--gos-promote-bundle", in: arguments) {
                let specId = value(for: "--gos-spec-id", in: arguments) ?? "aaci.first-slice"
                let operatorId = value(for: "--operator-id", in: arguments) ?? NSUserName()
                let operatorRole = value(for: "--operator-role", in: arguments) ?? "operator"
                let rationale = value(for: "--activation-rationale", in: arguments) ?? "bundle promoted via HealthOSCLI"
                let root = try resolveRuntimeRoot()
                let registry = FileBackedGOSBundleRegistry(root: root)
                let auditRecord = try await registry.promoteReviewedBundle(
                    bundleId: bundleId,
                    specId: specId,
                    actorId: operatorId,
                    actorRole: operatorRole,
                    rationale: rationale
                )
                print("gos_bundle_promoted=true")
                print("gos_spec_id=\(specId)")
                print("gos_bundle_id=\(bundleId)")
                print("gos_activation_audit_id=\(auditRecord.id.uuidString)")
                print("gos_operator_id=\(auditRecord.actorId)")
                print("gos_operator_role=\(auditRecord.actorRole)")
                return
            }

            let approveGate = !arguments.contains("--reject-gate")
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
                ResolveGateCommand(sessionId: startedState.sessionId, approve: approveGate)
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
            print("draft_review_status=\(summary.reviewedDraftStatus.rawValue)")
            print("referral_draft_state=\(bridgeState.referralDraft.state.rawValue)")
            print("referral_draft_status=\(summary.referralDraftStatus.rawValue)")
            print("referral_draft=\(summary.referralDraftObjectPath)")
            print("referral_draft_summary=\(summary.referralDraftSummary)")
            print("prescription_draft_state=\(bridgeState.prescriptionDraft.state.rawValue)")
            print("prescription_draft_status=\(summary.prescriptionDraftStatus.rawValue)")
            print("prescription_draft=\(summary.prescriptionDraftObjectPath)")
            print("prescription_draft_summary=\(summary.prescriptionDraftSummary)")
            print("gate=\(bridgeState.gateState.rawValue)")
            print("gate_resolution=\(summary.gateResolution.rawValue)")
            print("gate_review_type=\(summary.gateReviewType.rawValue)")
            print("final_document_state=\(bridgeState.finalDocument.state.rawValue)")
            if let finalPath = summary.finalDocumentObjectPath {
                print("final_document=\(finalPath)")
            } else {
                print("final_document=<not effectuated>")
            }
            print("final_document_summary=\(bridgeState.finalDocument.summary)")
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

    private static func resolveRuntimeRoot(fileManager: FileManager = .default) throws -> URL {
        var candidate = URL(fileURLWithPath: fileManager.currentDirectoryPath, isDirectory: true).standardizedFileURL
        for _ in 0..<5 {
            if fileManager.fileExists(atPath: candidate.appending(path: "runtime-data").path) {
                return candidate.appending(path: "runtime-data/Users/Shared/HealthOS").standardizedFileURL
            }
            let parent = candidate.deletingLastPathComponent()
            guard parent.path != candidate.path else { break }
            candidate = parent
        }
        throw CLIError.invalidState("Could not resolve runtime-data root for GOS promotion command.")
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
