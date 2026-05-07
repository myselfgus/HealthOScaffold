# Skill: app boundary discipline

## Purpose
Keep reference apps such as Scribe, Veridia, CloudClinic, and future apps from drifting into core-law ownership.

## Scope
- screen and flow design
- app state vocabulary
- boundary-aware contract consumption
- role separation across professional, patient, and service contexts
- App Integration Boundary and App Charter readiness before app implementation

## Never do
- implement consent logic uniquely in one app
- implement gate semantics only in UI copy
- duplicate identity or access law in front-end state as source of truth
- blur patient-facing and service-facing responsibilities
- advance app wiring around a mediated surface that is only contracted, absent, or unstable

## Required outputs when editing app-facing domains
- explicit consumed contracts
- role/scope statement
- state model aligned with glossary and architecture docs
- note stating what remains outside app responsibility
- tier classification and App Charter status from `docs/architecture/50-app-layer-boundary-and-reference-apps.md`
