# Core services

## IdentityService
Responsibilities:
- authenticate user/device context
- resolve civil identity token linkage under governance rules
- expose non-UI identity contract to apps and runtimes

## HabilitationService
Responsibilities:
- validate professional membership in a service
- open and close habilitation windows
- emit bounded access context for runtime use

## ConsentService
Responsibilities:
- evaluate purpose/finality, scope, and time validity
- return allow/deny/explain decisions
- expose audit hooks for sensitive reads

## GateService
Responsibilities:
- create gate requests from drafts
- capture resolutions and signatures
- prevent regulatory effect before resolution

## ProvenanceService
Responsibilities:
- append operation lineage
- capture provider/model/prompt/input/output hashes
- expose read-only audit/report patterns

## DataStoreService
Responsibilities:
- map canonical objects to filesystem/object paths
- maintain metadata link in SQL
- enforce audit hooks on read/write

## Open design points
- exact local API seam between Swift and TypeScript
- whether some services remain library-only in single-node mode
