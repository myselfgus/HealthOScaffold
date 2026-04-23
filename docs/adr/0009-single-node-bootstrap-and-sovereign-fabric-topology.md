# ADR 0009: Single-node bootstrap and sovereign fabric topology

Status: Accepted

## Decision

`single-node` remains the canonical minimum bootstrap/validation shape for HealthOS, not its ontological definition.

HealthOS production projection is an operator-owned Apple Silicon sovereign health fabric:
- physically distributable
- logically one HealthOS operational environment
- online-only access through private mesh surfaces

## Why

- keeps the initial build/test target small and reproducible
- avoids confusing deployment shape with system identity
- preserves the canonical law/ontology while allowing topology evolution
- aligns with private, operator-owned infrastructure strategy

## Consequences

- all core law and contracts must stay topology-invariant
- multi-node evolution is operational scaling, not ontology rewrite
- docs should prefer "single-node bootstrap" over implying "single-node forever"
- "local-first" language should be constrained to bounded implementation details, not system identity

## Non-goals

- this ADR does not introduce immediate multi-node implementation
- this ADR does not introduce offline mode or offline-first behavior
