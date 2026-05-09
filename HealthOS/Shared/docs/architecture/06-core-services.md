# Core services

## IdentityService
Responsibilities:
- authenticate user/device context
- resolve civil identity token linkage under governance rules
- expose non-UI identity contract to apps and runtimes

Success output:
- authenticated subject context
- device/session context
- pseudonymous user linkage token

Deny / failure outputs:
- invalid credentials or invalid device trust
- unresolved civil linkage
- suspended/disabled user context
- insufficient re-identification authority for a requested operation

## HabilitationService
Responsibilities:
- validate professional membership in a service
- open and close habilitation windows
- emit bounded access context for runtime use

Success output:
- active habilitation context with service, professional record, and time window

Deny / failure outputs:
- no active professional record
- service membership absent or inactive
- record expired or not validated
- attempted action outside habilitation window

## ConsentService
Responsibilities:
- evaluate purpose/finality, scope, and time validity
- return allow/deny/explain decisions
- expose audit hooks for sensitive reads

Success output:
- allow decision with matching consent basis and evaluated scope

Deny / failure outputs:
- no matching consent
- consent expired
- consent revoked
- requested scope exceeds granted scope
- requested finality/purpose mismatch

## GateService
Responsibilities:
- create gate requests from drafts with explicit review type, finalization target, and rationale
- capture resolutions, reviewer role, timestamp, and signature expectations
- prevent regulatory effect or document finalization before resolution

Success output:
- pending gate request
- approved/rejected/cancelled gate resolution with explicit reviewer context

Deny / failure outputs:
- draft not eligible for gate
- wrong resolver role
- required signature absent or invalid
- attempt to treat unresolved draft as effective act or finalized document

## ProvenanceService
Responsibilities:
- append operation lineage
- capture provider/model/prompt/input/output hashes
- expose read-only audit/report patterns

Success output:
- appended immutable provenance record

Deny / failure outputs:
- malformed provenance payload
- missing operation identity
- attempted mutation of append-only record

## DataStoreService
Responsibilities:
- map canonical objects to filesystem/object paths
- maintain metadata link in SQL
- enforce audit hooks on read/write

Success output:
- stored object metadata + object path + audit/provenance linkage
- retrieved object under lawful access context

Deny / failure outputs:
- object write without owner/titular context
- object read without lawful access basis
- object path mismatch / integrity mismatch
- attempted read requiring re-identification without authorization

## Shared rule
All deny/failure outputs must be explicit and lawful.
A deny is not a crash.
A crash is not an authorization decision.
Every sensitive deny path should still be auditable when appropriate.

## Open design points
- whether some services remain library-only in single-node mode
- whether deny outputs should be normalized into one shared error envelope schema
