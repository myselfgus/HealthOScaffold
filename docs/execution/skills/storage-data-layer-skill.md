# Skill: storage data-layer governance

## When to use
Storage contracts, lawfulContext validation, data-layer routing, reidentification guards.

## Required reading
`docs/architecture/05-data-layers.md`, `07-storage-and-sql.md`, `21-object-integrity-strategy.md`.

## Invariants
Direct identifiers separated; reidentification is sensitive; lawfulContext required for governed access.

## Main files
`swift/Sources/HealthOSCore/StorageContracts.swift`, `ReidentificationGovernance.swift`, `sql/migrations/001_init.sql`.

## Expected tests
`cd swift && swift test --filter Storage` (or full suite).

## Absolute restrictions
No raw CPF in operational payloads; no silent integrity repair.

## Definition of done
Layer-sensitive checks covered by tests and docs/coverage updated.

## What not to do
No app-driven storage law.
