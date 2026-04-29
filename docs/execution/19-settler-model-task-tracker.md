# Settler model task tracker

## Repository identity note

HealthOScaffold is the historical repository name and construction repository for HealthOS.

Scaffold describes maturity or foundation phase. It does not describe a separate product identity.

## Current truth

The Settler model is doctrine-only.

No multiagent runtime is implemented.

No `healthos-mcp` server is implemented.

No Settler profiles are implemented as executable agents.

`docs/architecture/47-steward-settler-engineering-model.md` is the canonical architecture document for the model.

Repository-local documentation roots exist:
- `.healthos-settler/` for future Settler profiles and Settlement records
- `.healthos-territory/` for future Territory records

These roots are documentation scaffolds only.

## Streams

### ST-1 Settler profile instructions

Create profile docs or skill files for each initial Settler.

Define territory, invariants, forbidden moves, validation expectations, maturity, and handoff requirements for each profile.

Current scaffold root: `.healthos-settler/profiles/`.

### ST-2 Settlement record schema

Define a schema for a Settlement work unit.

The schema should capture objective, Territory, files in scope, invariants, restrictions, validation commands, done criteria, residual gaps, and handoff.

No execution is implemented in this stream.

Current scaffold root: `.healthos-settler/settlements/`.

### ST-2a Territory record scaffolds

Define Territory records as documentation-only repository domain records.

Current scaffold root: `.healthos-territory/territories/`.

### ST-3 healthos-mcp operations for Steward/Settlers

Expose repository-maintenance tools for Steward and Settlers.

Operations may include `validate-docs`, `validate-all`, `scan-status`, `next-task`, `read-gap-register`, `get-handoff`, `check-invariants`, `check-doc-drift`, and `generate-pr-review-draft`.

No clinical tools are exposed.

### ST-4 Deterministic CLI support

Add deterministic CLI support when the doctrine and record shape are ready.

Possible operations:
- list Settlements
- generate next Settlement
- validate Settlement scope
- produce handoff

The CLI remains deterministic. It does not implement multiagent intelligence by itself.

### ST-5 Xcode surface alignment

Expose Settler profiles to Steward for Xcode as instruction material.

Xcode Intelligence may use instructions and MCP where available.

Xcode Intelligence is not HealthOS Core, not a clinical runtime, and not a HealthOS-controlled law engine.

## Active queue

### ST-001 Create Settler architecture doctrine

Status: DONE in this work unit.

Outcome:
- created canonical architecture doc for Steward / Settler / Settlement / Territory model
- documented that the model is outside the HealthOS clinical/runtime hierarchy
- kept `healthos-mcp` as repository-maintenance MCP only

### ST-002 Create Settler profile instruction files

Status: TODO; documentation root scaffolded.

Goal:
- create instruction or skill artifacts for initial Settler profiles
- include territory, invariants, forbidden moves, validation expectations, and maturity

### ST-003 Define Settlement record schema

Status: TODO; documentation root scaffolded.

Goal:
- define the document/schema shape for bounded Settlement work units
- keep it non-executable until separately implemented

### ST-004 Define healthos-mcp Settler operations

Status: TODO.

Goal:
- define repository-maintenance MCP operations that support Steward and Settlers
- keep all operations outside the clinical/runtime hierarchy

### ST-005 Add deterministic CLI support for settlement records

Status: TODO.

Goal:
- add deterministic CLI support for listing, generating, validating, and handing off Settlement records
- do not implement multiagent intelligence in the CLI

### ST-006 Define Territory record files

Status: TODO; documentation root scaffolded.

Goal:
- define initial Territory records under `.healthos-territory/territories/`
- keep records subordinate to official docs
- include canonical docs, files in scope, invariants, validation commands, maturity, and known gaps

## Non-claims

No implementation exists yet.

No clinical agents are created.

No merge authority is granted.

No production readiness is claimed.

No `healthos-mcp` server is implemented.

No HealthOS runtime MCP server is implemented.

No Territory loader is implemented.
