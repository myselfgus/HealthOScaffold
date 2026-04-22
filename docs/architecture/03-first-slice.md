# First vertical slice

## Goal

Deliver the minimal cross-layer slice that proves the system shape:

1. professional authenticates and selects service
2. service membership and professional habilitation are validated
3. patient is selected
4. session opens
5. session input is captured
6. transcription agent emits transcript events
7. context retrieval agent fetches prior operational context
8. draft composer produces a SOAP draft artifact
9. gate coordinator issues a gate request
10. professional approves/rejects the draft
11. gate resolution is recorded
12. provenance is appended
13. draft and final artifact are persisted

## Components touched

- Core Identity
- Habilitation Service
- Consent Service
- DataStore Service
- Provenance Service
- AACI Runtime
- Scribe Interface
- Gate Service
- PostgreSQL metadata
- filesystem object store
