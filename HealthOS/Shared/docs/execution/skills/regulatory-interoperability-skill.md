# Skill: regulatory/interoperability/signature/emergency

## When to use
Regulatory audit, emergency access, signature scaffold, interoperability package governance.

## Required reading
`HealthOS/Shared/docs/architecture/39-regulatory-interoperability-signature-emergency-governance.md`, `HealthOS/Shared/docs/execution/10-invariant-matrix.md`.

## Invariants
Gate and legal lineage required; placeholder integrations must be explicit.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/regulatory-interoperability-signature-emergency-governance.schema.json`.

## Expected tests
`cd HealthOS && swift test --filter RegulatoryGovernanceTests`.

## Absolute restrictions
No false claim of ICP-Brasil/RNDS/TISS/FHIR production integration.

## Definition of done
Fail-closed guards + test evidence + honest wording.

## What not to do
No simulated legal-valid signature claims.
