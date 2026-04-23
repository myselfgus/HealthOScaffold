# AI context bundle

This file is the minimum context pack an AI must internalize before touching code in HealthOS.

## Identity of the system

HealthOS is the whole sovereign computational environment.
AACI is one runtime inside HealthOS.
Scribe, Sortio, and CloudClinic are interfaces over HealthOS.

## What must never be confused

- HealthOS is not just AACI.
- AACI is not the whole platform.
- Apps are not the core.
- Mesh/VPN is not a governance mechanism.
- Provider choice is not ontology.
- Gate is not optional.
- Storage is not zero-knowledge against the platform itself.

## Hard invariants

1. every meaningful datum has owner/titular context and access policy
2. directly identifying data is separated and strongly protected
3. operational content remains processable by HealthOS
4. consent, habilitation, purpose/finality, and provenance are first-class
5. no regulatory/clinical effect without human gate resolution
6. apps consume laws; they do not create them
7. single-node correctness comes before any mesh expansion

## Build order memory

- laws first
- storage second
- runtime contracts third
- AACI fourth
- app flows after that
- ops and ML remain subordinate to ontology

## Coding posture for an AI

- prefer explicit contracts over convenience shortcuts
- prefer narrow changes that preserve architecture
- if a change leaks app logic into core or governance into UI, stop and correct
- if a task depends on undefined contracts, define the contract first
