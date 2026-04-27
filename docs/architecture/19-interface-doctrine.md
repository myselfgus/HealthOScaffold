# Interface doctrine

## Core statement

HealthOS is not the end-user UX layer.
HealthOS is the governed platform.
Apps/interfaces are the human-facing UX layer.

HealthOS also remains health-exclusive by ontology.
Apps do not convert it into generic workflow infrastructure.

## Canonical split

### HealthOS
Owns:
- law
- governance
- identity
- consent
- habilitation
- provenance
- gate mechanics
- storage and data model
- GOS as subordinate operational spec layer
- runtimes
- actors and agents
- operational/engineering surfaces

### Apps / interfaces
Own:
- human-facing workflows
- ergonomic presentation
- task-specific interaction design
- role-specific views

## Architectural compliance doctrine

Compliance in HealthOS is isomorphic to architecture.
In practice, this means compliance is carried by core seams and contracts, not reimplemented inside every app.

Therefore apps:
- do not own consent law
- do not define independent access policy engines
- do not own habilitation rules
- do not own gate/effectuation law
- do not interpret GOS as a sovereign source of law
- must call HealthOS contracts for governed operations

This is a platform virtue: new apps can be added without cloning regulatory logic.

## Guarantee boundary

HealthOS can enforce entry/exit seams, lawful access checks, gate rules, and provenance capture.
HealthOS cannot, by itself, guarantee all behavior of a malicious app once that app legitimately receives bytes.

Mitigations for this boundary are ecosystem governance mechanisms:
- app review and licensing
- contract-bound permission scopes
- operator-controlled distribution
- auditability and revocation of app/runtime credentials

This boundary does not weaken the central rule that app-layer compliance logic should not be duplicated.

## Examples

- Scribe = professional-facing UX
- Sortio = patient-facing UX
- CloudClinic = service-facing UX

## Allowed HealthOS-facing surfaces

- CLI
- local service APIs
- runtime controls
- operator/admin tooling
- coding agents and engineering assistants

## Design consequence

No app should be treated as the definition of the platform.
No platform law should depend on an app-specific UI assumption.
No app should become an independent interpreter of operational policy outside the contracts surfaced by HealthOS runtimes.

## Scaffold posture / non-claims

All three app interfaces (Scribe, Sortio, CloudClinic) are currently scaffold-level:
- Scribe has a minimal macOS SwiftUI validation surface for first-slice wiring only; it is not a final production UI
- Sortio and CloudClinic remain contract-first documentation surfaces with no UI shells implemented
- no app owns or reimplements consent/habilitation/gate/finality law; all governance remains in HealthOS Core
- app-facing surfaces are explicitly mediated (no raw direct identifiers, no reidentification mappings, no storage path leakage by default)
- cross-app coordination envelope (`AppSurfaceEnvelope`) exists as a scaffold contract with tested boundary validators, but no production multi-app workflow is wired
