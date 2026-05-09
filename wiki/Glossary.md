# Glossary

> HealthOS uses a precise vocabulary. This glossary exists to reduce onboarding friction while preserving the canonical doctrine.

---

## A

### AACI

Ambient-Agentic Clinical Intelligence. A HealthOS runtime for clinical-adjacent automation such as transcription, retrieval, draft composition, note structuring, and task preparation. AACI does not finalize health acts by itself.

### Artifact

A clinical or operational output such as a draft note, final SOAP, referral, prescription draft, audit event, or derived document. Final artifacts require governed finality and provenance.

### Audit

The reviewable record of governed activity. Audit supports accountability and evidence of consent, habilitation, gate, finality, and provenance behavior.

---

## B

### Boundary

The HealthOS-owned consumption frontier between runtimes and Stage applications. Boundary exposes safe references, envelopes, commands, results, mediated state, and degraded state. Stages should consume Boundary, not lower runtime internals.

---

## C

### CloudClinic

A Tier 4 Stage intended for service operations. In the current scaffold posture, it is contractually defined but not a finished production application.

### Consent

A governed precondition for health processing. In HealthOS, consent is tied to purpose/finality and should affect whether runtime behavior may execute.

### Constructor

The external repository construction layer. It includes Steward, Settlers, Territories, Settlements, and MCP tooling. Constructor helps maintain the repository but does not become clinical runtime authority.

### Core Law

The constitutional layer of HealthOS. It governs consent, habilitation, lawful context, finality, provenance, gate, audit, storage law, and fail-closed behavior.

### Custom

A Stage-definition boundary mechanism. Custom defines capabilities, prohibitions, validation requirements, degradation policy, and compliance posture for a Stage.

---

## D

### Degraded state

An explicit state where a capability is partially available or constrained. HealthOS should reveal degraded state honestly rather than pretending full functionality exists.

### Doctrine-only

A maturity level. The concept or target is documented, but no executable behavior is claimed.

### Draft

A non-final clinical or operational artifact. AI and runtime automation may generate drafts under governance, but regulatory effectuation requires gate/finality.

---

## E

### Effectuation

The moment a clinical, regulatory, or operational act becomes official or externally meaningful. HealthOS requires governed finality and gate behavior before effectuation.

### Envelope

A Boundary-mediated package of data, metadata, authority, and state that can be safely consumed by Stage applications.

---

## F

### Fail-closed

A security/governance principle: when authority, consent, lawful context, provider capability, or validation is missing, HealthOS denies or degrades rather than proceeding silently.

### Finality

The governed transition from draft/prepared state to final/effective state. Finality must be auditable and must not be implied by UI alone.

### First slice

The current bounded executable orchestration path through habilitation, consent, session start, capture/transcription posture, normalization, retrieval, SOAP draft, derived drafts, gate, final SOAP, and provenance.

---

## G

### Gate

The human or governed approval checkpoint before final clinical/regulatory effectuation. A gate can approve, reject, or withhold an artifact.

### GOS

Governed Operating System / Governance Operating Surface in the HealthOS context. It mediates runtime lifecycle, activation, review, and binding under Core Law.

---

## H

### Habilitation

The professional authority window or qualification check required before professional clinical actions may occur.

### HealthOS

A sovereign computational environment and juridical application substrate for health operations.

### HealthOScaffold

The historical repository name and scaffold/foundation phase for HealthOS. It is not a separate product identity.

### HealthOSBoundary

The Swift Tier 3 target that exposes mediated Stage-consumable surfaces.

### HealthOSCLI

The operator executable in the central Swift package. It supports scaffold-level execution and validation paths.

### HealthOSCore

The Tier 1 Swift target containing Core Law and core governance types.

### HealthOSProviders

The Tier 2 Swift runtime provider-adapter target. It is distinct from `HealthOS/Support`, which contains support tooling.

---

## I

### Implemented seam

A maturity level. A real interface, adapter, or runtime seam exists, but broader coverage or production hardening remains incomplete.

---

## J

### JAE

Juridical Application Engine. The category HealthOS claims: applications run inside a legally governed execution substrate rather than implementing compliance independently.

---

## L

### Lawful context

The context proving that a given operation is authorized under HealthOS law: identity, consent, habilitation, purpose/finality, actor, and operation constraints.

### Liquid Glass

The macOS 26+ presentation baseline referenced by the HealthOS design system. It is a UI/material posture, not governance law.

---

## M

### Mestral Core

Tier 1 constitutional layer of HealthOS.

### ModelGovernance

The governance posture for model/provider use, including capability routing, allowed/denied behavior, degradation, and provenance.

### MSR

Mental Space Runtime. A Tier 2 runtime domain involving ASL, VDLP, GEM, transcript normalization, semantic structuring, and provenance metadata.

---

## P

### Provenance

The lineage of an artifact or action: source, actor, transformation, model/runtime involvement, timestamp, gate state, and audit context.

### Production-hardened

A maturity level. The component is ready for production operation with security, observability, distributed behavior, monitoring, recovery, and operational processes. This is not the general current posture of the repo.

---

## R

### Runtime

An execution module under Core Law, such as AACI, MSR, Async, User Agent, Service, Session Runtime, or provider routing.

---

## S

### Scaffolded contract

A maturity level. The boundary is defined through docs, types, schemas, or validators, but full runtime/UI/provider behavior is not complete.

### Scribe

A Tier 4 Stage for professional clinical workspace behavior, including capture, drafting, review, and finalization under Boundary mediation.

### Settler

A specialized engineering profile in the Construction System.

### Settlement

A bounded work unit in the Construction System.

### Stage

A governed application consumer in HealthOS. Stages consume mediated Boundary surfaces and should not import Tier 1 or Tier 2 internals directly.

### Steward

The Construction System coordinator responsible for repository work orchestration and derived memory. Steward is not clinical runtime authority.

### Support

`HealthOS/Support`, containing ops, Python, ML scaffolds, and provider-support tooling. Support assists; it does not replace `HealthOSProviders` or Core Law.

---

## T

### Tested operational path

A maturity level. Executable behavior exists with tests, smoke evidence, or validation harness support inside scaffold boundaries.

### Tier

A HealthOS architectural layer. Tiers separate constitutional law, runtimes, Boundary, and Stage consumption.

---

## V

### Veridia

A Tier 4 Stage for patient identity and sovereignty surfaces.

---

## W

### Wiki

This human onboarding layer. The Wiki explains and routes readers; it does not replace canonical docs, tests, or package manifests.
