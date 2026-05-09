# Skill: cross-Stage shared surfaces

## When to use
Shared envelope/safe refs/notifications across Stages such as Scribe, Veridia, CloudClinic, and future governed application consumers.

## Required reading
`HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`, `43-cross-app-coordination-shared-surfaces.md`, `19-interface-doctrine.md`.

## Invariants
Envelope is never legal authorization; safe refs never carry raw direct identifiers.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/cross-app-coordination-shared-surfaces.schema.json`.

## Expected tests
`cd HealthOS && swift test --filter CrossAppCoordinationContractsTests`.

## Absolute restrictions
No cross-Stage navigation ref granting implicit data access.

## Definition of done
Role/Stage mismatch and payload leak denials are tested.

## What not to do
No raw compiled spec payload in Stage-facing envelope.
