# HealthOScaffold

HealthOS is a sovereign computational environment for health data and clinical operations. This repository is in **controlled implementation / scaffold hardening** phase, establishing foundational architecture.

## 🏗️ Canonical Architecture

HealthOS mediates all clinical acts through a strictly layered, governance-first fabric.

```mermaid
graph TD
    subgraph "Sovereign Fabric"
        subgraph "Interfaces"
            A[Scribe]
            B[Sortio]
            C[CloudClinic]
        end
        subgraph "Runtimes"
            D[AACI Runtime]
            E[Async Runtime]
            F[User-Agent Runtime]
        end
        subgraph "Core Law"
            G[Identity]
            H[Consent]
            I[Provenance/Audit]
            J[Gate]
        end
        subgraph "Material Substrate"
            K[Storage / SQL]
            L[Mesh/VPN]
        end
    end
    A & B & C --> D & E & F
    D & E & F --> G & H & I & J
    G & H & I & J --> K & L
```

## 📊 Current Maturity Dashboard

| Layer | Status | Focus |
| :--- | :--- | :--- |
| **Core Law** | ✅ Implemented Seam | Invariant-based governance |
| **GOS Layer** | ✅ Operational Path | Stabilization & Binding |
| **AACI First Slice** | 🚧 Scaffold Hardening | Boundary enforcement |
| **Provider/ML** | ⚠️ Stub/Contract | Deterministic safety |
| **Apps/UI** | 🧩 Contract-First | Minimal validation surface |

## 🚀 Quick Start

| Intent | Commands |
| :--- | :--- |
| **Bootstrap** | `make bootstrap` |
| **Build** | `make swift-build`, `make ts-build` |
| **Test** | `make swift-test`, `make ts-test` |
| **Validate** | `make validate-all` |
| **Smoke** | `make smoke-cli`, `make smoke-scribe` |

## 🧠 Developer Protocol (Read in Order)

1. `README.md`
2. `docs/execution/README.md`
3. `docs/execution/00-master-plan.md`
4. `docs/execution/02-status-and-tracking.md`
5. `docs/execution/11-current-maturity-map.md`
6. `docs/execution/skills/*.md`

## 🤖 Project Steward Agent

`@healthos/steward` automates repository diagnostics and planning.

```bash
cd ts && npx --yes --workspace @healthos/steward healthos-steward next-task
```

*Note: Canonical truth resides in `docs/` and project manifests. Steward memory is derived operational state.*

## 📂 Repository Structure

```mermaid
mindmap
  root((HealthOScaffold))
    docs
      architecture
      execution
    schemas
      contracts
    swift
      Core
      AACI
    ts
      steward
      runtime-async
      runtime-user-agent
    apps
      scribe
      sortio
      cloudclinic
    ops
    sql
```
