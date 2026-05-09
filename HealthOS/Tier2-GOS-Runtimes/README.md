# Tier 2 - GOS and Runtimes

Tier 2 contains operational mediation and runtime execution under Core law: GOS, Session Runtime, AACI, MSR, providers, Async Runtime, User-Agent Runtime, and Service Runtime.

GOS remains subordinate to Core law. Runtimes execute and mediate work; they do not own consent, habilitation, storage law, gate, finality, provenance, or audit authority.

Current contents:

- `Sources/HealthOSGOS/` - canonical GOS target surface.
- `Sources/HealthOSAACI/` - AACI session and GOS binding surface.
- `Sources/HealthOSMSR/` - mental-space runtime pipeline scaffolding.
- `Sources/HealthOSProviders/` - provider protocols, stubs, Foundation Models adapter, and ModelGovernance.
- `Sources/HealthOSSessionRuntime/` - first-slice orchestration and transcript normalization.
- `Sources/HealthOSAsyncRuntime/`, `HealthOSUserAgentRuntime/`, `HealthOSServiceRuntime/` - runtime scaffold seams.
- `GOS/` and `Bootstrap/` - governed operational spec and bootstrap fixtures.
- `Tests/HealthOSRuntimeTests/` - Tier 2 tests.

Transcript normalization remains owned by `HealthOSSessionRuntime`, before MSR execution.
