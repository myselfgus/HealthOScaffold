# Skill: user-agent / Veridia

## When to use
Veridia boundaries, patient health identity app, patient agent interaction, Core-mediated identity/access/consent/export surfaces.

## Required reading
`docs/architecture/12-veridia.md`, `docs/architecture/24-veridia-screen-contracts.md`, `docs/architecture/43-cross-app-coordination-shared-surfaces.md`.

## Invariants
User-Agent Runtime cannot perform clinical/regulatory acts; Veridia app surfaces must be app-safe. Veridia is not Core law, not the User-Agent Runtime, and has no clinical authority.

## Main files
`swift/Sources/HealthOSCore/UserSovereigntyContracts.swift`, `ts/packages/runtime-user-agent/src/index.ts`, `schemas/contracts/user-agent-patient-identity-veridia.schema.json`.

## Expected tests
`cd swift && swift test --filter UserSovereigntyGovernanceTests`.

## Absolute restrictions
- No raw CPF/reidentification/storage payload leaks.
- No clinical/regulatory acts.
- No final UI implementation claim.
- Do not describe Veridia as Core law, GOS, or the User-Agent Runtime.

## Definition of done
Boundary checks and docs reflect contract-only vs runtime maturity truth. Veridia is defined as the patient health identity app throughout.

## What not to do
No chatbot/product claims. No "patient sovereignty interface" as primary definition. No Sortio naming in new code or docs.
