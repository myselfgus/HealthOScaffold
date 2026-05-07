# HealthOSAppBoundary

App Integration Boundary — the sole permitted import surface for Tier 5 apps.

`HealthOSAppBoundary` is the Tier 3 gateway between the HealthOS runtime stack (Tiers 1–2) and app implementations (Tier 5). No app may import `HealthOSCore`, `HealthOSAACI`, `HealthOSSessionRuntime`, or any other Tier 1–2 module directly. All app-facing surfaces — session facades, mediated state, safe refs, command/result envelopes, and degraded-state views — are exposed exclusively through this module.

## Architecture Position

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef boundary fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef app      fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87

    CORE[HealthOSCore]:::core
    RT["Tier 2 Runtimes\nAACI · GOS · MSR · SessionRuntime\nAsyncRuntime · UserAgentRuntime · ServiceRuntime"]:::runtime
    BOUND[HealthOSAppBoundary\nThis module — Tier 3 boundary]:::boundary
    SCRIBE[HealthOSScribeApp]:::app
    VERIDIA[HealthOSVeridiaApp]:::app
    CC[HealthOSCloudClinicApp]:::app

    CORE --> RT
    RT --> BOUND
    BOUND --> SCRIBE
    BOUND --> VERIDIA
    BOUND --> CC
```

## Responsibilities

- Expose app-safe session surfaces — facades that wrap `HealthOSSessionRuntime` without leaking internal types
- Provide mediated state views, safe object references, command envelopes, and result envelopes
- Surface degraded-state representations so apps can render gracefully when Tier 2 runtimes are unavailable
- Enforce the boundary contract: no raw direct identifiers, no GOS spec JSON, no provider secrets, no storage paths reach app code
- Remain the single dependency point; adding a new Tier 2 surface to apps always goes through this module first

## File Map

| File | Domain |
| :--- | :--- |
| `AppBoundary.swift` | Placeholder enum — facade implementation pending Tier 2 surface stabilization |

## Current Maturity

**Stub / scaffold.** `AppBoundary.swift` imports all upstream Tier 2 modules and declares the namespace, but no facades or envelopes are implemented. Facade implementation is blocked on Tier 2 surface stabilization.

Known deviations (marked as TODO in `Package.swift`):
- `HealthOSVeridiaApp` retains a direct dependency on `HealthOSCore` and `HealthOSSessionRuntime` pending AppBoundary completion.
- `HealthOSScribeApp` retains a direct dependency on `HealthOSCore` and `HealthOSSessionRuntime` pending AppBoundary completion.

These deviations are tracked and must be resolved before Tier 5 apps are considered boundary-compliant.

Architecture reference: `docs/execution/21-structural-ontology-and-product-readiness-plan.md`

## Key Invariants

- Tier 5 apps must import `HealthOSAppBoundary` only — never any Tier 1–2 module directly.
- Raw direct identifiers (CPF, name, DOB in unmasked form) must never appear in any type exported by this module.
- Degraded-state views must be accurate; they must not claim availability that Tier 2 has not confirmed.
- Facade implementations must not bypass Core law checks (consent, habilitation, gate, finality, provenance).
- App wiring advances only after the mediated surface it consumes is implemented and stable at Tier 2.
