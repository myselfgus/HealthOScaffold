<p align="center">
  <img src="docs/assets/healthos_overview.gif" width="100%" alt="HealthOS — Sovereign Clinical Platform">
</p>

<p align="center">
  <img src="https://img.shields.io/badge/Swift-6.2-FA7343?style=flat&logo=swift&logoColor=white" alt="Swift 6.2">
  <img src="https://img.shields.io/badge/macOS-26%2B-000000?style=flat&logo=apple&logoColor=white" alt="macOS 26+">
  <img src="https://img.shields.io/badge/Platform-Apple%20Silicon-333333?style=flat&logo=apple&logoColor=white" alt="Apple Silicon">
  <img src="https://img.shields.io/badge/Build-SwiftPM%206.2-orange?style=flat" alt="SwiftPM 6.2">
  <img src="https://img.shields.io/badge/Phase-Scaffold%20Hardening-3B82F6?style=flat" alt="Scaffold Hardening">
  <img src="https://img.shields.io/badge/UI-Liquid%20Glass%20%28macOS%2026%2B%29-8B5CF6?style=flat" alt="Liquid Glass">
  <img src="https://img.shields.io/badge/AI-Apple%20FoundationModels-000000?style=flat&logo=apple&logoColor=white" alt="Apple FoundationModels">
</p>

# HealthOS

> **Sovereign computational environment for health data and clinical operations.**  
> Governance-first architecture — every clinical act mediated through strictly layered contract law.

**HealthOScaffold is the historical repository name for the scaffold/foundation phase of HealthOS.** All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are HealthOS work. "Scaffold" describes maturity, not product identity.

**This repository is not production-ready, not a complete EHR, and not a final UI delivery.** It establishes foundational architecture with executable first-slice orchestration, cross-language contracts (Swift / TypeScript / JSON Schema / SQL), and macOS 26+ native app surfaces targeting Liquid Glass as the design baseline.

HealthOS is the full app-agnostic platform. **AACI is one runtime inside HealthOS. GOS is a governed operational layer subordinate to Core law. Initial reference apps such as Scribe, Veridia, CloudClinic, and future apps consume mediated surfaces; they never define constitutional law or the HealthOS ontology.**

---

## How to Read This Repository

Use this README as an entry surface, not as a replacement for the canonical architecture and execution docs. The repository mixes tested operational paths, implemented seams, scaffolded contracts, placeholders, and future gaps; read every claim through that maturity lens.

| Reader question | Current answer | Canonical follow-up |
| :--- | :--- | :--- |
| What is HealthOS? | The whole governed, app-agnostic platform for health operations, not one app or an EHR skin. | `docs/architecture/01-overview.md` |
| What proves executable behavior today? | The Swift first-slice path through habilitation, consent, capture, retrieval, SOAP draft, gate, final SOAP, and provenance. | `docs/architecture/28-first-slice-executable-path.md` |
| What is still scaffolded or placeholder? | Provider deployment, semantic retrieval, final app shells, regulatory/signature/interoperability effectuation, and production ops. | `docs/execution/11-current-maturity-map.md` |
| Where does construction tooling sit? | Steward, Settlers, Settlements, Territories, and `healthos-forge-mcp` are repository engineering surfaces outside the clinical/runtime hierarchy. | `docs/execution/22-steward-construction-operating-model.md` |

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart LR
    classDef core fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef runtime fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef interface fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef design fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A
    classDef construction fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef boundary fill:#F2F4F7,stroke:#8793A1,stroke-width:2px,color:#334155

    subgraph CLINICAL["HealthOS clinical/runtime hierarchy"]
        CORE[Core law\nconsent · habilitation · gate · finality]:::core
        GOS[GOS\nsubordinate operational mediation]:::runtime
        RT[Runtimes\nSession Runtime · AACI · MSR · TS runtimes]:::runtime
        AIB[App Integration Boundary\nfacades · envelopes · app-safe views]:::interface
        APP[Reference apps\nScribe · Veridia · CloudClinic · future apps]:::interface
        DS[Native design system\nmacOS 26+ presentation contract\nSF Pro · semantic tint · Liquid Glass]:::design
        ART[Artifacts/effects\ndrafts · derived artifacts · gated final documents]:::core
        CORE --> GOS --> RT --> AIB --> APP
        APP --> DS
        APP --> ART
    end

    subgraph BUILD["Repository construction layer"]
        STEW[Steward\ncoordination]:::construction
        SETT[Settlers\nspecialized engineering profiles]:::construction
        TERR[Territories\nrepository domains]:::construction
        WORK[Settlements\nbounded work units]:::construction
        MCP[healthos-forge-mcp\nrepo-maintenance tools]:::construction
        STEW --> SETT
        SETT --> TERR
        STEW --> WORK
        MCP -. deterministic repository operations .-> STEW
    end

    BUILD -. outside clinical/runtime hierarchy .-> CLINICAL
    DS -. presentation only, never law .-> APP
```

### Evidence and Maturity Lens

| Maturity term | How to read it here | Example surfaces |
| :--- | :--- | :--- |
| `tested operational path` | Executable path plus tests/smoke evidence inside the scaffold boundary. | Core law, GOS lifecycle/tooling, validation harness, first-slice gate behavior |
| `implemented seam` | Real interface or adapter exists, but broader production or multi-runtime coverage is still incomplete. | AACI first-slice mediation, local async runtime, Scribe minimal validation surface, construction system |
| `scaffolded contract` | Types, schemas, docs, or validators define the boundary, but full runtime/UI/provider behavior is not complete. | MSR stage contracts, provider/ML posture, Veridia and CloudClinic app-safe contracts |
| `doctrine-only` / placeholder | Canonical scope or target exists without executable product behavior. | Future HealthOS control panel, production mesh/fabric, final native app shells |
| not claimed | Do not infer this from the scaffold. | production readiness, complete EHR, real regulatory/signature/interoperability integration, real semantic retrieval |

---

## 🏗️ Canonical Architecture

HealthOS is a governance-first platform. Every clinical act flows through a strictly layered, consent- and provenance-governed fabric. Apps and interfaces consume only mediated surfaces — they never become law engines.

App wiring advances only after the mediated surface the app consumes is implemented and stable, not merely contracted. See `docs/architecture/50-app-layer-boundary-and-reference-apps.md` for the App Integration Boundary, App Charter template, and tiered task ordering.

Steward, Settlers, Settlements, Territories, and `healthos-forge-mcp` are repository engineering concepts **outside** this clinical/runtime hierarchy. They inspect, edit, validate, and record repository work. They do not become HealthOS law, runtime automation, or clinical effectuation.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'titleColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef iface    fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef design   fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A
    classDef gos      fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef session  fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef swift    fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef tsrt     fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef provider fill:#F5F2F7,stroke:#7B5E8E,stroke-width:2px,color:#3A2946
    classDef core     fill:#EAF7F2,stroke:#2E8C6A,stroke-width:2px,color:#174234
    classDef substrate fill:#F2F4F7,stroke:#8793A1,stroke-width:2px,color:#334155

    subgraph IFACE["  Interfaces  "]
        SC[Scribe\nSwiftUI - macOS 26+]
        SO[Veridia\nPatient Health Identity]
        CC[CloudClinic\nService Operations]
    end

    subgraph DS_L["  Native Design System — Presentation Contract  "]
        DS[HealthOSDesignSystem\nSF Pro · semantic state colors\nstandard controls first · Liquid Glass when needed]
    end

    subgraph GOS_L["  GOS — Governed Operational Spec  "]
        GOS[Compiler - Validator - Bundler\nTypeScript tooling + Swift runtime consumption\nBundle lifecycle - AACI binding]
    end

    subgraph SRT_L["  Session Runtime — Swift  "]
        SR[SessionRunner\nFirst-slice orchestrator - Swift actor\nHabilitation - Consent - Capture - Gate]
    end

    subgraph SWIFT_L["  Swift Runtimes  "]
        AACI[AACI\nCapture - Transcription\nDraft composition - GOS binding]
        MSR[MSR\nASL - VDLP - GEM\nSemantic enrichment - Provenance]
        PROV[Providers\nFoundationModels - ProviderRouter\nStubs - Capability profiles]
    end

    subgraph TS_L["  TypeScript Runtimes  "]
        ASYNC[Async Runtime\nJobs - Idempotency\nRetry - Dead-lettering]
        UA[User-Agent Runtime\nPatient-governed queries\nProhibited-capability enforcement]
        SVC[Service Runtime\nCloudClinic envelope adapter\nLegalAuthorizing guard]
    end

    subgraph CORE_L["  Core Law  "]
        ID[Identity\nHabilitation]
        CO[Consent\nFinalidade]
        PR[Provenance\nAudit]
        GA[Gate\nFinalization]
    end

    subgraph SUB["  Material Substrate  "]
        ST[Storage - File-backed\nAPFS + FileVault + Secure Enclave]
        NE[Mesh - VPN - Network]
    end

    DS -. presentation guidance only .-> SC
    DS -. presentation guidance only .-> SO
    DS -. presentation guidance only .-> CC
    SC -->|mediated surface| GOS
    SO -->|mediated surface| GOS
    CC -->|mediated surface| GOS
    GOS -->|runtime binding| SR
    SR --> AACI
    SR --> MSR
    AACI --> PROV
    MSR --> PROV
    SR -->|lawful-context| ID
    SR -->|lawful-context| CO
    SR -->|lawful-context| PR
    SR -->|lawful-context| GA
    AACI -->|lawful-context| ID
    AACI -->|lawful-context| GA
    MSR -->|lawful-context| PR
    ASYNC -->|lawful-context| CO
    ASYNC -->|lawful-context| PR
    UA -->|lawful-context| CO
    UA -->|lawful-context| PR
    SVC -->|lawful-context| ID
    SVC -->|lawful-context| CO
    ID --> ST
    ID --> NE
    CO --> ST
    CO --> NE
    PR --> ST
    PR --> NE
    GA --> ST
    GA --> NE

    class SC,SO,CC iface
    class DS design
    class GOS gos
    class SR session
    class AACI,MSR swift
    class PROV provider
    class ASYNC,UA,SVC tsrt
    class ID,CO,PR,GA core
    class ST,NE substrate
```

### First Slice — Executable Orchestration Path

The current scaffold-level executable path, consumed by `HealthOSCLI` and `HealthOSScribeApp`:

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f0f9ff', 'primaryBorderColor': '#bae6fd', 'primaryTextColor': '#0c4a6e', 'edgeLabelBackground': '#fafafa', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart LR
    classDef govern   fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef capture  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos      fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef norm     fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef msr      fill:#ede9fe,stroke:#a78bfa,stroke-width:2px,color:#3b0764
    classDef draft    fill:#fdf4ff,stroke:#c084fc,stroke-width:2px,color:#581c87
    classDef gate     fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef final    fill:#d1fae5,stroke:#34d399,stroke-width:2px,color:#065f46
    classDef terminal fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#475569

    HAB[Habilitation\nValidate]:::govern
    CON[Consent\nValidate]:::govern
    SES[Session\nStart]:::capture
    GOS_ACT[GOS Activation\nBundle · Binding Plan]:::gos
    CAP[Capture\nAudio · Text]:::capture
    TRA[Transcription\nready · degraded · unavailable]:::capture
    NORM[Transcript\nNormalization]:::norm
    MSR[MSR Pipeline\nASL · VDLP · GEM]:::msr
    RET[Retrieval\nContext Package]:::capture
    SOAP[SOAP Draft\nCompose]:::draft
    DER[Referral · Prescription\nDerived Drafts]:::draft
    GR[Gate Request]:::gate
    GV[Gate Resolve\napproved · rejected]:::gate
    FIN[Final SOAP\n+ Provenance]:::final
    STOP([withheld]):::terminal

    HAB --> CON --> SES --> GOS_ACT --> CAP --> TRA --> NORM
    NORM --> MSR
    NORM --> RET
    MSR --> SOAP
    RET --> SOAP
    SOAP --> DER --> GR --> GV
    GV -->|approved| FIN
    GV -->|rejected| STOP
```

---

## 📦 Swift Package Graph

All nine targets build from `swift/Package.swift` (Swift tools 6.2, platform `.macOS(.v26)`). External dependencies: none — sovereignty by design.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f8f4ff', 'primaryBorderColor': '#c4b5fd', 'primaryTextColor': '#3b0764', 'clusterBkg': '#fdfbff', 'clusterBorder': '#e9d5ff', 'titleColor': '#0f172a', 'edgeLabelBackground': '#fdf8ff', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
graph LR
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef provider fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef msr      fill:#ede9fe,stroke:#a78bfa,stroke-width:2px,color:#3b0764
    classDef app      fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef cli      fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    CORE[HealthOSCore\nlaw · governance · contracts]:::core
    PROV[HealthOSProviders\nprotocols · FoundationModels · stubs]:::provider
    AACI[HealthOSAACI\nsession · GOS bindings · subagents]:::runtime
    MSR[HealthOSMSR\nASL · VDLP · GEM pipeline]:::msr
    SRT[HealthOSSessionRuntime\norchestration · normalization · bridge]:::runtime

    CLI[HealthOSCLI\nexecutable]:::cli
    SCRIBE[HealthOSScribeApp\nexecutable · SwiftUI · Liquid Glass]:::app
    VERIDIA[HealthOSVeridiaApp\nexecutable · session boundary smoke]:::app
    CLOUDCLINIC[HealthOSCloudClinicApp\nexecutable · scaffold placeholder]:::app

    CORE --> PROV
    CORE --> AACI
    CORE --> MSR
    PROV --> AACI
    PROV --> MSR
    CORE --> SRT
    AACI --> SRT
    PROV --> SRT
    MSR --> SRT
    CORE --> CLI
    SRT --> CLI
    CORE --> SCRIBE
    SRT --> SCRIBE
    CORE --> VERIDIA
    CORE --> CLOUDCLINIC
```

| Target | Kind | Description |
| :--- | :--- | :--- |
| `HealthOSCore` | Library | Core law, governance types, storage contracts, GOS types, MSR runtime types, entity model |
| `HealthOSProviders` | Library | Provider protocol contracts, `AppleFoundationProvider` (FoundationModels), stub providers, model governance |
| `HealthOSAACI` | Library | AACI runtime, GOS bindings, GOS runtime activation/context/resolution |
| `HealthOSMSR` | Library | Mental Space Runtime pipeline — ASL, VDLP, GEM executors, provenance metadata |
| `HealthOSSessionRuntime` | Library | Session orchestration (`SessionRunner`), normalization executor, Scribe bridge adapter |
| `HealthOSCLI` | Executable | Command-line operator interface for session and GOS lifecycle |
| `HealthOSScribeApp` | Executable | Minimal Scribe professional workspace validation surface (SwiftUI, macOS 26+) |
| `HealthOSVeridiaApp` | Executable | Smoke-testable Veridia session boundary, no final UI |
| `HealthOSCloudClinicApp` | Executable | Scaffold placeholder — product-graph representation, no final UI |

---

## 🪟 Native Interface Layer — Liquid Glass Design System

HealthOS native macOS surfaces target macOS 26+ and adopt **Liquid Glass as the design baseline** per `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`.

Standard SwiftUI/AppKit controls and navigation surfaces (sidebars, toolbars, sheets, `NavigationSplitView`) inherit system Liquid Glass behavior automatically. Custom `glassEffect`, `GlassEffectContainer`, and glass button styles are reserved for app-specific HealthOS surfaces not covered by standard controls.

**Current scaffold state:** `HealthOSScribeApp` uses `GroupBox` + `.thinMaterial` with standard SwiftUI controls. `HealthOSDesignSystem` is the implemented design system baseline (DS-001, 2026-05-05). Full Liquid Glass adoption is in progress as the macOS 26+ native app shell matures.

<p align="center">
  <img src="docs/assets/liquidglass_intro.gif" width="100%" alt="Demonstração do Liquid Glass UI — HealthOS Scribe First Slice">
</p>

### UI Component Stack

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'titleColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef runtime fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef bridge  fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef vm      fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef view    fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef design  fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A
    classDef state   fill:#FFF7E8,stroke:#C28A2E,stroke-width:2px,color:#5F4217
    classDef sys     fill:#F2F4F7,stroke:#8793A1,stroke-width:1px,color:#334155

    subgraph RT["Session Runtime"]
        SRT[SessionRunner\norchestration]:::runtime
        BR[ScribeFirstSliceBridge\nmediated app-safe state]:::bridge
    end

    subgraph VM["ViewModel"]
        MVM[ScribeFirstSliceViewModel\nObservable - MainActor]:::vm
    end

    subgraph DS["HealthOSDesignSystem"]
        TOK[Semantic tokens\nsovereign · mediated · ready · degraded · denied]:::design
        STD[Native controls first\nWindowGroup · toolbar · sidebar · sheet]:::sys
        CUS[Custom glass only when needed\nGlassEffectContainer per logical group]:::design
    end

    subgraph SCRIBEAPP["HealthOSScribeApp"]
        APP[WindowGroup\nScribe First Slice]:::view
        ROOT[ScribeFirstSliceView\nScrollView root]:::view
        C1[Surface summary\nstatus capsule + provenance summary]:::state
        C2[Session setup\nstandard controls + semantic state]:::state
        C3[Workspace\ncapture and review surface]:::state
        C4[Slice outputs\nreadable material or glass surface]:::state
        C5[Issues\nbounded degraded-state banner]:::state
        SYSGL[System glass auto-applied\nToolbar - NavigationSplitView - Sheet]:::sys
    end

    SRT --> BR
    BR --> MVM
    TOK --> MVM
    STD --> APP
    CUS --> C1
    CUS --> C2
    CUS --> C3
    CUS --> C4
    CUS --> C5
    MVM --> APP
    APP --> ROOT
    ROOT --> C1
    ROOT --> C2
    ROOT --> C3
    ROOT --> C4
    ROOT --> C5
```

### ScribeFirstSliceView — Session Lifecycle & Glass Surfaces

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
stateDiagram-v2
    [*] --> Idle : app launch · loadIfNeeded()

    Idle --> Opening : startSession()
    Opening --> Active : session opened\nhabilitation + consent valid
    Opening --> Failed : governance deny\nor operational failure

    Active --> Active : submitCapture()\nselectPatient() · requestDraftPreview()
    Active --> Degraded : transcription unavailable\nor retrieval degraded
    Active --> GateReview : gate request raised

    Degraded --> GateReview : gate request raised (degraded path)

    GateReview --> Closed : gate approved → final SOAP + provenance
    GateReview --> Withheld : gate rejected → artifact withheld

    Closed --> [*]
    Withheld --> [*]
    Failed --> [*]

    note right of Active
        Design-system guidance:
        standard controls first;
        custom glass only for grouped
        HealthOS-specific surfaces
    end note

    note right of GateReview
        Gate state uses semantic tint:
        approved, rejected, withheld,
        degraded, pending
    end note
```

### Liquid Glass Adoption Map (macOS 26+)

| Surface | Current (scaffold) | macOS 26+ target |
| :--- | :--- | :--- |
| App window | `WindowGroup` | `WindowGroup` + system auto-glass toolbar |
| Navigation | flat `VStack` | `NavigationSplitView` with auto-glass sidebar |
| Session cards | `GroupBox` | `GlassEffectContainer` (one per logical group) |
| Output blocks | `.thinMaterial` | `glassEffect` modifier |
| Gate panel | plain `HStack` buttons | Glass-prominent approve/reject with semantic tint |
| Degraded banner | `.secondary` text | Tinted glass warning surface |
| Issues list | `ForEach` + `Text` | Grouped in single `GlassEffectContainer` |

> **Rule:** group nearby custom glass elements in one `GlassEffectContainer`. Standard controls and navigation surfaces never need explicit glass modifiers — they adapt automatically on macOS 26+. Keep tint semantic, not decorative.

---

## 📋 Current Repository Posture (May 2026)

This repository is in **controlled implementation / scaffold hardening**:

| Layer | Status | Focus |
| :--- | :--- | :--- |
| **Core Law** | ✅ Implemented Seam | Invariant-based governance, storage contracts |
| **GOS Layer** | ✅ Operational Path | Stabilization, bundle binding, compiler tooling |
| **AACI First Slice** | 🚧 Scaffold Hardening | Boundary enforcement + GOS-mediated derived drafts |
| **MSR Pipeline** | 🚧 Scaffold | ASL · VDLP · GEM stages, provenance metadata |
| **Provider / ML** | ⚠️ Stub / Contract | `AppleFoundationProvider` adapter; deterministic safety posture |
| **Reference Apps / UI** | 🧩 Contract-First | Minimal Scribe validation surface; Veridia boundary scaffold; CloudClinic blocked before new wiring |
| **Liquid Glass UI** | 🎯 macOS 26+ Baseline | HealthOSDesignSystem baseline (DS-001); glass adoption in progress |
| **Construction System** | ✅ Implemented Seam | 10 CLI commands (healthos-steward) + 10 MCP tools (healthos-forge-mcp) |

Read this table as an onboarding summary. The authoritative maturity ladder is `doctrine-only` → `scaffolded contract` → `implemented seam` → `tested operational path` → `production-hardened`, maintained in `docs/execution/11-current-maturity-map.md`.

**This repository is not:**
- a production-ready product
- a complete EHR
- a final UI delivery of any reference app
- a real regulatory-signature or interoperability integration
- a real semantic retrieval stack with embeddings/vector index
- a real external provider deployment (LM/STT/embedding remain scaffold/stub posture)

---

## 🚀 Quick Start

```bash
# Bootstrap all surfaces
make bootstrap

# Build
make swift-build
make ts-build
make python-check

# Test
make swift-test
make ts-test

# Validate contracts and documentation
make validate-schemas
make validate-contracts
make validate-docs
make validate-all
```

**Xcode:** open `HealthOS.xcworkspace` from repository root — resolves `swift/Package.swift`.

**Smoke paths:**

```bash
make smoke-cli
make smoke-scribe
make smoke-veridia
make smoke-cloudclinic
```

**Direct smoke commands:**

```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSCLI --reject-gate
cd swift && swift run HealthOSScribeApp --smoke-test
cd swift && swift run HealthOSScribeApp --smoke-test-audio
cd swift && swift run HealthOSVeridiaApp --smoke-test
cd swift && swift run HealthOSCloudClinicApp --smoke-test
```

**GOS bundle lifecycle:**

```bash
cd swift && swift run HealthOSCLI \
  --gos-review-bundle <bundle-id> \
  --gos-spec-id <spec-id> \
  --reviewer-id <id> \
  --review-rationale "<reason>"

cd swift && swift run HealthOSCLI \
  --gos-promote-bundle <bundle-id> \
  --gos-spec-id <spec-id> \
  --activator-id <id> \
  --activation-rationale "<reason>"
```

`HealthOSVeridiaApp` has a smoke-testable Veridia session boundary. `HealthOSCloudClinicApp` remains a scaffold placeholder executable for product-graph representation. Neither implements final UI, clinical authority, real provider/signature/interoperability behavior, or production readiness.

---

## 🧩 Cross-Language Contract Discipline

HealthOS is not "just a Swift app" or "just a TypeScript workspace". The same doctrine flows through schemas, Swift, TypeScript, SQL, and execution docs. **When ontology or contracts change, align all four surfaces in the same work unit.**

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f8fbff', 'primaryBorderColor': '#cadcf0', 'primaryTextColor': '#17324d', 'clusterBkg': '#ffffff', 'clusterBorder': '#dbeafe', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fbff', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart LR
    classDef source fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef schema fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef swift  fill:#ede9fe,stroke:#8b5cf6,stroke-width:2px,color:#4c1d95
    classDef ts     fill:#fff7ed,stroke:#f59e0b,stroke-width:2px,color:#7c2d12
    classDef sql    fill:#fce7f3,stroke:#ec4899,stroke-width:2px,color:#831843

    C[Canonical doctrine\narchitecture + execution docs]:::source
    J[schemas/\nJSON Schema]:::schema
    SW[swift/\nCore contracts + services + tests]:::swift
    TS[ts/\ncontracts + runtimes + tooling]:::ts
    SQL[sql/migrations/\nmetadata shape]:::sql

    C --> J & SW & TS & SQL
    J <--> SW
    J <--> TS
    SW <--> TS
    SQL -. when relevant .-> SW
    SQL -. when relevant .-> TS
```

---

## ✨ Reading Paths

| If you want to… | Start here | Then go to |
| :--- | :--- | :--- |
| Understand what HealthOS is | `docs/architecture/01-overview.md` | `19-interface-doctrine.md`, `46-apple-sovereignty-architecture.md` |
| Understand the consolidated technical product definition | `docs/product/01-healthos-technical-product-specification.md` | `docs/product/README.md`, `docs/architecture/` and `docs/execution/` sources referenced by the spec |
| Understand the executable slice | `docs/architecture/28-first-slice-executable-path.md` | `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`, `swift/Sources/HealthOSCore/FirstSliceContracts.swift` |
| Understand GOS | `docs/architecture/29-governed-operational-spec.md` | `30-gos-authoring-and-compiler.md` → `33-gos-app-consumption-patterns.md` |
| Understand MSR | `docs/architecture/49-mental-space-runtime.md` | `swift/Sources/HealthOSMSR/`, `swift/Sources/HealthOSCore/MSRRuntime.swift` |
| Understand native UI + Liquid Glass | `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` | `swift/Sources/HealthOSScribeApp/` |
| Understand Apple sovereignty | `docs/architecture/46-apple-sovereignty-architecture.md` | `swift/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift` |
| Understand apps and boundaries | `docs/architecture/11-scribe.md` | `12-veridia.md`, `13-cloudclinic.md`, `43-cross-app-coordination-shared-surfaces.md` |
| Understand maturity and gaps | `docs/execution/11-current-maturity-map.md` | `13-scaffold-release-candidate-criteria.md`, `14-final-gap-register.md` |
| Start coding safely | `docs/execution/README.md` | `01-agent-operating-protocol.md`, `02-status-and-tracking.md`, relevant `todo/*.md` |
| Understand Steward for Xcode | `docs/architecture/45-healthos-xcode-agent.md` | `docs/execution/17-healthos-xcode-agent-migration-plan.md` |
| Understand the construction system | `docs/execution/22-steward-construction-operating-model.md` | `docs/execution/19-settler-model-task-tracker.md`, `.healthos-settler/territories/` |
| Use Steward CLI | `CLAUDE.md` Steward usage section | `ts/agent-infra/healthos-steward/` |
| Use healthos-forge-mcp | `ts/agent-infra/healthos-forge-mcp/` | `docs/execution/22-steward-construction-operating-model.md` |
| See open documentation tasks | `docs/execution/20-documental-todos-work-plan.md` | `docs/execution/prompts/` |
| See latest daily digest | `.healthos-steward/memory/automations/daily-todo-tracker/latest.md` | `docs/execution/02-status-and-tracking.md` |

### Executive Visual Overview

`DOC-README-VISUAL-PRESENTATION-001` produced an editable visual overview deck as an external work-unit deliverable because this checkout does not yet contain a clear versioned `docs/assets/presentations/` pattern. When a repository asset policy exists, the intended durable path is `docs/assets/presentations/healthos-visual-overview.pptx`.

The deck narrative is: HealthOS is a governed platform; Core law stays sovereign; GOS mediates operational structure; runtimes and apps consume mediated contracts; construction tooling stays outside the clinical/runtime hierarchy; maturity and residual gaps remain explicit.

### Visual Reading Map

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'titleColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart TD
    classDef entry   fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A
    classDef arch    fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef exec    fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef code    fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef steward fill:#F5F2F7,stroke:#7B5E8E,stroke-width:2px,color:#3A2946
    classDef ui      fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63

    R[README.md\nEntry Surface]:::entry

    A1[Architecture\n01 overview · 19 doctrine · 46 sovereignty]:::arch
    A2[Execution\nREADME · protocol · status · maturity · gaps]:::exec
    A3[Code Surfaces\nswift · ts · schemas · sql]:::code
    A4[Repository Engineering\nSteward · Settlers · Territories]:::steward
    A5[Claude Code Automations\nupdate · digest · sync]:::steward
    A6[Native UI + Liquid Glass\n48-native-macos-ui · HealthOSDesignSystem · ScribeApp]:::ui

    R --> A1 & A2 & A3 & A4 & A5 & A6

    A1 --> A11[Core law]
    A1 --> A12[GOS]
    A1 --> A13[Apps and interfaces]
    A2 --> A21[What is ready now]
    A2 --> A22[What is blocked]
    A2 --> A23[What to do next]
    A3 --> A31[Executable first slice]
    A3 --> A32[Cross-language contracts]
    A4 --> A41[Steward baseline]
    A4 --> A42[Settler doctrine]
    A6 --> A61[Component contracts]
    A6 --> A62[Semantic tokens + glass adoption path]
```

---

## 🗺️ Repository Atlas

The repository is four synchronized surfaces: doctrine, execution discipline, executable code, and cross-language contracts.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'titleColor': '#1D2733', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph LR
    classDef docs  fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef exec  fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef code  fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef data  fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef agent fill:#F5F2F7,stroke:#7B5E8E,stroke-width:2px,color:#3A2946

    D[docs/architecture\nCanonical doctrine]:::docs
    E[docs/execution\nProtocol · status · TODO · handoff]:::exec
    S[schemas + sql\nContract and metadata shape]:::data
    W[swift/\nCore · AACI · MSR · apps · tests]:::code
    T[ts/\ncontracts · runtimes · tooling · steward]:::code
    DS[HealthOSDesignSystem\npresentation tokens · UI kits · assets]:::code
    P[python/\nOffline ML governance scaffolds]:::code
    EG[.healthos-steward\n.healthos-settler]:::agent
    AU[.claude/automations\nupdate-claude-md · daily-todo · sync-work-plan]:::agent

    D -->|defines boundaries for| W
    D -->|defines boundaries for| T
    D -->|canonical doctrine for| EG
    E -->|governs work order for| W
    E -->|governs work order for| T
    E -->|tracks engineering records for| EG
    S -->|align with| W
    S -->|align with| T
    D -->|bounds presentation claims for| DS
    DS -->|proposes app-safe interface skin for| W
    W -->|first executable slice| T
    P -->|offline-only support posture| W
    EG -. outside clinical/runtime hierarchy .-> D
    AU -->|reads + syncs| E
    AU -->|pushes to| D
```

### Code-to-Doc Orientation

| Surface | Primary docs | Primary code |
| :--- | :--- | :--- |
| Core law | `docs/architecture/06-core-services.md`, `05-data-layers.md`, `07-storage-and-sql.md` | `swift/Sources/HealthOSCore/` |
| AACI + first slice | `docs/architecture/09-aaci.md`, `28-first-slice-executable-path.md` | `swift/Sources/HealthOSAACI/`, `swift/Sources/HealthOSSessionRuntime/` |
| MSR | `docs/architecture/49-mental-space-runtime.md` | `swift/Sources/HealthOSMSR/` |
| GOS | `29-governed-operational-spec.md` → `34-gos-review-and-activation-policy.md` | `ts/packages/healthos-gos-tooling/`, `swift/Sources/HealthOSCore/` |
| App Integration Boundary | `docs/architecture/50-app-layer-boundary-and-reference-apps.md`, `19-interface-doctrine.md` | mediated facades/envelopes in `swift/Sources/HealthOSCore/` and runtime adapters |
| Native UI + Liquid Glass | `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` | `swift/Sources/HealthOSScribeApp/` |
| Reference apps/interfaces | `11-scribe.md`, `12-veridia.md`, `13-cloudclinic.md`, `43-cross-app-coordination-shared-surfaces.md` | `swift/Sources/HealthOSScribeApp/`, `HealthOSVeridiaApp/`, `HealthOSCloudClinicApp/` |
| Providers / ML | `docs/architecture/16-providers-and-ml.md`, `27-provider-threshold-policy.md` | `swift/Sources/HealthOSProviders/` |
| Steward | `45-healthos-xcode-agent.md`, `47-steward-settler-engineering-model.md` | `ts/agent-infra/healthos-steward/`, `.healthos-steward/` |

---

## 📂 Internal Documentation Index

| Module / Folder | README | Focus |
| :--- | :--- | :--- |
| `swift/Sources/HealthOSCore/` | [README](swift/Sources/HealthOSCore/README.md) | Core law contracts, governance types, storage, GOS, MSR runtime types, entity model |
| `swift/Sources/HealthOSScribeApp/` | [README](swift/Sources/HealthOSScribeApp/README.md) | Scribe validation surface, SwiftUI architecture, Liquid Glass adoption path |
| `swift/Sources/HealthOSMSR/` | [README](swift/Sources/HealthOSMSR/README.md) | Mental Space Runtime pipeline — ASL · VDLP · GEM executors, provenance metadata |
| `swift/Sources/HealthOSProviders/` | [README](swift/Sources/HealthOSProviders/README.md) | Provider protocol contracts, Apple FoundationModels adapter, stub providers |
| `docs/architecture/` | [index](docs/architecture/) | 48+ canonical architecture doctrine documents |
| `docs/execution/` | [README](docs/execution/README.md) | Execution protocol, status tracking, TODO tracker, maturity/handoff |
| `ts/` | [README](ts/README.md) | TypeScript workspace: contracts, GOS tooling, async runtime, Steward CLI |
| `.healthos-steward/` | [README](.healthos-steward/README.md) | Steward derived state, session memory, automation logs |
| `ts/agent-infra/healthos-forge-mcp/` | — | Forge MCP stdio server — 10 deterministic repository-maintenance tools wrapping @healthos/steward lib |

---

## 🗂️ Repository Map (current)

- `docs/architecture/` — canonical architecture and doctrine docs (GOS, app-boundary, regulatory, cross-app, native UI)
- `docs/execution/` — governed execution protocol, status tracking, coverage, invariants, TODOs, maturity/handoff
- `schemas/` — JSON Schema entity contracts and GOS schemas
- `swift/` — Core, AACI, Providers, MSR, SessionRuntime, CLI, Scribe app, XCTest suites
- `ts/` — workspace packages (`contracts`, `runtime-async`, `runtime-user-agent`, `healthos-gos-tooling`, `healthos-steward`, `healthos-forge-mcp`)
- `python/` — offline ML governance scaffolds only
- `sql/migrations/001_init.sql` — canonical metadata schema scaffold
- `ops/` and `scripts/` — local operational scaffolding, bootstrap, network and backup notes
- `apps/` — interface boundary scaffolds/documentation
- `.healthos-steward/` — derived Steward state, policies, prompts, session memory
- `.healthos-steward/memory/automations/` — automation run logs and daily TODO digests
- `.healthos-settler/` — Settler profiles (`.healthos-settler/settlers/`) and Territory Registry (`.healthos-settler/territories/`)
- `.claude/automations/` — Claude Code automation definitions
- `.claude/scheduled_tasks.json` — durable cron job registry

---

## Steward, Settlers, and Territories

Steward is the canonical engineering agent for this repository. `healthos-steward` is the CLI, package, and repository-local state root.

- CLI and package: `ts/agent-infra/healthos-steward/`
- Repository-local derived state root: `.healthos-steward/`
- Current persisted runtime state: `.healthos-steward/memory/sessions/`

Settlers are specialized engineering agent profiles. Settlements are bounded engineering work units. Territories are documented repository domains. Canonical model: `docs/architecture/47-steward-settler-engineering-model.md`.

```bash
make ts-build
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd ts && npx --yes --workspace @healthos/steward healthos-steward session
cd ts && npx --yes --workspace @healthos/steward healthos-steward list territories
cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlers
cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlements
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect territory <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect settler <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward inspect settlement <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward next
cd ts && npx --yes --workspace @healthos/steward healthos-steward generate-prompt <settlement-id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward validate-settlement <settlement-id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward pr-draft <settlement-id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward build-memory
```

Ten `healthos-steward` CLI commands are implemented (ST-010 through ST-017). `dist/` is not committed — run `make ts-build` once before invoking.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#fdf2f8', 'primaryBorderColor': '#f9a8d4', 'primaryTextColor': '#831843', 'clusterBkg': '#ffffff', 'clusterBorder': '#e5e7eb', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fafc', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart TD
    classDef steward   fill:#fdf2f8,stroke:#ec4899,stroke-width:2px,color:#831843
    classDef settler   fill:#f5f3ff,stroke:#8b5cf6,stroke-width:2px,color:#4c1d95
    classDef territory fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef docs      fill:#ecfdf5,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef boundary  fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    DOCS[Official docs\ncanonical truth]:::docs
    STEW[Steward\ncoordinator]:::steward
    SETT[Settler profiles\nspecialized instructions]:::settler
    WORK[Settlements\nbounded work records]:::settler
    TERR[Territories\nrepository domains]:::territory
    MCP[healthos-forge-mcp\nrepository maintenance\nimplemented seam\nST-018 · 10 tools]:::boundary

    DOCS --> STEW
    DOCS --> TERR
    STEW -->|frames| WORK
    STEW -->|chooses| SETT
    SETT -->|operates within| TERR
    WORK -->|records scope and validation| DOCS
    MCP -. deterministic repo operations .-> STEW
    MCP -. deterministic repo operations .-> SETT
```

**Steward for Xcode** is the Xcode-integration posture: integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface. See `docs/architecture/45-healthos-xcode-agent.md` for target architecture.

### 🏗️ Construction System Lifecycle

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#fdf2f8', 'primaryBorderColor': '#f9a8d4', 'primaryTextColor': '#831843', 'clusterBkg': '#ffffff', 'clusterBorder': '#e5e7eb', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fafc', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart TD
    classDef steward   fill:#fdf2f8,stroke:#ec4899,stroke-width:2px,color:#831843
    classDef settler   fill:#f5f3ff,stroke:#8b5cf6,stroke-width:2px,color:#4c1d95
    classDef territory fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef docs      fill:#ecfdf5,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef mcp       fill:#fff7ed,stroke:#f59e0b,stroke-width:2px,color:#7c2d12
    classDef mem       fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    DOCS[Official docs\ncanonical truth]:::docs
    STEW[Steward\n10 CLI commands]:::steward
    SETTLER[Settler profiles\n9 profiles · settlers/]:::settler
    TERR[Territory Registry\n15 territories · territories/]:::territory
    SETTLE[Settlements\nbounded work records]:::settler
    MCP[healthos-forge-mcp\nimplemented seam · ST-018\n10 steward_* MCP tools]:::mcp
    MEM[Derived Memory\nmemory/derived/\nnon-canonical snapshots]:::mem

    DOCS --> STEW
    DOCS --> TERR
    STEW -->|selects| SETTLER
    STEW -->|frames| SETTLE
    SETTLER -->|operates within| TERR
    SETTLE -->|records scope and validation| DOCS
    MCP -->|wraps| STEW
    STEW -->|build-memory writes| MEM
    MEM -. non-canonical do not cite .-> DOCS
```

Canonical truth resides in `docs/` and project manifests. Steward memory, Settler scaffolds, Settlement records, and Territory records are derived or instructional engineering surfaces — non-clinical, non-constitutional, and non-authorizing.

---

## 🤖 Claude Code Automations

Three durable automations keep repository state synchronized. All follow **main-first**: pull `origin/main` → read → write → commit → push. Any agent always sees the latest state after a pull.

| Automation | Schedule | Function | Output pushed to `main` |
| :--- | :--- | :--- | :--- |
| `update-claude-md` | Mon 09:03 | Reviews recent git history, Makefile, Steward CLI; updates `CLAUDE.md` with genuinely new commands or patterns | `CLAUDE.md` + memory log |
| `daily-todo-tracker` | Daily 08:07 | Scans all `todo/*.md`, trackers, gap register; writes structured daily digest | `.healthos-steward/memory/automations/daily-todo-tracker/YYYY-MM-DD.md` + `latest.md` |
| `sync-work-plan` | Mon/Wed/Fri 08:47 | Builds truth table for every open documental task; marks completed, unblocks dependencies | `docs/execution/20-documental-todos-work-plan.md` + memory log |

Definitions: `.claude/automations/` · Registry: `.claude/scheduled_tasks.json`

To run any automation immediately: ask Claude Code directly (e.g. *"run the daily-todo-tracker now"*).

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f0fdf4', 'primaryBorderColor': '#86efac', 'primaryTextColor': '#14532d', 'clusterBkg': '#fafafa', 'clusterBorder': '#e2e8f0', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fafc', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart LR
    classDef trigger fill:#f0fdf4,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef git     fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#1e3a8a
    classDef read    fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef write   fill:#ede9fe,stroke:#8b5cf6,stroke-width:2px,color:#4c1d95
    classDef mem     fill:#fce7f3,stroke:#ec4899,stroke-width:2px,color:#831843

    CRON[Cron trigger\nor manual request]:::trigger
    STASH[stash + checkout main\ngit pull origin main]:::git
    READ[read sources\ndocs · todo · trackers · gaps · git log]:::read
    WRITE[write output\ndoc update or digest]:::write
    COMMIT[git add + commit\ngit push origin main]:::git
    RESTORE[restore branch\ngit stash pop]:::git
    MEM[.healthos-steward/memory/\nautomations/]:::mem

    CRON --> STASH --> READ --> WRITE --> COMMIT --> RESTORE
    WRITE --> MEM
    MEM --> COMMIT
```

### Documental Work Plan

`docs/execution/20-documental-todos-work-plan.md` is the living plan for all open documentation tasks. Kept synchronized by the `sync-work-plan` automation.

Phase execution prompts in `docs/execution/prompts/`:

| Prompt file | Phase | Tasks |
| :--- | :--- | :--- |
| `phase-1-settler-territory.md` | Phase 1 | ST-006 Territory records · ST-002 Settler profiles · ST-003 Settlement schema |
| `phase-2-architecture-proposals.md` | Phase 2 | CL-006 Error envelope · OPS-003 Incident command set · ST-004 healthos-forge-mcp spec |
| `phase-3-xcode-agent-streams.md` | Phase 3 | Stream C tool contracts · Stream D backend contract · Stream F Xcode envelope |

---

## 🧠 Where Agents Should Start

Read in order before coding:

1. `README.md` (this file)
2. `docs/execution/README.md`
3. `docs/execution/00-master-plan.md`
4. `docs/execution/01-agent-operating-protocol.md`
5. `docs/execution/02-status-and-tracking.md`
6. `docs/execution/06-scaffold-coverage-matrix.md`
7. `docs/execution/10-invariant-matrix.md`
8. `docs/execution/11-current-maturity-map.md`
9. `docs/execution/12-next-agent-handoff.md`
10. `docs/execution/13-scaffold-release-candidate-criteria.md`
11. `docs/execution/14-final-gap-register.md`
12. `docs/execution/15-scaffold-finalization-plan.md`
13. `docs/execution/16-next-10-actions-plan.md`
14. `docs/execution/22-steward-construction-operating-model.md` — construction system operating model
15. `docs/execution/19-settler-model-task-tracker.md` — ST task sequence and status
16. relevant `docs/execution/todo/*.md`
17. matching `docs/execution/skills/*.md`
18. if touching Swift/SwiftUI/Xcode: `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` and matching `docs/execution/skills/<name>/SKILL.md`

---

## Canonical Hierarchy

```text
Material substrate
  └─ host, storage, private network/mesh, backups
     (APFS + FileVault + Secure Enclave key custody)
HealthOS Core
  └─ law/governance (identity, consent, habilitation, storage, provenance, gate, audit)
Governed Operational Spec (GOS)
  └─ operational translation layer subordinate to Core
HealthOS Runtimes
  ├─ AACI runtime (session · first slice · subagents)
  ├─ Async runtime (jobs · retry · backpressure)
  ├─ MSR runtime (ASL · VDLP · GEM pipeline)
  └─ User-Agent runtime (patient-facing interactions)
Actors / Agents
  └─ bounded actors and role-governed agents
App Integration Boundary
  └─ facades, envelopes, app-safe views, safe refs, command/result envelopes
Reference App Layer  (macOS 26+ · Liquid Glass design baseline)
  ├─ initial examples: Scribe (professional workspace)
  ├─ initial examples: Veridia (patient health identity)
  ├─ initial examples: CloudClinic (service operations)
  └─ future apps in arbitrary number
Artifacts / Effects
  └─ drafts, gate records, final artifacts, provenance/audit traces
```

## Maturity Snapshot by Layer

Full detail: `docs/execution/11-current-maturity-map.md`.

- **Core law + storage governance:** implemented seam / tested operational path (local scaffold)
- **GOS authoring/compiler/lifecycle:** implemented seam / tested operational path (scaffold hardening)
- **AACI + first slice orchestration:** implemented seam / tested operational path (bounded scope)
- **MSR pipeline:** scaffold — executors present, provenance metadata defined, provider integration pending
- **Liquid Glass UI:** design baseline established; HealthOSDesignSystem implemented (DS-001)
- **Construction system (Steward + Forge MCP):** implemented seam — 10 CLI commands + 10 MCP tools deterministic; no LLM, no merge authority, no clinical scope

## Scaffold/Foundation Phase Closure References

- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`
- `docs/execution/16-next-10-actions-plan.md`
