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
- keep object payloads out of loopback transport whenever possible

## PostgreSQL responsibilities
- hold canonical metadata and governance state
- hold sessions, events, drafts, gates, provenance, consent, habilitation
- index retrieval and audit patterns
- link metadata rows to filesystem/object references

## Explicit storage contract
- `put(owner, kind, layer, content, metadata)` -> returns object reference
- `get(objectRef, lawfulContext)` -> returns content if lawful
- `list(owner, filters, lawfulContext)` -> returns object references
- `audit(objectRef, action, actorId, metadata)` -> records sensitive interaction

The canonical Swift contract lives in:
- `swift/Sources/HealthOSCore/StorageContracts.swift`

## Object naming guidance

Use owner-rooted, layer-aware paths.
Examples:
- `users/<cpf-hash>/artifacts/<kind>/<uuid>.bin`
- `users/<cpf-hash>/drafts/<kind>/<uuid>.json`
- `services/<service-id>/records/<kind>/<uuid>.bin`
- `services/<service-id>/drafts/<kind>/<uuid>.json`
- `users/<cpf-hash>/reidentification/<uuid>.bin`

Guideline:
- artifact identity lives in SQL/metadata
- payload identity lives in object path + content hash
- direct identifiers stay out of convenience path names beyond governed pseudonymous keys

## Open tasks
- expand migration comments and invariants
- decide first concrete hash strategy implementation for object content verification
- add lawful-context examples for reads across user/service scopes
