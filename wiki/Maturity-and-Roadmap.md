# Maturity and Roadmap

> HealthOS uses explicit maturity language so that architecture, contracts, seams, tests, and production readiness are never confused.

---

## Maturity ladder

HealthOS components are read through this ladder:

| Level | Meaning |
| :--- | :--- |
| Doctrine-only | The canonical concept or target exists, but no executable behavior is claimed. |
| Scaffolded contract | Types, schemas, docs, or validators define the boundary, but runtime/UI/provider behavior remains incomplete. |
| Implemented seam | A real interface, adapter, or local behavior exists, but broader coverage or production hardening remains incomplete. |
| Tested operational path | Executable behavior has local tests, smoke evidence, or validation harness support inside scaffold boundaries. |
| Production-hardened | Operational, distributed, monitored, secured, and ready for production use. This is not the current general repository posture. |

---

## Current posture summary

| Area | Current posture | Practical meaning |
| :--- | :--- | :--- |
| Core law | Tested operational path | Consent, habilitation, gate, finality, lawful context, and provenance have active governance suites. |
| Data/storage | Tested operational path | Layer-aware guards and provenance are present, but production key management and distributed storage remain gaps. |
| GOS | Tested operational path / scaffold hardening | Lifecycle, review, activation, and binding exist with Swift and TypeScript test posture. |
| AACI | Implemented seam / first-slice operational path | Capture, draft, and gate behavior exist within bounded first-slice scope. |
| Providers/ML | Scaffolded contract / implemented seam | Routing and fail-closed model posture exist; real external provider integrations remain future work. |
| Retrieval/memory/index | Scaffolded contract / implemented seam | Governed retrieval posture exists; embeddings and vector infrastructure are not complete. |
| Async runtime | Implemented seam / local tested path | Local retry, idempotency, lawful context, and denial paths exist; distributed workers remain future work. |
| MSR | Scaffolded contract / implemented seam | ASL, VDLP, GEM contracts exist; full first-slice execution remains incomplete. |
| Network/fabric | Doctrine-only / scaffolded contract | Private mesh doctrine exists; production sovereign fabric implementation is not complete. |
| Regulatory/signature/interoperability | Scaffolded contract / tested validators | Fail-closed validators exist; real integrations remain production gaps. |
| Scribe | Implemented seam / minimal tested path | Professional workspace surface exists at minimal scaffold level; not final UI/product. |
| Veridia | Scaffolded contract / boundary-tested | Patient-sovereignty surface is defined before final shell. |
| CloudClinic | Scaffolded contract / boundary-tested | Service operations contracts exist; Custom and persisted workflow need more work. |
| Validation harness | Tested operational path | Local validation is one of the stronger repository assets. |
| Operations | Scaffolded contract | Runbooks and posture exist; automation and production incident tooling remain gaps. |

---

## What is safe to claim today

It is safe to claim that HealthOS has:

- a strong constitutional architecture;
- explicit Tier separation;
- a Swift package graph for Tiers 1-3;
- Stage package separation;
- Boundary-first Stage consumption doctrine;
- first-slice orchestration evidence;
- local validation and governance tests;
- a clear scaffold maturity map;
- documentation that distinguishes product vision from current execution.

---

## What is not safe to claim today

Do not claim that HealthOS is currently:

- production-ready;
- a complete EHR;
- a full clinical operations platform;
- a finished macOS app suite;
- integrated with real regulatory/signature/interoperability endpoints;
- backed by production sovereign mesh/fabric;
- equipped with full semantic vector retrieval;
- supported by hardened distributed production operations.

---

## Roadmap themes

### 1. Close scaffold/foundation gaps

Priority should remain on areas marked `needs-small-closure` or `partial-but-acceptable-with-explicit-gap` in the canonical maturity map.

Key work:

- network/fabric closure;
- cross-app shared surfaces;
- provider and retrieval execution hardening;
- MSR first-slice adapters;
- clearer app-readiness gates.

### 2. Harden Boundary before Stage expansion

Stage work should proceed only after the mediated surfaces are implemented and stable. Do not build UI that assumes runtime authority not yet exposed through Boundary.

### 3. Convert local validation into CI discipline

The local validation harness is a major strength. The next maturity move is to wire equivalent gates into CI while keeping maturity claims honest.

### 4. Make security/privacy operational

Docs and validators are necessary but not sufficient. Production hardening requires key management, operational audit, retention workflows, incident handling, access reviews, and backup/restore automation.

### 5. Separate public narrative from internal doctrine

The public-facing narrative should explain HealthOS in simple language while preserving the canonical doctrine internally. The Wiki and GitHub Pages should act as progressive disclosure layers.

---

## Roadmap table

| Horizon | Goal | Exit condition |
| :--- | :--- | :--- |
| Immediate | Finish scaffold closure issues. | Gap register reduced; small-closure areas resolved. |
| Near-term | CI-backed validation and clearer contribution gates. | Build/test/docs validation runs on PR. |
| Near-term | Boundary readiness for Scribe expansion. | Scribe consumes stable Boundary surfaces only. |
| Mid-term | Provider and retrieval hardening. | Real provider/index pipelines integrated without weakening fail-closed policy. |
| Mid-term | Veridia and CloudClinic adapter wiring. | Stage shells consume mediated contracts with persisted workflow projections where needed. |
| Long-term | Production sovereign fabric. | Hardened deployment, observability, backup/restore, incident operations, and access governance. |

---

## Canonical references

Use these files as source of truth:

- `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
- `HealthOS/Shared/docs/execution/14-final-gap-register.md`
- `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md`
- `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`
- `HealthOS/Package.swift`
