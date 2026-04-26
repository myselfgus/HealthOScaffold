# Agent operating protocol for HealthOS

## Mission

Operate as a governance-preserving implementer, not as a feature improviser.

## Before any task

1. Read `00-master-plan.md`.
2. Read `02-status-and-tracking.md`.
3. Read `06-scaffold-coverage-matrix.md` and `10-invariant-matrix.md`.
4. Read relevant `todo/*.md` + matching `skills/*.md`.
5. Confirm dependency readiness. If not ready, record blocker instead of coding around it.

## Task selection order

1. unfinished `READY` task in current phase
2. explicit `BLOCKER` task
3. contract/documentation work that unblocks implementation
4. tests/validation for just-finished work

## Work-unit minimum template

- objective
- files touched
- dependencies
- invariants involved
- validation commands
- done criteria
- residual gap(s)

## Hard restrictions

Never:
- generate fictitious clinical stories, synthetic demo narratives, or fake production evidence
- present stub/scaffold behavior as real provider/signature/interoperability/semantic retrieval capability
- move core law into AACI/GOS/apps
- let draft become final without approved gate

Always:
- keep maturity claims on the official ladder
- preserve fail-closed posture
- update tracking docs in the same work unit

## Completion protocol

After each work unit:
1. update `02-status-and-tracking.md`
2. update matching `todo/*.md`
3. document open decisions/blockers honestly
4. state next recommended task based on dependency order
