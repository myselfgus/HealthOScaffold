---
automation: Update CLAUDE.md
automation-id: update-claude-md
schedule: weekly — Monday 09:03 local
memory: .healthos-steward/memory/automations/update-claude-md/memory.md
target-agent: Claude Code
git-target: origin/main (sempre trabalha sobre main; push para main a cada run — inclui memory file mesmo sem mudanças no CLAUDE.md)
last-run: never
---

Atualize o CLAUDE.md com workflows, comandos e padrões descobertos recentemente.

## O que verificar

1. Leia o CLAUDE.md atual na íntegra.
2. Execute `git log --oneline --since="14 days ago"` para ver commits recentes.
3. Verifique se alguma dessas coisas mudou e está ausente do CLAUDE.md:
   - Novos targets `make` (verifique o `Makefile` por adições desde o último run)
   - Novos documentos canônicos em `docs/execution/` (novos arquivos numerados)
   - Novos comandos da CLI do Steward (`ts/agent-infra/healthos-steward/src/cli.ts`)
   - Novas convenções de nomeação de branch observadas no git log
   - Novos invariantes ou seções de governança adicionados ao CLAUDE.md do repositório
4. Se e somente se algo genuíno estiver faltando: faça a edição mínima necessária.
5. Se fizer edição:
   - `git add CLAUDE.md`
   - `git commit -m "chore(auto): update CLAUDE.md — <descrição de 1 linha>"`
   - `git push`
6. Escreva um resumo (≤ 6 linhas) em `.healthos-steward/memory/automations/update-claude-md/memory.md`:
   - data do run
   - o que você verificou
   - o que você mudou (ou "nenhuma mudança necessária")
   - próxima verificação sugerida

## Padrão git (main-first)

```bash
# ANTES de qualquer leitura ou edição:
CURRENT=$(git -C $REPO rev-parse --abbrev-ref HEAD)
git -C $REPO stash 2>/dev/null || true
git -C $REPO checkout main
git -C $REPO pull origin main

# Após commit:
git -C $REPO push origin main

# Restaurar estado anterior:
git -C $REPO checkout $CURRENT 2>/dev/null || true
git -C $REPO stash pop 2>/dev/null || true
```

## Restrições

- **Não altere** seções de identidade constitucional, invariantes absolutos, ou restrições de execução sem um motivo verificado no histórico do repositório.
- **Não invente** comandos ou workflows que você não confirmou existirem no código atual.
- **Não altere** seções não relacionadas ao que você encontrou.
- **Em caso de dúvida**, adicione um comentário TODO com observação curta em vez de inventar.
- **Não cometa** nada além do CLAUDE.md e do arquivo de memória.
- **Não declare** production readiness nem altere claims de maturidade.
