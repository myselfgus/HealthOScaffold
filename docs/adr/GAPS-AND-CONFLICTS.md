# Relatório de Gaps & Conflitos — ADRs HealthOS

Data da revisão: 2026-05-06
Escopo: ADRs 0001-0012 + auditoria contra [swift/Package.swift](../../swift/Package.swift) e árvore de código.

Este relatório lista (a) gaps de cobertura ADR (decisões importantes ainda não documentadas formalmente), (b) conflitos potenciais ou ambiguidades entre ADRs existentes, (c) ADRs novas propostas, e (d) recomendações de evolução.

---

## 1. Resumo

- **Decisões fundacionais.** ADRs 0001-0012 cobrem o núcleo constitucional, topologia, stack, seam local, UX, lawfulContext, ontologia/compliance, GOS e identidade do repositório. **Não há conflitos diretos** entre as ADRs existentes; várias se reforçam mutuamente.
- **Conformidade com Package.swift.** Direção de dependências declarada em [swift/Package.swift](../../swift/Package.swift) é compatível com toda a hierarquia constitucional descrita no ADR-0001. **Sem violações** detectadas.
- **Gaps materiais.** Existe substancial trabalho de arquitetura **implementado** ([docs/architecture/](../architecture/) inclui arquivos 01-44, e há ~30 arquivos Swift no Core, MSR/AACI bindings, providers reais) que **ainda não tem cobertura ADR específica**. Exemplos: política de threshold de provedor, observabilidade de operador, coordenação cross-app, integração MSR, prompts versionados.

---

## 2. Conflitos / ambiguidades entre ADRs existentes

### 2.1 Nenhum conflito direto

Após revisão integral, **nenhuma ADR contradiz outra**. Reforços mútuos:

| Reforço | ADRs envolvidas |
|---|---|
| Identidade de sistema vs. forma de deployment | 0001 ↔ 0002 ↔ 0009 ↔ 0012 |
| Compliance no Core (não em apps) | 0001 ↔ 0003 ↔ 0004 ↔ 0007 ↔ 0010 ↔ 0011 |
| Subordinação hierárquica | 0001 ↔ 0011 (GOS subordinada ao Core) |
| Stack e seam | 0005 ↔ 0006 |

### 2.2 Ambiguidades de baixa criticidade

- **ADR-0008 (lawfulContext flexível) ↔ ADR-0010 (compliance arquiteturalizada).** A flexibilidade do mapa pode parecer afrouxar o contrato de Core. Mitigação já presente: `CoreLawfulContext` tipado + validação fail-closed em `CoreLaw.swift`. **Recomendação:** documentar explicitamente em uma futura ADR de "transport hardening" o caminho de migração para envelope rígido (já declarado como follow-up no ADR-0008).
- **ADR-0006 (loopback HTTP + Postgres + filesystem) ↔ ADR-0009 (fabric soberano multi-node).** Quando a topologia for multi-node, "loopback" deixa de ser trivial. **Recomendação:** ADR específica para "mesh provider" antes da implementação multi-node, com mapeamento entre `httpLocal` e `httpMesh`.

---

## 3. Gaps de cobertura ADR (decisões implementadas sem ADR)

Listadas em ordem de prioridade. Cada gap propõe uma ADR candidata (numeração tentativa).

### 3.1 [ADR-0013 proposta] **Provider model governance e threshold policy**

- **Por que.** Existe código consolidado em [swift/Sources/HealthOSProviders/ProviderProtocols.swift](../../swift/Sources/HealthOSProviders/ProviderProtocols.swift), [ProviderProtocols](../../swift/Sources/HealthOSProviders/ProviderProtocols.swift), [ModelGovernance.swift](../../swift/Sources/HealthOSProviders/ModelGovernance.swift), e doc [docs/architecture/27-provider-threshold-policy.md](../architecture/27-provider-threshold-policy.md), além de `ProviderKind` (apple-native, http-local, training-offline, remote, local), `ProviderTaskClass`, `ProviderSafetyDenialReason`. **Não há ADR formal** que cristalize a decisão.
- **Recomendação.** Criar ADR-0013 cobrindo: kinds permitidos, regras de segurança fail-closed (denial reasons), política de threshold, requisitos de stub vs. real, `allowsPHI` / `requiresNetwork` / `allowsIdentifiableData` como contratos.
- **Risco.** Sem ADR, próximas evoluções podem flexibilizar denials sem revisão arquitetural.

### 3.2 [ADR-0014 proposta] **Apple Foundation Models como provider apple-native**

- **Por que.** Existe adapter implementado em [swift/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift](../../swift/Sources/HealthOSProviders/AppleFoundationModelsAdapter.swift) sem ADR.
- **Recomendação.** ADR específica documentando: por que Apple Foundation Models foi escolhido como provider primário on-device; restrições de PHI; fallback e degradation; relação com ADR-0005 (stack) e ADR-0009 (soberania).

### 3.3 [ADR-0015 proposta] **Observabilidade do operador como contrato**

- **Por que.** Existe [docs/architecture/26-operator-observability-contract.md](../architecture/26-operator-observability-contract.md) e código em `runtime-data/`. **ADR-0007** menciona surfaces de operador, mas não fixa o contrato de observabilidade.
- **Recomendação.** ADR formalizando métricas, logs, traces obrigatórios; SLOs; redaction; relação com ADR-0004 (PHI).

### 3.4 [ADR-0016 proposta] **MSR (Medical Speech Recognition) — pipeline e prompts versionados**

- **Por que.** [HealthOSMSR](../../swift/Sources/HealthOSMSR) tem `MSRPipeline`, `Executors/{ASLExecutor, VDLPExecutor, GEMArtifactBuilder, MSRJSONRepair}`, e prompts em `Prompts/{asl-system.md, vdlp-system.md, gem-system.md}`. Sem ADR.
- **Recomendação.** ADR cobrindo: papel de ASL/VDLP/GEM no pipeline, versionamento de prompts (golden tests), relação com `Prompts/` resources copy em [Package.swift:23](../../swift/Package.swift:23), governança de output, contrato com SessionRuntime.

### 3.5 [ADR-0017 proposta] **Coordenação cross-app e shared surfaces**

- **Por que.** Existe [swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift](../../swift/Sources/HealthOSCore/CrossAppCoordinationContracts.swift) e doc [docs/architecture/43-cross-app-coordination-shared-surfaces.md](../architecture/43-cross-app-coordination-shared-surfaces.md). Sem ADR.
- **Recomendação.** ADR formalizando como Scribe/Veridia/CloudClinic coordenam (sem violar ADR-0007 e ADR-0010): handoff de session state, surfaces compartilhadas, escopo de cada app.

### 3.6 [ADR-0018 proposta] **Backup, retenção e governança de objetos**

- **Por que.** [BackupGovernance.swift](../../swift/Sources/HealthOSCore/BackupGovernance.swift), [docs/architecture/21-object-integrity-strategy.md](../architecture/21-object-integrity-strategy.md). Sem ADR.
- **Recomendação.** ADR sobre estratégia de backup, retenção mínima/máxima (LGPD), integridade de objetos, recuperação.

### 3.7 [ADR-0019 proposta] **Retrieval-augmented memory governance**

- **Por que.** [RetrievalMemoryGovernance.swift](../../swift/Sources/HealthOSCore/RetrievalMemoryGovernance.swift) implementa contratos para retrieval governado, sem ADR.
- **Recomendação.** ADR sobre escopo permitido de retrieval, base legal, limites de bounded-context, relação com ADR-0004.

### 3.8 [ADR-0020 proposta] **First-slice executable path**

- **Por que.** Existe [FirstSliceContracts.swift](../../swift/Sources/HealthOSCore/FirstSliceContracts.swift), [FirstSliceServices.swift](../../swift/Sources/HealthOSCore/FirstSliceServices.swift), [docs/architecture/03-first-slice.md](../architecture/03-first-slice.md), [docs/architecture/28-first-slice-executable-path.md](../architecture/28-first-slice-executable-path.md). Sem ADR sobre o que é "first slice" canônico.
- **Recomendação.** ADR fixando: o que constitui first slice executable; relação com `aaci.first-slice` exemplar GOS; gates de scaffold-closure.

### 3.9 [ADR-0021 proposta] **Steward e infra de agente para construção**

- **Por que.** [.healthos-steward/](../../.healthos-steward/), [docs/architecture/44-project-steward-agent.md](../architecture/44-project-steward-agent.md). Sem ADR.
- **Recomendação.** ADR sobre papel do Steward na construção, MCPs, segregação entre infra de construção e plataforma HealthOS.

### 3.10 [ADR-0022 proposta] **Esquemas governados e drift detection**

- **Por que.** [docs/architecture/18-schema-governance-audit.md](../architecture/18-schema-governance-audit.md), `make validate-schemas`, `make validate-contracts` mas sem ADR formal.
- **Recomendação.** ADR sobre disciplina de schemas (JSON Schema canônico), versionamento, deprecação, drift detection no CI.

### 3.11 Outros gaps menores (podem virar uma ADR conjunta ou registros menores)

- **Async runtime jobs** ([AsyncRuntimeJobs.swift](../../swift/Sources/HealthOSCore/AsyncRuntimeJobs.swift)) — política de jobs assíncronos.
- **Service operations** ([ServiceOperationsContracts.swift](../../swift/Sources/HealthOSCore/ServiceOperationsContracts.swift)) — contratos operacionais.
- **Veridia session contracts** ([VeridiaSessionContracts.swift](../../swift/Sources/HealthOSCore/VeridiaSessionContracts.swift)) — escopo da app Veridia.
- **Scribe professional workspace** ([ScribeProfessionalWorkspaceContracts.swift](../../swift/Sources/HealthOSCore/ScribeProfessionalWorkspaceContracts.swift)) — escopo Scribe.

---

## 4. Decisões obsoletas ou candidatas a Supersedência

Após revisão, **nenhuma ADR existente está obsoleta**. Todas continuam materialmente vinculantes. Pontos de monitoramento:

- **ADR-0008 (lawfulContext flexível em v1).** Quando vocabulário estabilizar (métrica `lawfulcontext.unknown_key.total ≈ 0` por 90 dias), considerar superseder com ADR de envelope rígido. **Não obsoleta hoje.**
- **ADR-0006 (seam loopback).** Pode ser complementada (não substituída) por ADR específica de IPC/XPC/UDS quando latência justificar. **Não obsoleta.**

---

## 5. Recomendações de PR/processo

1. **Criar ADRs 0013-0022** propostas acima, em ondas (governança → providers → MSR → cross-app → schemas).
2. **Implementar lint arquitetural em CI:**
   - Verificar ausência de redefinição de tipos `Consent*`, `Gate*`, `Habilitation*` fora do Core (ADR-0001/0010).
   - Verificar bind apenas em `127.0.0.1`/UDS (ADR-0006).
   - Verificar ausência de PII direta em logs (ADR-0004) — scanner regex.
3. **Atualizar [TRACEABILITY-MATRIX.md](TRACEABILITY-MATRIX.md) sempre que código referenciado em ADRs mover.**
4. **Adotar convenção:** toda nova capacidade que produza artefato com efeito clínico deve referenciar ADR-0003 e ADR-0010 em PR description.
5. **Auditoria trimestral:** revisar contadores de `gate.bypass_attempt`, `lawfulcontext.unknown_key`, `identifier.leak.detected` — sinalizam drift de governança.

---

## 6. Itens de TODO documentais

| TODO | Responsável | ADR relacionada |
|---|---|---|
| Criar lint arquitetural em CI | Tooling | 0001, 0006, 0010 |
| Scanner anti-PII em logs/traces no CI | Compliance + Tooling | 0004 |
| Documentar política de threshold de provider em ADR formal | Providers eng | 0013 (proposta) |
| Versionamento de prompts MSR + golden tests | MSR eng | 0016 (proposta) |
| Criar ADR de mesh provider antes da implementação multi-node | Platform/Infra | 0009 (já antecipa) |
| Migração lawfulContext map → envelope rígido (quando estável) | Core eng | 0008 (já antecipa) |
