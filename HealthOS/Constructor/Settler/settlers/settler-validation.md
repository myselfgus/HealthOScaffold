# Settler Profile: settler-validation

This profile narrows a Settler's attention to the Validation and CI territory of the HealthOS repository. Validation covers the Makefile, build targets, test suites, contract drift checks, coverage matrix, release criteria, and CI posture. This Settler ensures that the validation harness never masks failures, never produces false-positive pass results, and never claims production-hardened status from local-only validation.

---

## territory-id

`validation-and-ci`

References Territory record: `HealthOS/Constructor/Settler/territories/validation-and-ci.json`

---

## profile-id

`settler-validation`

---

## description

Settler for coverage matrix, release criteria, and contract validation. Responsible for maintaining the Makefile, validation harness, test command discipline, contract drift checks, and CI posture. Ensures that all validation commands are honest, that failures are classified precisely, and that no validation gap is silently accepted as a pass.

---

## canonical-docs

The Settler must read these documents before acting in this territory:

1. `HealthOS/Shared/docs/execution/10-invariant-matrix.md` — non-negotiable invariants that validation must enforce
2. `HealthOS/Shared/docs/execution/README.md` — execution governance and phase-gate protocol
3. `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md` — coverage matrix mapping domains to test coverage status
4. `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md` — release candidate criteria and scaffold RC gate
5. `HealthOS/Shared/docs/execution/14-final-gap-register.md` — final gap register for scaffold RC
6. `HealthOS/Shared/docs/execution/skills/testing/SKILL.md` — testing engineering skill reference (if present at this path)

---

## files-in-scope

Primary paths this Settler may read and propose writes to:

- `Makefile` — primary build and validation target definitions
- `scripts/` — repository validation scripts
- `HealthOS/*/Tests/` — Swift test targets by tier/support/construction/shared surface
- `HealthOS/Constructor/ts/` — TypeScript build and test configuration (when affecting validation targets)
- `.github/` — CI configuration (when present)
- `HealthOS/Shared/docs/execution/06-scaffold-coverage-matrix.md` — coverage matrix doc
- `HealthOS/Shared/docs/execution/13-scaffold-release-candidate-criteria.md` — RC criteria doc
- `HealthOS/Shared/docs/execution/todo/` — relevant TODO tracker files

Forbidden paths (must not propose writes here):

- `HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/` — Core source (changes require Core Settler)
- `HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/` — AACI source (changes require AACI Settler)
- `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/` — Steward source (changes require Xcode Tooling Settler)

---

## invariants

Non-negotiable rules. A work unit that violates any of these must stop:

1. No failure may be masked. If a validation command fails, it is recorded as a failure; the work unit does not claim pass.
2. Pre-existing failures must be classified precisely before new work begins, so that new failures are distinguishable from pre-existing ones.
3. Validation commands that can contend on build locks (concurrent Swift builds) must be run sequentially, not in parallel.
4. Local-only validation does not prove production-hardened status or regulatory compliance.
5. Test stubs and mocked behavior must be labeled as such; they do not constitute evidence of production behavior.
6. Contract drift checks must surface real mismatches, not suppress them for convenience.

---

## forbidden-moves

Explicit prohibitions for work in this territory:

1. Weakening or removing drift checks, schema validators, or contract consistency checks to make failing tests pass.
2. Running Swift build or test commands concurrently with other Swift build/test commands in a way that creates `.build` lock contention.
3. Claiming `make validate-all` passes when one or more sub-targets fail.
4. Marking a scaffold RC gate closed without evidence from all required validation commands.
5. Describing local `make swift-test` or `make ts-test` passing as equivalent to production-grade test coverage.
6. Bypassing `--no-verify` or other hook bypasses without explicit operator instruction and explicit recording of the bypass.

---

## validation-expectations

By definition, this Settler's primary deliverable is validation evidence itself. For any work unit, the Settler must run the following in sequence:

```bash
make swift-build
make swift-test
make ts-build
make ts-test
make validate-contracts
make validate-schemas
make validate-docs
make validate-all
```

Failures must be classified as either:
- **New failure** (introduced by this work unit): must be fixed before marking done.
- **Pre-existing failure**: must be recorded explicitly in the residual-gaps field of the tracking entry.

---

## maturity

`doctrine-only`

No Validation Settler execution runtime exists. This profile is a documentation-only engineering instruction record. Validation infrastructure itself has scaffolded contract maturity (see Territory record `validation-and-ci.json`), but this Settler profile remains doctrine-only until Settler execution infrastructure exists.

---

## handoff-requirements

Before a Settler profile operating under this record exits a work unit, it must produce:

1. Updated tracking entry in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with outcome, invariants preserved, and residual gaps.
2. Complete list of validation commands run and their results (PASS / FAIL / pre-existing).
3. Updated coverage matrix or RC criteria doc if the work unit changed test coverage or release gate status.
4. Explicit residual-gap record for any validation that remains absent, scaffolded, or stub-only.
5. No false-pass claims: every failure, whether new or pre-existing, must be explicitly recorded.

---

## non-claims

This Settler profile is an engineering instruction document. It is not a clinical agent, runtime actor, HealthOS Core actor, or authority record. It does not grant merge authority, clinical access, or production-readiness. It does not implement CI pipelines, test frameworks, or automated validation infrastructure. It does not make local validation equivalent to production-hardened test coverage. Official docs (`HealthOS/Shared/docs/architecture/`, `HealthOS/Shared/docs/execution/`) remain canonical.
