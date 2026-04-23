# GOS and compiler backlog

## Purpose

Track the work needed after doctrinal introduction of Governed Operational Spec (GOS).

This backlog is intentionally about:
- compiler work
- validation work
- runtime binding work
- adoption discipline

It is intentionally not about scenario-specific implementations.

## 1. Foundational closure
- [x] GOS named and placed in architecture
- [x] GOS explicitly declared subordinate to HealthOS Core
- [x] canonical schema added for compiled JSON form
- [x] primitive families declared explicitly
- [ ] authoring conventions for YAML source form documented
- [ ] glossary entries added for GOS vocabulary if not already present

## 2. Compiler pipeline
- [ ] define source-canonicalization stage
- [ ] define normalization stage from human-authored text to reviewed structured draft
- [ ] define compiler output contract from declarative authoring form to canonical JSON
- [ ] preserve source provenance in compiler output
- [ ] define conservative failure rules for ambiguous source text
- [ ] define human review/correction loop before activation

## 3. Validation
- [ ] add schema validation workflow for canonical GOS JSON
- [ ] add cross-reference validation (task refs, slot refs, gate refs, deadline refs)
- [ ] add non-goal/invariant validation (no effectuation semantics without explicit human gate requirement)
- [ ] add validation for evidence hook completeness where required

## 4. Runtime binding
- [ ] define how AACI subagents bind to GOS primitive families
- [ ] define GOS-to-agent routing contract
- [ ] define how GOS drives extraction without hardcoding prompt logic
- [ ] define how GOS drives draft preparation without confusing draft and final artifact
- [ ] define how GOS binds deadlines/escalations into runtime state surfaces
- [ ] define how GOS scope requirements map to lawful-context prechecks

## 5. Storage / lifecycle
- [ ] define canonical storage location/versioning strategy for compiled GOS packages
- [ ] define activation/deprecation lifecycle for GOS packages
- [ ] define rollback strategy when a compiled GOS package is invalid or superseded

## 6. App boundary discipline
- [ ] define which GOS-derived states are allowed to surface to apps
- [ ] confirm that apps never become sovereign interpreters of GOS
- [ ] add examples of allowed Scribe/Sortio/CloudClinic consumption patterns

## 7. Future strategic extensions (not immediate implementation)
- [ ] break-glass / emergency-access compatible GOS bindings
- [ ] legal-retention / visibility constraints where operational specs intersect with governance law
- [ ] regulatory audit pathway bindings
- [ ] interoperability-oriented export bindings (future only)

## Reading rule

Any future work on GOS should begin from:
- `docs/adr/0011-governed-operational-spec-is-subordinate-to-core.md`
- `docs/architecture/29-governed-operational-spec.md`
- `schemas/governed-operational-spec.schema.json`
