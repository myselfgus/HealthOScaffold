---
id: ADR-0002
title: Single-node é o mínimo canônico de deployment (Single-node is the canonical minimum deployment)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Platform/Infra lead]
consulted: [Core engineering, Apps lead, Operações/Operadores]
informed: [All HealthOS contributors, partners de fabric soberano]
tags: [arquitetura, topologia, deployment, bootstrap, apple-silicon, soberania]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSCLI
  - HealthOSScribeStage
  - HealthOSVeridiaStage
  - HealthOSCloudClinicStage
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0005, ADR-0006, ADR-0009]
code_references:
  - path: HealthOS/Package.swift
    type: pipeline
    note: Plataforma alvo `.macOS(.v26)` — Apple Silicon canonical.
  - path: Makefile
    type: pipeline
    note: Targets `bootstrap`, `swift-build`, `swift-test`, `swift-smoke` validam single-node.
  - path: scripts/bootstrap-local.sh
    type: pipeline
    note: Script de bootstrap canônico para um host.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift
    type: impl
    note: `SessionRunner` opera com `root: URL` local — sem assumir multi-host.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/DirectoryLayout.swift
    type: protocol
    note: Layout de diretório local; não pressupõe filesystem distribuído.
risk_level: Medium
compliance:
  privacy: Single-node simplifica residência de dados (PHI/PII permanece em um host físico controlado pelo operador) e atende soberania do dado em LGPD por padrão.
  security: Superfície de ataque mínima; sem rede pública. Criptografia em repouso (FileVault/macOS) e em trânsito local (loopback) sob ADR-0006.
  data_classification: PHI/PII permanece local até existir uma ADR explícita autorizando travessia.
observability:
  logs: Logs estruturados locais com rotação; nenhuma exfiltração para SaaS por padrão. Campos com PHI passam por redaction conforme ADR-0004.
  metrics: Métricas locais (Prometheus-style file/HTTP local opcional); SLOs single-node — startup < 30s, smoke-tests < 60s.
  traces: Tracing local opcional (OpenTelemetry → arquivo) com sampling controlado.
testing:
  strategy: Unidade + contrato + integração single-node. Smoke tests por executável (`smoke-cli`, `smoke-scribe`, `smoke-veridia`, `smoke-cloudclinic`). Sem testes que exigem múltiplos hosts no caminho default de CI.
  coverage_targets: Todos os módulos buildam e passam testes em um único host Apple Silicon. `make swift-test` é gate canônico.
rollout:
  plan: Adotada como regra desde o scaffold. Topologia multi-node é evolução operacional (ADR-0009), não rewriting.
  monitoring: CI verifica que `make swift-build` e `make swift-test` passam em runner single-host. Detectar regressões que assumam multi-host como obrigatório.
---

# ADR 0002 — Single-node é o mínimo canônico de deployment

## Contexto

- **Problema e motivação.** HealthOS precisa de um alvo concreto e testável que valide ontologia e fronteiras de módulos sem exigir infraestrutura multi-host. Decisões iniciais corriam risco de (a) over-engineering, com consenso distribuído antes de contratos clínicos estáveis, ou (b) under-engineering, com assunções single-node "queimadas" nos contratos.
- **Pressupostos e restrições.** (a) Apple Silicon é a plataforma alvo (`.macOS(.v26)` em [HealthOS/Package.swift:6](../../../HealthOS/Package.swift:6)); (b) operadores podem rodar em hardware próprio; (c) ADR-0009 esclarece que single-node é forma de bootstrap, não topologia permanente.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Toda lei do Core e contratos são topology-invariant.
  - **Critério mensurável.** `make bootstrap && make swift-build && make swift-test` passa em uma máquina Apple Silicon limpa, sem Postgres remoto, sem mesh, sem rede pública. Smoke por executável (`make swift-smoke`) verde.

## Decisão

O primeiro alvo válido de deployment é um único host Apple Silicon. Toda ontologia, fronteiras de módulo e contratos de governança devem **se manter** em um nó. Esta é a forma canônica mínima — a menor topologia que valida a superfície de contratos completa.

Expansão multi-node é **escala operacional**, não reescrita ontológica. Lei do Core e contratos devem ser topology-invariant por design.

- **Escopo.** Decisão sobre topologia mínima de bootstrap e validação. Não congela a topologia; ADR-0009 abre a porta para fabric soberano distribuível.
- **Justificativa.** Permite construir e validar a superfície completa de contratos clínicos (consent, habilitation, gate, finality, provenance, storage) com mínimo overhead, antes de pagar custo de consenso/network partitioning.

## Alternativas Consideradas

### Alternativa A — Multi-node desde o dia zero
- **Prós.** "Pronto para produção distribuída" cedo; força contratos topology-invariant por necessidade.
- **Contras.** Exige consenso distribuído, particionamento de rede, identity resolution remota antes que contratos clínicos estejam estáveis. Custo enorme em código e ops para validar uma superfície ainda em formação.
- **Rejeitada.** Prematuro e não validável em fase de scaffold.

### Alternativa B — Single-node forever
- **Prós.** Modelo mental simples, sem custo distribuído.
- **Contras.** Trava topologia; impede fabric soberano distribuível futuro; conflita com ADR-0009.
- **Rejeitada.** Confunde identidade do sistema com forma de deployment.

### Alternativa C — Single-node como mínimo canônico (escolhida)
- **Prós.** Build/test pequeno e reproduzível; preserva contratos topology-invariant; permite escala futura sem rewrite.
- **Contras.** Requer disciplina para não introduzir suposições single-host nos contratos (ex.: paths absolutos, IDs de processo, tempos baseados em relógio local sem tolerância de skew).

## Consequências

- **Positivas.**
  - Onboarding e CI rápidos: tudo em um host.
  - Contratos Swift/TS não assumem identity resolution multi-host.
  - Documentação canônica usa "single-node bootstrap".
- **Negativas / trade-offs.**
  - Necessário monitorar PRs para detectar suposições single-host indevidas (ex.: locks via filesystem que não funcionariam em mesh).
  - Performance de testes integrados eventualmente exige paralelização sem violar invariantes.
- **Riscos e mitigação.**
  - **Risco.** Contratos vazam suposições single-host. **Mitigação.** Code review + testes de contrato que exercitem `URL`-based vs ID-based references; ADR-0006 define seam local explícito.
  - **Risco.** Operadores leem "single-node" como "single-node forever". **Mitigação.** ADR-0009 + linguagem padronizada nos docs.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Mantidas como em [HealthOS/Package.swift](../../../HealthOS/Package.swift). Single-node não relaxa a hierarquia constitucional (ADR-0001).
- **Conformidade com Package.swift.** Plataforma `.macOS(.v26)`; targets executáveis (CLI, Scribe, Veridia, CloudClinic) constroem e rodam local.
- **Concurrency.** `actor SessionRunner` ([HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift:6](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift:6)) e `actor AACIOrchestrator` ([HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5)) são suficientes para isolamento single-host; cancelamento estruturado (`Task.cancel`) garante shutdown limpo.
- **Segurança/Privacidade.** PHI persistido em `root: URL` controlado pelo operador. Criptografia em repouso herdada do FileVault macOS. Loopback HTTP (ADR-0006) garante que tráfego não saia do host.
- **Observabilidade.** Logs em filesystem local com rotação; sampling local; sem dependência cloud.
- **Testes.** `make swift-build`, `make swift-test`, `make swift-smoke` formam o gate. Suite `HealthOSTests` ([HealthOS/Shared/Tests/HealthOSTests/](../../../HealthOS/Shared/Tests/HealthOSTests/)) cobre fronteiras críticas single-node.

## Plano de Adoção e Migração

- **Passos.** Já adotada. Manutenção: corrigir, em PRs futuras, suposições single-host indevidas.
- **Impacto em APIs e contratos.** Contratos devem ser topology-invariant; nenhum contrato pode exigir hostname/IP local hardcoded.
- **Critérios de saída.** Plenamente adotada quando ADR-0009 estiver materializada com primeiro experimento multi-node passando os mesmos contratos sem mudanças na superfície.

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
