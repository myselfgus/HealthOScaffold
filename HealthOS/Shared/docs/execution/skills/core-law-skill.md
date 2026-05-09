# Skill: core law

## When to use
Any task touching consent, habilitation, gate, finalization, provenance, lawfulContext, or constitutional boundaries.

## Required reading
`HealthOS/Shared/docs/architecture/01-overview.md`, `06-core-services.md`, `39-regulatory-interoperability-signature-emergency-governance.md`, `HealthOS/Shared/docs/execution/10-invariant-matrix.md`.

## Invariants
Core sovereign; gate required for regulatory final effects; draft != final; fail-closed lawfulContext.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift`, `GateContracts.swift`, `FirstSliceServices.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/*gate*`.

## Expected tests
`cd HealthOS && swift test --filter Governance` (or full `swift test`).

## Absolute restrictions
Do not move law into app/AACI/GOS; do not claim production regulatory integration.

## Definition of done
Contracts + tests + tracking updated with honest maturity level.

## What not to do
No fictitious clinical examples, no bypass shortcuts.
