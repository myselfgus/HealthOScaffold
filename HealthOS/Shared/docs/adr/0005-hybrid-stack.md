---
id: ADR-0005
title: Stack híbrida — Swift, TypeScript, Python (Hybrid stack)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Platform/Infra lead]
consulted: [Core engineering, Apps lead, ML/Research lead, Tooling lead]
informed: [All HealthOS contributors]
tags: [stack, linguagens, swift, typescript, python, plataforma, swift6, apple-silicon]
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
  related: [ADR-0001, ADR-0002, ADR-0006, ADR-0009]
code_references:
  - path: HealthOS/Package.swift
    type: pipeline
    note: swift-tools-version 6.2; plataforma `.macOS(.v26)`; todos os módulos HealthOS são Swift.
  - path: HealthOS/Constructor/ts/package.json
    type: pipeline
    note: TypeScript workspace para tooling, agent-infra, GOS compiler.
  - path: HealthOS/Constructor/ts/packages
    type: resource
    note: Pacotes TS (incluindo `healthos-gos-tooling`) — orquestração e MCP.
  - path: HealthOS/Support/python/pyproject.toml
    type: pipeline
    note: Python isolado para offline ML; nunca runtime clínico.
  - path: Makefile
    type: pipeline
    note: Gates `swift-build`, `swift-test`, `ts-build`, `ts-test`, `python-check` independentes.
risk_level: Medium
compliance:
  privacy: Linguagens não tocam diretamente em PHI no caminho clínico exceto Swift (runtime); Python permanece em pipelines offline com dados anonimizados/sintéticos.
  security: Swift garante memory safety; TypeScript em processo de tooling separado; Python sem caminho de produção evita superfície de ataque adicional.
  data_classification: Swift atua sobre PHI; TypeScript e Python NÃO atuam sobre PHI no caminho ao vivo.
observability:
  logs: Logs por linguagem/processo com correlação via `correlation_id` no seam Swift↔TS (ADR-0006).
  metrics: Métricas separadas por runtime; agregação via labels (`process=swift|ts|python`).
  traces: Traces cruzam Swift↔TS via headers HTTP loopback (`traceparent`).
testing:
  strategy: Gates de CI independentes por linguagem; testes de contrato Swift↔TS via JSON Schemas compartilhados.
  coverage_targets: `make swift-test` e `make ts-test` verdes; `make python-check` verde. Adicionar 4ª linguagem requer ADR superseding explícita.
rollout:
  plan: Adotada desde scaffold. Ponto de revisão se Swift server-side madurar a ponto de absorver tooling, ou se um runtime ML precisar virar online (gatilho para nova ADR).
  monitoring: Acompanhar custo de manutenção por linguagem (PRs/mês, build minutes) — sinaliza se a relação benefício/custo mudou.
---

# ADR 0005 — Stack híbrida: Swift, TypeScript, Python

## Contexto

- **Problema e motivação.** HealthOS exige (a) integração nativa macOS/Apple Silicon para runtime local, (b) orquestração assíncrona de serviços para pipelines de sessão e tooling, (c) suporte a ML/fine-tuning para desenvolvimento de modelos. Nenhuma linguagem única atende às três bem; escolher uma só força hacks de integração nativa (TS/Python puros) ou anti-padrões de service/async (Swift puro).
- **Pressupostos e restrições.** (a) Runtime clínico precisa ser nativo Apple Silicon; (b) tooling/infra/agentes operam melhor em Node/TS; (c) ML moderno é Python-first; (d) o seam Swift↔TS é ADR-0006.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Cada linguagem é alocada à camada que ela serve melhor; os seams são explícitos.
  - **Critérios.** `make swift-build`, `make ts-build`, `make python-check` são gates independentes; cada um pode ser executado e validado em isolamento.

## Decisão

HealthOS usa stack deliberada de três linguagens, com cada uma alocada à camada que ela serve melhor:

| Linguagem | Versão/alvo | Papel |
|---|---|---|
| **Swift** | Swift 6.2, `.macOS(.v26)` ([HealthOS/Package.swift](../../HealthOS/Package.swift)) | Núcleo, runtime nativo, providers, apps macOS (Scribe/Veridia/CloudClinic), CLI. Concurrency via `actor` e structured concurrency. |
| **TypeScript** | Node moderno, workspace TS ([HealthOS/Constructor/ts/package.json](../../HealthOS/Constructor/ts/package.json)) | Serviços assíncronos, APIs, tooling de orquestração, infra de agente (Steward, Steward MCP), compilador GOS, scripts CI/CD. |
| **Python** | Pyproject ([HealthOS/Support/python/pyproject.toml](../../HealthOS/Support/python/pyproject.toml)) | Pipelines offline de ML, fine-tuning, processamento de dados. **Nunca** no caminho clínico ao vivo. |

- **Escopo.** Decisão sobre linguagens permitidas e fronteiras de uso. Não decide framework específico (ex.: SwiftUI vs AppKit fica em outra ADR/spec).
- **Justificativa.** Cada linguagem ocupa o nicho onde sua tooling/maturidade entrega o maior valor por menor risco; seams explícitos (ADR-0006) tornam a heterogeneidade auditável.

## Alternativas Consideradas

### Alternativa A — TypeScript-only
- **Prós.** Stack única; tooling unificada.
- **Contras.** Integração macOS via FFI/Node-API ou Electron é frágil; APIs Apple (audio, system) ficam awkward; performance/latência piores no caminho clínico.
- **Rejeitada.**

### Alternativa B — Swift-only
- **Prós.** Type-safety end-to-end; um runtime.
- **Contras.** Ecosistema server-side Swift menos maduro para tooling/MCP/agent infra; Python ML não tem equivalente Swift.
- **Rejeitada.**

### Alternativa C — Python-first com Swift para UI
- **Prós.** Faz sentido para projetos data-science.
- **Contras.** Python não atende latência baixa em runtime clínico Apple Silicon; sem integração nativa fluida.
- **Rejeitada para runtime; mantida para ML offline.**

### Alternativa D — Stack híbrida (escolhida)
- **Prós.** Cada linguagem no seu ponto forte; seams explícitos via ADR-0006.
- **Contras.** Maior custo cognitivo (3 toolchains); seam Swift↔TS exige disciplina.

## Consequências

- **Positivas.**
  - Todo código de plataforma macOS, contratos de runtime e shells de app são Swift.
  - Toda orquestração assíncrona, tooling de agente, MCP servers e tooling de GOS são TypeScript.
  - Python permanece offline-only; nenhum risco de regressão de runtime ao vivo.
  - Contratos cross-language são validados via JSON Schemas compartilhados em `HealthOS/Tier1-Mestral-Core/Schemas/`.
- **Negativas / trade-offs.**
  - Build matrix maior; CI mais demorada.
  - Onboarding requer fluência em pelo menos duas linguagens.
- **Riscos e mitigação.**
  - **Risco.** Drift entre Swift e TS no seam (esquemas divergentes). **Mitigação.** Schemas compartilhados em `HealthOS/Tier1-Mestral-Core/Schemas/`; `make validate-schemas` no CI; testes de contrato em ambos lados.
  - **Risco.** Python "vaza" para runtime ao vivo. **Mitigação.** Política explícita aqui; CI de produção não tem Python no caminho de execução; runbooks documentam separação.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Swift para `HealthOS*` em [swift/](../../swift/); TS para tooling em [HealthOS/Constructor/ts/](../../HealthOS/Constructor/ts/); Python isolado em [HealthOS/Support/python/](../../HealthOS/Support/python/). Seam Swift↔TS é loopback HTTP + Postgres + filesystem (ADR-0006).
- **Conformidade com Package.swift.** Todos os 9 produtos (5 libs + 4 executáveis) e 1 test target são Swift puros, sem dependências em Node/Python.
- **Concurrency.** Swift: `actor`/structured concurrency. TS: async/await + workers. Python: jobs offline, sem concorrência clínica relevante.
- **Segurança/Privacidade.** Swift opera sobre PHI; TS toca metadados governance; Python opera sobre datasets sintéticos/anonimizados.
- **Observabilidade.** `correlation_id` propagado pelo seam HTTP; cada runtime emite logs estruturados.
- **Testes.** Independentes: `make swift-test`, `make ts-test`, `make python-check`. Contrato cruzado via schemas.

## Plano de Adoção e Migração

- **Passos.** Adotada. Adicionar uma 4ª linguagem requer ADR superseding explícita com justificativa e seam.
- **Impacto em APIs e contratos.** Linguagem é detalhe interno por camada; o que cruza é JSON sob schema validado.
- **Critérios de saída.** Continua válida enquanto: (a) Swift mantiver primazia macOS; (b) tooling/agent infra preferir Node/TS; (c) Python permanecer offline.

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
