# Skill: provider governance

## When to use
Provider routing/capability/model registry/fine-tuning governance updates.

## Required reading
`docs/architecture/16-providers-and-ml.md`, `27-provider-threshold-policy.md`, `docs/execution/10-invariant-matrix.md`.

## Invariants
Provider choice is not ontology; remote fallback fail-closed for sensitive data.

## Main files
`swift/Sources/HealthOSProviders/`, `swift/Tests/HealthOSTests/ProviderGovernanceTests.swift`.

## Expected tests
`cd swift && swift test --filter ProviderGovernanceTests`.

## Absolute restrictions
No claims of real external provider integration when stubbed.

## Definition of done
Capability/policy/test/docs all aligned.

## What not to do
No fake benchmark victory or production-readiness statement.
