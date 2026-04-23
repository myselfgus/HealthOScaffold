# Runtime, actor, and agent model

## Proposed relation
- actor = concurrency/state/isolation primitive
- agent = actor with semantic role, permissions, boundary, and domain responsibility

## Runtime contract
Each runtime should eventually expose:
- start
- ready
- active
- paused (optional)
- terminating
- terminated
- failed

## Mailbox model
- messages are explicit contracts
- every message has from, to, kind, payload, correlation
- runtime controls mailbox delivery semantics

## Boundary model
Each agent must state:
- what it can read
- what it can write
- what it can invoke
- what governance checks must pass first

## Runtime set
- AACI runtime
- async runtime
- user-agent runtime

## Open tasks
- formalize lifecycle states in code and schemas
- define inter-runtime transport for single-node mode
- define failure/retry semantics for async and AACI subflows
