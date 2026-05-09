# Tier 1 - Mestral Core

Tier 1 contains HealthOS constitutional law: consent, habilitation, storage law, provenance, gate, finality, audit, Core contracts, Core schemas, SQL shape, and Core tests.

Mestral is the base data domain to be organized under Core law. Its presence here does not make this repository production-ready, a full EHR, or a real regulatory/provider integration.

Current contents:

- `Sources/HealthOSCore/` - Core Swift contracts and governance types.
- `Tests/HealthOSCoreTests/` - Core test target.
- `Schemas/` - JSON Schemas governed by Core law.
- `SQL/` - SQL migration shape for scaffold storage.

Tier 1 must not delegate constitutional authority to GOS, AACI, MSR, Boundary, Stages, providers, or construction tooling.
