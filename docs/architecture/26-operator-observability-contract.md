# Operator observability contract

## Purpose

Define the minimum operator-facing visibility required to run a single-node HealthOS safely.

## Minimum indicators

### Platform health
- core service reachability
- PostgreSQL reachability
- runtime health by runtime kind
- launchd service health

### Workload health
- async failed jobs count
- async deferred jobs count
- async dead-letter count
- async retry-scheduled count
- gate backlog count
- stale pending gates count
- stale drafts awaiting gate count

### Data safety
- backup freshness
- restore-test status
- storage integrity mismatch count
- last integrity audit time

### Operational pressure
- queue saturation indicator
- degraded-mode count by runtime/task class
- provider fallback count

## Interpretation rule
Operator dashboards may summarize operational truth.
They must not be treated as legal proof of access authorization or clinical completion.

## Minimum display surfaces
- summary panel
- failure panel
- queue/gate panel
- backup/restore panel
- integrity panel

## Async job event surface (implemented scaffold)
- `job.enqueued`
- `job.started`
- `job.completed`
- `job.failed`
- `job.retry_scheduled`
- `job.dead_lettered`
- `job.cancelled`
- `job.policy_denied`
- `job.idempotency_reused`

Event payload rule:
- include job id, job kind, state, source actor/system, timestamp
- include failure kind and provenance reference when present
- never include direct identifiers in observability event payloads

## Alert classes
- warning
- critical
- informational

## Incident → event kind → action mapping

| Incident Class | Canonical Event Kind(s) | Action Vocabulary |
| :--- | :--- | :--- |
| **Runtime failure** | `runtime.unhealthy`, `runtime.degraded` | `runtime.restart.requested` |
| **Queue saturation** | `job.queue.saturated` | `job.ingest.paused`, `job.dead-letter.inspect`, `job.requeue.requested` |
| **Backup concern** | `backup.integrity.mismatch`, `retention.legal_hold.conflict`, `backup.manifest.missing` | `restore.dry-run.only`, `retention.review.requested` |
| **Integrity incident** | `storage.hash.mismatch`, `deidentification.access.denied`, `reidentification.denial` | `storage.partition.frozen`, `export.audit.requested` |


## Backup / restore / export / retention / DR governance events (implemented scaffold)
- `backup.created`
- `backup.failed`
- `backup.integrity_verified`
- `restore.requested`
- `restore.validated`
- `restore.executed`
- `restore.failed`
- `export.requested`
- `export.created`
- `export.denied`
- `retention.decision`
- `retention.hold.applied`
- `dr.dry_run.completed`
- `dr.readiness.failed`

Payload posture:
- include operation id, actor/system id, scope, and failure kind when present
- include only non-sensitive attributes (no raw CPF, no direct identifier payloads, no secrets)
