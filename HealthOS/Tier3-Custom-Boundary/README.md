# Tier 3 - Custom Boundary

Tier 3 contains the HealthOS-owned consumption frontier: Boundary facades, safe refs, envelopes, mediated state, degraded state, commands/results, and app-safe views.

Custom is the Core-law-governed definition of a Stage. It is not a separate HealthOS hierarchy tier. This directory name keeps Custom/Boundary work visible because Stage definitions and consumed surfaces must be validated together, but Boundary remains the executable consumption frontier.

Current contents:

- `Sources/CustomSDK/` - Stage Custom SDK vocabulary and scaffold compliance checks.
- `Sources/HealthOSBoundary/` - Boundary Swift target.
- `Tests/HealthOSBoundaryTests/` - Boundary test target.

Stages consume mediated Boundary surfaces through separate Stage packages. The allowed platform imports for a Stage package are `HealthOSBoundary` and `CustomSDK`; direct Stage dependencies on Core or Tier 2 runtimes are no longer allowed.
