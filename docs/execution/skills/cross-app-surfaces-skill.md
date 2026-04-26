# Skill: cross-app shared surfaces

## When to use
Shared envelope/safe refs/notifications across Scribe, Sortio, CloudClinic.

## Required reading
`docs/architecture/43-cross-app-coordination-shared-surfaces.md`, `19-interface-doctrine.md`.

## Invariants
Envelope is never legal authorization; safe refs never carry raw direct identifiers.

## Main files
`swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift`, `schemas/contracts/cross-app-coordination-shared-surfaces.schema.json`.

## Expected tests
`cd swift && swift test --filter CrossAppCoordinationContractsTests`.

## Absolute restrictions
No cross-app navigation ref granting implicit data access.

## Definition of done
Role/app mismatch and payload leak denials are tested.

## What not to do
No raw compiled spec payload in app envelope.
