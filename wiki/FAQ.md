# FAQ

## Is HealthOS an EHR?

No. HealthOS is not an EHR skin or a replacement label for an EHR. It is a governed health execution substrate where health applications can run under Core Law, Boundary mediation, consent, habilitation, gate, finality, provenance, and audit.

An EHR could be a consumer, integration target, or adjacent system. HealthOS itself is broader than that.

---

## Is HealthOS production-ready?

No. The repository is in scaffold/foundation maturity. Several components have tested operational paths, but production hardening remains a future milestone.

Do not claim production readiness until security, key management, distributed storage, CI gates, operations, backup/restore, incident handling, provider integrations, and regulatory effectuation are hardened.

---

## Why is the repository called HealthOScaffold?

`HealthOScaffold` is the historical repository name for the scaffold/foundation phase. The product identity is HealthOS. Scaffold describes maturity, not a separate product.

---

## What is Core Law?

Core Law is the constitutional layer of HealthOS. It governs consent, habilitation, lawful context, finality, gate, provenance, audit, and fail-closed behavior.

Applications should not implement Core Law independently. They consume surfaces governed by it.

---

## What is a Stage?

A Stage is a governed application consumer of HealthOS. Examples include Scribe, Veridia, and CloudClinic.

Stages consume mediated surfaces through `HealthOSBoundary` and `CustomSDK`. They should not import Tier 1 or Tier 2 internals directly.

---

## What is Boundary?

Boundary is the HealthOS-owned consumption frontier between runtimes and Stage applications. It exposes safe references, envelopes, mediated state, degraded state, commands, and results.

Boundary protects Stages from owning runtime law and protects Core/Runtimes from direct application coupling.

---

## What is Custom?

Custom is the Stage-definition mechanism. It declares what a Stage can do, what it cannot do, what validation it requires, and how it should degrade when capabilities are unavailable.

---

## What is AACI?

AACI means Ambient-Agentic Clinical Intelligence. It is a runtime for clinical-adjacent automation such as transcription, retrieval, note structuring, draft composition, and document preparation.

AACI may draft. It must not finalize a health act by itself.

---

## Can AI produce final clinical documents?

AI can help prepare drafts under governance. Final clinical or regulatory effectuation requires gate/finality behavior and provenance. UI copy should never imply that AI-generated content is official before approval.

---

## What is the first slice?

The first slice is the current bounded executable path through habilitation, consent, session start, capture/transcription posture, transcript normalization, retrieval context, SOAP draft, derived drafts, gate resolution, final SOAP, and provenance.

It proves an orchestration spine, not a full production platform.

---

## Why separate Tiers 1-4?

Tier separation prevents applications from becoming law engines and prevents runtime behavior from bypassing governance.

| Tier | Purpose |
| :--- | :--- |
| Tier 1 | Constitutional law. |
| Tier 2 | Runtime execution under law. |
| Tier 3 | Boundary-mediated consumption. |
| Tier 4 | Governed application consumers. |

---

## Why not put everything in the Wiki?

Because canonical technical documentation should be versioned with code, reviewed by PR, and aligned with tests. The Wiki exists for onboarding, navigation, and progressive disclosure.

Source-of-truth order:

1. Tests and validation.
2. Package manifests and contracts.
3. `HealthOS/Shared/docs`.
4. Wiki.

---

## How should I start contributing?

Start with `README.md`, `HealthOS/Shared/docs/architecture/01-overview.md`, `HealthOS/Package.swift`, and the maturity map. Then choose one narrow module, read its tests, and preserve the Tier boundary.

Do not start by building UI against nonexistent runtime authority.

---

## What is Constructor?

Constructor is the repository engineering layer. It includes Steward, Settlers, Territories, Settlements, and forge MCP tooling.

Constructor can inspect, edit, validate, and organize repository work. It is not Core Law, runtime authority, or clinical automation.

---

## What is Support?

`HealthOS/Support` contains ops, Python, ML scaffolds, and provider-support tooling. It assists Core, runtimes, Stages, and Constructor workflows under Core governance.

It is not the same as `HealthOSProviders`, which is the Swift runtime provider-adapter module.

---

## What should public messaging emphasize?

Emphasize that HealthOS is a governed substrate for health applications. Avoid overstating production readiness. Explain that the strongest current assets are constitutional architecture, Tier separation, Boundary doctrine, first-slice execution, validation posture, and explicit maturity tracking.

---

## What should public messaging avoid?

Avoid claiming that HealthOS is:

- production-ready;
- a complete EHR;
- a finished app suite;
- fully integrated with real clinical/regulatory endpoints;
- a generic AI assistant;
- autonomous clinical decision infrastructure.

---

## What is the most important invariant?

> Every clinical act must remain governed by consent, habilitation, purpose, gate, finality, provenance, and audit before it persists or propagates.
