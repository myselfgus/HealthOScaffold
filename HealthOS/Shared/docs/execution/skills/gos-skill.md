# Skill: GOS

## When to use
Tasks for GOS schema, compiler, lifecycle, activation, mediation, or runtime binding.

## Required reading
`HealthOS/Shared/docs/architecture/29-governed-operational-spec.md`, `30-gos-authoring-and-compiler.md`, `31-gos-runtime-binding.md`, `32-gos-bundles-and-lifecycle.md`, `34-gos-review-and-activation-policy.md`.

## Invariants
GOS is subordinate to Core; never authorizing; app consumes mediated state only.

## Main files
`HealthOS/Tier2-GOS-Runtimes/GOS/specs/`, `HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec*.json`, `HealthOS/Constructor/ts/packages/healthos-gos-tooling/`, `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift`.

## Expected tests
`cd HealthOS/Constructor/ts && npm run --workspace @healthos/gos-tooling test`, `cd HealthOS && swift test --filter GOS`.

## Absolute restrictions
No raw GOS-to-app law path, no lifecycle activation without policy/audit.

## Definition of done
Compiler/runtime/HealthOS/Shared/docs/trackers aligned; invariant matrix unchanged or improved.

## What not to do
Do not invent operational narratives as fake evidence.
