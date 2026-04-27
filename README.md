# HealthOScaffold

HealthOS is a sovereign computational environment for health data and clinical operations. This repository is in **controlled implementation / scaffold hardening** phase, establishing foundational architecture.

HealthOS is the full platform. **AACI is one runtime inside HealthOS**. **GOS is a governed operational layer subordinate to Core law**. **Scribe, Sortio, and CloudClinic are app/interfaces that consume mediated surfaces; they never define constitutional law**.

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

## 📋 Current repository posture (April 2026)

This repository is in **controlled implementation / scaffold hardening**:
- multiple cross-language contracts (Swift/TS/JSON Schema/SQL) are executable
- Swift governance and boundary suites are present and runnable
- TypeScript workspace builds; GOS tooling has automated tests
- first-slice execution exists (CLI + minimal Scribe validation surface)

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

Optional local smoke path:

```bash
make smoke-cli
make smoke-scribe
```

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

## ⚙️ Provider Orchestration (Model-Agnostic)

`@healthos/steward` supports optional provider adapters (OpenAI, Anthropic, xAI, disabled) with secure defaults:
- providers disabled by default | dry-run first behavior
- no secrets committed | explicit `--post-comment` required for PR comment write

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

## Scaffold RC closure references

For final scaffold-closure auditing and handoff discipline, use:
- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`
- `docs/execution/16-next-10-actions-plan.md`
EOF
