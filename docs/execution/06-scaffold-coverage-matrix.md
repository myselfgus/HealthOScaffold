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

## 2. Core laws
- [x] user, service, professional record, membership, habilitation represented
- [x] consent represented as first-class object
- [x] gate request and gate resolution represented
- [x] provenance represented
- [~] deny/failure semantics still need explicit closure
- [~] some law-level invariants still need stronger contract wording

## 3. Data and storage
- [x] SQL foundation exists
- [x] filesystem/object-store concept exists
- [x] layered data model exists
- [x] de-identification / re-identification concept exists
- [~] canonical directory implementation in Swift still needs full closure
- [~] storage API contract still needs full explicitness

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
- [~] core-law failure semantics still block honest closure
- [~] storage/runtime contracts still need tightening before heavy implementation

## Practical reading

The scaffold is already real and structured.
What remains is not basic identity or shape, but closure work on:
- law precision
- storage precision
- runtime precision
- app flow precision
- ops detail

That means the project is now in a good pre-coding hardening phase, not in a blank-page phase.
