# Skill: async runtime

## When to use
Async job contract, retry/backpressure, idempotency, dead-letter, async observability.

## Required reading
`docs/architecture/20-runtime-operational-policy.md`, `26-operator-observability-contract.md`.

## Invariants
Sensitive async jobs require lawfulContext and fail-closed policy checks.

## Main files
`swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift`, `ts/packages/runtime-async/src/index.ts`.

## Expected tests
`cd swift && swift test --filter AsyncRuntimeGovernanceTests`, `cd ts && npm run build`.

## Absolute restrictions
No duplicated sensitive side effects on retry.

## Definition of done
Lifecycle + denial paths covered and tracked.

## What not to do
No distributed-runtime maturity claims.
