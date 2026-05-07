# swift/

Swift package for HealthOS — all native platform targets, from Core law through Stages.
Open `swift/Package.swift` in Xcode (or `cd swift && swift build`) to work with this surface.

External dependencies: none. Sovereignty by design.

---

## Package Structure

Fifteen targets across Core, GOS/runtimes, Boundary, and Stage groups, plus the operator CLI.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos      fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef provider fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef msr      fill:#ede9fe,stroke:#a78bfa,stroke-width:2px,color:#3b0764
    classDef boundary fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef app      fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87
    classDef cli      fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    CORE[HealthOSCore\nlaw · governance · contracts]:::core

    PROV[HealthOSProviders\nFoundationModels · stubs · ModelGovernance]:::provider
    GOS[HealthOSGOS\nGOS runtime · operational mediation]:::gos
    AACI[HealthOSAACI\nsession · GOS bindings · capture]:::runtime
    MSR[HealthOSMSR\nASL · VDLP · GEM pipeline]:::msr
    ASYNC[HealthOSAsyncRuntime\njob queue · lifecycle]:::runtime
    UAR[HealthOSUserAgentRuntime\npatient session · sovereignty]:::runtime
    SVR[HealthOSServiceRuntime\nservice operations session]:::runtime
    SRT[HealthOSSessionRuntime\norchestration · normalization · bridge]:::runtime

    AB[HealthOSAppBoundary\nfacades · safe refs · envelopes]:::boundary

    CLI[HealthOSCLI\noperator executable]:::cli
    SCRIBE[HealthOSScribeApp\nSwiftUI · Liquid Glass · macOS 26+]:::app
    VERIDIA[HealthOSVeridiaApp\npatient identity surface]:::app
    CC[HealthOSCloudClinicApp\nservice operations surface]:::app

    CORE --> PROV & GOS & MSR & ASYNC & UAR & SVR & SRT
    PROV --> AACI & MSR
    GOS --> AACI
    CORE --> AACI
    AACI & MSR & ASYNC & UAR & SVR & SRT --> AB
    GOS & CORE --> AB
    CORE & SRT --> CLI
    AB & SRT --> SCRIBE
    AB & CORE --> VERIDIA
    AB --> CC
```

---

## Module Reference

### Tier 1 — Core Law

| Module | README | Maturity |
| :--- | :--- | :--- |
| `HealthOSCore` | [README](Sources/HealthOSCore/README.md) | Implemented seam |

Core law, governance invariants, entity model, storage contracts, consent/habilitation/gate/finality types, GOS type vocabulary, MSR runtime types.

---

### Tier 2 — Runtime / Mediation

| Module | README | Maturity |
| :--- | :--- | :--- |
| `HealthOSProviders` | [README](Sources/HealthOSProviders/README.md) | Implemented seam |
| `HealthOSGOS` | [README](Sources/HealthOSGOS/README.md) | Scaffold stub (migration from AACI pending) |
| `HealthOSAACI` | [README](Sources/HealthOSAACI/README.md) | Implemented seam (bounded scope) |
| `HealthOSMSR` | [README](Sources/HealthOSMSR/README.md) | Scaffold (executors present, provider integration pending) |
| `HealthOSAsyncRuntime` | [README](Sources/HealthOSAsyncRuntime/README.md) | Scaffold stub |
| `HealthOSUserAgentRuntime` | [README](Sources/HealthOSUserAgentRuntime/README.md) | Scaffold stub |
| `HealthOSServiceRuntime` | [README](Sources/HealthOSServiceRuntime/README.md) | Scaffold stub |
| `HealthOSSessionRuntime` | — | Implemented seam |

---

### Tier 3 — Boundary

| Module | README | Maturity |
| :--- | :--- | :--- |
| `HealthOSAppBoundary` | [README](Sources/HealthOSAppBoundary/README.md) | Scaffold stub — facade pending Tier 2 stabilization |

The only surface Stages are permitted to import. Stages must never import Core, SessionRuntime, or any Tier 2 module directly. Known deviations (Veridia to Core, Scribe to SessionRuntime) are marked TODO in `Package.swift` pending Boundary facade completion.

---

### Operator CLI

`HealthOSCLI` — command-line interface for session and GOS bundle lifecycle. Not a Stage; depends directly on Core and SessionRuntime as an operator-facing tool.

```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSCLI --reject-gate
cd swift && swift run HealthOSCLI \
  --gos-review-bundle <id> --gos-spec-id <id> \
  --reviewer-id <id> --review-rationale "<reason>"
```

---

### Tier 4 — Stages

| Stage target | Scheme | Smoke command | Maturity |
| :--- | :--- | :--- | :--- |
| `HealthOSScribeApp` | `HealthOSScribeApp` | `swift run HealthOSScribeApp --smoke-test` | Minimal validation surface (SwiftUI, macOS 26+) |
| `HealthOSVeridiaApp` | `HealthOSVeridiaApp` | `swift run HealthOSVeridiaApp --smoke-test` | Session boundary smoke — no final UI |
| `HealthOSCloudClinicApp` | `HealthOSCloudClinicApp` | `swift run HealthOSCloudClinicApp --smoke-test` | Scaffold placeholder — no final UI |

Shared Xcode schemes live in `.swiftpm/xcode/xcshareddata/xcschemes/` and are committed — open `swift/Package.swift` in Xcode to use them. Each scheme pre-configures smoke-test launch arguments (disabled by default) and a Release profile action for Instruments.

Stage icon asset catalogs (`Resources/Assets.xcassets/AppIcon.appiconset/`) are present as slots; actual icon images are produced by Icon Composer and placed there before release.

---

## Tests

| Target | Scope | Maturity |
| :--- | :--- | :--- |
| `HealthOSTests` | Existing integration tests across Core, AACI, Providers, MSR, SessionRuntime | Operational |
| `HealthOSCoreTests` | Core law unit tests | Scaffold stub |
| `HealthOSRuntimeTests` | Tier 2 runtime integration tests | Scaffold stub |
| `HealthOSAppBoundaryTests` | Tier 3 boundary contract tests | Scaffold stub |

```bash
cd swift && swift build
cd swift && swift test
```

---

## Build and Validation

```bash
cd swift && swift build          # build all targets
cd swift && swift test           # run all test suites
cd swift && swift run HealthOSCLI --smoke-test   # first-slice smoke
make swift-build                 # from repo root
make swift-test
make smoke-cli
make smoke-scribe
make smoke-veridia
make smoke-cloudclinic
```

Xcode: open `swift/Package.swift` — not the root `Package.swift`.
