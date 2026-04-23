# TODO — Ops, network, providers, ML

## COMPLETED

### OPS-004 Clarify online-only mesh doctrine and sovereign fabric projection
Outcome:
- networking/mesh doctrine now states online-only access posture and rejects offline-mode drift
- topology vocabulary now distinguishes single-node bootstrap minimum from sovereign fabric production projection
Files touched:
- `docs/architecture/04-networking.md`
- `docs/architecture/15-mesh-provider.md`
- `docs/adr/0009-single-node-bootstrap-and-sovereign-fabric-topology.md`

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

### OPS-002 Define operator dashboards/minimum observability contract
Outcome:
- minimum operator visibility indicators and alert classes defined
Files touched:
- `docs/architecture/26-operator-observability-contract.md`
- `docs/architecture/14-operations-runbook.md`

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

### ML-003 Define benchmark threshold policy by task class
Outcome:
- explicit threshold guidance added by task class for provider selection decisions
Files touched:
- `docs/architecture/27-provider-threshold-policy.md`
- `docs/architecture/16-providers-and-ml.md`

## READY

### OPS-003 Define incident-response command set for first operator tools
Objective:
- list canonical operator actions for runtime failure, queue saturation, backup concern, and integrity incident handling
Files:
- `docs/architecture/14-operations-runbook.md`
- `docs/architecture/26-operator-observability-contract.md`
Dependencies:
- OPS-001, OPS-002
Definition of done:
- first operator tooling can map visible incidents to explicit action vocabulary

## TESTS / VALIDATION

- no public data service exposure by default
- restore path is documented
- ML pipeline remains offline boundary, not accidental production runtime
