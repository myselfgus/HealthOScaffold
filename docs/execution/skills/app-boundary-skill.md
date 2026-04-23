# Skill: app boundary discipline

## Purpose
Keep Scribe, Sortio, and CloudClinic from drifting into core-law ownership.

## Scope
- screen and flow design
- app state vocabulary
- boundary-aware contract consumption
- role separation across professional, patient, and service contexts

## Never do
- implement consent logic uniquely in one app
- implement gate semantics only in UI copy
- duplicate identity or access law in front-end state as source of truth
- blur patient-facing and service-facing responsibilities

## Required outputs when editing app-facing domains
- explicit consumed contracts
- role/scope statement
- state model aligned with glossary and architecture docs
- note stating what remains outside app responsibility
