# Automation memory — update-claude-md

## Último run

**Data**: 2026-05-04
**Verificado**: git log (14 dias), Makefile, `HealthOS/Constructor/ts/agent-infra/healthos-steward/src/cli.ts`, leitura integral do CLAUDE.md, HealthOS/Shared/docs/execution/ por novos arquivos canônicos, HealthOS/Shared/docs/product/ por novos docs de produto

## Mudanças feitas

1. **Reading order — itens 15 e 16 adicionados** (renumeração 15→17, 16→18, 17→19, 18→20):
   - Item 15: `HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md` — canonical priority-ordered task selection plan. Justificativa: doc criado em 2026-04-29, referenciado em handoff/tracker como leitura obrigatória antes de selecionar tarefas, ausente da lista formal do CLAUDE.md principal.
   - Item 16: `HealthOS/Shared/docs/product/01-healthos-technical-product-specification.md` — technical product specification baseline. Justificativa: doc criado em ST-011B (2026-05-01), primeiro spec técnico consolidado; handoff doc instrui leitura junto com docs de arquitetura/execução.

2. **Seção `## Prompt architecture template` adicionada**: referência ao template mestre em `HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md` com regras-chave (atomic, bounded, governance-preserving, forbidden names, healthos-forge-mcp, HealthOSSessionRuntime). Justificativa: template criado por solicitação explícita do operador em 2026-05-04 para padronizar prompts de implementação por qualquer IA/LLM.

## O que não mudou

- Makefile: nenhum target novo (lista em CLAUDE.md já cobre todos os targets existentes)
- Steward CLI: baseline `status`, `runtime`, `session` inalterado (cli.ts confirmado)
- Seções constitucionais: intocadas
- Claims de maturidade: inalterados
- `HealthOS/Shared/docs/execution/22-steward-construction-operating-model.md`: já referenciado na seção Steward; não adicionado à lista formal (subordinate reference suficiente)

## Próxima verificação sugerida

Semana de 2026-05-11 (Monday 09:03 — próxima execução programada).
Verificar se novos docs canônicos criados por APP-011/APP-012 ou ST-012 exigem atualização da lista de leitura.

## Histórico

| Data | O que foi verificado | Mudanças feitas |
|---|---|---|
| 2026-04-28 | Makefile, Steward CLI, git log 14d, novos docs execution/ | Added item 14 (work plan) to reading order; added Automations section |
| 2026-05-04 | Makefile, Steward CLI, git log 14d, HealthOS/Shared/docs/execution/ (doc 21), HealthOS/Shared/docs/product/ (doc 01), stash state | Added items 15 (doc 21) and 16 (product spec) to reading order; added Prompt architecture template section; created prompt-architecture-template.md |
