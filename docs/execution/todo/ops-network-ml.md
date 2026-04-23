# TODO — Ops, network, providers, ML

## COMPLETED

### ML-001 Define provider benchmark and selection policy
Outcome:
- provider routing baseline, benchmark dimensions, and task-class policy outcomes documented
Files touched:
- `docs/architecture/16-providers-and-ml.md`

## READY AFTER PHASE 00

### OPS-001 Define single-node runbook
Objective:
- produce operator-facing steps for bootstrap, local services, logs, backup, restore, and upgrade checks
Files:
- `docs/architecture/14-operations-runbook.md`
- `ops/*`
Dependencies:
- none beyond phase 00
Definition of done:
- a new operator can bootstrap and inspect the node without guessing

### NET-001 Define MeshProvider abstraction and access policy
Objective:
- document MeshProvider contract and local/mesh exposure policy
Files:
- `docs/architecture/15-mesh-provider.md`
- `ops/network/*`
Dependencies:
- phase 00
Definition of done:
- private access rules are explicit and future mesh expansion does not alter ontology

### ML-002 Define fine-tuning governance
Objective:
- document dataset governance, adapter promotion, rollback, and offline-only safety policy
Files:
- `docs/architecture/16-providers-and-ml.md`
- `python/README.md`
- `python/healthos_ml/*`
Dependencies:
- ML-001
Definition of done:
- offline specialization path exists without contaminating online runtime assumptions

## TESTS / VALIDATION

- no public data service exposure by default
- restore path is documented
- ML pipeline remains offline boundary, not accidental production runtime
