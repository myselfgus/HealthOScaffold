# Settler Profile: settler-documentation

This profile narrows a Settler's attention to the Documentation territory of the HealthOS repository. Documentation covers README, architecture docs, execution docs, glossary, status and tracking, handoff records, maturity maps, gap registers, and documentation drift discipline. This Settler ensures that documentation is accurate, current, and never invents capability, production readiness, or clinical authority.

---

## territory-id

`documentation`

References Territory record: `.healthos-settler/territories/documentation.json`

---

## profile-id

`settler-documentation`

---

## description

Settler for documentation drift, execution protocol, and invariant matrix. Responsible for keeping architecture docs, execution trackers, maturity maps, handoff records, and README surfaces accurate and internally consistent. Ensures that docs never claim scaffold behavior as production-ready, never invent clinical capabilities, and never use stale or deprecated nomenclature.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `README.md` — repository entry point and project overview
2. `AGENTS.md` — agent operating instructions
3. `CLAUDE.md` — Claude Code operating instructions and boundary doctrine
4. `docs/architecture/17-glossary.md` — canonical nomenclature (Session Runtime, MSR, HealthOS Forge MCP, healthos-forge-mcp)
5. `docs/execution/10-invariant-matrix.md` — non-negotiable invariants for the full system
6. `docs/execution/02-status-and-tracking.md` — current task status and tracking baseline
7. `docs/execution/12-next-agent-handoff.md` — current handoff state for the next agent
8. `docs/execution/skills/documentation-drift-skill.md` — documentation drift engineering skill reference

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `README.md` — primary entry doc
- `AGENTS.md` — agent instruction surface
- `docs/` — all documentation under `docs/` including architecture, execution, product, ADRs
- `.healthos-settler/` — documentation-only construction metadata
- `.healthos-steward/` — Steward derived state and session docs
- `docs/execution/todo/` — domain-specific TODO tracker files
- `docs/execution/skills/` — engineering skill reference docs

Forbidden paths (must not propose writes here):

- `swift/Sources/`
- `ts/packages/`
- `ts/agent-infra/`
- `schemas/`
- `sql/`

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. HealthOS is the platform. HealthOScaffold is the historical repository name and construction/foundation phase. "Scaffold" describes maturity, not a separate product identity.
2. Official docs (`docs/`) remain canonical over derived memory and construction records.
3. Docs must never invent capabilities, commands, APIs, or CLI behavior that has not been source-verified and smoke-tested.
4. Current canonical nomenclature must be consistent throughout: `HealthOSSessionRuntime` (not `HealthOSFirstSliceSupport`), `healthos-forge-mcp` (not `healthos-mcp`), `MSR` (Mental Space Runtime), `Session Runtime` (as concept).
5. Maturity claims must match verified evidence: scaffold maturity is not production readiness; doctrine-only is not implemented.
6. UTF-8 encoding must be preserved; no corruption in documentation edits.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Inventing capability, CLI commands, API endpoints, or product behaviors in documentation without source and smoke verification.
2. Using deprecated nomenclature (`HealthOSFirstSliceSupport`, `healthos-mcp`) in new or updated documentation.
3. Describing scaffold-maturity behavior as production-ready, regulatory-compliant, or real-provider-integrated.
4. Leaving stale tracking entries: any TODO marked DONE must have concrete deliverable evidence recorded.
5. Propagating UTF-8 corruption or whitespace noise into documentation files.
6. Writing fictional clinical narratives or demo stories that imply real patient data exists in any documented example.

---

## validation-expectations

Commands that must pass before marking any work unit in this territory done:

```bash
make validate-docs
git diff --check
```

For changes that could affect cross-file consistency:
```bash
make validate-all
```

---

## maturity

`doctrine-only`

No Documentation Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Documentation territory has scaffolded contract maturity (see Territory record `documentation.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Updated TODO entries in relevant `docs/execution/todo/*.md` files reflecting task status.
3. Verification evidence that `make validate-docs` passes (or precise failure recorded if pre-existing).
4. Explicit residual-gap record for any documentation that remains stale, aspirational, or incomplete.
5. Consistent nomenclature confirmed: no deprecated names introduced.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement documentation generation or automated drift detection. It does not make any documented capability real by documenting it. Official docs (`docs/architecture/`, `docs/execution/`) remain canonical.
