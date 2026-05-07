# ts/

TypeScript workspace for HealthOS — contracts, runtimes, GOS tooling, Steward CLI, and Forge MCP.

Build: `make ts-build` or `cd ts && pnpm install && pnpm -r build`

---

## Packages

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#F6F8FB', 'primaryBorderColor': '#D6DEE8', 'primaryTextColor': '#1D2733', 'clusterBkg': '#FFFFFF', 'clusterBorder': '#D6DEE8', 'lineColor': '#5B6B7C', 'edgeLabelBackground': '#F6F8FB', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph LR
    classDef core      fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef runtime   fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef gos       fill:#ecfeff,stroke:#06b6d4,stroke-width:2px,color:#164e63
    classDef construct fill:#fdf2f8,stroke:#ec4899,stroke-width:2px,color:#831843
    classDef substrate fill:#f1f5f9,stroke:#94a3b8,stroke-width:2px,color:#334155

    CON[contracts\n@healthos/contracts\nshared type vocabulary]:::core

    GOS[healthos-gos-tooling\n@healthos/gos-tooling\nGOS compiler · validator · bundler]:::gos
    ASYNC[runtime-async\n@healthos/runtime-async\njob queue · idempotency · dead-letter]:::runtime
    UA[runtime-user-agent\n@healthos/runtime-user-agent\npatient queries · prohibition enforcement]:::runtime
    SVC[service-runtime\n@healthos/service-runtime\nservice-ops envelope · LegalAuthorizing guard]:::runtime

    STEW[healthos-steward\n@healthos/steward\n10 CLI commands + library]:::construct
    MCP[healthos-forge-mcp\nstdio MCP server\n10 steward_* tools]:::construct

    CON --> GOS & ASYNC & UA & SVC
    CON --> STEW
    STEW --> MCP
```

### `packages/contracts` — `@healthos/contracts`

Shared TypeScript type vocabulary: session, governance, provenance, gate, GOS spec interfaces. Consumed by all other packages. Maturity: implemented seam.

### `packages/healthos-gos-tooling` — `@healthos/gos-tooling`

GOS authoring toolchain — compiler, validator, bundler, and lifecycle tooling. Parses `.gos.yaml` specs, validates against Core invariants, produces runtime bundles consumed by Swift. Maturity: operational path (scaffold hardening).

### `packages/runtime-async` — `@healthos/runtime-async`

Reference implementation for the Async Runtime — durable job queue, idempotency keys, retry, dead-lettering. Subordinate to Core law; no consent, gate, or storage authority. Maturity: implemented seam. The Swift `HealthOSAsyncRuntime` target mirrors this posture natively.

### `packages/runtime-user-agent` — `@healthos/runtime-user-agent`

User-Agent Runtime — patient-governed queries, prohibited-capability enforcement, sovereignty contract execution. Maturity: scaffolded contract / partial implementation.

### `packages/service-runtime` — `@healthos/service-runtime`

Service Runtime — CloudClinic envelope adapter, `LegalAuthorizing` guard, service-operations session boundary. Maturity: scaffolded contract / partial implementation.

---

## Agent Infrastructure

### `agent-infra/healthos-steward` — `@healthos/steward`

Steward CLI and library — 10 deterministic repository engineering commands. No LLM calls, no merge authority, no clinical scope.

```bash
make ts-build
cd ts && npx --yes --workspace @healthos/steward healthos-steward status
cd ts && npx --yes --workspace @healthos/steward healthos-steward next
cd ts && npx --yes --workspace @healthos/steward healthos-steward list territories
cd ts && npx --yes --workspace @healthos/steward healthos-steward list settlements
cd ts && npx --yes --workspace @healthos/steward healthos-steward generate-prompt <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward validate-settlement <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward pr-draft <id>
cd ts && npx --yes --workspace @healthos/steward healthos-steward build-memory
```

Full command reference: `CLAUDE.md` Steward usage section.

### `agent-infra/healthos-forge-mcp`

Forge MCP — stdio MCP server exposing 10 `steward_*` tools for deterministic repository maintenance. Used by Steward for Xcode, Xcode Intelligence, and external coding assistants. Not a clinical, runtime, or governance MCP server. See `docs/architecture/45-healthos-xcode-agent.md`.

---

## Cross-Language Contract Discipline

When ontology or contracts change, align TypeScript contracts here in the same work unit as `swift/`, `schemas/`, and `sql/`. See root `README.md § Cross-Language Contract Discipline`.
