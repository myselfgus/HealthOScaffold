# Skill: user-agent / Sortio

## When to use
User sovereignty contracts, Sortio boundaries, patient-facing mediated surfaces.

## Required reading
`docs/architecture/12-sortio.md`, `24-sortio-screen-contracts.md`, `43-cross-app-coordination-shared-surfaces.md`.

## Invariants
User agent cannot perform clinical/regulatory acts; app surfaces must be app-safe.

## Main files
`swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`, `ts/packages/runtime-user-agent/src/index.ts`.

## Expected tests
`cd swift && swift test --filter UserSovereigntyGovernanceTests`.

## Absolute restrictions
No raw CPF/reidentification/storage payload leaks.

## Definition of done
Boundary checks and docs reflect contract-only vs runtime maturity truth.

## What not to do
No chatbot/product claims.
