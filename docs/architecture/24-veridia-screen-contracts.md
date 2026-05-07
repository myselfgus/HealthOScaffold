# Veridia screen contracts

Screen-level contracts for Veridia, an initial patient health identity Stage for HealthOS.
All screens consume Core-mediated surfaces. Veridia does not own consent, habilitation, finality, gate, provenance, or storage law.
No final UI implementation is claimed at scaffold maturity.

Future Veridia screen wiring must not advance unless the mediated surface it consumes is implemented and stable, and the Veridia Custom covers that surface.

## Identity

Primary actions:
- view HealthOS health identity overview
- view linked service state
- view access and custody state summary

Contract calls:
- Core-mediated identity state retrieval (pseudonymized/safe-ref surface)

Result states:
- `identity-loaded`
- `identity-restricted`
- `identity-degraded`
- `failed`

## Keys and access

Primary actions:
- view mediated key custody controls presented by Core
- view access grant/revoke state

Contract calls:
- Core-backed key and access control surface (Secure Enclave / Keychain mediated by Core)

Result states:
- `keys-loaded`
- `keys-restricted`
- `access-revoked`
- `failed`

Note: Veridia presents Core-backed controls. Veridia does not store keys or make autonomous key custody decisions.

## My data / categories

Primary actions:
- browse owned data categories
- inspect item metadata or bounded content within user scope

Contract calls:
- `DataVisibilityRetentionItem` — user-scoped data visibility and retention status
- user-scoped artifact/data listing via Core-mediated surface

Result states:
- `ready`
- `redacted`
- `denied`
- `failed`

## Consent center

Primary actions:
- inspect active, revoked, and expiring consent objects
- initiate allowed consent actions (revocation, restriction) through Core

Contract calls:
- `PatientConsentView` — consent read
- Core-mediated consent update request (where allowed by Core)

Result states:
- `active`
- `restricted`
- `expired`
- `revoked`
- `updating`
- `failed`

## Access trail

Primary actions:
- inspect governed access audit history within patient scope
- apply filters (by date range, by emergency marker, by regulatory marker)

Contract calls:
- `PatientAuditQuery` + `PatientAccessAuditView` — audit trail reads under user scope

Result states:
- `ready`
- `filtered`
- `redacted`
- `failed`

## Exports

Primary actions:
- request data export
- inspect export status

Contract calls:
- `PatientExportRequestSurface` — export request submission
- export status retrieval via Core-mediated surface

Result states:
- `pending`
- `ready`
- `denied`
- `failed`

## Patient agent

Primary actions:
- ask for explanation or summarization within own scope
- retrieve own-context information through the User-Agent Runtime

Contract calls:
- `VeridiaUserAgentInteractionEnvelope` — wraps `UserAgentRequest` and `UserAgentResponse`
- User-Agent Runtime invocation (informational-user-facing disposition only)

Result states:
- `available`
- `degraded`
- `paused`
- `failed`

Note: Patient agent responses must have disposition `informational-user-facing`. Clinical-act disposition is prohibited. Veridia does not become the User-Agent Runtime; it is the app shell for patient agent interaction.
