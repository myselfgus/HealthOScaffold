---
id: ADR-0014
title: Governed AI Agent Society no HealthOS
status: Accepted
date: 2026-05-09
deciders: [HealthOS Architecture Council]
consulted: [Core engineering, Runtime engineering, Provider governance, Boundary engineering]
informed: [All HealthOS contributors]
tags: [agentes, ia, runtimes, core-law, providers, boundary, governanca]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSUserAgentRuntime
  - HealthOSBoundary
  - TypeScript contracts
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0001, ADR-0003, ADR-0004, ADR-0005, ADR-0007, ADR-0008, ADR-0010, ADR-0011, ADR-0013]
code_references:
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedAIAgentContracts.swift
    type: contract
    note: Canonical Swift contract for AgentID, mandate, memory, tools, provider policy, negotiation envelope, custody refs, and protocol projection.
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSUserAgentRuntime/UserAgentRuntime.swift
    type: runtime
    note: PersonalAgentRuntime v1 for patient, professional, and generic user personal agents.
  - path: HealthOS/Tier3-Custom-Boundary/Sources/HealthOSBoundary/AgentProtocolBoundary.swift
    type: boundary
    note: HealthOS-governed AACP/A2A/ACP projection guard.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/contracts/governed-ai-agent-society.schema.json
    type: schema
    note: JSON schema mirror for governed AI agent society contracts.
  - path: HealthOS/Constructor/ts/packages/contracts/src/index.ts
    type: contract
    note: TypeScript mirror for cross-language agent society contracts.
risk_level: High
compliance:
  privacy: Agent envelopes deny raw CPF/direct identifiers, reidentification maps, raw storage paths, key material, and internal memory exposure by default.
  security: LLM/provider selection is policy-routed and cannot become the identity or authority of an agent.
  data_classification: Data layers stay explicit; external provider routing requires policy, minimization, and provenance.
observability:
  logs: Runtime responses and queued offline posture carry audit/provenance refs.
  metrics: Future work may count provider routing denials, degraded-sovereignty events, and agent negotiation outcomes.
  traces: Agent negotiation envelopes must preserve causal refs without exposing raw internal memory or tool implementation.
testing:
  strategy: Core contract tests, personal runtime tests, Boundary projection tests, TypeScript/schema validation, and provider-governance policy tests.
  coverage_targets: GovernedAIAgentTests, PersonalAgentRuntimeTests, AgentNegotiationBoundaryTests, ProviderGovernanceTests, UserSovereigntyGovernanceTests.
rollout:
  plan: Adopt as Tier 1-3 first slice. Stages may consume mediated surfaces later only after Boundary/Custom readiness.
  monitoring: Track agent-contract drift through schema/TS/Swift validation and execution TODOs.
---

# ADR 0014 - Governed AI Agent Society no HealthOS

## Contexto

- **Problema e motivacao.** HealthOS ja usa "agent" para atores/runtimes, mas a nova direcao exige uma sociedade de agentes de IA governados: agentes pessoais de pacientes, profissionais e usuarios, alem de agentes internos de Core, runtimes, providers, storage/custody, audit, Boundary e operacoes. Sem decisao explicita, ha risco de confundir agente com LLM, mover lei para Stages, ou transformar Veridia/Scribe em cofre/runtime.
- **Pressupostos e restricoes.** HealthOS e a plataforma inteira (ADR-0001); human gate e obrigatorio para efeitos clinicos/regulatorios (ADR-0003); identificadores protegidos e reidentificacao seguem Core/storage law (ADR-0004); stack hibrida admite modelos locais e externos quando policy permite (ADR-0005); Stages nao definem ontologia nem lei (ADR-0007, ADR-0013); GOS segue subordinado ao Core (ADR-0011).
- **Protocolos externos considerados.** A2A e referencia para agent-agent interoperavel e opaco; ACP e referencia para operar UI existente. HealthOS define o perfil governado AACP e adapters, sem entregar autoridade legal para os protocolos externos.

## Decisao

HealthOS passa a reconhecer uma **Governed AI Agent Society**:

1. **Agente e identidade governada.** Um agente e entidade persistente com `AgentID`, principal representado, mandato, memoria governada, tool grants, provider policy, delegation policy e protocolo. O LLM/modelo e motor selecionavel, nunca a identidade nem a autoridade do agente.
2. **Agentes pessoais entram juntos.** `PatientPersonalAgent`, `ProfessionalPersonalAgent` e `UserPersonalAgent` sao agentes pessoais de IA governados no `PersonalAgentRuntime`. Eles podem educar, negociar, aplicar preferencias, responder async/offline sob policy e solicitar/receber consentimento mediado.
3. **Agentes internos sao explicitos.** Core governance agents, runtime agents, provider/model agents e Boundary/protocol agents sao catalogados como agentes governados, sempre subordinados ao seu layer.
4. **Provider routing e policy.** Apple Silicon/local-first e preferencia quando adequado, mas modelos externos podem ser usados quando policy explicita permitir, com minimizacao, data-layer allowlist, provenance, audit e degraded-sovereignty.
5. **Dados cegos sao governanca, nao promessa simplista.** O modelo usa pseudonimizacao, separacao identidade/conteudo/persona/custodia, safe refs, grants efemeros e reidentificacao governada. Veridia nao guarda chaves; Scribe nao governa persona profissional.
6. **Stage non-scope inicial.** Nenhum Stage vira runtime, cofre, lei ou autoridade nesta decisao. Stages poderao consumir superficies mediadas depois de Boundary/Custom readiness.

## Alternativas Consideradas

### Alternativa A - Agente como LLM/provider
- **Pros.** Simples de explicar tecnicamente.
- **Contras.** Faz o modelo parecer autoridade; quebra troca de providers; dificulta audit/provenance; conflita com policy local/external.
- **Rejeitada.**

### Alternativa B - Comecar por Veridia/Scribe como agentes
- **Pros.** Produz demo visual mais rapido.
- **Contras.** Move responsabilidade para Stage, conflita com ADR-0013 e com a documentacao atual de Veridia.
- **Rejeitada.**

### Alternativa C - Contratos Core + runtime pessoal + Boundary protocol adapter
- **Pros.** Preserva lei no Core, permite paciente e profissional juntos, fortalece provider policy, e cria superficie consumivel futura sem UI Stage.
- **Contras.** Primeiro slice e mais estrutural que visual.
- **Escolhida.**

## Consequencias

- **Positivas.**
  - HealthOS ganha vocabulario executavel para agentes pessoais e internos.
  - Provider/model routing passa a ser parte do mandato/policy do agente, sem prender o sistema a modelos locais apenas.
  - A2A/ACP entram como adapters governados, nao como autoridade.
  - O papel documentado de Veridia/Scribe permanece intacto.
- **Negativas / trade-offs.**
  - UX de Stage continua bloqueada ate as superficies mediadas amadurecerem.
  - O runtime pessoal v1 ainda e scaffold/foundation: nao executa modelo real, nao persiste memoria produtiva, nao gerencia chaves reais e nao concede acesso clinico por si.
- **Riscos e mitigacao.**
  - **Risco.** Agentes pessoais parecerem procuradores legais autonomos. **Mitigacao.** `legalAuthorizing=false`, intents clinicos/regulatorios autonomos negados, gate humano preservado.
  - **Risco.** Provider externo receber dado sensivel sem policy. **Mitigacao.** policy explicita, data-layer checks e negacao de identificadores/reidentificacao.
  - **Risco.** Protocolo externo vazar memoria/tools. **Mitigacao.** Boundary projection app-safe sem memoria interna, raw storage, key material ou tool implementation.

### Nao-objetivos

Esta ADR nao:
- implementa UI de Stage;
- move Veridia ou Scribe;
- declara Veridia como cofre de chaves;
- implementa provider LLM externo real;
- implementa assinatura, diagnostico, prescricao ou finalizacao autonoma;
- declara HealthOS production-ready, EHR completo ou integracao regulatoria real.

## Detalhes de Implementacao

- `HealthOSCore/GovernedAIAgentContracts.swift` define `AgentID`, `AgentPrincipalRef`, `AgentMandate`, `DelegationPolicy`, `AgentMemoryScope`, `AgentToolGrant`, `AgentProviderRoutingPolicy`, `AgentNegotiationEnvelope`, `EphemeralAccessGrantRef`, `CustodyControlRef`, `GovernedAIAgentDescriptor`, `AgentProtocolProjection` e validadores fail-closed.
- `PersonalAgentRuntime` em `HealthOSUserAgentRuntime` inicia agentes pessoais de paciente, profissional e usuario, aplica validacao Core, roteia provider quando configurado, retorna somente disposicao informacional e suporta queue offline governada.
- `AgentProtocolBoundary` projeta envelopes para HealthOS AACP, A2A ou ACP futuro sem autoridade legal e sem dados/estado interno proibidos.
- O contrato e espelhado em TypeScript e JSON Schema.
- A arquitetura detalhada vive em [52-governed-ai-agent-society.md](../architecture/52-governed-ai-agent-society.md).

## Plano de Adocao e Migracao

1. Adotar os contratos Core e schemas como fonte inicial da sociedade de agentes.
2. Expandir provider/model governance com registros persistidos de avaliacao, fallback, rollback e degraded-sovereignty.
3. Evoluir `PersonalAgentRuntime` para persistencia de memoria governada e mailbox async sem violar Core law.
4. Adicionar facades de Core governance agents sem mover lei para runtime.
5. Integrar Stages apenas depois de Boundary/Custom readiness, mantendo Veridia/Scribe como consumidores governados.

## Checklist de Completude

- [x] Status e data corretos; front matter preenchido.
- [x] Definicao de agente separada de LLM/modelo.
- [x] Paciente, profissional e usuario cobertos no primeiro slice.
- [x] Agentes internos de Core/runtime/provider/Boundary catalogados.
- [x] A2A/ACP tratados como referencias/adapters, nao autoridade.
- [x] Stage non-scope e papel de Veridia/Scribe preservados.
- [x] Guardas de direct identifiers, reidentification, raw storage, key material e legal finality implementados.
- [x] Swift, TypeScript e JSON Schema alinhados.
