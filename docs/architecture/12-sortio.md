# Sortio

## Purpose
Patient/user-facing sovereignty interface.

## What Sortio is
- the user-facing sovereignty UX
- the place where owned data visibility, consent visibility, audit visibility, and export flows are presented
- the user-facing shell for the user-agent runtime

## What Sortio is not
- not a professional workspace
- not a service-operations dashboard
- not the owner of governance law; it displays and invokes it

## Primary flows
- dashboard of owned data and recent activity
- consent management
- access audit trail
- export requests
- user-agent interaction shell

## Primary screens
- dashboard
- my data / categories
- consent center
- access trail
- exports
- user-agent panel

## Key UI states
- consent loading / active / restricted / expired / revoked
- audit loading / ready / filtered / export_pending
- runtime health healthy / degraded / failed
- user-agent available / paused / degraded

## Important user flows
1. inspect what data categories exist
2. inspect who/what accessed data in bounded form
3. grant/restrict/revoke consent
4. request export
5. ask user-agent for explanation or retrieval within own scope

## Related detailed contract
See:
- `docs/architecture/24-sortio-screen-contracts.md`

## Boundaries
- Sortio may never behave as if it is the professional authority
- Sortio may expose audit and access visibility, but it does not redefine access law
- Sortio may show redaction and denial states when the platform must protect sensitive linkage or governed data paths

## Boundary
Sortio is user-facing. It does not behave as a professional workspace.
