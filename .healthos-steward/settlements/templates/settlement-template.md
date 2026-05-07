# Settlement Record: <SETTLEMENT-YYYYMMDD-slug>

<!-- HealthOS Construction System — Settlement Record Template -->
<!-- Instructions: copy this file to .healthos-steward/settlements/active/<slug>.md, replace all <PLACEHOLDER> values, then move to .healthos-steward/settlements/completed/ when all done-criteria are met. -->
<!-- Schema spec: .healthos-settler/settlements/SCHEMA.md -->
<!-- JSON Schema: .healthos-steward/settlements/templates/settlement.schema.json -->

> **Non-claims**: A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims. Settlement records are subordinate to official docs. They are engineering work unit documentation.

---

## Identity

**id**: `<SETTLEMENT-YYYYMMDD-slug>`
<!-- Format: SETTLEMENT-<YYYYMMDD>-<slug>. YYYYMMDD is today's date in compact ISO-8601 form. Slug is kebab-case derived from the task name. Example: SETTLEMENT-20260504-settler-profile-registry -->

**title**: `<SHORT HUMAN-READABLE TITLE>`
<!-- One line. Example: "ST-013 Settlement Record Schema and Templates" -->

**status**: `DRAFT`
<!-- Allowed values: DRAFT | IN-PROGRESS | COMPLETE | BLOCKED. Set to DRAFT at creation. Update as work progresses. -->

---

## Scope

**objective**:
<!-- One paragraph. State what this Settlement delivers and why. No bullet lists. No clinical claims. Be concrete enough that a future agent can determine whether the Settlement is complete. -->
<OBJECTIVE STATEMENT — one paragraph describing the bounded deliverable>

**territory**:
<!-- Territory IDs from .healthos-settler/territories/. Each ID must match a file <id>.json in that directory. -->
<!-- Valid IDs (from ST-011): core, gos, session-runtime, msr, aaci, providers, apps, type-script-runtimes, storage-and-data, regulatory-and-interoperability, operations-and-observability, construction-system, validation-and-ci, documentation -->
- `<TERRITORY-ID-1>`
<!-- Add more territory IDs as needed. A Settlement may span multiple Territories. -->

**settler-profile**:
<!-- Settler Profile IDs from .healthos-settler/settlers/. Each ID must match a file <id>.md in that directory. -->
<!-- Valid IDs (from ST-012): settler-core-law, settler-storage, settler-gos, settler-aaci, settler-ops, settler-apps, settler-xcode-tooling, settler-documentation, settler-validation -->
- `<SETTLER-ID-1>`
<!-- Add more profile IDs as needed. Chosen profile(s) must cover the listed territory/territories. -->

**files-in-scope**:
<!-- Repository-relative paths of files this Settlement may read and write. Be explicit and narrow. Files not listed are out of scope. -->
<!-- Read-only files may also be listed to make the reading scope explicit. -->
- `<FILE-PATH-1>`
- `<FILE-PATH-2>`
<!-- Add more paths as needed. Do not include files from Territories not assigned above. -->

---

## Governance

**invariants**:
<!-- Non-negotiable rules that must be preserved throughout this Settlement. Start with invariants from the assigned Territory record(s), then add Settlement-specific rules. Minimum 3 required. -->
<!-- A Settlement must never violate an invariant even to meet a done criterion. If conflict occurs, Settlement is BLOCKED until resolved in official docs. -->
- <INVARIANT-1 — inherited from Territory or Settlement-specific non-negotiable rule>
- <INVARIANT-2>
- <INVARIANT-3>
<!-- Add more invariants as needed. -->

**restrictions**:
<!-- Additional prohibitions beyond Territory invariants. List forbidden files, forbidden scope expansions, forbidden capability claims, forbidden interactions with adjacent systems. -->
- <RESTRICTION-1 — something the Settler must not do in this Settlement>
- <RESTRICTION-2>
<!-- Add more restrictions as needed. -->

**validation-commands**:
<!-- Make targets or shell commands that must pass before marking COMPLETE. Must be reproducible without secrets, real providers, or production infrastructure. -->
<!-- If a command fails, either fix the failure (if caused by this Settlement) or record the pre-existing failure explicitly. Never mark COMPLETE with unrecorded failures. -->
- `<COMMAND-1>` <!-- e.g., make validate-docs -->
- `<COMMAND-2>` <!-- e.g., make validate-all -->
<!-- Add more commands as needed. -->

---

## Lifecycle

**done-criteria**:
<!-- Explicit, verifiable deliverables. Each criterion must be binary: the deliverable exists or it does not. -->
<!-- Check each item off when met. Settlement is not COMPLETE until every criterion is checked. -->
- [ ] <CRITERION-1 — specific, checkable deliverable>
- [ ] <CRITERION-2>
- [ ] <CRITERION-3>
<!-- Add more criteria as needed. -->

**residual-gaps**:
<!-- Known limitations, deferred work, or open questions not addressed by this Settlement. Record honestly. May be an empty list if genuinely none. -->
<!-- It is better to record a gap than to silently ignore it. -->
- <GAP-1 — deferred task or open question>
- <GAP-2>
<!-- Add more gaps as needed. Or write: (none identified) -->

**handoff**:
<!-- One paragraph. State what artifacts were produced, which tracking docs were updated, and what the recommended next Settlement is. This enables the next agent to continue without re-reading all tracking docs. -->
<HANDOFF STATEMENT — artifacts produced, tracking updated, next Settlement recommended>

---

## Source docs

<!-- List all canonical docs consulted before writing this Settlement. Read before executing. -->
<!-- Start with docs for the assigned Territory. Add any task-specific docs. -->
- `<DOC-PATH-1>` <!-- e.g., docs/execution/22-steward-construction-operating-model.md -->
- `<DOC-PATH-2>` <!-- e.g., docs/architecture/47-steward-settler-engineering-model.md -->
<!-- Add more docs as needed. -->
