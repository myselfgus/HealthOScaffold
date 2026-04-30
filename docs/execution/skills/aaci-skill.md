# Skill: AACI

## When to use
AACI orchestration, session state, capture/transcription, retrieval mediation, draft generation.

## Required reading
`docs/architecture/09-aaci.md`, `28-first-slice-executable-path.md`, `20-runtime-operational-policy.md`, `docs/execution/10-invariant-matrix.md`.

## Invariants
AACI assists; does not finalize clinical acts; draft-only before gate; degraded truth must be explicit.

## Main files
`swift/Sources/HealthOSAACI/`, `swift/Sources/HealthOSSessionRuntime/SessionRunner.swift`.

## Expected tests
`cd swift && swift test --filter AACI`, plus first-slice smoke if changed.

## Absolute restrictions
No fake transcription/provider/semantic claims.

## Definition of done
AACI path remains Core-mediated with provenance and boundary tests.

## What not to do
Do not bypass consent/habilitation/gate for ergonomics.
