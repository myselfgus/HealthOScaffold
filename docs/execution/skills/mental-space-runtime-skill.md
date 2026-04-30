# Skill: Mental Space Runtime

## When to use

Mental Space Runtime artifacts, transcript normalization, ASL, VDLP, GEM, clinician insight surfaces, and staged cognitive/linguistic derived artifacts.

## Required reading

`docs/architecture/49-mental-space-runtime.md`, `09-aaci.md`, `16-providers-and-ml.md`, `20-runtime-operational-policy.md`, `26-operator-observability-contract.md`, and `docs/execution/10-invariant-matrix.md`.

## Invariants

Mental Space artifacts are derived and gated. They do not diagnose, authorize clinical action, replace consent/habilitation/finality/gate law, or become provider/regulatory effectuation.

## Main files

`swift/Sources/HealthOSCore/MentalSpaceRuntime.swift`, `swift/Sources/HealthOSAACI/AACI.swift`, `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`, `swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift`, `ts/packages/contracts/src/index.ts`, `schemas/contracts/mental-space-artifact.schema.json`.

## Expected tests

`cd swift && swift test --filter MentalSpaceRuntimeTests`, `cd swift && swift test --filter AsyncRuntimeGovernanceTests`, `cd ts && npm run build`, `make validate-schemas`, `make validate-docs`.

## Absolute restrictions

No remote normalization by default. No stub output persisted as real normalized transcript. No raw prompts, raw artifact JSON, direct identifiers, or ungated diagnostic claims in app-facing surfaces.

## Definition of done

Stage dependencies fail closed, provider posture is explicit, derived artifacts carry provenance and limitations, and tracking docs are updated.

## What not to do

Do not collapse Mental Space Runtime into generic async runtime, GOS, AACI, or Core law.
