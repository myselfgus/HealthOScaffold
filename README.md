<p align="center">
  <img src="HealthOS/Shared/docs/assets/healthos-logo.png" width="320" alt="HealthOS">
</p>
<p align="center">
  <img src="https://img.shields.io/badge/macOS-26%2B-000000?style=flat&logo=apple&logoColor=white" alt="macOS 26+">
  <img src="https://img.shields.io/badge/Node.js-LTS%2020%2B-339933?style=flat&logo=nodedotjs&logoColor=white" alt="Node.js LTS 20+">
  <img src="https://img.shields.io/badge/UI-Liquid%20Glass-8B5CF6?style=flat" alt="Liquid Glass">
  <img src="https://img.shields.io/badge/AI-Apple%20FoundationModels-000000?style=flat&logo=apple&logoColor=white" alt="Apple FoundationModels">
  <img src="https://img.shields.io/badge/Status-Scaffold%20%E2%80%94%20Foundation%20Phase-6B7280?style=flat" alt="Status: Scaffold — Foundation Phase">
</p>

# HealthOS

> **A juridical execution environment for health applications.**  
> Third-party applications run *inside* HealthOS — governed, isolated, and legally abstracted by Core Law before any instruction may persist or propagate.

HealthOS is not an EHR skin, not a compliance API wrapper, and not a generic health-data cloud. It is a **Juridical Application Engine (JAE)** — a new infrastructure category: a Health Compliance Platform as a Service (HC-PaaS) in which companies host and run their own health applications under full juridical isolation and deterministic governance. HealthOS executes application code within Core Law constraints. Health compliance is not a post-development checklist layered on top — it is the ground on which every instruction executes.

The platform does not compete with health applications; it becomes the substrate they run on.

**What the architecture provides to governed applications (Stages):**

| Capability | How HealthOS delivers it |
| :--- | :--- |
| Juridical isolation | Deterministic separation between application logic and legal/compliance enforcement via Core Law |
| Execution under Core Law | Consent, habilitation, finality, provenance, gate, and audit govern every clinical act |
| Compliance abstraction | Stages define capabilities and prohibitions via Custom; HealthOS enforces them — no compliance code in the app |
| Infrastructure and security abstraction | APFS, FileVault, Secure Enclave, and private mesh beneath every runtime |
| Unified presentation contract | Design System (macOS 26+, Liquid Glass) available to all governed Stage applications if desired |

---

**Repository and maturity:** HealthOScaffold is the historical name for the scaffold/foundation phase. All architecture, contracts, runtimes, apps, tests, and documentation in this repository are HealthOS work. "Scaffold" describes maturity, not product identity. This repository is **not production-ready, not a complete EHR, and not a final UI delivery.** It establishes foundational architecture with executable first-slice orchestration, cross-language contracts (Swift / TypeScript / JSON Schema / SQL), and macOS 26+ native app surfaces targeting Liquid Glass as the design baseline.

**Platform tier summary:** Tier 1 — Mestral Core is constitutional law. Tier 2 — GOS / Runtimes executes and mediates under Core, including the `HealthOSProviders` runtime-adapter module (with `HealthOS/Support` as its direct foundation). Tier 3 — Custom Boundary is the HealthOS-owned consumption frontier and governed Stage-definition boundary. Tier 4 — Stages Cast (Scribe, Veridia, CloudClinic) are governed application consumers whose sole contact point is Boundary. Constructor / Construction System stays outside the clinical/runtime hierarchy. Support is shared ops, Python, provider-support, and ML tooling, governed by Core.

---

## Requirements

| Tool | Version | Purpose |
| :--- | :--- | :--- |
| Swift / SwiftPM | 6.2+ | Platform package (Tiers 1–3), Stage packages, `HealthOSCLI` |
| macOS | 26+ | Required build and runtime platform; Liquid Glass surfaces require macOS 26+ |
| Xcode | 26+ | Open `HealthOS.xcworkspace` for shared schemes, test plans, and Swift previews |
| Node.js | LTS (20+) | TypeScript workspace (`HealthOS/Constructor/ts/`) |
| pnpm | 9+ | Workspace package manager — required for `Constructor/ts` |
| Python | 3.11+ | Support ML and governance scaffolds (`HealthOS/Support/python/`) — optional |

> **External framework dependencies: none.** The Swift platform package is sovereignty-by-design. TypeScript tooling uses no proprietary cloud SDKs. Provider adapters (`HealthOSProviders`, `HealthOS/Support/ML/`) interact only with local Apple on-device models.

---

## How to Read This Repository

Use this README as an entry surface, not as a replacement for the canonical architecture and execution docs. The repository mixes tested operational paths, implemented seams, scaffolded contracts, placeholders, and future gaps; read every claim through that maturity lens.

| Reader question | Current answer | Canonical follow-up |
| :--- | :--- | :--- |
| What is HealthOS? | The whole governed, app-agnostic platform for health operations, not one app or an EHR skin. | `HealthOS/Shared/docs/architecture/01-overview.md` |
| What proves executable behavior today? | The Swift first-slice path through habilitation, consent, capture, retrieval, SOAP draft, gate, final SOAP, and provenance. | `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md` |
| How does HealthOS govern AI agents? | Core Governance Agents enforce constitutional law; Personal Agents (patient, professional) operate under mandate; Boundary projects envelopes to app-safe surfaces; no model is ever the agent's authority. | `HealthOS/Shared/docs/architecture/52-governed-ai-agent-society.md` |
| What is still scaffolded or placeholder? | Provider deployment, semantic retrieval, final app shells, regulatory/signature/interoperability effectuation, and production ops. | `HealthOS/Shared/docs/execution/11-current-maturity-map.md` |
| Where does construction tooling sit? | Steward, Settlers, Settlements, Territories, and `healthos-forge-mcp` are repository engineering surfaces outside the clinical/runtime hierarchy. | `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` |

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart LR
    classDef core fill:#F0F6F3,stroke:#3E8E6F,stroke-width:2px,color:#174234
    classDef runtime fill:#EEF7F8,stroke:#0E7C86,stroke-width:2px,color:#164E63
    classDef interface fill:#F4F2F8,stroke:#3B4A6B,stroke-width:2px,color:#202A3A
    classDef design fill:#F6F8FB,stroke:#5B6B7C,stroke-width:2px,color:#2F3C4A
    classDef construction fill:#FAF7F4,stroke:#A1693A,stroke-width:2px,color:#553018
    classDef support fill:#FFF7E8,stroke:#C28A2E,stroke-width:2px,color:#5F4217
    classDef boundary fill:#F2F4F7,stroke:#8793A1,stroke-width:2px,color:#334155

    subgraph PLATFORM["HealthOS platform"]
        subgraph CLINICAL["Clinical/runtime environment: Tiers 1-3"]
            CORE[Tier 1 — Mestral Core\nHealthOS/Tier1-Mestral-Core\nconsent · habilitation · storage law\ngate · finality · provenance · audit]:::core
            GOS[Tier 2 — GOS / Runtimes\nGOS · Session Runtime · AACI · MSR\nAsync · User-Agent · Service\nHealthOSProviders runtime adapters]:::runtime
            AIB[Tier 3 — Custom Boundary\nHealthOS/Tier3-Custom-Boundary\nfacades · envelopes · safe refs\nCustom · mediated/degraded state]:::interface
            ART[Artifacts/effects\ndrafts · derived artifacts · gated final documents]:::core
            CORE --> GOS --> AIB
            CORE -. governs Custom and Boundary policy .-> AIB
            AIB --> ART
        end

        subgraph STAGES["Stage universe: Tier 4 — Stages Cast"]
            APP[HealthOS/Tier4-Stages-Cast\nScribe · Veridia · CloudClinic\nfuture governed consumers]:::interface
            DS[HealthOS/Shared/DesignSystem\nmacOS 26+ presentation contract\nSF Pro · semantic tint · Liquid Glass]:::design
        end

        SUPPORT[HealthOS/Support\nops · python · provider-support tooling · ML scaffolds\nCreate ML · Core ML · MLX\nnot a runtime import target]:::support

        AIB -->|only mediated Stage contact| APP
        APP --> DS
        CORE -. governs Support policy .-> SUPPORT
        SUPPORT -. used by Core · runtimes · Stages · Constructor .-> CORE
        SUPPORT -. tooling and governed ML support for provider work .-> GOS
        SUPPORT -. governed assets and tooling .-> APP
    end

    subgraph BUILD["Constructor / Construction System: external repository-maintenance layer"]
        CONROOT[HealthOS/Constructor\nvisible construction root]:::construction
        STEW[Steward\ncoordination · derived memory]:::construction
        SETT[Settlers\nspecialized engineering profiles]:::construction
        TERR[Territories\nrepository domains]:::construction
        WORK[Settlements\nbounded work units]:::construction
        MCP[healthos-forge-mcp\nrepo-maintenance MCP tools]:::construction
        CONROOT --> STEW
        CONROOT --> SETT
        CONROOT --> TERR
        STEW --> SETT
        SETT --> TERR
        STEW --> WORK
        MCP -. deterministic repository operations .-> STEW
    end

    BUILD -. outside clinical/runtime hierarchy .-> PLATFORM
    SUPPORT -. available to Constructor tooling under Core governance .-> CONROOT
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

HealthOS is a governance-first platform. Every clinical act flows through a strictly layered, consent- and provenance-governed fabric. Stages consume only mediated surfaces through Boundary — they never become law engines.

The clinical/runtime environment is composed by Tiers 1-3 plus the Stage universe that consumes it. Tier 4 Stages are still HealthOS clinical/application surfaces, but they are intentionally displayed and governed as a separate consumer universe: their contact point is Tier 3 Custom Boundary, not direct Core/GOS/runtime ownership.

Stage work advances only after the mediated surface the Stage consumes is implemented and stable, not merely contracted, and after the relevant Custom is complete. See `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md` for the Boundary, Stage, Custom, and task-ordering doctrine.

`HealthOSProviders` remains the Swift runtime provider-adapter target under Tier 2. `HealthOS/Support/` contains shared provider-support tooling, ops, Python, and governed ML scaffolds; it may support Core, runtimes, Stages, and Constructor workflows, but its usage remains governed by Core law and ModelGovernance.
Apple-native frameworks are HealthOS-governed substrate capabilities, not direct Stage authority or Core Law. See `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md` for SwiftData, CloudKit, FoundationModels, Core ML, NaturalLanguage, RegexBuilder, CryptoKit, AppleArchive, XPC, ServiceManagement, Network, Virtualization, FSKit, and Xcode Cloud posture.

`HealthOS/Constructor/` is the visible Construction System root. Steward, Settlers, Settlements, Territories, and `healthos-forge-mcp` are repository engineering concepts **outside** this clinical/runtime hierarchy. They inspect, edit, validate, and record repository work. They do not become HealthOS law, runtime automation, or clinical effectuation.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F8FAFC', 'primaryBorderColor': '#CBD5E1', 'primaryTextColor': '#0F172A', 'clusterBkg': '#FAFBFC', 'clusterBorder': '#CBD5E1', 'titleColor': '#0F172A', 'lineColor': '#6B7C93', 'edgeLabelBackground': '#FFFFFF', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TB
    classDef core     fill:#DCFCE7,stroke:#15803D,stroke-width:2.5px,color:#14532D
    classDef gos      fill:#DBEAFE,stroke:#1D4ED8,stroke-width:2px,color:#1E3A8A
    classDef runtime  fill:#E0F2FE,stroke:#0284C7,stroke-width:1.5px,color:#0C4A6E
    classDef provider fill:#FEF9C3,stroke:#B45309,stroke-width:1.5px,color:#78350F
    classDef boundary fill:#F3E8FF,stroke:#7C3AED,stroke-width:2.5px,color:#3B0764
    classDef stage    fill:#FCE7F3,stroke:#9D174D,stroke-width:2px,color:#831843
    classDef design   fill:#F1F5F9,stroke:#94A3B8,stroke-width:1px,color:#475569
    classDef support  fill:#FFF7ED,stroke:#C2410C,stroke-width:1px,color:#9A3412
    classDef sub      fill:#F8FAFC,stroke:#CBD5E1,stroke-width:1px,color:#64748B
    classDef build    fill:#FDF2F8,stroke:#DB2777,stroke-width:1.5px,color:#9D174D

    subgraph T1["  Tier 1 — Mestral Core · Constitutional Law  "]
        direction LR
        ID["Identity · Habilitation\nconsent-governed identity claims\nhabilitation check before every session"]:::core
        CO["Consent · Finalidade\npatient-facing purpose claims\nfail-closed consent gate"]:::core
        PR["Provenance · Audit\nimmutable trail for all clinical acts\nappend-only provenance model"]:::core
        GA["Gate · Finalization\ngoverned gate before artifact effectuation\napproved → final · rejected → withheld"]:::core
    end

    subgraph T2A["  Tier 2 — GOS + Session Orchestration  "]
        direction LR
        GOS_N["HealthOSGOS\nBundle lifecycle · binding plan · AACI binding\nTypeScript compiler + validator + Swift runtime"]:::gos
        SR_N["HealthOSSessionRuntime\nSessionRunner (Swift actor) · first-slice orchestrator\ntranscript normalization executor · Scribe bridge"]:::gos
    end

    subgraph T2B["  Tier 2 — Clinical Runtimes  "]
        direction LR
        AACI_N["HealthOSAACI\nCapture · transcription (ready / degraded / unavailable)\nDraft composition · GOS binding consumption"]:::runtime
        MSR_N["HealthOSMSR · Mental Space Runtime\nASL (lexical normalization) · VDLP (semantic structuring)\nGEM (enrichment) · provenance metadata per stage"]:::runtime
        PROV_N["HealthOSProviders\nAppleFoundationModels adapter · ProviderRouter\nstub providers · capability profiles · ModelGovernance"]:::provider
    end

    subgraph T2C["  Tier 2 — Scaffold Stubs (Swift + TS reference)  "]
        direction LR
        AS_N["HealthOSAsyncRuntime\nDurable job queue · idempotency keys\ndead-lettering · retry lifecycle"]:::runtime
        UA_N["HealthOSUserAgentRuntime\nPatient-governed query lifecycle\nProhibited-capability enforcement"]:::runtime
        SV_N["HealthOSServiceRuntime\nService operations session lifecycle\nLegalAuthorizing context guard"]:::runtime
    end

    subgraph T3["  Tier 3 — Custom Boundary · HealthOS-Owned Consumption Frontier  "]
        direction LR
        CS_N["CustomSDK\nStage-definition SDK · Custom manifests\nCapabilities · prohibitions · degradation policy\nvalidation requirements · compliance checks"]:::boundary
        BN_N["HealthOSBoundary\nFacades · safe refs · envelopes\nMediated state · degraded state\nCommands · results · consumable surfaces"]:::boundary
    end

    subgraph T4["  Tier 4 — Stages Cast · Separate Governed Consumer Universe  "]
        direction LR
        SC_N["Scribe\nProfessional clinical workspace · macOS 26+\nSwiftUI · Liquid Glass baseline\nimplemented seam"]:::stage
        VD_N["Veridia\nPatient health identity · macOS 26+\napp-safe patient identity surface\nscaffolded contract"]:::stage
        CC_N["CloudClinic\nService operations · macOS 26+\nscaffold — Custom incomplete\nBLOCKED — APP-012"]:::stage
    end

    subgraph BUILD["  Constructor / Construction System · External Repository-Maintenance Layer  "]
        direction LR
        STEW_N["Steward\ncoordinator · 10 CLI commands (ST-010–ST-017)\nderived memory · session state"]:::build
        SETT_N["Settler profiles\n9 specialized engineering profiles\noperates within Territory scope"]:::build
        TERR_N["Territory Registry\n15 JSON-defined repository domains\nscope · boundaries · maturity"]:::build
        WORK_N["Settlements\nbounded work records · done criteria\nscope · validation · evidence"]:::build
        FMCP_N["healthos-forge-mcp\n10 steward_* MCP tools · ST-018\nstdio + Streamable HTTP"]:::build
        MA_N["Managed Agent seam\nST-022 · Anthropic Managed Agents API\ndiscover · brief · validate · handoff\nhuman-triggered only"]:::build
    end

    DS_N["HealthOS/Shared/DesignSystem\nmacOS 26+ · SF Pro · semantic tint · Liquid Glass\npresentation contract — never constitutional law"]:::design
    SP_N["HealthOS/Support\nops · python · ML scaffolds · Create ML · Core ML · MLX\nnot a runtime import target · governed by Core law"]:::support
    SB_N["Material Substrate\nAPFS · FileVault · Secure Enclave\nprivate mesh · encrypted backups"]:::sub

    T1 -->|"governs"| T2A
    T1 -->|"governs"| T2B
    T1 -->|"governs"| T2C
    GOS_N -->|"runtime binding"| SR_N
    SR_N --> AACI_N
    SR_N --> MSR_N
    AACI_N --> PROV_N
    MSR_N --> PROV_N
    T2A & T2B & T2C -->|"contracts and mediated state"| T3
    T3 -->|"mediated surfaces only — no direct Tier 1/2 access"| T4
    DS_N -.->|"presentation guidance"| T4
    T1 -.->|"governs"| SP_N
    SP_N -.->|"direct foundation · provider-support tooling under ModelGovernance"| PROV_N
    T1 --> SB_N
    T2A --> SB_N
    T2B --> SB_N
    STEW_N -->|"selects"| SETT_N
    STEW_N -->|"frames"| WORK_N
    SETT_N -->|"operates within"| TERR_N
    FMCP_N -. "wraps" .-> STEW_N
    MA_N -. "human-triggered sessions" .-> STEW_N
    T1 -.->|"canonical docs are truth for"| BUILD
    BUILD -. "inspects · validates · proposes PRs\nnever clinical authority · never merge authority" .-> T3
    SP_N -. "governed tooling available to Constructor" .-> BUILD
```

### First Slice — Executable Orchestration Path

The current scaffold-level executable path, consumed by `HealthOSCLI` and `Scribe`:

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

### Governed AI Agent Society

HealthOS implements a **Governed AI Agent Society** — a structured hierarchy of AI agents that operate strictly under Core Law. An agent is a governed entity with a stable `AgentID`, a declared `AgentMandate`, constrained memory scope, explicit tool grants, and a provider-routing policy. An AI model (Apple FoundationModels, Core ML, or a future approved provider) is only the execution engine for an inference step — the agent's authority and clinical permissions are determined by Core Law governance, never by the model itself.

Core Governance Agents (Tier 1) enforce constitutional law: consent, habilitation, gate, finality, custody, and provenance. Runtime Agents (Tier 2) orchestrate operational mediation. Personal Agents represent patient and professional principals through the User-Agent Runtime (Tier 2). The Boundary (Tier 3) projects negotiation envelopes to app-safe protocol surfaces (`healthos-aacp`, `a2a`, `acp`). Stages (Tier 4) consume only projected envelopes — never raw agent state, internal memory, direct identifiers, or key material.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F8FAFC', 'primaryBorderColor': '#CBD5E1', 'primaryTextColor': '#0F172A', 'clusterBkg': '#FAFBFC', 'clusterBorder': '#CBD5E1', 'lineColor': '#6B7C93', 'edgeLabelBackground': '#FFFFFF', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TB
    classDef law      fill:#DCFCE7,stroke:#15803D,stroke-width:3px,color:#14532D
    classDef cgov     fill:#D1FAE5,stroke:#059669,stroke-width:2px,color:#064E3B
    classDef runtime  fill:#DBEAFE,stroke:#1D4ED8,stroke-width:1.5px,color:#1E3A8A
    classDef personal fill:#FEF9C3,stroke:#B45309,stroke-width:2.5px,color:#78350F
    classDef boundary fill:#F3E8FF,stroke:#7C3AED,stroke-width:2px,color:#3B0764
    classDef stage    fill:#FCE7F3,stroke:#9D174D,stroke-width:1.5px,color:#831843
    classDef provider fill:#ECFDF5,stroke:#10B981,stroke-width:1.5px,color:#064E3B

    CL["Core Law\nconsent · habilitation · gate · finality\nprovenance · audit · storage law"]:::law

    subgraph CGOV_GRP["  Core Governance Agents — Tier 1 · Constitutional enforcement  "]
        direction LR
        CGA1["ConsentGovernanceAgent"]:::cgov
        CGA2["HabilitationGovernanceAgent"]:::cgov
        CGA3["GateFinalityAgent"]:::cgov
        CGA4["CustodyAccessAgent"]:::cgov
        CGA5["AuditProvenanceAgent"]:::cgov
    end

    subgraph RUNTIME_GRP["  Runtime Agents — Tier 2 · Operational mediation  "]
        direction LR
        RA1["SessionAgent"]:::runtime
        RA2["AACIAgent"]:::runtime
        RA3["MSRAgent"]:::runtime
        RA4["AsyncJobAgent"]:::runtime
        RA5["ProviderRouterAgent\nroutes to approved models only"]:::runtime
    end

    subgraph PERSONAL_GRP["  Personal Agents — Tier 2 · User-Agent Runtime · Principal representation  "]
        direction LR
        PA1["PatientPersonalAgent\njuridical-digital patient representative\neducate · consent · ephemeral access · sovereignty"]:::personal
        PA2["ProfessionalPersonalAgent\nprofessional context agent\nrequest mediated access · track consent"]:::personal
    end

    APB["AgentProtocolBoundary — Tier 3\nproject(envelope:) → healthos-aacp · a2a · acp\nfail-closed · no raw IDs · no internal memory · no key material"]:::boundary

    subgraph STAGES_GRP["  Stages — Tier 4 · Projected envelope consumption only  "]
        direction LR
        VD["Veridia\npatient-facing surface"]:::stage
        SC["Scribe\nprofessional workspace"]:::stage
    end

    PROV["HealthOSProviders\nApple FoundationModels · Core ML\nlocal-first · external denied by default\nmodel is not agent identity or authority"]:::provider

    CL -->|"governs"| CGOV_GRP
    CL -->|"governs"| RUNTIME_GRP
    CL -->|"governs"| PERSONAL_GRP
    CGOV_GRP -->|"constitutional enforcement"| PERSONAL_GRP
    CGOV_GRP -->|"constitutional enforcement"| RUNTIME_GRP
    PERSONAL_GRP -->|"negotiation envelope\nGovernedAIAgentValidator"| APB
    RUNTIME_GRP -->|"operational envelope"| APB
    APB -->|"app-safe projected envelope only"| STAGES_GRP
    RA5 --> PROV
    PA1 & PA2 -.->|"provider routing\nwhen policy allows"| RA5
```

#### Patient Agent — Data Sovereignty and Health Education

`PatientPersonalAgent` is the patient's juridical-digital representative inside HealthOS — an AI agent that advocates on behalf of the patient through governed, mandate-scoped interactions under Core Law. It can educate patients about their health data, surface own-data derived summaries, negotiate consent decisions asynchronously (including while offline), and grant time-bounded ephemeral access to professionals. Its memory never holds raw PHI; its envelopes never carry direct identifiers or reidentification maps; it cannot autonomously finalize any clinical act — a human gate is always required for finality.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#FFFBEB', 'primaryBorderColor': '#F59E0B', 'primaryTextColor': '#78350F', 'clusterBkg': '#FFFDF7', 'clusterBorder': '#FDE68A', 'lineColor': '#92400E', 'edgeLabelBackground': '#FFFBEB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart LR
    classDef patient  fill:#FEF9C3,stroke:#B45309,stroke-width:2.5px,color:#78350F
    classDef allowed  fill:#DCFCE7,stroke:#15803D,stroke-width:2px,color:#14532D
    classDef denied   fill:#FEE2E2,stroke:#DC2626,stroke-width:2px,color:#7F1D1D
    classDef core     fill:#DBEAFE,stroke:#1D4ED8,stroke-width:2px,color:#1E3A8A
    classDef boundary fill:#F3E8FF,stroke:#7C3AED,stroke-width:1.5px,color:#3B0764
    classDef stage    fill:#FCE7F3,stroke:#9D174D,stroke-width:1.5px,color:#831843
    classDef rule     fill:#F1F5F9,stroke:#94A3B8,stroke-width:1px,color:#334155

    CORE["Core Law\nconsent · habilitation\ngate · provenance · audit"]:::core

    PA["PatientPersonalAgent\nPatient juridical-digital representative\nApple FoundationModels local-first\nmemory: derived preferences only · no raw PHI"]:::patient

    subgraph CAPS["  Permitted — AgentMandate  "]
        direction TB
        C1["educate\nhealth education and learning"]:::allowed
        C2["summarizeOwnData\nown derived data — never raw PHI"]:::allowed
        C3["requestConsent / respondConsent\nasync and offline consent decisions"]:::allowed
        C4["grantEphemeralAccess\ntime-bounded access to professional"]:::allowed
        C5["emergencyAccessRequest\nemergency scenario initiation"]:::allowed
    end

    subgraph DENY["  Denied — Core Law Invariants  "]
        direction TB
        D1["autonomous diagnosis\nprescription or referral"]:::denied
        D2["record finalization or signature\nwithout human gate"]:::denied
        D3["raw PHI in agent memory\nor internal memory exposed to protocol"]:::denied
        D4["direct identifiers\nor reidentification maps in envelopes"]:::denied
    end

    subgraph SOV["  Data Sovereignty Invariants  "]
        direction TB
        S1["mayPersistRawPHI: false"]:::rule
        S2["mayExposeInternalMemoryToProtocol: false"]:::rule
        S3["allowDirectIdentifierFlowExplicit: false"]:::rule
        S4["allowAutonomousClinicalOrRegulatoryFinality: false"]:::rule
        S5["requiresHumanGateForFinality: true"]:::rule
        S6["allowsAsyncOfflineResponse: true\nresponses queued with provenance"]:::rule
    end

    APB["AgentProtocolBoundary\nhealthos-aacp · a2a\nfail-closed app-safe projection"]:::boundary
    VD["Veridia\npatient health identity Stage\nenvelope consumption only"]:::stage

    CORE -->|"mandate and\nmemory scope"| PA
    PA --> CAPS
    PA -.->|"blocked by\nCore Law"| DENY
    PA --> SOV
    PA -->|"negotiation envelope"| APB
    APB -->|"app-safe projection"| VD
```

#### Agent Negotiation Envelope — Governance Validation Pipeline

Every Personal Agent interaction passes through `GovernedAIAgentValidator` before execution. The validator is fail-closed: any failed check produces a `GovernedAIAgentFailure`, and the interaction is withheld and logged. No partial execution occurs.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F8FAFC', 'primaryBorderColor': '#CBD5E1', 'primaryTextColor': '#0F172A', 'edgeLabelBackground': '#FFFFFF', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
flowchart TD
    classDef input fill:#FEF9C3,stroke:#B45309,stroke-width:2px,color:#78350F
    classDef check fill:#DBEAFE,stroke:#1D4ED8,stroke-width:1.5px,color:#1E3A8A
    classDef pass  fill:#DCFCE7,stroke:#15803D,stroke-width:2.5px,color:#14532D
    classDef fail  fill:#FEE2E2,stroke:#DC2626,stroke-width:2.5px,color:#7F1D1D

    ENV["AgentNegotiationEnvelope\nfrom PersonalAgent"]:::input

    V1{"Valid AgentID\nand principal ref?"}:::check
    V2{"Intent within\nmandate scope?"}:::check
    V3{"No autonomous clinical\nor regulatory finality?"}:::check
    V4{"Lawful context\npresent?"}:::check
    V5{"Data layers within\nallowed set?"}:::check
    V6{"No direct identifiers\nor reidentification maps?"}:::check
    V7{"No raw storage paths\nor key material?"}:::check
    V8{"No internal memory\nexposed to protocol?"}:::check
    V9{"Provider policy\ncompliant?"}:::check

    PASS["GovernedAIAgentValidator · PASS\nPersonalAgentRuntime.handle()"]:::pass
    FAIL["GovernedAIAgentFailure\nfail-closed · logged · withheld"]:::fail

    ENV --> V1
    V1 -->|yes| V2
    V1 -->|no| FAIL
    V2 -->|yes| V3
    V2 -->|no| FAIL
    V3 -->|yes| V4
    V3 -->|no| FAIL
    V4 -->|yes| V5
    V4 -->|no| FAIL
    V5 -->|yes| V6
    V5 -->|no| FAIL
    V6 -->|yes| V7
    V6 -->|no| FAIL
    V7 -->|yes| V8
    V7 -->|no| FAIL
    V8 -->|yes| V9
    V8 -->|no| FAIL
    V9 -->|yes| PASS
    V9 -->|no| FAIL
```

**Canonical references:** `HealthOS/Shared/docs/architecture/52-governed-ai-agent-society.md` · `HealthOS/Shared/docs/adr/0014-governed-ai-agent-society.md` · `GovernedAIAgentContracts.swift` · `UserAgentRuntime.swift` · `AgentProtocolBoundary.swift`

---

## 📦 Swift Package Graph

The public platform Swift products build from `HealthOS/Package.swift` (Swift tools 6.2, platform `.macOS(.v26)`). This central package owns Tiers 1-3, `CustomSDK`, `HealthOSCLI`, and structural test targets for Construction System, Support, Stage package separation, and shared governance suites. Tier 4 Stages are separate Swift packages under `HealthOS/Tier4-Stages-Cast/<Stage>/Package.swift`; they consume the platform only through `HealthOSBoundary` and `CustomSDK`. External dependencies: none — sovereignty by design.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F8FAFC', 'primaryBorderColor': '#CBD5E1', 'primaryTextColor': '#0F172A', 'clusterBkg': '#FAFBFC', 'clusterBorder': '#CBD5E1', 'titleColor': '#0F172A', 'edgeLabelBackground': '#FFFFFF', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TB
    classDef core     fill:#DCFCE7,stroke:#15803D,stroke-width:2px,color:#14532D
    classDef gos      fill:#E0F2FE,stroke:#0284C7,stroke-width:1.5px,color:#0C4A6E
    classDef runtime  fill:#DBEAFE,stroke:#1D4ED8,stroke-width:1.5px,color:#1E3A8A
    classDef provider fill:#FEF9C3,stroke:#B45309,stroke-width:1.5px,color:#78350F
    classDef msr      fill:#F3E8FF,stroke:#7C3AED,stroke-width:1.5px,color:#3B0764
    classDef boundary fill:#FCE7F3,stroke:#9D174D,stroke-width:2px,color:#831843
    classDef app      fill:#FDF4FF,stroke:#C026D3,stroke-width:1.5px,color:#701A75
    classDef cli      fill:#F1F5F9,stroke:#475569,stroke-width:1px,color:#1E293B
    classDef test     fill:#F8FAFC,stroke:#94A3B8,stroke-width:1px,color:#64748B
    classDef ts       fill:#FFF7ED,stroke:#EA580C,stroke-width:1.5px,color:#9A3412
    classDef build    fill:#FDF2F8,stroke:#DB2777,stroke-width:1.5px,color:#9D174D

    subgraph T1["  Tier 1 — Mestral Core · HealthOS/Tier1-Mestral-Core  "]
        CORE["HealthOSCore\nCore law · governance types · storage contracts\nGOS types · MSR runtime types · entity model\nSources/HealthOSCore"]:::core
    end

    subgraph T2["  Tier 2 — GOS / Runtimes · HealthOS/Tier2-GOS-Runtimes  "]
        direction LR
        GOS["HealthOSGOS\nGOS runtime · operational mediation\nSources/HealthOSGOS"]:::gos
        PROV["HealthOSProviders\nruntime provider-adapter module\nFoundationModels · ProviderRouter · stubs\nSources/HealthOSProviders"]:::provider
        AACI["HealthOSAACI\nAACI runtime · GOS binding\ncapture · draft composition\nSources/HealthOSAACI"]:::runtime
        MSR["HealthOSMSR\nMental Space Runtime\nASL · VDLP · GEM executors\nSources/HealthOSMSR"]:::msr
        SRT["HealthOSSessionRuntime\norchestration · normalization\nScribe bridge adapter\nSources/HealthOSSessionRuntime"]:::gos
        ASYNC["HealthOSAsyncRuntime\njob queue · idempotency\nSources/HealthOSAsyncRuntime"]:::runtime
        UAR["HealthOSUserAgentRuntime\npatient session · sovereignty\nSources/HealthOSUserAgentRuntime"]:::runtime
        SVR["HealthOSServiceRuntime\nservice operations session\nSources/HealthOSServiceRuntime"]:::runtime
    end

    subgraph T3["  Tier 3 — Custom Boundary · HealthOS/Tier3-Custom-Boundary  "]
        direction LR
        CUSTOM["CustomSDK\nStage-definition SDK · capabilities\nprohibitions · degradation policy · validation\nSources/CustomSDK"]:::boundary
        AB["HealthOSBoundary\nfacades · safe refs · envelopes\nCustom-mediated Stage consumption\nSources/HealthOSBoundary"]:::boundary
    end

    subgraph T4["  Tier 4 — Stages Cast · separate Swift packages  "]
        direction LR
        SCRIBE["Scribe Package\nTier4-Stages-Cast/Scribe/Package.swift\nSources/Scribe"]:::app
        VERIDIA["Veridia Package\nTier4-Stages-Cast/Veridia/Package.swift\nSources/Veridia"]:::app
        CC["CloudClinic Package\nTier4-Stages-Cast/CloudClinic/Package.swift\nSources/CloudClinic"]:::app
    end

    subgraph SHARED["  Shared · HealthOS/Shared  "]
        CLI["HealthOSCLI\noperator executable\nSources/HealthOSCLI"]:::cli
    end

    subgraph EXTTEST["  Structural test targets  "]
        direction LR
        CST["HealthOSConstructionSystemTests"]:::test
        SUPT["HealthOSSupportToolingTests"]:::test
        SHT["HealthOSTests"]:::test
    end

    SUPPORT["HealthOS/Support\nops · python · ML tooling\nnot imported as HealthOSProviders"]:::cli

    CORE --> GOS & PROV & MSR & ASYNC & UAR & SVR & SRT
    PROV --> AACI & MSR
    GOS --> AACI
    CORE --> AACI
    CORE --> CUSTOM
    AACI & MSR & ASYNC & UAR & SVR & SRT --> AB
    GOS & CORE & CUSTOM --> AB
    CORE & SRT --> CLI
    AB & CUSTOM --> SCRIBE
    AB & CUSTOM --> VERIDIA
    AB & CUSTOM --> CC
    CST -. keeps Constructor external and testable .-> CORE
    SUPT -. keeps Support Core-governed .-> CORE
    SUPPORT -. supports provider tooling under ModelGovernance .-> PROV
    SUPPORT -. validated by .-> SUPT
    SHT -. shared governance regression suite .-> CORE

    subgraph TSPKG["  Constructor/ts TypeScript Workspace · HealthOS/Constructor/ts  "]
        direction LR
        TSCON["@healthos/contracts\nCore type mirrors · GOS contracts\nentity model · runtime types\npackages/contracts/"]:::ts
        TSGOS["@healthos/healthos-gos-tooling\nGOS compiler · validator · bundler\nbundle lifecycle tooling\npackages/healthos-gos-tooling/"]:::ts
        TSASYNC["@healthos/runtime-async\nTS reference implementation\nfor HealthOSAsyncRuntime\npackages/runtime-async/"]:::ts
        TSUA["@healthos/runtime-user-agent\nTS reference implementation\nfor HealthOSUserAgentRuntime\npackages/runtime-user-agent/"]:::ts
        TSSTEW["@healthos/steward\n10 CLI commands · ST-010–ST-017\ncoordinator · derived memory · sessions\nagent-infra/healthos-steward/"]:::build
        TSMCP["@healthos/forge-mcp\n10 steward_* MCP tools · ST-018\nstdio + Streamable HTTP · repo-maintenance only\nagent-infra/healthos-forge-mcp/"]:::build
        TSMA["@healthos/managed-agent\nST-022 · Anthropic Managed Agents API\ndiscover · brief · validate · handoff\nhuman-triggered only · not a clinical surface\nagent-infra/healthos-managed-agent/"]:::build
    end

    %% Cross-language alignment — TypeScript to Swift
    TSCON -. "cross-language type alignment" .-> CORE
    TSGOS -. "compiles/validates bundles consumed by" .-> GOS
    TSASYNC -. "TS reference impl for" .-> ASYNC
    TSUA -. "TS reference impl for" .-> UAR
    TSMCP -. "wraps CLI commands of" .-> TSSTEW
    TSMA -. "uses Forge MCP HTTP for session workflows" .-> TSMCP
```

| Target | Tier | Kind | Description |
| :--- | :--- | :--- | :--- |
| `HealthOSCore` | Tier 1 — Mestral Core | Library | Core law, governance types, storage contracts, GOS types, MSR runtime types, entity model |
| `HealthOSProviders` | Tier 2 — GOS / Runtimes | Library | Runtime provider-adapter module: provider protocol contracts, `AppleFoundationProvider` (FoundationModels), stub providers, model governance |
| `HealthOSGOS` | Tier 2 — GOS / Runtimes | Library | GOS runtime — operational mediation subordinate to Core law; canonical home for GOS lifecycle (migration from AACI in progress) |
| `HealthOSAACI` | Tier 2 — GOS / Runtimes | Library | AACI runtime, GOS binding consumption, session capture, draft composition |
| `HealthOSMSR` | Tier 2 — GOS / Runtimes | Library | Mental Space Runtime pipeline — ASL, VDLP, GEM executors, provenance metadata |
| `HealthOSAsyncRuntime` | Tier 2 — GOS / Runtimes | Library | Durable job queue and async task lifecycle — scaffold stub; TS reference implementation in `HealthOS/Constructor/ts/packages/runtime-async/` |
| `HealthOSUserAgentRuntime` | Tier 2 — GOS / Runtimes | Library | Patient/user-side session lifecycle and sovereignty enforcement — scaffold stub |
| `HealthOSServiceRuntime` | Tier 2 — GOS / Runtimes | Library | Professional/service-operations session lifecycle — scaffold stub |
| `HealthOSSessionRuntime` | Tier 2 — GOS / Runtimes | Library | Session orchestration (`SessionRunner`), transcript normalization executor, Scribe bridge adapter |
| `CustomSDK` | Tier 3 — Custom Boundary | Library | Stage-definition SDK: Custom manifests, capabilities, prohibitions, degradation policy, validation requirements, and compliance checks |
| `HealthOSBoundary` | Tier 3 — Custom Boundary | Library | Boundary compatibility module — the technical import surface for mediated Stage consumption; transitional shim pending full Tier 2 facade stabilization |
| `HealthOSCLI` | — | Executable | Operator command-line interface for session and GOS lifecycle |

Tier 4 Stage executables are no longer products of the central platform package:

| Stage package | Product | Required platform imports | Maturity |
| :--- | :--- | :--- | :--- |
| `HealthOS/Tier4-Stages-Cast/Scribe/Package.swift` | `Scribe` | `HealthOSBoundary`, `CustomSDK` | Scribe professional workspace Stage validation surface (SwiftUI, macOS 26+) |
| `HealthOS/Tier4-Stages-Cast/Veridia/Package.swift` | `Veridia` | `HealthOSBoundary`, `CustomSDK` | Veridia patient identity Stage boundary — smoke-testable, no final UI |
| `HealthOS/Tier4-Stages-Cast/CloudClinic/Package.swift` | `CloudClinic` | `HealthOSBoundary`, `CustomSDK` | CloudClinic service operations Stage — scaffold placeholder, no final UI |

---

## 🪟 Native Interface Layer — Liquid Glass Design System

HealthOS native macOS surfaces target macOS 26+ and adopt **Liquid Glass as the design baseline** per `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`.

Standard SwiftUI/AppKit controls and navigation surfaces (sidebars, toolbars, sheets, `NavigationSplitView`) inherit system Liquid Glass behavior automatically. Custom `glassEffect`, `GlassEffectContainer`, and glass button styles are reserved for app-specific HealthOS surfaces not covered by standard controls.

**Current scaffold state:** `Scribe` uses `GroupBox` + `.thinMaterial` with standard SwiftUI controls. `HealthOS/Shared/DesignSystem/` is the implemented design system baseline (DS-001, 2026-05-05). Full Liquid Glass adoption is in progress as the macOS 26+ native app shell matures.

<p align="center">
  <img src="HealthOS/Shared/docs/assets/liquidglass_intro.gif" width="100%" alt="Demonstração do Liquid Glass UI — HealthOS Scribe First Slice">
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

    subgraph DS["HealthOS/Shared/DesignSystem"]
        TOK[Semantic tokens\nsovereign · mediated · ready · degraded · denied]:::design
        STD[Native controls first\nWindowGroup · toolbar · sidebar · sheet]:::sys
        CUS[Custom glass only when needed\nGlassEffectContainer per logical group]:::design
    end

    subgraph SCRIBEAPP["Scribe"]
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
| **Governed AI Agent Society** | ✅ Implemented Seam | Core contracts (`GovernedAIAgentContracts`), `PersonalAgentRuntime`, `AgentProtocolBoundary` — first slice; no real provider, no productive PHI memory |
| **GOS Layer** | ✅ Operational Path | Stabilization, bundle binding, compiler tooling |
| **AACI First Slice** | 🚧 Scaffold Hardening | Boundary enforcement + GOS-mediated derived drafts |
| **MSR Pipeline** | 🚧 Scaffold | ASL · VDLP · GEM stages, provenance metadata |
| **Provider / ML** | ⚠️ Stub / Contract | `AppleFoundationProvider` adapter; deterministic safety posture |
| **Stage / UI** | 🧩 Contract-First | Minimal Scribe validation surface; Veridia Boundary scaffold; CloudClinic blocked before new wiring |
| **Liquid Glass UI** | 🎯 macOS 26+ Baseline | `HealthOS/Shared/DesignSystem/` baseline (DS-001); glass adoption in progress |
| **Construction System** | ✅ Implemented Seam | 10 CLI commands (healthos-steward) + 10 MCP tools (healthos-forge-mcp) |

Read this table as an onboarding summary. The authoritative maturity ladder is `doctrine-only` → `scaffolded contract` → `implemented seam` → `tested operational path` → `production-hardened`, maintained in `HealthOS/Shared/docs/execution/11-current-maturity-map.md`.

### Known Limitations

The following are **not present in this repository** and must not be inferred from scaffold behavior:

| Area | Limitation |
| :--- | :--- |
| Production readiness | This is a scaffold/foundation phase. Not production-ready in any tier. |
| EHR | Not a complete Electronic Health Record. |
| UI delivery | No final native macOS app shell for any Stage (Scribe, Veridia, CloudClinic). |
| Regulatory / signature | Fail-closed validators exist; no real endpoint, signature provider, or interoperability integration. |
| Semantic retrieval | Governed contracts exist; no real embeddings adapter, vector index, or embedding provider. |
| External providers | `HealthOSProviders` and `HealthOS/Support/ML/` remain scaffold/stub posture for LM, STT, and embedding. |
| Async Runtime | Swift stub; TS reference implementation exists but no PostgreSQL-backed executor. |
| MSR execution | ASL/VDLP/GEM contracts defined; pipeline execution incomplete end-to-end. |
| Production fabric | Network/mesh is doctrine-only; no production sovereign fabric or ACL tooling. |
| CloudClinic wiring | `APP-012` is BLOCKED — Custom definition incomplete; Boundary needs explicit service facade decision. |
| CI/CD | Validation harness is local-only (Make + scripts); no GitHub Actions CI pipeline yet. |

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

**Xcode:** open `HealthOS.xcworkspace` from repository root — resolves `HealthOS/Package.swift`, visible `Constructor` / `Support` roots, shared schemes, profile schemes, and layer test plans.

**Smoke paths:**

```bash
make smoke-cli
make smoke-scribe
make smoke-veridia
make smoke-cloudclinic
```

**Direct smoke commands:**

```bash
cd HealthOS && swift run HealthOSCLI
cd HealthOS && swift run HealthOSCLI --reject-gate
cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test
cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test-audio
cd HealthOS/Tier4-Stages-Cast/Veridia && swift run Veridia --smoke-test
cd HealthOS/Tier4-Stages-Cast/CloudClinic && swift run CloudClinic --smoke-test
```

**GOS bundle lifecycle:**

```bash
cd HealthOS && swift run HealthOSCLI \
  --gos-review-bundle <bundle-id> \
  --gos-spec-id <spec-id> \
  --reviewer-id <id> \
  --review-rationale "<reason>"

cd HealthOS && swift run HealthOSCLI \
  --gos-promote-bundle <bundle-id> \
  --gos-spec-id <spec-id> \
  --activator-id <id> \
  --activation-rationale "<reason>"
```

`Veridia` has a smoke-testable Veridia session boundary. `CloudClinic` remains a scaffold placeholder executable for product-graph representation. Neither implements final UI, clinical authority, real provider/signature/interoperability behavior, or production readiness.

### Environment Variables

| Variable | Default | Purpose |
| :--- | :--- | :--- |
| `FORGE_MCP_PORT` | `3791` | Port for `healthos-forge-mcp` Streamable HTTP server |
| `FORGE_MCP_URL` | _(unset)_ | Publicly reachable URL for remote Managed Agent connection; localhost is not sufficient |
| `ANTHROPIC_API_KEY` | _(unset)_ | Required for `healthos-managed-agent` live create/update (ST-022/ST-023) |
| `ANTHROPIC_AUTH_TOKEN` | _(unset)_ | Alternative auth token for Anthropic API (used in place of `ANTHROPIC_API_KEY`) |

> No secrets are committed to this repository. Provider local configs with secrets must never be committed. If you encounter API keys or tokens in the codebase, move them to environment variables or a secret manager immediately.

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
    J[HealthOS/Tier1-Mestral-Core/Schemas/\nJSON Schema]:::schema
    SW[HealthOS/Package.swift\nPlatform Swift products + tests\nCore · runtimes · Boundary · CustomSDK]:::swift
    STAGEPKG[HealthOS/Tier4-Stages-Cast/<Stage>/Package.swift\nSeparate Stage packages\nScribe · Veridia · CloudClinic]:::swift
    TS[HealthOS/Constructor/ts/\ncontracts + runtimes + tooling]:::ts
    SQL[HealthOS/Tier1-Mestral-Core/SQL/migrations/\nmetadata shape]:::sql

    C --> J & SW & STAGEPKG & TS & SQL
    J <--> SW
    J <--> TS
    SW <--> TS
    SW --> STAGEPKG
    SQL -. when relevant .-> SW
    SQL -. when relevant .-> TS
```

---

## ✨ Reading Paths

| If you want to… | Start here | Then go to |
| :--- | :--- | :--- |
| Understand what HealthOS is | `HealthOS/Shared/docs/architecture/01-overview.md` | `19-interface-doctrine.md`, `46-apple-sovereignty-architecture.md` |
| Understand the consolidated technical product definition | `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` | `HealthOS/Shared/docs/product/README.md`, `HealthOS/Shared/docs/architecture/` and `HealthOS/Shared/docs/execution/` sources referenced by the spec |
| Understand the executable slice | `HealthOS/Shared/docs/architecture/28-first-slice-executable-path.md` | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/FirstSliceContracts.swift` |
| Understand GOS | `HealthOS/Shared/docs/architecture/29-governed-operational-spec.md` | `30-gos-authoring-and-compiler.md` → `33-gos-app-consumption-patterns.md` |
| Understand MSR | `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md` | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/MSRRuntime.swift` |
| Understand native UI + Liquid Glass | `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` | `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/` |
| Understand governed AI agents and patient sovereignty | `HealthOS/Shared/docs/architecture/52-governed-ai-agent-society.md` | `HealthOS/Shared/docs/adr/0014-governed-ai-agent-society.md`, `GovernedAIAgentContracts.swift`, `UserAgentRuntime.swift` |
| Understand Apple sovereignty | `HealthOS/Shared/docs/architecture/46-apple-sovereignty-architecture.md` | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift` |
| Understand apps and boundaries | `HealthOS/Shared/docs/architecture/11-scribe.md` | `12-veridia.md`, `13-cloudclinic.md`, `43-cross-app-coordination-shared-surfaces.md` |
| Understand maturity and gaps | `HealthOS/Shared/docs/execution/11-current-maturity-map.md` | `13-scaffold-release-candidate-criteria.md`, `14-final-gap-register.md` |
| Start coding safely | `HealthOS/Shared/docs/execution/README.md` | `01-agent-operating-protocol.md`, `02-status-and-tracking.md`, relevant `todo/*.md` |
| Understand Steward for Xcode | `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` | `HealthOS/Shared/docs/execution/17-healthos-xcode-agent-migration-plan.md` |
| Understand the construction system | `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` | `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`, `HealthOS/Constructor/Settler/territories/` |
| Use Steward CLI | `CLAUDE.md` Steward usage section | `HealthOS/Constructor/ts/agent-infra/healthos-steward/` |
| Use healthos-forge-mcp | `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` | `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` |
| See open documentation tasks | `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md` | `HealthOS/Shared/docs/execution/prompts/` |
| Select the next implementation task | `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` — canonical priority-ordered task list | `HealthOS/Shared/docs/execution/02-status-and-tracking.md`, relevant `todo/*.md` |
| See current status and handoff | `HealthOS/Shared/docs/execution/02-status-and-tracking.md` | `HealthOS/Shared/docs/execution/12-next-agent-handoff.md` |

### Executive Visual Overview

`DOC-README-VISUAL-PRESENTATION-001` produced an editable visual overview deck as an external work-unit deliverable because this checkout does not yet contain a clear versioned `HealthOS/Shared/docs/assets/presentations/` pattern. When a repository asset policy exists, the intended durable path is `HealthOS/Shared/docs/assets/presentations/healthos-visual-overview.pptx`.

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
    A3[Code Surfaces\nHealthOS tiers · Constructor/ts · schemas · SQL]:::code
    A4[Repository Engineering\nSteward · Settlers · Territories]:::steward
    A5[Claude Code Automations\nupdate · digest · sync]:::steward
    A6[Native UI + Liquid Glass\n48-native-macos-ui · Shared/DesignSystem · Scribe Stage]:::ui
    A7[Product Specification\nproduct/01-healthos-technical-product-specification.md\nTask selection: 21-structural-ontology-and-product-readiness-plan.md]:::exec

    R --> A1 & A2 & A3 & A4 & A5 & A6 & A7

    A1 --> A11[Core law]
    A1 --> A12[GOS]
    A1 --> A13[Boundary and Stages]
    A2 --> A21[What is ready now]
    A2 --> A22[What is blocked]
    A2 --> A23[What to do next]
    A3 --> A31[Executable first slice]
    A3 --> A32[Cross-language contracts]
    A4 --> A41[Steward baseline]
    A4 --> A42[Settler doctrine]
    A6 --> A61[Component contracts]
    A6 --> A62[Semantic tokens + glass adoption path]
    A7 --> A71[Technical product baseline]
    A7 --> A72[Priority-ordered task selection]
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

    D[HealthOS/Shared/docs/architecture\nCanonical doctrine]:::docs
    E[HealthOS/Shared/docs/execution\nProtocol · status · TODO · handoff]:::exec
    S[HealthOS/Tier1-Mestral-Core\nSchemas · SQL]:::data
    W[HealthOS/Package.swift\nTiered Swift graph]:::code
    T[HealthOS/Constructor/ts\ncontracts · tooling · agent infra]:::code
    DS[HealthOS/Shared/DesignSystem\npresentation tokens · UI kits · assets]:::code
    P[HealthOS/Support/\nops · python · ML/provider-support tooling]:::code
    EG[HealthOS/Constructor\nSteward + Settler state]:::agent
    CA[Codex automations\nGuidance · status · dependency · skill map]:::agent

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
    W -->|contract checks align with| T
    P -->|Core-governed support posture| W
    EG -. outside clinical/runtime hierarchy .-> D
    CA -->|reports drift for| E
    CA -->|proposes PRs for| D
```

### Code-to-Doc Orientation

| Surface | Primary docs | Primary code |
| :--- | :--- | :--- |
| Core law | `HealthOS/Shared/docs/architecture/06-core-services.md`, `05-data-layers.md`, `07-storage-and-sql.md` | `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` |
| Governed AI Agent Society | `HealthOS/Shared/docs/architecture/52-governed-ai-agent-society.md`, `HealthOS/Shared/docs/adr/0014-governed-ai-agent-society.md` | `GovernedAIAgentContracts.swift`, `UserAgentRuntime.swift`, `AgentProtocolBoundary.swift` |
| AACI + first slice | `HealthOS/Shared/docs/architecture/09-aaci.md`, `28-first-slice-executable-path.md` | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/`, `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/` |
| MSR | `HealthOS/Shared/docs/architecture/49-mental-space-runtime.md` | `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/` |
| GOS | `29-governed-operational-spec.md` → `34-gos-review-and-activation-policy.md` | `HealthOS/Constructor/ts/packages/healthos-gos-tooling/`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` |
| Boundary | `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`, `19-interface-doctrine.md` | mediated facades/envelopes in `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` and runtime adapters |
| Native UI + Liquid Glass | `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` | `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/` |
| Apple substrate capabilities | `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md`, `46-apple-sovereignty-architecture.md` | Apple-native capabilities only through Core/Boundary/provider/runtime mediation; no Stage-owned authority |
| Stages | `11-scribe.md`, `12-veridia.md`, `13-cloudclinic.md`, `43-cross-app-coordination-shared-surfaces.md` | `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/`, `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/`, `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic/` |
| Providers / ML | `HealthOS/Shared/docs/architecture/16-providers-and-ml.md`, `27-provider-threshold-policy.md` | Runtime adapters: `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/`; governed support tooling: `HealthOS/Support/ML/`, `HealthOS/Support/python/` |
| Steward | `45-healthos-xcode-agent.md`, `47-steward-settler-engineering-model.md` | `HealthOS/Constructor/ts/agent-infra/healthos-steward/`, `HealthOS/Constructor/Steward/` |

---

## 📂 Internal Documentation Index

| Module / Folder | README | Focus |
| :--- | :--- | :--- |
| `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` | [README](HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/README.md) | Core law contracts, governance types, storage, GOS, MSR runtime types, entity model |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSGOS/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSGOS/README.md) | GOS runtime stub — canonical home for GOS lifecycle; migration from HealthOSAACI in progress |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/README.md) | AACI runtime — session capture, GOS binding consumption, draft composition |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSMSR/README.md) | Mental Space Runtime pipeline — ASL · VDLP · GEM executors, provenance metadata |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/README.md) | Runtime provider-adapter module: provider protocol contracts, Apple FoundationModels adapter, stub providers |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAsyncRuntime/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAsyncRuntime/README.md) | Async Runtime stub — job queue and lifecycle; TS reference implementation |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSUserAgentRuntime/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSUserAgentRuntime/README.md) | User-Agent Runtime — `PersonalAgentRuntime` actor, `PatientPersonalAgent` / `ProfessionalPersonalAgent` session lifecycle, envelope validation, offline response queue |
| `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedAIAgentContracts.swift` | — | Core agent contracts: `GovernedAIAgentKind`, `AgentMandate`, `AgentMemoryScope`, `AgentToolGrant`, `DelegationPolicy`, `AgentNegotiationEnvelope`, `GovernedAIAgentValidator` |
| `HealthOS/Tier3-Custom-Boundary/Sources/HealthOSBoundary/AgentProtocolBoundary.swift` | — | Boundary projection: `project(envelope:)` → healthos-aacp / a2a / acp; fail-closed app-safe projection guard |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSServiceRuntime/` | [README](HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSServiceRuntime/README.md) | Service Runtime stub — professional/service-operations session lifecycle |
| `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/` | — | Session orchestration, normalization executor, Scribe bridge adapter |
| `HealthOS/Tier3-Custom-Boundary/Sources/HealthOSBoundary/` | [README](HealthOS/Tier3-Custom-Boundary/Sources/HealthOSBoundary/README.md) | Boundary compatibility module — Tier 3 facade; Stage executables should consume mediated surfaces through it as it matures |
| `HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/` | [README](HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/README.md) | Scribe validation surface, SwiftUI architecture, Liquid Glass adoption path |
| `HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia/` | — | Veridia smoke-testable Stage executable and app-safe patient identity surface |
| `HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic/` | — | CloudClinic smoke-testable Stage executable and service operations placeholder |
| `HealthOS/Shared/DesignSystem/` | [README](HealthOS/Shared/DesignSystem/README.md) | Shared presentation tokens, UI kits, previews, and Stage visual assets |
| `HealthOS/Shared/docs/architecture/` | [index](HealthOS/Shared/docs/architecture/) | 50+ canonical architecture doctrine documents |
| `HealthOS/Shared/docs/execution/` | [README](HealthOS/Shared/docs/execution/README.md) | Execution protocol, status tracking, TODO tracker, maturity/handoff |
| `HealthOS/Constructor/` | [README](HealthOS/Constructor/README.md) | Visible external Construction System root: Steward, Settler, Territory, TS tooling, and structural tests |
| `HealthOS/Constructor/ts/` | [README](HealthOS/Constructor/ts/README.md) | TypeScript workspace: contracts, GOS tooling, runtime reference packages, Steward CLI, Forge MCP, Managed Agent seam |
| `HealthOS/Support/ML/` | [README](HealthOS/Support/ML/README.md) | Create ML/Core ML/MLX scaffolds — transcript normalization; gated by ModelGovernance |
| `HealthOS/Support/` | [README](HealthOS/Support/README.md) | Visible Support root for ops, Python, and governed ML tooling |
| `HealthOS/Constructor/Steward/` | [README](HealthOS/Constructor/Steward/README.md) | Steward derived state, session memory, automation logs |
| `HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/` | [README](HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/README.md) | Forge MCP stdio and Streamable HTTP server — 10 deterministic repository-maintenance tools |

---

## 🗂️ Repository Map (current)

- `HealthOS/Shared/docs/architecture/` — canonical architecture and doctrine docs (GOS, app-boundary, regulatory, cross-app, native UI)
- `HealthOS/Shared/docs/execution/` — governed execution protocol, status tracking, coverage, invariants, TODOs, maturity/handoff
- `HealthOS/Tier1-Mestral-Core/Schemas/` — JSON Schema entity contracts and GOS schemas
- `HealthOS/Package.swift` — canonical SwiftPM graph for Core (T1), `HealthOSProviders` runtime adapters plus GOS/AACI/MSR/Runtimes (T2), `CustomSDK` and Boundary (T3), CLI, Support/Construction/Stage-package structural tests, and shared test suites
- `HealthOS/Tier4-Stages-Cast/<Stage>/Package.swift` — separate SwiftPM package per Stage; each Stage depends on the platform package only through `HealthOSBoundary` and `CustomSDK`
- `HealthOS/Constructor/ts/` — workspace packages (`contracts`, `runtime-async`, `runtime-user-agent`, `healthos-gos-tooling`, `healthos-steward`, `healthos-forge-mcp`)
- `HealthOS/Constructor/ts/agent-infra/` — Construction System agent infrastructure (`healthos-steward`, `healthos-forge-mcp`, `healthos-managed-agent`)
- `HealthOS/Constructor/Tests/` — Swift structural tests that keep Construction System files visible and outside the clinical/runtime hierarchy
- `HealthOS/Support/ML/` — Create ML/Core ML/MLX scaffolds for governed local model tooling (transcript normalizer stub; gated by ModelGovernance)
- `HealthOS/Support/python/` — offline ML governance scaffolds only
- `HealthOS/Tier1-Mestral-Core/SQL/migrations/001_init.sql` — canonical metadata schema scaffold
- `HealthOS/Support/ops/` and `scripts/` — local operational scaffolding, bootstrap, network and backup notes
- `HealthOS/Tier4-Stages-Cast/AppDocs/` — interface boundary scaffolds/documentation
- `HealthOS/Constructor/Steward/` — derived Steward state, policies, prompts, session memory
- `HealthOS/Constructor/Steward/memory/automations/` — automation run logs and daily TODO digests
- `HealthOS/Constructor/Settler/` — Settler profiles (`HealthOS/Constructor/Settler/settlers/`) and Territory Registry (`HealthOS/Constructor/Settler/territories/`)
- `.claude/settings.json` — Claude Code settings/MCP configuration; no repository-local scheduled-task registry

---

## Steward, Settlers, and Territories

Steward is the canonical engineering agent for this repository. `healthos-steward` is the CLI, package, and repository-local state root.

- CLI and package: `HealthOS/Constructor/ts/agent-infra/healthos-steward/`
- Repository-local derived state root: `HealthOS/Constructor/Steward/`
- Current persisted runtime state: `HealthOS/Constructor/Steward/memory/sessions/`

Settlers are specialized engineering agent profiles. Settlements are bounded engineering work units. Territories are documented repository domains. Canonical model: `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md`.

```bash
make ts-build
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward status
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward session
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list territories
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list settlers
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward list settlements
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect territory <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect settler <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward inspect settlement <id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward next
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward generate-prompt <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward validate-settlement <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward pr-draft <settlement-id>
cd HealthOS/Constructor/ts && npx --yes --workspace @healthos/steward healthos-steward build-memory
```

Ten `healthos-steward` CLI commands are implemented (ST-010 through ST-017). `dist/` is not committed — run `make ts-build` once before invoking.

**Steward for Xcode** is the Xcode-integration posture: integrates with Xcode Intelligence as an Apple-controlled engineering runtime surface. See `HealthOS/Shared/docs/architecture/45-healthos-xcode-agent.md` for target architecture.

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
    classDef agent     fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843

    DOCS[Official docs\ncanonical truth]:::docs
    STEW[Steward\n10 CLI commands · ST-010–ST-017]:::steward
    SETTLER[Settler profiles\n9 profiles · settlers/]:::settler
    TERR[Territory Registry\n15 territories · territories/]:::territory
    SETTLE[Settlements\nbounded work records]:::settler
    MCP[healthos-forge-mcp\nimplemented seam · ST-018\n10 steward_* MCP tools\nstdio + Streamable HTTP]:::mcp
    MEM[Derived Memory\nmemory/derived/\nnon-canonical snapshots]:::mem
    MA[Managed Agent seam\nST-022 · Anthropic API\ndiscover · brief · validate · handoff\nhuman-triggered only]:::agent

    DOCS --> STEW
    DOCS --> TERR
    STEW -->|selects| SETTLER
    STEW -->|frames| SETTLE
    SETTLER -->|operates within| TERR
    SETTLE -->|records scope and validation| DOCS
    MCP -->|wraps| STEW
    STEW -->|build-memory writes| MEM
    MA -. human-triggered lifecycle sessions .-> STEW
    MEM -. non-canonical do not cite .-> DOCS
```

### Managed Agent Seam (ST-022/ST-023)

`@healthos/managed-agent` provides Anthropic Managed Agents API integration for typed construction lifecycle sessions. It is a human-triggered engineering helper, not an autonomous executor or merge authority.

```bash
# Dry-run agent registration (no API call)
cd HealthOS/Constructor/ts && npm run create-agent:dry-run --workspace @healthos/managed-agent

# Live create/update (requires ANTHROPIC_API_KEY or ANTHROPIC_AUTH_TOKEN)
cd HealthOS/Constructor/ts && npm run create-agent --workspace @healthos/managed-agent
```

Typed session workflows: `discover`, `brief`, `validate`, `handoff`. Writes `HealthOS/Constructor/Steward/managed-agent/agent.json` when live. See `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`.

Canonical truth resides in `HealthOS/Shared/docs/` and project manifests. Steward memory, Settler scaffolds, Settlement records, and Territory records are derived or instructional engineering surfaces — non-clinical, non-constitutional, and non-authorizing.

---

## 🤖 Repository Maintenance Automations

Scheduled repository maintenance is owned by grouped Codex automations outside the repository, not by a Claude Code cron registry. Read-only jobs report evidence; document-changing jobs must use a worktree/branch and PR handoff, never direct push to `main`.

| Automation group | Cadence | Mode | Function |
| :--- | :--- | :--- | :--- |
| `HealthOScaffold Agent Guidance Maintenance` | Weekly, Tuesday 10:00 | worktree, PR-only | Reviews AGENTS/CLAUDE/README, Steward/Xcode docs, and automation guidance drift |
| `HealthOScaffold Status Digest` | Monday/Wednesday/Friday 08:30 | worktree, read-only | Reports READY/BLOCKED/DONE evidence, tracker inconsistencies, gaps, and next actions |
| `HealthOScaffold Dependency and SDK Drift` | Weekly, Thursday 11:00 | worktree, read-only | Reports manifest, lockfile, SDK, and toolchain drift |
| `HealthOScaffold Retrospective Skill Map` | Every two weeks, Friday 10:00 | worktree, read-only | Suggests concrete skills to deepen from PR/review/commit evidence |

No `.claude/automations/` directory or `.claude/scheduled_tasks.json` file is kept for retired jobs. Historical derived logs may remain under `HealthOS/Constructor/Steward/memory/automations/`, but they are not scheduler definitions.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f0fdf4', 'primaryBorderColor': '#86efac', 'primaryTextColor': '#14532d', 'clusterBkg': '#fafafa', 'clusterBorder': '#e2e8f0', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fafc', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart LR
    classDef trigger fill:#f0fdf4,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef git     fill:#dbeafe,stroke:#3b82f6,stroke-width:2px,color:#1e3a8a
    classDef read    fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef write   fill:#ede9fe,stroke:#8b5cf6,stroke-width:2px,color:#4c1d95
    classDef mem     fill:#fce7f3,stroke:#ec4899,stroke-width:2px,color:#831843

    CRON[Codex cron trigger\nor explicit operator request]:::trigger
    STASH[spawn worktree\nread current main]:::git
    READ[read sources\ndocs · todo · trackers · gaps · git log]:::read
    WRITE[report evidence\nor propose minimal patch]:::write
    COMMIT[branch + PR only\nwhen docs change]:::git
    RESTORE[no direct main push]:::git
    MEM[HealthOS/Constructor/Steward/memory/\nautomations/]:::mem

    CRON --> STASH --> READ --> WRITE --> COMMIT --> RESTORE
    READ -. historical derived logs .-> MEM
```

### Documental Work Plan

`HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md` is the living plan for open documentation tasks. It is no longer edited by a scheduled Claude cron job; update it only through an explicit, scoped work unit with validation and PR handoff.

Phase execution prompts in `HealthOS/Shared/docs/execution/prompts/`:

| Prompt file | Phase | Tasks |
| :--- | :--- | :--- |
| `phase-1-settler-territory.md` | Phase 1 | ST-006 Territory records · ST-002 Settler profiles · ST-003 Settlement schema |
| `phase-2-architecture-proposals.md` | Phase 2 | CL-006 Error envelope · OPS-003 Incident command set · ST-004 healthos-forge-mcp spec |
| `phase-3-xcode-agent-streams.md` | Phase 3 | Stream C tool contracts · Stream D backend contract · Stream F Xcode envelope |

---

## 🧠 Where Agents Should Start

Read in order before coding:

1. `README.md` (this file)
2. `HealthOS/Shared/docs/execution/README.md`
3. `HealthOS/Shared/docs/execution/00-master-plan.md`
4. `HealthOS/Shared/docs/execution/01-agent-operating-protocol.md`
5. `HealthOS/Shared/docs/execution/02-status-and-tracking.md`
6. `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md`
7. `HealthOS/Shared/docs/execution/10-invariant-matrix.md`
8. `HealthOS/Shared/docs/execution/11-current-maturity-map.md`
9. `HealthOS/Shared/docs/execution/12-next-agent-handoff.md`
10. `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`
11. `HealthOS/Shared/docs/execution/14-final-gap-register.md`
12. `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md`
13. `HealthOS/Shared/docs/execution/16-next-10-actions-plan.md`
14. `HealthOS/Shared/docs/execution/20-documental-todos-work-plan.md` — living plan for open documentation tasks
15. `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` — **read before selecting any implementation task**; canonical priority-ordered task selection plan
16. `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` — **read before generating construction or product work units**; technical product specification baseline
17. `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md` — construction system operating model
18. `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md` — ST task sequence and status
19. relevant `HealthOS/Shared/docs/execution/todo/*.md`
20. relevant `HealthOS/Shared/docs/architecture/*.md`
21. matching `HealthOS/Shared/docs/execution/skills/*.md`
22. if touching Swift/SwiftUI/Xcode: `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` and matching `HealthOS/Shared/docs/execution/skills/<name>/SKILL.md`

---

## Canonical Hierarchy

```text
HealthOS
  Tier 1 — Mestral Core
    consent, habilitation, storage law,
    provenance, gate, finality, audit
  Tier 2 — GOS / Runtimes
    GOS subordinate operational mediation, never constitutional authority.
    Session Runtime, AACI, MSR, Async Runtime,
    User-Agent Runtime, Service Runtime.
    HealthOSProviders is the runtime provider-adapter module.
  Tier 3 — Custom Boundary
    HealthOS-owned consumption frontier:
    facades, envelopes, safe refs, mediated state,
    degraded state, commands/results, consumable surfaces.
    Custom is the Core-law-governed Stage definition:
    capabilities, limits, consumed surfaces, actors,
    degradation behavior, validation, prohibitions.
  Tier 4 — Stages Cast
    Separate governed Stage universe:
    Scribe, Veridia, CloudClinic, future governed consumers.
    Stages are in the clinical/application environment, but their
    point of contact with the rest of HealthOS is Tier 3 Boundary.

HealthOS/Support
  Shared provider-support tooling, ops, Python, Create ML/Core ML/MLX tooling.
  It is not the HealthOSProviders runtime import target.
  Reachable from Core, runtimes, Stages, and Constructor workflows;
  governed by Core law and ModelGovernance.

Material substrate
  host, storage, private network/mesh, backups,
  APFS + FileVault + Secure Enclave key custody

Artifacts / effects
  drafts, gate records, final artifacts, provenance/audit traces

Constructor / Construction System
  HealthOS/Constructor:
  Steward, Settlers, Territories, Settlements, HealthOS Forge MCP.
  Outside the HealthOS clinical/runtime hierarchy.
```

## Maturity Snapshot by Layer

Full detail: `HealthOS/Shared/docs/execution/11-current-maturity-map.md`.

- **Core law + storage governance:** implemented seam / tested operational path (local scaffold)
- **Governed AI Agent Society:** implemented seam — `GovernedAIAgentContracts`, `PersonalAgentRuntime`, `AgentProtocolBoundary` with tests; no real LLM provider, no productive PHI memory persistence
- **GOS authoring/compiler/lifecycle:** implemented seam / tested operational path (scaffold hardening)
- **AACI + first slice orchestration:** implemented seam / tested operational path (bounded scope)
- **MSR pipeline:** scaffold — executors present, provenance metadata defined, provider integration pending
- **Liquid Glass UI:** design baseline established; `HealthOS/Shared/DesignSystem/` implemented (DS-001)
- **Construction system (Steward + Forge MCP):** implemented seam — 10 CLI commands + 10 MCP tools deterministic; no LLM, no merge authority, no clinical scope

## Contributing

This repository uses a **branch → PR → merge** workflow. Direct pushes to `main` are not permitted for document-changing or code work.

```bash
# 1. Sync with remote first
git fetch origin --prune
git checkout main && git pull --ff-only

# 2. Create a task branch
git checkout -b <task-type>/<short-description>

# 3. Build and validate before committing
make swift-build
make swift-test
make validate-all   # schemas, contracts, docs

# 4. Commit atomically — docs + contracts + tests together when governing the same change
git add <specific files>
git commit -m "<tier/area>: <concise imperative description>"

# 5. Open a PR to main
gh pr create --title "<short title>" --body "<summary>"
```

**Task selection order** (from `01-agent-operating-protocol.md`):
1. `READY` task in the current phase
2. `BLOCKER` task
3. Documentation/contract task that unblocks coding
4. Validation for just-finished work

After each work unit, update `HealthOS/Shared/docs/execution/02-status-and-tracking.md` and the corresponding `todo/*.md` file.

Read `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` before selecting any implementation task. Read `HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md` before generating any AI coding prompt.

---

## Scaffold/Foundation Phase Closure References

- `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md`
- `HealthOS/Shared/docs/execution/14-final-gap-register.md`
- `HealthOS/Shared/docs/execution/15-scaffold-finalization-plan.md`
- `HealthOS/Shared/docs/execution/16-next-10-actions-plan.md`
