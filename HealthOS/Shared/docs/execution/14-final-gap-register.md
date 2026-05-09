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
| GAP-001 | RESOLVED | Cross-Stage surfaces | Cross-Stage shared envelope/safe-ref propagation was reconciled through APP-008 evidence. Remaining Veridia/CloudClinic work is Stage session wiring, not an RC blocker. ADR-0013 now blocks new Stage wiring until upstream mediated surfaces and Customs are ready. | scaffolded contract / tested operational path | medium | resolved | medium | Stage wiring phase after Core/GOS/runtime/Boundary/Custom readiness | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore` + future Stage adapters | Swift Boundary tests for Veridia/CloudClinic adapter wiring |
| GAP-002 | RESOLVED | Network / Ops | Incident-response command vocabulary was reconciled through OPS-003 evidence. This remains vocabulary/runbook posture, not an implemented operator console. | doctrine-only / scaffolded contract | medium | resolved | medium | Post-scaffold operator tooling | `HealthOS/Shared/docs/architecture/14-operations-runbook.md`, `26-operator-observability-contract.md` | doc drift pass + command vocabulary consistency check |
| GAP-003 | post-scaffold hardening | Data/storage | SQL/object backends are complementary query/index/projection substrates. They are not parity replacements for file-backed canonical record storage. File-backed storage with `lawfulContext` validation is permanent canonical record design per `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md`. Future SQL/object adapters must preserve `lawfulContext` and storage layer semantics. Current gap: no SQL/object adapter with full lawfulContext/layer enforcement exists beyond local file-backed paths. | tested operational path (local file-backed) | medium | low | high (for query/index/projection workloads requiring SQL) | Post-scaffold hardening 01: complementary backend hardening | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift`, future SQL/object adapters | layer-semantics and lawfulContext parity tests for SQL/object adapters (not parity replacement tests) |
| GAP-004 | production requirement | Providers/ML | No real external provider integrations (LM/STT/embedding); only governed stubs. | scaffolded contract / implemented seam | medium | low | high | Product phase: provider onboarding | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/*` | integration tests with policy-denial coverage |
| GAP-005 | production requirement | Retrieval/memory | No embedding/vector index stack; semantic retrieval remains unavailable/degraded by design. | scaffolded contract / implemented seam | medium | low | high | Product phase: semantic retrieval foundation | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RetrievalMemoryGovernance.swift` | evaluation harness + semantic precision/recall tests |
| GAP-006 | production requirement | Async runtime | Distributed worker execution and transactional idempotency locks are not implemented. | implemented seam / tested operational path (local) | medium | low | high | Post-scaffold hardening 02 | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/AsyncRuntimeJobs.swift` + infra adapters | stress/retry/idempotency consistency tests |
| GAP-007 | production requirement | Backup/DR | Operational restore drills and automated DR evidence are not implemented. | scaffolded contract / tested operational path | high | low | high | Post-scaffold hardening 03 | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/BackupGovernance.swift` + ops automation | scripted restore rehearsal + integrity audit proof |
| GAP-008 | regulatory/legal requirement | Signature/interoperability | Real qualified signature provider + legal endpoint integration absent; current delivery is placeholder-only. | scaffolded contract / tested operational path | high | low | high | Regulatory integration phase | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift` | legal profile conformance tests (without false claims) |
| GAP-009 | post-scaffold hardening | User/Service runtimes | Runtime-boundary adapter coverage improved through RT-008, but user/service runtime paths still need deeper adapter and persistence coverage beyond boundary negatives. | scaffolded contract / tested operational path (boundary) | medium | low | medium | Post-scaffold runtime adapter hardening | runtime adapter packages + Swift tests | dedicated adapter and persistence negative test expansion |
| GAP-010 | optional enhancement | Repository governance | CI-distributed execution of validate-all gates is pending; current posture is local-only. | tested operational path (local) | low | low | medium | Post-scaffold hardening 04 | CI pipeline config + scripts | CI run evidence mirroring local harness |

## Apple-native implementation track

These notes document permitted Apple-native substrate directions for GAP-003 through GAP-010 without changing closure classification or maturity. `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md` is the canonical architecture reference for this track.

- **GAP-003:** SwiftData may serve governed projection/index workloads; canonical custody remains file-backed and every projection must preserve canonical refs, lawfulContext hash, provenance ref, storage layer, and schema/degraded posture. CloudKit may sync governed projections only after Core policy exists.
- **GAP-004:** FoundationModels remains the primary Apple-native language-model provider seam behind `HealthOSProviders` / `ProviderRouter`; NaturalLanguage, Core ML, and Speech adapters must declare capability profiles, deny direct identifiers/reidentification mapping by default, and emit provider provenance.
- **GAP-005:** Semantic retrieval starts with local NaturalLanguage preprocessing, bounded file-backed embedding index, governed Core ML embedding adapters, and evaluation harness evidence; no external vector DB is the first implementation and no semantic retrieval claim is allowed before evaluation.
- **GAP-006:** Local in-process execution cells precede XPC worker transport; XPC precedes ServiceManagement lifecycle; every job requires lawfulContext, idempotency, peer identity validation where applicable, and failed/degraded provenance.
- **GAP-007:** AppleArchive + CryptoKit may provide evidence archive, backup, export, integrity envelope, and restore dry-run substrate; manifests, archive hashes, verification before restore, and lawfulContext checks are mandatory.
- **GAP-008:** CryptoKit internal signatures may harden artifact integrity and regulatory state-machine transitions, but they must not be named or treated as legal/qualified/regulatory signatures unless a real qualified provider integration exists.
- **GAP-009:** Runtime-boundary adapters may expose Apple-backed app-safe projections or service results, but Stage packages consume them only through `CustomSDK` and `HealthOSBoundary`; direct Tier 2 imports and direct Apple authority framework calls remain blocked.
- **GAP-010:** Xcode Cloud may run deterministic validation, but local CLI validation remains required; CI run evidence or artifacts must be recorded before maturity language changes.

## Closure interpretation

- GAP-001 and GAP-002 are **resolved for scaffold/foundation phase RC tracking** after APP-008 and OPS-003 evidence was reconciled. They are no longer current strict-closure blockers.
- Remaining gaps are explicitly accepted for later HealthOS maturity/product hardening phases and must remain non-claims in all entry docs.
