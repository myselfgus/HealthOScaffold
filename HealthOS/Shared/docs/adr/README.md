# Architecture Decision Records (ADRs) — HealthOS

Este diretório contém os **Architecture Decision Records (ADRs)** canônicos do HealthOS. Cada ADR documenta uma decisão arquitetural ou constitucional significativa — seu contexto, alternativas consideradas, decisão escolhida e consequências.

> ADRs são **append-only**: uma vez `Accepted`, uma ADR não é editada para reverter sua decisão. Quando uma decisão muda, **uma ADR superseding é criada** que declara `Supersedes: ADR-XXXX` e a ADR superseded passa a `Superseded`.

Todas as ADRs seguem o **template canônico** (ver `Template ADR Canônico` em [HealthOS/Shared/docs/architecture/](../architecture/) ou no front matter de qualquer ADR existente).

---

## Índice

| ADR | Título | Status | Risco | Módulos impactados (principais) |
|-----|--------|--------|-------|---------------------------------|
| [0001](0001-healthos-is-the-whole-system.md) | HealthOS é o sistema inteiro | Accepted | High | Todos |
| [0002](0002-single-node-is-canonical-minimum.md) | Single-node é o mínimo canônico de deployment | Accepted | Medium | Todos |
| [0003](0003-gate-human-required.md) | Human gate é obrigatório para artefatos clínicos/regulatórios | Accepted | High | Core, AACI, MSR, SessionRuntime, Apps |
| [0004](0004-operational-visibility-with-protected-identifiers.md) | Visibilidade operacional com identificadores protegidos | Accepted | High | Core, Providers, AACI, MSR, SessionRuntime, Apps |
| [0005](0005-hybrid-stack.md) | Stack híbrida — Swift, TypeScript, Python | Accepted | Medium | Todos |
| [0006](0006-local-swift-ts-seam.md) | Seam local inicial entre Swift e TypeScript | Accepted | Medium | Core, Providers, AACI, SessionRuntime, CLI |
| [0007](0007-healthos-has-no-end-user-ux.md) | HealthOS não tem UX de usuário-final própria | Accepted | Low | Core, Apps, CLI |
| [0008](0008-lawfulcontext-v1-flexible-map.md) | `lawfulContext` continua mapa canônico flexível em v1 | Accepted | Low | Core, Providers, AACI, MSR, SessionRuntime |
| [0009](0009-single-node-bootstrap-and-sovereign-fabric-topology.md) | Single-node bootstrap e topologia de fabric soberano | Accepted | Medium | Todos |
| [0010](0010-health-exclusive-ontology-and-architecturalized-compliance.md) | Ontologia health-exclusiva e compliance arquiteturalizada | Accepted | High | Todos |
| [0011](0011-governed-operational-spec-is-subordinate-to-core.md) | Governed Operational Spec subordinada ao Core | Accepted | High | Core, AACI, MSR, SessionRuntime, Providers |
| [0012](0012-healthoscaffold-is-healthos-construction-repository.md) | HealthOScaffold é o repositório de construção do HealthOS | Accepted | Low | Todos |
| [0013](0013-healthos-platform-app-layer-construction-system-boundary.md) | HealthOS hierarchy, Stage/Custom, Boundary e Construction System permanecem separados | Accepted | High | Todos |
| [0014](0014-governed-ai-agent-society.md) | Governed AI Agent Society no HealthOS | Accepted | High | Core, Providers, UserAgentRuntime, Boundary, TS contracts |

### Documentos auxiliares

- **[GAPS-AND-CONFLICTS.md](GAPS-AND-CONFLICTS.md)** — relatório de gaps, conflitos potenciais e ADRs novas propostas.
- **[TRACEABILITY-MATRIX.md](TRACEABILITY-MATRIX.md)** — matriz ADR ↔ módulos ↔ código ↔ testes ↔ HealthOS/Tier1-Mestral-Core/Schemas/pipelines.
- **[EXECUTIVE-SUMMARY.md](EXECUTIVE-SUMMARY.md)** — resumo executivo das decisões, riscos críticos e próximos passos.

---

## Vocabulário de status

| Status | Significado |
|---|---|
| **Proposed** | Em discussão; ainda não vinculante. |
| **Accepted** | Vinculante; todo trabalho novo deve ser consistente com a decisão. |
| **Deprecated** | Não se aplica mais; ver ADR superseding linkada. |
| **Superseded** | Substituída por ADR mais recente (linkada no registro deprecated). |

---

## Como adicionar uma ADR

1. Pegar o próximo número sequencial.
2. Criar `NNNN-short-title-slug.md` neste diretório.
3. Usar o **Template ADR Canônico** com:
   - **Front matter YAML** completo (id, title, status, date, deciders, consulted, informed, tags, modules_impacted, related_adrs, code_references, risk_level, compliance, observability, testing, rollout).
   - Seções: **Contexto**, **Decisão**, **Alternativas Consideradas**, **Consequências**, **Detalhes de Implementação**, **Plano de Adoção e Migração**, **Checklist de Completude**.
4. Adicionar uma linha ao índice acima.
5. Linkar a ADR de docs de arquitetura relevantes (`HealthOS/Shared/docs/architecture/`) e do tracker de status (`HealthOS/Shared/docs/execution/02-status-and-tracking.md`).
6. Atualizar [TRACEABILITY-MATRIX.md](TRACEABILITY-MATRIX.md) com a nova entrada.

### Quando uma ADR substitui outra

1. Marcar a ADR antiga como `Status: Superseded` e adicionar `superseded_by: [ADR-XXXX]` no front matter; **não** alterar a decisão original (append-only).
2. Adicionar à nova ADR `supersedes: [ADR-XXXX]` no front matter, e expor o motivo da supersedência em **Contexto**.
3. Atualizar o índice no README.

---

## Hierarquia constitucional (referência)

```
HealthOS Core              (ADR 0001, 0003, 0004, 0010)
      ↓
Governed Operational Spec  (ADR 0011)
      ↓
HealthOS Runtimes          (AACI, MSR, SessionRuntime; ADR 0001, 0010)
      ↓
Boundary                   (mediated app-safe surfaces; ADR 0013)
      ↓
Stage                      (Scribe, Veridia, CloudClinic, future governed consumers; ADR 0007, 0013)

Custom                     (CoreLaw-governed Stage definition; ADR 0013; not a tier)
Construction System        (outside clinical/runtime hierarchy; ADR 0012, 0013)
```

**Decisões de deployment e stack:** ADR 0002, 0005, 0006, 0009, 0012.

**Decisões de governança/compliance:** ADR 0001, 0003, 0004, 0010, 0011.

**Decisões de transport/contratos:** ADR 0006, 0008.

---

## Validação contínua

Toda PR que adiciona/modifica ADRs deve:

- [ ] Atualizar este README.
- [ ] Atualizar [TRACEABILITY-MATRIX.md](TRACEABILITY-MATRIX.md) se módulos ou códigos referenciados mudaram.
- [ ] Verificar que a hierarquia de dependências em [HealthOS/Package.swift](../../../HealthOS/Package.swift) **continua respeitada** após a decisão proposta:
  - `HealthOSCore` não depende de nenhum outro módulo.
  - `HealthOSProviders` depende apenas de `HealthOSCore`.
  - `HealthOSAACI` depende de `HealthOSCore` e `HealthOSProviders`.
  - `HealthOSMSR` depende de `HealthOSCore` e `HealthOSProviders`.
  - `HealthOSSessionRuntime` depende de `HealthOSCore`, `HealthOSAACI`, `HealthOSProviders`, `HealthOSMSR`.
  - Executáveis (CLI, Scribe, Veridia, CloudClinic) respeitam as direções declaradas em `Package.swift`.
