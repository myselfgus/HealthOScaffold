# Current maturity map (2026-04-26)

Ladder: doctrine-only → scaffolded contract → implemented seam → tested operational path → production-hardened.

| Layer | Current maturity | Enforcement status | Test status | Production gap | Next logical work |
|---|---|---|---|---|---|
| Core law | tested operational path | fail-closed contracts for consent/habilitation/gate/finality/lawfulContext | Swift governance suites active | no multi-actor/RBAC workflow engine | propagate same guards to all runtime entrypoints |
| Data/storage | tested operational path | layer-aware guards + lawfulContext + append-only provenance | storage/reidentification tests present | no production key mgmt/distributed storage hardening | backend parity across future SQL/object services |
| GOS | tested operational path (scaffold hardening) | lifecycle/review/activation policy + subordinate binding | Swift + TS tests for lifecycle/tooling | no multi-node policy governance | strengthen semantic lint + distributed revocation |
| AACI | implemented seam / tested operational path (first slice) | draft-only + gate required + provenance checkpoints | AACI/first-slice tests and smoke | bounded to first-slice scope | expand non-slice runtime mode coverage |
| Providers/ML | scaffolded contract / implemented seam | capability routing + fail-closed remote policy + model/adaptor governance | Provider tests present | no real external provider integration | integrate real providers without weakening fail-closed policy |
| Retrieval/memory/index | scaffolded contract / implemented seam | governed retrieval + honest semantic unavailable posture | retrieval governance tests present | no embeddings/vector infra | integrate real embedding/index pipeline with same contracts |
| Async runtime | implemented seam / tested operational path (local) | lawfulContext, retry/idempotency, policy-denial events | async governance tests present | no distributed workers/transactional persistence | SQL-backed executor parity |
| Network/fabric | doctrine-only / scaffolded contract | private-mesh doctrine + ops posture documented | docs-level only | no production sovereign fabric implementation | operator command set and hardened ACL tooling |
| Backup/restore/export/retention | scaffolded contract / tested operational path | fail-closed governance validators in Core | backup governance tests present | no full operational automation | map contracts to persistent ops workflows |
| Regulatory/signature/interoperability/emergency | scaffolded contract / tested operational path | fail-closed validators + placeholder delivery posture | regulatory tests present | no real endpoint/signature provider integration | state-machine + role approval workflow hardening |
| User Agent / Sortio | scaffolded contract / tested operational path (boundary) | prohibited clinical capability + app-safe sovereignty surfaces | user sovereignty tests present | no final Sortio app/runtime shell | adapter/runtime wiring on existing contracts |
| Service Ops / CloudClinic | scaffolded contract / tested operational path (boundary) | service context/membership/queue/gate boundaries enforced | service operations tests present | no persisted workflow engine/UI shell | runtime adapter + persisted projections |
| Scribe | implemented seam / tested operational path (minimal UI) | professional workspace boundary + gate/finalization mediation | Scribe boundary tests + smoke path | not final product UI | incremental session state integration with full spine |
| Cross-app surfaces | scaffolded contract / tested operational path (contract) | shared envelope + safe refs + notification boundary validators | cross-app tests present | non-Scribe adapters incomplete | propagate envelope to all app adapters |
| Apps/UI overall | scaffolded contract / implemented seam (Scribe minimal) | app-boundary doctrine and contracts exist | mainly boundary tests | no final UX for three apps | continue adapter-first without moving law to UI |
| Validation harness | tested operational path (local) | fail-closed make/script gates for docs/schema/contracts/build/test/smoke + summary artifact | validate-all exercised locally | no CI/distributed gate yet | wire same harness into CI without inflating maturity claims |
| Operations | scaffolded contract | runbooks/launchd/network docs + observability taxonomy | mostly docs + smoke | no production ops automation | incident command set and operator tooling |

## Scaffold RC closure classification (audit sync)

| Layer | Closure classification |
|---|---|
| Core law | ready-for-scaffold-closure |
| Data/storage/identity | partial-but-acceptable-with-explicit-gap |
| GOS | ready-for-scaffold-closure |
| AACI | partial-but-acceptable-with-explicit-gap |
| Providers/ML | partial-but-acceptable-with-explicit-gap |
| Retrieval/memory/index | partial-but-acceptable-with-explicit-gap |
| Async runtime/jobs | ready-for-scaffold-closure |
| Network/mesh/fabric | needs-small-closure |
| Backup/restore/retention/export/DR | partial-but-acceptable-with-explicit-gap |
| Regulatory/signature/interoperability/emergency | partial-but-acceptable-with-explicit-gap |
| User Agent/Sortio | partial-but-acceptable-with-explicit-gap |
| Service Ops/CloudClinic | partial-but-acceptable-with-explicit-gap |
| Scribe | ready-for-scaffold-closure |
| Cross-app shared surfaces | needs-small-closure |
| Repository governance/validation | ready-for-scaffold-closure |

Source of truth for open blockers: `docs/execution/14-final-gap-register.md`.
