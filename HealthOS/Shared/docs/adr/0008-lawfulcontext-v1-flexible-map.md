---
id: ADR-0008
title: lawfulContext continua mapa canônico flexível em v1 (lawfulContext remains a flexible canonical map in v1)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Core engineering lead]
consulted: [Storage/governance lead, Apps lead]
informed: [All HealthOS contributors]
tags: [arquitetura, contratos, lawful-context, transport, v1, evolução-de-schema, governança]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0002, ADR-0004, ADR-0011]
code_references:
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift
    type: protocol
    note: `CoreLawfulContext` expõe campos canônicos + `raw: [String:String]` flexível.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift
    type: protocol
    note: `ProviderRoutingRequest.lawfulContext: [String: String]` em transporte.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift
    type: protocol
    note: Vocabulário canônico de chaves.
risk_level: Low
compliance:
  privacy: Mapa não relaxa lei; chaves canônicas sustentam minimização e auditoria.
  security: Validação no Core (`CoreLawError.invalidLawfulContext`) impede payloads malformados.
  data_classification: Metadados de governança (não-PHI; identificadores como UUIDs e papéis).
observability:
  logs: Todas as chaves canônicas são allowlisted em logs estruturados; chaves desconhecidas são descartadas/logadas como warning, nunca emitidas em telemetria pública.
  metrics: `healthos.lawfulcontext.unknown_key.total{key}` indica drift; `healthos.lawfulcontext.invalid.total` correlaciona com erros de validação.
  traces: Atributos derivados do lawfulContext (actorRole, scope, finalidade) propagam-se em spans relevantes; identificadores diretos jamais.
testing:
  strategy: Testes de validação positiva/negativa para todas as chaves canônicas; goldens para combinações comuns (cuidado direto, billing, retrieval governado).
  coverage_targets: 100% das chaves canônicas listadas têm teste de validação; transitions inválidas geram `CoreLawError`.
rollout:
  plan: V1 mantém mapa flexível. Versão futura introduz envelope tipado por nova ADR sem alterar lei.
  monitoring: Acompanhar contadores de chaves desconhecidas/invalid; gatilho para envelope rígido quando estabilidade for alta.
---

# ADR 0008 — `lawfulContext` continua mapa canônico flexível em v1

## Contexto

- **Problema e motivação.** Diferentes situações de acesso requerem chaves bounded distintas; rigidificar prematuramente o transporte de `lawfulContext` causaria churn antes de paths de acesso estabilizarem. A primeira implementação single-node (ADR-0002) também se beneficia de menor fricção em transporte.
- **Pressupostos e restrições.** (a) Lei do Core já está ancorada em consent/habilitation/finality/owner scope (ADR-0001); (b) ADR-0004 exige que identificadores diretos passem por canais governados; (c) GOS (ADR-0011) ainda evolui e seu vocabulário deve poder expandir.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Transport de lawfulContext flexível em v1, sem relaxar a lei.
  - **Critérios.** Mapa usa apenas chaves canônicas em uso; chaves novas são introduzidas via PR com revisão; validação no Core permanece estrita.

## Decisão

Para o scaffold e a primeira onda de implementação, `lawfulContext` permanece como **mapa canônico flexível** (ex.: `[String: String]`), e não como schema de envelope rígido.

Flexível **não significa arbitrário**. O mapa deve usar **chaves canônicas** quando aplicáveis:

- `actorRole`
- `actorUserId`
- `serviceId`
- `patientUserId`
- `habilitationId`
- `consentBasis`
- `finalidade`
- `sessionId`
- `scope`
- `accessBasis`

`HealthOSCore` define `CoreLawfulContext` ([HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift](../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift)) com campos canônicos tipados **e** um campo `raw: [String: String]` para o transporte flexível.

- **Escopo.** Decisão sobre forma de transporte de lawfulContext em v1. Não decide vocabulário final, nem reclassifica chaves.
- **Justificativa.** Reduz churn em fase de scaffold; mantém lei estrita validando no Core.

## Alternativas Consideradas

### Alternativa A — Envelope rígido tipado desde v1
- **Prós.** Type-safety end-to-end; refatorar é fácil em IDE.
- **Contras.** Cada nova chave exige PR de schema, breaking change em código gerado, churn em todos os consumidores antes do vocabulário estabilizar.
- **Rejeitada para v1.**

### Alternativa B — Mapa totalmente arbitrário sem chaves canônicas
- **Prós.** Maior flexibilidade.
- **Contras.** Sem chaves canônicas, governança fica frouxa; auditoria e logs viram caos.
- **Rejeitada.**

### Alternativa C — Mapa canônico flexível (escolhida)
- **Prós.** Equilibra evolução de vocabulário com governança estrita; `CoreLawfulContext` tipado para chaves canônicas + `raw` para flexibilidade.
- **Contras.** Discipline necessária para manter chaves canônicas atualizadas e validadas.

## Consequências

- **Positivas.**
  - Implementações de runtime/storage aceitam mapa em v1 sem fricção.
  - Documentação fornece exemplos de lawfulContext canônico (em [HealthOS/Shared/docs/architecture/](../architecture/)).
  - Versão futura pode introduzir envelope mais rígido **sem mudar a lei** — apenas o transport.
- **Negativas / trade-offs.**
  - Validação centralizada no Core é gargalo arquitetural — precisa cobrir todas as chaves canônicas em uso.
  - Risco de "stringly-typed code" se desenvolvedores deixarem de usar `CoreLawfulContext` tipado.
- **Riscos e mitigação.**
  - **Risco.** Vocabulário desvia em diferentes runtimes. **Mitigação.** Documentação canônica + métrica `lawfulcontext.unknown_key.total` para detectar drift.
  - **Risco.** Chave sensível (ex.: nome paciente) entra no mapa indevidamente. **Mitigação.** Validação anti-PII no Core; testes; ADR-0004 reforça.

### Não-objetivo

Esta ADR **não** enfraquece lei de acesso. Apenas posterga tipagem estrita do payload de transporte.

## Detalhes de Implementação

- **Fronteiras entre módulos.** `HealthOSCore` define o contrato canônico. Runtimes/Providers consomem via `CoreLawfulContext` ou via mapa raw quando atravessando seam (ADR-0006).
- **Conformidade com Package.swift.** Tipo no Core; nenhum módulo redefine.
- **Concurrency.** `CoreLawfulContext` é `Sendable`; pode atravessar atores sem custo.
- **Segurança/Privacidade.** Validação fail-closed: ausência de campos obrigatórios → `CoreLawError`.
- **Observabilidade.** Métricas de chaves desconhecidas/invalid; logs com chaves canônicas allowlisted.
- **Testes.** Validação positiva/negativa para combinações canônicas; testes de erro para campos faltantes.

## Plano de Adoção e Migração

- **Passos.** Adotada em v1. Migração para envelope rígido futuro segue:
  1. Estabilizar vocabulário (reduzir `unknown_key.total` a zero por 90 dias).
  2. Nova ADR define envelope.
  3. Coexistência por release de transição com `raw` aceitando map.
  4. Deprecação do path map-only.
- **Impacto em APIs e contratos.** Mínimo em v1; envelope futuro será migração coordenada.
- **Critérios de saída.** Plenamente adotada quando vocabulário converge e é coberto por testes.

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
