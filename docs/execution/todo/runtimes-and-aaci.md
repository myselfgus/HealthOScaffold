# TODO — Runtimes and AACI

## COMPLETED

### RT-001 Formalize actor vs agent model
Outcome:
- actor/agent distinction formalized in architecture and reflected in Swift/TypeScript contracts
Files touched:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `swift/Sources/HealthOSCore/ActorModel.swift`
- `ts/packages/contracts/src/index.ts`

### RT-002 Define runtime lifecycle contract
Outcome:
- runtime lifecycle states and failure categories formalized in docs, schemas, Swift, and TypeScript
Files touched:
- `docs/architecture/08-runtime-actor-agent-model.md`
- `schemas/contracts/runtime-lifecycle.schema.json`
- `swift/Sources/HealthOSCore/ActorModel.swift`
- `ts/packages/contracts/src/index.ts`

### AACI-001 Expand AACI session model
Outcome:
- session modes documented with bounded meaning and explicit authorization caveat
Files touched:
- `docs/architecture/09-aaci.md`

### AACI-002 Define hot / warm / cold path routing
Outcome:
- path classes documented and baseline task allocation defined
Files touched:
- `docs/architecture/09-aaci.md`

### AACI-003 Specify subagent boundaries
Outcome:
- subagent boundaries defined in architecture and reflected in Swift descriptors for the initial subagent set
Files touched:
- `docs/architecture/09-aaci.md`
- `swift/Sources/HealthOSAACI/AACI.swift`
- `schemas/contracts/agent-boundary.schema.json`
- `schemas/contracts/agent-descriptor.schema.json`

### RT-003 Decide retry envelope and backpressure policy by runtime
Outcome:
- runtime operational policy added covering degradation, retry, backpressure, and failure visibility across AACI hot/warm paths, async runtime, and user-agent runtime
Files touched:
- `docs/architecture/20-runtime-operational-policy.md`

### AACI-004 Define provider-routing policy per task class
Outcome:
- provider routing baseline defined by task class, privacy mode, and fallback policy
Files touched:
- `docs/architecture/16-providers-and-ml.md`

## READY

### RT-004 Define runtime status surfaces for apps/interfaces
Objective:
- specify which runtime states and degraded modes must surface into Scribe, Sortio, and CloudClinic
Files:
- `docs/architecture/10-app-state-model.md`
- app architecture docs as needed
Dependencies:
- RT-003, AACI-004
Definition of done:
- runtime state visibility is consistent across apps and does not invent governance meaning

## TESTS / VALIDATION

- no AACI path bypasses gate
- no subagent requires undefined access semantics
- provider routing remains provider-agnostic at contract level
- actor/agent/runtime vocabulary matches glossary and schemas
