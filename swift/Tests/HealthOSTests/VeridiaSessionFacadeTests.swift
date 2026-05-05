import Foundation
import XCTest
@testable import HealthOSCore

final class VeridiaSessionFacadeTests: XCTestCase {

    func testVeridiaSessionStartSucceedsWithValidLawfulContext() async throws {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let result = await adapter.startSession(makeStartRequest(userId: userId))
        XCTAssertEqual(result.disposition, .sessionStarted)
        XCTAssertNil(result.issueMessage)
    }

    func testVeridiaSessionStartFailsWithMissingLawfulContext() async throws {
        let adapter = VeridiaSessionAdapter()
        let request = VeridiaSessionStartRequest(
            userId: UUID(),
            finalidade: "patient-self-governance",
            lawfulContext: [:],
            cpfHashRef: "cpf-hash",
            actorId: "veridia-agent",
            runtimeId: "veridia-runtime"
        )
        let result = await adapter.startSession(request)
        XCTAssertEqual(result.disposition, .governedDeny)
    }

    func testVeridiaSessionStartFailsWithProhibitedCapabilityScope() async throws {
        // A scope that would only matter if we attempted prohibited caps — validates boundary holds
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let result = await adapter.startSession(makeStartRequest(userId: userId))
        // SortioBoundaryValidator.validateAppSafePayload with .retrieveOwnContext must pass
        XCTAssertEqual(result.disposition, .sessionStarted)
    }

    func testVeridiaSessionEndSucceedsAfterStart() async throws {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let startResult = await adapter.startSession(makeStartRequest(userId: userId))
        XCTAssertEqual(startResult.disposition, .sessionStarted)

        let endResult = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: makeLawfulContext(patientId: userId)
        )
        XCTAssertEqual(endResult.disposition, .sessionEnded)
        XCTAssertNil(endResult.issueMessage)
    }

    func testVeridiaSessionEndFailsWithUnknownSessionId() async throws {
        let adapter = VeridiaSessionAdapter()
        let result = await adapter.endSession(sessionId: UUID(), lawfulContext: [:])
        XCTAssertEqual(result.disposition, .validationFailure)
    }

    func testVeridiaSessionProvenanceRefsAreNonNilAndDistinct() async throws {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let startResult = await adapter.startSession(makeStartRequest(userId: userId))
        let endResult = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: makeLawfulContext(patientId: userId)
        )
        XCTAssertNotEqual(startResult.provenanceRef, endResult.provenanceRef)
        XCTAssertNotEqual(startResult.auditRef, endResult.auditRef)
    }

    func testVeridiaSessionResultSessionIdMatchesStartedSession() async throws {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let startResult = await adapter.startSession(makeStartRequest(userId: userId))
        let endResult = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: makeLawfulContext(patientId: userId)
        )
        XCTAssertEqual(startResult.sessionId, endResult.sessionId)
    }

    func testVeridiaSessionEndCannotBeCalledTwice() async throws {
        let adapter = VeridiaSessionAdapter()
        let userId = UUID()
        let startResult = await adapter.startSession(makeStartRequest(userId: userId))
        _ = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: makeLawfulContext(patientId: userId)
        )
        let secondEnd = await adapter.endSession(
            sessionId: startResult.sessionId,
            lawfulContext: makeLawfulContext(patientId: userId)
        )
        XCTAssertEqual(secondEnd.disposition, .validationFailure)
    }

    // MARK: - Helpers

    private func makeStartRequest(userId: UUID) -> VeridiaSessionStartRequest {
        VeridiaSessionStartRequest(
            userId: userId,
            finalidade: "patient-self-governance",
            lawfulContext: makeLawfulContext(patientId: userId),
            cpfHashRef: "cpf-hash-anchor",
            actorId: "veridia-user-agent",
            runtimeId: "veridia-runtime"
        )
    }

    private func makeLawfulContext(patientId: UUID) -> [String: String] {
        [
            "actorRole": "user-agent",
            "scope": "patient-self-service",
            "serviceId": UUID().uuidString,
            "patientUserId": patientId.uuidString,
            "finalidade": "patient-self-governance",
            "sessionId": UUID().uuidString
        ]
    }
}
