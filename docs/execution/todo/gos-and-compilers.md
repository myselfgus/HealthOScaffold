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
- [~] source provenance preservation needs stronger implementation
- [~] human review/correction loop still needs stronger implementation support

## 3. Validation
- [x] cross-reference validation scaffold added
- [ ] schema validation workflow for canonical GOS JSON still needs implementation
- [ ] invariant validation still needs implementation
- [ ] evidence-hook completeness validation still needs implementation

## 4. Runtime binding
- [x] AACI-to-GOS binding doctrine documented
- [x] GOS-to-agent routing doctrine documented
- [x] draft/gate/scope discipline documented for runtime use
- [ ] executable runtime loader/binding contracts still need implementation

## 5. Storage / lifecycle
- [x] canonical storage/location posture documented
- [x] lifecycle states documented
- [x] rollback posture documented
- [x] bundle-manifest schema added
- [ ] activation/deprecation mechanics still need implementation
- [ ] bundle registry/storage implementation still needs implementation

## 6. App boundary discipline
- [x] app-boundary doctrine clarified: apps do not interpret GOS as sovereign law
- [ ] examples of allowed Scribe/Sortio/CloudClinic consumption patterns

## Reading rule

Any future work on GOS should begin from:
- `docs/adr/0011-governed-operational-spec-is-subordinate-to-core.md`
- `docs/architecture/29-governed-operational-spec.md`
- `docs/architecture/30-gos-authoring-and-compiler.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/architecture/32-gos-bundles-and-lifecycle.md`
- `schemas/governed-operational-spec.schema.json`
- `schemas/governed-operational-spec-authoring.schema.json`
- `schemas/governed-operational-spec-bundle-manifest.schema.json`
- `gos/templates/blank.gos.yaml`
- `ts/packages/healthos-gos-tooling/`
