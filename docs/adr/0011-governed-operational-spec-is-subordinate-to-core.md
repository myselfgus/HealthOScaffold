# ADR 0011: Governed Operational Spec is a subordinate spec layer inside HealthOS

## Status
Accepted

## Context

HealthOS already models the sovereign layer of the system through core law:
- identity
- consent
- habilitation
- finality
- provenance
- gate mechanics
- storage/access contracts

AACI and other runtimes need a disciplined way to transform human-authored operational language into machine-usable execution structure.
That language may come from:
- policies
- protocols
- guidelines
- operational rules
- service procedures
- documentation rules
- administrative instructions

The repository already contains enough constitutional structure to support this translation, but it did not yet name or formalize the intermediate representation layer that should sit between human-authored operational language and runtime execution.

## Decision

HealthOS introduces a new architectural layer called **Governed Operational Spec (GOS)**.

GOS is:
- a declarative intermediate specification layer
- authored for human/AI collaboration
- compiled into canonical machine-readable form
- consumed by HealthOS runtimes such as AACI
- always subordinate to HealthOS Core law

GOS is not:
- the constitutional layer of the system
- an alternative policy engine to the core
- an app-owned workflow framework
- a replacement for gate, consent, habilitation, or finality
- a clinically autonomous decision engine

## Placement in architecture

Canonical hierarchy becomes:

Material substrate
↓
HealthOS Core
↓
Governed Operational Spec (GOS)
↓
HealthOS Runtimes
↓
Agents / Actors
↓
Apps / Interfaces
↓
Artifacts / Effects

This means GOS can describe what should be extracted, derived, checked, drafted, timed, escalated, and evidenced, but it cannot override the core laws that determine whether access or effectuation is lawful.

## GOS primitive families

GOS is built from explicit primitive spec families:
- signal specs
- slot specs
- derivation specs
- task specs
- tool binding specs
- draft output specs
- guard specs
- deadline specs
- evidence hook specs
- human gate requirement specs
- escalation specs
- scope requirement specs

These primitives are constitutional for GOS itself, but not for HealthOS as a whole.
The constitutional layer remains the core.

## Runtime rule

Runtimes may consume GOS to:
- normalize natural-language operational guidance into executable structures
- guide extraction and structuring work
- bind subagents to bounded responsibilities
- prepare drafts and administrative actions
- surface deadlines, checks, and escalations
- attach evidence/provenance hooks

Runtimes may not use GOS to bypass:
- consent checks
- habilitation checks
- scope/finality checks
- gate requirements
- lawful storage boundaries

## App rule

Apps do not interpret GOS as a source of law.
Apps may consume states, outputs, previews, and summaries produced by runtimes that executed under GOS, but they do not become independent interpreters of regulatory or governance logic.

## Authoring form

Preferred authoring form is human/AI-friendly declarative text (for example YAML), compiled into canonical JSON for machine transport, validation, versioning, and execution binding.

## Consequences

Positive:
- gives HealthOS a native place for policy/protocol/workflow compilation
- keeps natural-language operational guidance out of ad hoc prompt logic
- improves reuse across AACI subagents and future runtimes
- makes evidence, deadlines, and guards explicit instead of implicit
- allows compiler/runtime evolution without moving law into apps

Negative / constraints:
- requires a compiler/validator layer
- requires careful vocabulary discipline so GOS does not grow into a second constitution
- requires explicit bindings from runtime agents to GOS primitives

## Non-goals

This ADR does not introduce:
- scenario-specific protocol implementations
- multi-node execution changes
- offline execution modes
- autonomous clinical effectuation
- vendor-specific runtime commitments

## Follow-up

The scaffold should add:
- architecture docs for GOS
- canonical schema for GOS
- execution/backlog references for compiler + runtime binding work

## Follow-up status

All items above are closed as of the GOS stabilization wave.
See `docs/execution/08-gos-stabilization-handoff.md` for the full closure record.

Closed items:
- architecture docs added: `docs/architecture/29` through `docs/architecture/34`
- canonical schema added: `schemas/governed-operational-spec.schema.json` and variants
- authoring schema and bundle-manifest schema added
- execution backlog added: `docs/execution/todo/gos-and-compilers.md`
- TypeScript compiler scaffolded: `ts/packages/healthos-gos-tooling/`
- Swift contracts scaffolded: `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift` and related
- file-backed registry and loader implemented: `GOSFileBackedRegistry`
- AACI activation seam implemented: `AACIOrchestrator.activateGOS`
- first-slice runtime path integrated with GOS activation and mediation
- bootstrap exemplar bundle shipped for `aaci.first-slice`

The ADR status remains Accepted.
The GOS ontology established here should not be changed without a new or superseding ADR.
