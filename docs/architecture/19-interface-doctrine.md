# Interface doctrine

## Core statement

HealthOS is not the end-user UX layer.
HealthOS is the governed platform.
Apps/interfaces are the human-facing UX layer.

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
- runtimes
- actors and agents
- operational/engineering surfaces

### Apps / interfaces
Own:
- human-facing workflows
- ergonomic presentation
- task-specific interaction design
- role-specific views

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
