# Runtime operational policy

## Purpose

Define retry, backpressure, degradation, and visibility rules for HealthOS runtimes.

## Core principle

Operational failure behavior must preserve ontology.
A retry policy must never bypass consent, habilitation, gate, or provenance rules.

## Runtime-specific policy

### AACI hot path
Characteristics:
- latency-sensitive
- human is actively working
- interruption cost is high

Policy:
- prefer graceful degradation over aggressive retry
- at most one immediate retry for transient transport/dependency failures
- if still failing, emit explainable degraded state and continue session where possible
- never block the entire session UI waiting on a non-critical hot-path retry

Examples:
- partial transcript missing -> show degraded transcription state, allow continued work
- context retrieval timeout -> show missing-context state, allow manual retry

### AACI warm path
Characteristics:
- seconds/minutes acceptable
- draft composition/organization work

Policy:
- bounded retry allowed for transient failures
- exponential backoff permitted within short envelope
- if retries exhaust, convert work item into visible pending/error state
- require provenance note for retried draft-producing operations

### Async runtime
Characteristics:
- deferred, queue-based, non-interruptive to live work

Policy:
- retry policy is job-class specific
- exponential backoff permitted
- poison job threshold must exist
- failed jobs move to visible failed queue with diagnostics
- retries must preserve idempotency assumptions or explicitly record non-idempotent risk

### User-agent runtime
Characteristics:
- user-facing explanation and retrieval
- should prefer trust and intelligibility over hidden complexity

Policy:
- prefer explicit deny/explain over silent retry
- bounded retry only for clearly transient provider or transport issues
- never retry sensitive access escalation automatically

## Backpressure policy

### AACI hot path
- shed non-critical work first
- downgrade optional enrichment before core capture/transcription
- never allow warm/cold tasks to starve capture and gate review

### AACI warm path
- queue and defer when hot path is under pressure
- cap concurrent draft-generation tasks per session

### Async runtime
- queue depth thresholds should trigger degraded scheduling mode
- lower-priority jobs should be delayed before high-value clinical-operational jobs

### User-agent runtime
- cap concurrent conversational/retrieval expansions
- preserve auditability of deferred or denied actions

## Failure visibility

Every runtime should surface failures in one of these ways:
- degraded but continuing
- denied with explanation
- queued for retry
- failed and operator-visible

## Never do
- infinite retry
- hidden retry loops on sensitive access checks
- automatic escalation from denied to privileged path
- converting a failed retrieval into fabricated content without explicit degraded labeling
