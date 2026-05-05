# Final gap register (scaffold/foundation phase RC closure audit)

Date baseline: April 26, 2026.

This register is the canonical list of remaining gaps after the HealthOS scaffold/foundation phase closure audit in the HealthOScaffold repository.
It is intentionally finite and actionable.

Post-scaffold gaps are work items for the next maturity phase of the same HealthOS project in this repository. Production requirements are future HealthOS hardening phases, not another product or repository.

## Gap categories

- `scaffold blocker`
- `post-scaffold hardening` (next HealthOS maturity phase)
- `production requirement`
- `regulatory/legal requirement`
- `optional enhancement`

## Gaps

| Gap ID | Category | Layer | Description | Current maturity | Risk | Scaffold closure impact | Production impact | Recommended next milestone | Owner/module | Validation needed |
|---|---|---|---|---|---|---|---|---|---|---|
| GAP-001 | RESOLVED | Cross-app surfaces | Cross-app shared envelope/safe-ref propagation was reconciled through APP-008 evidence. Remaining Veridia/CloudClinic work is app session wiring, not an RC blocker. | scaffolded contract / tested operational path | medium | resolved | medium | Product app wiring phase | `swift/Sources/HealthOSCore` + future app adapters | Swift boundary tests for Veridia/CloudClinic adapter wiring |
| GAP-002 | RESOLVED | Network / Ops | Incident-response command vocabulary was reconciled through OPS-003 evidence. This remains vocabulary/runbook posture, not an implemented operator console. | doctrine-only / scaffolded contract | medium | resolved | medium | Post-scaffold operator tooling | `docs/architecture/14-operations-runbook.md`, `26-operator-observability-contract.md` | doc drift pass + command vocabulary consistency check |
| GAP-003 | post-scaffold hardening | Data/storage | SQL/object backends are complementary query/index/projection substrates. They are not parity replacements for file-backed canonical record storage. File-backed storage with `lawfulContext` validation is permanent canonical record design per `docs/architecture/46-apple-sovereignty-architecture.md`. Future SQL/object adapters must preserve `lawfulContext` and storage layer semantics. Current gap: no SQL/object adapter with full lawfulContext/layer enforcement exists beyond local file-backed paths. | tested operational path (local file-backed) | medium | low | high (for query/index/projection workloads requiring SQL) | Post-scaffold hardening 01: complementary backend hardening | `swift/Sources/HealthOSCore/StorageContracts.swift`, future SQL/object adapters | layer-semantics and lawfulContext parity tests for SQL/object adapters (not parity replacement tests) |
| GAP-004 | production requirement | Providers/ML | No real external provider integrations (LM/STT/embedding); only governed stubs. | scaffolded contract / implemented seam | medium | low | high | Product phase: provider onboarding | `swift/Sources/HealthOSProviders/*` | integration tests with policy-denial coverage |
| GAP-005 | production requirement | Retrieval/memory | No embedding/vector index stack; semantic retrieval remains unavailable/degraded by design. | scaffolded contract / implemented seam | medium | low | high | Product phase: semantic retrieval foundation | `swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift` | evaluation harness + semantic precision/recall tests |
| GAP-006 | production requirement | Async runtime | Distributed worker execution and transactional idempotency locks are not implemented. | implemented seam / tested operational path (local) | medium | low | high | Post-scaffold hardening 02 | `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift` + infra adapters | stress/retry/idempotency consistency tests |
| GAP-007 | production requirement | Backup/DR | Operational restore drills and automated DR evidence are not implemented. | scaffolded contract / tested operational path | high | low | high | Post-scaffold hardening 03 | `swift/Sources/HealthOSCore/BackupGovernance.swift` + ops automation | scripted restore rehearsal + integrity audit proof |
| GAP-008 | regulatory/legal requirement | Signature/interoperability | Real qualified signature provider + legal endpoint integration absent; current delivery is placeholder-only. | scaffolded contract / tested operational path | high | low | high | Regulatory integration phase | `swift/Sources/HealthOSCore/RegulatoryGovernance.swift` | legal profile conformance tests (without false claims) |
| GAP-009 | post-scaffold hardening | User/Service runtimes | Runtime-boundary adapter coverage improved through RT-008, but user/service runtime paths still need deeper adapter and persistence coverage beyond boundary negatives. | scaffolded contract / tested operational path (boundary) | medium | low | medium | Post-scaffold runtime adapter hardening | runtime adapter packages + Swift tests | dedicated adapter and persistence negative test expansion |
| GAP-010 | optional enhancement | Repository governance | CI-distributed execution of validate-all gates is pending; current posture is local-only. | tested operational path (local) | low | low | medium | Post-scaffold hardening 04 | CI pipeline config + scripts | CI run evidence mirroring local harness |

## Closure interpretation

- GAP-001 and GAP-002 are **resolved for scaffold/foundation phase RC tracking** after APP-008 and OPS-003 evidence was reconciled. They are no longer current strict-closure blockers.
- Remaining gaps are explicitly accepted for later HealthOS maturity/product hardening phases and must remain non-claims in all entry docs.
