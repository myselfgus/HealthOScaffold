# HealthOScaffold

HealthOS is the full platform. AACI is one runtime inside HealthOS.

This scaffold establishes a single-node, Apple-Silicon-first architecture for a sovereign health operations environment with:
- a canonical core for identity, consent, habilitation, provenance, gates, and storage
- an AACI runtime for ambient, agentic, bureaucratic automation
- an async runtime for deferred jobs and reprocessing
- a user-agent runtime for patient/user interactions
- three interface apps: Scribe, Sortio, and CloudClinic
- a private-drive/private-cloud behavior built from canonical directories plus governance metadata

## Canonical hierarchy

```text
Material substrate
  └─ Apple Silicon host(s), macOS, disk, networking, backups
HealthOS Core
  └─ identity, storage, governance, schemas, actor/agent/runtime contracts
HealthOS Runtimes
  ├─ AACI Runtime
  ├─ Async Runtime
  └─ User-Agent Runtime
Actors / Agents
  ├─ professional/user agents
  └─ AACI subagents
Apps / Interfaces
  ├─ Scribe
  ├─ Sortio
  └─ CloudClinic
Artifacts / Effects
  ├─ transcripts
  ├─ drafts
  ├─ gate requests/resolutions
  ├─ audit/provenance records
  └─ derived AI outputs
```

## Stack

- Swift: core domain libraries, local runtime integration, providers, app-facing contracts
- TypeScript: async/runtime services, orchestration, local HTTP APIs, MCP adapters
- Python: offline ML/fine-tuning pipelines only
- PostgreSQL: canonical metadata and governance store
- Filesystem: canonical encrypted/pseudonymized object/document store
- launchd: local service supervision
- mesh/VPN: private node-to-node and device-to-node connectivity

## What this scaffold is

A deliberate foundation for the whole HealthOS system.

## What this scaffold is not

- not a full product implementation
- not a zero-knowledge vault
- not a complete EHR
- not a finished multi-node cloud
- not a clinically autonomous system

## First vertical slice

This scaffold is arranged to support the first end-to-end slice:

1. professional starts a service session
2. habilitation is validated
3. patient is selected
4. session input is captured
5. transcription is produced
6. context is retrieved
7. SOAP draft is composed
8. human gate is presented
9. approval/rejection is recorded
10. provenance is appended
11. artifacts are persisted

## Repository guide

- `docs/architecture`: canonical definitions and system design
- `docs/adr`: architectural decision records
- `schemas`: JSON Schemas for core entities and contracts
- `sql/migrations`: canonical DB migrations
- `swift`: Swift packages for core/runtime/providers/app contracts
- `ts`: TypeScript workspace for async and user-agent services
- `python`: ML/fine-tuning scaffolds
- `apps`: interface app scaffolds
- `scripts`: local bootstrap and dev scripts
- `ops`: launchd, network, backup, health checks

## Quick start

```bash
./scripts/bootstrap-local.sh
```

Then inspect:
- `docs/architecture/01-overview.md`
- `docs/architecture/02-modules.md`
- `docs/architecture/03-first-slice.md`
