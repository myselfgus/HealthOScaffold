# Skill: backup/restore/retention/export

## When to use
Backup manifests, restore plans, retention/export governance, DR posture.

## Required reading
`HealthOS/Shared/docs/architecture/14-operations-runbook.md`, `26-operator-observability-contract.md`, `39-regulatory-interoperability-signature-emergency-governance.md`.

## Invariants
Infra operations never bypass lawfulContext or sensitive-layer governance.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/BackupGovernance.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/backup-restore-retention-export-dr-governance.schema.json`.

## Expected tests
`cd HealthOS && swift test --filter BackupGovernanceTests`.

## Absolute restrictions
No restore/export maturity claim without enforcement tests.

## Definition of done
Contracts + tests + status docs aligned.

## What not to do
No “backup exists = recoverable” assumption.
