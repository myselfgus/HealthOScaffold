# Repository Tour

> This page is a guided map of the HealthOS repository. It explains ownership, boundaries, and reading order without replacing the canonical docs and package manifests.

---

## Root identity

The repository name `HealthOScaffold` is historical. The product identity is HealthOS. `Scaffold` describes the maturity phase, not a separate product.

The repository contains:

- platform architecture;
- Swift packages and runtime targets;
- TypeScript contracts and construction tooling;
- Stage application packages;
- tests and validation harnesses;
- canonical docs;
- support, ML, and ops scaffolds.

---

## Main directory map

| Path | Role | How to read it |
| :--- | :--- | :--- |
| `HealthOS/Package.swift` | Central Swift package manifest for Tiers 1-3 and CLI. | Start here for executable module boundaries. |
| `HealthOS/Tier1-Mestral-Core/` | Constitutional law and core governance. | Highest-authority domain for consent, habilitation, finality, provenance, storage law, audit. |
| `HealthOS/Tier2-GOS-Runtimes/` | Governed runtime layer. | Contains GOS, AACI, MSR, providers, async, user-agent, service, and session runtime modules. |
| `HealthOS/Tier3-Custom-Boundary/` | Stage consumption frontier. | Defines `CustomSDK` and `HealthOSBoundary`; Stages should consume here, not below. |
| `HealthOS/Tier4-Stages-Cast/` | Governed Stage applications. | Contains Stage packages such as Scribe, Veridia, and CloudClinic. |
| `HealthOS/Shared/` | Shared sources, tests, design system, canonical docs. | Primary documentation and shared validation area. |
| `HealthOS/Support/` | Ops, Python, provider-support, ML scaffolds. | Supportive tooling governed by Core, not a runtime import target. |
| `HealthOS/Constructor/` | Construction System. | Repository maintenance layer: Steward, Settlers, Territories, Settlements, MCP tooling. |
| `wiki/` | Human onboarding Wiki. | Presentation and navigation layer; not canonical law. |

---

## Tier 1 — Mestral Core

Tier 1 is the constitutional layer. Changes here should be treated as high-risk because downstream behavior depends on these rules.

Read for:

- identity and habilitation;
- consent and finality;
- lawful context;
- storage law;
- provenance;
- gate behavior;
- audit semantics.

Contribution posture:

- require tests;
- update docs when semantics change;
- avoid app-specific leakage;
- preserve fail-closed behavior.

---

## Tier 2 — GOS / Runtimes

Tier 2 contains runtime execution under Core Law.

Key modules:

| Module | Responsibility |
| :--- | :--- |
| `HealthOSGOS` | Bundle lifecycle and runtime mediation. |
| `HealthOSAACI` | Ambient-Agentic Clinical Intelligence runtime. |
| `HealthOSMSR` | Mental Space Runtime. |
| `HealthOSProviders` | Provider adapters and model governance. |
| `HealthOSAsyncRuntime` | Local async jobs and retry/idempotency behavior. |
| `HealthOSUserAgentRuntime` | Patient-governed user-agent behavior. |
| `HealthOSServiceRuntime` | Service operations runtime. |
| `HealthOSSessionRuntime` | Session orchestration and first-slice bridge. |

Contribution posture:

- runtime behavior must remain subordinate to Core;
- provider failures must degrade honestly;
- automation must not finalize clinical acts without gate;
- tests should prove denial paths, not only happy paths.

---

## Tier 3 — Custom Boundary

Tier 3 is the application consumption frontier.

It owns:

- Stage-facing facades;
- safe references;
- envelopes;
- mediated and degraded state;
- commands and results;
- Custom-defined capabilities, prohibitions, and validation requirements.

Contribution posture:

- preserve the rule that Stages consume Boundary;
- do not expose Tier 1 or Tier 2 internals to Stage packages;
- make degraded/unavailable states explicit;
- avoid UI-driven law.

---

## Tier 4 — Stages Cast

Stages are governed application consumers.

| Stage | Intent | Current caution |
| :--- | :--- | :--- |
| Scribe | Professional workspace. | Minimal first-slice seam exists; not final product UI. |
| Veridia | Patient identity and sovereignty. | App-safe contracts exist before final shell. |
| CloudClinic | Service operations. | Custom and persisted workflow surfaces need further hardening. |

Contribution posture:

- Stage packages should not import Tier 2 modules directly;
- UI should reveal governed state;
- finality should always remain gated;
- design must remain aligned with native macOS 26+ / Liquid Glass posture.

---

## Shared docs and design system

`HealthOS/Shared/docs` is the canonical architecture and execution documentation area. The Wiki should point to it, not compete with it.

`HealthOS/Shared/DesignSystem` owns the shared presentation contract. It should be treated as a UI doctrine: it shapes surfaces, but never becomes governance law.

---

## Constructor

Constructor is external to the clinical/runtime hierarchy. It supports repository work through:

- Steward;
- Settlers;
- Settlements;
- Territories;
- forge MCP tools;
- managed-agent seams where applicable.

It can help construct the repository. It cannot become HealthOS law, runtime authority, or clinical finalization authority.

---

## Fast inspection path

For a new reviewer:

1. Read `README.md`.
2. Read `HealthOS/Shared/docs/architecture/01-overview.md`.
3. Read `HealthOS/Package.swift`.
4. Read `HealthOS/Shared/docs/execution/11-current-maturity-map.md`.
5. Inspect the test target matching the Tier you care about.
6. Read the Stage package manifest before touching Stage code.

---

## Boundary rule

When in doubt, apply this rule:

> Core governs. Runtimes execute under Core. Boundary mediates. Stages consume. Constructor constructs. Support assists. Presentation reveals, but never becomes law.
