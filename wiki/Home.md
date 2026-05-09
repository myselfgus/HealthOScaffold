# HealthOS Wiki

<p align="center">
  <img src="../HealthOS/Shared/docs/assets/healthos-logo.png" width="280" alt="HealthOS">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/HealthOS-Juridical%20Application%20Engine-0F172A?style=flat" alt="HealthOS JAE">
  <img src="https://img.shields.io/badge/Maturity-Scaffold%20Foundation-64748B?style=flat" alt="Scaffold Foundation">
  <img src="https://img.shields.io/badge/UI-Liquid%20Glass-8B5CF6?style=flat" alt="Liquid Glass">
</p>

> HealthOS is a sovereign computational environment for health operations. It is not an EHR skin, not a generic agent framework, and not a compliance wrapper. It is a juridical execution substrate where health applications run under Core Law, governed boundaries, consent, habilitation, finality, provenance, and audit.

This Wiki is the human entry surface for the HealthOS repository. It does not replace the canonical documentation under `HealthOS/Shared/docs`; it helps readers navigate the architecture, maturity, terminology, and contribution model without losing the legal and design intent of the platform.

---

## Navigation

| Page | Purpose |
| :--- | :--- |
| [Product Narrative](Product-Narrative.md) | Explains the HealthOS thesis, audience, value proposition, and non-goals. |
| [Conceptual Map](Conceptual-Map.md) | Defines Core Law, GOS, Boundary, Custom, Stages, Constructor, and Support. |
| [Repository Tour](Repository-Tour.md) | Walks through the main directories and what each domain owns. |
| [Maturity and Roadmap](Maturity-and-Roadmap.md) | Summarizes what is tested, scaffolded, partial, blocked, or production-gap. |
| [Developer Onboarding](Developer-Onboarding.md) | Provides the shortest practical path to build, test, inspect, and contribute. |
| [Design System Alignment](Design-System-Alignment.md) | Documents the presentation posture, visual grammar, and UI constraints. |
| [Security and Privacy Posture](Security-and-Privacy-Posture.md) | Explains governance, data separation, consent, audit, and production caveats. |
| [Glossary](Glossary.md) | Defines the canonical vocabulary used across HealthOS. |
| [FAQ](FAQ.md) | Answers common questions for technical and non-technical readers. |

---

## Reading order

If you are new to HealthOS, read in this order:

1. [Product Narrative](Product-Narrative.md)
2. [Conceptual Map](Conceptual-Map.md)
3. [Repository Tour](Repository-Tour.md)
4. [Maturity and Roadmap](Maturity-and-Roadmap.md)
5. [Developer Onboarding](Developer-Onboarding.md)

If you are evaluating the project, start with [Maturity and Roadmap](Maturity-and-Roadmap.md), then inspect `HealthOS/Shared/docs/execution/11-current-maturity-map.md` and `HealthOS/Shared/docs/execution/14-final-gap-register.md`.

If you are contributing code, start with [Developer Onboarding](Developer-Onboarding.md), then inspect `HealthOS/Package.swift` and the tests for the Tier you intend to touch.

---

## Canonical doctrine

The Wiki is intentionally lighter than the canonical docs. When there is conflict, the source of truth is:

1. Executable tests and validation harnesses.
2. `HealthOS/Package.swift` and Stage package manifests.
3. `HealthOS/Shared/docs` canonical architecture and execution documents.
4. This Wiki.

---

## Maturity lens

HealthOS is currently a scaffold/foundation repository, not a production clinical platform. Its maturity language is explicit:

`doctrine-only → scaffolded contract → implemented seam → tested operational path → production-hardened`

Do not infer production readiness from architectural completeness. The repository intentionally separates constitutional architecture, contracts, runtime seams, tests, app shells, and production operations.
