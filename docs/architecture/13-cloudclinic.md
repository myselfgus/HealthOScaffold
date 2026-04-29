# CloudClinic

## Purpose
Service-facing operational interface for patient management and service work visibility.

## What CloudClinic is
- the service operations UX
- the place where queues, pending work, service-scoped patient operations, and document/gate visibility become operationally manageable
- the service-layer cockpit, not the clinical session cockpit

## What CloudClinic is not
- not the patient sovereignty app
- not the live professional session workspace
- not the owner of service law or access law

## Primary flows
- service dashboard
- patient registry
- queue and pending work
- draft and gate visibility
- operational documents
- service-level coordination

## Primary screens
- dashboard
- patient registry
- queue board
- pending drafts
- pending gates
- service documents / operational records
- staff activity / coordination view

## Key UI states
- queue empty / ready / saturated / deferred / failed
- gate queue pending / reviewing / resolved
- draft visibility ready / awaiting_gate / approved / rejected
- runtime health healthy / degraded / failed

## Important service flows
1. inspect current operational load
2. locate patient within service context
3. view pending documents and drafts
4. route pending work to professionals/operators
5. inspect service-level gate backlog
6. inspect high-level operational history

## Related detailed contract
See:
- `docs/architecture/25-cloudclinic-screen-contracts.md`
- `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`

## Boundaries
- CloudClinic may show service-scoped work and visibility
- CloudClinic may not impersonate patient sovereignty functions from Sortio
- CloudClinic may not replace Scribe as the live professional workspace
- CloudClinic may not redefine service access law in its own UI state

## Boundary
CloudClinic is service-facing. It must not absorb patient sovereignty functions from Sortio or professional session functions from Scribe.

## Scaffold posture / non-claims

CloudClinic is a scaffold contract and documentation-only surface:
- no final CloudClinic UI shell has been implemented
- native macOS app-shell scope is defined for future work, but no executable CloudClinic target exists
- no persisted queue/task projection service is wired
- service operations contracts exist in Swift Core + TypeScript + JSON Schema with fail-closed validators, but no runtime adapter is implemented
- CloudClinic does not own service access law or membership policy; it consumes mediated surfaces from HealthOS Core
- operational queue visibility is contract-first only (no production workflow engine)
