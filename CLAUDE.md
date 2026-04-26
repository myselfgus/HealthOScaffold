# CLAUDE.md

Guidance for coding agents working in HealthOScaffold.

## Constitutional identity (never collapse)

- **HealthOS is the whole platform**.
- **AACI is one runtime inside HealthOS**.
- **GOS is subordinate to Core law** (operational mediation, never constitutional authority).
- **Scribe/Sortio/CloudClinic are app/interfaces** consuming mediated surfaces, not law engines.
- This repo is an advanced scaffold, **not production-ready**, **not a full EHR**, and **not a real regulatory/provider integration**.

## Required reading order before coding

1. `README.md`
2. `docs/execution/README.md`
3. `docs/execution/00-master-plan.md`
4. `docs/execution/01-agent-operating-protocol.md`
5. `docs/execution/02-status-and-tracking.md`
6. `docs/execution/06-scaffold-coverage-matrix.md`
7. `docs/execution/10-invariant-matrix.md`
8. `docs/execution/11-current-maturity-map.md`
9. relevant `docs/execution/todo/*.md`
10. relevant `docs/architecture/*.md`
11. matching `docs/execution/skills/*.md`

Task selection order:
1. `READY` task in current phase
2. `BLOCKER` task
3. documentation/contract task that unblocks coding
4. validation for just-finished work

After each work unit, update:
- `docs/execution/02-status-and-tracking.md`
- corresponding file in `docs/execution/todo/`

## Absolute execution restrictions

Never:
- invent fictitious clinical stories/examples or demo narratives
- treat scaffolded/stubbed behavior as real provider, signature, interoperability, or semantic retrieval
- move consent/habilitation/gate/finality/provenance/storage law into AACI/GOS/apps
- expose raw direct identifiers in app-facing surfaces
- declare production readiness

Always:
- keep claims honest about maturity
- preserve fail-closed governance behavior
- record unresolved contradiction/gap explicitly instead of coding around it

## Canonical first-slice reference

Primary executable slice orchestration lives in:
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- consumed by `HealthOSCLI` and the minimal `HealthOSScribeApp`

Reference ordering:
habilitation validate → consent validate → session start → capture → transcript provenance → retrieval provenance → SOAP draft provenance → gate request → gate resolve → final artifact (only if approved) + provenance.

## Real command baseline

```bash
make bootstrap
make swift-build
make swift-test
make ts-build
make ts-test
make python-compile
```

Smoke path (when validating runnable flow):
```bash
cd swift && swift run HealthOSCLI
cd swift && swift run HealthOSScribeApp --smoke-test
```

## Cross-language contract discipline

When ontology/contracts change, align in the same work unit:
- JSON Schemas (`schemas/`)
- Swift contracts (`swift/Sources/HealthOSCore/` etc.)
- TypeScript contracts (`ts/packages/contracts/src/index.ts`)
- SQL shape (`sql/migrations/001_init.sql`) when relevant

## Commit discipline

- one coherent work chunk per commit
- docs + contracts + tests together when they govern same change
- do not leave tracking stale after code/doc updates
