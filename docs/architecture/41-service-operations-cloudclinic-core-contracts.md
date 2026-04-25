# Service Operations / CloudClinic Core Contracts

## Purpose

Define app-safe, Core-mediated contracts for service operations consumed by CloudClinic without moving sovereign law into app/UI.

## Constitutional boundary

- HealthOS Core decides consent, habilitation, finalidade, gate transitions, and finalization.
- CloudClinic consumes mediated summaries/surfaces only.
- Queue/worklist visibility is never authorization by itself.
- Administrative operation role never becomes professional authority.

## Contract set (Swift + TS + JSON Schema)

Implemented in:
- `swift/Sources/HealthOSCore/ServiceOperationsContracts.swift`
- `ts/packages/contracts/src/index.ts`
- `schemas/contracts/service-operations-cloudclinic.schema.json`

### 1) ServiceOperationalContext

Core-mediated operation context with:
- service/actor/member/professional/patient references
- lawfulContext + finalidade + scope
- allowed/denied operations
- provenance/audit references

Fail-closed rules:
- missing lawfulContext fails
- missing finalidade for sensitive operations fails
- CloudClinic path must declare Core mediation
- admin/coordinator roles cannot expose professional actions in allowed operations

### 2) ServiceMembership

Membership and role governance with role/status/professional linkage fields.

Fail-closed rules:
- inactive/suspended/revoked members fail
- professional role requires professional record + habilitation linkage
- non-professional roles cannot carry habilitation linkage

### 3) ProfessionalHabilitationSurface

App-safe informational surface for professional habilitation state.

Fail-closed rules:
- must be informational/app-safe
- must remain Core-decided
- non-active or expired habilitation fails

### 4) PatientServiceRelationshipSurface

App-safe patient-service relation surface with consent summary, visibility status, retention/custody markers, restrictions, and pseudonymous patient reference.

Fail-closed rules:
- relationship never replaces consent/finalidade
- direct-identifier exposure denied
- retention/custody marker never grants unrestricted access

### 5) ServiceQueueItem

Operational queue/worklist item with lawful scope summary and Core action reference.

Fail-closed rules:
- queue item never grants access by itself
- lawful scope summary + Core action ref required
- sensitive item summary cannot expose raw payload

### 6) ServiceDocumentSurface

Service document/draft summary with draft/final distinction, gate status, finalization status, provenance refs, and access-scope summary.

Fail-closed rules:
- draft cannot be final
- final requires approved gate
- pending gate is not approval
- raw content exposure denied by default
- transition/finalization remains Core-only

### 7) GateWorklistItem

Gate pending worklist summary contract.

Fail-closed rule:
- admin/coordinator cannot resolve professional clinical gate when pending

### 8) ServiceAdministrativeTask

Administrative tasks are allowlisted:
- request missing document
- notify pending gate
- prepare export package request
- schedule operational follow-up
- assign administrative owner
- reconcile incomplete metadata
- review audit response status

Fail-closed rules:
- prohibited clinical/regulatory tasks are denied
- sensitive tasks cannot bypass consent/habilitation/finalidade
- sensitive tasks must emit audit + provenance refs

## Coverage posture

- [x] Contract surfaces implemented for service context/membership/habilitation/relationship/queue/doc/gate/task
- [x] Negative tests implemented in Swift for required fail-closed paths
- [~] No persisted CloudClinic runtime adapter yet (contract-first only)
- [~] No dedicated SQL tables for queue/task/document summaries yet (current posture: contract + validator)
- [ ] Final CloudClinic UI
- [ ] Full EHR/clinical workflow expansion
