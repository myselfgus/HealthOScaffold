# GOS authoring and compiler

## Purpose

This document defines how Governed Operational Spec (GOS) should be authored, normalized, compiled, and validated inside HealthOS.

It does not define scenario-specific packages.
It defines the authoring discipline and compiler posture for the GOS layer itself.

## Authoring posture

Preferred human/AI authoring form is YAML.

Rationale:
- easier for human authors to read and review
- easier for coding agents to edit safely
- supports comments and staged drafting
- still compiles cleanly into canonical JSON

Canonical machine form remains JSON.

Therefore:
- YAML is the authoring form
- JSON is the compiled canonical form

## Authoring rules

A GOS authoring document should:
- declare metadata first
- declare all primitive families explicitly
- avoid hidden implicit tasks or guards
- make degraded/failure behavior explicit where relevant
- make draft-only outputs explicit
- make human-gate requirements explicit when any output could be mistaken for effectuation
- declare scope assumptions without pretending to replace core lawful-context checks

## Spec family guidance

The `spec_family` field selects the authoring intent for the GOS document.
Valid values and their intended use:

**workflow**
A bounded sequence of operational steps with defined inputs, outputs, tasks, and artifacts.
Use for: session capture flows, review pipelines, administrative routines.
Must not contain: governance rules that determine lawful access or effectuation.
Example: `aaci.first-slice` is a workflow spec.

**policy**
Operational constraints and rules that runtimes should respect during execution.
Use for: timing constraints, documentation rules, escalation thresholds, degradation policies.
Must not contain: consent definitions, habilitation rules, or finality conditions.
Risk: a policy GOS that expands to include lawful-access rules crosses into second-constitution territory.
If in doubt, the rule belongs in HealthOS Core law, not a GOS policy spec.

**document**
Structural templates or rules for how a particular document type should be produced.
Use for: note structure constraints, referral format rules, prescription format requirements.
Must not contain: clinical decision authority or conditions that authorize effectuation.

**service_rule**
Rules scoped to a specific service or service class.
Use for: service-specific slot requirements, service-specific deadlines, service-level guards.
Must not contain: platform-wide governance that belongs in Core.

**operational_bundle**
A composite spec grouping related operational structures for a specific runtime context.
Use for: packaging a set of related workflow, policy, and document rules together.
Must not substitute for a Core policy bundle or expand to hold sovereignty rules.

## Compiler stages

### 1. parse
Read YAML into a raw authoring object.

Compiler must fail conservatively if:
- the document is not valid YAML
- required top-level sections are missing
- scalar/array/object shapes are malformed

### 2. normalize
Normalize authoring conveniences into canonical internal shapes.

Examples:
- trim scalar whitespace
- coerce omitted primitive-family arrays to empty arrays where allowed
- normalize ids and tags without changing meaning
- preserve source ordering only where semantically relevant

### 3. canonicalize
Produce deterministic compiled JSON.

Canonicalization should:
- preserve semantic meaning
- emit stable object shapes
- sort id-indexed families deterministically where appropriate
- keep primitive families explicit even when empty

### 4. validate structurally
Validate against the canonical GOS schema.

This includes:
- required field checks
- enum checks
- object shape checks
- array item shape checks

### 5. validate cross-references
Validate internal links.

Examples:
- task references must point to existing task ids
- slot inputs must point to declared slots/signals/derivations as appropriate
- human gate requirement targets must point to declared draft outputs or task outputs
- deadline targets must point to declared refs
- escalation triggers must point to declared refs

### 6. produce compiler report
The compiler should emit a report containing:
- parse status
- structural validation status
- cross-reference validation status
- warnings
- normalized metadata summary
- source provenance hints

## Conservative failure doctrine

Compiler behavior must be conservative.

It must not silently invent:
- missing gates
- missing guards
- missing scope requirements
- implied lawful access
- implied finalization/effectuation semantics

Ambiguity should yield:
- compilation failure
- or explicit warnings requiring human review

## Bounded reasoning in derivation specs

`derivationSpec` entries with `method_kind: bounded_reasoning` require particular care during authoring.

Authoring rule for bounded_reasoning:
- declare all inputs explicitly in the `inputs` array; do not rely on implied context
- declare all output fields explicitly in the `outputs` array; bounded means no side outputs
- do not use bounded_reasoning to infer lawful access, consent basis, or gate satisfaction
- do not use bounded_reasoning to produce outputs that substitute for a clinical determination
- the "bounded" constraint is on scope: the reasoning must stay within the declared surface

A bounded_reasoning derivation that expands its input scope at runtime (by accessing state not declared
in the spec) is a spec violation, not a complier error. Authors should write derivation specs tightly
to make violations detectable in review.

## Non-goals for compiler v1

Compiler v1 is not:
- an LLM-native autonomous interpreter
- a scenario pack generator
- a runtime engine
- a second legal/policy engine beside HealthOS Core

## Output bundle

A compiled GOS bundle should minimally include:
- canonical compiled JSON spec
- compiler report
- source provenance references
- compilation timestamp/version info

## Repository posture

The scaffold should provide:
- a blank YAML template
- a TypeScript compiler/validator package
- canonical schema(s)
- backlog for runtime binding and lifecycle management

## Human review rule

A compiled GOS document should be treated as reviewable operational infrastructure.
It should not be activated purely because compilation succeeded.

Compile success means:
- structurally coherent
- internally reference-safe

Compile success does not mean:
- semantically approved
- clinically appropriate
- lawfully effectable on its own
