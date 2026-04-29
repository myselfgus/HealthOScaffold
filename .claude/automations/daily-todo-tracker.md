---
automation: Daily TODO tracker
automation-id: daily-todo-tracker
schedule: daily — 08:07 local
memory: .healthos-steward/memory/automations/daily-todo-tracker/
target-agent: Claude Code
git-target: origin/main (pull antes de ler, commit + push digest para main após cada run)
last-run: never
---

Varre todos os TODOs, blockers e pendências do repositório e escreve um digest diário de status.

## Padrão git (main-first — commit + push após cada run)

```bash
# Antes de ler:
CURRENT=$(git -C $REPO rev-parse --abbrev-ref HEAD)
git -C $REPO stash 2>/dev/null || true
git -C $REPO checkout main && git -C $REPO pull origin main

# Após escrever o digest:
git -C $REPO add .healthos-steward/memory/automations/daily-todo-tracker/
git -C $REPO commit -m "chore(auto): daily-todo-tracker digest YYYY-MM-DD"
git -C $REPO push origin main

# Restaurar estado anterior:
git -C $REPO checkout $CURRENT 2>/dev/null || true
git -C $REPO stash pop 2>/dev/null || true
```

## O que fazer

1. Leia `docs/execution/02-status-and-tracking.md` (primeiras 80 linhas — fase atual e recentes).
2. Leia `docs/execution/12-next-agent-handoff.md` (prioridades e próximos passos).
3. Leia `docs/execution/14-final-gap-register.md` (gaps abertos).
4. Leia todos os arquivos em `docs/execution/todo/` e contabilize por domínio:
   - tarefas READY
   - tarefas BLOCKED (se houver)
   - total pendente vs total concluído
5. Leia `docs/execution/18-healthos-xcode-agent-task-tracker.md` (status dos streams Xcode).
6. Leia `docs/execution/19-settler-model-task-tracker.md` (status do modelo Settler).
7. Escreva o digest em `.healthos-steward/memory/automations/daily-todo-tracker/YYYY-MM-DD.md`
   usando o template abaixo.
8. Sobrescreva `.healthos-steward/memory/automations/daily-todo-tracker/latest.md`
   com o conteúdo do digest do dia.
9. **Não commite nada.** Estes arquivos são memória derivada, não docs canônicos.

## Template do digest

```markdown
# Daily status digest — YYYY-MM-DD

**Fase atual**: <fase>
**Gerado por**: daily-todo-tracker automation

## Tarefas READY por domínio

| Domínio | ID | Prioridade | Dependências |
|---|---|---|---|
| <domain> | <id> | High/Medium/Low | <deps ou —> |

## Tarefas BLOCKED

| ID | Motivo do blocker |
|---|---|
| <id> | <motivo> |

(Se não houver, escreva: nenhum blocker ativo)

## Contador geral

- READY: <n>
- BLOCKED: <n>
- COMPLETED recentes (últimas 2 semanas): <n>
- Gaps abertos no gap register: <n>

## Xcode Agent streams

| Stream | Status |
|---|---|
| Stream A | <status> |
| Stream B | <status> |
| Stream C | <status> |
| Stream D | <status> |
| Stream E | <status> |
| Stream F | <status> |

## Settler model

| Tarefa | Status |
|---|---|
| ST-002 | <status> |
| ST-003 | <status> |
| ST-004 | <status> |
| ST-005 | <status> |
| ST-006 | <status> |

## Top 3 próximas ações de maior impacto

1. **<id>**: <descrição de 1 linha> — prioridade: <High/Medium>
2. **<id>**: <descrição de 1 linha> — prioridade: <High/Medium>
3. **<id>**: <descrição de 1 linha> — prioridade: <Medium>

## Observações

<qualquer gap, inconsistência, ou arquivo faltando encontrado durante o scan>
```

## Restrições

- **Não modifique** nenhum arquivo em `docs/execution/`.
- **Não marque** nenhum TODO como concluído.
- **Não crie** branches nem PRs.
- Commite e faça push **apenas** de `.healthos-steward/memory/automations/daily-todo-tracker/`.
- Se um arquivo estiver faltando ou ilegível, registre no digest e continue.
- O digest é memória derivada — nunca declare production readiness nem altere claims.
