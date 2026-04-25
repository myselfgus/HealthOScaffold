# Regulatory / interoperability / signature / emergency governance (scaffold wave)

## Scope of this wave

This wave adds **governed scaffold contracts** for:
- regulatory audit request pathways
- emergency / break-glass access controls
- legal retention vs patient visibility governance
- digital-signature placeholder flows
- interoperability packaging (FHIR/RNDS/TISS profile adapters)
- legal/probative document lineage references

This wave is intentionally **non-finalistic**.

## Explicit non-claims

This wave does **not** claim:
- full regulatory compliance certification
- RNDS/TISS endpoint integration
- ICP-Brasil real qualified signature issuance
- legal effectuation without gate + lineage + provider prerequisites

## Core governance posture

- Core remains sovereign for regulatory contracts.
- AACI and GOS are not regulatory authorities.
- Apps can request workflows only through Core-mediated contracts.
- Regulatory/emergency pathways are fail-closed when rationale/legal-basis/scope/lawfulContext are missing.
- External delivery remains placeholder-only in this wave.

## Minimum guardrails introduced

- regulatory audit requests require legal basis, rationale, scope, lawfulContext, and layer minimization
- emergency requests require rationale, scope, and duration; grants must expire and preserve post-review + patient notification obligations
- retention obligation is separated from visibility/export/deletion/anonymization decisions
- signature scaffold requires final-document lineage + approved gate + document hash and preserves unsigned/requested states without real provider
- interoperability packages must preserve source refs/hashes/provenance and remain validation scaffold only
- observability events are non-sensitive and avoid direct identifiers/secrets

## Implementation references

- `swift/Sources/HealthOSCore/RegulatoryGovernance.swift`
- `swift/Tests/HealthOSTests/RegulatoryGovernanceTests.swift`
- `schemas/contracts/regulatory-interoperability-signature-emergency-governance.schema.json`
- `sql/migrations/001_init.sql`
