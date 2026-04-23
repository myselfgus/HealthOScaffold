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

## READY

### RT-003 Decide retry envelope and backpressure policy by runtime
Objective:
- define how hot path, warm path, and async work should degrade, retry, or fail visibly
Files:
- `docs/architecture/08-runtime-actor-agent-model.md`
- optional runtime docs/contracts
Dependencies:
- RT-002, AACI-002
Definition of done:
- runtime failure handling is operationally actionable instead of merely named

### AACI-004 Define provider-routing policy per task class
Objective:
- specify which task classes prefer local/private-first providers and when remote fallback is permitted
Files:
- `docs/architecture/09-aaci.md`
- `docs/architecture/16-providers-and-ml.md`
Dependencies:
- AACI-002, AACI-003
Definition of done:
- provider routing becomes policy-driven and compatible with privacy posture

## TESTS / VALIDATION

- no AACI path bypasses gate
- no subagent requires undefined access semantics
- provider routing remains provider-agnostic at contract level
- actor/agent/runtime vocabulary matches glossary and schemas
