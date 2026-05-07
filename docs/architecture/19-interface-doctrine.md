# Interface doctrine

## Core statement

HealthOS is not the end-user UX layer.
HealthOS is the governed platform.
Apps/interfaces are the human-facing UX layer.

The HealthOScaffold repository is where HealthOS is being built. App/interface docs in this repository describe HealthOS components at varying maturity levels; "scaffold" does not mean the apps are outside HealthOS.

HealthOS also remains health-exclusive by ontology.
Apps do not convert it into generic workflow infrastructure.

Apps are multiplicable consumers of mediated HealthOS surfaces. Scribe, Veridia, CloudClinic, and future apps are reference-app consumers, not a closed set and not the ontology of HealthOS. HealthOS can exist without any specific app.

App wiring advances only after the mediated surface the app consumes is implemented and stable, not merely contracted. Contract-only surfaces may be documented and tested as boundary evidence, but they do not justify non-provisional app implementation by themselves.

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
- must have an App Charter before substantial new wiring

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
- Veridia = patient health identity app
- CloudClinic = service-facing UX
- future apps = additional consumers of the same mediated HealthOS boundary, not new Core law

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

Native macOS UI work follows the same boundary. The shared design system and app shells are presentation contracts over mediated state, not sources of HealthOS law. See `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md` for the scaffold scope covering Scribe, Veridia, CloudClinic, and a future HealthOS control panel for macOS.

## Scaffold-stage HealthOS posture / non-claims

The initial reference app interfaces are HealthOS interfaces currently at scaffold-stage maturity:
- Scribe has a minimal macOS SwiftUI validation surface for first-slice wiring only; it is not a final production UI
- Veridia and CloudClinic remain contract-first documentation surfaces with no UI shells implemented
- native macOS app-shell and design-system scope is now defined as scaffold guidance, not implemented final UX
- no app owns or reimplements consent/habilitation/gate/finality law; all governance remains in HealthOS Core
- app-facing surfaces are explicitly mediated (no raw direct identifiers, no reidentification mappings, no storage path leakage by default)
- cross-app coordination envelope (`AppSurfaceEnvelope`) exists as a scaffold contract with tested boundary validators, but no production multi-app workflow is wired

See `docs/architecture/50-app-layer-boundary-and-reference-apps.md` for the tiered ordering rule and App Charter template.
