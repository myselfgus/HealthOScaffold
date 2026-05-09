---
id: ADR-0001
title: HealthOS é o sistema inteiro (HealthOS is the whole system)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Gustavo Mendes e Silva (clinical+architecture lead)]
consulted: [Core engineering, Governance/Compliance lead, Apps lead (Scribe/Veridia/CloudClinic)]
informed: [All HealthOS contributors, downstream app teams, operators]
tags: [arquitetura, identidade-de-sistema, hierarquia-constitucional, governança, core, runtimes, apps]
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
  related: [ADR-0007, ADR-0010, ADR-0011, ADR-0012]
code_references:
  - path: HealthOS/Package.swift
    type: pipeline
    note: Topologia de módulos materializa a hierarquia (Core base; Providers→Core; AACI/MSR→Core+Providers; SessionRuntime→Core+AACI+Providers+MSR; Apps→Core+SessionRuntime ou Core).
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift
    type: impl
    note: Sede da lei constitucional (CoreLawError, CoreLawfulContext, validações).
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift
    type: protocol
    note: Tipos GOS no Core, deixando claro que GOS é subordinada à constituição (ADR-0011).
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift
    type: impl
    note: AACIOrchestrator é runtime DENTRO do HealthOS, não o produto.
  - path: HealthOS/Shared/docs/architecture/01-overview.md
    type: resource
    note: Documentação de visão geral espelha a hierarquia constitucional.
risk_level: High
compliance:
  privacy: A identidade do sistema é a âncora para LGPD/HIPAA — sem identidade clara, controlador/operador legal fica ambíguo. Esta ADR fixa "HealthOS" como controlador lógico para fins de minimização e finalidade.
  security: Privilégio mínimo é interpretado a partir da hierarquia constitucional; apps não herdam privilégios do Core além dos seams expostos.
  data_classification: Meta-decisão (não governa dados diretamente; governa onde a lei sobre dados reside).
observability:
  logs: Toda telemetria de runtime/agente/app deve incluir tag de camada (`layer=core|gos|runtime|agent|app|artifact`) para rastrear trânsito entre camadas. Sem PHI nas tags.
  metrics: Cardinalidade controlada via enum `layer`. Conta de atravessamentos de seams (`healthos.layer.transition.total{from,to}`) detecta desvios de governança.
  traces: Span raiz por sessão deve ter atributo `healthos.system_identity=HealthOS`; spans descendentes herdam para correlação.
testing:
  strategy: Teste arquitetural — verificar que HealthOS/Tier4-Stages-Cast/AppDocs/runtimes não publicam types públicos que reimplementam law (consent, gate, habilitation) e que dependem dos contracts do Core. Testes de fronteira em `HealthOSTests`.
  coverage_targets: 100% das declarações de targets em Package.swift respeitando direção de dependência; nenhum target violando hierarquia.
rollout:
  plan: Decisão constitucional já adotada; não há rollout incremental. Esforço contínuo: detectar e corrigir violações em PRs (review checklist + lint arquitetural).
  monitoring: Auditoria de PRs com a checklist desta ADR; CI valida `swift build` por target garantindo respeito ao grafo declarado em Package.swift.
---

# ADR 0001 — HealthOS é o sistema inteiro

## Contexto

- **Problema e motivação.** Em fases iniciais de design houve risco de tratar AACI, Scribe ou apps individuais como o "produto principal", com HealthOS como rótulo guarda-chuva difuso. Esta confusão constitucional faz com que a lógica de governança (consent, habilitation, gate, finality, provenance) migre para a camada errada e fragmenta a lei do núcleo. O nome `HealthOScaffold` agrava o risco de implicar que o repositório é "pré-HealthOS" em vez de HealthOS em maturidade de scaffold (ver ADR-0012).
- **Pressupostos e restrições.** (a) Existe uma constituição única e auditável; (b) compliance regulatório (LGPD, HIPAA-aware, CFM) exige identidade clara de controlador/operador; (c) o Swift Package em [HealthOS/Package.swift](../../../HealthOS/Package.swift) já materializa a hierarquia em direção de dependências.
- **Objetivos e critérios de sucesso.**
  - **Objetivo 1.** Toda decisão sobre lei (consent/habilitation/gate/finality/provenance/storage) tem um único endereço: `HealthOSCore`.
  - **Objetivo 2.** Runtimes (AACI/MSR/SessionRuntime), agentes/atores e apps consomem a lei do Core; nunca a definem.
  - **Critério mensurável.** Zero ocorrências, em código de runtime/app, de redefinição de tipos `Consent*`, `Gate*`, `Habilitation*` fora do Core (verificável via `grep` arquitetural em CI).

## Decisão

HealthOS é o ambiente computacional soberano inteiro — o sistema. Todo runtime, agente, app, interface, schema, contrato e mecanismo de governança existe **dentro** de HealthOS, não ao lado dele.

Hierarquia constitucional canônica (refletida em [HealthOS/Package.swift](../../../HealthOS/Package.swift)):

| Camada | Targets / artefatos | Papel |
|---|---|---|
| HealthOS Core | `HealthOSCore` | Constituição: lei, contratos (consent, habilitation, gate, finality, provenance, storage). |
| Governed Operational Spec (GOS) | `HealthOSCore/GovernedOperationalSpec.swift`, `HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec*.schema.json` | Camada de spec subordinada (ADR-0011). |
| Runtimes | `HealthOSAACI`, `HealthOSMSR`, `HealthOSSessionRuntime`, `HealthOSProviders` | Execução sob lei do Core e guidance de GOS. |
| Boundary | `HealthOSBoundary`, mediated facades/envelopes | Fronteira HealthOS-owned para consumo seguro por Stages. |
| Stage / Interfaces | `HealthOSScribeStage`, `HealthOSVeridiaStage`, `HealthOSCloudClinicStage`, `HealthOSCLI` | UX/CLI consumindo saídas mediadas (ADR-0007, ADR-0013). |
| Artefatos / Efeitos | Arquivos persistidos, registros de gate, provenance | Saídas governadas com proveniência (ADR-0003). |

- **Escopo.** Decisão constitucional sobre identidade e topologia lógica do sistema. Não decide stack (ADR-0005), topologia operacional (ADR-0009) nem nome de repositório (ADR-0012).
- **Justificativa.** Manter lei e contratos em um núcleo único é a única forma de adicionar runtimes/apps sem duplicar governança e sem fragmentar a auditoria regulatória.

## Alternativas Consideradas

### Alternativa A — AACI como produto principal
- **Prós.** Foco comercial em "inteligência clínica"; narrativa de produto mais simples.
- **Contras.** Governança e consent law teriam de viver dentro de AACI, impedindo adicionar novos runtimes (ex.: MSR) sem duplicar lei. Toda nova interface herdaria liability de AACI. Mistura "razão clínica" com "norma constitucional".
- **Por que rejeitada.** Fragmenta a constituição e cria um SPOF arquitetural.

### Alternativa B — Apps (Scribe/Veridia/CloudClinic) como produto principal
- **Prós.** UX-first é familiar; cada app teria autonomia total.
- **Contras.** Cada app reimplementaria consent/habilitation/gate. Violaria ADR-0010 (compliance arquiteturalizado). Conflito direto com ADR-0007.
- **Por que rejeitada.** UX é ergonomia, não constituição.

### Alternativa C — HealthOS como sistema inteiro (escolhida)
- **Prós.** Lei única; runtimes/apps são consumidores, não co-iguais. Auditoria regulatória endereçável a um controlador. Permite ecossistema de apps sob compliance comum.
- **Contras.** Exige disciplina contínua para impedir drift; novos contribuintes precisam internalizar a hierarquia.

## Consequências

- **Positivas.**
  - Documentação de arquitetura, glossário e todos os ADRs subsequentes podem usar HealthOS como sujeito único.
  - Novos runtimes/apps herdam Core law automaticamente.
  - Endereço regulatório único para LGPD/HIPAA.
- **Negativas / trade-offs.**
  - Toda PR que adicionar runtime/app deve ser auditada quanto a violação de hierarquia.
  - Curva de aprendizado para contribuintes acostumados a "app é o produto".
- **Riscos e mitigação.**
  - **Risco.** Drift de governança para apps. **Mitigação.** Lint arquitetural + checklist de PR + ADR-0010.
  - **Risco.** Confusão de nomenclatura HealthOScaffold ≠ HealthOS. **Mitigação.** ADR-0012 + glossário em [HealthOS/Shared/docs/architecture/17-glossary.md](../architecture/17-glossary.md).
- **Implicações operacionais.** Não há SLO específico desta ADR; ela fornece o frame onde SLOs operacionais (ADR-0009, ADR-0026) são definidos.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Direção única: Core ← Providers ← (AACI, MSR) ← SessionRuntime ← Apps/CLI. `HealthOSVeridiaStage` e `HealthOSCloudClinicStage` dependem apenas de `HealthOSCore`.
- **Conformidade com Package.swift.** Topologia em [HealthOS/Package.swift](../../../HealthOS/Package.swift) reflete a hierarquia. Qualquer adição que invertesse a direção (ex.: Core dependendo de Providers) seria violação direta desta ADR.
- **Concurrency.** A camada de execução (AACI/MSR/SessionRuntime) usa `actor` Swift para isolamento (ex.: `public actor AACIOrchestrator` em [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift:5); `public actor SessionRunner` em [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift:6](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift:6)). Core expõe contratos `Sendable` (ex.: `CoreLawfulContext`).
- **Segurança/Privacidade.** A identidade "HealthOS" é a âncora do controlador para fins de LGPD; downstream apps são processadores delegados sob essa identidade.
- **Observabilidade.** Toda emissão de log/trace deve carregar `healthos.layer` para rastrear travessias de seam.
- **Testes.** Testes em [HealthOS/Shared/Tests/HealthOSTests/](../../../HealthOS/Shared/Tests/HealthOSTests/) verificam que apps consomem contratos do Core (ex.: `ScribeProfessionalWorkspaceContractsTests`, `VeridiaSessionFacadeTests`).

## Plano de Adoção e Migração

- **Passos.** Decisão já adotada e materializada na topologia. Esforço residual: revisar PRs históricas que possam conter resíduos de "AACI-as-product"; varrer documentação para uniformizar linguagem.
- **Impacto em APIs.** Nenhum impacto direto em APIs públicas; impacto em narrativa e em organização de pacotes.
- **Critérios de saída.** Considera-se plenamente adotada quando: (a) glossário e overview reforçam a hierarquia; (b) zero violações em CI; (c) novos contribuintes conseguem identificar a camada correta para cada decisão sem ambiguidade.

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
