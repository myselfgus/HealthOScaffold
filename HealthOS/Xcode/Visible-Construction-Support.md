# Visible Construction and Support Directories

The Xcode workspaces intentionally reference these non-tier roots directly:

- `HealthOS/Constructor/`
- `HealthOS/Support/`

They are visible directory names because Xcode navigation can hide hidden roots in some views. `Constructor` is external construction tooling, and `Support` is governed provider-support tooling, ML, Python, and ops support. `Support` is separate from the Tier 2 `HealthOSProviders` runtime-adapter module. Both roots must stay visible in Xcode navigation so agents and operators do not lose Steward, Settler, Forge MCP, provider-support tooling, ops, Python, or ML scaffolds during tier work.
