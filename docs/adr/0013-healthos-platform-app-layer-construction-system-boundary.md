---
id: ADR-0013
title: HealthOS hierarchy, Stage/Custom, Boundary e Construction System permanecem separados
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
  - HealthOSScribeStage
  - HealthOSVeridiaStage
  - HealthOSCloudClinicStage
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
    note: Queue reordered by Core/GOS/runtime/Boundary/Stage hierarchy, Custom readiness, and external Construction System class.
  - path: AGENTS.md
    type: resource
    note: Agent instructions require layer classification before task acceptance.
risk_level: High
compliance:
  privacy: Stages receive only mediated, app-safe surfaces; direct identifiers remain governed by Core/storage policy.
  security: Stage wiring cannot bypass Core/GOS/runtime/Boundary readiness, Core law, gate, or provenance.
  data_classification: Stage-facing surfaces must remain redacted, scoped, and classified by the layer that provides them.
observability:
  logs: Task classification and blockers must be recorded in execution tracking.
  metrics: N/A for this documentation decision.
  traces: Stage traces may consume mediated state only after the providing layer is implemented and stable.
testing:
  strategy: Documentation validation plus PR review of tier mapping; source code is unchanged by this ADR.
  coverage_targets: ADR index, architecture doctrine, execution queue, TODOs, handoff, and prompt template.
rollout:
  plan: Adopt immediately for task selection and prompt generation. Reclassify Stage wiring tasks blocked until Core/GOS/runtime/Boundary surfaces and Customs are ready.
  monitoring: Review all future work units for explicit layer classification and app-surface readiness evidence.
---

# ADR 0013 - HealthOS hierarchy, Stage/Custom, Boundary e Construction System permanecem separados

## Contexto

- **Problema e motivacao.** Docs e trackers recentes eram corretos ao dizer que Scribe, Veridia e CloudClinic nao sao law engines, mas ainda podiam sugerir uma ordem errada: criar wiring de app porque o contrato existe, mesmo quando a superficie mediada que o app consumiria ainda nao esta implementada e estavel. Isso produz scaffold falso que parece progresso de produto, mas tende a ser reescrito quando a plataforma amadurece.
- **Pressupostos e restricoes.** HealthOS e a plataforma inteira (ADR-0001); apps nao sao Core (ADR-0007); compliance vive em seams de Core (ADR-0010); GOS e subordinado (ADR-0011); HealthOScaffold e o repositorio/fase de construcao de HealthOS (ADR-0012). Esta ADR nao altera codigo.
- **Objetivos e criterios de sucesso.**
  - **Objetivo 1.** HealthOS permanece app-agnostic: pode existir sem qualquer app especifico.
  - **Objetivo 2.** Stage wiring so avanca depois que a superficie mediada consumida esta implementada e estavel, nao apenas contratada, e depois que o Custom relevante esta completo.
  - **Objetivo 3.** Construction System fica fora da hierarquia clinica/runtime e nao vira plataforma nem app.
  - **Criterio.** Todo task tracker e prompt novo classifica o trabalho por layer/tier antes de aceitar implementacao.

## Decisao

HealthOS deve ser tratado como uma plataforma composta pela hierarquia constitucional:

| Layer | Responsabilidade | Nunca deve fazer |
|---|---|---|
| Core | CoreLaw: consent, habilitation, storage law, provenance, gate, finality, audit, invariantes e contratos soberanos | Absorver semantica de Stage especifico |
| GOS | Mediacao operacional subordinada a CoreLaw | Virar lei constitucional ou autorizar ato por si |
| Runtimes | Session Runtime, AACI, MSR, Async Runtime, User-Agent Runtime, Service Runtime e providers subordinados a Core/GOS | Virar lei constitucional ou autorizar ato por si |
| Boundary | Facades, envelopes, app-safe views, safe refs, command/result envelopes, mediated state, degraded state e consumable surfaces | Fingir estabilidade quando a superficie fornecedora nao existe |
| Stage | Scribe, Veridia, CloudClinic e futuros consumidores governados em numero arbitrario | Definir Core, GOS, Runtimes, Boundary, invariantes ou storage law |
| Custom | Definicao CoreLaw-governed de um Stage: capacidades, limites, superficies consumidas, atores, degradacao, validacao e proibicoes | Virar tier separado ou autoridade do Stage |
| Construction System | Steward, Settlers, Territories, Settlements e HealthOS Forge MCP | Virar runtime clinico, Stage, Core law, ou autoridade de merge |

Regra vinculante: **Stage wiring avanca somente depois que a superficie mediada que o Stage consome esta implementada e estavel, nao apenas contratada, e depois que o Custom relevante esta completo.**

Scribe, Veridia e CloudClinic sao Stages iniciais / exemplos de consumidores governados. Eles nao sao a totalidade nem a ontologia do HealthOS. Podem existir muitos Stages; nenhum Stage especifico define HealthOS.

Custom nao e um tier separado da hierarquia HealthOS. Stage e o ultimo tier da hierarquia HealthOS; a arquitetura interna de cada Stage pertence ao universo interno desse Stage.

## Alternativas Consideradas

### Alternativa A - Tratar os Stages iniciais como conjunto definidor
- **Pros.** Facilita demonstracoes e planejamento visual inicial.
- **Contras.** Faz a plataforma parecer dependente de tres apps fixos; incentiva mover semantica de app para Core; dificulta apps futuros.
- **Rejeitada.**

### Alternativa B - Permitir Stage wiring assim que contratos existirem
- **Pros.** Produz artefatos executaveis cedo.
- **Contras.** Contrato sem superficie implementada/estavel gera scaffold falso e reescrita futura; apps passam a inferir comportamento ausente.
- **Rejeitada.**

### Alternativa C - Core/GOS/runtime/Boundary/Custom readiness antes de Stage wiring
- **Pros.** Preserva HealthOS app-agnostic; evita wiring em superficies ausentes; mantem scaffold validado honesto.
- **Contras.** Apps avancam mais devagar quando dependem de plataforma/runtime incompletos.
- **Escolhida.**

## Consequencias

- **Positivas.**
  - Tarefas de Core/GOS/runtime/Boundary que fornecem superficies consumiveis por Stages devem avancar antes de novo Stage wiring.
  - Tarefas de Stage bloqueadas passam a declarar dependencia objetiva e criterio de desbloqueio.
  - Construction-system work independente pode rodar em paralelo sem virar plataforma, runtime ou app.
  - Existing Scribe and Veridia scaffold remains valid evidence of Boundary scaffolding, not a reason to continue Stage wiring before upstream surfaces stabilize.
- **Negativas / trade-offs.**
  - APP-012 e tarefas semelhantes deixam de ser o proximo passo automatico quando dependem de superficies instaveis.
  - Prompt generation para Stage implementation deve ser mais criterioso e pode virar Custom/Boundary-readiness work primeiro.
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

- **Fronteiras entre modulos.** Nenhuma mudanca de codigo nesta ADR. Futuras mudancas devem preservar Core abaixo de GOS/Runtimes, Boundary como fronteira HealthOS-owned, e Stages como consumidores governados.
- **Task ordering.** `docs/execution/21-structural-ontology-and-product-readiness-plan.md` deve mapear tasks abertas por hierarquia e classe externa:
  1. Core
  2. GOS / Runtimes
  3. Boundary
  4. Stage
  - External: Construction System
- **Custom.** Todo Stage novo, e todo novo wiring substancial de Stage existente, exige Custom antes da implementacao. Custom e CoreLaw-governed e aplicado via Boundary; nao e tier separado.
- **Construction System.** Steward, Settlers, Territories, Settlements e HealthOS Forge MCP continuam ferramentas de engenharia, nao runtime clinico.
- **Seguranca/privacidade.** Stage-facing state deve permanecer app-safe, redigido, provenance-facing quando aplicavel, e sem raw direct identifiers.
- **Testes.** Este trabalho e documental; validacao minima: `git diff --check`, `make validate-docs`, `make validate-contracts`, diagnostics de linguagem e diagnostics read-only de vazamento em Core.

## Plano de Adocao e Migracao

1. Criar/atualizar o doc canonico de Boundary, Stage e Custom.
2. Atualizar AGENTS/CLAUDE e template do Steward para exigir classificacao por hierarquia HealthOS ou Construction System externo.
3. Reclassificar tasks abertas: Core/GOS/runtime/Boundary independente fica READY; Stage wiring fica BLOCKED quando depende de superficies ausentes/instaveis ou Custom incompleto; ambiguo vira `needs-review`.
4. Registrar drift de linguagem e ordering sem reescrever historico de validacoes honestas.

## Checklist de Completude

- [x] Status e data corretos; front matter preenchido.
- [x] Drivers, objetivos e criterios de sucesso mensuraveis.
- [x] Alternativas com pros/contras reais e nao triviais.
- [x] Consequencias, riscos e mitigacao registrados.
- [x] Fronteiras entre Core, GOS, Runtimes, Boundary, Stage e Construction System definidas.
- [x] Regra de Stage wiring depois de superficie implementada/estavel documentada.
- [x] Custom exigido antes de implementacao futura de Stage e registrado como nao-tier.
- [x] Plano de validacao documental definido.
- [x] Relacoes entre ADRs atualizadas.
