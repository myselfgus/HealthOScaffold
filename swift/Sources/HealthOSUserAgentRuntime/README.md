# HealthOSUserAgentRuntime

User-Agent Runtime — patient and user-side session lifecycle and sovereignty enforcement for HealthOS.

`HealthOSUserAgentRuntime` is a Tier 2 module subordinate to `HealthOSCore`. It owns the patient/user-facing session surface: sovereignty enforcement, consent execution, user-sovereign state management, and audit trail for user-initiated actions. It is not constitutional authority and does not hold consent law — it executes consent operations as delegated by Core.

## Architecture Position

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef boundary fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef stage    fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87

    CORE[HealthOSCore\nUserSovereigntyContracts.swift]:::core
    UAR[HealthOSUserAgentRuntime\nThis module]:::runtime
    BOUND[HealthOSAppBoundary\nBoundary compatibility module]:::boundary
    VERIDIA[HealthOSVeridiaApp\nPatient health identity Stage]:::stage

    CORE --> UAR
    UAR --> BOUND
    BOUND --> VERIDIA
```

## Responsibilities

- Manage user-sovereign session state: initialization, active, suspended, and terminated lifecycle states
- Execute consent grant and revocation operations delegated by Core law
- Enforce that no raw direct patient identifiers (CPF, name, date of birth) are stored or transmitted in unmasked form
- Produce per-action audit trail entries for every user-sovereign state transition
- Surface user-facing degraded states when upstream Tier 2 runtimes are unavailable

## File Map

| File | Domain |
| :--- | :--- |
| `UserAgentRuntime.swift` | Placeholder enum — user-sovereign session surface, consent execution, and audit trail pending implementation |

## Current Maturity

**Scaffold stub.** `UserAgentRuntime.swift` declares the module namespace only. The user-sovereign session surface, consent execution path, identifier masking enforcement, and audit trail are not yet implemented.

`HealthOSVeridiaApp` (technical executable for the patient health identity Stage) is the primary Stage consumer of this runtime via `HealthOSAppBoundary`. Veridia Stage wiring to this surface is blocked until the mediated session surface is implemented and stable.

Type vocabulary cross-reference: `HealthOSCore/UserSovereigntyContracts.swift`

## Key Invariants

- This module does not hold consent law. It executes consent operations as directed by Core.
- Raw direct patient identifiers must never be stored, logged, or transmitted by this module.
- Every consent state transition must produce a provenance record.
- User-sovereign session state must fail closed: if Core invariant checks fail, the session must not proceed.
- Degraded states must be surfaced explicitly — silent availability claims are forbidden.
