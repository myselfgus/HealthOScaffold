# Skill: service operations / CloudClinic

## When to use
CloudClinic service operations context, queue/worklist boundary, membership/habilitation mediation.

## Required reading
`docs/architecture/13-cloudclinic.md`, `25-cloudclinic-screen-contracts.md`, `41-service-operations-cloudclinic-core-contracts.md`.

## Invariants
Queue/worklist is not authorization; admin role not professional authority.

## Main files
`swift/Sources/HealthOSCore/ServiceOperationsContracts.swift`, `schemas/contracts/service-operations-cloudclinic.schema.json`.

## Expected tests
`cd swift && swift test --filter ServiceOperationsGovernanceTests`.

## Absolute restrictions
No direct clinical finalization path from app.

## Definition of done
Service context/membership/document/gate contracts stay Core-mediated.

## What not to do
No RBAC completeness claims beyond implemented scaffold.
