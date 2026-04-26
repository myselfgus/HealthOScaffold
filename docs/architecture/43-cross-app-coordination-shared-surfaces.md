# Cross-app coordination shared surfaces

## Purpose

Define a single app-safe vocabulary for Scribe, Sortio, and CloudClinic so cross-app coordination remains Core-mediated and no app acquires legal authority.

## Shared envelope

`AppSurfaceEnvelope` carries:
- request id
- app kind (`Scribe`, `Sortio`, `CloudClinic`)
- actor role
- safe subject refs
- allowed actions
- denied actions (typed reason)
- issues/degraded states
- provenance refs
- audit refs
- redaction/deidentification status
- generated timestamp
- `legalAuthorizing = false`

This envelope is informational/operational only. It never grants legal authorization.

## Safe references

Shared taxonomy:
- `SafeUserRef`
- `SafePatientRef`
- `SafeProfessionalRef`
- `SafeServiceRef`
- `SafeSessionRef`
- `SafeDraftRef`
- `SafeGateRef`
- `SafeArtifactRef`
- `SafeExportRef`
- `SafeAuditRef`
- `SafeProvenanceRef`

All references use `SafeRefCore` with:
- redaction status
- capability (`navigation_only` vs `data_access_capable`)
- explicit `grantsDataAccess` marker
- `directIdentifierPresent = false` default posture

Navigation references are never treated as data access rights.

## Role-aware allowed actions

Allowed actions are constrained by app and actor role:
- Scribe (professional workspace actions)
- Sortio (patient sovereignty actions)
- CloudClinic (service operations actions)

Any app mismatch, role mismatch, or non-`core://` command reference fails closed.

## Redaction/deidentification

`RedactionSurfaceStatus` standardizes:
- status (`none`, `pseudonymized`, `redacted`, `deidentified`, `restricted`)
- direct identifier presence flag (default false)
- reidentification required/allowed posture (allowed default false)
- reason
- lawful scope summary

## Notifications and obligations

`AppNotificationSurface` standardizes typed cross-app notifications including gate, consent, export, emergency/regulatory, signature, provider degradation, and async-failure categories.

Notification rules:
- no sensitive payload by default
- references are safe refs
- notifications do not grant access

`NotificationObligationRecord` requires explicit completion record evidence before patient-facing obligation completion can be considered satisfied.

## Boundary posture

No app-to-app direct sharing is introduced.
All cross-app surfaces remain Core-mediated and app-safe.
