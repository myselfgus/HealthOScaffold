# Shared

`Shared` contains repository-wide HealthOS assets that are not owned by one tier.

Current contents:

- `docs/` - active documentation, architecture records, execution trackers, and skills.
- `DesignSystem/` and `design/` - shared design-system assets and visual references.
- `templates/` - scaffold templates.
- `Shared/runtime-data/` - non-sensitive scaffold runtime and validation fixtures.
- `Sources/HealthOSCLI/` - operator-facing CLI target.
- `Tests/HealthOSTests/` - existing cross-surface integration tests.

Shared assets must not be used to bypass tier ownership. The operator CLI is not a Stage.
