# Execution layer

This directory governs implementation order and anti-drift behavior for HealthOScaffold.

## Current phase posture

As of April 26, 2026, repository posture is:
- **controlled implementation / scaffold hardening**
- executable contracts and tests across multiple domains
- no production-hardening claim

## Read in this order

1. `00-master-plan.md`
2. `01-agent-operating-protocol.md`
3. `02-status-and-tracking.md`
4. `06-scaffold-coverage-matrix.md`
5. `10-invariant-matrix.md`
6. `11-current-maturity-map.md`
7. `12-next-agent-handoff.md`
8. `13-scaffold-release-candidate-criteria.md`
9. `14-final-gap-register.md`
10. `15-scaffold-finalization-plan.md`
11. `16-next-10-actions-plan.md`
12. relevant `todo/*.md`
13. matching `skills/*.md`

## Maturity ladder (required language)

Use only this ladder when updating status/coverage/todo:
1. doctrine-only
2. scaffolded contract
3. implemented seam
4. tested operational path
5. production-hardened

Never skip levels in claims. If uncertain, downgrade to the lower level and record the gap.

## Rules

- Never mark a TODO done without concrete validation evidence.
- Never claim real provider/signature/interoperability/semantic retrieval if still scaffold/stub.
- Never move core law into app/runtime/GOS.
- Always update tracking (`02-status-and-tracking.md` + relevant `todo/*.md`) in same work unit.
