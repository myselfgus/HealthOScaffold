# ADR 0010: Health-exclusive ontology and architecturalized compliance

Status: Accepted

## Decision

HealthOS is health-exclusive by ontology and should not be modeled as generic cloud infrastructure with optional health plugins.

Compliance is architecturalized in core seams/contracts.
Apps/interfaces consume these seams and must not reimplement consent, habilitation, gate, provenance, or governance policy engines.

## Why

- preserves coherent domain law in one governed core
- reduces duplicated regulatory logic across apps
- enables app ecosystem growth with consistent compliance posture
- keeps health-native primitives explicit (professional record/habilitation, purpose-bound consent, gate, provenance)

## Boundary

This decision governs platform seams and controlled flows.
It does not claim HealthOS can prevent every malicious use of legitimately received bytes in an app process.

That residual risk is mitigated via:
- app review/licensing/governance
- constrained permissions and distribution
- auditability and revocable credentials

## Consequences

- architecture docs and app doctrine should describe compliance as platform-native
- apps should focus on UX/workflow, not law engines
- future app onboarding should include seam conformance checks
