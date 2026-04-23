# Runtime, actor, and agent model

## Proposed relation
- actor = concurrency/state/isolation primitive
- agent = actor with semantic role, permissions, boundary, and domain responsibility

## Why the distinction exists
Actors solve execution concerns.
Agents solve execution plus domain meaning.
This allows HealthOS to separate isolation/lifecycle mechanics from professional, user, and AACI-specific responsibilities.

## Runtime contract
Every runtime must be expressible in the same lifecycle language:
- booting
- ready
- active
- paused
- terminating
- terminated
- failed

### State meaning
- booting: runtime is initializing dependencies and not yet able to process work
- ready: runtime is healthy and can accept work
- active: runtime is processing work
- paused: runtime is intentionally not accepting new work but remains live
- terminating: runtime is shutting down and draining or abandoning work according to policy
- terminated: runtime has stopped cleanly
- failed: runtime or critical dependency entered unrecoverable error state

## Runtime failure categories
- configuration_failure
- dependency_failure
- authorization_failure
- integrity_failure
- transport_failure
- timeout_failure
- internal_failure

Authorization failure is not a crash.
A denied action can occur inside a healthy runtime.

## Actor contract
Each actor must expose:
- actorId
- runtimeKind
- receive(message)

Actors are not assumed to be domain-aware beyond their explicit contract.

## Agent contract
Each agent must additionally expose:
- semantic role
- permissions
- boundary description
- allowed input kinds
- emitted output kinds
- governance requirements before sensitive operations

## Mailbox model
- messages are explicit contracts
- every message has from, to, kind, payload, correlation
- runtime controls mailbox delivery semantics
- mailbox processing may be at-most-once or retrying depending on runtime policy, but never implicit

## Permission model
Permissions are capability strings grouped by concern:
- read capabilities
- write capabilities
- invoke capabilities
- governance-check capabilities

Examples:
- `session:read`
- `capture:write`
- `patient:context:read`
- `consent:check`
- `gate:request`

## Boundary model
Each agent must state:
- what it can read
- what it can write
- what it can invoke
- what governance checks must pass first
- what it must never finalize or mutate

## Runtime set
- AACI runtime
- async runtime
- user-agent runtime

## Single-node inter-runtime transport
Initial single-node transport is:
- loopback HTTP for service/runtime coordination
- PostgreSQL for canonical state and metadata
- filesystem/object references for larger payloads

## Retry/failure policy baseline
- async runtime may retry according to explicit job policy
- AACI hot-path work should prefer bounded failure and graceful degradation over heavy retries
- user-agent runtime should prefer explainable denial over silent failure

## Practical rule
No runtime, actor, or agent contract may blur the distinction between:
- computational preparation
- human approval/effectuation

That boundary is preserved by gate semantics and core law.
