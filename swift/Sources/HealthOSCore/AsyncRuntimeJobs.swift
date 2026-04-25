import Foundation

public enum AsyncJobState: String, Codable, Sendable {
    case pending
    case leased
    case running
    case completed
    case failed
    case retryScheduled = "retry_scheduled"
    case cancelled
    case deadLetter = "dead_letter"
}

public enum AsyncJobPriority: String, Codable, Sendable {
    case low
    case normal
    case high
    case critical

    var rank: Int {
        switch self {
        case .critical: return 0
        case .high: return 1
        case .normal: return 2
        case .low: return 3
        }
    }
}

public enum AsyncJobKind: String, Codable, Sendable {
    case indexing
    case embeddingGeneration = "embedding_generation"
    case retrievalIndexMaintenance = "retrieval_index_maintenance"
    case provenanceEnrichment = "provenance_enrichment"
    case auditExport = "audit_export"
    case backup
    case restoreValidation = "restore_validation"
    case providerEvaluation = "provider_evaluation"
    case fineTuningOffline = "fine_tuning_offline"
    case lifecycleMaintenance = "lifecycle_maintenance"
    case agentMailboxDispatch = "agent_mailbox_dispatch"
    case maintenance
}

public enum AsyncJobFailureKind: String, Codable, Sendable {
    case policyDenied = "policy_denied"
    case validationFailed = "validation_failed"
    case dependencyFailure = "dependency_failure"
    case timeout = "timeout"
    case transportFailure = "transport_failure"
    case internalFailure = "internal_failure"
    case cancelled = "cancelled"
}

public enum JobSubmissionSource: String, Codable, Sendable {
    case `operator`
    case system
    case aaci
    case app
    case gos
}

public struct AsyncJobLawfulContextRequirement: Codable, Sendable, Equatable {
    public let requireLawfulContext: Bool
    public let requireFinalidade: Bool
    public let requireConsent: Bool
    public let requireHabilitation: Bool
    public let requirePatientContext: Bool
    public let requireServiceContext: Bool

    public init(
        requireLawfulContext: Bool = false,
        requireFinalidade: Bool = false,
        requireConsent: Bool = false,
        requireHabilitation: Bool = false,
        requirePatientContext: Bool = false,
        requireServiceContext: Bool = false
    ) {
        self.requireLawfulContext = requireLawfulContext
        self.requireFinalidade = requireFinalidade
        self.requireConsent = requireConsent
        self.requireHabilitation = requireHabilitation
        self.requirePatientContext = requirePatientContext
        self.requireServiceContext = requireServiceContext
    }

    public static var none: AsyncJobLawfulContextRequirement { .init() }
}

public struct AsyncJobRetryPolicy: Codable, Sendable, Equatable {
    public enum Backoff: String, Codable, Sendable {
        case fixed
        case exponential
    }

    public let maxRetries: Int
    public let baseDelaySeconds: Int
    public let backoff: Backoff
    public let automaticRetryAllowed: Bool

    public init(maxRetries: Int, baseDelaySeconds: Int = 5, backoff: Backoff = .exponential, automaticRetryAllowed: Bool = true) {
        self.maxRetries = max(0, maxRetries)
        self.baseDelaySeconds = max(1, baseDelaySeconds)
        self.backoff = backoff
        self.automaticRetryAllowed = automaticRetryAllowed
    }

    public func delaySeconds(forAttempt retryCount: Int) -> Int {
        switch backoff {
        case .fixed:
            return baseDelaySeconds
        case .exponential:
            return baseDelaySeconds * Int(pow(2.0, Double(max(0, retryCount - 1))))
        }
    }
}

public struct AsyncJobDescriptor: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let kind: AsyncJobKind
    public let requestedByActor: String
    public let submissionSource: JobSubmissionSource
    public let lawfulContextRequirement: AsyncJobLawfulContextRequirement
    public let dataLayersTouched: [StorageLayer]
    public let inputRefs: [String]
    public var outputRefs: [String]
    public let idempotencyKey: String
    public let priority: AsyncJobPriority
    public let createdAt: Date
    public var scheduledAt: Date?
    public var startedAt: Date?
    public var completedAt: Date?
    public var failedAt: Date?
    public var retryCount: Int
    public let retryPolicy: AsyncJobRetryPolicy
    public var state: AsyncJobState
    public var provenanceRefs: [UUID]
    public var auditRefs: [UUID]
    public let idempotent: Bool
    public let allowsRemoteProvider: Bool

    public init(
        id: UUID = UUID(),
        kind: AsyncJobKind,
        requestedByActor: String,
        submissionSource: JobSubmissionSource,
        lawfulContextRequirement: AsyncJobLawfulContextRequirement,
        dataLayersTouched: [StorageLayer],
        inputRefs: [String],
        outputRefs: [String] = [],
        idempotencyKey: String,
        priority: AsyncJobPriority = .normal,
        createdAt: Date = .now,
        scheduledAt: Date? = nil,
        retryPolicy: AsyncJobRetryPolicy,
        state: AsyncJobState = .pending,
        provenanceRefs: [UUID] = [],
        auditRefs: [UUID] = [],
        idempotent: Bool,
        allowsRemoteProvider: Bool = false
    ) {
        self.id = id
        self.kind = kind
        self.requestedByActor = requestedByActor
        self.submissionSource = submissionSource
        self.lawfulContextRequirement = lawfulContextRequirement
        self.dataLayersTouched = dataLayersTouched
        self.inputRefs = inputRefs
        self.outputRefs = outputRefs
        self.idempotencyKey = idempotencyKey
        self.priority = priority
        self.createdAt = createdAt
        self.scheduledAt = scheduledAt
        self.retryPolicy = retryPolicy
        self.state = state
        self.provenanceRefs = provenanceRefs
        self.auditRefs = auditRefs
        self.retryCount = 0
        self.startedAt = nil
        self.completedAt = nil
        self.failedAt = nil
        self.idempotent = idempotent
        self.allowsRemoteProvider = allowsRemoteProvider
    }

    public var touchesDirectIdentifiers: Bool {
        dataLayersTouched.contains(.directIdentifiers)
    }

    public var touchesReidentificationMapping: Bool {
        dataLayersTouched.contains(.reidentificationMapping)
    }

    public var isSensitive: Bool {
        lawfulContextRequirement.requireLawfulContext ||
        touchesDirectIdentifiers ||
        touchesReidentificationMapping ||
        lawfulContextRequirement.requireConsent ||
        lawfulContextRequirement.requireHabilitation
    }
}

public struct AsyncJobFailure: Codable, Sendable, Equatable {
    public let kind: AsyncJobFailureKind
    public let message: String
    public let at: Date

    public init(kind: AsyncJobFailureKind, message: String, at: Date = .now) {
        self.kind = kind
        self.message = message
        self.at = at
    }
}

public struct AsyncJobAttemptRecord: Codable, Sendable, Equatable {
    public let attempt: Int
    public let startedAt: Date
    public let finishedAt: Date
    public let failure: AsyncJobFailure?
    public let provenanceRef: UUID?
    public let auditRef: UUID?
}

public struct AsyncJobExecutionRecord: Codable, Sendable, Equatable {
    public let jobId: UUID
    public var attempts: [AsyncJobAttemptRecord]
    public var lastFailure: AsyncJobFailure?

    public init(jobId: UUID, attempts: [AsyncJobAttemptRecord] = [], lastFailure: AsyncJobFailure? = nil) {
        self.jobId = jobId
        self.attempts = attempts
        self.lastFailure = lastFailure
    }
}

public enum AsyncJobEventKind: String, Codable, Sendable {
    case enqueued = "job.enqueued"
    case started = "job.started"
    case completed = "job.completed"
    case failed = "job.failed"
    case retryScheduled = "job.retry_scheduled"
    case deadLettered = "job.dead_lettered"
    case cancelled = "job.cancelled"
    case policyDenied = "job.policy_denied"
    case idempotencyReused = "job.idempotency_reused"
}

public struct AsyncJobObservabilityEvent: Codable, Sendable, Equatable, Identifiable {
    public let id: UUID
    public let kind: AsyncJobEventKind
    public let jobId: UUID
    public let jobKind: AsyncJobKind
    public let state: AsyncJobState
    public let source: String
    public let timestamp: Date
    public let failureKind: AsyncJobFailureKind?
    public let provenanceRef: UUID?

    public init(
        id: UUID = UUID(),
        kind: AsyncJobEventKind,
        jobId: UUID,
        jobKind: AsyncJobKind,
        state: AsyncJobState,
        source: String,
        timestamp: Date = .now,
        failureKind: AsyncJobFailureKind? = nil,
        provenanceRef: UUID? = nil
    ) {
        self.id = id
        self.kind = kind
        self.jobId = jobId
        self.jobKind = jobKind
        self.state = state
        self.source = source
        self.timestamp = timestamp
        self.failureKind = failureKind
        self.provenanceRef = provenanceRef
    }
}

public struct AsyncJobHealthSummary: Sendable, Equatable {
    public let pending: Int
    public let running: Int
    public let retryScheduled: Int
    public let failed: Int
    public let deadLetter: Int
}

public enum AsyncJobRunResult: Sendable {
    case completed(outputRefs: [String], provenanceRef: UUID?, auditRef: UUID?)
    case failed(AsyncJobFailure, retryable: Bool)
}

public enum AsyncJobRuntimeError: Error, LocalizedError, Sendable, Equatable {
    case invalidTransition(from: AsyncJobState, to: AsyncJobState)
    case missingLawfulContext
    case reidentificationScopeRequired
    case directIdentifierScopeRequired
    case missingConsentBasis
    case missingProviderPolicy
    case appBoundaryDenied
    case gosBoundaryDenied
    case duplicateIdempotencyKeyExistingJob(UUID)
    case notFound(UUID)
    case cancelNotAllowed(AsyncJobState)
    case requeueNotAllowed(AsyncJobState)

    public var errorDescription: String? {
        switch self {
        case .invalidTransition(let from, let to):
            return "Invalid async job transition: \(from.rawValue) -> \(to.rawValue)."
        case .missingLawfulContext:
            return "Lawful context is required for this async job."
        case .reidentificationScopeRequired:
            return "Reidentification mapping jobs require scope = reidentification-governance."
        case .directIdentifierScopeRequired:
            return "Direct identifier jobs require governed direct-identifier scope."
        case .missingConsentBasis:
            return "Sensitive async job requires explicit consent basis."
        case .missingProviderPolicy:
            return "Provider evaluation job denied without explicit remote provider policy."
        case .appBoundaryDenied:
            return "App source cannot directly enqueue sensitive async jobs."
        case .gosBoundaryDenied:
            return "GOS source cannot authorize sensitive async jobs."
        case .duplicateIdempotencyKeyExistingJob(let existing):
            return "Idempotency key already belongs to job \(existing)."
        case .notFound(let id):
            return "Async job not found: \(id)."
        case .cancelNotAllowed(let state):
            return "Job cancellation is not allowed in state \(state.rawValue)."
        case .requeueNotAllowed(let state):
            return "Job requeue is only allowed from dead letter, got \(state.rawValue)."
        }
    }
}

public enum AsyncJobStateMachine {
    public static func canTransition(from: AsyncJobState, to: AsyncJobState) -> Bool {
        switch (from, to) {
        case (.pending, .leased),
             (.pending, .cancelled),
             (.leased, .running),
             (.running, .completed),
             (.running, .failed),
             (.failed, .retryScheduled),
             (.failed, .deadLetter),
             (.retryScheduled, .leased),
             (.pending, .deadLetter),
             (.retryScheduled, .cancelled):
            return true
        default:
            return false
        }
    }

    public static func requireTransition(from: AsyncJobState, to: AsyncJobState) throws {
        guard canTransition(from: from, to: to) else {
            throw AsyncJobRuntimeError.invalidTransition(from: from, to: to)
        }
    }
}

public actor InMemoryAsyncJobRuntime {
    private var jobs: [UUID: AsyncJobDescriptor] = [:]
    private var records: [UUID: AsyncJobExecutionRecord] = [:]
    private var events: [AsyncJobObservabilityEvent] = []
    private var idempotencyKeys: [String: UUID] = [:]

    public init() {}

    @discardableResult
    public func enqueue(_ descriptor: AsyncJobDescriptor) throws -> AsyncJobDescriptor {
        if descriptor.isSensitive && descriptor.submissionSource == .app {
            throw AsyncJobRuntimeError.appBoundaryDenied
        }
        if descriptor.isSensitive && descriptor.submissionSource == .gos {
            throw AsyncJobRuntimeError.gosBoundaryDenied
        }
        if descriptor.kind == .providerEvaluation && descriptor.allowsRemoteProvider == false {
            throw AsyncJobRuntimeError.missingProviderPolicy
        }

        if let existingId = idempotencyKeys[descriptor.idempotencyKey],
           let existing = jobs[existingId] {
            if existing.state == .completed {
                emit(.idempotencyReused, job: existing, failure: nil, provenanceRef: existing.provenanceRefs.last)
                return existing
            }
            throw AsyncJobRuntimeError.duplicateIdempotencyKeyExistingJob(existingId)
        }

        jobs[descriptor.id] = descriptor
        records[descriptor.id] = AsyncJobExecutionRecord(jobId: descriptor.id)
        idempotencyKeys[descriptor.idempotencyKey] = descriptor.id
        emit(.enqueued, job: descriptor)
        return descriptor
    }

    public func listJobs(state: AsyncJobState? = nil) -> [AsyncJobDescriptor] {
        let values = Array(jobs.values)
        let filtered = state.map { status in values.filter { $0.state == status } } ?? values
        return filtered.sorted { lhs, rhs in
            if lhs.priority.rank != rhs.priority.rank {
                return lhs.priority.rank < rhs.priority.rank
            }
            return lhs.createdAt < rhs.createdAt
        }
    }

    public func inspectJob(id: UUID) throws -> (AsyncJobDescriptor, AsyncJobExecutionRecord?) {
        guard let descriptor = jobs[id] else { throw AsyncJobRuntimeError.notFound(id) }
        return (descriptor, records[id])
    }

    @discardableResult
    public func cancelPendingJob(id: UUID, actor: String) throws -> AsyncJobDescriptor {
        guard var descriptor = jobs[id] else { throw AsyncJobRuntimeError.notFound(id) }
        guard descriptor.state == .pending || descriptor.state == .retryScheduled else {
            throw AsyncJobRuntimeError.cancelNotAllowed(descriptor.state)
        }
        try AsyncJobStateMachine.requireTransition(from: descriptor.state, to: .cancelled)
        descriptor.state = .cancelled
        descriptor.failedAt = .now
        jobs[id] = descriptor
        appendAttempt(jobId: id, failure: AsyncJobFailure(kind: .cancelled, message: "Cancelled by \(actor)"), provenanceRef: nil, auditRef: nil)
        emit(.cancelled, job: descriptor, failure: .cancelled)
        return descriptor
    }

    @discardableResult
    public func requeueDeadLetter(id: UUID, actor: String) throws -> AsyncJobDescriptor {
        guard var descriptor = jobs[id] else { throw AsyncJobRuntimeError.notFound(id) }
        guard descriptor.state == .deadLetter else {
            throw AsyncJobRuntimeError.requeueNotAllowed(descriptor.state)
        }
        descriptor.state = .pending
        descriptor.scheduledAt = .now
        descriptor.failedAt = nil
        jobs[id] = descriptor
        emit(.enqueued, job: descriptor)
        return descriptor
    }

    @discardableResult
    public func runJob(
        id: UUID,
        lawfulContext: [String: String]?,
        now: Date = .now,
        execute: @Sendable (AsyncJobDescriptor, Int) async -> AsyncJobRunResult
    ) async throws -> AsyncJobDescriptor {
        guard var descriptor = jobs[id] else { throw AsyncJobRuntimeError.notFound(id) }

        try ensureTransition(&descriptor, to: .leased)
        try ensureTransition(&descriptor, to: .running)
        descriptor.startedAt = now
        jobs[id] = descriptor
        emit(.started, job: descriptor)

        do {
            try validateLawfulContext(for: descriptor, lawfulContext: lawfulContext)
        } catch {
            let failure = AsyncJobFailure(kind: .policyDenied, message: error.localizedDescription, at: now)
            descriptor = applyFailure(
                descriptor: descriptor,
                failure: failure,
                retryable: false,
                now: now,
                emitPolicyDenied: true
            )
            jobs[id] = descriptor
            return descriptor
        }

        let attempt = descriptor.retryCount + 1
        let result = await execute(descriptor, attempt)
        switch result {
        case .completed(let outputRefs, let provenanceRef, let auditRef):
            try ensureTransition(&descriptor, to: .completed)
            descriptor.state = .completed
            descriptor.completedAt = now
            descriptor.outputRefs = outputRefs
            if let provenanceRef { descriptor.provenanceRefs.append(provenanceRef) }
            if let auditRef { descriptor.auditRefs.append(auditRef) }
            appendAttempt(jobId: descriptor.id, failure: nil, provenanceRef: provenanceRef, auditRef: auditRef)
            jobs[id] = descriptor
            emit(.completed, job: descriptor, provenanceRef: provenanceRef)
            return descriptor

        case .failed(let failure, let retryable):
            descriptor = applyFailure(
                descriptor: descriptor,
                failure: failure,
                retryable: retryable,
                now: now
            )
            jobs[id] = descriptor
            return descriptor
        }
    }

    @discardableResult
    public func runNext(
        lawfulContext: [String: String]?,
        now: Date = .now,
        execute: @Sendable (AsyncJobDescriptor, Int) async -> AsyncJobRunResult
    ) async throws -> AsyncJobDescriptor? {
        let candidate = jobs.values
            .filter { $0.state == .pending || $0.state == .retryScheduled }
            .filter { descriptor in
                guard let scheduledAt = descriptor.scheduledAt else { return true }
                return scheduledAt <= now
            }
            .sorted { lhs, rhs in
                if lhs.priority.rank != rhs.priority.rank {
                    return lhs.priority.rank < rhs.priority.rank
                }
                return lhs.createdAt < rhs.createdAt
            }
            .first

        guard let candidate else { return nil }
        return try await runJob(id: candidate.id, lawfulContext: lawfulContext, now: now, execute: execute)
    }

    public func healthSummary() -> AsyncJobHealthSummary {
        var pending = 0
        var running = 0
        var retryScheduled = 0
        var failed = 0
        var deadLetter = 0

        for job in jobs.values {
            switch job.state {
            case .pending: pending += 1
            case .leased, .running: running += 1
            case .retryScheduled: retryScheduled += 1
            case .failed: failed += 1
            case .deadLetter: deadLetter += 1
            case .completed, .cancelled: break
            }
        }

        return AsyncJobHealthSummary(
            pending: pending,
            running: running,
            retryScheduled: retryScheduled,
            failed: failed,
            deadLetter: deadLetter
        )
    }

    public func observabilityEvents() -> [AsyncJobObservabilityEvent] {
        events
    }

    private func ensureTransition(_ descriptor: inout AsyncJobDescriptor, to nextState: AsyncJobState) throws {
        try AsyncJobStateMachine.requireTransition(from: descriptor.state, to: nextState)
        descriptor.state = nextState
    }

    private func validateLawfulContext(for descriptor: AsyncJobDescriptor, lawfulContext: [String: String]?) throws {
        guard descriptor.isSensitive || descriptor.lawfulContextRequirement.requireLawfulContext else {
            return
        }

        guard let lawfulContext else { throw AsyncJobRuntimeError.missingLawfulContext }

        let requirements = LawfulContextRequirement(
            requireServiceId: descriptor.lawfulContextRequirement.requireServiceContext,
            requirePatientUserId: descriptor.lawfulContextRequirement.requirePatientContext,
            requireHabilitationId: descriptor.lawfulContextRequirement.requireHabilitation,
            requireFinalidade: descriptor.lawfulContextRequirement.requireFinalidade
        )
        let validated = try LawfulContextValidator.validate(lawfulContext, requirements: requirements)

        if descriptor.touchesReidentificationMapping && validated.scope != "reidentification-governance" {
            throw AsyncJobRuntimeError.reidentificationScopeRequired
        }

        if descriptor.touchesDirectIdentifiers {
            let allowedScopes: Set<String> = ["direct-identifiers-governance", "reidentification-governance"]
            if !allowedScopes.contains(validated.scope) {
                throw AsyncJobRuntimeError.directIdentifierScopeRequired
            }
        }

        if descriptor.lawfulContextRequirement.requireConsent {
            let consentBasis = lawfulContext["consentBasis"]?.trimmingCharacters(in: .whitespacesAndNewlines)
            if consentBasis == nil || consentBasis?.isEmpty == true {
                throw AsyncJobRuntimeError.missingConsentBasis
            }
        }
    }

    private func applyFailure(
        descriptor: AsyncJobDescriptor,
        failure: AsyncJobFailure,
        retryable: Bool,
        now: Date,
        emitPolicyDenied: Bool = false
    ) -> AsyncJobDescriptor {
        var mutated = descriptor
        try? ensureTransition(&mutated, to: .failed)
        mutated.failedAt = now
        mutated.retryCount += 1
        appendAttempt(jobId: mutated.id, failure: failure, provenanceRef: nil, auditRef: nil)

        if emitPolicyDenied {
            emit(.policyDenied, job: mutated, failure: failure.kind)
        }
        emit(.failed, job: mutated, failure: failure.kind)

        let shouldRetry = retryable &&
            mutated.idempotent &&
            mutated.retryPolicy.automaticRetryAllowed &&
            mutated.retryCount <= mutated.retryPolicy.maxRetries

        if shouldRetry {
            try? ensureTransition(&mutated, to: .retryScheduled)
            let backoff = mutated.retryPolicy.delaySeconds(forAttempt: mutated.retryCount)
            mutated.scheduledAt = now.addingTimeInterval(Double(backoff))
            emit(.retryScheduled, job: mutated, failure: failure.kind)
            jobs[mutated.id] = mutated
            return mutated
        }

        try? ensureTransition(&mutated, to: .deadLetter)
        emit(.deadLettered, job: mutated, failure: failure.kind)
        jobs[mutated.id] = mutated
        return mutated
    }

    private func appendAttempt(jobId: UUID, failure: AsyncJobFailure?, provenanceRef: UUID?, auditRef: UUID?) {
        guard var record = records[jobId] else { return }
        let attempt = record.attempts.count + 1
        let timestamp = failure?.at ?? .now
        record.attempts.append(
            AsyncJobAttemptRecord(
                attempt: attempt,
                startedAt: timestamp,
                finishedAt: timestamp,
                failure: failure,
                provenanceRef: provenanceRef,
                auditRef: auditRef
            )
        )
        record.lastFailure = failure
        records[jobId] = record
    }

    private func emit(_ kind: AsyncJobEventKind, job: AsyncJobDescriptor, failure: AsyncJobFailureKind? = nil, provenanceRef: UUID? = nil) {
        events.append(
            AsyncJobObservabilityEvent(
                kind: kind,
                jobId: job.id,
                jobKind: job.kind,
                state: job.state,
                source: job.requestedByActor,
                failureKind: failure,
                provenanceRef: provenanceRef
            )
        )
    }
}
