# Matriz de Rastreabilidade — ADRs ↔ Módulos ↔ Código ↔ Testes ↔ Pipelines

Data da revisão: 2026-05-06
Fonte de verdade da topologia: [HealthOS/Package.swift](../../../HealthOS/Package.swift).

> Esta matriz é viva. Atualizar quando: (a) uma ADR for adicionada ou supersedida; (b) um caminho de código referenciado por uma ADR mover/renomear; (c) um teste relacionado for adicionado/removido.

---

## 1. Topologia de dependências (Package.swift)

```
Tier 1:
  HealthOSCore

Tier 2:
  HealthOSProviders       → Core
  HealthOSGOS             → Core
  HealthOSAACI            → Core, GOS, Providers
  HealthOSMSR             → Core, Providers (resources: Prompts/)
  HealthOSAsyncRuntime    → Core
  HealthOSUserAgentRuntime→ Core
  HealthOSServiceRuntime  → Core
  HealthOSSessionRuntime  → Core, AACI, Providers, MSR

Tier 3:
  HealthOSBoundary        → Core, GOS, AACI, MSR, Async, User-Agent, Service, Session

Executáveis:
  HealthOSCLI             → Core, SessionRuntime
  HealthOSScribeStage     → Boundary, Core, SessionRuntime
  HealthOSVeridiaStage    → Boundary, Core
  HealthOSCloudClinicStage→ Boundary

Structural / shared tests:
  HealthOSCoreTests, HealthOSRuntimeTests, HealthOSBoundaryTests,
  HealthOSStageSmokeTests, HealthOSConstructionSystemTests,
  HealthOSSupportToolingTests, HealthOSTests
```

**Validação.** Não há violação de hierarquia em [HealthOS/Package.swift](../../../HealthOS/Package.swift): Core é base; Tier 2 depende de Core e dos providers/GOS necessários; Boundary agrega superfícies mediadas; Stage executables convergem para Boundary com TODOs explícitos para remover dependências diretas remanescentes de Core/SessionRuntime conforme as facades amadurecem.

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
| 0013 | Platform/App/Construction boundary | ● | ● | ● | ● | ● | ● | ● | ● | ● |

---

## 3. Matriz ADR ↔ Código

| ADR | Caminhos de código primários |
|-----|-----------------------------|
| 0001 | [HealthOS/Package.swift](../../../HealthOS/Package.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/), [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/AACI.swift), [HealthOS/Shared/docs/architecture/01-overview.md](../architecture/01-overview.md) |
| 0002 | [HealthOS/Package.swift](../../../HealthOS/Package.swift), [Makefile](../../../Makefile), [scripts/bootstrap-local.sh](../../../scripts/bootstrap-local.sh), [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/DirectoryLayout.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/DirectoryLayout.swift) |
| 0003 | [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GateContracts.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift), [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime/SessionRunner.swift) |
| 0004 | [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ReidentificationGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/ReidentificationGovernance.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift) |
| 0005 | [HealthOS/Package.swift](../../../HealthOS/Package.swift), [HealthOS/Constructor/ts/package.json](../../../HealthOS/Constructor/ts/package.json), [HealthOS/Support/python/pyproject.toml](../../../HealthOS/Support/python/pyproject.toml), [Makefile](../../../Makefile) |
| 0006 | [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift), [HealthOS/Constructor/ts/packages/](../../../HealthOS/Constructor/ts/packages/), [HealthOS/Tier1-Mestral-Core/Schemas/](../../../HealthOS/Tier1-Mestral-Core/Schemas/) |
| 0007 | [HealthOS/Shared/Sources/HealthOSCLI/CLIEntrypoint.swift](../../../HealthOS/Shared/Sources/HealthOSCLI/CLIEntrypoint.swift), [HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/](../../../HealthOS/Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage/), [HealthOS/Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage/](../../../HealthOS/Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage/), [HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage/](../../../HealthOS/Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage/), [HealthOS/Shared/docs/architecture/19-interface-doctrine.md](../architecture/19-interface-doctrine.md) |
| 0008 | [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/SharedEnvelopeVocabulary.swift), [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSProviders/ProviderProtocols.swift) |
| 0009 | [HealthOS/Package.swift](../../../HealthOS/Package.swift), [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/StorageContracts.swift), [HealthOS/Shared/docs/architecture/15-mesh-provider.md](../architecture/15-mesh-provider.md), [scripts/bootstrap-local.sh](../../../scripts/bootstrap-local.sh) |
| 0010 | [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/CoreLaw.swift), [RegulatoryGovernance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/RegulatoryGovernance.swift), [Provenance.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/Provenance.swift), [UserSovereigntyContracts.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/UserSovereigntyContracts.swift) |
| 0011 | [HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GovernedOperationalSpec.swift), [GOSFileBackedRegistry.swift](../../../HealthOS/Tier1-Mestral-Core/Sources/HealthOSCore/GOSFileBackedRegistry.swift), [HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSBindings.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSBindings.swift), [GOSRuntimeActivation.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeActivation.swift), [GOSRuntimeContext.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeContext.swift), [GOSRuntimeResolution.swift](../../../HealthOS/Tier2-GOS-Runtimes/Sources/HealthOSAACI/GOSRuntimeResolution.swift), [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json), [HealthOS/Constructor/ts/packages/healthos-gos-tooling/](../../../HealthOS/Constructor/ts/packages/healthos-gos-tooling/) |
| 0012 | [README.md](../../../README.md), [HealthOS/Package.swift](../../../HealthOS/Package.swift), [AGENTS.md](../../../AGENTS.md) |
| 0013 | [HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md](../architecture/50-app-layer-boundary-and-reference-apps.md), [HealthOS/Shared/docs/execution/21-structural-ontology-and-product-readiness-plan.md](../execution/21-structural-ontology-and-product-readiness-plan.md), [AGENTS.md](../../../AGENTS.md), [HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md](../../../HealthOS/Constructor/Steward/prompts/prompt-architecture-template.md) |

---

## 4. Matriz ADR ↔ Testes

| ADR | Testes relevantes em [HealthOS/Shared/Tests/HealthOSTests/](../../../HealthOS/Shared/Tests/HealthOSTests/) | Outros |
|-----|---------------------------------------------|--------|
| 0001 | (estrutural — todos) | `swift build` valida hierarquia |
| 0002 | Smoke targets do `Makefile` | `make swift-test`, `make swift-smoke` |
| 0003 | [RegulatoryGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/RegulatoryGovernanceTests.swift), [VeridiaSessionFacadeTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift) | — |
| 0004 | [StorageGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/StorageGovernanceTests.swift), [RetrievalMemoryGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/RetrievalMemoryGovernanceTests.swift), [UserSovereigntyGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift) | scanner anti-PII (proposto) |
| 0005 | (gates por linguagem) | `make swift-test`, `make ts-test`, `make python-check` |
| 0006 | [ProviderGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/ProviderGovernanceTests.swift), contract tests cross-language (proposto) | `make validate-schemas` |
| 0007 | [ScribeProfessionalWorkspaceContractsTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/ScribeProfessionalWorkspaceContractsTests.swift), [VeridiaSessionFacadeTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/VeridiaSessionFacadeTests.swift), [CrossAppCoordinationContractsTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/CrossAppCoordinationContractsTests.swift) | smoke targets |
| 0008 | (cobertura embutida em testes que usam `CoreLawfulContext`) | — |
| 0009 | (não específico — invariantes em todos) | experimental multi-node (futuro) |
| 0010 | [RegulatoryGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/RegulatoryGovernanceTests.swift), [UserSovereigntyGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/UserSovereigntyGovernanceTests.swift), [StorageGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/StorageGovernanceTests.swift), [ServiceBoundaryTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/ServiceBoundaryTests.swift), [ServiceOperationsGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/ServiceOperationsGovernanceTests.swift) | — |
| 0011 | [GOSRuntimeAdoptionTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/GOSRuntimeAdoptionTests.swift) | TS compiler tests em `HealthOS/Constructor/ts/packages/healthos-gos-tooling/` |
| 0012 | (auditoria de docs) | revisão de PR |
| 0013 | (auditoria de HealthOS/Shared/docs/governança) | tier mapping, language diagnostics, Core semantic leak diagnostic |

Outros testes auxiliares úteis: [AsyncRuntimeGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/AsyncRuntimeGovernanceTests.swift), [BackupGovernanceTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/BackupGovernanceTests.swift), [MSRRuntimeTests.swift](../../../HealthOS/Shared/Tests/HealthOSTests/MSRRuntimeTests.swift) — relacionados a gaps propostos (ver [GAPS-AND-CONFLICTS.md](GAPS-AND-CONFLICTS.md)).

---

## 5. Matriz ADR ↔ Pipelines / Schemas

| ADR | Pipelines e schemas |
|-----|---------------------|
| 0001 | `make swift-build` (valida grafo Package.swift) |
| 0002 | `make bootstrap`, `make swift-build`, `make swift-test`, `make swift-smoke` |
| 0003 | (sem schema dedicado — embutido em CoreLaw/GateContracts) |
| 0004 | (proposto) scanner anti-PII no CI |
| 0005 | `make swift-build`, `make ts-build`, `make python-check`, `make validate-all` |
| 0006 | [HealthOS/Tier1-Mestral-Core/Schemas/](../../../HealthOS/Tier1-Mestral-Core/Schemas/), `make validate-schemas`, `make validate-contracts` |
| 0007 | `make swift-smoke` |
| 0008 | (embutido em validação CoreLaw) |
| 0009 | `make bootstrap` (single-node), pipeline mesh (futuro) |
| 0010 | `make validate-contracts` (drift detection) |
| 0011 | [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec.schema.json), [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-authoring.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-authoring.schema.json), [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-bundle-manifest.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-bundle-manifest.schema.json), [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-lifecycle-audit.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-lifecycle-audit.schema.json), [HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-review-record.schema.json](../../../HealthOS/Tier1-Mestral-Core/Schemas/governed-operational-spec-review-record.schema.json) |
| 0012 | `make validate-docs` |
| 0013 | `make validate-docs`, `make validate-contracts`, language and Core leak diagnostics |

---

## 6. Cobertura por target Swift

| Target | Tipo | Depende de | ADRs primárias | Smoke / test |
|--------|------|------------|----------------|--------------|
| `HealthOSCore` | lib | — | 0001, 0003, 0004, 0008, 0010, 0011 | `swift test` |
| `HealthOSProviders` | lib | Core | 0004, 0005, 0006, 0008 | `ProviderGovernanceTests` |
| `HealthOSAACI` | lib | Core, Providers | 0001, 0003, 0010, 0011 | `GOSRuntimeAdoptionTests` |
| `HealthOSMSR` | lib | Core, Providers (resources: Prompts) | 0003, 0004, 0010, 0011 (proposto: 0016) | `MSRRuntimeTests` |
| `HealthOSSessionRuntime` | lib | Core, AACI, Providers, MSR | 0001, 0003, 0010, 0011 | tests integrados |
| `HealthOSCLI` | exec | Core, SessionRuntime | 0007, 0013 | `make smoke-cli` |
| `HealthOSScribeStage` | exec | Boundary, Core, SessionRuntime | 0007, 0010, 0013 | `make smoke-scribe` |
| `HealthOSVeridiaStage` | exec | Boundary, Core | 0007, 0010, 0013 | `make smoke-veridia` |
| `HealthOSCloudClinicStage` | exec | Boundary | 0007, 0010, 0013 | `make smoke-cloudclinic` |
| `HealthOSBoundary` | lib | Core, GOS, AACI, MSR, Async, User-Agent, Service, Session | 0013 | `HealthOSBoundaryTests` |
| `HealthOSConstructionSystemTests` | test | structural | 0012, 0013 | `HealthOS-Construction` scheme / `swift test` |
| `HealthOSSupportToolingTests` | test | structural | 0005, 0006 | `HealthOS-Support` scheme / `swift test` |
| `HealthOSTests` | test | Core, AACI, Providers, MSR, SessionRuntime | (todos) | `make swift-test` |

---

## 7. Notas de manutenção

- **Quando uma ADR for adicionada:** anexar linha em todas as três matrizes (módulos, código, testes) e em "Cobertura por target Swift" se relevante.
- **Quando um arquivo for movido/renomeado:** atualizar todos os links neste documento e em [README.md](../../../README.md).
- **Quando uma ADR for supersedida:** marcar com tachado (`~~ADR-XXXX~~`) e linkar a superseding.
