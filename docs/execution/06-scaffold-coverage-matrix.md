# Scaffold coverage matrix

Legend:
- [x] established in scaffold
- [~] partially established / needs closure
- [ ] not yet established enough

## 1. Canonical system identity
- [x] HealthOS defined as the whole system
- [x] AACI defined as runtime inside HealthOS
- [x] app/interface distinction established
- [x] substrate/core/runtime/agent/app hierarchy established
- [x] glossary added
- [x] interface doctrine established: HealthOS is not end-user UX; apps/interfaces are end-user UX

## 2. Core laws
- [x] user, service, professional record, membership, habilitation represented
- [x] consent represented as first-class object
- [x] gate request and gate resolution represented
- [x] provenance represented
- [x] deny/failure semantics explicitly documented for core services
- [~] some law-level invariants still need stronger contract wording

## 3. Data and storage
- [x] SQL foundation exists
- [x] filesystem/object-store concept exists
- [x] layered data model exists
- [x] de-identification / re-identification concept exists
- [x] canonical directory implementation in Swift exists
- [x] storage API contract exists explicitly
- [~] SQL migration refinement and lawful-context examples still need closure

## 4. Runtime / actor / agent model
- [x] actor/agent distinction documented
- [x] runtime set established (AACI, async, user-agent)
- [x] message/mailbox concept exists
- [~] lifecycle states need stronger typed/formal closure
- [~] permission and failure model need fuller closure

## 5. AACI
- [x] purpose and boundaries established
- [x] session modes established
- [x] hot/warm/cold path concept established
- [x] initial subagents established
- [~] subagent contracts still need fuller detail
- [~] provider routing needs fuller operational policy

## 6. Apps / interfaces
- [x] Scribe defined
- [x] Sortio defined
- [x] CloudClinic defined
- [x] app/core separation established
- [~] detailed state maps and full flow contracts still need closure

## 7. Networking / operations
- [x] local-first stance established
- [x] mesh/VPN posture established
- [x] launchd/backup/network docs scaffolded
- [~] runbook detail still needs closure
- [~] MeshProvider abstraction still needs fuller contract form

## 8. Providers / ML
- [x] provider abstraction established
- [x] offline ML boundary established
- [x] fine-tuning/adapters concept scaffolded
- [~] benchmark policy still needs closure
- [~] dataset governance and promotion/rollback need fuller detail

## 9. AI execution layer
- [x] master plan created
- [x] AI operating protocol created
- [x] status tracking created
- [x] definition of done created
- [x] skills roadmap created
- [~] skills are still early skeletons, not full reusable skill packs

## 10. First vertical slice readiness
- [x] slice target defined
- [x] slice dependency order defined
- [x] core-law failure semantics no longer block honest closure
- [~] runtime precision, app-flow precision, and storage-lawful-context detail still need tightening before heavy implementation

## Practical reading

The scaffold is already real and structured.
What remains is not identity of the system, but closure work on:
- law precision beyond baseline
- runtime precision
- app flow precision
- ops detail
- provider/ML governance detail

That means the project is in a serious pre-coding hardening phase with most foundational identity and contract questions already anchored.
