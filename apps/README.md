# apps/

Boundary scaffolds and design surface documentation for initial HealthOS Stages.

Stages are consumers of mediated platform surfaces — they never define Core law, constitutional authority, or HealthOS ontology. Each Stage consumes `HealthOSBoundary` (Tier 3) only; it never imports Tier 1/2 modules directly.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph LR
    classDef boundary fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef stage    fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87
    classDef design   fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A

    AB[HealthOSBoundary\nTier 3 — mediated surface]:::boundary
    DS[HealthOSDesignSystem\npresentation guidance only]:::design
    SC[Scribe\nprofessional workspace]:::stage
    VE[Veridia\npatient health identity]:::stage
    CC[CloudClinic\nservice operations]:::stage

    AB --> SC & VE & CC
    DS -. presentation only .-> SC & VE & CC
```

---

## Initial Stages

| Stage | Surface | Maturity | Swift target |
| :--- | :--- | :--- | :--- |
| **Scribe** | Professional clinical workspace — session capture, transcript, SOAP draft, gate | Minimal validation surface (SwiftUI, macOS 26+) | `HealthOSScribeStage` |
| **Veridia** | Patient health identity — identity management, consent, access trail, export | Session boundary smoke — no final UI | `HealthOSVeridiaStage` |
| **CloudClinic** | Service operations — service setup, professional onboarding, ops dashboard | Scaffold placeholder — no final UI | `HealthOSCloudClinicStage` |

Full executable surface documentation: [`swift/Sources/`](../swift/Sources/)  
Design system: [`HealthOSDesignSystem/`](../HealthOSDesignSystem/)

---

**None of these Stages are production-ready.**
