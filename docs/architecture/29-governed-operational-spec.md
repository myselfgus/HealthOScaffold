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

## Why "Governed" in the name

"Governed" does not mean that GOS governs health decisions or clinical acts.
It means that GOS itself is subject to governance:
- governed by HealthOS Core policy (which determines what is lawful)
- governed by bundle lifecycle policy (which determines what is active)
- governed by compilation discipline (which determines what is structurally valid)
- governed by human review before activation (which determines what is semantically approved)

GOS structures operational work within governance boundaries.
GOS does not extend, replace, or constitute governance itself.

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

## Operational versus clinical-sovereign boundary

GOS addresses the operational layer.
HealthOS Core addresses the sovereign layer.
The line between them must be explicit.

Something belongs in GOS (operational) when:
- it structures how work is extracted, derived, prepared, timed, or evidenced
- its outputs are always draft-only and gate-required before effectuation
- it does not determine lawful access, consent basis, or effectuation authority

Something belongs in Core (clinical-sovereign) when:
- it determines whether access is lawful
- it determines whether a health act may be effectuated
- it holds consent, habilitation, finality, or gate authority
- its violation renders an action legally defective, not just operationally degraded

Practical test:
If removing GOS from a runtime would make an output unlawful → that logic belongs in Core, not GOS.
If removing GOS from a runtime would make an output incomplete or unstructured but not unlawful → that logic belongs in GOS.

This boundary also determines what may be authored in GOS primitives.
A `scopeRequirementSpec` declaring a consent prerequisite does not satisfy that consent requirement.
A `humanGateRequirementSpec` declaring review is needed does not substitute for the Core gate mechanism.
GOS describes the operational shape of the work; Core enforces whether the work is lawful.

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

Bounded reasoning defined:
A derivation with `method_kind: bounded_reasoning` means:
- inputs are explicitly declared in the derivation spec (no implicit context expansion)
- outputs are limited to the declared output fields only
- the reasoning does not produce effects beyond those declared output fields
- the derivation does not infer lawful access, consent basis, or effectuation authority
- a language model used for bounded reasoning operates within the declared input/output surface
- the result remains a derived operational field, not a clinical determination or a gate substitute

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

Critical distinction:
Scope requirement specs are declarations of prerequisites, not verifications.
Declaring a scope requirement in GOS does not mean the requirement is satisfied.
Verification of consent, habilitation, finality, or lawful context is always the responsibility of HealthOS Core.
A runtime that reads a `scope_requirement_spec` with `scope_kind: consent` must not infer that consent exists.
It must still validate that consent through HealthOS Core before proceeding.
A runtime that uses scope requirement specs as a substitute for Core verification is violating Core sovereignty.

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

The GOS compiler accepts human-authored YAML as its canonical input form.
Compiled output is deterministic canonical JSON.

The compiler must:
- parse YAML authoring documents into normalized internal form
- validate structurally against the canonical GOS schema
- validate cross-references within the document
- produce a compiler report preserving source provenance
- fail conservatively when input is malformed or semantics are ambiguous

See `docs/architecture/30-gos-authoring-and-compiler.md` for the full six-stage compiler specification.

Note on natural-language sources:
Accepting unstructured natural-language text as direct compiler input is out of scope for GOS v1.
If operational language from policies or protocols needs to be encoded in GOS, it must first be
represented as structured YAML authoring form, with human or AI assistance in that translation step.
That translation step is not part of the GOS compiler itself.

## Evidence hook verification posture

Evidence hook specs declare what should be captured during execution.
They do not guarantee that capture occurred.

In the current scaffold, evidence hooks are declarative.
A compiled GOS bundle that declares evidence hooks does not automatically verify that those hooks
were executed at runtime. Runtime authors are responsible for implementing hook execution
aligned with the declared hook specs.

Future hardening should add:
- runtime verification that declared evidence hooks were actually invoked
- audit records that include per-hook execution status
- policy enforcement that flags or rejects runs where required hooks were not fired

Until that hardening exists, evidence hook conformance is an implementation discipline, not a structural guarantee.
This is a known scaffold-level limitation that should not be mistaken for production-grade provenance enforcement.

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
