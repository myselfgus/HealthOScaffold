# Scaffold Release Candidate (RC) closure criteria

Date baseline: April 26, 2026.

This document defines when the **HealthOS scaffold/foundation phase in the HealthOScaffold repository is ready for closure**.
It does **not** define product launch readiness, production release, or a repository handoff away from HealthOS construction here.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

## Scaffold Done (objective criteria)

The foundation/scaffold phase can be considered RC-closure-ready only when all of the following are true:

1. Canonical architecture is coherent across `README.md`, `AGENTS.md`, `CLAUDE.md`, `docs/architecture/*`, and `docs/execution/*`.
2. Core constitutional contracts exist and are executable (Swift/TS/schema) for consent, habilitation, lawfulContext, gate, finalization, provenance, and deny/failure semantics.
3. Critical invariants are protected by automated negative tests in Swift suites and tracked in `10-invariant-matrix.md`.
4. Local validation harness exists and is executable (`make validate-all`) with fail-closed behavior.
5. Contract drift and doc drift checks exist and are runnable locally.
6. App boundaries are contract-protected (Scribe, Sortio, CloudClinic, cross-app shared surfaces) and do not absorb Core law.
7. Maturity map is honest and uses the canonical ladder (`doctrine-only`, `scaffolded contract`, `implemented seam`, `tested operational path`, `production-hardened`).
8. Open gaps are explicitly classified (scaffold/foundation blocker vs next HealthOS maturity hardening vs production requirement) in `14-final-gap-register.md`.
9. Next-agent handoff is current and sufficient for continuity without reconstructing prior chat context.

## Product Not Done (explicit non-claims)

Even with scaffold/foundation phase closure, HealthOS is **not** yet:

- final product release
- complete EHR
- final UI for Scribe/Sortio/CloudClinic
- production cloud/fabric
- production KMS and key lifecycle operations
- real qualified digital signature provider
- real RNDS/TISS/FHIR endpoint integration
- real remote provider deployment (LM/STT/embedding)
- real semantic retrieval stack (embeddings + vector index + evaluation)
- final legal/compliance certification
- production multi-node operation + disaster recovery evidence

## Release Candidate criteria by layer (closure classification)

### Status vocabulary

- `ready-for-scaffold-closure`
- `needs-small-closure`
- `partial-but-acceptable-with-explicit-gap`
- `blocker-for-scaffold-closure`
- `future-production-work`

| Layer | Classification | Why | Minimum closure action |
|---|---|---|---|
| Core law | ready-for-scaffold-closure | fail-closed contracts + tests are in place | keep invariant/test parity with drift checks |
| Data/storage/identity | partial-but-acceptable-with-explicit-gap | strong local guards exist; production crypto/ops not present | keep gaps explicit in final register |
| GOS | ready-for-scaffold-closure | lifecycle + policy + runtime mediation + tests present | preserve subordinate-to-Core posture |
| AACI | partial-but-acceptable-with-explicit-gap | first-slice is tested; non-first-slice modes remain open | keep non-first-slice backlog explicit |
| Providers/ML | partial-but-acceptable-with-explicit-gap | governance and fail-closed stubs exist; no real providers | maintain explicit stub truthfulness |
| Retrieval/memory | partial-but-acceptable-with-explicit-gap | governed lexical path exists; no real semantic infra | keep semantic unavailable posture explicit |
| Async runtime/jobs | ready-for-scaffold-closure | local executor and negative guards are tested | preserve local-scope claim only |
| Network/mesh/fabric | needs-small-closure | doctrine is clear but incident command surface still thin | finish ops command vocabulary docs |
| Backup/restore/retention/export/DR | partial-but-acceptable-with-explicit-gap | contracts/tests exist; operational automation missing | classify as next HealthOS maturity hardening |
| Regulatory/signature/interoperability/emergency | partial-but-acceptable-with-explicit-gap | fail-closed scaffold contracts/tests exist | keep non-integration claims explicit |
| User Agent/Sortio | partial-but-acceptable-with-explicit-gap | boundary contracts/tests exist; adapter/UI incomplete | keep adapter tasks explicit |
| Service Ops/CloudClinic | partial-but-acceptable-with-explicit-gap | core service boundary contracts/tests exist | keep persistence/runtime adapter gap explicit |
| Scribe | ready-for-scaffold-closure | minimal executable surface + boundary tests exist | keep non-final-UI claim explicit |
| Cross-app shared surfaces | needs-small-closure | contracts/tests exist; non-Scribe adapter propagation pending | close APP-008 or classify as accepted gap |
| Repository governance/validation | ready-for-scaffold-closure | validate-all + drift checks + handoff/maturity docs exist | keep docs synchronized each work unit |

## RC closure decision rule

Scaffold/foundation phase RC closure is allowed when:

- no layer remains `blocker-for-scaffold-closure`
- every `needs-small-closure` item has either been completed or explicitly accepted with owner and milestone in `14-final-gap-register.md`
- validation harness is green locally, or failures are explicitly classified with impact and next action
