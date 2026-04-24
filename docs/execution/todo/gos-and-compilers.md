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
- [x] canonical `aaci.first-slice` authoring spec added
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
- [x] bundle CLI smoke coverage now verifies manifest/spec/compiler-report/source-provenance emission for canonical lifecycle artifacts
- [x] local validation checklist documented
- [x] local workspace validation run executed (`bootstrap`, TS build/validate/bundle, Swift build, HealthOSCLI smoke, HealthOSScribeApp smoke)

## 4. Runtime binding
- [x] AACI-to-GOS binding doctrine documented
- [x] GOS-to-agent routing doctrine documented
- [x] draft/gate/scope discipline documented for runtime use
- [x] Swift contracts added for GOS bundle loading, registry, bundle manifest, compiled bundle, and runtime binding plan
- [x] default AACI runtime binding plan scaffold added in Swift
- [x] AACI activation/loading surface added in Swift
- [x] first-slice runner now attempts optional GOS activation and uses the resulting bundle to mediate persisted SOAP/referral/prescription drafts, events, and provenance when an active bundle exists
- [x] AACI draft composition/referral/prescription paths now apply active-bundle mediation inside orchestrator runtime execution (runner no longer mutates draft content as the primary mediation point)
- [x] AACI now exposes a small resolved runtime view for active GOS bundles and uses that view directly in SOAP/referral/prescription draft composition metadata, runtime boundary summaries, and bound-actor/family lookups
- [x] first-slice runner now derives persisted storage metadata and event attributes from the resolved runtime view instead of only from activation-summary flags
- [x] first-slice provenance now explicitly distinguishes bundle activation from per-draft-path usage (`gos.use.compose.soap`, `gos.use.compose.referral`, `gos.use.compose.prescription`) and records the concrete composing actor for each usage path
- [~] bundle-provided runtime binding plans are loadable and active in current draft paths, but broader non-draft subagent-path adoption still remains open

## 5. Storage / lifecycle
- [x] canonical storage/location posture documented
- [x] lifecycle states documented
- [x] rollback posture documented
- [x] bundle-manifest schema added
- [x] minimal file-backed bundle registry/loader implementation added in Swift
- [x] minimal activation hardening added: only reviewed/active bundles may be promoted, and deprecate/revoke clear active registry pointers
- [x] bootstrap exemplar bundle, registry entry, and copy script added for `aaci.first-slice`
- [x] minimum loader hardening added for registry-pointer consistency, manifest/spec/report/source-provenance presence, compiler-report validity checks, and runtime-binding-plan shape checks
- [x] minimal lifecycle ergonomics helper added for reviewed→active promotion (`FileBackedGOSBundleRegistry.promoteReviewedBundle(...)`, surfaced in CLI as `--gos-promote-bundle`)
- [~] registry/storage implementation is now stable-minimum, but richer policy controls/version pinning are still open

## 6. App boundary discipline
- [x] app-boundary doctrine clarified: apps do not interpret GOS as sovereign law
- [x] examples of allowed Scribe/Sortio/CloudClinic consumption patterns documented

## 7. Validation hardening
- [~] Swift XCTest coverage added in-repo for:
  - AACI resolved GOS runtime view influence in SOAP/referral/prescription draft payloads
  - first-slice provenance distinction between GOS activation and GOS draft-path usage
  - reviewed→active lifecycle promotion helper behavior in file-backed registry
  note: the current local Swift toolchain on this machine does not expose `XCTest`, so `swift test` currently validates package buildability while executable GOS closure is confirmed through CLI smoke runs
- [x] TypeScript tests added for `@healthos/gos-tooling` compile + cross-reference failure paths
- [x] TypeScript tests now also cover bundle CLI lifecycle artifact emission

## Reading rule

Any future work on GOS should begin from:
- `docs/adr/0011-governed-operational-spec-is-subordinate-to-core.md`
- `docs/architecture/29-governed-operational-spec.md`
- `docs/architecture/30-gos-authoring-and-compiler.md`
- `docs/architecture/31-gos-runtime-binding.md`
- `docs/architecture/32-gos-bundles-and-lifecycle.md`
- `docs/architecture/33-gos-app-consumption-patterns.md`
- `docs/architecture/34-gos-review-and-activation-policy.md`
- `docs/execution/08-gos-stabilization-handoff.md`
- `docs/execution/09-local-validation-checklist.md`
- `schemas/governed-operational-spec.schema.json`
- `schemas/governed-operational-spec-authoring.schema.json`
- `schemas/governed-operational-spec-bundle-manifest.schema.json`
- `gos/specs/aaci.first-slice.gos.yaml`
- `ts/packages/healthos-gos-tooling/`
- `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift`
- `swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift`
- `swift/Sources/HealthOSAACI/GOSBindings.swift`
- `swift/Sources/HealthOSAACI/GOSRuntimeActivation.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `bootstrap/gos/system/gos/`
