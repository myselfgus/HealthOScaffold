---
id: ADR-0009
title: Single-node bootstrap e topologia de fabric soberano (Single-node bootstrap and sovereign fabric topology)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Platform/Infra lead]
consulted: [Operações/Operadores, Apps lead, Privacy/Compliance]
informed: [All HealthOS contributors, partners de fabric soberano]
tags: [topologia, bootstrap, single-node, fabric-soberano, mesh, apple-silicon, soberania, online-only]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSCLI
  - HealthOSScribeApp
  - HealthOSVeridiaApp
  - HealthOSCloudClinicApp
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0002, ADR-0005, ADR-0006]
code_references:
  - path: swift/Package.swift
    type: pipeline
    note: Plataforma `.macOS(.v26)` — alvo Apple Silicon canônico.
  - path: swift/Sources/HealthOSCore/StorageContracts.swift
    type: protocol
    note: Contratos de storage devem permanecer topology-invariant.
  - path: docs/architecture/15-mesh-provider.md
    type: resource
    note: Documenta projeção de mesh para fabric distribuível.
  - path: scripts/bootstrap-local.sh
    type: pipeline
    note: Script de bootstrap single-node.
risk_level: Medium
compliance:
  privacy: Operadores donos do hardware mantêm residência de dados; mesh privada (sem rede pública) preserva soberania.
  security: Online-only via mesh privada; nada de rede pública por padrão; identidade de host federada via certificados de operador.
  data_classification: PHI permanece no fabric do operador.
observability:
  logs: Cada nó emite logs locais; agregação opcional via mesh, sob governança do operador.
  metrics: Métricas por nó com SLO de disponibilidade (`healthos.node.up`); fabric-level latency p99 < 100ms entre nós próximos.
  traces: `traceparent` entre nós; topologia visível em traces.
testing:
  strategy: Single-node remains canonical para CI; experimentos multi-node são gates separados (não bloqueiam mainline). Contratos topology-invariant validados em ambos.
  coverage_targets: Contratos de storage/provenance passam em both single-node e multi-node experimental sem mudança de superfície.
rollout:
  plan: Single-node já adotado (ADR-0002). Multi-node é opcional, evolutivo, governado por operadores. Sem feature flag global; cada operador decide expansão.
  monitoring: Painel multi-node opcional para operadores que ativarem mesh; alarmes de partição.
---

# ADR 0009 — Single-node bootstrap e topologia de fabric soberano

## Contexto

- **Problema e motivação.** A linguagem "single-node" pode ser lida como "single-node forever", o que implicaria que HealthOS é um sistema local-first/offline-first. Não é. HealthOS é uma plataforma soberana cuja **forma de bootstrap** é single-node, e cuja **projeção de produção** é um fabric Apple Silicon distribuível, operator-owned, online-only via mesh privada.
- **Pressupostos e restrições.** (a) ADR-0001 separa identidade de sistema de forma de deployment; (b) ADR-0002 fixa single-node como mínimo canônico; (c) operadores donos do hardware fornecem soberania (não cloud público).
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Linguagem e contratos diferenciam claramente "bootstrap shape" de "topologia ontológica".
  - **Critério.** Documentação usa consistentemente "single-node bootstrap"; expansão multi-node não exige mudanças constitucionais.

## Decisão

`single-node` permanece a forma canônica mínima de bootstrap/validação para HealthOS, **não** sua definição ontológica.

A projeção de produção é um **fabric soberano de saúde Apple Silicon, operator-owned**:

- fisicamente distribuível (múltiplos hosts em propriedade do operador);
- logicamente um único ambiente operacional HealthOS;
- acesso online-only via superfícies de mesh privada (sem rede pública).

- **Escopo.** Decisão sobre relação entre single-node e topologia de produção; preserva possibilidade de fabric distribuído sem alteração de lei.
- **Justificativa.** Mantém build/test pequeno e reproduzível; evita confundir forma de deployment com identidade de sistema; preserva lei/ontologia canônica enquanto permite evolução topológica; alinha-se com infra privada operator-owned.

## Alternativas Consideradas

### Alternativa A — Single-node ontológico (single-node forever)
- **Prós.** Modelo simples; nenhum esforço para topology-invariance.
- **Contras.** Inviabiliza operadores grandes (clínicas, hospitais) que precisam mais de uma máquina; trava futuro.
- **Rejeitada.**

### Alternativa B — Cloud distribuído desde o início
- **Prós.** Escalabilidade sem limite.
- **Contras.** Quebra soberania; expõe PHI a cloud público; operadores perdem controle físico.
- **Rejeitada.**

### Alternativa C — Single-node bootstrap + fabric soberano (escolhida)
- **Prós.** Bootstrap pequeno, produção realista, soberania preservada.
- **Contras.** Requer disciplina contínua para topology-invariance.

## Consequências

- **Positivas.**
  - Lei e contratos do Core ficam topology-invariant.
  - Evolução multi-node é escala operacional, não rewriting.
  - Documentação prefere "single-node bootstrap" ao invés de "single-node forever".
  - Linguagem "local-first" fica restrita a detalhes de implementação, não identidade de sistema.
- **Negativas / trade-offs.**
  - Toda PR deve evitar suposições single-host sneaky.
  - Mesh provider exige design (ver `docs/architecture/15-mesh-provider.md`).
- **Riscos e mitigação.**
  - **Risco.** Multi-node introduz consistência distribuída fraca. **Mitigação.** Postgres como source of truth (ADR-0006); contratos transactional.
  - **Risco.** Mesh privada mal configurada vira rede pública. **Mitigação.** Runbook de mesh; templates de config; auditoria.

### Não-objetivos

- Esta ADR não introduz implementação multi-node imediata.
- Esta ADR não introduz modo offline ou comportamento offline-first.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Sem alteração na hierarquia (ADR-0001). `HealthOSProviders` ganha `ProviderKind.httpLocal` e, futuramente, providers de mesh privada (nova ADR específica).
- **Conformidade com Package.swift.** Topologia do package permanece igual; multi-node é detalhe de runtime, não de pacote.
- **Concurrency.** Atores Swift continuam aplicáveis; coordenação multi-host se faz via Postgres + APIs governadas, não via shared state.
- **Segurança/Privacidade.** Mesh privada opera com identidades de operador (mTLS); nada exposto em rede pública.
- **Observabilidade.** Métricas por nó + agregação opcional; tracing cruza nós via `traceparent`.
- **Testes.** Single-node é gate canônico de CI; multi-node em pipeline de operador, não em mainline.

## Plano de Adoção e Migração

- **Passos.**
  1. Single-node já adotado (ADR-0002).
  2. Mesh provider design (ver doc 15) → ADR específica antes de implementação.
  3. Operadores adotam expansão multi-node por escolha; rollback é remover hosts.
- **Impacto em APIs e contratos.** Nenhum imediato; mesh provider futuro vira novo `ProviderKind`.
- **Critérios de saída.** Plenamente adotada quando primeiro experimento multi-node passar contratos topology-invariant sem alteração.

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
