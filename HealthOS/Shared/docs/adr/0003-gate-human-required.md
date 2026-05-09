---
id: ADR-0003
title: Human gate é obrigatório para artefatos clínicos e regulatórios (Human gate is required for regulatory and clinical artifacts)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Clinical lead (Dr. Gustavo Mendes e Silva), Compliance/Legal advisor]
consulted: [AACI engineering, MSR engineering, Apps lead, Provenance/audit lead]
informed: [All HealthOS contributors, app users (clinicians/operators)]
tags: [governança, gate, fail-closed, consent, habilitation, provenance, regulatório, clínico, CFM, LGPD, HIPAA]
modules_impacted:
  - HealthOSCore
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - Scribe
  - Veridia
  - CloudClinic
  - HealthOSCLI
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0004, ADR-0010, ADR-0011]
code_references:
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift
    type: protocol
    note: Tipos canônicos `GateRequest`, `GateResolution`, `GateRequestStatus` — gate é seam do Core.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift
    type: protocol
    note: `CoreLawError.gateApprovalRequired`, `regulatedFinalizationDenied` — fail-closed por design.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift
    type: impl
    note: Provenance liga artefato → gate event → ator resolvedor.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift
    type: impl
    note: Acoplamento entre gate e finalização regulada.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift
    type: impl
    note: `SimpleGateService` instanciado e exposto na orquestração da sessão.
  - path: HealthOS/Shared/Tests/HealthOSTests/RegulatoryGovernanceTests.swift
    type: test
    note: Cobre paths de finalização regulada e gating obrigatório.
risk_level: High
compliance:
  privacy: Eventos de gate são persistidos em provenance com identificação do ator (ID profissional), timestamp e racional. Sem PHI no campo de rationale (validado por contrato).
  security: Habilitation profissional é validada antes da resolução. Resolução é assinada/registrada e imutável; tentativa de bypass é erro de runtime (`gateApprovalRequired`).
  data_classification: PHI (artefato clínico em draft) + identidade profissional (PII).
observability:
  logs: `gate.requested`, `gate.resolved{action=approved|rejected|deferred}`, `gate.bypass_attempt` (alerta crítico). Sem PHI em payload de log; apenas IDs.
  metrics: `healthos.gate.pending.count`, `healthos.gate.resolution.latency_seconds` (histogram), `healthos.gate.rejection.rate`, `healthos.gate.bypass_attempt.total` (alerta se > 0).
  traces: Span `gate.resolution` com atributos `actor_id`, `draft_id`, `decision`, `requires_signature`. PHI redacted.
testing:
  strategy: Unidade (validação de transição de estado), contrato (entre AACI e Core), integração (SessionRunner ponta-a-ponta produz draft → exige gate → finaliza). Golden tests para mensagens de erro fail-closed.
  coverage_targets: Cobertura de branches em `GateContracts`/`RegulatoryGovernance` ≥ 95%. Todo path que produz artefato clínico testa cenário "sem gate → falha".
rollout:
  plan: Já parte da constituição. Toda nova capacidade que produza artefato com efeito clínico/regulatório deve declarar requisito de gate em ADR específica ou inherit por contrato.
  monitoring: Alarme dedicado para `gate.bypass_attempt > 0` em qualquer ambiente. Painel de latência de resolução de gate por especialidade/serviço.
---

# ADR 0003 — Human gate é obrigatório para artefatos clínicos e regulatórios

## Contexto

- **Problema e motivação.** Runtimes HealthOS (especialmente AACI e MSR) processam dados de sessão clínica, produzem rascunhos (SOAP, atestados, encaminhamentos) e geram outros artefatos com potencial efeito regulatório/clínico. Sem um gate humano obrigatório, um artefato gerado por IA poderia ser aplicado diretamente ao prontuário ou fluxo do paciente — burlando o juízo clínico, exigência ética e legalmente mandatória na prática médica brasileira (CFM) e em jurisdições análogas (HIPAA, FDA SaMD).
- **Pressupostos e restrições.** (a) A responsabilidade clínica é pessoal, intransferível, do profissional habilitado; (b) IA é assistente, nunca decisor autônomo em efeito clínico; (c) artefatos com potencial efeito devem ser fail-closed.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Nenhum artefato com efeito clínico/regulatório atinge estado final sem aprovação humana habilitada e registrada.
  - **Critério mensurável.** 100% das transições de `draft → final` em runtimes HealthOS passam por `GateResolution` válida com `actor_id`, `decision`, `rationale`, `timestamp`. Tentativas de bypass falham com `CoreLawError.gateApprovalRequired` em testes adversariais.

## Decisão

Qualquer artefato com efeito regulatório ou clínico permanece em estado `draft` até que um **gate humano** o resolva explicitamente para um estado final (`approved` ou `rejected`). Nenhum runtime, agente ou superfície de app pode burlar ou auto-resolver o gate.

Resolução de gate exige:
- ator humano explícito com habilitação apropriada (validada em [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift) e governança em [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift));
- decisão registrada (approve / reject / defer) com racional;
- registro de proveniência ligando artefato, evento de gate e ator resolvedor (ver `Provenance.swift`).

- **Escopo.** Todos os artefatos gerados por runtimes HealthOS com potencial efeito clínico, regulatório, financeiro (billing) ou administrativo regulado.
- **Justificativa.** Única opção consistente com fail-closed posture e responsabilidade profissional intransferível.

## Alternativas Consideradas

### Alternativa A — Auto-aprovação para outputs de IA com alta confiança
- **Prós.** Maior throughput; menos atrito clínico.
- **Contras.** Confidência de modelo não substitui juízo clínico; nenhum modelo elimina responsabilidade legal por efetuação autônoma; viola CFM/HIPAA/FDA SaMD.
- **Rejeitada categoricamente.**

### Alternativa B — Soft gate (default-approve com opt-out)
- **Prós.** UX mais suave; "default-aprovado" reduz fricção em fluxos de baixo risco.
- **Contras.** Inverte fail-closed para fail-open; ônus de rejeitar passa ao humano em vez de aprovar; auditoria fica hostil em casos de incidente.
- **Rejeitada.**

### Alternativa C — Gate humano obrigatório (escolhida)
- **Prós.** Fail-closed; alinhamento ético/legal; auditoria simples (presença de `GateResolution` é binária).
- **Contras.** Custo de UX para profissional; latência intrínseca; requer ergonomia cuidadosa em apps.

## Consequências

- **Positivas.**
  - Qualquer ambiente HealthOS é defensável regulatoriamente em auditoria.
  - Apps focam UX; lei vive no Core (ADR-0010).
  - Provenance fica completa por construção.
- **Negativas / trade-offs.**
  - Apps precisam expor gate como cidadão de primeira classe (ver ADR-0007 sobre UX em apps).
  - Latência de resolução pode tornar workflows assincronos; runtimes devem suportar `defer`.
- **Riscos e mitigação.**
  - **Risco.** App tenta bypass por conveniência. **Mitigação.** Tipos do Core não expõem `markAsFinalized` sem `GateResolution`; teste adversarial (ver `RegulatoryGovernanceTests`).
  - **Risco.** Resolução em massa sem revisão real ("rubber stamp"). **Mitigação.** Exigir rationale não-vazio; medir latência por draft (resoluções < 5s para casos clinicamente complexos sinalizam rubber stamping).
  - **Risco.** PHI vaza em `rationale`. **Mitigação.** Contrato de validação em `GateRequest`/`GateResolution`; redaction obrigatório em logs.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Tipos canônicos em `HealthOSCore` ([HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift)). Runtimes (AACI/MSR/SessionRuntime) emitem `GateRequest` e consomem `GateResolution`. Apps oferecem UX para resolver. **Apps NÃO definem novos tipos de gate.**
- **Conformidade com Package.swift.** `GateContracts` em `HealthOSCore` é dependência transitiva de todos os runtimes e apps. Nenhuma camada acima do Core pode redefinir gate.
- **Concurrency.** `SimpleGateService` (em `HealthOSSessionRuntime`) opera dentro do `actor SessionRunner`. Resolução é cancelável; `defer` mantém estado pendente persistente.
- **Segurança/Privacidade.** Habilitation validada antes; rationale validado; provenance imutável.
- **Observabilidade.** Métricas/logs/traces conforme front matter. Alarme crítico em `bypass_attempt`.
- **Testes.** `RegulatoryGovernanceTests`, `VeridiaSessionFacadeTests` e cobertura adicional em `HealthOSTests`.

## Plano de Adoção e Migração

- **Passos.** Decisão constitucional; não há rollout fásico. Cada nova capacidade clínica deve, em sua ADR/spec, declarar pontos de gate.
- **Impacto em APIs e contratos.** Toda função pública que finalize artefato regulado exige `GateResolution` no caminho.
- **Critérios de saída.** Plenamente adotada quando: (a) toda finalização regulada está coberta por testes adversariais; (b) zero alarmes de bypass em CI/staging por 90 dias consecutivos.

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
