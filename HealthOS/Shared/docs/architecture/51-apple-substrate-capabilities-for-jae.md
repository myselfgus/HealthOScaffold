# Apple Substrate Capabilities for the HealthOS Juridical Application Engine

## 1. Purpose

HealthOS is a Juridical Application Engine (JAE) for health applications. Apple-native frameworks are permitted and encouraged when they strengthen the local, sovereign substrate, but they are substrate capabilities mediated by HealthOS, not direct clinical authority.

The governing rule is:

```text
Stage request
  -> Custom capability declaration
  -> HealthOSBoundary command envelope
  -> Core Law validation
  -> Tier 2 runtime adapter
  -> Apple substrate capability
  -> governed result envelope
  -> provenance / audit event
  -> Boundary-mediated Stage result
```

Core Law remains the constitutional authority for consent, habilitation, lawfulContext, storage-layer semantics, provenance, audit, gate, and finality. Apple APIs can compute, store projections, package evidence, isolate workers, or transport governed envelopes; they cannot authorize a clinical act or create legal finality.

## 2. Scope

This document covers the Apple-native capabilities most likely to be incorporated into HealthOS scaffold/foundation and later hardening work:

- SwiftData
- CloudKit
- FoundationModels
- Core ML
- Create ML / Create ML Components
- NaturalLanguage
- RegexBuilder
- CryptoKit
- AppleArchive
- XPC
- ServiceManagement
- Network
- ThreadNetwork
- Virtualization / vmnet
- FSKit
- Xcode Cloud

## 3. Non-claims

This is doctrine and implementation-track guidance. It does not upgrade maturity for any gap.

- Apple APIs are not Core Law.
- CloudKit is not canonical custody.
- SwiftData is not canonical custody.
- FoundationModels, Core ML, NaturalLanguage, and Speech are not clinical authority.
- XPC and ServiceManagement are not app-owned authority.
- Network is not arbitrary propagation.
- AppleArchive and CryptoKit create integrity/evidence, not legal finality.
- Xcode Cloud is not runtime authority and is not merge authority.
- This repository remains scaffold/foundation maturity: not production-ready, not a complete EHR, and not a real regulatory/provider integration.
- No Apple Private Cloud Compute, Xcode Intelligence, real semantic retrieval, distributed mesh, distributed workers, CloudKit canonical custody, SwiftData canonical custody, autonomous clinical finalization, or autonomous regulatory effectuation claim is made here.

## 4. Exposure model

Every Stage-facing Apple-backed capability must be exposed through Custom and Boundary:

1. A Stage requests a declared Custom capability.
2. `HealthOSBoundary` accepts the request as an app-safe command envelope.
3. Core Law validates lawfulContext, consent, habilitation, finality posture, storage layer, provenance requirements, and gate/finality requirements.
4. A Tier 2 runtime adapter invokes the Apple substrate capability if policy allows.
5. The runtime returns a governed result envelope with degraded/unavailable status where appropriate.
6. Provenance and audit events record the decision, provider/substrate identity, model/version where relevant, storage-layer posture, and outcome.
7. The Stage receives only a Boundary-mediated result or denial.

There must be no Stage -> Apple authority shortcut for clinical or health-operational work.

## 5. Capability matrix

| Apple capability | HealthOS role | Allowed use | Prohibited use | Owning tier | Likely module | Required tests |
|---|---|---|---|---|---|---|
| SwiftData | Projection/cache/index substrate | Governed projections, UI caches, non-canonical indexes, query acceleration | Canonical custody, final-document source of truth, lawfulContext bypass | Tier 1/3 depending on contract; Stage only for UI cache | `HealthOSCore`, `HealthOSBoundary`, Stage UI cache packages | Projection denied without lawfulContext; projection records canonical source ref; direct identifier projection denied unless app-safe policy exists; Stage usage documented as cache-only |
| CloudKit | Governed projection/sync candidate | Policy-gated projection sync with provenance and degraded/unavailable status | Canonical custody, direct identifier propagation, reidentification mapping sync by convenience | Tier 2/3 mediated service | future `HealthOSServiceRuntime` / `HealthOSBoundary` adapter | Sync denied without policy; raw identifiers denied; sync provenance emitted; unavailable state explicit |
| FoundationModels | Apple-native local inference provider | On-device language-model provider behind `HealthOSProviders` / `ProviderRouter` | Direct Stage import, clinical authority, fake real inference from stubs, remote fallback by default | Tier 2 | `HealthOSProviders` | Direct identifiers denied; unavailable provider degrades honestly; model/prompt provenance recorded |
| Core ML | Local model runtime substrate | Governed classification/embedding providers after model governance | Direct Stage clinical inference, ungoverned embeddings, real semantic retrieval claim without evaluation | Tier 2 plus Support tooling | `HealthOSProviders`, `HealthOS/Support/ML` | Provider profile enforced; no direct identifiers embedded; evaluation harness before maturity upgrade |
| Create ML / Create ML Components | Offline model development/evaluation tooling | Scaffolded local model preparation and evaluation with governed datasets | Runtime authority, training on real patient data without model governance/provenance | Support / External construction support | `HealthOS/Support/ML` | Dataset lineage checks; model governance status explicit; no loadable-runtime claim without approval |
| NaturalLanguage | Local preprocessing substrate | Tokenization, linguistic preprocessing, NER assistance, validation support behind providers/runtimes | Direct Stage clinical inference or direct identifier extraction for convenience | Tier 2 | `HealthOSProviders`, retrieval/runtime adapters | Direct identifiers/reidentification denied; preprocessing provenance recorded; degraded when unavailable |
| RegexBuilder | Deterministic parsing substrate | Bounded parsing, post-validation, envelope validation helpers | Clinical authorization, silent normalization of governed records | Tier 1/2 utility | Core/runtimes as needed | Parse failures fail closed where governance-critical; provenance for transformations |
| CryptoKit | Integrity/encryption/signature primitive | Hashing, signing, verification, encryption, key agreement, internal integrity envelopes | Legal/qualified signature claim, clinical authorization, storing plaintext keys | Tier 1/2 | `HealthOSCore`, backup/regulatory adapters | Hash/signature verification; internal signature does not set provider accepted; secrets not logged |
| AppleArchive | Evidence package substrate | Backup, restore dry-run, export packaging, manifest-bound evidence archives | Simple archive as legal finality, restore without verification, archive without lawfulContext/provenance refs | Tier 1/2 ops | `HealthOSCore`, ops tooling | Manifest generated; archive hash verified; restore-to-temp dry-run; denied lawfulContext blocks backup |
| XPC | Local isolation/transport substrate | Local execution-cell or worker transport after contract tests | Stage-to-worker bypass, arbitrary shell execution, worker without lawfulContext | Tier 2 | `HealthOSAsyncRuntime`, future worker host | Peer identity validation; denied lawfulContext does not enqueue; crash yields degraded/failed event; idempotency enforced |
| ServiceManagement | Helper lifecycle substrate | Managed helper/login item/daemon lifecycle under operator policy | App-owned authority, bypassing Core Law, undisclosed background clinical execution | Tier 2 ops | future worker lifecycle adapter | Registration gated/documented; lifecycle provenance; degraded/unavailable status explicit |
| Network | Governed mesh transport substrate | Envelope transport with source/destination identity, encryption/signature where policy requires | Raw health-data propagation outside policy, arbitrary direct network client in Stage | Tier 2/3 | future mesh/Boundary adapter | Raw payload denied; lawfulContext/provenance refs required; offline/degraded state covered |
| ThreadNetwork | Future device/network credential capability | Policy-gated future credential operations | Ungoverned device propagation or credential leakage | Tier 2 future | future ops adapter | Policy gate tests before implementation |
| Virtualization / vmnet | Future sovereign lab/sandbox substrate | Local sandbox or lab environment under policy | Production distributed worker claim, bypassing storage/provenance | Tier 2/Support future | future ops/lab tooling | Explicit policy gate; no production claim; evidence isolation tests |
| FSKit | High-risk filesystem capability | Future policy-gated filesystem experiments | Canonical storage replacement or ungoverned file system authority | Tier 1/2 future | future storage experiments | Threat-model and policy tests before implementation |
| Xcode Cloud | Deterministic CI substrate | Running documented validation gates and uploading evidence | Runtime authority, maturity upgrade without repeated evidence, AI/CI merge authority | External construction/CI | repo CI config | CI run URL/artifact recorded; failure path documented; no secrets in logs |

## 6. Implementation tracks by gap

- **GAP-003 — Data/storage complementary backends:** SwiftData may serve governed projection/index workloads with canonical source refs, lawfulContext hash, provenance ref, storage layer, schema version, and degraded/stale status. File-backed canonical custody remains authoritative.
- **GAP-004 — Providers/ML:** FoundationModels remains an Apple-native language-model provider behind `HealthOSProviders` / `ProviderRouter`. NaturalLanguage, Core ML, and Speech adapters must declare `ProviderCapabilityProfile`, deny direct identifiers and reidentification mapping by default, and emit provider execution provenance.
- **GAP-005 — Retrieval/memory/index semantic layer:** Semantic retrieval starts local-first with NaturalLanguage preprocessing, bounded file-backed embedding index, Core ML embedding provider where governed, and evaluation harness before maturity upgrade. No external vector DB in the first implementation.
- **GAP-006 — Async runtime distributed/local workers:** Define execution-cell contracts first, start with in-process/mock transport, then local XPC, then ServiceManagement lifecycle. Every job carries lawfulContext and idempotency and emits provenance/degraded events.
- **GAP-007 — Backup/restore/export/DR:** AppleArchive and CryptoKit may package evidence and create integrity envelopes. Generate manifests first, verify archive hashes before restore, run restore dry-runs, and do not claim legal finality.
- **GAP-008 — Regulatory/signature/interoperability:** CryptoKit internal signatures may harden artifact integrity and state-machine transitions. They must be named `internalIntegritySignature` or `HealthOSArtifactSignature`, not legal/qualified/regulatory signatures unless a real provider integration exists.
- **GAP-009 — User/Service runtimes and Stage adapters:** Veridia, CloudClinic, Scribe, and future Stages consume app-safe projections and runtime results through Boundary/Custom only. Stage packages must not import Tier 2 modules directly.
- **GAP-010 — CI-distributed validate-all:** Xcode Cloud may run deterministic validation, but local CLI validation remains required and CI evidence must be recorded before any maturity claim changes.

## 7. Stage rules

Stages are governed application consumers inside HealthOS. They may present professional, patient-facing, or service-facing workflows, but they do not own compliance enforcement, canonical custody, provider authority, propagation authority, clinical law, or regulatory finality.

Stage packages may import `HealthOSBoundary` and `CustomSDK`. They must not directly import Tier 2 runtime modules or Apple authority frameworks for clinical execution. Apple UI frameworks are allowed for presentation. SwiftData in a Stage is allowed only for UI projection/cache with documentation and tests. CloudKit, FoundationModels, Core ML, NaturalLanguage, Network, XPC, ServiceManagement, and direct file-backed canonical storage are blocked for Stage clinical authority unless a governed Boundary capability and policy explicitly mediate the use.

## 8. Provider rules

FoundationModels, Core ML, NaturalLanguage, and Speech must go through `HealthOSProviders` and `ProviderRouter` for clinical or health-operational work. Provider adapters must:

- declare `ProviderCapabilityProfile`;
- preserve fail-closed direct-identifier and reidentification guards;
- avoid remote fallback unless explicit policy permits it;
- distinguish real provider execution from stub/unavailable/degraded behavior;
- emit model, model-version, prompt-version, task-class, storage-layer, provider-kind, provider-id, and execution-status provenance where applicable.

## 9. Storage and sync rules

File-backed canonical record storage remains authoritative. SwiftData and CloudKit are projection, index, cache, sync, or propagation substrates only. Governed projections must carry canonical object refs, lawfulContext hashes, provenance refs, storage-layer posture, schema version, and degraded/stale status where relevant. Direct identifiers and reidentification mapping must fail closed unless a specifically governed reidentification flow exists.

## 10. Agent coding rules

- Classify work by tier or external construction class before changing files.
- Preserve the Stage -> Custom -> Boundary -> Core Law -> Runtime -> Apple substrate -> provenance -> Boundary-result path.
- Do not create CloudKit or SwiftData canonical storage.
- Do not let Stages import Tier 2 runtime modules or directly call Apple authority frameworks for clinical execution.
- Do not weaken ProviderRouter, direct-identifier denial, reidentification denial, remote-fallback denial, or degraded-state honesty.
- Do not claim production readiness, regulatory compliance, qualified signature integration, real semantic retrieval, distributed mesh, distributed workers, Xcode Intelligence integration, or Apple Private Cloud Compute integration without implementation evidence.
- Update tracking docs and TODOs when architectural doctrine or implementation tracks change.
