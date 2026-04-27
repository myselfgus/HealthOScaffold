# Operations runbook

## Single-node baseline
1. bootstrap local tree
2. provision PostgreSQL
3. configure launchd entries
4. verify local ports
5. verify logs
6. verify backup destination and restore process
7. verify mesh/VPN identity and ACL posture when enabled

## Bootstrap checklist
- create runtime-data tree
- confirm PostgreSQL reachable on loopback only
- confirm launchd entries point to correct binaries/paths
- confirm logs path writable
- confirm backup target exists and is encrypted

## Daily checks
- runtime health
- failed jobs
- gate backlog
- backup freshness
- storage growth
- queue saturation
- degraded-mode indicators

## Weekly checks
- restore drill sample
- integrity/audit spot check
- review failed async jobs
- review stale pending gates/drafts

## Incident-response command vocabulary

| Incident Class | Trigger Condition | Event Kind(s) | Canonical Response Action(s) | Escalation |
| :--- | :--- | :--- | :--- | :--- |
| **Runtime failure** | Node unhealthy/degraded | `runtime.unhealthy`, `runtime.degraded` | Isolate node, drain queue, trigger restart, emit `runtime.restart.requested` | Escalation to infrastructure team |
| **Queue saturation** | Backpressure breach | `job.queue.saturated` | Pause ingestion (`job.ingest.paused`), inspect dead-letter (`job.dead-letter.inspect`), requeue after drain (`job.requeue.requested`) | Escalation to service architecture |
| **Backup concern** | Integrity/Retention conflict | `backup.integrity.mismatch`, `retention.legal_hold.conflict`, `backup.manifest.missing` | Halt auto-restore (`restore.dry-run.only`), verify hash chain, escalate to policy review (`retention.review.requested`) | Escalation to compliance/legal |
| **Integrity incident** | Storage/Re-ID breach | `storage.hash.mismatch`, `deidentification.access.denied`, `reidentification.denial` | Freeze partition (`storage.partition.frozen`), audit export (`export.audit.requested`), deny reidentification | Escalation to security officer |


## Change discipline
- prefer staged upgrades
- review migrations before applying
- keep restore drills documented
- changes to governance or storage contract should update docs and ADRs together when architecture shifts

## Minimum operator visibility surfaces
- runtime health summary
- failed/deferred job count
- gate backlog count
- backup freshness indicator
- restore-test status
- integrity-check status

Detailed visibility doctrine lives in:
- `docs/architecture/26-operator-observability-contract.md`

## Governed backup/restore/export discipline (scaffold)
- backup, restore, and export operations are Core-mediated governance actions, not app/runtime direct storage actions
- backup manifests must include object refs + hashes + data-layer classification + retention/restore eligibility
- restore must validate manifest + hash integrity before destructive action; destructive restore requires explicit conflict policy
- direct identifiers and reidentification mappings require explicit elevated policy for backup/restore
- patient export does not include reidentification mapping by default and never bypasses lawfulContext
- restoring final documents requires preserved gate lineage; restore cannot auto-reactivate revoked lifecycle state by default
- encryption posture is explicit scaffold status (`scaffolded` / `required` / `notImplemented`), not production-crypto claim

## Operator command boundary
- operators may trigger governed backup/restore/export workflows
- operators are not implicitly granted clinical-access rights by running infra commands
- AACI and GOS are denied as control-plane decision authorities for backup/restore/export governance
