# Boundary, Stage, Custom, and Construction System

This document is the canonical architecture reference for keeping HealthOS app-agnostic while defining how governed application consumers enter the platform.

The file path keeps its historical app-layer wording for compatibility. The canonical conceptual names are now Boundary, Stage, and Custom.

HealthOS can exist without any specific Stage. Scribe, Veridia, CloudClinic, and future first-party, third-party, native, web, external, Swift, or other governed application consumers are Stages. They consume mediated HealthOS surfaces; they do not define HealthOS itself.

## Constitutional Hierarchy

```text
HealthOS
  Core
    constitutional law: consent, habilitation, storage law,
    provenance, gate, finality, audit, fail-closed governance
        |
        v
  GOS
    subordinate operational mediation, never constitutional authority
        |
        v
  Runtimes
    Session Runtime, AACI, MSR, Async Runtime,
    User-Agent Runtime, Service Runtime
        |
        v
  Boundary
    HealthOS-owned consumption frontier:
    facades, envelopes, safe refs, mediated state, degraded state,
    commands/results, app-safe consumable surfaces
        |
        v
  Stage
    governed application consumers: Scribe, Veridia, CloudClinic,
    future first-party/third-party/native/web/external consumers

Custom (required for each Stage)
  CoreLaw-governed definition of capabilities, limits, consumed surfaces,
  actors, degradation behavior, validation, and prohibitions.
  Custom is applied through Boundary and is not a separate HealthOS tier.

Construction System (parallel, outside clinical/runtime hierarchy)
  Steward, Settlers, Territories, Settlements, HealthOS Forge MCP.
  Produces prompts, validation records, PR drafts, derived memory.
```

## Core Rule

Stage work advances only after the mediated surface the Stage consumes is implemented and stable, not merely contracted, and after the relevant Custom is complete.

A contract-only surface can be useful evidence, but it is not enough for non-provisional Stage wiring. Building a Stage adapter around absent or unstable platform behavior creates false scaffold that will need to be rewritten.

## What Stages May Consume

Stages may consume:

- command/result envelopes issued by Core or runtime-mediated facades;
- app-safe views and summaries;
- safe refs that do not grant access by themselves;
- mediated runtime state, including explicit degraded/unavailable states;
- provenance-facing metadata that explains what happened without exposing raw internals.

Stages may not consume:

- raw storage internals, reidentification maps, or direct identifiers by default;
- raw GOS spec JSON or compiled runtime-binding payloads as Stage law;
- provider secrets, provider raw JSON, or clinical payload dumps;
- incomplete platform contracts as if they were stable implementation.

## Hierarchy And Readiness Map

The HealthOS hierarchy ends at Stage. Custom is a required governed definition for a Stage, not its own HealthOS tier. Construction System work is external to the clinical/runtime hierarchy.

| Class | Name | Examples | Advancement rule |
|---|---|---|---|
| HealthOS Tier 1 | Core | `CI-001`, storage law, validation harness, Core law guard propagation | Can remain READY when not blocked by Stage-specific dependencies; should advance before Stage work that relies on the surface |
| HealthOS Tier 2 | GOS / Runtimes | `RT-ASYNC-001`, `RT-RETRIEVAL-001`, Session Runtime, AACI, GOS runtime views, MSR/provider execution, Async/User-Agent/Service runtimes | Must expose honest, implemented, stable mediated surfaces before Stages consume them non-provisionally |
| HealthOS Tier 3 | Boundary | facades, envelopes, safe refs, command/result envelopes, mediated state adapters, degraded-state views | Must be implemented and tested before Stage shells or wiring rely on it |
| Stage readiness gate | Custom | Scribe, Veridia, CloudClinic, and future Stage definitions | Required before new Stage implementation or substantial new wiring; CoreLaw-governed and applied through Boundary |
| HealthOS Tier 4 | Stage | Scribe UI work, Veridia wiring, CloudClinic session wiring, future Stage shells | BLOCKED until relevant Core/GOS/Runtime/Boundary dependencies and Custom readiness are DONE or explicitly accepted with degraded semantics |
| External | Construction System | Steward, Settlers, Territories, Settlements, HealthOS Forge MCP, prompt generation, validation drafts | Independent construction work may run in parallel; construction output targeting blocked Stage wiring must be reframed or blocked |

## Current Customs

### Custom Template

Every Stage needs at least:

- Stage name and role;
- users/actors served;
- mediated surfaces consumed;
- upstream Core/GOS/Runtime/Boundary dependencies;
- explicit non-authority boundaries;
- degraded/unavailable-state behavior;
- data exposure limits;
- validation/smoke expectations;
- unblock criteria before implementation.

### Scribe Custom

| Field | Current Custom |
|---|---|
| Stage role | Professional workspace / documentation capture Stage |
| Actors | Professional operator in a governed session context |
| Mediated surfaces consumed | `ScribeFirstSliceFacade`, `ScribeSessionBridgeState`, command/result envelopes, gate and final document summaries, GOS runtime summaries, MSR stage summaries |
| Upstream dependencies | Core law, Session Runtime, AACI first slice, bounded retrieval, gate/finality, GOS runtime mediation, MSR derived artifact surfaces where explicitly exposed |
| Non-authority boundaries | Does not own consent, habilitation, gate, finality, referral/prescription law, storage law, GOS policy, provider routing, or clinical authority |
| Current maturity | Valid proof of Boundary scaffold: minimal Scribe validation surface consumes mediated state and exposes degraded/draft-only truth |
| Unblock criteria for new wiring | The specific mediated surface being added must be implemented and stable, with Boundary tests or smoke evidence, and the Scribe Custom must cover it |

### Veridia Custom

| Field | Current Custom |
|---|---|
| Stage role | Patient health identity Stage |
| Actors | Patient/user interacting with Core-mediated identity, consent, access trail, export, and patient-agent surfaces |
| Mediated surfaces consumed | `VeridiaSessionFacade`, `VeridiaSessionAdapter`, `UserSovereigntyContracts`, app-safe patient consent/access/export/data visibility summaries, patient-agent envelopes |
| Upstream dependencies | Core law, User-Agent Runtime boundary, app-safe identity and consent surfaces, key custody mediated by Core and Apple substrate |
| Non-authority boundaries | Does not own Core law, key custody authority, consent law, storage law, User-Agent Runtime, clinical acts, prescriptions, referrals, signatures, or record finalization |
| Current maturity | Valid proof of Boundary scaffold: smoke-testable session start/end boundary exists; no final UI shell or patient-agent runtime product flow is claimed |
| Unblock criteria for new wiring | The exact patient/user mediated surface and Custom field must be implemented and tested before UI/session wiring grows |

### CloudClinic Custom

| Field | Current Custom |
|---|---|
| Stage role | Service operations Stage |
| Actors | Service/professional operations users working with queues, worklists, service membership, gate backlog, and operational visibility |
| Mediated surfaces intended | `ServiceOperationsContracts`, service context, membership, queue/worklist, draft/document metadata, gate backlog, administrative task, runtime health and issue surfaces |
| Upstream dependencies | Core service-operations law, Service Runtime mediation, durable async/worklist semantics, governed retrieval/context surfaces where used, app-safe command/result envelopes |
| Non-authority boundaries | Does not own service access law, membership policy, gate/finality law, queue-as-authorization, storage law, clinical authority, signature, interoperability, or real provider behavior |
| Current maturity | Incomplete Custom for implementation: contracts and placeholder executable exist, but smoke-testable service session wiring and stable upstream mediated surfaces are not complete |
| Missing before APP-012 | Confirm stable Service Runtime/Boundary; decide whether APP-012 consumes only Core contract validation or also async queue/retrieval surfaces; define degraded behavior when SQL async and semantic retrieval are unavailable |
| Unblock criteria | Relevant Core/GOS/Runtime tasks accepted or DONE, Service Runtime mediation stable, Boundary facade/envelope specified, CloudClinic Custom completed |

## Drift Register

This audit found four classes of drift:

| Drift | Evidence | Disposition |
|---|---|---|
| Boundary naming drift | Some docs still named the canonical layer "App Integration Boundary" | Replace conceptual use with Boundary while preserving technical names such as `HealthOSAppBoundary` |
| Stage naming drift | Some docs treated Scribe, Veridia, and CloudClinic as a closed reference-app layer | Replace with Stage language and state that future governed consumers may exist in arbitrary number |
| Custom drift | The governed Stage definition was still called App Charter and sometimes modeled as a separate tier | Replace with Custom and state that Custom is CoreLaw-governed, applied through Boundary, and not a HealthOS tier |
| Ordering drift | APP-012 was READY while platform/runtime surfaces such as async execution, semantic retrieval, and CI still provide Stage-consumable foundations | APP-012 remains BLOCKED until Core/GOS/Runtime/Boundary/Custom readiness criteria are satisfied |

Historical validation entries that honestly recorded scaffold status at the time do not need to be erased. New work must apply this Boundary/Stage/Custom doctrine from this ADR forward.
