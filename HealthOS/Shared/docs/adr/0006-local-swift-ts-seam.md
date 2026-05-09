---
id: ADR-0006
title: Seam local inicial entre Swift e TypeScript (Initial local seam between Swift and TypeScript)
status: Accepted
date: 2025-04-23
deciders: [HealthOS Architecture Council, Platform/Infra lead]
consulted: [Core engineering, Tooling lead, MCP/Agent infra lead]
informed: [All HealthOS contributors]
tags: [seam, integração, swift, typescript, http, loopback, postgres, filesystem, ipc, xpc]
modules_impacted:
  - HealthOSCore
  - HealthOSProviders
  - HealthOSAACI
  - HealthOSSessionRuntime
  - HealthOSCLI
related_adrs:
  supersedes: []
  superseded_by: []
  related: [ADR-0002, ADR-0005, ADR-0008]
code_references:
  - path: HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift
    type: protocol
    note: ProviderKind inclui `httpLocal = "http-local"` — declaração explícita de seam loopback.
  - path: HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift
    type: protocol
    note: Layers de storage compatíveis com Postgres como source of truth.
  - path: HealthOS/Constructor/ts/packages
    type: resource
    note: Pacotes TS que podem expor endpoints loopback HTTP.
  - path: HealthOS/Tier1-Mestral-Core/Schemas/
    type: resource
    note: Schemas JSON compartilhados validam payloads do seam.
risk_level: Medium
compliance:
  privacy: Loopback (`127.0.0.1` / Unix socket) garante que tráfego não saia do host. Payloads só carregam pseudônimos quando possível (ADR-0004); identificadores diretos exigem base legal e habilitação.
  security: TLS opcional em loopback; autenticação via tokens locais com escopo restrito; nenhum bind em interface pública.
  data_classification: PHI pode trafegar em payloads governados; identificadores diretos exigem ADR-0004 + habilitação.
observability:
  logs: Cada chamada loopback emite `seam.request{method,path,status,duration_ms,correlation_id}`. PHI redacted.
  metrics: `healthos.seam.latency_ms` (histograma p50/p95/p99), `healthos.seam.error_rate{kind}`, `healthos.seam.payload_size_bytes`.
  traces: `traceparent` propagado HTTP cross-language.
testing:
  strategy: Testes de contrato cross-language com schemas compartilhados; testes de integração rodam ambos processos e validam fim-a-fim.
  coverage_targets: Endpoints expostos têm: (a) schema JSON; (b) teste de contract Swift; (c) teste de contract TS; (d) teste de integração loopback.
rollout:
  plan: Adotada como seam inicial. IPC/XPC/UDS pode ser introduzido por nova ADR quando justificado por latência/segurança.
  monitoring: Painel de seam: latência p99 < 50ms para chamadas síncronas; error rate < 0.5%.
---

# ADR 0006 — Seam local inicial entre Swift e TypeScript

## Contexto

- **Problema e motivação.** Dada a stack híbrida (ADR-0005), Swift e TypeScript precisam coordenar operações localmente sem expor o sistema a uma rede pública nem forçar acoplamento por linguagem. O seam precisa ser inspecionável, debugável e compatível com schemas governados.
- **Pressupostos e restrições.** (a) Single-node bootstrap (ADR-0002); (b) PHI pode atravessar o seam sob governança; (c) Postgres é o source of truth canônico para metadata/state.
- **Objetivos e critérios de sucesso.**
  - **Objetivo.** Seam local, explícito, debugável, compatível com schemas governados.
  - **Critérios.** Tráfego sem sair do host; latência p99 < 50ms para chamadas síncronas pequenas; payloads grandes movidos por referência (path/objeto), não inline.

## Decisão

O seam local inicial entre Swift e TypeScript é:

| Mecanismo | Uso |
|---|---|
| **Loopback HTTP** (`127.0.0.1` ou Unix Domain Socket local) | Chamadas de serviço e coordenação de runtime entre processos Swift e TS. |
| **PostgreSQL local** | Source of truth canônico para metadata/state compartilhado (governança, registries, índice de bundles GOS). |
| **Filesystem / object paths** | Payloads grandes (transcripts, áudio, embeddings) trafegam por referência, não inline. |

A `ProviderKind.httpLocal` em [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift) materializa o seam para providers que vivem em TS.

- **Escopo.** Comunicação cross-language local. Não é seam externo (ADR-0009 trata fabric soberano).
- **Justificativa.** Loopback HTTP é universalmente debugável (curl, tcpdump local, OpenAPI), Postgres é a base canônica de metadata em HealthOS, e filesystem evita serialização absurda de blobs.

## Alternativas Consideradas

### Alternativa A — IPC/XPC nativo macOS desde o início
- **Prós.** Latência baixíssima; integrado ao macOS.
- **Contras.** Difícil debug/inspeção; menos portátil; tooling TS/Node não consome XPC nativamente.
- **Rejeitada para v1.** Pode ser introduzido por nova ADR quando latência justificar.

### Alternativa B — Mensageria (Redis/NATS) local
- **Prós.** Pub/sub, fan-out.
- **Contras.** Adiciona dependência operacional; over-engineering para single-node bootstrap.
- **Rejeitada.**

### Alternativa C — Loopback HTTP + Postgres + Filesystem (escolhida)
- **Prós.** Inspecionável, debugável, schemas validáveis, compatível com tooling existente, single-node first.
- **Contras.** HTTP overhead em chamadas hot; mitigado movendo blobs por path.

## Consequências

- **Positivas.**
  - Apps e runtimes integram via endpoints locais explícitos.
  - Schemas/contratos escritos como payloads boundary-safe (Codable Swift + Zod/AJV TS sobre o mesmo JSON Schema em [HealthOS/Tier1-Mestral-Core/Schemas/](../../../HealthOS/Tier1-Mestral-Core/Schemas/)).
  - Artefatos pesados não passam por RPC payload.
- **Negativas / trade-offs.**
  - Overhead HTTP em loops apertados (mitigar com batching ou path-by-reference).
  - Um processo TS precisa estar rodando para chamadas Swift→TS funcionarem; documentado em runbook.
- **Riscos e mitigação.**
  - **Risco.** Bind acidental em `0.0.0.0`. **Mitigação.** Code review + teste de smoke que confirma `127.0.0.1` only.
  - **Risco.** Drift de schema entre Swift e TS. **Mitigação.** `make validate-schemas` em CI; PR review checklist.

### Não-objetivos

- Não é fronteira de rede pública.
- Não substitui checagens de governança (Core law continua autoritativa).
- Não compromete contra IPC/XPC futuro onde justificado por latência/segurança.

## Detalhes de Implementação

- **Fronteiras entre módulos.** Swift `HealthOSProviders` expõe adapters `httpLocal`. Apps consumem via SessionRuntime → Providers → endpoint loopback TS.
- **Conformidade com Package.swift.** `HealthOSProviders` depende apenas de `HealthOSCore` (validado em [HealthOS/Package.swift:20](../../../HealthOS/Package.swift:20)).
- **Concurrency.** Cliente HTTP em Swift usa `URLSession` async/await; cancelamento estruturado propaga via `Task`.
- **Segurança/Privacidade.** Bind em `127.0.0.1`/UDS apenas; tokens locais; payloads conformes ADR-0004.
- **Observabilidade.** `correlation_id` cross-language; `traceparent` HTTP; logs estruturados em ambos os lados.
- **Testes.** Contrato cross-language por endpoint; integração local com ambos processos.

## Plano de Adoção e Migração

- **Passos.** Adotada como seam padrão. Migração para IPC/XPC ou UDS exclusivo: ADR específica futura.
- **Impacto em APIs e contratos.** APIs cross-language são versionadas por schema; deprecação requer release note + período de coexistência.
- **Critérios de saída.** Permanece válida enquanto latência atender ao SLO; substituição requer ADR.

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
