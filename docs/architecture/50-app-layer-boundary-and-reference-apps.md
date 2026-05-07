# App Layer Boundary and Reference Apps

This document is the canonical architecture reference for keeping HealthOS app-agnostic while still allowing reference apps to consume mediated HealthOS surfaces.

HealthOS can exist without any specific app. Scribe, Veridia, CloudClinic, and future apps are consumers of mediated surfaces, not definitions of HealthOS itself.

## Layer Model

```text
HealthOS Platform / Core Layer
  Core law, sovereign contracts, storage law, consent, habilitation,
  finalidade, provenance, gate, fail-closed governance
        |
        v
Runtime / Mediation Layer
  Session Runtime, AACI, GOS, MSR, Providers, Async Runtime,
  User-Agent Runtime, Service Runtime
        |
        v
App Integration Boundary
  Facades, envelopes, app-safe views, safe refs, command/result envelopes,
  mediated state, degraded-state truth, provenance-facing summaries
        |
        v
Reference App Layer
  Initial reference apps: Scribe, Veridia, CloudClinic.
  Future apps may be added in arbitrary number.

Construction System (parallel, outside clinical/runtime hierarchy)
  Steward, Settler, Territory, Settlement, HealthOS Forge MCP.
  Produces prompts, validation records, PR drafts, derived memory.
```

## Core Rule

App wiring advances only after the mediated surface the app consumes is implemented and stable, not merely contracted.

A contract-only surface can be useful evidence, but it is not enough for non-provisional app wiring. Building an app adapter around absent or unstable platform behavior creates false scaffold that will need to be rewritten.

## What Apps May Consume

Apps may consume:

- command/result envelopes issued by Core or runtime-mediated facades;
- app-safe views and summaries;
- safe refs that do not grant access by themselves;
- mediated runtime state, including explicit degraded/unavailable states;
- provenance-facing metadata that explains what happened without exposing raw internals.

Apps may not consume:

- raw storage internals, reidentification maps, or direct identifiers by default;
- raw GOS spec JSON or compiled runtime-binding payloads as app law;
- provider secrets, provider raw JSON, or clinical payload dumps;
- incomplete platform contracts as if they were stable implementation.

## Tier Map

The first five tiers order platform-to-app work. Tier 6 is parallel construction-system work outside the clinical/runtime hierarchy.

| Tier | Name | Examples | Advancement rule |
|---|---|---|---|
| 1 | Platform/Core | `CI-001`, storage law, validation harness, Core law guard propagation, `RT-ASYNC-001` when it provides durable platform execution | Can remain READY when not blocked by app-specific dependencies; should advance before app wiring that relies on the surface |
| 2 | Runtime/Mediation | `RT-RETRIEVAL-001`, Session Runtime, AACI, GOS runtime views, MSR/provider execution, Async/User-Agent/Service runtimes | Must expose honest, implemented, stable mediated surfaces before apps consume them non-provisionally |
| 3 | App Integration Boundary | app-safe facades, envelopes, safe refs, command/result envelopes, mediated state adapters | Must be implemented and tested before app shell/wiring relies on it |
| 4 | App Charter | Scribe, Veridia, CloudClinic charters and future app charters | Required before new app implementation or substantial new wiring |
| 5 | App Implementation | Scribe UI work, Veridia app wiring, CloudClinic session wiring, future app shells | BLOCKED until relevant Tier 1-4 dependencies are DONE or explicitly accepted with degraded semantics |
| 6 | Construction System | Steward, Settler, Territory, Settlement, HealthOS Forge MCP, prompt generation, validation drafts | Independent construction work may run in parallel; construction output targeting blocked app wiring must be reframed or blocked |

## Current App Charters

### Charter Template

Every reference app or future app needs at least:

- app name and role;
- users/actors served;
- mediated surfaces consumed;
- upstream platform/runtime dependencies;
- explicit non-authority boundaries;
- degraded/unavailable-state behavior;
- data exposure limits;
- validation/smoke expectations;
- unblock criteria before implementation.

### Scribe Charter

| Field | Current charter |
|---|---|
| App role | Professional workspace / documentation capture reference app |
| Actors | Professional operator in a governed session context |
| Mediated surfaces consumed | `ScribeFirstSliceFacade`, `ScribeSessionBridgeState`, command/result envelopes, gate and final document summaries, GOS runtime summaries, MSR stage summaries |
| Upstream dependencies | Core law, Session Runtime, AACI first slice, bounded retrieval, gate/finality, GOS runtime mediation, MSR derived artifact surfaces where explicitly exposed |
| Non-authority boundaries | Does not own consent, habilitation, gate, finality, referral/prescription law, storage law, GOS policy, provider routing, or clinical authority |
| Current maturity | Valid proof of boundary scaffold: minimal Scribe validation surface consumes mediated state and exposes degraded/draft-only truth |
| Unblock criteria for new wiring | The specific mediated surface being added must be implemented and stable, with bridge tests or smoke evidence |

### Veridia Charter

| Field | Current charter |
|---|---|
| App role | Patient health identity reference app |
| Actors | Patient/user interacting with Core-mediated identity, consent, access trail, export, and patient-agent surfaces |
| Mediated surfaces consumed | `VeridiaSessionFacade`, `VeridiaSessionAdapter`, `UserSovereigntyContracts`, app-safe patient consent/access/export/data visibility summaries, patient-agent envelopes |
| Upstream dependencies | Core law, User-Agent Runtime boundary, app-safe identity and consent surfaces, key custody mediated by Core and Apple substrate |
| Non-authority boundaries | Does not own Core law, key custody authority, consent law, storage law, User-Agent Runtime, clinical acts, prescriptions, referrals, signatures, or record finalization |
| Current maturity | Valid proof of boundary scaffold: smoke-testable session start/end boundary exists; no final UI shell or patient-agent runtime product flow is claimed |
| Unblock criteria for new wiring | The exact patient/user mediated surface and App Charter field must be implemented and tested before UI/session wiring grows |

### CloudClinic Charter

| Field | Current charter |
|---|---|
| App role | Service operations reference app |
| Actors | Service/professional operations users working with queues, worklists, service membership, gate backlog, and operational visibility |
| Mediated surfaces intended | `ServiceOperationsContracts`, service context, membership, queue/worklist, draft/document metadata, gate backlog, administrative task, runtime health and issue surfaces |
| Upstream dependencies | Core service-operations law, Service Runtime mediation, durable async/worklist semantics, governed retrieval/context surfaces where used, app-safe command/result envelopes |
| Non-authority boundaries | Does not own service access law, membership policy, gate/finality law, queue-as-authorization, storage law, clinical authority, signature, interoperability, or real provider behavior |
| Current maturity | Incomplete charter for implementation: contracts and placeholder executable exist, but smoke-testable service session wiring and stable upstream mediated surfaces are not complete |
| Missing before APP-012 | Confirm stable Service Runtime/App Integration Boundary; decide whether APP-012 consumes only Core contract validation or also async queue/retrieval surfaces; define degraded behavior when SQL async and semantic retrieval are unavailable |
| Unblock criteria | Tier 1 platform tasks accepted or DONE for relevant surfaces, Tier 2 service/runtime mediation stable, Tier 3 app-safe facade/envelope specified, CloudClinic charter completed |

## Drift Register

This audit found three classes of drift:

| Drift | Evidence | Disposition |
|---|---|---|
| Language drift | Some docs treated the initial reference apps as a closed set | Replace with "initial reference apps" or "apps can be added in arbitrary number" in current doctrine docs |
| Ordering drift | APP-012 was READY while platform/runtime surfaces such as async execution, semantic retrieval, and CI still provide app-consumable foundations | APP-012 becomes BLOCKED until relevant surfaces and charter criteria are satisfied |
| Boundary drift | Existing Scribe and Veridia scaffold could be misread as permission for more app wiring on unstable surfaces | Record them as valid proof of boundary scaffold only |

Historical validation entries that honestly recorded scaffold status at the time do not need to be erased. New work must apply this boundary from this ADR forward.
