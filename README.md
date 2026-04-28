# HealthOScaffold

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

HealthOS is a sovereign computational environment for health data and clinical operations. This repository is the HealthOS construction repository in **controlled implementation / scaffold hardening** phase, establishing foundational architecture.

HealthOS is the full platform. **AACI is one runtime inside HealthOS**. **GOS is a governed operational layer subordinate to Core law**. **Scribe, Sortio, and CloudClinic are app/interfaces that consume mediated surfaces; they never define constitutional law**.

## 🏗️ Canonical Architecture

HealthOS mediates all clinical acts through a strictly layered, governance-first fabric.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f0f9ff', 'primaryBorderColor': '#bae6fd', 'primaryTextColor': '#0c4a6e', 'clusterBkg': '#fafafa', 'clusterBorder': '#e2e8f0', 'titleColor': '#0f172a', 'edgeLabelBackground': '#f8fafc', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
graph TD
    classDef iface    fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos      fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef runtime  fill:#e0f2fe,stroke:#0ea5e9,stroke-width:2px,color:#0c4a6e
    classDef core     fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef substrate fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    subgraph IFACE["  Interfaces  "]
        SC[Scribe\nProfessional Workspace]
        SO[Sortio\nPatient Sovereignty]
        CC[CloudClinic\nService Operations]
    end

    subgraph GOS_L["  GOS — Governed Operational Spec  "]
        GOS[Compiler · Validator · Lifecycle\nRuntime Mediation · Bundle Binding]
    end

    subgraph RT["  Runtimes  "]
        AACI[AACI Runtime\nSession · First Slice · Subagents]
        ASYNC[Async Runtime\nJobs · Retry · Backpressure]
        UA[User-Agent Runtime\nPatient-Facing Interactions]
    end

    subgraph CORE_L["  Core Law  "]
        ID[Identity &\nHabilitation]
        CO[Consent &\nFinalidade]
        PR[Provenance &\nAudit]
        GA[Gate &\nFinalization]
    end

    subgraph SUB["  Material Substrate  "]
        ST[Storage · SQL · File-Backed]
        NE[Mesh · VPN · Network]
    end

    SC & SO & CC -->|mediated surfaces| GOS
    GOS -->|runtime binding| AACI & ASYNC & UA
    AACI & ASYNC & UA -->|lawful-context required| ID & CO & PR & GA
    ID & CO & PR & GA --> ST & NE

    class SC,SO,CC iface
    class GOS gos
    class AACI,ASYNC,UA runtime
    class ID,CO,PR,GA core
    class ST,NE substrate
```

### First Slice — Executable Orchestration Path

The current scaffold-level executable path, consumed by `HealthOSCLI` and `HealthOSScribeApp`.

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f0f9ff', 'primaryBorderColor': '#bae6fd', 'primaryTextColor': '#0c4a6e', 'edgeLabelBackground': '#fafafa', 'fontFamily': 'ui-sans-serif, system-ui, -apple-system'}}}%%
flowchart LR
    classDef govern   fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef capture  fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos      fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef draft    fill:#ede9fe,stroke:#a78bfa,stroke-width:2px,color:#3b0764
    classDef gate     fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843
    classDef final    fill:#d1fae5,stroke:#34d399,stroke-width:2px,color:#065f46
    classDef terminal fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#475569

    HAB[Habilitation\nValidate]:::govern
    CON[Consent\nValidate]:::govern
    SES[Session\nStart]:::capture
    CAP[Capture\nAudio · Text]:::capture
    TRA[Transcription\nready · degraded · unavailable]:::capture
    GOS_ACT[GOS Activation\nBundle · Binding Plan]:::gos
    RET[Retrieval\nContext Package]:::capture
    SOAP[SOAP Draft\nCompose]:::draft
    DER[Referral · Prescription\nDerived Drafts]:::draft
    GR[Gate Request]:::gate
    GV[Gate Resolve\napproved · rejected]:::gate
    FIN[Final SOAP\n+ Provenance]:::final
    STOP([withheld]):::terminal

    HAB --> CON --> SES --> CAP --> TRA --> GOS_ACT --> RET --> SOAP --> DER --> GR --> GV
    GV -->|approved| FIN
    GV -->|rejected| STOP
```

## 📋 Current repository posture (April 2026)

This repository is in **controlled implementation / scaffold hardening**:
- multiple cross-language contracts (Swift/TS/JSON Schema/SQL) are executable
- Swift governance and boundary suites are present and runnable
- TypeScript workspace builds; GOS tooling has automated tests
- first-slice execution exists (CLI + minimal Scribe validation surface)

These are HealthOS components at varied maturity levels. Scaffold-stage components are not a separate product and are not placeholders for another future repository; their maturity must simply be described honestly.

It is **not**:
- a production-ready product
- a complete EHR
- a final UI delivery of Scribe/Sortio/CloudClinic
- a real regulatory-signature/interoperability integration
- a real semantic retrieval stack with embeddings/vector index
- a real external provider deployment (LM/STT/embedding remain scaffold/stub posture)

## 📊 Current Maturity Dashboard

| Layer | Status | Focus |
| :--- | :--- | :--- |
| **Core Law** | ✅ Implemented Seam | Invariant-based governance |
| **GOS Layer** | ✅ Operational Path | Stabilization & Binding |
| **AACI First Slice** | 🚧 Scaffold Hardening | Boundary enforcement + GOS-mediated derived drafts |
| **Provider/ML** | ⚠️ Stub/Contract | Deterministic safety |
| **Apps/UI** | 🧩 Contract-First | Minimal validation surface |

## 🚀 Quick Start

```bash
make bootstrap
make swift-build
make swift-test
make ts-build
make ts-test
make python-check
make validate-docs
make validate-schemas
make validate-contracts
make validate-all
```

Xcode entrypoint:

- open `HealthOS.xcworkspace` from repository root
- the workspace resolves the canonical Swift package at `swift/Package.swift`

Optional local smoke path:

```bash
make smoke-cli
make smoke-scribe
```

## 🧠 Where agents should start

Read in order before coding:
1. `README.md`
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
14. relevant `docs/execution/todo/*.md`
15. matching `docs/execution/skills/*.md`

## 📂 Repository map (real, current)

- `docs/architecture/` — canonical architecture/doctrine docs (including GOS, app-boundary, regulatory, and cross-app waves)
- `docs/execution/` — governed execution protocol, status tracking, coverage, invariants, TODOs, maturity/handoff
- `schemas/` — JSON Schema contracts/entities and GOS schemas
- `swift/` — Core, AACI, Providers, first-slice support, CLI, minimal Scribe app, XCTest suites
- `ts/` — workspace packages (`contracts`, `runtime-async`, `runtime-user-agent`, `mcp-local`, `healthos-gos-tooling`)
- `python/` — offline ML governance scaffolds only
- `sql/migrations/001_init.sql` — canonical metadata schema scaffold
- `ops/` and `scripts/` — local operational scaffolding, bootstrap, network and backup notes
- `apps/` — interface boundary scaffolds/documentation

## 🤖 HealthOS Xcode Agent (engineering agent — in rework)

The engineering agent scaffold lives at `ts/packages/healthos-steward/` with persistent memory/session templates under `.healthos-steward/`.

The steward is currently in a **hard-reset baseline** (`status`, `runtime`, `session` commands only) and is being rearchitected as the **HealthOS Xcode Agent** — a workspace-aware engineering agent with conversation surfaces, session continuity, tool-mediated inspection/editing, and Xcode-native intelligence. See `docs/architecture/45-healthos-xcode-agent.md` for the target architecture and `docs/execution/17-healthos-xcode-agent-migration-plan.md` for the migration plan.

Current minimal baseline:

```bash
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward runtime
cd ts && npx --yes --workspace @healthos/steward healthos-steward session
```

*Note: Canonical truth resides in `docs/` and project manifests. Steward memory is derived operational state. The agent is non-clinical, non-constitutional, and non-authorizing.*

## Canonical hierarchy

```text
Material substrate
  └─ host, storage, private network/mesh, backups
HealthOS Core
  └─ law/governance (identity, consent, habilitation, storage, provenance, gate, audit)
Governed Operational Spec (GOS)
  └─ operational translation layer subordinate to Core
HealthOS Runtimes
  ├─ AACI runtime
  ├─ Async runtime
  └─ User-Agent runtime
Actors / Agents
  └─ bounded actors and role-governed agents
Apps / Interfaces
  ├─ Scribe (professional workspace)
  ├─ Sortio (patient sovereignty)
  └─ CloudClinic (service operations)
Artifacts / Effects
  └─ drafts, gate records, final artifacts, provenance/audit traces
```

## Maturity snapshot by layer

Use `docs/execution/11-current-maturity-map.md` for full detail. Short view:
- Core law + storage governance: **implemented seam / tested operational path (local scaffold)**
- GOS authoring/compiler/lifecycle: **implemented seam / tested operational path (scaffold hardening)**
- AACI + first slice orchestration: **implemented seam / tested operational path (bounded scope)**

## Scaffold/foundation phase closure references

For final scaffold/foundation phase closure auditing and handoff discipline, use:
- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`
- `docs/execution/16-next-10-actions-plan.md`
