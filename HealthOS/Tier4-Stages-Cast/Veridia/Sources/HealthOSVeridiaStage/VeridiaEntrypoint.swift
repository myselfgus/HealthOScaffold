import Foundation
import HealthOSBoundary
import HealthOSCore

// Veridia is the patient health identity Stage for HealthOS.
// Architecture: HealthOS/Shared/docs/architecture/12-veridia.md
// Governance contracts: HealthOSCore/UserSovereigntyContracts.swift
// Session boundary: HealthOSCore/VeridiaSessionContracts.swift
// TODO: consume these surfaces solely through HealthOSBoundary once Veridia session facade types migrate.
// Veridia consumes mediated identity, key custody, consent, access trail, and export surfaces.
// Veridia is not Core law, not the User-Agent Runtime, and has no clinical authority.
@main
struct VeridiaEntrypoint {
    static func main() async {
        let args = CommandLine.arguments
        if args.contains("--smoke-test") {
            await runSmokeTest()
            return
        }
        print("Veridia Stage: patient health identity scaffold placeholder - no final UI shell, no clinical authority (see HealthOS/Shared/docs/architecture/12-veridia.md)")
    }

    private static func runSmokeTest() async {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let lawfulContext: [String: String] = [
            "actorRole": "user-agent",
            "scope": "patient-self-service",
            "serviceId": UUID().uuidString,
            "patientUserId": userId.uuidString,
            "finalidade": "patient-self-governance",
            "sessionId": UUID().uuidString
        ]
        let request = VeridiaSessionStartRequest(
            userId: userId,
            finalidade: "patient-self-governance",
            lawfulContext: lawfulContext,
            cpfHashRef: "cpf-hash-smoke-test",
            actorId: "veridia-smoke-agent",
            runtimeId: "veridia-smoke-runtime"
        )

        let startResult = await adapter.startSession(request)
        guard startResult.disposition == .sessionStarted else {
            print("Veridia Stage smoke FAIL: session start returned \(startResult.disposition.rawValue) — \(startResult.issueMessage ?? "no detail")")
            exit(1)
        }

        let endResult = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: lawfulContext
        )
        guard endResult.disposition == .sessionEnded else {
            print("Veridia Stage smoke FAIL: session end returned \(endResult.disposition.rawValue) — \(endResult.issueMessage ?? "no detail")")
            exit(1)
        }

        print("Veridia Stage scaffold: smoke OK (veridia.session.start + veridia.session.end Boundary verified)")
    }
}
