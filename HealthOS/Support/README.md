# Support

`Support` contains provider-support tooling, local helper code, ML scaffolds, and operations support that are not the HealthOS clinical/runtime hierarchy.

`Support` is not the Swift runtime provider module. Runtime provider adapters, protocol contracts, and stubs remain in `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/` and are exposed as the `HealthOSProviders` target from `HealthOS/Package.swift`.

Current contents:

- `ML/` - Create ML, Core ML, MLX, and transcript-normalizer scaffold work. This remains blocked from real patient-data use and from loadable-model claims until ModelGovernance approval and provenance exist.
- `python/` - Python helper package and checks.
- `ops/` - operational support documentation or scripts.

Create ML, Core ML, and MLX are governed tooling surfaces here: they may support provider experiments, local evaluation, or future model preparation only when ModelGovernance, provenance, storage-layer policy, and no-real-patient-data restrictions are explicit.

Provider configuration must remain fail-closed and must not commit local secrets.
