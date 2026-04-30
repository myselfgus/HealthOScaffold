# GOS stabilization handoff pack

## Purpose

This document is the explicit handoff pack for coding agents continuing GOS-related work in the HealthOScaffold repository, the HealthOS construction repository.

HealthOScaffold is the historical repository name and initial scaffolding phase for HealthOS. All implemented architecture, contracts, runtimes, apps, tests, and documentation in this repository are part of HealthOS unless explicitly marked experimental or deprecated. "Scaffold" describes maturity, not project identity.

Read this before changing GOS, AACI, bundle lifecycle, or first-slice mediation paths.

## What is already closed

The repository already has:
- GOS as a named architectural layer between HealthOS Core and runtimes
- ADR and architecture docs for GOS purpose, authoring, runtime binding, lifecycle, and app consumption
- canonical schema, authoring schema, and bundle-manifest schema
- YAML authoring workspace and a canonical `aaci.first-slice` authoring spec
- TypeScript GOS tooling for parse, canonicalize, schema-validate, cross-validate, compile, and bundle
- Swift contracts for bundle manifests, compiled bundles, runtime binding plans, loader, and registry
- minimal-functional file-backed registry/loader
- AACI activation seam
- first-slice runtime path that optionally consumes an active `aaci.first-slice` bundle and mediates persisted draft outputs, metadata, events, and provenance
- bootstrap bundle assets for `aaci.first-slice`

## What must not be broken

Do not break these invariants:
- HealthOS Core remains sovereign
- GOS remains subordinate to Core
- apps do not become sovereign interpreters of GOS
- no regulated effectuation occurs without human gate
- GOS may shape work, but not replace consent, habilitation, finality, or gate law
- bootstrap bundle logic must remain compatible with the file-backed registry/loader

## What is still scaffold-level / incomplete

Still incomplete:
- richer reviewed-state promotion workflow
- stronger registry hardening
- stronger compile provenance richness beyond current source hash/report
- deeper execution-time adoption inside AACI subagent paths
- local build validation of the latest GitHub-side changes

## Safe next tasks for coding agents

Safe tasks:
- harden local build/compile correctness in Swift and TypeScript
- add reviewed-state promotion commands/services
- improve bundle registry conflict handling
- enrich provenance for bundle activation and promotion
- deepen GOS influence inside AACI subagent execution paths
- add tests for GOS tooling and file-backed registry/loader

## Unsafe tasks unless explicitly requested

Avoid without explicit instruction:
- moving law into apps
- making GOS a programming language or second constitution
- bypassing gate because a workflow spec says so
- widening bundle load rules without lifecycle discipline
- replacing the first-slice executable path wholesale

## Critical files to read first

Architecture:
- `docs/architecture/29-governed-operational-spec.md`
- `docs/architecture/30-gos-authoring-and-compiler.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/architecture/32-gos-bundles-and-lifecycle.md`
- `docs/architecture/33-gos-app-consumption-patterns.md`
- `docs/architecture/34-gos-review-and-activation-policy.md`

Execution / tracking:
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/todo/gos-and-compilers.md`

Runtime / tooling:
- `gos/specs/aaci.first-slice.gos.yaml`
- `ts/packages/healthos-gos-tooling/`
- `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift`
- `swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift`
- `swift/Sources/HealthOSAACI/GOSBindings.swift`
- `swift/Sources/HealthOSAACI/GOSRuntimeActivation.swift`
- `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`
- `bootstrap/gos/system/gos/`

## Immediate recommended order

1. validate local build and fix type/import drift
2. validate bootstrap bundle end-to-end with loader + AACI activation
3. add reviewed-state promotion path
4. deepen AACI runtime use of loaded bundle semantics
5. add tests and hardening

## Definition of a good continuation

A good continuation:
- preserves the ontology
- improves operational rigor
- reduces ambiguity
- strengthens runtime truth without inflating app responsibility
- leaves a clearer system than it found
