# Matriz de Rastreabilidade — ADRs ↔ Módulos ↔ Código ↔ Testes ↔ Pipelines

Data da revisão: 2026-05-06
Fonte de verdade da topologia: [swift/Package.swift](../../swift/Package.swift).

> Esta matriz é viva. Atualizar quando: (a) uma ADR for adicionada ou supersedida; (b) um caminho de código referenciado por uma ADR mover/renomear; (c) um teste relacionado for adicionado/removido.

---

## 1. Topologia de dependências (Package.swift)

```
HealthOSCore
   ↑
HealthOSProviders
   ↑                     ↑
HealthOSAACI          HealthOSMSR (resources: Prompts/)
   ↑                     ↑
HealthOSSessionRuntime ─┘

Executáveis:
  HealthOSCLI           → Core, SessionRuntime
  HealthOSScribeApp     → Core, SessionRuntime
  HealthOSVeridiaApp    → Core
  HealthOSCloudClinicApp→ Core

Tests:
  HealthOSTests         → Core, AACI, Providers, MSR, SessionRuntime
```

**Validação.** Não há violação de hierarquia em [swift/Package.swift](../../swift/Package.swift): Core é base; Providers depende só de Core; AACI/MSR dependem de Core+Providers (sem mútua); SessionRuntime depende de todos os runtimes; Apps dependem de Core (e SessionRuntime quando precisam orquestrar sessão); Veridia/CloudClinic dependem só de Core.

---

## 2. Matriz ADR ↔ Módulos

Legenda: `●` = impactada diretamente · `○` = relacionada · ` ` = não impactada.

| ADR | Title (resumido) | Core | Providers | AACI | MSR | SessionRuntime | CLI | ScribeApp | VeridiaApp | CloudClinicApp |
|-----|-------------------|:----:|:---------:|:----:|:---:|:--------------:|:---:|:---------:|:----------:|:--------------:|
| 0001 | HealthOS é o sistema | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 0002 | Single-node mínimo | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 0003 | Human gate obrigatório | ● | ○ | ● | ● | ● | ● | ● | ● | ● |
| 0004 | Identificadores protegidos | ● | ● | ● | ● | ● | ○ | ● | ● | ● |
| 0005 | Stack híbrida | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 0006 | Seam Swift↔TS | ● | ● | ● | ○ | ● | ● | ○ | ○ | ○ |
| 0007 | Sem UX no HealthOS | ● | ○ | ● | ● | ● | ● | ● | ● | ● |
| 0008 | lawfulContext flexível | ● | ● | ● | ● | ● | ○ | ○ | ○ | ○ |
| 0009 | Fabric soberano | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 0010 | Compliance arquiteturalizada | ● | ● | ● | ● | ● | ● | ● | ● | ● |
| 0011 | GOS subordinada ao Core | ● | ○ | ● | ● | ● | ○ | ○ | ○ | ○ |
| 0012 | HealthOScaffold = HealthOS | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ | ○ |

---

## 3. Matriz ADR ↔ Código

| ADR | Caminhos de código primários |
|-----|-----------------------------|
| 0001 | [swift/Package.swift](../../swift/Package.swift), [swift/Sources/HealthOSCore/](../../swift/Sources/HealthOSCore/), [swift/Sources/HealthOSAACI/AACI.swift](../../swift/Sources/HealthOSAACI/AACI.swift), [docs/architecture/01-overview.md](../architecture/01-overview.md) |
| 0002 | [swift/Package.swift](../../swift/Package.swift), [Makefile](../../Makefile), [scripts/bootstrap-local.sh](../../scripts/bootstrap-local.sh), [swift/Sources/HealthOSSessionRuntime/SessionRunner.swift](../../swift/Sources/HealthOSSessionRuntime/SessionRunner.swift), [swift/Sources/HealthOSCore/DirectoryLayout.swift](../../swift/Sources/HealthOSCore/DirectoryLayout.swift) |
| 0003 | [swift/Sources/HealthOSCore/GateContracts.swift](../../swift/Sources/HealthOSCore/GateContracts.swift), [swift/Sources/HealthOSCore/CoreLaw.swift](../../swift/Sources/HealthOSCore/CoreLaw.swift), [swift/Sources/HealthOSCore/Provenance.swift](../../swift/Sources/HealthOSCore/Provenance.swift), [swift/Sources/HealthOSCore/RegulatoryGovernance.swift](../../swift/Sources/HealthOSCore/RegulatoryGovernance.swift), [swift/Sources/HealthOSSessionRuntime/SessionRunner.swift](../../swift/Sources/HealthOSSessionRuntime/SessionRunner.swift) |
| 0004 | [swift/Sources/HealthOSCore/ReidentificationGovernance.swift](../../swift/Sources/HealthOSCore/ReidentificationGovernance.swift), [swift/Sources/HealthOSCore/StorageContracts.swift](../../swift/Sources/HealthOSCore/StorageContracts.swift), [swift/Sources/HealthOSCore/Provenance.swift](../../swift/Sources/HealthOSCore/Provenance.swift), [swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift](../../swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift) |
| 0005 | [swift/Package.swift](../../swift/Package.swift), [ts/package.json](../../ts/package.json), [python/pyproject.toml](../../python/pyproject.toml), [Makefile](../../Makefile) |
| 0006 | [swift/Sources/HealthOSProviders/ProviderProtocols.swift](../../swift/Sources/HealthOSProviders/ProviderProtocols.swift), [swift/Sources/HealthOSCore/StorageContracts.swift](../../swift/Sources/HealthOSCore/StorageContracts.swift), [ts/packages/](../../ts/packages/), [schemas/](../../schemas/) |
| 0007 | [swift/Sources/HealthOSCLI/CLIEntrypoint.swift](../../swift/Sources/HealthOSCLI/CLIEntrypoint.swift), [swift/Sources/HealthOSScribeApp/](../../swift/Sources/HealthOSScribeApp/), [swift/Sources/HealthOSVeridiaApp/](../../swift/Sources/HealthOSVeridiaApp/), [swift/Sources/HealthOSCloudClinicApp/](../../swift/Sources/HealthOSCloudClinicApp/), [docs/architecture/19-interface-doctrine.md](../architecture/19-interface-doctrine.md) |
| 0008 | [swift/Sources/HealthOSCore/CoreLaw.swift](../../swift/Sources/HealthOSCore/CoreLaw.swift), [swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift](../../swift/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift), [swift/Sources/HealthOSProviders/ProviderProtocols.swift](../../swift/Sources/HealthOSProviders/ProviderProtocols.swift) |
| 0009 | [swift/Package.swift](../../swift/Package.swift), [swift/Sources/HealthOSCore/StorageContracts.swift](../../swift/Sources/HealthOSCore/StorageContracts.swift), [docs/architecture/15-mesh-provider.md](../architecture/15-mesh-provider.md), [scripts/bootstrap-local.sh](../../scripts/bootstrap-local.sh) |
| 0010 | [swift/Sources/HealthOSCore/CoreLaw.swift](../../swift/Sources/HealthOSCore/CoreLaw.swift), [RegulatoryGovernance.swift](../../swift/Sources/HealthOSCore/RegulatoryGovernance.swift), [Provenance.swift](../../swift/Sources/HealthOSCore/Provenance.swift), [UserSovereigntyContracts.swift](../../swift/Sources/HealthOSCore/UserSovereigntyContracts.swift) |
| 0011 | [swift/Sources/HealthOSCore/GovernedOperationalSpec.swift](../../swift/Sources/HealthOSCore/GovernedOperationalSpec.swift), [GOSFileBackedRegistry.swift](../../swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift), [swift/Sources/HealthOSAACI/GOSBindings.swift](../../swift/Sources/HealthOSAACI/GOSBindings.swift), [GOSRuntimeActivation.swift](../../swift/Sources/HealthOSAACI/GOSRuntimeActivation.swift), [GOSRuntimeContext.swift](../../swift/Sources/HealthOSAACI/GOSRuntimeContext.swift), [GOSRuntimeResolution.swift](../../swift/Sources/HealthOSAACI/GOSRuntimeResolution.swift), [schemas/governed-operational-spec.schema.json](../../schemas/governed-operational-spec.schema.json), [ts/packages/healthos-gos-tooling/](../../ts/packages/healthos-gos-tooling/) |
| 0012 | [README.md](../../README.md), [swift/Package.swift](../../swift/Package.swift), [AGENTS.md](../../AGENTS.md) |

---

## 4. Matriz ADR ↔ Testes

| ADR | Testes relevantes em [swift/Tests/HealthOSTests/](../../swift/Tests/HealthOSTests/) | Outros |
|-----|---------------------------------------------|--------|
| 0001 | (estrutural — todos) | `swift build` valida hierarquia |
| 0002 | Smoke targets do `Makefile` | `make swift-test`, `make swift-smoke` |
| 0003 | [RegulatoryGovernanceTests.swift](../../swift/Tests/HealthOSTests/RegulatoryGovernanceTests.swift), [VeridiaSessionFacadeTests.swift](../../swift/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift) | — |
| 0004 | [StorageGovernanceTests.swift](../../swift/Tests/HealthOSTests/StorageGovernanceTests.swift), [RetrievalMemoryGovernanceTests.swift](../../swift/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift), [UserSovereigntyGovernanceTests.swift](../../swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift) | scanner anti-PII (proposto) |
| 0005 | (gates por linguagem) | `make swift-test`, `make ts-test`, `make python-check` |
| 0006 | [ProviderGovernanceTests.swift](../../swift/Tests/HealthOSTests/ProviderGovernanceTests.swift), contract tests cross-language (proposto) | `make validate-schemas` |
| 0007 | [ScribeProfessionalWorkspaceContractsTests.swift](../../swift/Tests/HealthOSTests/ScribeProfessionalWorkspaceContractsTests.swift), [VeridiaSessionFacadeTests.swift](../../swift/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift), [CrossAppCoordinationContractsTests.swift](../../swift/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift) | smoke targets |
| 0008 | (cobertura embutida em testes que usam `CoreLawfulContext`) | — |
| 0009 | (não específico — invariantes em todos) | experimental multi-node (futuro) |
| 0010 | [RegulatoryGovernanceTests.swift](../../swift/Tests/HealthOSTests/RegulatoryGovernanceTests.swift), [UserSovereigntyGovernanceTests.swift](../../swift/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift), [StorageGovernanceTests.swift](../../swift/Tests/HealthOSTests/StorageGovernanceTests.swift), [ServiceBoundaryTests.swift](../../swift/Tests/HealthOSTests/ServiceBoundaryTests.swift), [ServiceOperationsGovernanceTests.swift](../../swift/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift) | — |
| 0011 | [GOSRuntimeAdoptionTests.swift](../../swift/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift) | TS compiler tests em `ts/packages/healthos-gos-tooling/` |
| 0012 | (auditoria de docs) | revisão de PR |

Outros testes auxiliares úteis: [AsyncRuntimeGovernanceTests.swift](../../swift/Tests/HealthOSTests/AsyncRuntimeGovernanceTests.swift), [BackupGovernanceTests.swift](../../swift/Tests/HealthOSTests/BackupGovernanceTests.swift), [MSRRuntimeTests.swift](../../swift/Tests/HealthOSTests/MSRRuntimeTests.swift) — relacionados a gaps propostos (ver [GAPS-AND-CONFLICTS.md](GAPS-AND-CONFLICTS.md)).

---

## 5. Matriz ADR ↔ Pipelines / Schemas

| ADR | Pipelines e schemas |
|-----|---------------------|
| 0001 | `make swift-build` (valida grafo Package.swift) |
| 0002 | `make bootstrap`, `make swift-build`, `make swift-test`, `make swift-smoke` |
| 0003 | (sem schema dedicado — embutido em CoreLaw/GateContracts) |
| 0004 | (proposto) scanner anti-PII no CI |
| 0005 | `make swift-build`, `make ts-build`, `make python-check`, `make validate-all` |
| 0006 | [schemas/](../../schemas/), `make validate-schemas`, `make validate-contracts` |
| 0007 | `make swift-smoke` |
| 0008 | (embutido em validação CoreLaw) |
| 0009 | `make bootstrap` (single-node), pipeline mesh (futuro) |
| 0010 | `make validate-contracts` (drift detection) |
| 0011 | [schemas/governed-operational-spec.schema.json](../../schemas/governed-operational-spec.schema.json), [schemas/governed-operational-spec-authoring.schema.json](../../schemas/governed-operational-spec-authoring.schema.json), [schemas/governed-operational-spec-bundle-manifest.schema.json](../../schemas/governed-operational-spec-bundle-manifest.schema.json), [schemas/governed-operational-spec-lifecycle-audit.schema.json](../../schemas/governed-operational-spec-lifecycle-audit.schema.json), [schemas/governed-operational-spec-review-record.schema.json](../../schemas/governed-operational-spec-review-record.schema.json) |
| 0012 | `make validate-docs` |

---

## 6. Cobertura por target Swift

| Target | Tipo | Depende de | ADRs primárias | Smoke / test |
|--------|------|------------|----------------|--------------|
| `HealthOSCore` | lib | — | 0001, 0003, 0004, 0008, 0010, 0011 | `swift test` |
| `HealthOSProviders` | lib | Core | 0004, 0005, 0006, 0008 | `ProviderGovernanceTests` |
| `HealthOSAACI` | lib | Core, Providers | 0001, 0003, 0010, 0011 | `GOSRuntimeAdoptionTests` |
| `HealthOSMSR` | lib | Core, Providers (resources: Prompts) | 0003, 0004, 0010, 0011 (proposto: 0016) | `MSRRuntimeTests` |
| `HealthOSSessionRuntime` | lib | Core, AACI, Providers, MSR | 0001, 0003, 0010, 0011 | tests integrados |
| `HealthOSCLI` | exec | Core, SessionRuntime | 0007 | `make smoke-cli` |
| `HealthOSScribeApp` | exec | Core, SessionRuntime | 0007, 0010 | `make smoke-scribe` |
| `HealthOSVeridiaApp` | exec | Core | 0007, 0010 | `make smoke-veridia` |
| `HealthOSCloudClinicApp` | exec | Core | 0007, 0010 | `make smoke-cloudclinic` |
| `HealthOSTests` | test | todos os módulos | (todos) | `make swift-test` |

---

## 7. Notas de manutenção

- **Quando uma ADR for adicionada:** anexar linha em todas as três matrizes (módulos, código, testes) e em "Cobertura por target Swift" se relevante.
- **Quando um arquivo for movido/renomeado:** atualizar todos os links neste documento e em [README.md](../../README.md).
- **Quando uma ADR for supersedida:** marcar com tachado (`~~ADR-XXXX~~`) e linkar a superseding.
