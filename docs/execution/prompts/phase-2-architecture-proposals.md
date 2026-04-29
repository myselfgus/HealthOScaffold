# Phase 2 Prompt — Architecture proposals and operations documentation

**Version**: 1.0 | **Date**: 2026-04-28 | **Plan source**: `docs/execution/20-documental-todos-work-plan.md`

---

## IDENTITY AND MISSION

You are a governance-preserving documentation agent working inside the **HealthOScaffold** repository — the construction repository for **HealthOS**. Your mission is to extend three existing architecture documents with new sections that define:

1. A shared error-envelope proposal for local service boundaries (CL-006)
2. An incident-response command set for first operator tools (OPS-003)
3. A specification of healthos-mcp Settler operations (ST-004)

These are architecture-writing tasks. You will extend existing `.md` files. You will not write code, modify Swift/TypeScript/Python/SQL files, or claim production readiness.

**Prerequisite**: Phase 1 (`codex/phase-1-settler-territory-docs`) must be merged before Phase 2 begins.

---

## ABSOLUTE INVARIANTS — NEVER VIOLATE

1. **HealthOS is the platform.** Never use "scaffold" to imply this work lives outside HealthOS.
2. **No production-readiness claim.** No document may state or imply any component is production-ready, regulatory-approved, or real-provider-integrated.
3. **No clinical content.** No fictitious clinical stories, real patient data, or invented examples.
4. **Core law stays in Core.** Service boundary proposals must not move consent/habilitation/gate/finality into AACI, GOS, or apps.
5. **`healthos-mcp` is repository-maintenance only.** It never becomes a clinical tool server, runtime MCP, or Core law engine.
6. **Fail-closed always.** Every proposal involving service responses, tool operations, or incident handling must default to deny/fail, not silently succeed.
7. **Tracking is mandatory.** After each task, update `docs/execution/02-status-and-tracking.md` and the relevant `docs/execution/todo/*.md` in the same work unit.
8. **Verify before referencing.** Check that every path you reference exists before citing it.

---

## BRANCH SETUP (do this first)

```bash
git checkout main
git pull origin main
git checkout -b codex/phase-2-architecture-proposals
```

---

## MANDATORY PRE-READING ORDER

Read every file below before writing. Do not skip.

```
1.  docs/execution/20-documental-todos-work-plan.md           ← tasks 4–6 in the master plan
2.  docs/execution/01-agent-operating-protocol.md             ← operating rules
3.  docs/execution/10-invariant-matrix.md                     ← all 43 invariants
4.  docs/execution/02-status-and-tracking.md                  ← current status (top 80 lines)
5.  docs/execution/todo/core-laws.md                          ← CL-006 definition and context
6.  docs/execution/todo/ops-network-ml.md                     ← OPS-003 definition and context
7.  docs/execution/19-settler-model-task-tracker.md           ← ST-004 definition
8.  docs/architecture/06-core-services.md                     ← CL-006 target file (READ IN FULL)
9.  docs/adr/0006-local-swift-ts-seam.md                     ← CL-003 seam decision (loopback HTTP)
10. docs/architecture/14-operations-runbook.md                ← OPS-003 target file (READ IN FULL)
11. docs/architecture/26-operator-observability-contract.md   ← OPS-002 visibility contract
12. docs/architecture/47-steward-settler-engineering-model.md ← ST-004 canonical model
13. docs/execution/17-healthos-xcode-agent-migration-plan.md  ← WS-2 definition
14. CLAUDE.md                                                  ← healthos-mcp boundary doctrine
```

After reading, confirm:
- `docs/architecture/06-core-services.md` exists → YES/NO
- `docs/architecture/14-operations-runbook.md` exists → YES/NO
- `docs/architecture/26-operator-observability-contract.md` exists → YES/NO
- `docs/architecture/47-steward-settler-engineering-model.md` exists → YES/NO
- `docs/adr/0006-local-swift-ts-seam.md` exists → YES/NO

If any file is missing, stop and report the gap.

---

## TASK 4 OF 9 (PHASE 2 TASK 1 OF 3) — CL-006: Shared error-envelope proposal

**Source**: `docs/execution/todo/core-laws.md` → CL-006
**Target file**: `docs/architecture/06-core-services.md` (extend — do not replace)
**Optional target**: `schemas/contracts/local-service-error-envelope.schema.json` (create only if spec is complete enough)
**Priority**: Medium
**Dependencies satisfied**: CL-003 (loopback HTTP seam decided), CL-004 (deny/failure semantics defined)

### Context you must absorb before writing

- CL-003 fixed the local seam as: loopback HTTP + PostgreSQL metadata + filesystem/object references (from `docs/adr/0006-local-swift-ts-seam.md`)
- CL-004 established that deny is a governed refusal (not a crash) and failure is a runtime error (not a deny) — from the existing content of `docs/architecture/06-core-services.md`
- The gap: there is no single transport envelope that expresses all three outcomes (success / deny / failure) consistently for the loopback HTTP seam

### What to add to `docs/architecture/06-core-services.md`

Find a logical insertion point after the existing deny/failure semantics section. Add a new `## Shared error envelope for local service boundaries` section.

The section must contain:

#### 1. Rationale paragraph

Explain why a shared envelope matters: without it, callers at the loopback seam must inspect HTTP status codes, body shapes, and error fields inconsistently across services. The envelope creates one surface that unambiguously represents all three outcomes.

#### 2. Outcome classes

Define exactly three outcome classes with no ambiguity:

```
ok       — governed operation succeeded; payload present
denied   — governed refusal; operation was processed but policy, consent, habilitation,
           gate, or finality check refused it; not a crash; payload absent
error    — runtime failure; service could not process the request; not a policy decision;
           payload absent
```

The critical distinction: **denied is a legitimate governance outcome, not an error.** An `error` means something broke; a `denied` means something was refused by design.

#### 3. Envelope shape

```
{
  "status": "ok" | "denied" | "error",
  "code":   string,    // governed refusal code or error kind; required when status != "ok"
  "message": string,   // non-sensitive, non-clinical, human-readable; optional on "ok"
  "payload": <T>       // service-specific payload; present only when status = "ok"
}
```

Define the `code` vocabulary for denied responses (minimum):
- `consent.required` — operation requires consent that is absent or revoked
- `habilitation.required` — operation requires habilitation that is absent
- `gate.required` — operation requires an approved gate that has not resolved
- `finality.violation` — operation would modify a finalized record
- `lawfulContext.missing` — lawfulContext required by this service layer is absent
- `layer.policy.denied` — data layer sensitivity policy denies this operation

Define the `code` vocabulary for error responses (minimum):
- `service.unavailable` — the service could not handle the request
- `internal` — unexpected runtime failure

#### 4. HTTP transport contract

```
200 OK       → status: "ok"
403 Forbidden → status: "denied"   (governed refusal, not a crash; must include code)
500 Internal Server Error → status: "error"  (runtime failure; must include code)
```

Do not use 400 for governance denials. 403 is the correct transport signal for a governed refusal.

#### 5. Invariants that apply to this envelope

List these explicitly — they are non-negotiable:

```
1. Denied responses MUST NOT include the raw payload of the denied request.
2. Error responses MUST NOT include stack traces or internal system state.
3. Both denied and error are fail-closed — they must not silently degrade to partial success.
4. The code field in denied responses must use the vocabulary above; no free-form strings.
5. The message field must never contain direct identifiers or clinical data.
6. Services must not return status "ok" with an empty payload unless the service contract
   explicitly defines empty-payload as a valid success state.
```

#### 6. Adoption note

End the section with an honest maturity note:

```
**Maturity note**: This envelope is a proposal at scaffold maturity. It defines the target
shape for loopback HTTP responses. Existing service stubs that do not yet use this envelope
are known gaps. Full adoption requires each service stub to be updated as it moves beyond
scaffold maturity. This proposal does not claim real provider integration or production readiness.
```

### Optional: JSON Schema

If the envelope shape above is sufficiently precise, also create `schemas/contracts/local-service-error-envelope.schema.json` with a JSON Schema definition of the envelope. Include the `code` enum values for denied and error. Mark it as a proposal, not a final contract.

Only create this file if you can do so without guessing at field types or validation rules. If uncertain, skip the schema and note the gap.

### After completing Task 4

Update `docs/execution/todo/core-laws.md`:
- Move CL-006 from READY to COMPLETED.
- Add outcome block:
  ```
  ### CL-006 Add shared error-envelope proposal for local service boundaries
  Outcome:
  - added ## Shared error envelope section to docs/architecture/06-core-services.md
  - defined three outcome classes: ok, denied, error
  - defined envelope shape with status/code/message/payload fields
  - defined code vocabulary for denied and error responses
  - defined HTTP transport contract (200/403/500)
  - listed 6 invariants for envelope use
  Files touched:
  - docs/architecture/06-core-services.md
  - schemas/contracts/local-service-error-envelope.schema.json (if created)
  ```

Add entry to `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Local service boundary can represent success, deny, and failure outcomes consistently from the new section.

---

## TASK 5 OF 9 (PHASE 2 TASK 2 OF 3) — OPS-003: Incident-response command set

**Source**: `docs/execution/todo/ops-network-ml.md` → OPS-003
**Target file**: `docs/architecture/14-operations-runbook.md` (extend — do not replace)
**Priority**: High
**Dependencies satisfied**: OPS-001 (runbook bootstrapped), OPS-002 (observability contract defined)

### Context you must absorb before writing

- OPS-001 added bootstrap, daily/weekly checks, and incident categories to the operations runbook — read the full current file before adding anything
- OPS-002 defined minimum operator visibility indicators and alert classes — read `docs/architecture/26-operator-observability-contract.md` in full before writing; the incident detection signals must match the alert classes already defined
- The gap: there is an incident categories section but no explicit action vocabulary — an operator seeing an alert cannot map it to a concrete command without guessing

### What to add to `docs/architecture/14-operations-runbook.md`

Find the existing incident categories section (from OPS-001). After that section, add a new `## Incident-response command vocabulary` section.

The section must cover **four incident categories**. For each one, provide all five sub-sections.

#### Incident category 1: Runtime failure

Detection signal (must match OPS-002 alert classes):
- Health check returns non-200 for any critical service
- Error rate exceeds threshold defined in `docs/architecture/26-operator-observability-contract.md`
- Service process not responding

Immediate operator action:
1. Check service health endpoint: describe the exact endpoint pattern
2. Check most recent log output: describe where logs are written
3. If process is down: describe restart procedure (do not invent real commands; describe the action in terms of the scaffold's documented service model)
4. If health check passes but error rate is high: check queue depth and recent session logs

Escalation path:
- If service cannot be restarted within the first operator's ability: escalate to engineering; document timeline and exact error observed
- Clinical sessions in progress at time of failure: describe how the fail-closed posture handles in-flight sessions

Recovery confirmation:
- Health check returns 200 for all critical services
- Error rate falls below threshold
- No governed operations are silently dropping

Post-incident record:
- Record: service name, failure onset time, root cause (if known), actions taken, resolution time
- Record must not contain patient identifiers or clinical session content

#### Incident category 2: Queue saturation

Detection signal (must match OPS-002 alert classes):
- Async job queue depth exceeds threshold
- Processing lag crosses defined latency boundary
- Governed operation backlog observable in session audit

Immediate operator action:
1. Check queue depth metric: describe where it is visible
2. Identify whether saturation is from burst input or from processing slowdown
3. If processing slowdown: check downstream service health (this loops back to Runtime failure category)
4. Do not drop governed payloads to clear the queue; fail-closed posture applies

Escalation path:
- If queue does not drain within acceptable window: escalate to engineering
- If queue saturation affects a live session with a patient: fail-closed; do not attempt a workaround that bypasses governance

Recovery confirmation:
- Queue depth below threshold
- Processing lag within acceptable range
- No governed payloads dropped

Post-incident record:
- Record: queue name, saturation onset time, depth peak, root cause (if known), actions taken, resolution time

#### Incident category 3: Backup concern

Detection signal (must match OPS-005 backup governance):
- Backup job completion status: failed or not recorded
- Backup integrity hash mismatch detected
- Retention policy threshold crossed without backup confirmation

Immediate operator action:
1. Check backup job log for last successful completion
2. Check integrity hash for last completed backup
3. Do not attempt restore from an unverified backup
4. If hash mismatch: quarantine the backup set; escalate before proceeding

Escalation path:
- If last verifiable backup exceeds retention threshold: escalate immediately; do not attempt recovery alone
- If integrity check fails: treat as potential data integrity incident (see category 4)

Recovery confirmation:
- Backup job completes successfully with matching integrity hash
- Retention policy window satisfied

Post-incident record:
- Record: backup job name, failure onset, integrity check result, resolution steps, confirmation hash

#### Incident category 4: Integrity incident

Detection signal:
- Provenance record mismatch detected between session audit and artifact log
- Finality violation: a finalized record was modified without an approved gate
- Unauthorized write attempt observed in audit trail

Immediate operator action:
1. Do not attempt to correct the record without a formal documented request
2. Identify the affected artifact ID and session ID (without logging patient identifiers in the incident record itself)
3. Preserve the audit trail as-is; do not delete or overwrite any record during investigation
4. Alert the designated responsible person immediately

Escalation path:
- All integrity incidents are immediate escalation — there is no operator self-resolution path
- If finality violation is confirmed: regulatory and legal review may be required
- Document: artifact ID, detected mismatch, timestamp, who was notified

Recovery confirmation:
- Root cause identified and documented
- Artifact lineage verified or flagged as unverifiable
- Corrective action (if any) taken through approved gate, not operator override

Post-incident record:
- This incident category requires a formal record beyond the standard runbook entry
- Record must be preserved immutably; must not be modified after the fact

#### Closing section: Post-incident discipline

Add a final sub-section with these rules:

```
1. Every incident record must be created even if resolution was trivial.
2. Incident records must not contain patient identifiers, session clinical content,
   or any direct identifier.
3. The root cause field is required before an incident is marked resolved.
   "Unknown" is acceptable when root cause genuinely cannot be determined;
   it must not be used to avoid investigation.
4. Incident records are not modified after the fact to improve appearance.
5. Recurring incidents of the same kind must trigger a documented gap in
   docs/execution/14-final-gap-register.md.
```

### After completing Task 5

Update `docs/execution/todo/ops-network-ml.md`:
- Move OPS-003 from READY to COMPLETED.
- Add outcome block listing all four incident categories and post-incident discipline section.

Add entry to `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Operator tooling can map any of the four visible incident categories to an explicit action vocabulary from the new section.

---

## TASK 6 OF 9 (PHASE 2 TASK 3 OF 3) — ST-004: Define healthos-mcp Settler operations spec

**Source**: `docs/execution/19-settler-model-task-tracker.md` → ST-004
**Target file**: `docs/architecture/47-steward-settler-engineering-model.md` (add new section)
**Supporting update**: `docs/execution/19-settler-model-task-tracker.md` (mark ST-004 done)
**Priority**: Medium
**Dependencies**: Phase 1 complete (profiles and Territory records exist)

### Context you must absorb before writing

- `healthos-mcp` is doctrine-only. No server is implemented. The spec defines what operations it will expose — not what it currently does.
- CLAUDE.md establishes the two-family boundary: `healthos-mcp` is repository-maintenance only; HealthOS runtime MCP servers are a separate family. These must never be collapsed.
- The canonical model doc (`docs/architecture/47-steward-settler-engineering-model.md`) already defines `healthos-mcp` at a high level. You are adding a detailed operations specification section.
- The migration plan (`docs/execution/17-healthos-xcode-agent-migration-plan.md` WS-2) defines the implementation objective. The spec must be consistent with that objective.

### What to add to `docs/architecture/47-steward-settler-engineering-model.md`

Find the existing `healthos-mcp` section in the document. After it, add a new `## healthos-mcp operations specification` section.

The section must contain:

#### 1. Boundary declaration (mandatory opening)

```
healthos-mcp is a repository-maintenance MCP server for Steward and Settlers.
It exposes typed operations for maintaining the HealthOS construction repository.

It is NOT:
- a clinical tool server
- a HealthOS runtime MCP server
- a Core law engine
- an authorization surface for clinical decisions

Operations exposed by healthos-mcp must never receive clinical payloads, patient identifiers,
or session clinical content. They must never move HealthOS Core law into tooling.
```

#### 2. Operations table

For each of the 9 operations below, write a full specification block. Each block must contain:
- Operation name (as it would appear in an MCP tool call)
- Description (one sentence)
- Input parameters (typed)
- Output shape (structured fields, not free text)
- Error conditions and behavior
- Dry-run support note
- Non-clinical guarantee (explicit statement that no clinical data is processed)

**Operations to specify:**

**`validate-docs`**
- Runs the docs validation target
- Input: `{ "target": "validate-docs" | "validate-all" | "validate-schemas" | "validate-contracts" }` (default: `validate-docs`)
- Output: `{ "status": "pass" | "fail", "target": string, "errors": [{ "file": string, "message": string }], "duration_ms": number }`
- Error: if make target is not found, returns `{ "status": "error", "code": "target.not_found" }`
- Dry-run: when `dry_run: true`, returns what would be run without executing

**`validate-all`**
- Shorthand for `validate-docs` with `target: "validate-all"`
- Same shape as validate-docs

**`scan-status`**
- Reads `docs/execution/02-status-and-tracking.md` and returns current phase and recent completions
- Input: `{}` (no parameters)
- Output: `{ "current_phase": string, "recent_completions": [{ "id": string, "title": string, "date": string }], "open_items": number }`
- Error: if file not found, returns `{ "status": "error", "code": "file.not_found" }`
- Dry-run: returns what would be read without returning content

**`next-task`**
- Reads all `docs/execution/todo/*.md` files and returns the highest-priority READY task
- Input: `{ "domain": string? }` (optional filter by domain: `core-laws`, `ops-network-ml`, `apps-and-interfaces`, `runtimes-and-aaci`, `data-storage`, `gos-and-compilers`)
- Output: `{ "task_id": string, "title": string, "priority": "High" | "Medium" | "Low", "domain": string, "skill": string?, "dependencies": string[] }`
- Error: if no READY task found, returns `{ "status": "empty", "message": "no READY tasks found" }`

**`read-gap-register`**
- Reads `docs/execution/14-final-gap-register.md` and returns open gaps
- Input: `{ "filter": "open" | "all" }` (default: `open`)
- Output: `{ "gaps": [{ "id": string, "title": string, "severity": string, "status": string }] }`

**`get-handoff`**
- Reads `docs/execution/12-next-agent-handoff.md` and returns current handoff state
- Input: `{}`
- Output: `{ "current_state": string, "priority_gaps": string[], "next_tasks": string[], "validation_baseline": string[] }`

**`check-invariants`**
- Reads `docs/execution/10-invariant-matrix.md` and returns invariants flagged as having known gaps
- Input: `{ "layer": string? }` (optional filter by layer)
- Output: `{ "invariants": [{ "id": string, "layer": string, "status": "enforced" | "gap" | "missing", "gap_note": string? }] }`

**`check-doc-drift`**
- Compares key execution tracking files for internal consistency (status vs todo files, handoff vs status)
- Input: `{ "scope": "quick" | "full" }` (default: `quick`)
- Output: `{ "drifts": [{ "file_a": string, "file_b": string, "description": string }], "clean": boolean }`
- Note: this operation reads only docs files; it does not read or modify source code

**`generate-pr-review-draft`**
- Produces a structured PR review template from current tracking state
- Input: `{ "pr_number": number?, "include_sections": string[]? }`
- Output: `{ "draft": string, "sections": string[], "policy_version": string }`
- CRITICAL: This operation NEVER posts to GitHub by default. Posting requires an explicit `post: true` flag and must only send real provider output — never a placeholder.
- Dry-run: always available; `dry_run: true` returns the draft without any side effects

#### 3. Shared operation constraints

All operations must satisfy:
```
1. Dry-run support: every operation accepts an optional dry_run: boolean parameter.
   When true, the operation returns what it would do without taking any action.

2. No clinical payloads: no operation accepts or returns patient identifiers,
   session clinical content, consent records, or habilitation records.

3. No secrets in logs: operations must not log API keys, tokens, or credentials.

4. Fail-closed: when an operation cannot complete, it returns a structured error
   with a code field. It must not silently return partial results as if successful.

5. No Core law moved into tooling: operations read docs and run make targets.
   They do not implement governance logic, consent enforcement, or gate resolution.

6. Idempotent reads: scan-status, get-handoff, check-invariants, check-doc-drift,
   next-task, and read-gap-register are read-only. They must not modify any file.

7. Maturity: all operations are doctrine-only specifications. No implementation exists yet.
```

#### 4. Maturity declaration

End the section with:
```
**Maturity**: This operations specification is doctrine-only. No `healthos-mcp` server
is implemented as of this writing. The specification defines the target interface for
future implementation. No production-readiness or live-server claim is made.
```

### After completing Task 6

Update `docs/execution/19-settler-model-task-tracker.md`:
- Change ST-004 status from `TODO` to `DONE`.
- Add outcome block.

Add entry to `docs/execution/02-status-and-tracking.md`.

**Definition of done**: Each of the 9 operations has typed input, structured output, error conditions, dry-run note, and a non-clinical guarantee.

---

## TRACKING UPDATE (after all three tasks)

Add an entry to `docs/execution/02-status-and-tracking.md` at the top of "Completed recently":

```markdown
## PHASE-2-ARCHITECTURE-PROPOSALS — Architecture proposals and operations documentation (2026-04-28)

Objective: write CL-006, OPS-003, and ST-004 documental artifacts per
docs/execution/20-documental-todos-work-plan.md Phase 2.

Files touched:
- docs/architecture/06-core-services.md (CL-006 — shared error-envelope section added)
- schemas/contracts/local-service-error-envelope.schema.json (if created)
- docs/architecture/14-operations-runbook.md (OPS-003 — incident-response command vocabulary added)
- docs/architecture/47-steward-settler-engineering-model.md (ST-004 — operations spec section added)
- docs/execution/todo/core-laws.md
- docs/execution/todo/ops-network-ml.md
- docs/execution/19-settler-model-task-tracker.md
- docs/execution/02-status-and-tracking.md

Invariants involved:
- Core law stays in Core (CL-006 envelope does not move consent/gate/finality)
- healthos-mcp is repository-maintenance only (ST-004)
- fail-closed posture in all proposals
- no production-readiness or clinical claims

Validation:
- make validate-docs PASS

Done criteria:
- CL-006 moved to COMPLETED in core-laws.md
- OPS-003 moved to COMPLETED in ops-network-ml.md
- ST-004 moved to DONE in 19-settler-model-task-tracker.md
```

---

## GIT WORKFLOW

### Three commits — one per task

```bash
# After Task 4 (CL-006):
git add docs/architecture/06-core-services.md docs/execution/todo/core-laws.md
# (add schema file if created)
git commit -m "docs(arch): CL-006 — add shared error-envelope proposal for local service boundaries

Adds ## Shared error envelope section to 06-core-services.md.
Defines ok/denied/error outcome classes, envelope shape, HTTP transport contract,
code vocabulary (6 denied codes, 2 error codes), and 6 invariants.
CL-006 moved to COMPLETED in todo/core-laws.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 5 (OPS-003):
git add docs/architecture/14-operations-runbook.md docs/execution/todo/ops-network-ml.md
git commit -m "docs(ops): OPS-003 — add incident-response command vocabulary

Adds ## Incident-response command vocabulary section to 14-operations-runbook.md.
Covers 4 categories: runtime failure, queue saturation, backup concern, integrity incident.
Each category has detection signal, immediate action, escalation path, recovery confirmation,
and post-incident record. OPS-003 moved to COMPLETED in todo/ops-network-ml.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"

# After Task 6 (ST-004) + tracking update:
git add docs/architecture/47-steward-settler-engineering-model.md \
        docs/execution/19-settler-model-task-tracker.md \
        docs/execution/02-status-and-tracking.md
git commit -m "docs(settler): ST-004 — define healthos-mcp operations specification

Adds ## healthos-mcp operations specification section to 47-steward-settler-engineering-model.md.
Specifies 9 operations: validate-docs, validate-all, scan-status, next-task, read-gap-register,
get-handoff, check-invariants, check-doc-drift, generate-pr-review-draft.
Each operation has typed input, structured output, error conditions, dry-run note, non-clinical guarantee.
ST-004 moved to DONE in 19-settler-model-task-tracker.md.

Co-Authored-By: Claude Sonnet 4.6 <noreply@anthropic.com>"
```

### Push and PR

```bash
git push -u origin codex/phase-2-architecture-proposals

gh pr create \
  --title "docs: Phase 2 — Architecture proposals and operations documentation (CL-006, OPS-003, ST-004)" \
  --body "## Summary
- CL-006: shared error-envelope proposal added to docs/architecture/06-core-services.md
- OPS-003: incident-response command vocabulary added to docs/architecture/14-operations-runbook.md
- ST-004: healthos-mcp operations specification added to docs/architecture/47-steward-settler-engineering-model.md

## Changes by task

### CL-006
- New section: ## Shared error envelope for local service boundaries
- Defines: ok/denied/error outcome classes; envelope shape (status/code/message/payload); HTTP transport (200/403/500); denied code vocabulary (6 codes); error code vocabulary (2 codes); 6 invariants

### OPS-003
- New section: ## Incident-response command vocabulary
- Covers: runtime failure / queue saturation / backup concern / integrity incident
- Each category: detection signal, immediate action, escalation path, recovery confirmation, post-incident record

### ST-004
- New section: ## healthos-mcp operations specification
- Specifies 9 operations with typed input, structured output, error conditions, dry-run, non-clinical guarantee
- Opening boundary declaration: healthos-mcp is never clinical, never runtime, never Core law
- Closing maturity note: doctrine-only, no implementation

## Invariants
- Core law stays in Core (envelope does not move consent/gate/finality)
- healthos-mcp remains repository-maintenance only
- All proposals are fail-closed
- No production-readiness or clinical claims

## Test plan
- [ ] make validate-docs passes
- [ ] 06-core-services.md has new ## Shared error envelope section with all required sub-sections
- [ ] 14-operations-runbook.md has new ## Incident-response command vocabulary section covering all 4 categories
- [ ] 47-steward-settler-engineering-model.md has ## healthos-mcp operations specification with all 9 operations
- [ ] CL-006 moved to COMPLETED in docs/execution/todo/core-laws.md
- [ ] OPS-003 moved to COMPLETED in docs/execution/todo/ops-network-ml.md
- [ ] ST-004 moved to DONE in docs/execution/19-settler-model-task-tracker.md

🤖 Generated with Claude Code" \
  --base main
```

---

## PHASE 2 DEFINITION OF DONE

Phase 2 is complete when ALL of the following are true:

- [ ] `docs/architecture/06-core-services.md` contains `## Shared error envelope for local service boundaries` with: rationale, three outcome classes, envelope shape, HTTP transport contract, `denied` code vocabulary (≥6 codes), `error` code vocabulary (≥2 codes), 6 invariants, maturity note
- [ ] `docs/architecture/14-operations-runbook.md` contains `## Incident-response command vocabulary` with all 4 incident categories and post-incident discipline section
- [ ] `docs/architecture/47-steward-settler-engineering-model.md` contains `## healthos-mcp operations specification` with boundary declaration, all 9 operations fully specified, shared constraints, maturity declaration
- [ ] CL-006 moved to COMPLETED in `docs/execution/todo/core-laws.md`
- [ ] OPS-003 moved to COMPLETED in `docs/execution/todo/ops-network-ml.md`
- [ ] ST-004 moved to DONE in `docs/execution/19-settler-model-task-tracker.md`
- [ ] `docs/execution/02-status-and-tracking.md` has PHASE-2-ARCHITECTURE-PROPOSALS entry
- [ ] `make validate-docs` passes
- [ ] Three separate commits on branch `codex/phase-2-architecture-proposals`
- [ ] Branch pushed to remote
- [ ] PR created targeting main

**If any item above is not met, the phase is not complete.**
