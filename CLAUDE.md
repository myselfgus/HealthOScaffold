# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## What this repository is

HealthOScaffold is the scaffold for **HealthOS**, a sovereign computational environment for health operations. It is deliberately a *scaffold* (contracts, schemas, docs, executable spine) — not a product. The architecture is designed around a canonical hierarchy: Material substrate → HealthOS Core → Runtimes → Actors/Agents → Apps/Interfaces → Artifacts/Effects.

**Critical distinction (do not collapse):**
- HealthOS is the whole platform.
- **AACI** (Ambient-Agentic Clinical Intelligence) is *one runtime* inside HealthOS. Never treat AACI as the whole system.
- **Scribe**, **Sortio**, **CloudClinic** are apps/interfaces over HealthOS. They *consume* core laws; they never define them.

## Execution discipline (read before coding)

This repository has an explicit governed execution layer. Before any coding task, read in order:

1. `README.md`
2. `docs/execution/README.md`
3. `docs/execution/00-master-plan.md`
4. `docs/execution/01-agent-operating-protocol.md`
5. `docs/execution/02-status-and-tracking.md` (current phase, in-progress, blockers)
6. relevant `docs/execution/todo/*.md`
7. relevant `docs/architecture/*.md`
8. matching skill in `docs/execution/skills/`

Task selection order (from `01-agent-operating-protocol.md`):
1. unfinished task in current phase marked `READY`
2. blocking task marked `BLOCKER`
3. contract/documentation task that unblocks coding
4. tests/validation for a just-finished task

Never jump to a later-phase task because it is easier. Never code around a missing dependency — record the block.

After completing a work unit, **always** update `docs/execution/02-status-and-tracking.md` and the matching `todo/` file.

## Non-negotiable architectural invariants

These come from `docs/execution/04-ai-context-bundle.md` and `01-agent-operating-protocol.md`. Violating any of them is an escalation, not a judgment call.

- **Core before apps.** App-layer code must never compensate for undefined core law.
- **Gate before regulatory effects.** AACI never finalizes a health act. Anything regulatory stays a *draft* until a `GateResolution` with `.approved` is recorded.
- **Consent/habilitation before bounded retrieval.** Professional action requires validated habilitation; patient data access requires a matching `Consentimento` with `finalidade`.
- **Provenance is append-only.** Enforced at the DB layer (`proveniencia_no_update`/`_no_delete` rules in `sql/migrations/001_init.sql`). Never bypass.
- **Direct-identifier separation.** Direct identifiers (CPF, name, contact) live encrypted in `identidades_civis`; operational content uses `cpf_hash`/`civil_token` anchors on `usuarios`. Do not mix them in casual operational payloads.
- **Owner invariant on `dados`.** An object belongs to *one* `usuario` XOR *one* `servico`, never both (enforced by CHECK constraint).
- **Single-node correctness before mesh.** Do not hardcode loopback/local assumptions into ontology, but also do not introduce remote/public exposure by default.
- **No provider-specific assumptions in core contracts.** Provider choice is not ontology.

## Canonical slice (the reference flow)

The first vertical slice is implemented end-to-end in `swift/Sources/HealthOSCLI/FirstSliceRunner.swift`. When designing new work, this is the reference for the *ordering* and *evidence* that must be preserved:

habilitation validate → consent validate → session start → capture → transcript (provenance) → context retrieval (provenance) → SOAP draft (provenance) → gate request → gate resolve → (if approved) final artifact (provenance).

Every AACI-produced artifact has a matching `ProvenanceRecord` appended. Every storage write has a matching `storage.audit` with a `lawfulContext` map (`actorRole`, `scope`, `serviceId`, `patientUserId`, `habilitationId`, `finalidade`, `sessionId`).

## Repository layout (by concern)

- `docs/architecture/` — canonical system definitions (numbered 01–28). Start with 01-overview, 02-modules, 03-first-slice.
- `docs/adr/` — architectural decision records. New ontology-affecting decisions get a new ADR.
- `docs/execution/` — master plan, status, todos, phases, skills. The governing layer for AI work.
- `schemas/entities/` + `schemas/contracts/` — JSON Schemas for entities (usuario, servico, habilitacao, consentimento, …) and contracts (agent-message, gate-request, artifact-draft, …). Must match Swift/TS types and SQL columns.
- `sql/migrations/001_init.sql` — canonical Postgres metadata schema. Broad by design; sections are labeled 01–10.
- `swift/` — `HealthOSCore` (entities, contracts, storage, provenance, gates, directory layout), `HealthOSProviders` (provider protocols + stubs), `HealthOSAACI` (orchestrator), `HealthOSCLI` (executable slice runner). macOS 14+, Swift 6 tools.
- `ts/packages/` — pnpm/npm workspace: `contracts` (shared TS types mirroring Swift/schema contracts), `runtime-async`, `runtime-user-agent`, `mcp-local`. Each package builds via `tsc`.
- `python/healthos_ml/` — offline ML/fine-tuning only (dataset prep, eval, adapter jobs). Not an online runtime.
- `apps/` — scaffolds only for Scribe/Sortio/CloudClinic/shared-ui (READMEs describing boundaries).
- `ops/` — launchd plist examples, network/ports policy, backup notes, Tailscale ACL example.
- `scripts/bootstrap-local.sh` — creates `runtime-data/Users/Shared/HealthOS/{system,users,services,agents,runtimes/*,models/*,network/*,backups,logs}`. The CLI expects this tree.
- `runtime-data/` — local data root; gitignored. Populated by bootstrap + CLI.
- `templates/user-structure.txt`, `templates/service-structure.txt` — canonical per-user / per-service subdirectory layout (mirrored in `DirectoryLayout.swift`).

## Common commands

From `Makefile` and package configs:

```bash
make bootstrap        # run scripts/bootstrap-local.sh to create runtime-data tree
make swift-build      # cd swift && swift build
make ts-build         # cd ts && npm install && npm run build (workspaces)
make sql-print        # print sql/migrations/001_init.sql
make tree             # list files up to depth 4
```

Direct variants:

```bash
# Swift
cd swift && swift build
cd swift && swift run HealthOSCLI   # runs the first-slice end-to-end against runtime-data/

# TypeScript (npm workspaces; pnpm-workspace.yaml also declares ts/packages/*)
cd ts && npm install && npm run build
cd ts/packages/<pkg> && npx tsc -p tsconfig.json

# Postgres
psql -f sql/migrations/001_init.sql
```

There is no configured test runner, linter, or CI yet. If you add tests, wire them through `swift test` / per-package TS scripts and update `Makefile` + status tracking.

## Cross-language contract discipline

The same contract lives in three places and must stay aligned:

- **JSON Schema** in `schemas/` (source of truth for cross-language validation)
- **Swift** types in `swift/Sources/HealthOSCore/` (Portuguese domain names: `Usuario`, `Servico`, `SessaoTrabalho`, `Consentimento`, `Habilitacao`, `Proveniencia`)
- **TypeScript** types in `ts/packages/contracts/src/index.ts` (same shape, English camelCase)
- **SQL** columns in `sql/migrations/001_init.sql` (Portuguese table/column names: `usuarios`, `servicos`, `sessoes_trabalho`, `consentimentos`, `habilitacoes`, `proveniencia`)

When changing any one of these, update all four *in the same work unit* and record the ontology impact in ADR/docs if it affects meaning. Runtime lifecycle states and failure kinds are defined once (`CanonicalTypes.swift`, `contracts/src/index.ts`, `docs/architecture/08-runtime-actor-agent-model.md`) and must match exactly.

## Naming conventions worth knowing

- Domain entities use **Portuguese** names (from the Brazilian civil/health context): `Usuario`, `Servico`, `SessaoTrabalho`, `Habilitacao`, `Consentimento`, `Proveniencia`, `RegistroProfissional`, `MembroServico`, `Finalidade`.
- `cpf_hash` / `civil_token` are the pseudonymous anchors; raw CPF lives encrypted in `identidades_civis.cpf_cifrado`.
- `tempo_usuario` vs `tempo_sistema`: user-time (event time) vs system-time (insertion time). Both are first-class in sessions/data/provenance.
- Storage layers on `dados.data_layer` and on `StoragePutRequest.layer`: `directIdentifiers`, `operationalContent`, `governanceMetadata`, `derivedArtifacts`, `reidentificationMapping` (see `docs/architecture/05-data-layers.md`).
- Agent permission capabilities are colon-separated strings: `session:read`, `capture:write`, `patient:context:read`, `consent:check`, `gate:request`.

## Commit and change discipline

From `docs/execution/01-agent-operating-protocol.md`:

- One concept or one vertical work chunk per commit.
- Documentation and contract changes may accompany the code they govern — prefer that to separating them.
- If a change affects ontology, update ADR/docs in the *same* work unit.
- If you find a contradiction between docs/code, app/core law, or provider/privacy — **stop local improvisation**, record the contradiction, propose the smallest lawful correction.

## Self-review questions before declaring work done

From `docs/execution/05-ai-coding-behavior.md`:

- Did I accidentally move law into UI?
- Did I accidentally let AACI act as clinician (finalize vs draft)?
- Did I erase the distinction between direct identifiers and operational content?
- Did I bypass consent / habilitation / provenance / gate?
- Did I make future mesh expansion harder by hardcoding local assumptions into ontology?
