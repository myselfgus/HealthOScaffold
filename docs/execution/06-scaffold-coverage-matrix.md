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
- [x] initial hash/integrity strategy is established
- [~] lawfulContext transport strictness still needs final decision

## 4. Runtime / actor / agent model
- [x] actor/agent distinction documented and typed
- [x] runtime set established (AACI, async, user-agent)
- [x] message/mailbox concept exists
- [x] lifecycle states formalized across docs, schema, Swift, and TypeScript
- [x] permission/boundary model established at scaffold level
- [x] retry/backpressure baseline exists
- [~] runtime-state surface policy across apps still needs one more closure pass

## 5. AACI
- [x] purpose and boundaries established
- [x] session modes established with bounded meaning
- [x] hot/warm/cold path concept established
- [x] initial subagents established
- [x] subagent contracts substantially defined
- [x] provider-routing baseline exists by task class
- [~] provider-routing policy still needs threshold/benchmark detail for stronger operational closure

## 6. Apps / interfaces
- [x] Scribe defined
- [x] Sortio defined
- [x] CloudClinic defined
- [x] app/core separation established
- [x] shared state vocabulary exists
- [x] primary flow maps exist for all three apps
- [~] runtime-state surfaces and some deeper screen/interaction contracts still need closure

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
- [x] provider benchmark dimensions and routing outcomes exist
- [~] dataset governance and promotion/rollback need fuller procedural detail

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
- [x] storage and runtime baselines are strong enough for controlled implementation
- [~] app runtime-state surfacing and provider-threshold details still need tightening before heavy implementation

## Practical reading

The scaffold is already real and structured.
What remains is not identity of the system, but closure work on:
- runtime-state surfacing into apps
- ops detail
- provider/ML governance detail
- lawfulContext transport strictness
- stronger reusable AI skills

That means the project is in a late pre-coding hardening phase with most foundational identity, contract, boundary, and flow questions already anchored.
