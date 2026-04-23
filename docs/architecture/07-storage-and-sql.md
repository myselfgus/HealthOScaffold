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

## Lawful-context examples

### Example 1: patient-owned artifact read by the same user
Context:
- actor = user-agent runtime acting for the same user
- owner = `usuario(cpfHash)`
- basis = self-access
- expected result = allowed

Minimal lawfulContext example:
```json
{
  "actorRole": "user-agent",
  "actorUserId": "<same-user-id>",
  "accessBasis": "self",
  "scope": "own-data"
}
```

### Example 2: service professional retrieving patient operational context during active work session
Context:
- actor = AACI/ContextRetrievalAgent under professional session
- owner = patient-linked operational artifact in service scope
- basis = active habilitation + matching consent/finality + active session
- expected result = allowed if scope matches

Minimal lawfulContext example:
```json
{
  "actorRole": "professional-agent",
  "habilitationId": "<active-habilitation-id>",
  "serviceId": "<service-id>",
  "patientUserId": "<patient-id>",
  "consentBasis": "matched",
  "finalidade": "care-context-retrieval",
  "sessionId": "<session-id>"
}
```

### Example 3: service professional attempting read after habilitation closed
Context:
- actor = professional or subagent
- basis = stale/closed habilitation
- expected result = denied

Minimal lawfulContext example:
```json
{
  "actorRole": "professional-agent",
  "habilitationId": "<closed-habilitation-id>",
  "serviceId": "<service-id>",
  "patientUserId": "<patient-id>",
  "consentBasis": "matched",
  "finalidade": "care-context-retrieval"
}
```

Decision rule:
- deny because access basis is no longer temporally valid

### Example 4: re-identification layer access by ordinary operational agent
Context:
- actor = AACI or async subagent
- owner = re-identification mapping layer
- basis = operational convenience only
- expected result = denied

Decision rule:
- re-identification is never granted by convenience
- explicit governed authorization is required

### Example 5: audit/list operation for service-owned drafts
Context:
- actor = CloudClinic service-facing interface under operator context
- owner = `servico(serviceId)`
- basis = service-scoped role and lawful operational visibility
- expected result = allowed for references and metadata, not necessarily for all payload bodies

Minimal lawfulContext example:
```json
{
  "actorRole": "service-operator",
  "serviceId": "<service-id>",
  "accessBasis": "service-scope",
  "scope": "draft-metadata"
}
```

## Integrity strategy

See:
- `docs/architecture/21-object-integrity-strategy.md`

Baseline:
- SHA-256 content hash
- mismatch => `integrity_failure`
- mismatch must be auditable and never silently repaired in place

## Open tasks
- decide whether lawfulContext should remain a flexible map or become a stricter shared transport envelope
