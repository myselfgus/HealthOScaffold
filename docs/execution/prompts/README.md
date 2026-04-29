# AI phase prompts

Prompts de execução para o plano de trabalho documental (`docs/execution/20-documental-todos-work-plan.md`).

Cada prompt é auto-contido e contém todo o contexto, invariantes, entregáveis, e instruções de git/PR necessárias para uma IA executar a fase sem intervenção humana.

## Prompts disponíveis

| Arquivo | Fase | Tarefas | Branch alvo |
|---|---|---|---|
| [phase-1-settler-territory.md](phase-1-settler-territory.md) | Phase 1 | ST-006, ST-002, ST-003 | `codex/phase-1-settler-territory-docs` |
| [phase-2-architecture-proposals.md](phase-2-architecture-proposals.md) | Phase 2 | CL-006, OPS-003, ST-004 | `codex/phase-2-architecture-proposals` |
| [phase-3-xcode-agent-streams.md](phase-3-xcode-agent-streams.md) | Phase 3 | Stream C, Stream D, Stream F | `codex/phase-3-xcode-agent-streams` |

## Ordem de execução

Phase 1 → Phase 2 → Phase 3. Cada fase deve ser mergeada antes de iniciar a próxima.

## Estrutura de cada prompt

1. Identity and mission
2. Absolute invariants (never violate)
3. Branch setup
4. Mandatory pre-reading order
5. Task-by-task specifications (fields, content, file targets)
6. Tracking update requirements
7. Git workflow (commits, push, PR)
8. Phase definition of done
