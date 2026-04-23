# ADR 0008: `lawfulContext` remains a flexible canonical map in v1

Status: Accepted

## Decision

For the scaffold and first implementation wave, `lawfulContext` remains a flexible map-based transport object rather than a rigid envelope schema.

## Why

- different access situations require different bounded keys
- single-node first implementation benefits from lower transport friction
- the platform already has core-law semantics anchored in consent, habilitation, finality, and owner scope
- premature rigidification would create churn before access paths stabilize

## Constraints

Flexible does not mean arbitrary.
The map must still use canonical keys where applicable, such as:
- `actorRole`
- `actorUserId`
- `serviceId`
- `patientUserId`
- `habilitationId`
- `consentBasis`
- `finalidade`
- `sessionId`
- `scope`
- `accessBasis`

## Consequence

- runtime and storage implementations may accept a map in v1
- documentation must provide lawful-context examples
- later versions may introduce a stricter envelope without changing core law

## Non-goal

This ADR does not weaken access law.
It only postpones strict transport typing for lawful-context payloads.
