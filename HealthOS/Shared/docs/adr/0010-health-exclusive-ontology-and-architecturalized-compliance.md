---
id: ADR-0010
title: Ontologia health-exclusiva e compliance arquiteturalizada (Health-exclusive ontology and architecturalized compliance)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Clinical lead, Compliance/Legal advisor]
consulted: [Core engineering, Apps lead, Operações, Provenance/audit lead]
informed: [All HealthOS contributors, app teams, operadores]
tags: [arquitetura, compliance, ontologia, saúde, LGPD, HIPAA, CFM, governança, seams, plataforma]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSMSR
  - HealthOSSessionRuntime
  - HealthOSScribeStage
  - HealthOSVeridiaStage
  - HealthOSCloudClinicStage
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0003, ADR-0004, ADR-0007, ADR-0011]
code_references:
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift
    type: protocol
    note: Sede da lei (consent/habilitation/scope/finality/storage/gate).
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift
    type: impl
    note: Governança regulatória centralizada.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift
    type: impl
    note: Provenance como cidadão de primeira classe.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift
    type: protocol
    note: Soberania do usuário/paciente em contratos típicos.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift
    type: impl
    note: Acoplamento entre gate e finalização regulada.
  - path: HealthOS/Shared/Tests/HealthOSTests/RegulatoryGovernanceTests.swift
    type: test
    note: Testes de seam regulatório.
risk_level: High
compliance:
  privacy: Lei centralizada simplifica DPIA e auditoria LGPD/HIPAA — controlador único, política única.
  security: Apps proibidos de reimplementar lei; superfície de violação reduzida.
  data_classification: PHI + identidade profissional + provenance.
observability:
  logs: Eventos de seam (consent.checked, habilitation.validated, gate.requested, gate.resolved, reidentification.performed) emitidos no Core; apps consomem mas não emitem cópias.
  metrics: `healthos.law.violation.attempts.total{kind}` (alerta crítico); `healthos.seam.bypass.attempts.total` (alerta crítico).
  traces: Cada chamada que cruza seam de lei tem span dedicado com decisão (allow/deny) e razão.
testing:
  strategy: Testes adversariais que tentam burlar lei via apps; testes de contrato app↔Core; goldens regulatórios.
  coverage_targets: Cada lei (consent/habilitation/scope/finality/gate/storage) tem cobertura ≥ 95% em paths permitido/negado.
rollout:
  plan: Estrutural; aplicado desde scaffold. Onboarding de novo app inclui "seam conformance check" como gate.
  monitoring: Painel de violations/bypass attempts; revisão trimestral de surfaces de app.
---

# ADR 0010 — Ontologia health-exclusiva e compliance arquiteturalizada

## Contexto

- **Problema e motivação.** HealthOS é um sistema de saúde, não infraestrutura cloud genérica com plugin opcional de saúde. Tratar compliance como camada opcional ou bibliotecária resulta em duplicação regulatória, drift entre apps e custo enorme de auditoria. Compliance precisa ser **propriedade arquitetural**, não política documental.
- **Pressupostos e restrições.** (a) ADR-0001 fixa HealthOS como sistema; (b) ADR-0003 fixa gate humano; (c) ADR-0004 fixa identificadores protegidos; (d) ADR-0011 fixa GOS subordinada ao Core.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Compliance vive em seams do Core; apps consomem; não reimplementam.
  - **Critérios mensuráveis.** Apps passam "seam conformance check" antes de release; zero implementações duplicadas de consent/habilitation/gate fora do Core (auditável por grep arquitetural em CI).

## Decisão

HealthOS é **health-exclusivo por ontologia** e **não deve** ser modelado como infra cloud genérica com plugins de saúde opcionais.

Compliance é **arquiteturalizada em seams/contratos do Core**.

Apps/interfaces consomem esses seams e **não devem** reimplementar consent, habilitation, gate, provenance ou policy engines de governança.

- **Escopo.** Decisão sobre onde lei reside e como apps consomem. Vincula vinculantemente: Core é o único lugar de consent/habilitation/gate/finality/scope/provenance.
- **Justificativa.** Coerência de domínio em um core governado; redução de duplicação regulatória; ecossistema de apps cresce com postura de compliance consistente; primitivos health-native explícitos (registro/habilitação profissional, consent purpose-bound, gate, provenance).

## Alternativas Consideradas

### Alternativa A — Compliance como biblioteca opcional
- **Prós.** Apps "leves" sem dependência de lei.
- **Contras.** Cada app reimplementa lei; auditoria fragmentada; drift garantido.
- **Rejeitada.**

### Alternativa B — Compliance documental (não arquitetural)
- **Prós.** Implementação inicial mais rápida.
- **Contras.** Política sem enforcement; depende de disciplina humana; falha sob pressão.
- **Rejeitada.**

### Alternativa C — Compliance arquiteturalizada em seams (escolhida)
- **Prós.** Lei viva no Core; apps consomem; auditoria centralizada; primitivos health-native explícitos.
- **Contras.** Core fica mais "pesado"; precisa governar evolução de seams cuidadosamente.

## Consequências

- **Positivas.**
  - Documentação de arquitetura e doutrina de app descrevem compliance como nativa da plataforma.
  - Apps focam em UX/workflow, não em policy engines.
  - Onboarding de app inclui "seam conformance check".
  - Auditoria regulatória (LGPD/HIPAA/CFM) é endereçável a um core único.
- **Negativas / trade-offs.**
  - Mudanças de seam exigem revisão arquitetural cuidadosa (impactam todos os apps).
  - Apps inovadores precisam negociar extensões via ADR/spec, não unilateralmente.
- **Riscos e mitigação.**
  - **Risco.** Apps tentam contornar seam por conveniência. **Mitigação.** Tipos do Core não expõem caminhos sem-governança; testes adversariais; ADR-0007 reforça separação.
  - **Risco.** Core engessa por excesso de seam-specific code. **Mitigação.** Manter seams ortogonais e bem nomeados; refatorar com supersedência via ADR.

### Boundary

Esta decisão governa seams da plataforma e fluxos controlados.
Não pretende prevenir todo uso malicioso de bytes legitimamente recebidos por um processo de app.

Esse risco residual é mitigado por:
- revisão/licenciamento/governança de apps;
- permissões e distribuição constrained;
- auditabilidade e credenciais revogáveis.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Lei vive em [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift), [GateContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift), [RegulatoryGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift), [ReidentificationGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ReidentificationGovernance.swift), [UserSovereigntyContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift), [Provenance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift), [BackupGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/BackupGovernance.swift).
- **Conformidade com Package.swift.** Apps dependem de Core; Core não depende de apps. Nenhuma redefinição de contratos de lei fora de Core.
- **Concurrency.** Atores garantem serialização em pontos de aplicação de lei.
- **Segurança/Privacidade.** Lei aplicada antes de qualquer travessia que toque PHI.
- **Observabilidade.** Eventos de seam emitidos no Core; apps consomem.
- **Testes.** `RegulatoryGovernanceTests`, `UserSovereigntyGovernanceTests`, `StorageGovernanceTests` ([HealthOS/Shared/Tests/HealthOSTests/](../../../HealthOS/Shared/Tests/HealthOSTests/)).

## Plano de Adoção e Migração

- **Passos.** Adotada desde scaffold. Cada novo app passa por "seam conformance check" antes de release. Cada nova capacidade clínica que precise de lei adicional deve evoluir o seam no Core via ADR/spec, não criar lei paralela em app.
- **Impacto em APIs e contratos.** Estrutural; APIs públicas do Core são contrato regulatório.
- **Critérios de saída.** Plenamente adotada quando: (a) onboarding de app inclui automated seam conformance check; (b) zero violações em CI por 90 dias rolling.

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
