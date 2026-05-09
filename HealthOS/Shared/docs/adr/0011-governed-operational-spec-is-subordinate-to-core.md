---
id: ADR-0011
title: Governed Operational Spec é subordinada ao Core (Governed Operational Spec is subordinate to Core)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Core engineering lead, AACI lead]
consulted: [GOS tooling lead (TS), MSR lead, Apps lead, Compliance/Legal advisor]
informed: [All HealthOS contributors, partners de protocolo/política]
tags: [GOS, governed-operational-spec, runtime-binding, compiler, AACI, MSR, ontologia, hierarquia-constitucional, prompts]
modules_impacted:
  - HealthOSCore
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSProviders
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0003, ADR-0004, ADR-0005, ADR-0010]
code_references:
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift
    type: protocol
    note: Tipos canônicos da spec GOS no Core.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GOSFileBackedRegistry.swift
    type: impl
    note: Registry file-backed para bundles GOS.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSBindings.swift
    type: impl
    note: Bindings AACI ↔ GOS primitives.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeActivation.swift
    type: impl
    note: Ativação de GOS no runtime AACI.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeContext.swift
    type: impl
    note: Contexto de runtime para execução GOS.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeResolution.swift
    type: impl
    note: Resolução de execução GOS.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json
    type: resource
    note: Schema canônico machine-readable.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-authoring.schema.json
    type: resource
    note: Schema authoring (human/AI-friendly).
  - path: HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-bundle-manifest.schema.json
    type: resource
    note: Manifesto de bundle.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-lifecycle-audit.schema.json
    type: resource
    note: Auditoria de ciclo de vida.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-review-record.schema.json
    type: resource
    note: Registro de revisão.
  - path: HealthOS/Constructor/ts/packages/healthos-gos-tooling
    type: pipeline
    note: Compilador TS de GOS.
  - path: HealthOS/Shared/docs/architecture/29-governed-operational-spec.md
    type: resource
    note: Documentação de arquitetura GOS.
  - path: HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift
    type: test
    note: Testes de adoção runtime.
risk_level: High
compliance:
  privacy: GOS não contém PHI; é spec compilada. Bundles versionados; ativação requer revisão e aprovação registradas.
  security: Bundles assinados ou validados via schema antes de ativação; lifecycle audit imutável.
  data_classification: Metadados operacionais; sem PHI direto.
observability:
  logs: `gos.bundle.activated{bundle_id,version,actor}`, `gos.execution.completed{spec_id,duration}`, `gos.activation.denied{reason}`.
  metrics: `healthos.gos.bundles.active{kind}`, `healthos.gos.execution.latency_ms`, `healthos.gos.activation.failures.total`, `healthos.gos.compiler.errors.total`.
  traces: Span `gos.execute` com atributos `bundle_id`, `spec_id`, `runtime`, `outcome`.
testing:
  strategy: Compiler tests (TS); contract tests Core↔AACI; integration tests SessionRuntime executando bundle de exemplar; "golden specs" para regressão.
  coverage_targets: Schema validation 100%; compiler warnings ≥ 95% cobertos; integration test passa para `aaci.first-slice` exemplar.
rollout:
  plan: Adotada e materializada (GOS stabilization wave). Novos primitivos requerem evolução de schema + ADR superseding ou complementar.
  monitoring: Painel de bundles ativos por runtime; alarmes em falhas de ativação.
---

# ADR 0011 — Governed Operational Spec é subordinada ao Core

## Contexto

- **Problema e motivação.** HealthOS já modela a camada soberana através da lei do Core (identidade, consent, habilitation, finality, provenance, gate, contratos de storage/access). AACI e outros runtimes precisam de uma forma disciplinada de transformar **linguagem operacional autorada por humano** (políticas, protocolos, guidelines, regras administrativas, instruções de serviço) em **estrutura executável** machine-usable. Sem essa camada intermediária, a tradução vira lógica de prompt ad hoc, não-versionada, não-auditável.
- **Pressupostos e restrições.** (a) Hierarquia constitucional do ADR-0001; (b) compliance arquiteturalizada do ADR-0010; (c) gate humano do ADR-0003 não pode ser eliminado por GOS; (d) authoring deve ser amigável a humano e IA; transport canônico é JSON.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** GOS é a camada declarativa intermediária entre linguagem operacional autorada e execução de runtime.
  - **Critérios.** (a) Bundles GOS são compiláveis, validáveis e versionáveis; (b) runtimes executam GOS sem reimplementar lei do Core; (c) primer GOS para `aaci.first-slice` é executável end-to-end (alcançado).

## Decisão

HealthOS introduz uma camada arquitetural chamada **Governed Operational Spec (GOS)**.

GOS **é**:
- camada declarativa de spec intermediária;
- autorada para colaboração humano/IA (formato declarativo amigável, ex.: YAML);
- compilada para forma canônica machine-readable (JSON sob schema em [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json));
- consumida por runtimes HealthOS como AACI;
- **sempre subordinada à lei do HealthOS Core**.

GOS **não é**:
- a camada constitucional do sistema;
- engine de política alternativa ao core;
- framework de workflow propriedade de app;
- substituto de gate, consent, habilitation ou finality;
- engine clinicamente autônoma de decisão.

### Posicionamento na arquitetura

```
Substrato material
    ↓
HealthOS Core
    ↓
Governed Operational Spec (GOS)
    ↓
HealthOS Runtimes (AACI/MSR/SessionRuntime)
    ↓
Boundary
    ↓
Stage
    ↓
Artefatos / Efeitos
```

GOS pode descrever o que deve ser **extraído, derivado, checado, draftado, cronometrado, escalado, evidenciado**, mas **não pode** sobrepor leis core que determinam se acesso ou efetuação é lícito.

### Famílias de primitivos GOS

GOS é construída de famílias explícitas de spec primitives:
- signal specs
- slot specs
- derivation specs
- task specs
- tool binding specs
- draft output specs
- guard specs
- deadline specs
- evidence hook specs
- human gate requirement specs
- escalation specs
- scope requirement specs

Esses primitivos são constitucionais para GOS, mas **não** para HealthOS como um todo.

### Regra de runtime

Runtimes podem consumir GOS para:
- normalizar guidance operacional natural-language em estruturas executáveis;
- guiar trabalho de extração e estruturação;
- ligar subagentes a responsabilidades bounded;
- preparar drafts e ações administrativas;
- expor deadlines, checks, escalações;
- anexar evidence/provenance hooks.

Runtimes **não** podem usar GOS para burlar:
- consent checks;
- habilitation checks;
- scope/finality checks;
- gate requirements;
- lawful storage boundaries.

### Regra de app

Apps **não** interpretam GOS como fonte de lei. Apps consomem estados/outputs/previews/summaries produzidos por runtimes que executaram sob GOS, mas **não** se tornam intérpretes independentes de lógica regulatória ou de governança (consistente com ADR-0010).

### Forma de authoring

Forma de authoring preferida: declarativa human/AI-friendly (ex.: YAML), compilada para JSON canônico para transporte machine, validação, versioning e binding de execução.

- **Escopo.** Define camada GOS, primitivos, regras de runtime/app, forma de authoring. Não define protocolos clínicos específicos (esses são bundles GOS), nem motor multi-node.
- **Justificativa.** Coloca a tradução natural-language→executável em uma camada governada e versionada, ortogonal à lei do Core.

## Alternativas Consideradas

### Alternativa A — Continuar com prompts/policies ad hoc no código de runtime
- **Prós.** Sem nova camada para construir.
- **Contras.** Não-versionado; impossível auditar; reuse zero; mistura razão clínica com lei.
- **Rejeitada.**

### Alternativa B — Engine de policy independente fora do Core
- **Prós.** Modular.
- **Contras.** Cria segunda constituição; viola ADR-0010 (compliance arquiteturalizada no Core); engenharia paralela.
- **Rejeitada.**

### Alternativa C — GOS subordinada ao Core (escolhida)
- **Prós.** Bundles versionáveis, compiláveis, auditáveis; reuse entre runtimes; lei core permanece autoritativa.
- **Contras.** Requer compiler/validator; vocabulário disciplinado; bindings explícitos.

## Consequências

- **Positivas.**
  - HealthOS tem lugar nativo para compilação de policy/protocol/workflow.
  - Guidance operacional natural-language sai de prompt logic ad hoc.
  - Reuse entre subagentes AACI e runtimes futuros.
  - Evidence/deadlines/guards explícitos, não implícitos.
  - Compiler/runtime evoluem sem mover lei para apps.
- **Negativas / constraints.**
  - Camada de compiler/validator para manter.
  - Disciplina de vocabulário para evitar GOS virar segunda constituição.
  - Bindings explícitos de runtime agents para GOS primitives.

### Não-objetivos

Esta ADR **não** introduz:
- implementações de protocolos cenário-específicos;
- mudanças de execução multi-node;
- modos de execução offline;
- efetuação clínica autônoma;
- compromissos com runtime vendor-específicos.

## Detalhes de Implementação

- **Fronteiras entre módulos.**
  - Tipos canônicos: `HealthOSCore` ([GovernedOperationalSpec.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift), [GOSFileBackedRegistry.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GOSFileBackedRegistry.swift)).
  - Bindings/ativação: `HealthOSAACI` ([GOSBindings.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSBindings.swift), [GOSRuntimeActivation.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeActivation.swift), [GOSRuntimeContext.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeContext.swift), [GOSRuntimeResolution.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeResolution.swift)).
  - Compiler authoring → canonical: `HealthOS/Constructor/ts/packages/healthos-gos-tooling` (TypeScript).
  - Schemas: [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec*.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/).
- **Conformidade com Package.swift.** GOS no Core respeita a hierarquia: Core base → AACI consome (com `dependencies: ["HealthOSCore", "HealthOSProviders"]` em [HealthOS/Package.swift:21](../../../HealthOS/Package.swift:21)). Apps não importam GOS internals.
- **Concurrency.** Activation runs in `actor AACIOrchestrator` ([HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5)); cancelamento estruturado.
- **Segurança/Privacidade.** Bundles validados por schema antes de ativação; lifecycle audit registra ativação/desativação; sem PHI no spec.
- **Observabilidade.** Métricas/logs/traces conforme front matter; cada execução de spec emite `gos.execute` span.
- **Testes.** `GOSRuntimeAdoptionTests` ([HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift)); golden specs para `aaci.first-slice`; testes de compiler em TS.

## Plano de Adoção e Migração

- **Passos.** Já adotada e materializada na "GOS stabilization wave" (ver `HealthOS/Shared/docs/execution/08-gos-stabilization-handoff.md`).
- **Impacto em APIs e contratos.** Tipos públicos no Core são contrato; novos primitivos exigem evolução de schema (`HealthOS/Tier1-Mestral-Core/Schemas/`) e ADR específica.
- **Critérios de saída.** Plenamente adotada — confirmado: arch docs 29-34, schemas, TS compiler scaffold, Swift contracts, file-backed registry, AACI activation seam, first-slice runtime path integrado, exemplar bundle `aaci.first-slice`.

### Status de follow-up (mantido)

Itens encerrados:
- arch docs adicionados: [HealthOS/Shared/docs/architecture/29-governed-operational-spec.md](../architecture/29-governed-operational-spec.md) até [HealthOS/Shared/docs/architecture/34-gos-review-and-activation-policy.md](../architecture/34-gos-review-and-activation-policy.md);
- schema canônico: [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json) e variantes;
- schemas authoring e bundle-manifest adicionados;
- backlog de execução: `HealthOS/Shared/docs/execution/todo/gos-and-compilers.md`;
- compilador TS scaffolded: [HealthOS/Constructor/ts/packages/healthos-gos-tooling/](../../../HealthOS/Constructor/ts/packages/healthos-gos-tooling/);
- contratos Swift scaffolded: [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift) e relacionados;
- registry file-backed e loader: [GOSFileBackedRegistry](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GOSFileBackedRegistry.swift);
- seam de ativação AACI: [GOSRuntimeActivation.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeActivation.swift) e `AACIOrchestrator.activateGOS`;
- caminho de first-slice runtime integrado com ativação GOS;
- bundle exemplar shipped para `aaci.first-slice`.

Status da ADR permanece **Accepted**. Ontologia GOS estabelecida aqui não deve ser alterada sem ADR superseding.

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
