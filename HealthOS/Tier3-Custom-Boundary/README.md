# Tier 3 - Custom Boundary

Tier 3 contains the HealthOS-owned consumption frontier: Boundary facades, safe refs, envelopes, mediated state, degraded state, commands/results, and app-safe views.

Custom is the Core-law-governed definition of a Stage. It is not a separate HealthOS hierarchy tier. This directory name keeps Custom/Boundary work visible because Stage definitions and consumed surfaces must be validated together, but Boundary remains the executable consumption frontier.

Current contents:

- `Sources/HealthOSBoundary/` - Boundary Swift target.
- `Tests/HealthOSBoundaryTests/` - Boundary test target.

Stages should consume mediated Boundary surfaces. Known direct dependencies from current scaffold targets are documented in `HealthOS/Package.swift` as TODOs, not as permanent architecture.
