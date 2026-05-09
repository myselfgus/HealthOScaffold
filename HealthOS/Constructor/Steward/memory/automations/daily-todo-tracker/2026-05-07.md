# Daily status digest — 2026-05-07

**Fase atual**: Controlled implementation — first vertical slice started
**Gerado por**: daily-todo-tracker automation

## Tarefas READY por domínio

| Domínio | ID | Prioridade | Dependências |
|---|---|---|---|
| Ops/Network/CI | CI-001 | P4 / Tier 1 | P0-P2 complete; GitHub Actions workflow absent in current tree |
| Runtimes e AACI | RT-ASYNC-001 | P3 / Tier 1 | Local PostgreSQL/runbook path or explicit environment-gated skip |
| Runtimes e AACI | RT-RETRIEVAL-001 | P3 / Tier 1 | Real embeddings provider/path or explicit policy-approved degraded posture |
| Ops/Steward | WS-2 | Medium / needs-review | Phase A complete; reconcile with implemented `healthos-forge-mcp` stdio+HTTP seam |
| Ops/Steward | WS-3 | Medium / needs-review | Phase A complete; reconcile with implemented deterministic Steward commands |

## Tarefas BLOCKED

| ID | Motivo do blocker |
|---|---|
| APP-012 | BLOCKED after ADR-0013 until Tier 1 platform/runtime foundations, CloudClinic App Integration Boundary, and CloudClinic App Charter are ready |
| ST-020 | NEEDS-REVIEW / BLOCKED AS WRITTEN because it targets APP-012 implementation prompt generation before APP-012 is unblocked |

## Contador geral

- READY: 5
- BLOCKED: 2
- COMPLETED recentes (ultimas 2 semanas): 53 entries in `HealthOS/Shared/docs/execution/02-status-and-tracking.md` with 2026-04/2026-05 completion headings
- Gaps abertos no gap register: 8 (GAP-003 a GAP-010)

## Xcode Agent streams

| Stream | Status |
|---|---|
| Stream A | IN PROGRESS — Runtime core |
| Stream B | IN PROGRESS — Session model |
| Stream C | TODO — Tool runtime |
| Stream D | TODO — Model backend layer |
| Stream E | TODO — CLI conversation surface |
| Stream F | TODO — Xcode conversation surface |

## Settler model

| Tarefa | Status |
|---|---|
| ST-002 | not present as active ST task in current tracker |
| ST-003 | not present as active ST task in current tracker |
| ST-004 | not present as active ST task in current tracker |
| ST-005 | not present as active ST task in current tracker |
| ST-006 | not present as active ST task in current tracker |
| ST-010 | DONE |
| ST-011 | DONE |
| ST-011B | DONE |
| ST-012 | DONE |
| ST-013 | DONE |
| ST-014 | DONE |
| ST-015 | DONE |
| ST-016 | DONE |
| ST-017 | DONE |
| ST-018 | DONE |
| ST-019 | DONE |
| ST-020 | NEEDS-REVIEW / BLOCKED AS WRITTEN |
| ST-021 | DONE |
| ST-022 | DONE |
| ST-023 | DONE |

## Top 3 próximas ações de maior impacto

1. **CI-001**: Wire `make validate-all` into GitHub Actions; `.github/workflows/` is absent in the current tree — prioridade: High
2. **RT-ASYNC-001**: Implement or environment-gate SQL-backed async runtime executor without moving Core law — prioridade: High
3. **RT-RETRIEVAL-001**: Add real embeddings provider/path or explicit policy-approved degraded semantic retrieval posture — prioridade: High

## Observações

- Current branch is `main`; before writing this digest, local `main` and `origin/main` were even by `git rev-list --left-right --count origin/main...main` (`0 0`). After the digest commit, local `main` is ahead by 1 until network access allows push. Fetch/pull was not run in this restricted automation environment.
- Pre-existing local changes are present outside this digest path: `.claude/scheduled_tasks.json`, `AGENTS.md`, `CLAUDE.md`, workspace settings, `.claude/worktrees/`, `.codex/`, and `outputs/`. They were left untouched.
- Git log since the last automation includes README tier/diagram work, Swift package tier structure, Xcode schemes/assets/Create ML scaffold, ADR/app-layer boundary documentation, Forge/Steward doc drift correction, UX copy docs, and AACI SOAP plan honesty fixes.
- `CI-001` is not DONE: no `.github/workflows/validate.yml` or `.github/workflows/swift-test.yml` exists in the current tree.
- `RT-ASYNC-001` is not DONE: SQL schema includes async job tables, but `HealthOSAsyncRuntime` still documents a scaffold stub and no PostgreSQL async executor was found.
- `RT-RETRIEVAL-001` is not DONE: embedding provider contracts/stubs exist, but semantic retrieval still records unavailable/fail-closed behavior without a real embedding provider/index.
- `APP-012` must not be selected as app implementation work until the ADR-0013 unblock criteria are satisfied or explicitly narrowed to degraded/out-of-scope semantics.
- `WS-2` and `WS-3` appear stale/needs-review in `ops-network-ml.md`: current implemented surfaces are `healthos-forge-mcp` and the expanded deterministic `healthos-steward` command set, not the older `healthos-mcp` wording.
