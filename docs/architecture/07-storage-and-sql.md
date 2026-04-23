# Storage and SQL

## Canonical storage layers
- direct identifiers
- clinical/operational content
- access/governance metadata
- derived AI artifacts
- re-identification mapping

## Filesystem responsibilities
- hold user/service/agent/runtime/model trees
- store artifacts and object payloads
- preserve deterministic object paths

## PostgreSQL responsibilities
- hold canonical metadata and governance state
- hold sessions, events, drafts, gates, provenance, consent, habilitation
- index retrieval and audit patterns

## Storage API to define
- put(owner, kind, layer, content)
- get(id, context)
- list(owner, filters)
- audit(id, action, actor)

## Open tasks
- finalize directory layout implementation in Swift
- expand migration comments and invariants
- decide first object naming convention for draft and transcript artifacts
