---
id: ADR-0004
title: Visibilidade operacional com identificadores protegidos (Operational visibility with protected identifiers)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Privacy/Compliance lead, Clinical lead]
consulted: [Core engineering, Apps lead, Provenance/audit lead]
informed: [All HealthOS contributors, operadores, auditores externos]
tags: [privacidade, LGPD, HIPAA, pseudonimização, re-identificação, provenance, governança]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSScribeApp
  - HealthOSVeridiaApp
  - HealthOSCloudClinicApp
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0003, ADR-0008, ADR-0010]
code_references:
  - path: swift/Sources/HealthOSCore/ReidentificationGovernance.swift
    type: protocol
    note: Contrato e governança para re-identificação auditada (habilitação + gate quando aplicável).
  - path: swift/Sources/HealthOSCore/StorageContracts.swift
    type: protocol
    note: Layers de storage forçam separação de identidade direta vs pseudônimo.
  - path: swift/Sources/HealthOSCore/Provenance.swift
    type: impl
    note: Provenance registra acesso a registros identificáveis com ator/finalidade/base legal.
  - path: swift/Sources/HealthOSCore/CoreLaw.swift
    type: protocol
    note: `CoreLawError.missingReidentificationScope` força escopo lawful explícito.
  - path: swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift
    type: protocol
    note: Vocabulário canônico para envelopes evita vazamento de identificadores diretos.
  - path: swift/Tests/HealthOSTests/StorageGovernanceTests.swift
    type: test
    note: Cobre separação de identificadores e violações esperadas.
risk_level: High
compliance:
  privacy: Pseudonimização no ingress; re-identificação como operação auditada com base legal explícita; minimização aplicada em superfícies de app.
  security: Tabela de mapeamento direto-↔-pseudônimo segregada com controle de acesso reforçado; chaves de re-identificação separadas dos dados pseudonimizados.
  data_classification: PHI (direto) e PHI-pseudonimizado (categorizado como "indiretamente identificável").
observability:
  logs: Logs operacionais usam apenas pseudônimos (`patient_pseudo_id`, `session_id`). Re-identificação emite evento dedicado `reidentification.performed` com legal_basis, actor, scope. Redaction obrigatório.
  metrics: `healthos.reidentification.events.total{legal_basis,actor_role}`, `healthos.identifier.leak.detected.total` (alerta).
  traces: Spans em superfícies de app usam apenas pseudônimo; spans de re-identificação carregam `legal_basis` mas nunca o identificador direto.
testing:
  strategy: Testes adversariais que tentam acessar identificadores diretos sem habilitação; testes de contrato de storage; golden tests para garantir que payloads cross-app/cross-runtime não vazem identidade direta.
  coverage_targets: 100% das funções públicas que tocam identidade direta exercitadas em teste com path autorizado e path negado. Nenhum log/trace produzido em testes contém PII direta.
rollout:
  plan: Decisão estrutural; aplicada desde o scaffold. Toda nova superfície (provider, runtime, app) deve declarar mapeamento de identificadores em design review.
  monitoring: Painel `identifier-leak-detector` (regex em logs/streams) com alerta crítico para qualquer match. SLO: zero detections em 30 dias rolling.
---

# ADR 0004 — Visibilidade operacional com identificadores protegidos

## Contexto

- **Problema e motivação.** Uma abordagem ingênua de "privacy by blindness" faria HealthOS incapaz de processar seu próprio conteúdo operacional — precisaria de sistemas externos para dados que o próprio HealthOS deve governar, derrotando seu propósito como plataforma soberana de saúde. O extremo oposto — visibilidade irrestrita — exporia identificadores diretos do paciente em todas as superfícies, violando LGPD, HIPAA e criando risco massivo de re-identificação. O sistema deve ver o suficiente para funcionar e proteger o que precisa ser protegido.
- **Pressupostos e restrições.** (a) Soberania exige processamento local de dados clínicos; (b) LGPD/HIPAA exigem minimização e finalidade; (c) re-identificação às vezes é lícita (cuidado direto) e deve ser permitida sob auditoria.
- **Objetivos e critérios de sucesso.**
  - **Objetivo 1.** Identificadores diretos (nome, CPF/SSN, contato, número completo de prontuário) só circulam em superfícies privilegiadas, sob base legal explícita.
  - **Objetivo 2.** Re-identificação é evento auditado, nunca rotina silenciosa.
  - **Critérios mensuráveis.** (a) Zero ocorrências de PII direta em logs/traces de runtime/app (verificado por scanner em CI); (b) 100% de eventos de re-identificação com `legal_basis`, `actor_id`, `scope` em provenance.

## Decisão

HealthOS **não é cego** ao próprio conteúdo operacional. Ele pode e deve processar dados de sessão clínica, registros e artefatos para cumprir seu propósito. **No entanto**, identificadores diretos (nomes, CPF/SSN, contato, número completo de prontuário) são fortemente separados nos seams arquiteturais.

Mecanismos de proteção:

| Mecanismo | Onde |
|---|---|
| Pseudonimização no ingress | Superfícies de captura (Scribe, MSR ingest) substituem direto por pseudônimo estável o quanto antes. |
| Separação forte | Superfícies de app recebem referências pseudonimizadas, nunca identificadores diretos brutos. |
| Re-identificação auditada | Operação explícita, logada, gated por habilitação ([ReidentificationGovernance.swift](../../swift/Sources/HealthOSCore/ReidentificationGovernance.swift)). |
| Provenance | Todo acesso a registro identificável é registrado com ator, timestamp, finalidade, base legal ([Provenance.swift](../../swift/Sources/HealthOSCore/Provenance.swift)). |

- **Escopo.** Toda travessia de identidade entre camadas (capture → storage → runtime → app) e toda emissão de telemetria.
- **Justificativa.** Único modelo que satisfaz simultaneamente soberania computacional, minimização legal e auditabilidade.

## Alternativas Consideradas

### Alternativa A — Privacy by blindness (sem processamento de identidade)
- **Prós.** Risco de vazamento próximo de zero.
- **Contras.** HealthOS torna-se inútil para captura de sessão, geração de SOAP, gestão de prontuário. Plataforma não governa o que não vê.
- **Rejeitada.**

### Alternativa B — Visibilidade total sem separação
- **Prós.** Implementação simples; código mais direto.
- **Contras.** Viola LGPD/HIPAA; risco massivo em todo seam; dificulta auditoria; vazamentos catastróficos por log.
- **Rejeitada.**

### Alternativa C — Visibilidade operacional com identificadores protegidos (escolhida)
- **Prós.** A plataforma processa o que precisa, protege o que deve, e re-identificação é exceção governada.
- **Contras.** Custos de implementação (mapping table segregada, scanners em CI, contratos cuidadosos para envelopes).

## Consequências

- **Positivas.**
  - Apps (Scribe, Veridia, CloudClinic) consomem apenas referências pseudonimizadas (ADR-0007 + ADR-0010).
  - Storage contracts garantem separação ao nível de schema, não convenção (`StorageContracts.swift`).
  - Re-identificação requer habilitação + gate (quando há efeito clínico) + provenance.
  - Dashboards de operador mostram pseudônimos.
- **Negativas / trade-offs.**
  - Engenharia adicional para tokenização e mapeamento.
  - Scanner de PII em logs precisa ser mantido e rodar em CI.
- **Riscos e mitigação.**
  - **Risco.** Vazamento de identificador direto via log/trace de exceção. **Mitigação.** Redaction nos `errorDescription`s do Core; scanner em CI; alerta crítico se detectado em runtime.
  - **Risco.** Tabela de mapeamento comprometida → re-identificação massiva. **Mitigação.** Segregação física/lógica + criptografia + acesso gated por habilitação + auditoria.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Pseudonimização ocorre em ingress (HealthOSMSR / HealthOSSessionRuntime) e é canonicalizada por contratos em HealthOSCore (`StorageContracts`, `SharedEnvelopeVocabulary`). Apps recebem `*PseudoId`; nunca `directIdentifier`.
- **Conformidade com Package.swift.** Tipos canônicos no Core; nenhum app redefine.
- **Concurrency.** Operações de re-identificação executam em `actor` dedicado para serializar acesso à tabela de mapping; backpressure via `Task` cooperativo.
- **Segurança/Privacidade.** Mapeamento criptografado em repouso (chave por operador); rotação documentada em runbook (`docs/architecture/14-operations-runbook.md`).
- **Observabilidade.** Métricas e logs conforme front matter. Painel `identifier-leak-detector`.
- **Testes.** `StorageGovernanceTests`, `RetrievalMemoryGovernanceTests`, `UserSovereigntyGovernanceTests` ([swift/Tests/HealthOSTests/](../../swift/Tests/HealthOSTests/)).

## Plano de Adoção e Migração

- **Passos.** Já adotado no scaffold. Toda nova superfície (provider remoto sob ADR-0006, novo app, nova integração) deve passar por design review com checklist de identificadores.
- **Impacto em APIs e contratos.** APIs que retornem entidades clínicas usam tipos pseudonimizados por padrão; variantes "direct" são funções separadas, gated.
- **Critérios de saída.** Quando scanner em CI roda automaticamente em todos os módulos com 30 dias rolling sem detection, pode-se considerar plenamente adotada.

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
