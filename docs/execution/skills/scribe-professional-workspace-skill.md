# Skill: Scribe professional workspace

## When to use
Scribe workspace/session contracts, first-slice Boundary, draft-gate-finalization view discipline.

## Required reading
`docs/architecture/50-app-layer-boundary-and-reference-apps.md`, `11-scribe.md`, `23-scribe-screen-contracts.md`, `28-first-slice-executable-path.md`.

## Invariants
Scribe consumes mediated state only; gate and finalization remain Core-controlled.

## Main files
`swift/Sources/HealthOSCore/ScribeProfessionalWorkspaceContracts.swift`, `ScribeFirstSliceBridge.swift`, `swift/Sources/HealthOSScribeApp/`.

## Expected tests
`cd swift && swift test --filter ScribeProfessionalWorkspaceContractsTests`; smoke test when app-facing change occurs.

## Absolute restrictions
No UI-owned consent/habilitation/finality decisions.
No new Scribe wiring unless the consumed mediated surface is implemented and stable.

## Definition of done
Stage-facing contract remains honest about degraded/unavailable states.

## What not to do
No “final UI complete” claims.
