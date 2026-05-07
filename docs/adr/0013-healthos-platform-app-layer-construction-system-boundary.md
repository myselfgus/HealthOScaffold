---
id: ADR-0013
title: HealthOS Platform, App Layer e Construction System permanecem separados
status: Accepted
date: 2026-05-07
deciders: [HealthOS Architecture Council]
consulted: [Core engineering, Runtime engineering, Apps lead, Construction tooling lead]
informed: [All HealthOS contributors]
tags: [arquitetura, apps, plataforma, construction-system, app-boundary, governanca]
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
  related: [ADR-0001, ADR-0007, ADR-0010, ADR-0011, ADR-0012]
code_references:
  - path: docs/architecture/50-app-layer-boundary-and-reference-apps.md
    type: resource
    note: Canonical architecture doc for app-agnostic layering and task ordering.
  - path: docs/execution/21-structural-ontology-and-product-readiness-plan.md
    type: resource
    note: Queue reordered by platform/runtime/boundary/charter/app implementation tiers.
  - path: AGENTS.md
    type: resource
    note: Agent instructions require layer classification before task acceptance.
risk_level: High
compliance:
  privacy: Apps receive only mediated, app-safe surfaces; direct identifiers remain governed by Core/storage policy.
  security: App wiring cannot bypass platform/runtime readiness, Core law, gate, or provenance.
  data_classification: App-facing surfaces must remain redacted, scoped, and classified by the layer that provides them.
observability:
  logs: Task classification and blockers must be recorded in execution tracking.
  metrics: N/A for this documentation decision.
  traces: App traces may consume mediated state only after the providing layer is implemented and stable.
testing:
  strategy: Documentation validation plus PR review of tier mapping; source code is unchanged by this ADR.
  coverage_targets: ADR index, architecture doctrine, execution queue, TODOs, handoff, and prompt template.
rollout:
  plan: Adopt immediately for task selection and prompt generation. Reclassify app wiring tasks blocked until platform surfaces and App Charters are ready.
  monitoring: Review all future work units for explicit layer classification and app-surface readiness evidence.
---

# ADR 0013 - HealthOS Platform, App Layer e Construction System permanecem separados

## Contexto

- **Problema e motivacao.** Docs e trackers recentes eram corretos ao dizer que Scribe, Veridia e CloudClinic nao sao law engines, mas ainda podiam sugerir uma ordem errada: criar wiring de app porque o contrato existe, mesmo quando a superficie mediada que o app consumiria ainda nao esta implementada e estavel. Isso produz scaffold falso que parece progresso de produto, mas tende a ser reescrito quando a plataforma amadurece.
- **Pressupostos e restricoes.** HealthOS e a plataforma inteira (ADR-0001); apps nao sao Core (ADR-0007); compliance vive em seams de Core (ADR-0010); GOS e subordinado (ADR-0011); HealthOScaffold e o repositorio/fase de construcao de HealthOS (ADR-0012). Esta ADR nao altera codigo.
- **Objetivos e criterios de sucesso.**
  - **Objetivo 1.** HealthOS permanece app-agnostic: pode existir sem qualquer app especifico.
  - **Objetivo 2.** App wiring so avanca depois que a superficie mediada consumida esta implementada e estavel, nao apenas contratada.
  - **Objetivo 3.** Construction System fica fora da hierarquia clinica/runtime e nao vira plataforma nem app.
  - **Criterio.** Todo task tracker e prompt novo classifica o trabalho por layer/tier antes de aceitar implementacao.

## Decisao

HealthOS deve ser tratado como uma plataforma app-agnostic composta por camadas separadas:

| Layer | Responsabilidade | Nunca deve fazer |
|---|---|---|
| Platform/Core Layer | Core, invariantes, contratos soberanos, storage law, consentimento, habilitacao, finalidade, provenance e gate | Absorver semantica de app especifico |
| Runtime/Mediation Layer | Session Runtime, AACI, GOS, MSR, providers e runtimes TS subordinados ao Core | Virar lei constitucional ou autorizar ato por si |
| App Integration Boundary | Facades, envelopes, app-safe views, safe refs, command/result envelopes e mediated state | Fingir estabilidade quando a superficie fornecedora nao existe |
| Reference App Layer | Scribe, Veridia, CloudClinic e futuros apps em numero arbitrario | Definir Core, runtimes, invariantes, GOS, AACI, MSR ou storage law |
| Construction System | Steward, Settler, Territory, Settlement e HealthOS Forge MCP | Virar runtime clinico, app, Core law, ou autoridade de merge |

Regra vinculante: **app wiring avanca somente depois que a superficie mediada que o app consome esta implementada e estavel, nao apenas contratada.**

Scribe, Veridia e CloudClinic sao reference apps iniciais / exemplos de consumidores. Eles nao sao a totalidade nem a ontologia do HealthOS. Podem existir muitos apps; nenhum app especifico define HealthOS.

## Alternativas Consideradas

### Alternativa A - Tratar os reference apps iniciais como conjunto definidor
- **Pros.** Facilita demonstracoes e planejamento visual inicial.
- **Contras.** Faz a plataforma parecer dependente de tres apps fixos; incentiva mover semantica de app para Core; dificulta apps futuros.
- **Rejeitada.**

### Alternativa B - Permitir app wiring assim que contratos existirem
- **Pros.** Produz artefatos executaveis cedo.
- **Contras.** Contrato sem superficie implementada/estavel gera scaffold falso e reescrita futura; apps passam a inferir comportamento ausente.
- **Rejeitada.**

### Alternativa C - Plataforma estavel antes de boundary/app charter/wiring
- **Pros.** Preserva HealthOS app-agnostic; evita wiring em superficies ausentes; mantem scaffold validado honesto.
- **Contras.** Apps avancam mais devagar quando dependem de plataforma/runtime incompletos.
- **Escolhida.**

## Consequencias

- **Positivas.**
  - Tarefas de plataforma que fornecem superficies consumiveis por apps devem avancar antes de novo wiring de app.
  - Tarefas de app bloqueadas passam a declarar dependencia objetiva e criterio de desbloqueio.
  - Construction-system work independente pode rodar em paralelo sem virar plataforma, runtime ou app.
  - Existing Scribe and Veridia scaffold remains valid evidence of boundary scaffolding, not a reason to continue app wiring before upstream surfaces stabilize.
- **Negativas / trade-offs.**
  - APP-012 e tarefas semelhantes deixam de ser o proximo passo automatico quando dependem de superficies instaveis.
  - Prompt generation para app implementation deve ser mais criterioso e pode virar App Charter/boundary-readiness work primeiro.
- **Riscos e mitigacao.**
  - **Risco.** Bloquear app work demais por conservadorismo. **Mitigacao.** Platform/runtime/construction tasks independentes permanecem READY quando desbloqueadas.
  - **Risco.** Classificacao ambigua. **Mitigacao.** Marcar `needs-review` em vez de inventar status.

### Nao-objetivos

Esta ADR nao:
- remove scaffold validado;
- implementa APP-012 ou qualquer adapter novo;
- altera Swift, TypeScript, SQL, schemas ou package manifests;
- declara HealthOS production-ready;
- declara Scribe, Veridia ou CloudClinic como unicos apps possiveis.

## Detalhes de Implementacao

- **Fronteiras entre modulos.** Nenhuma mudanca de codigo nesta ADR. Futuras mudancas devem preservar Core abaixo de runtimes e apps acima de mediated boundaries.
- **Task ordering.** `docs/execution/21-structural-ontology-and-product-readiness-plan.md` deve mapear tasks abertas em tiers:
  1. Platform/Core
  2. Runtime/Mediation
  3. App Integration Boundary
  4. App Charter
  5. App Implementation
  6. Construction System
- **App Charter.** Todo app novo, e todo novo wiring substancial de app existente, exige App Charter antes da implementacao.
- **Construction System.** Steward, Settler, Territory, Settlement e HealthOS Forge MCP continuam ferramentas de engenharia, nao runtime clinico.
- **Seguranca/privacidade.** App-facing state deve permanecer app-safe, redigido, provenance-facing quando aplicavel, e sem raw direct identifiers.
- **Testes.** Este trabalho e documental; validacao minima: `git diff --check`, `make validate-docs`, `make validate-contracts`, diagnostics de linguagem e diagnostics read-only de vazamento em Core.

## Plano de Adocao e Migracao

1. Criar o doc canonico de App Layer Boundary e App Charter.
2. Atualizar AGENTS/CLAUDE e template do Steward para exigir classificacao de tier.
3. Reclassificar tasks abertas: plataforma independente fica READY; app wiring fica BLOCKED quando depende de superficies ausentes/instaveis ou App Charter incompleto; ambiguo vira `needs-review`.
4. Registrar drift de linguagem e ordering sem reescrever historico de validacoes honestas.

## Checklist de Completude

- [x] Status e data corretos; front matter preenchido.
- [x] Drivers, objetivos e criterios de sucesso mensuraveis.
- [x] Alternativas com pros/contras reais e nao triviais.
- [x] Consequencias, riscos e mitigacao registrados.
- [x] Fronteiras entre Platform/Core, Runtime/Mediation, App Integration Boundary, Reference App Layer e Construction System definidas.
- [x] Regra de app wiring depois de superficie implementada/estavel documentada.
- [x] App Charter exigido antes de implementacao futura de app.
- [x] Plano de validacao documental definido.
- [x] Relacoes entre ADRs atualizadas.
