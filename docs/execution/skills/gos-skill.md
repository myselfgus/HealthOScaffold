# Skill: GOS

## When to use
Tasks for GOS schema, compiler, lifecycle, activation, mediation, or runtime binding.

## Required reading
`docs/architecture/29-governed-operational-spec.md`, `30-gos-authoring-and-compiler.md`, `31-gos-runtime-binding.md`, `32-gos-bundles-and-lifecycle.md`, `34-gos-review-and-activation-policy.md`.

## Invariants
GOS is subordinate to Core; never authorizing; app consumes mediated state only.

## Main files
`gos/specs/`, `schemas/governed-operational-spec*.json`, `ts/packages/healthos-gos-tooling/`, `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift`.

## Expected tests
`cd ts && npm run --workspace @healthos/gos-tooling test`, `cd swift && swift test --filter GOS`.

## Absolute restrictions
No raw GOS-to-app law path, no lifecycle activation without policy/audit.

## Definition of done
Compiler/runtime/docs/trackers aligned; invariant matrix unchanged or improved.

## What not to do
Do not invent operational narratives as fake evidence.
