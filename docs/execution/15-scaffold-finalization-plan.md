# Scaffold finalization plan

Date baseline: April 26, 2026.

This plan defines the exact final sequence to reach scaffold closure without pretending product completion.

## Last actions for scaffold closure

1. Close or explicitly accept current scaffold blockers listed in `14-final-gap-register.md` (GAP-001, GAP-002).
2. Keep entry docs aligned (`README.md`, `AGENTS.md`, `CLAUDE.md`) with the same maturity truth.
3. Confirm `06-scaffold-coverage-matrix.md`, `10-invariant-matrix.md`, `11-current-maturity-map.md`, and `12-next-agent-handoff.md` are synchronized.
4. Keep TODO files organized with only actionable remaining tasks.
5. Run mandatory local validation gates and record outcomes.

## Merge criteria for closure PR

A closure PR is mergeable when:

- all changed docs agree on scaffold posture (no production-ready claim)
- gap register is updated with owner, impact, and milestone for each open gap
- maturity map and coverage matrix use the canonical ladder and honest status
- validate-all and required language-specific checks are executed and reported
- any failing command is clearly classified as blocker vs accepted future work

## Validation criteria (must run)

```bash
make validate-all
cd swift && swift build && swift test
cd ts && npm install && npm run build && npm test --if-present
cd python && python -m compileall .
cd swift && swift run HealthOSCLI && swift run HealthOSScribeApp --smoke-test
```

## Documents to review before tag/release prep

- `README.md`
- `AGENTS.md`
- `CLAUDE.md`
- `docs/execution/02-status-and-tracking.md`
- `docs/execution/06-scaffold-coverage-matrix.md`
- `docs/execution/10-invariant-matrix.md`
- `docs/execution/11-current-maturity-map.md`
- `docs/execution/12-next-agent-handoff.md`
- `docs/execution/13-scaffold-release-candidate-criteria.md`
- `docs/execution/14-final-gap-register.md`
- `docs/execution/15-scaffold-finalization-plan.md`

## Explicitly does NOT block scaffold closure

As long as they remain explicitly classified as gaps (not hidden), the following do not block scaffold closure:

- final app UI delivery
- real STT provider
- real semantic retrieval provider/index
- real remote provider deployment
- real RNDS/TISS/FHIR integrations
- real qualified digital signature integration
- production KMS and hardware-backed key workflows
- production multi-node mesh/fabric implementation
- production disaster recovery drills and SLO evidence
- full legal/compliance certification

## Post-scaffold/product phase handoff

After scaffold closure, prioritize:

1. provider and semantic retrieval real integrations with unchanged fail-closed governance
2. runtime adapter propagation for Sortio/CloudClinic and cross-app shared envelope usage
3. operational hardening: incident command set, CI gates, restore drill automation, distributed async execution
4. regulatory endpoint/signature integration without over-claiming legal validity until complete

