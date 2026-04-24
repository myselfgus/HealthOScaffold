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
- [x] lightweight authoring schema added for YAML source documents
- [x] bundle-manifest schema added for compiled bundle lifecycle
- [x] primitive families declared explicitly
- [x] authoring conventions for YAML source form documented
- [x] generic blank YAML authoring template added
- [ ] glossary entries added for GOS vocabulary if not already present

## 2. Compiler pipeline
- [x] source-canonicalization stage documented
- [x] normalization stage documented
- [x] compiler output contract documented
- [x] conservative failure doctrine documented
- [x] TypeScript compiler/CLI scaffold added
- [x] source provenance hashing/reporting added to compile output
- [x] bundle generation command added to CLI
- [~] human review/correction loop still needs stronger implementation support

## 3. Validation
- [x] cross-reference validation scaffold added
- [x] schema validation workflow added inside TypeScript tooling via Ajv-based validation helpers
- [x] simple invariant validation added (for example gate-required draft outputs without matching human gate requirements)
- [x] evidence-hook completeness validation added at minimal level

## 4. Runtime binding
- [x] AACI-to-GOS binding doctrine documented
- [x] GOS-to-agent routing doctrine documented
- [x] draft/gate/scope discipline documented for runtime use
- [x] Swift contracts added for GOS bundle loading, registry, bundle manifest, compiled bundle, and runtime binding plan
- [x] default AACI runtime binding plan scaffold added in Swift
- [x] AACI activation/loading surface added in Swift
- [~] bundle-provided runtime binding plans are loadable in the core loader seam, but deep execution-time adoption inside AACI subagent paths still remains open

## 5. Storage / lifecycle
- [x] canonical storage/location posture documented
- [x] lifecycle states documented
- [x] rollback posture documented
- [x] bundle-manifest schema added
- [x] minimal file-backed bundle registry/loader implementation added in Swift
- [~] activation/deprecation mechanics still need stronger implementation
- [~] registry/storage implementation is now minimal-functional, but not yet hardened

## 6. App boundary discipline
- [x] app-boundary doctrine clarified: apps do not interpret GOS as sovereign law
- [x] examples of allowed Scribe/Sortio/CloudClinic consumption patterns documented

## Reading rule

Any future work on GOS should begin from:
- `docs/adr/0011-governed-operational-spec-is-subordinate-to-core.md`
- `docs/architecture/29-governed-operational-spec.md`
- `docs/architecture/30-gos-authoring-and-compiler.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/architecture/32-gos-bundles-and-lifecycle.md`
- `docs/architecture/33-gos-app-consumption-patterns.md`
- `schemas/governed-operational-spec.schema.json`
- `schemas/governed-operational-spec-authoring.schema.json`
- `schemas/governed-operational-spec-bundle-manifest.schema.json`
- `gos/templates/blank.gos.yaml`
- `ts/packages/healthos-gos-tooling/`
- `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift`
- `swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift`
- `swift/Sources/HealthOSAACI/GOSBindings.swift`
- `swift/Sources/HealthOSAACI/GOSRuntimeActivation.swift`
