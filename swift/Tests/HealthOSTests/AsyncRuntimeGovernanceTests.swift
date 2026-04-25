import XCTest
@testable import HealthOSCore

final class AsyncRuntimeGovernanceTests: XCTestCase {
    private func makeLawfulContext(scope: String = "operational", includeConsent: Bool = true) -> [String: String] {
        var context: [String: String] = [
            "actorRole": "async-runtime",
            "scope": scope,
            "serviceId": UUID().uuidString,
            "patientUserId": UUID().uuidString,
            "habilitationId": UUID().uuidString,
            "finalidade": "runtime-maintenance",
            "sessionId": UUID().uuidString
        ]
        if includeConsent {
            context["consentBasis"] = "matched"
        }
        return context
    }

    private func makeJob(
        kind: AsyncJobKind = .maintenance,
        state: AsyncJobState = .pending,
        sensitive: Bool = false,
        idempotent: Bool = true,
        source: JobSubmissionSource = .system,
        layer: StorageLayer = .governanceMetadata,
        maxRetries: Int = 2,
        allowsRemoteProvider: Bool = false
    ) -> AsyncJobDescriptor {
        AsyncJobDescriptor(
            kind: kind,
            requestedByActor: "runtime.async",
            submissionSource: source,
            lawfulContextRequirement: sensitive
                ? AsyncJobLawfulContextRequirement(
                    requireLawfulContext: true,
                    requireFinalidade: true,
                    requireConsent: true,
                    requireHabilitation: true,
                    requirePatientContext: true,
                    requireServiceContext: true
                )
                : .none,
            dataLayersTouched: [layer],
            inputRefs: ["input://test"],
            idempotencyKey: "job-\(UUID().uuidString)",
            retryPolicy: AsyncJobRetryPolicy(maxRetries: maxRetries, baseDelaySeconds: 1),
            state: state,
            idempotent: idempotent,
            allowsRemoteProvider: allowsRemoteProvider
        )
    }

    func testLifecyclePendingRunningCompleted() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob())

        let completed = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .completed(outputRefs: ["output://1"], provenanceRef: UUID(), auditRef: UUID())
        }

        XCTAssertEqual(completed.state, .completed)
        XCTAssertEqual(completed.outputRefs.count, 1)
    }

    func testLifecyclePendingCancelled() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob())
        let cancelled = try await runtime.cancelPendingJob(id: job.id, actor: "operator.1")
        XCTAssertEqual(cancelled.state, .cancelled)
    }

    func testLifecycleRunningFailedRetryScheduled() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 2))

        let afterFailure = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .dependencyFailure, message: "temporary"), retryable: true)
        }

        XCTAssertEqual(afterFailure.state, .retryScheduled)
        XCTAssertEqual(afterFailure.retryCount, 1)
    }

    func testLifecycleRetryScheduledToRunning() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 2))

        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .timeout, message: "retry"), retryable: true)
        }

        let retried = try await runtime.runNext(lawfulContext: nil, now: Date().addingTimeInterval(2)) { _, _ in
            .completed(outputRefs: ["output://retry"], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(retried?.state, .completed)
    }

    func testLifecycleFailureAfterMaxRetriesToDeadLetter() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 1))

        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .dependencyFailure, message: "attempt-1"), retryable: true)
        }
        let afterSecond = try await runtime.runNext(lawfulContext: nil, now: Date().addingTimeInterval(2)) { _, _ in
            .failed(AsyncJobFailure(kind: .dependencyFailure, message: "attempt-2"), retryable: true)
        }

        XCTAssertEqual(afterSecond?.state, .deadLetter)
    }

    func testInvalidTransitionFails() throws {
        XCTAssertThrowsError(try AsyncJobStateMachine.requireTransition(from: .pending, to: .completed)) { error in
            XCTAssertEqual(error as? AsyncJobRuntimeError, .invalidTransition(from: .pending, to: .completed))
        }
    }

    func testSensitiveJobWithoutLawfulContextFailsClosed() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(sensitive: true))

        let result = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            XCTFail("Execution must not run when lawful context is missing")
            return .completed(outputRefs: [], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(result.state, .deadLetter)
    }

    func testNonSensitiveJobRunsWithoutLawfulContext() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(sensitive: false))

        let result = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .completed(outputRefs: ["ok"], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(result.state, .completed)
    }

    func testDirectIdentifiersRequireReinforcedScope() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(sensitive: true, layer: .directIdentifiers))

        let result = try await runtime.runJob(id: job.id, lawfulContext: makeLawfulContext(scope: "operational")) { _, _ in
            XCTFail("Should fail before execution")
            return .completed(outputRefs: [], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(result.state, .deadLetter)
    }

    func testReidentificationMappingWithoutProperScopeFails() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(sensitive: true, layer: .reidentificationMapping))

        let result = try await runtime.runJob(id: job.id, lawfulContext: makeLawfulContext(scope: "direct-identifiers-governance")) { _, _ in
            XCTFail("Should fail before execution")
            return .completed(outputRefs: [], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(result.state, .deadLetter)
    }

    func testRetryIncrementsAttemptCountAndPreservesFailureKind() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 1))

        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .timeout, message: "first failure"), retryable: true)
        }
        let inspected = try await runtime.inspectJob(id: job.id)

        XCTAssertEqual(inspected.0.retryCount, 1)
        XCTAssertEqual(inspected.1?.lastFailure?.kind, .timeout)
    }

    func testNonIdempotentJobDoesNotAutoRetry() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(idempotent: false, maxRetries: 3))

        let result = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .dependencyFailure, message: "no retry"), retryable: true)
        }

        XCTAssertEqual(result.state, .deadLetter)
    }

    func testIdempotencyReusesCompletedJob() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        var first = makeJob()
        first = try await runtime.enqueue(first)
        _ = try await runtime.runJob(id: first.id, lawfulContext: nil) { _, _ in
            .completed(outputRefs: ["output://same"], provenanceRef: nil, auditRef: nil)
        }

        var duplicate = makeJob()
        duplicate = AsyncJobDescriptor(
            id: UUID(),
            kind: duplicate.kind,
            requestedByActor: duplicate.requestedByActor,
            submissionSource: duplicate.submissionSource,
            lawfulContextRequirement: duplicate.lawfulContextRequirement,
            dataLayersTouched: duplicate.dataLayersTouched,
            inputRefs: duplicate.inputRefs,
            idempotencyKey: first.idempotencyKey,
            retryPolicy: duplicate.retryPolicy,
            idempotent: duplicate.idempotent
        )

        let reused = try await runtime.enqueue(duplicate)
        XCTAssertEqual(reused.id, first.id)
    }

    func testIdempotencyDuplicateActiveJobDenied() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let first = try await runtime.enqueue(makeJob())

        let duplicate = AsyncJobDescriptor(
            kind: .maintenance,
            requestedByActor: "runtime.async",
            submissionSource: .system,
            lawfulContextRequirement: .none,
            dataLayersTouched: [.governanceMetadata],
            inputRefs: [],
            idempotencyKey: first.idempotencyKey,
            retryPolicy: AsyncJobRetryPolicy(maxRetries: 1),
            idempotent: true
        )

        do {
            _ = try await runtime.enqueue(duplicate)
            XCTFail("Expected duplicate-idempotency denial")
        } catch {
            guard let casted = error as? AsyncJobRuntimeError,
                  case .duplicateIdempotencyKeyExistingJob = casted else {
                return XCTFail("Expected duplicate-idempotency denial")
            }
        }
    }

    func testRetryCreatesDistinctAttemptLogsAndNoDuplicateFinalProvenance() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 2))

        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .dependencyFailure, message: "attempt1"), retryable: true)
        }

        let finalProv = UUID()
        _ = try await runtime.runNext(lawfulContext: nil, now: Date().addingTimeInterval(2)) { _, _ in
            .completed(outputRefs: ["ok"], provenanceRef: finalProv, auditRef: nil)
        }

        let inspected = try await runtime.inspectJob(id: job.id)
        XCTAssertEqual(inspected.1?.attempts.count, 2)
        XCTAssertEqual(inspected.0.provenanceRefs.count, 1)
    }

    func testObservabilityEventsEmittedAndNoDirectIdentifierLeak() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob())
        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .completed(outputRefs: ["out"], provenanceRef: nil, auditRef: nil)
        }

        let events = await runtime.observabilityEvents()
        XCTAssertTrue(events.contains { $0.kind == .enqueued })
        XCTAssertTrue(events.contains { $0.kind == .started })
        XCTAssertTrue(events.contains { $0.kind == .completed })
        XCTAssertFalse(events.contains { $0.source.lowercased().contains("cpf") })
    }

    func testFailureDeadLetterEventsEmitted() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(maxRetries: 0))
        _ = try await runtime.runJob(id: job.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .internalFailure, message: "boom"), retryable: false)
        }

        let events = await runtime.observabilityEvents()
        XCTAssertTrue(events.contains { $0.kind == .failed })
        XCTAssertTrue(events.contains { $0.kind == .deadLettered })
    }

    func testAppCannotSubmitSensitiveJobWithoutCoreMediation() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        do {
            _ = try await runtime.enqueue(makeJob(sensitive: true, source: .app))
            XCTFail("Expected app boundary deny")
        } catch {
            XCTAssertEqual(error as? AsyncJobRuntimeError, .appBoundaryDenied)
        }
    }

    func testAACICannotBypassJobPolicy() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let job = try await runtime.enqueue(makeJob(sensitive: true, source: .aaci, layer: .directIdentifiers))

        let result = try await runtime.runJob(id: job.id, lawfulContext: makeLawfulContext(scope: "operational")) { _, _ in
            XCTFail("Execution must be policy denied")
            return .completed(outputRefs: [], provenanceRef: nil, auditRef: nil)
        }

        XCTAssertEqual(result.state, .deadLetter)
    }

    func testGOSCannotAuthorizeSensitiveJob() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        do {
            _ = try await runtime.enqueue(makeJob(sensitive: true, source: .gos))
            XCTFail("Expected GOS boundary deny")
        } catch {
            XCTAssertEqual(error as? AsyncJobRuntimeError, .gosBoundaryDenied)
        }
    }

    func testProviderRemoteJobDeniedWithoutExplicitPolicy() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        do {
            _ = try await runtime.enqueue(
                makeJob(
                    kind: .providerEvaluation,
                    source: .system,
                    allowsRemoteProvider: false
                )
            )
            XCTFail("Expected missing provider policy deny")
        } catch {
            XCTAssertEqual(error as? AsyncJobRuntimeError, .missingProviderPolicy)
        }
    }

    func testOperatorSurfaceListInspectCancelRequeueAndHealthSummary() async throws {
        let runtime = InMemoryAsyncJobRuntime()
        let pending = try await runtime.enqueue(makeJob())
        let failing = try await runtime.enqueue(makeJob(maxRetries: 0))

        _ = try await runtime.cancelPendingJob(id: pending.id, actor: "operator.1")
        _ = try await runtime.runJob(id: failing.id, lawfulContext: nil) { _, _ in
            .failed(AsyncJobFailure(kind: .internalFailure, message: "dead"), retryable: false)
        }

        _ = try await runtime.requeueDeadLetter(id: failing.id, actor: "operator.1")
        let listed = await runtime.listJobs()
        XCTAssertEqual(listed.count, 2)

        let inspected = try await runtime.inspectJob(id: failing.id)
        XCTAssertEqual(inspected.0.state, .pending)

        let health = await runtime.healthSummary()
        XCTAssertEqual(health.pending, 1)
    }
}
