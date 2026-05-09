---
id: ADR-0012
title: HealthOScaffold é o repositório de construção do HealthOS (HealthOScaffold is the HealthOS construction repository)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council]
consulted: [Core engineering, Apps lead, Tooling/CI lead]
informed: [All HealthOS contributors]
tags: [identidade, repositório, scaffold, maturidade, governança, nomenclatura]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSCLI
  - Scribe
  - Veridia
  - CloudClinic
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0009]
code_references:
  - path: README.md
    type: resource
    note: README do repositório enquadra HealthOScaffold como construção do HealthOS.
  - path: HealthOS/Package.swift
    type: pipeline
    note: Pacote chama-se `HealthOS` — identidade do sistema, não do repositório.
  - path: AGENTS.md
    type: resource
    note: Doutrina de agente reforça nomenclatura.
risk_level: Low
compliance:
  privacy: N/A — decisão de nomenclatura/identidade, sem efeito sobre dados.
  security: N/A.
  data_classification: Nenhum.
observability:
  logs: N/A.
  metrics: N/A.
  traces: N/A.
testing:
  strategy: Documentação/glossário consistente; verificação manual em PR review e em arquivos novos.
  coverage_targets: Glossário e overview alinhados; nenhum doc novo introduz "HealthOScaffold é separado do HealthOS".
rollout:
  plan: Estrutural; aplicada desde a fase atual. Sem renomeação de repo (ver não-objetivos).
  monitoring: Auditoria de PRs em docs detecta linguagem que sugere "HealthOScaffold ≠ HealthOS".
---

# ADR 0012 — HealthOScaffold é o repositório de construção do HealthOS

## Contexto

- **Problema e motivação.** O repositório foi historicamente nomeado `HealthOScaffold` porque começou como fase de scaffolding/foundation para construir HealthOS. Conforme a implementação progride, esse nome **não pode** criar uma falsa distinção entre o nome do repositório (fase de fundação) e a identidade do sistema HealthOS. Sem clareza, dois trabalhos emergem em paralelo: um teórico ("o HealthOS" futuro) e um material ("o HealthOScaffold" atual), com governança duplicada.
- **Pressupostos e restrições.** (a) ADR-0001 fixa HealthOS como o sistema; (b) componentes coexistem em diferentes maturidades (doctrine-only, contract scaffolded, implemented seam, tested operational path, production-hardened); (c) renomear o repo agora teria custo alto (links externos, CI, históricos).
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** "Scaffold" descreve **maturidade**, não **identidade de projeto**.
  - **Critérios.** Documentação e glossário usam HealthOScaffold como nome de repositório/fase; tratam todo código nele como HealthOS code.

## Decisão

`HealthOScaffold` é o **repositório canônico de construção** do HealthOS. "Scaffold" descreve a postura de maturidade inicial dos componentes e a fase de bootstrap/foundation do repositório, **não** uma identidade de sistema separada.

Toda arquitetura, contratos, runtimes, apps, testes, schemas, migrations e documentação implementados neste repositório são **parte do HealthOS**, exceto se explicitamente marcados como experimental ou deprecated.

- **Escopo.** Nomenclatura e relação repositório↔sistema. Não decide topologia, stack, ou lei.
- **Justificativa.** Evita bifurcação semântica entre "scaffold" e "HealthOS"; alinha com ADR-0001 (HealthOS é o sistema).

## Alternativas Consideradas

### Alternativa A — Renomear o repositório para `HealthOS`
- **Prós.** Nome reflete identidade.
- **Contras.** Custo alto: links externos quebrados, scripts de CI, histórico de PRs/issues, configs de IDE de contribuintes; ganho marginal vs. custo.
- **Rejeitada para já.** Pode ser revisitada quando a fase de scaffold fechar.

### Alternativa B — Tratar HealthOScaffold como projeto separado
- **Prós.** "Limpeza" semântica.
- **Contras.** Bifurca artefatos e governança; força um futuro "merge into HealthOS"; viola ADR-0001.
- **Rejeitada.**

### Alternativa C — HealthOScaffold é a fase/repo do HealthOS (escolhida)
- **Prós.** Custo zero de renomeação; alinhamento com ADR-0001; clareza explícita de que "scaffold" é maturidade.
- **Contras.** Nome do repo continua confuso para newcomers; mitigado por README e glossário.

## Consequências

- **Positivas.**
  - Código implementado neste repositório é HealthOS code.
  - Componentes podem viver em diferentes níveis de maturidade (doctrine-only, scaffolded contract, implemented seam, tested operational path, production-hardened) **sob a mesma identidade**.
  - Documentação mantém HealthOScaffold e HealthOS alinhados como nome-de-repo e identidade-de-sistema.
  - "Scaffold closure" significa fechamento da fase bootstrap/foundation, **não** abandono nem substituição por outro repositório.
  - "Post-scaffold" significa próxima fase de maturidade do **mesmo** projeto HealthOS.
  - Avisos de não-produção continuam válidos: este repositório pode conter código HealthOS sem estar production-ready.
- **Negativas / trade-offs.**
  - Newcomers podem confundir HealthOScaffold com sub-projeto separado; mitigação por README e ADR.
- **Riscos e mitigação.**
  - **Risco.** Documentação nova introduz "HealthOScaffold ≠ HealthOS" por descuido. **Mitigação.** Glossário canônico em [HealthOS/Shared/docs/architecture/17-glossary.md](../architecture/17-glossary.md); revisão de PR.

### Não-objetivos

Esta ADR **não**:
- renomeia o repositório;
- renomeia pacotes;
- declara prontidão para produção;
- declara completude de EHR;
- remove qualquer aviso de stub/scaffold maturity.

## Detalhes de Implementação

- **Fronteiras entre módulos.** N/A — decisão é semântica/identitária.
- **Conformidade com Package.swift.** Pacote chama-se `HealthOS` ([HealthOS/Package.swift:5](../../../HealthOS/Package.swift:5)) — identidade do sistema preservada no naming técnico.
- **Concurrency.** N/A.
- **Segurança/Privacidade.** N/A.
- **Observabilidade.** N/A.
- **Testes.** N/A — verificação é em revisão de docs.

## Plano de Adoção e Migração

- **Passos.** Adotada. Quando "scaffold closure" for declarada, decidir (em ADR superseding) se renomeia o repositório ou mantém o nome histórico.
- **Impacto em APIs e contratos.** Nenhum.
- **Critérios de saída.** Permanece válida enquanto o repositório mantiver o nome `HealthOScaffold`. Caso renomeado, ADR superseding registrará a transição.

## Checklist de Completude

- [x] Status e data corretos; front matter preenchido.
- [x] Drivers, objetivos e critérios de sucesso mensuráveis.
- [x] Alternativas com prós/contras reais e não triviais.
- [x] Consequências (positivas/negativas), riscos e mitigação.
- [x] Conformidade com arquitetura modular do HealthOS (Package.swift).
- [x] Fronteiras e contratos claros entre módulos.
- [x] Considerações de concorrência, segurança/privacidade e observabilidade.
- [x] Plano de testes e cobertura mínima definida.
- [x] Plano de rollout/migração e monitoramento.
- [x] Rastros para código, testes e pipelines.
- [x] Relações entre ADRs (supersede/superseded by) atualizadas.
