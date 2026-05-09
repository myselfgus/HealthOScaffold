# Settlement Record Schema

> **Repository identity note**: HealthOScaffold is the historical repository name for the HealthOS construction repository. Settlement records in this repository are HealthOS construction-system documentation. They describe bounded engineering work units; they are not clinical records, runtime contracts, or product-readiness declarations.

## Purpose

A Settlement record is a bounded construction work unit. It defines the objective, scope, Territories, Settler profiles, invariants, validation requirements, and handoff expectations for one unit of engineering work. Settlement records guide Steward and Settlers without replacing official docs or granting authority.

Settlement records live under `HealthOS/Constructor/Steward/settlements/`:
- Active records: `HealthOS/Constructor/Steward/settlements/active/`
- Completed records: `HealthOS/Constructor/Steward/settlements/completed/`
- Template and schema: `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/`

The canonical blank template is: `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/settlement-template.md`

The JSON Schema for machine validation is: `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/settlement.schema.json`

---

## Non-claims (verbatim)

A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims. Settlement records are subordinate to official docs. They are engineering work unit documentation.

---

## Field Definitions

Fields are grouped into four categories: Identity, Scope, Governance, and Lifecycle.

---

### Identity Fields

| Field | Type | Required | Format |
|-------|------|----------|--------|
| `id` | string | Required | `SETTLEMENT-<YYYYMMDD>-<slug>` |
| `title` | string | Required | Short human-readable title (one line) |
| `status` | string (enum) | Required | `DRAFT` \| `IN-PROGRESS` \| `COMPLETE` \| `BLOCKED` |

#### `id`

- **Type**: string
- **Required**: yes
- **Format**: `SETTLEMENT-<YYYYMMDD>-<slug>` where `<YYYYMMDD>` is the creation date in ISO-8601 compact form and `<slug>` is a short kebab-case identifier derived from the task or objective.
- **Example**: `SETTLEMENT-20260504-settler-profile-registry`
- **Description**: Unique identifier for this Settlement record. Used for cross-referencing in tracking docs, handoff notes, and derived memory.

#### `title`

- **Type**: string
- **Required**: yes
- **Format**: One line, human-readable.
- **Example**: `ST-012 Settler Profile Registry`
- **Description**: Human-readable summary of what this Settlement accomplishes.

#### `status`

- **Type**: string (enumerated)
- **Required**: yes
- **Allowed values** (Markdown records): `DRAFT` | `IN-PROGRESS` | `COMPLETE` | `BLOCKED`
- **Allowed values** (JSON schema): `draft` | `assigned` | `in_progress` | `validation_failed` | `ready_for_review` | `completed` | `blocked`
- **Description**: Current lifecycle state of the Settlement.
  - `DRAFT` — Settlement record created but not yet assigned or scoped.
  - `IN-PROGRESS` — Settlement is actively being executed.
  - `COMPLETE` — All done-criteria met, validation passed, tracking updated.
  - `BLOCKED` — Settlement cannot proceed; a specific blocker must be named.

---

### Scope Fields

| Field | Type | Required | Format |
|-------|------|----------|--------|
| `objective` | string | Required | One-paragraph statement |
| `territory` | string[] | Required | Territory IDs from ST-011 Territory Registry |
| `settler-profile` | string[] | Required | Settler Profile IDs from ST-012 Profile Registry |
| `files-in-scope` | string[] | Required | Repository-relative file paths |

#### `objective`

- **Type**: string (paragraph)
- **Required**: yes
- **Format**: One paragraph. State what this Settlement delivers and why. No bullet lists. No clinical claims.
- **Description**: The bounded objective of this work unit. Must be concrete enough that a future agent or reviewer can determine whether the Settlement is complete by checking the done-criteria.

#### `territory`

- **Type**: list of strings
- **Required**: yes
- **Format**: Territory IDs from the ST-011 Territory Registry under `HealthOS/Constructor/Settler/territories/`. Each ID must match a file `<id>.json` in that directory.
- **Valid IDs** (from ST-011): `core`, `gos`, `session-runtime`, `msr`, `aaci`, `providers`, `apps`, `type-script-runtimes`, `storage-and-data`, `regulatory-and-interoperability`, `operations-and-observability`, `construction-system`, `validation-and-ci`, `documentation`
- **Description**: The repository domain(s) this Settlement operates in. Determines which invariants, forbidden moves, and validation expectations apply. A Settlement must never operate outside its listed Territories.

#### `settler-profile`

- **Type**: list of strings
- **Required**: yes
- **Format**: Settler Profile IDs from the ST-012 Settler Profile Registry under `HealthOS/Constructor/Settler/settlers/`. Each ID must match a file `<id>.md` in that directory.
- **Valid IDs** (from ST-012): `settler-core-law`, `settler-storage`, `settler-gos`, `settler-aaci`, `settler-ops`, `settler-apps`, `settler-xcode-tooling`, `settler-documentation`, `settler-validation`
- **Description**: The engineering profile(s) assigned to execute this Settlement. Each profile defines focused scope, invariants, forbidden moves, and validation expectations for its assigned Territory. Choose the profile(s) whose Territory/Territories match the `territory` field.

#### `files-in-scope`

- **Type**: list of strings (repository-relative paths)
- **Required**: yes
- **Format**: Repository-relative paths. Use specific file paths where known; use directory patterns (e.g., `dir/`) for ranges only when a specific file list would be impractical. Files not listed here are out of scope.
- **Description**: Files the assigned Settler(s) may read and write during this Settlement. This field is the primary tool for preventing scope drift. Files outside the assigned Territories must not appear here.

---

### Governance Fields

| Field | Type | Required | Format |
|-------|------|----------|--------|
| `invariants` | string[] | Required | List of non-negotiable rules |
| `restrictions` | string[] | Required | Additional restrictions beyond Territory invariants |
| `validation-commands` | string[] | Required | Make targets or shell commands that must pass |

#### `invariants`

- **Type**: list of strings
- **Required**: yes
- **Minimum**: 3 items required.
- **Format**: Plain-language rule statements. Each invariant is a non-negotiable constraint that must be preserved throughout the Settlement. Begin with invariants inherited from the assigned Territory records, then add any Settlement-specific rules.
- **Description**: Non-negotiable rules that must be preserved unconditionally. If a done criterion conflicts with an invariant, the Settlement must stop and the conflict recorded — it is never resolved by weakening the invariant.

#### `restrictions`

- **Type**: list of strings
- **Required**: yes
- **Format**: Plain-language prohibition statements. Each restriction specifies something the Settler must not do during this Settlement, beyond what Territory invariants already prohibit.
- **Description**: Additional restrictions specific to this Settlement. May include forbidden files not already covered by Territory forbidden paths, forbidden scope expansions, forbidden capability claims, or forbidden interactions with adjacent systems.

#### `validation-commands`

- **Type**: list of strings
- **Required**: yes
- **Format**: Make targets (e.g., `make validate-docs`) or shell commands. Must be reproducible without secrets, real provider access, or production infrastructure.
- **Description**: Commands that must pass before the Settlement can be marked COMPLETE. If a command fails, the Settlement either fixes the failure (if caused by this Settlement) or records the pre-existing failure explicitly. A Settlement is never marked COMPLETE with unrecorded validation failures.

---

### Lifecycle Fields

| Field | Type | Required | Format |
|-------|------|----------|--------|
| `done-criteria` | string[] | Required | Explicit, verifiable deliverables |
| `residual-gaps` | string[] | Required | Known unresolved gaps (may be empty list) |
| `handoff` | string | Required | Handoff statement (one paragraph) |

#### `done-criteria`

- **Type**: list of strings
- **Required**: yes
- **Format**: Explicit, checkable deliverable statements. Each criterion must be binary: the deliverable either exists and meets the spec, or it does not. Avoid vague criteria like "documentation is complete."
- **Description**: The explicit list of deliverables whose existence constitutes completion. No done criterion may be partially satisfied — the Settlement is not COMPLETE until every criterion is met.

#### `residual-gaps`

- **Type**: list of strings
- **Required**: yes (may be an empty list if no gaps exist)
- **Format**: Plain-language statements of known unresolved questions, deferred work, or limitations not addressed by this Settlement.
- **Description**: Explicit record of what this Settlement does NOT deliver. Every known limitation, deferred task, or open question must appear here. Residual gaps become inputs to future Settlements. The guiding rule: it is better to record a gap than to silently ignore it.

#### `handoff`

- **Type**: string (paragraph)
- **Required**: yes
- **Format**: One paragraph. State what artifacts were produced, which tracking docs were updated, and what the recommended next Settlement is.
- **Description**: The handoff statement for the next agent or reviewer. Enables continuity without requiring the next agent to re-read all tracking docs. Must be accurate and specific — no vague claims, no false completion statements.

---

## How to Create a Settlement Record

1. **Select a task**: choose the next READY task from `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` or the ST construction sequence in `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`.

2. **Read the required docs**: read the canonical docs for the assigned Territory before defining the Settlement. All field values must be grounded in official docs, not memory.

3. **Assign an ID**: format is `SETTLEMENT-<YYYYMMDD>-<slug>`. Use today's date; derive the slug from the task name in kebab-case.

4. **Identify Territory and Settler Profile**: use Territory IDs from `HealthOS/Constructor/Settler/territories/` and Settler Profile IDs from `HealthOS/Constructor/Settler/settlers/`. Only use IDs that have corresponding records.

5. **Define `files-in-scope`**: be explicit and narrow. List only files the Settler needs to read or write. Do not include files belonging to other Territories.

6. **Write `invariants`**: start with the Territory's invariants (from the Territory record), then add any Settlement-specific rules. Every invariant must be unconditionally preserved.

7. **Write `restrictions`**: list prohibitions beyond Territory invariants. Be explicit about forbidden files, forbidden scope expansions, and forbidden claims.

8. **Write `validation-commands`**: list the make targets or commands that must pass. Do not include commands requiring secrets, real providers, or production infrastructure.

9. **Write `done-criteria`**: each criterion must be checkable. Prefer "File X exists and contains field Y" over vague statements.

10. **Write `objective`**: one paragraph, bounded and concrete.

11. **Set `status` to `DRAFT`**: the Settlement starts as DRAFT.

12. **Place the file**: use the template at `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/settlement-template.md`. Save active Settlements under `HealthOS/Constructor/Steward/settlements/active/`. Move to `HealthOS/Constructor/Steward/settlements/completed/` after all done-criteria are met and tracking is updated.

13. **Update tracking**: after completion, update `HealthOS/Shared/docs/execution/02-status-and-tracking.md`, `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`, and any relevant `HealthOS/Shared/docs/execution/todo/*.md`.

---

## Field Summary Table

| Field | Group | Type | Required |
|-------|-------|------|----------|
| `id` | Identity | string | Required |
| `title` | Identity | string | Required |
| `status` | Identity | string (enum) | Required |
| `objective` | Scope | string | Required |
| `territory` | Scope | string[] | Required |
| `settler-profile` | Scope | string[] | Required |
| `files-in-scope` | Scope | string[] | Required |
| `invariants` | Governance | string[] | Required (min 3) |
| `restrictions` | Governance | string[] | Required |
| `validation-commands` | Governance | string[] | Required |
| `done-criteria` | Lifecycle | string[] | Required |
| `residual-gaps` | Lifecycle | string[] | Required (may be empty) |
| `handoff` | Lifecycle | string | Required |

---

## Non-claims (verbatim)

A Settlement record does not authorize clinical activity, runtime execution, merge decisions, or production-readiness claims. Settlement records are subordinate to official docs. They are engineering work unit documentation.

---

## Related records

- Blank template: `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/settlement-template.md`
- JSON Schema: `HealthOS/Constructor/Steward/settlements/HealthOS/Shared/templates/settlement.schema.json`
- Territory Registry: `HealthOS/Constructor/Settler/territories/`
- Settler Profile Registry: `HealthOS/Constructor/Settler/settlers/`
- Construction Operating Model: `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`
- Architecture doctrine: `HealthOS/Shared/docs/architecture/47-steward-settler-engineering-model.md`
- ST task tracker: `HealthOS/Shared/docs/execution/19-settler-model-task-tracker.md`
