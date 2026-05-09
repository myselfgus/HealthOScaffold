---
id: ADR-0007
title: HealthOS não tem UX de usuário-final própria (HealthOS has no end-user UX of its own)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Apps lead]
consulted: [Core engineering, Design lead, Operações]
informed: [All HealthOS contributors, app teams]
tags: [arquitetura, ux, apps, plataforma, scribe, veridia, cloudclinic, cli, separação-de-camadas]
modules_impacted:
  - HealthOSCore
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
  related: [ADR-0001, ADR-0010]
code_references:
  - path: HealthOS/Shared/Sources/HealthOSCLI/CLIEntrypoint.swift
    type: impl
    note: CLI é superfície canônica de operador.
  - path: HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe
    type: impl
    note: Scribe — app focado em ditado/escriba; UX de profissional, não da plataforma.
  - path: HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia
    type: impl
    note: Veridia — app verificador/visualizador; UX de profissional/auditor.
  - path: HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic
    type: impl
    note: CloudClinic — app de cenário cloud/clinic; UX de cuidado.
  - path: HealthOS/Shared/docs/architecture/19-interface-doctrine.md
    type: resource
    note: Doutrina de interface alinhada a esta ADR.
risk_level: Low
compliance:
  privacy: Apps recebem superfícies pseudonimizadas (ADR-0004); plataforma não acumula PHI por engagement metrics.
  security: CLI/admin surfaces autenticadas via tokens locais; apps consomem APIs governadas; sem janela de admin pública.
  data_classification: Plataforma: técnico/operador. Apps: PHI sob governança herdada do Core.
observability:
  logs: Plataforma emite logs operacionais; apps emitem logs de UX/clínicos com redaction. Separação por `process` label.
  metrics: SLOs por app são responsabilidade do app team; SLOs operadores são responsabilidade da plataforma.
  traces: Spans cruzam fronteira app↔runtime via `traceparent`; root span identifica `surface=app:scribe|veridia|cloudclinic|cli`.
testing:
  strategy: Apps testam UX/usuário; plataforma testa contratos/CLI. Sem teste de UX no Core.
  coverage_targets: Apps mantêm cobertura UX-driven; Core mantém cobertura contract-driven.
rollout:
  plan: Decisão estrutural; aplicada desde scaffold. Novas surfaces: classificar como (a) app/interface ou (b) operador/admin antes de aceitar PR.
  monitoring: Auditoria de PR — qualquer adição de UX clínica ao Core/Runtime é flagrada.
---

# ADR 0007 — HealthOS não tem UX de usuário-final própria

## Contexto

- **Problema e motivação.** Misturar UX de usuário-final ao núcleo da plataforma cria gravidade incorreta: a lógica de UX começa a infiltrar contratos de governança e a lei do Core; o resultado é apps fracos com plataforma inflada, ou plataforma com lei diluída em ergonomia.
- **Pressupostos e restrições.** (a) HealthOS é a constituição (ADR-0001); (b) compliance é arquiteturalizada (ADR-0010); (c) apps existem para entregar UX clínica e operacional.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Plataforma e apps têm responsabilidades não-sobrepostas.
  - **Critério.** Toda UX direcionada a paciente/profissional reside em app; toda lei reside em Core. Adições mistas são revisadas e segregadas antes de mergear.

## Decisão

HealthOS, como plataforma core, **não é** ele próprio um produto de UI/UX para usuário-final.

Suas superfícies canônicas de operador são:
- CLI (`HealthOSCLI`)
- APIs locais/admin/serviço
- ferramentas de engenharia/runtime
- workflows de coding/ops assistidos por agente (Steward etc.)

UX de usuário-final pertence a HealthOS/Tier4-Stages-Cast/AppDocs/interfaces construídos sobre HealthOS, como:
- **Scribe** ([HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe](../../../HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe))
- **Veridia** ([HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia](../../../HealthOS/Tier4-Stages-Cast/Veridia/Sources/Veridia))
- **CloudClinic** ([HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic](../../../HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/CloudClinic))
- HealthOS/Tier4-Stages-Cast/AppDocs/interfaces futuros

- **Escopo.** Decisão sobre onde UX clínica/UX-paciente vive. Não proíbe ferramentas administrativas/dashboards técnicos.
- **Justificativa.** Preserva separação entre lei da plataforma e apresentação ergonômica; impede que lógica de governança vaze para código de interface; mantém HealthOS como ambiente soberano, não shell de app.

## Alternativas Consideradas

### Alternativa A — HealthOS empacota um app principal "oficial"
- **Prós.** Caminho mais curto para um produto vendável.
- **Contras.** Plataforma e UX se misturam; cada app futuro compete com o "oficial"; apps de terceiros viram cidadãos de segunda classe.
- **Rejeitada.**

### Alternativa B — HealthOS expõe UX via SDK clichê
- **Prós.** Padroniza UX entre apps.
- **Contras.** SDK de UX engessa apps; impede inovação e diferenciação; viola separação.
- **Rejeitada.**

### Alternativa C — Plataforma sem UX de usuário-final, apps com UX (escolhida)
- **Prós.** Separação limpa; apps inovam livremente sob compliance comum (ADR-0010).
- **Contras.** Time de plataforma não tem "produto" visível para usuário-final; precisa investir em DX/operador-UX.

## Consequências

- **Positivas.**
  - Distinção clara entre lei da plataforma e ergonomia.
  - Lógica de governança não "vaza" para código de interface.
  - HealthOS Core/Runtime fica enxuto.
  - Ecossistema de apps cresce sem dependência de "app oficial".
- **Negativas / trade-offs.**
  - Plataforma precisa investir em DX (CLI, APIs admin, observabilidade) para ser usável.
  - Cada app team replica ergonomia comum (mitigado por design system compartilhado em [HealthOS/Shared/DesignSystem/](../../../HealthOS/Shared/DesignSystem/), fora de Core).
- **Riscos e mitigação.**
  - **Risco.** "Vai-só-um-componentinho-de-UI-no-Core". **Mitigação.** Code review + esta ADR como referência.

### Não-objetivo

Esta ADR **não** proíbe ferramentas administrativas internas ou dashboards técnicos. Apenas afirma que essas ferramentas não constituem a UX humana clínica/usuário-final canônica da plataforma.

## Detalhes de Implementação

- **Fronteiras entre módulos.** `HealthOSCore`, `HealthOSProviders`, `HealthOSAACI`, `HealthOSMSR`, `HealthOSSessionRuntime` não importam frameworks de UX (SwiftUI, AppKit). Apps fazem isso (ver [HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/Views/](../../../HealthOS/Tier4-Stages-Cast/Scribe/Sources/Scribe/Views/)). CLI usa apenas APIs de terminal.
- **Conformidade com Package.swift.** `HealthOSCLI`/`Scribe`/`Veridia`/`CloudClinic` são executáveis; libs core/runtime não.
- **Concurrency.** N/A para esta decisão.
- **Segurança/Privacidade.** Surfaces de operador não exibem PHI direta; apps seguem ADR-0004.
- **Observabilidade.** Cada superfície identifica-se em telemetria.
- **Testes.** UX testes em apps; contratos no Core.

## Plano de Adoção e Migração

- **Passos.** Estrutural. Toda nova adição revisada antes de mergear.
- **Impacto em APIs e contratos.** APIs operadoras vivem na plataforma; APIs UX vivem em apps.
- **Critérios de saída.** Permanece válida enquanto a separação plataforma/app for organizacionalmente clara.

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
