# Skill: service operations / CloudClinic

## When to use
CloudClinic service operations context, queue/worklist boundary, membership/habilitation mediation.

## Required reading
`HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`, `13-cloudclinic.md`, `25-cloudclinic-screen-contracts.md`, `41-service-operations-cloudclinic-core-contracts.md`.

## Invariants
Queue/worklist is not authorization; admin role not professional authority.

## Main files
`HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ServiceOperationsContracts.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/contracts/service-operations-cloudclinic.schema.json`.

## Expected tests
`cd HealthOS && swift test --filter ServiceOperationsGovernanceTests`.

## Absolute restrictions
No direct clinical finalization path from app.
No APP-012-style wiring until the CloudClinic Custom and consumed mediated surfaces are ready.

## Definition of done
Service context/membership/document/gate contracts stay Core-mediated.

## What not to do
No RBAC completeness claims beyond implemented scaffold.
