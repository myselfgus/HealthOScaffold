# GEMINI.md

Este documento serve como o manual de instrução central para a colaboração entre humanos e IA no repositório **HealthOScaffold**.

## Identidade do repositório e vocabulário de scaffold

HealthOScaffold é o nome histórico do repositório e a fase inicial de andaime/fundação do HealthOS. Ele não é um produto separado do HealthOS. Toda arquitetura, contrato, runtime, app, teste e documentação implementados neste repositório são trabalho do HealthOS, salvo marcação explícita como experimental ou deprecated.

Use "scaffold" apenas para descrever maturidade ou fase de bootstrap/fundação, nunca para sugerir que este repositório está fora do HealthOS ou que outro HealthOS será criado fora daqui.

## 1. Visão Geral do Projeto
O HealthOS é uma plataforma soberana para dados de saúde e operações clínicas. Este repositório é o repositório de construção do HealthOS e encontra-se em fase de **"scaffold hardening"** (fortalecimento da estrutura base), com foco em arquitetura canônica, contratos de governança e validação de invariantes, não sendo um produto pronto para produção ou EHR completo.

### Hierarquia Canônica
- **Substrato Material:** Host, armazenamento, rede privada/mesh, backups.
- **Core (Law/Governance):** Identidade, consentimento, habilitação, armazenamento, proveniência, gate, auditoria.
- **GOS (Governed Operational Spec):** Camada de tradução operacional subordinada ao Core.
- **Runtimes:** AACI, Async, User-Agent.
- **Atores/Agentes:** Bounded, governados por papéis.
- **Apps/Interfaces:** Scribe (profissional), Sortio (paciente), CloudClinic (serviço).

## 2. Princípios de Execução (Mandatos)
- **Constitucionalidade:** HealthOS é o sistema completo; apps são apenas consumidores de superfícies mediadas. O Core define a lei; as apps/GOS nunca definem leis constitucionais.
- **Honestidade de Maturidade:** Jamais finja prontidão de produção para integrações (ex: FHIR, ICP-Brasil, busca semântica, provedores externos). Mantenha a distinção entre componentes HealthOS em maturidade de scaffold e capacidades realmente implementadas/endurecidas.
- **Falha Confiável (Fail-Closed):** A governança (consentimento, gate, habilitação) deve sempre falhar de forma segura.
- **Segurança de Dados:** Identificadores diretos (CPF, nomes) são estritamente separados do conteúdo operacional.

## 3. Protocolo de Trabalho
Antes de qualquer codificação, siga rigorosamente:
1. **Leitura de Contexto:** `README.md` -> `docs/execution/README.md` -> `docs/execution/00-master-plan.md` -> `docs/execution/11-current-maturity-map.md`.
2. **Uso de Skills:** Consulte os arquivos em `docs/execution/skills/` específicos para o seu domínio (ex: `aaci-skill.md`, `core-law-skill.md`). Para trabalho em Swift/SwiftUI/Xcode ou Apple platform, leia também as macOS skills em `docs/execution/skills/<nome>/SKILL.md` — o índice completo está em `docs/execution/skills/README.md`.
3. **Validação:** Use o conjunto de comandos `make validate-all`.
4. **Steward Agent:** Utilize `@healthos/steward` para diagnósticos e planos, mantendo a documentação em `docs/` como fonte da verdade.

## 4. Comandos Essenciais
- **Bootstrap:** `make bootstrap`
- **Build/Test:** `make swift-build`, `make swift-test`, `make ts-build`, `make ts-test`
- **Validação:** `make validate-all` (essencial antes de concluir qualquer tarefa)
- **Smoke Tests:** `make smoke-cli`, `make smoke-scribe`

## 5. Estrutura de Diretórios
- `docs/`: Arquitetura, planos de execução, ADRs e backlog.
- `schemas/`: Contratos JSON Schema (Core para App).
- `swift/`: Core, AACI, Provedores, CLI e app Scribe.
- `ts/`: Ferramentas de governança (GOS, Steward, Runtimes).
- `gos/`: Especificações operacionais.
- `apps/`: Fronteiras de interface (Scribe, Sortio, CloudClinic).

## 6. Restrições Absolutas
- **NUNCA:** Substitua a autoridade clínica, bypass de gates, injete narrativas fictícias ou coloque segredos no repositório.
- **Sempre:** Mantenha a rastreabilidade (proveniência) em qualquer modificação de estado operacional.
