# HealthOS Technical Product Specification

## Status

This document is the baseline technical product specification for HealthOS.

Maturity is scaffolded contract.

It consolidates existing repository doctrine and current code state.

It does not claim production readiness.

It does not replace architecture doctrine or execution tracking.

## Canonical statement

HealthOS is a sovereign computational environment for health data and clinical operations.

Core law is the sovereign layer.

Operational layers and runtimes consume mediated lawful context.

Apps consume mediated surfaces.

Construction tooling remains outside the clinical/runtime hierarchy.

## System layers

```text
Material substrate
  └─ storage, network, Apple sovereignty substrate
Core
  └─ identity, consent, habilitation, finality, provenance, gate, storage law
GOS
  └─ operational specification layer
Session Runtime
  └─ SessionRunner, normalization, session orchestration
Swift runtimes and infrastructure
  ├─ AACI
  ├─ MSR
  └─ Providers
TypeScript runtimes
  ├─ Async Runtime
  ├─ User-Agent Runtime
  └─ Service Runtime
Apps / Interfaces
  ├─ Scribe
  ├─ Veridia
  └─ CloudClinic
Construction layer
  └─ Steward, Settlers, Territories, Settlements, HealthOS Forge MCP
```

## Core

Core owns identity, consent, habilitation, gate, finality, provenance, and storage-law enforcement.

Core does not delegate sovereign legal checks to GOS, Session Runtime, AACI, MSR, providers, TS runtimes, or apps.

`lawfulContext` is the mediated access passport for runtime operations and storage behavior.

Core governs layer boundaries between direct identifiers, operational content, governance metadata, derived artifacts, and reidentification mappings.

Non-claims:
- Core is not replaced by app logic.
- Core sovereignty is not optional.

## GOS

GOS is the Governed Operational Spec intermediate representation for structured operational runtime behavior subordinate to Core law.

Earlier PIR-like terminology is not canonical in the current repository. The current canonical name is GOS.

GOS is bipartite:
- TypeScript authoring/compiler/validator/bundler/tooling (`healthos-gos-tooling`).
- Swift runtime consumption via AACI and Session Runtime bindings where applicable.

Primitive families:
1. signal specs
2. slot specs
3. derivation specs
4. task specs
5. tool binding specs
6. draft output specs
7. guard specs
8. deadline specs
9. evidence hook specs
10. human gate requirement specs
11. escalation specs
12. scope requirement specs

Technical usage model:
- Authoring form is declarative source specs.
- Compiled form is normalized, validated bundle artifacts consumed by runtime bindings.
- Task specs define bounded runtime work units.
- Task specs do not grant sovereign authority.
- Tool binding specs constrain which tool classes/tasks can fulfill task specs.
- Scope requirement specs declare required scope preconditions but never verify lawful satisfaction.
- Human gate requirement specs declare where gate is required but never resolve gate.
- Evidence hook specs declare provenance capture points and do not replace Core provenance authority.
- GOS-to-runtime binding exists to reduce ad hoc prompt/runtime hardcoding and preserve explicit governed operational structure.

## Session Runtime

Session Runtime is the orchestration layer for first-slice governed execution.

Implementation module: `HealthOSSessionRuntime`.

Primary actor: `SessionRunner`.

Session Runtime owns session orchestration, normalization stage invocation, runtime state mediation, and handoff sequencing to AACI/MSR under Core-governed context.

Session Runtime normalizes transcript output before MSR consumption.

Session Runtime is not Core, GOS, AACI, MSR, Async Runtime, Service Runtime, or app law.

## STT, transcription, and normalization

STT/speech-to-text is capture/transcription capability.

Transcription is raw or degraded capture output and is not equivalent to normalization.

Normalization is a Session Runtime stage.

Normalization uses local Apple Foundation Models provider when available, with explicit degraded/stub posture otherwise.

Normalization output is prerequisite input to MSR stages.

Remote fallback is denied for transcript normalization v1.

No hidden provider fallback is allowed.

## AACI

AACI is a Swift runtime peer to MSR under Session Runtime orchestration.

AACI provides draft-only ambient/agentic clinical-operational support.

AACI consumes GOS binding posture where active bundles exist.

AACI participates in capture/transcription/draft composition flows where currently wired.

AACI is never final clinical authority.

## MSR

MSR is the Mental Space Runtime.

Implementation module: `HealthOSMSR`.

MSR executes staged ASL → VDLP → GEM derivation.

MSR consumes normalized transcript input.

MSR produces derived and gated artifacts.

Legacy scripts are archived reference implementations. Active runtime implementation is Swift `HealthOSMSR` with prompt resources in Swift module resources.

MSR has no diagnosis authority and does not expose raw provider JSON as app-facing authority.

## ASL, VDLP, and GEM technical summary

Legacy references:
- `docs/reference/mental-space-legacy/4-asl.ts`
- `docs/reference/mental-space-legacy/5-vdlp.ts`
- `docs/reference/mental-space-legacy/6-gem.ts`
- normalization reference: `docs/reference/mental-space-legacy/2-process-transcriptions.ts`

ASL:
- Purpose: structured systemic language analysis as derived artifact.
- Input: normalized transcript / transcription artifact context.
- Output: ASL-derived artifact.
- Provider posture: governed provider execution with scaffold/degraded honesty.
- Chunking/consolidation: legacy implementation documents chunking for long transcriptions.
- Provenance marker: `mental-space.asl`.
- Non-claims: no diagnosis authority, no final clinical act.

VDLP:
- Purpose: dimension/vector derivation over ASL+transcript context.
- Input: transcript + ASL artifact.
- Output: VDLP-derived artifact.
- Provider posture: governed provider execution with scaffold/degraded honesty.
- Chunking/consolidation: legacy implementation includes processing over transcription length constraints.
- Provenance marker: `mental-space.vdlp`.
- Non-claims: no legal/clinical authority.

GEM:
- Purpose: graph-style mental-space derivation from transcript + ASL + VDLP.
- Input: transcript + ASL + VDLP artifacts.
- Output: GEM-derived artifact.
- Provider posture: governed provider execution with scaffold/degraded honesty.
- Chunking/consolidation: legacy implementation includes chunking and consolidation for token constraints.
- Provenance marker: `mental-space.gem`.
- Non-claims: no autonomous decision authority.

Legacy script guardrails:
- Legacy scripts are archived references only.
- Canonical prompt contracts now live in Swift resources.
- Prompt content must not be changed without re-validation.
- Legacy scripts must not be run against production data.

## Providers

Providers are infrastructure boundary components.

`ProviderRouter` enforces selection and policy posture.

Apple Foundation Models provider is the primary local model path when available.

Stub providers and capability profiles are explicit for degraded/scaffold operation.

Remote provider posture is governed and non-default in sensitive paths; transcript normalization v1 denies remote fallback.

Providers have no legal or clinical authority.

## Async Runtime

Async Runtime is the TypeScript async substrate (`runtime-async`).

It covers job lifecycle, idempotency posture, retry, and dead-lettering contracts.

Current maturity is scaffold/implemented seam behavior for local path, with broader SQL-backed executor hardening remaining future work.

Async Runtime is not Session Runtime.

## User-Agent Runtime

User-Agent Runtime is the TypeScript patient/user-agent governed query runtime (`runtime-user-agent`).

It enforces prohibited-capability posture and governed request boundaries.

It relates to Veridia as runtime substrate, but is not Veridia itself.

It is not Core law authority.

## Service Runtime

Service Runtime is the TypeScript service/operations workflow runtime (`service-runtime` taxonomy; current repository implementation remains limited).

It is the intended runtime locus for CloudClinic envelope-adapter and `LegalAuthorizing` guard posture.

It is not Session Runtime.

It is not Async Runtime.

It is not the CloudClinic UI.

Current maturity is doctrine-only to scaffolded contract depending on operation.

## Apps and interfaces

Scribe:
- professional-facing mediated session interface
- executable scaffold smoke path exists
- scaffold placeholders remain (no final UI claims)

Veridia:
- patient health identity app
- executable scaffold placeholder exists
- runtime/adapter maturation remains ongoing

CloudClinic:
- service-operations interface
- executable scaffold placeholder exists
- service-runtime integration remains scaffolded

Apps do not own consent, habilitation, gate, or finality law.

## Artifacts and provenance

Major artifact classes:
- transcripts
- normalized transcripts
- ASL artifacts
- VDLP artifacts
- GEM artifacts
- drafts
- gate requests/resolutions
- final artifacts
- provenance/audit records

Derived artifacts remain non-final until gate flow resolves where required.

Final artifacts require explicit gate resolution and provenance lineage.

## Runtime flow

```text
habilitation validation
  └─ consent validation
    └─ session start
      └─ GOS activation/binding where applicable
        └─ capture
          └─ transcription / degraded transcription
            └─ normalization
              ├─ MSR: ASL → VDLP → GEM
              ├─ AACI / draft composition
              └─ retrieval/context where available
                └─ draft outputs
                  └─ gate request
                    └─ gate resolution
                      ├─ final artifact
                      └─ withheld artifact
```

## Construction layer

Construction components:
- Steward
- Settler
- Territory
- Settlement
- HealthOS Forge MCP

Construction layer is outside the clinical/runtime hierarchy.

Construction components have no merge authority and no clinical authority.

## Implementation status

| Layer/component | Maturity |
|---|---|
| Core | scaffolded contract |
| GOS | implemented seam |
| Session Runtime | tested operational path |
| STT/transcription | scaffolded contract |
| normalization | implemented seam |
| AACI | implemented seam |
| MSR | implemented seam |
| ASL | implemented seam |
| VDLP | implemented seam |
| GEM | implemented seam |
| Providers | implemented seam |
| Async Runtime | implemented seam |
| User-Agent Runtime | implemented seam |
| Service Runtime | doctrine-only |
| Scribe | tested operational path |
| Veridia | scaffolded contract |
| CloudClinic | scaffolded contract |
| Steward/Settler construction system | scaffolded contract |
| Forge MCP | doctrine-only |

## Non-claims

HealthOS in this repository is not:
- production-ready
- regulatory-certified
- a complete EHR
- final UI delivery
- autonomous clinical authority
- a replacement for Core law
- proof that remote providers are allowed for all data
- evidence that Forge MCP or runtime MCP servers are implemented

## Open technical specification gaps

Required follow-up technical specifications:
- GOS primitive technical specification
- Session Runtime technical specification
- STT/transcription/normalization technical specification
- MSR artifact technical specification
- Service Runtime technical specification
- Provider policy technical specification
- App interface technical specifications for Scribe/Veridia/CloudClinic
- Construction-system technical specification for Steward/Settlers/Forge MCP

## Source documents

- `README.md`
- `docs/architecture/01-overview.md`
- `docs/architecture/05-data-layers.md`
- `docs/architecture/06-core-services.md`
- `docs/architecture/09-aaci.md`
- `docs/architecture/11-scribe.md`
- `docs/architecture/12-veridia.md`
- `docs/architecture/13-cloudclinic.md`
- `docs/architecture/16-providers-and-ml.md`
- `docs/architecture/17-glossary.md`
- `docs/architecture/19-interface-doctrine.md`
- `docs/architecture/20-runtime-operational-policy.md`
- `docs/architecture/28-first-slice-executable-path.md`
- `docs/architecture/29-governed-operational-spec.md`
- `docs/architecture/30-gos-authoring-and-compiler.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/architecture/33-gos-app-consumption-patterns.md`
- `docs/architecture/34-gos-lifecycle-and-storage.md`
- `docs/architecture/46-apple-sovereignty-architecture.md`
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
- `docs/architecture/49-mental-space-runtime.md`
- `docs/reference/mental-space-legacy/README.md`
- `docs/reference/mental-space-legacy/2-process-transcriptions.ts`
- `docs/reference/mental-space-legacy/4-asl.ts`
- `docs/reference/mental-space-legacy/5-vdlp.ts`
- `docs/reference/mental-space-legacy/6-gem.ts`
- `swift/Package.swift`
- `swift/Sources/HealthOSCore/`
- `swift/Sources/HealthOSSessionRuntime/`
- `swift/Sources/HealthOSAACI/`
- `swift/Sources/HealthOSMSR/`
- `swift/Sources/HealthOSProviders/`
- `ts/packages/runtime-async/`
- `ts/packages/runtime-user-agent/`
- `ts/packages/healthos-gos-tooling/`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/19-settler-model-task-tracker.md`
- `docs/execution/21-structural-ontology-and-product-readiness-plan.md`
- `docs/execution/22-steward-construction-operating-model.md`
