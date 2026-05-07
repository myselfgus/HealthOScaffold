# HealthOSGOS

Governed Operational Spec (GOS) runtime — operational mediation layer for HealthOS.

`HealthOSGOS` is a Tier 2 runtime module subordinate to `HealthOSCore`. GOS translates Core-governed invariants into runtime-operational spec bundles that other Tier 2 runtimes — primarily `HealthOSAACI` — consume as binding plans. GOS is operational mediation authority, never constitutional authority. Core law is sovereign; GOS operates within it.

## Architecture Position

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos      fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef boundary fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef stage    fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87

    CORE[HealthOSCore\nCore law, invariants, GOS type vocabulary]:::core
    GOS[HealthOSGOS\nThis module — GOS runtime]:::gos
    AACI[HealthOSAACI\nConsumes GOS binding plans]:::runtime
    BOUND[HealthOSAppBoundary\nBoundary compatibility module]:::boundary
    APPS[Stages\nScribe · Veridia · CloudClinic]:::stage

    CORE --> GOS
    GOS --> AACI
    AACI --> BOUND
    BOUND --> APPS
```

## Responsibilities

- Activate and resolve GOS spec bundles from the file-backed registry (`HealthOSCore/GOSFileBackedRegistry.swift`)
- Produce `GOSRuntimeBindingPlan` instances consumed by `HealthOSAACI` and other Tier 2 runtimes
- Enforce that all spec promotion, activation, and binding operations are traceable and provenance-recorded
- Mediate between Core-governed invariants and per-actor operational runtime behavior
- Reject or degrade gracefully when a requested spec is absent, malformed, or fails invariant checks

## File Map

| File | Domain |
| :--- | :--- |
| `GOSRuntime.swift` | Placeholder enum — canonical home for GOS runtime surface once migrated |

## Current Maturity

**Stub module.** `GOSRuntime.swift` declares the module namespace only. The operative GOS runtime files — `GOSBindings.swift`, `GOSRuntimeActivation.swift`, `GOSRuntimeContext.swift`, and `GOSRuntimeResolution.swift` — currently reside in `HealthOSAACI` and are scheduled for migration to this module in a dedicated task. Until that migration completes, `HealthOSGOS` is not the active GOS execution surface.

Architecture references:
- `docs/architecture/29-governed-operational-spec.md`
- `HealthOSCore/GovernedOperationalSpec.swift` — GOS type vocabulary

## Key Invariants

- GOS never holds constitutional authority. `HealthOSCore` is sovereign.
- GOS spec activation must produce a provenance record.
- A failed or missing spec must degrade gracefully; it must never silently substitute an unauthorized default.
- Apps must never consume GOS bindings directly — only through `HealthOSAACI` mediation via `HealthOSAppBoundary`.
- Do not move consent, habilitation, gate, or finality logic into GOS. Those belong to Core law.
