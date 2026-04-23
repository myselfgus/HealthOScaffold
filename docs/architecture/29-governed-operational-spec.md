# Governed Operational Spec (GOS)

## Canonical statement

Governed Operational Spec (GOS) is the HealthOS-native intermediate representation for translating human-authored operational language into executable runtime structure.

Human-authored operational language may include:
- protocols
- policies
- guidelines
- service rules
- documentation rules
- administrative instructions
- bounded clinical-operational routines

GOS is not the sovereign layer.
HealthOS Core remains the sovereign layer.
GOS is a subordinate operational spec layer.

## Why GOS exists

Without a native intermediate representation, operational guidance tends to leak into:
- ad hoc prompts
- app-specific workflow assumptions
- runtime-specific hardcoding
- hidden tool wiring
- fragile per-agent prompt conventions

GOS exists to make those operational structures:
- explicit
- typed
- versionable
- auditable
- runtime-consumable
- still subordinate to HealthOS law

## Placement in the system

Canonical hierarchy:

```text
Material substrate
  └─ Apple Silicon hosts, macOS, disk, networking, backups
HealthOS Core
  └─ identity, consent, habilitation, finality, provenance, gate, storage, schemas
Governed Operational Spec (GOS)
  └─ operational translation layer from human-authored rules to executable runtime structure
HealthOS Runtimes
  ├─ AACI Runtime
  ├─ Async Runtime
  └─ User-Agent Runtime
Actors / Agents
  ├─ professional/user agents
  └─ AACI subagents
Apps / Interfaces
  ├─ Scribe
  ├─ Sortio
  └─ CloudClinic
Artifacts / Effects
  ├─ transcripts
  ├─ drafts
  ├─ gate requests/resolutions
  ├─ audit/provenance records
  └─ derived AI outputs
```

## Constitutional boundary

HealthOS Core determines:
- who may access
- under which lawful context
- under which consent/habilitation/finality basis
- what requires gate
- what may become effective
- what provenance and storage guarantees apply

GOS determines:
- what operational signals matter
- what data should be extracted or derived
- what tasks may be prepared or executed by runtimes
- what guards and deadlines should exist
- what evidence hooks should fire
- what drafts may be produced
- what human gate requirements must be surfaced to runtimes

GOS cannot:
- bypass consent
- bypass habilitation
- bypass finality
- bypass gate
- define law independently of core contracts
- effectively authorize a health act by itself

## Preferred authoring and compiled form

Preferred authoring form:
- declarative text for human/AI collaboration, typically YAML

Canonical compiled form:
- JSON for validation, transport, versioning, and runtime binding

This means GOS should be thought of as:
- authored declaratively
- compiled deterministically
- validated structurally
- consumed by runtimes

## GOS primitive families

GOS should be seen as a primitive layer with its own explicit spec families.

### 1. signal specs
Describe raw sources or observable input channels that may feed runtime work.
Examples of concern:
- transcript stream
- local audio reference
- device measurement stream
- patient record reference
- service event stream

Purpose:
- define where operational input may originate
- define broad source semantics
- remain app-agnostic

### 2. slot specs
Describe fields/claims/observations that a runtime should try to populate.

Purpose:
- normalize extracted operational meaning
- define required vs optional bounded fields
- support later derivation and task routing

### 3. derivation specs
Describe fields or assertions computed from already-available inputs/slots.

Purpose:
- turn raw extracted state into bounded derived meaning
- keep derivation logic explicit rather than hidden in prompts

### 4. task specs
Describe bounded executable runtime tasks.

Purpose:
- define operational work units
- bind required inputs and produced outputs
- express runtime-appropriate action without declaring sovereign law

### 5. tool binding specs
Describe which bounded tool classes/tasks may be used to fulfill task specs.

Purpose:
- keep runtime orchestration explicit
- avoid hiding tool usage inside unstructured prompt text

### 6. draft output specs
Describe what drafts a runtime may prepare.

Purpose:
- keep draft production explicit
- define output structure expectations
- make clear that draft does not imply effectuation

### 7. guard specs
Describe predictive or bounded safety/quality/consistency checks.

Purpose:
- express operational barriers, alerts, or escalation triggers
- surface checks before downstream execution or human review

### 8. deadline specs
Describe bounded operational time windows.

Purpose:
- formalize timing expectations
- support runtime timers and escalation semantics

### 9. evidence hook specs
Describe what evidence/provenance/audit hooks should attach to execution.

Purpose:
- make trace obligations explicit
- support provenance-ready execution

### 10. human gate requirement specs
Describe where runtime output must remain gated.

Purpose:
- tell runtimes which prepared results are draft-only until explicit human resolution
- preserve the constitutional rule that effectuation does not emerge from prompt logic

### 11. escalation specs
Describe what should happen when runtime work degrades, fails, or crosses risk/urgency thresholds.

Purpose:
- make escalation explicit and typed
- prevent hidden app-specific fallback behavior

### 12. scope requirement specs
Describe bounded scope assumptions that must hold before operational work proceeds.

Purpose:
- declare expected scope requirements without replacing the core lawful-context checks
- help runtimes fail honestly before attempting work that would later be unlawful

## Relationship to AACI

AACI is the primary early consumer of GOS.

GOS can guide AACI subagents such as:
- CaptureAgent
- TranscriptionAgent
- ContextRetrievalAgent
- DraftComposerAgent
- TaskExtractionAgent
- ReferralDraftAgent
- PrescriptionDraftAgent
- NoteOrganizerAgent

This relationship should work like this:
- GOS structures the work
- AACI executes the work
- HealthOS Core governs whether that work is lawful and effectable

## Relationship to apps

Apps do not become the source of truth for GOS execution or law.
Apps may display:
- extraction state
- draft state
- retrieval summary
- deadline state
- degraded state
- gate-needed state
- evidence/provenance-facing summaries

But apps do not become independent interpreters of operational policy.

## Non-goals for GOS v1

GOS v1 should not try to be:
- a full programming language
- a second constitution beside HealthOS Core
- a vendor/runtime topology spec
- a learning/reward framework
- an agent memory framework
- a scenario-specific protocol package
- an app workflow DSL

## Compiler posture

A future GOS compiler should:
- accept natural-language operational sources
- produce normalized structured output
- preserve source provenance
- support human review and correction
- compile to canonical JSON
- fail conservatively when semantics are ambiguous

## Runtime posture

Runtimes consuming GOS should:
- remain bounded by lawful context
- surface degraded states honestly
- keep drafts distinct from final artifacts
- bind evidence hooks explicitly
- never confuse operational readiness with lawful effectuation

## Initial adoption posture

GOS enters the scaffold first as:
- doctrine
- architecture
- schema
- backlog for compiler/runtime binding

It does not enter first as:
- scenario implementation
- app-specific behavior
- runtime hardcoding explosion

## Practical consequence

HealthOS now has a native place for the idea of translating human operational language into executable runtime structure.
That translation becomes an explicit architectural layer rather than an implicit prompt habit.
