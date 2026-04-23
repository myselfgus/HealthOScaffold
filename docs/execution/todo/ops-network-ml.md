# TODO — Ops, network, providers, ML

## COMPLETED

### OPS-001 Define single-node runbook
Outcome:
- operations runbook strengthened with bootstrap, daily/weekly checks, incident categories, and operator visibility surfaces
Files touched:
- `docs/architecture/14-operations-runbook.md`

### NET-001 Define MeshProvider abstraction and access policy
Outcome:
- MeshProvider contract strengthened with identity, ACL, health, and failure posture expectations
Files touched:
- `docs/architecture/15-mesh-provider.md`
- `ops/network/*`

### ML-001 Define provider benchmark and selection policy
Outcome:
- provider routing baseline, benchmark dimensions, task-class policy outcomes, and benchmark harness artifacts documented
Files touched:
- `docs/architecture/16-providers-and-ml.md`

### ML-002 Define fine-tuning governance
Outcome:
- dataset governance, adapter promotion path, rollback rule, and offline-only specialization posture documented
Files touched:
- `docs/architecture/16-providers-and-ml.md`
- `python/README.md`
- `python/healthos_ml/*`

## READY

### OPS-002 Define operator dashboards/minimum observability contract
Objective:
- specify which operational indicators must appear in technical/operator surfaces
Files:
- `docs/architecture/14-operations-runbook.md`
- optional future ops docs
Dependencies:
- OPS-001, NET-001
Definition of done:
- operator-facing observability expectations are explicit enough for implementation

### ML-003 Define benchmark threshold policy by task class
Objective:
- specify what counts as acceptable latency/quality/privacy tradeoff per task class
Files:
- `docs/architecture/16-providers-and-ml.md`
Dependencies:
- ML-001, ML-002
Definition of done:
- provider selection decisions can be justified against explicit thresholds rather than only descriptive dimensions

## TESTS / VALIDATION

- no public data service exposure by default
- restore path is documented
- ML pipeline remains offline boundary, not accidental production runtime
