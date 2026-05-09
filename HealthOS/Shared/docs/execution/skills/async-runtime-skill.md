# Skill: async runtime

## When to use
Async job contract, retry/backpressure, idempotency, dead-letter, async observability.

## Required reading
`HealthOS/Shared/docs/architecture/20-runtime-operational-policy.md`, `26-operator-observability-contract.md`.

## Invariants
Sensitive async jobs require lawfulContext and fail-closed policy checks.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/AsyncRuntimeJobs.swift`, `HealthOS/Constructor/ts/packages/runtime-async/src/index.ts`.

## Expected tests
`cd HealthOS && swift test --filter AsyncRuntimeGovernanceTests`, `cd HealthOS/Constructor/ts && npm run build`.

## Absolute restrictions
No duplicated sensitive side effects on retry.

## Definition of done
Lifecycle + denial paths covered and tracked.

## What not to do
No distributed-runtime maturity claims.
