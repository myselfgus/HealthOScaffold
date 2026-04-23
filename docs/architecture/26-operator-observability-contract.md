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

## Alert classes
- warning
- critical
- informational

## Suggested alert mapping
- runtime degraded -> warning
- runtime failed -> critical
- backup stale -> critical
- restore untested -> warning
- integrity mismatch -> critical
- gate backlog saturation -> warning
