# GOS and compiler backlog

## Purpose

Track the work needed after doctrinal introduction of Governed Operational Spec (GOS).

This backlog is intentionally about:
- compiler work
- validation work
- runtime binding work
- adoption discipline

It is intentionally not about scenario-specific implementations.

## Invariant Enforcement Status

- [x] Draft/finalization invariant now has explicit code-level guard (`FirstSliceInvariantEnforcer.ensureSOAPDraftCanFinalize`) and typed failures for missing gate approval / invalid draft finalization state.
- [x] Registry activation now enforces typed invalid-state guards for invalid bundle lifecycle state and registry inconsistency before promoting bundles.
- [x] AACI runtime mediation now enforces Core gate-required posture for regulatory draft actors (`aaci.draft-composer`, `aaci.referral-draft`, `aaci.prescription-draft`) even when a bundle binding omits explicit gate primitive flags.
- [x] Swift XCTest coverage now includes explicit invariant regressions for finalization-without-approved-gate and activation with competing active bundles.
- [x] Swift XCTest lifecycle coverage now includes deprecated-bundle load denial when active lifecycle is required (`bundleDeprecated` fail-closed path).
- [x] Swift XCTest lifecycle coverage now verifies known-bundle history is preserved after denied invalid lifecycle transitions (no history deletion side effect).

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
- [x] glossary entries added for GOS vocabulary if not already present

## 2. Compiler pipeline
- [x] source-canonicalization stage documented
- [x] normalization stage documented
- [x] compiler output contract documented
- [x] conservative failure doctrine documented
- [x] TypeScript compiler/CLI scaffold added
- [x] source provenance hashing/reporting added to compile output
- [x] bundle generation command added to CLI
- [~] human review/correction loop now has persisted review approval + lifecycle audit support, but still lacks richer multi-review correction flow

## 3. Validation
- [x] cross-reference validation scaffold added
- [x] schema validation workflow added inside TypeScript tooling via Ajv-based validation helpers
- [x] simple invariant validation added (for example gate-required draft outputs without matching human gate requirements)
- [x] evidence-hook completeness validation added at minimal level
- [x] bundle CLI smoke coverage now verifies manifest/spec/compiler-report/source-provenance emission for canonical lifecycle artifacts
- [x] local validation checklist documented
- [x] local workspace validation run executed (`bootstrap`, TS build/validate/bundle, Swift build, HealthOSCLI smoke, HealthOSScribeApp smoke)
- [x] local lifecycle smoke now also confirms `--gos-review-bundle` and `--gos-promote-bundle` with persisted review/audit artifacts

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
- [x] first-slice runtime adoption now also uses the resolved runtime view for capture/transcription/context-retrieval metadata, reasoning boundaries, and explicit non-draft usage provenance
- [x] first-slice provenance now explicitly distinguishes bundle activation from SOAP draft composition usage (`gos.use.compose.soap`) and derived-draft generation usage (`gos.use.derive.referral`, `gos.use.derive.prescription`), recording the concrete composing actor for each path
- [~] bundle-provided runtime binding plans are now active across current first-slice capture/transcription/context/draft paths, but broader AACI adoption beyond those runtime paths still remains open

## 5. Storage / lifecycle
- [x] canonical storage/location posture documented
- [x] lifecycle states documented
- [x] rollback posture documented
- [x] bundle-manifest schema added
- [x] minimal file-backed bundle registry/loader implementation added in Swift
- [x] minimal activation hardening added: only reviewed/active bundles may be promoted, and deprecate/revoke clear active registry pointers
- [x] bootstrap exemplar bundle, registry entry, and copy script added for `aaci.first-slice`
- [x] minimum loader hardening added for registry-pointer consistency, manifest/spec/report/source-provenance presence, compiler-report validity checks, and runtime-binding-plan shape checks
- [x] deterministic multi-bundle conflict hardening added in file-backed registry loader (typed failures for missing active pointer with active candidates, competing active bundles, missing/corrupted registry entries)
- [x] lifecycle transition hardening now enforces explicit allowed transitions (`draft -> reviewed`, `reviewed -> active`, `reviewed -> revoked`, `active -> deprecated`, `active -> revoked`) with typed invalid-transition failures
- [x] minimal lifecycle ergonomics helper added for reviewed→active promotion (`FileBackedGOSBundleRegistry.promoteReviewedBundle(...)`, surfaced in CLI as `--gos-promote-bundle`)
- [x] draft→reviewed review records and append-only lifecycle audit records now persist in the file-backed registry/CLI path
- [x] registry lifecycle persistence now remains schema-aligned in `snake_case` across manifest, registry entry, review record, and audit artifacts
- [~] registry/storage implementation is now hardened-minimum with typed lifecycle/load failures, explicit draft→reviewed→active promotion helpers/results, and lifecycle-safe active-pointer cleanup; richer policy controls, separation of duties, and version pinning are still open

## 6. App boundary discipline
- [x] app-boundary doctrine clarified: apps do not interpret GOS as sovereign law
- [x] examples of allowed Scribe/Sortio/CloudClinic consumption patterns documented
- [x] Swift boundary coverage now verifies Scribe bridge state remains runtime-mediated and does not expose raw compiled GOS payload/spec objects as app-law inputs
- [x] Scribe bridge contract now exposes a dedicated runtime-mediated GOS app surface (`GOSRuntimeStateView`) with provenance-facing/informational-only flags, mediation summaries, and no raw spec/binding payloads
- [x] Swift boundary tests now verify both active-GOS and no-active-GOS Scribe bridge paths publish only safe/inactive GOS runtime surfaces while preserving gate-required + draft-only app constraints

## 7. Validation hardening
- [x] Swift XCTest coverage now verifies file-backed lifecycle/loader behavior for:
  - bundle register + valid active load path (manifest/spec/compiler-report/source-provenance present)
  - draft→reviewed review with persisted approval/audit artifacts
  - reviewed→active promotion/activation path
  - activation denial for draft bundles
  - load denial for revoked bundles
  - active pointer cleanup on revoke of active bundle
  - known-bundle preservation when deprecating non-active bundles
  - active pointer cleanup on deprecate of active bundles
  - manifest-missing activation failure
  - load failures for missing spec/compiler-report/source-provenance artifacts
  - load failure when registry active pointer references an unknown bundle id
  - runtime-binding-plan mismatch rejection
  - registry-missing and registry-corruption load failures
  - missing active-pointer inconsistency with known active bundle candidates
  - deterministic rejection of competing active bundles for the same spec
  - explicit deprecated-bundle load denial for active-only runtime loads
  - known-bundle history preservation after denied lifecycle transition attempts
  - bundle-load success without `runtime-binding-plan.json` plus AACI default-plan activation fallback
- [x] TypeScript tests added for `@healthos/gos-tooling` compile + cross-reference failure paths
- [x] TypeScript tests now also cover bundle CLI lifecycle artifact emission
- [x] TypeScript tests now also cover CLI `validate` and `compile` success paths plus validation/bundle failure exits for evidence-hook and cross-reference defects
- [x] Swift XCTest boundary coverage now verifies active-bundle and no-bundle first-slice execution, explicit gate.request/gate.resolve/document.finalize separation, and draft-only preservation under rejected human gate even when GOS is active
- [x] Swift XCTest boundary coverage now also verifies ordered provenance separation (`gos.activate` → draft composition/derivation → `gate.request` → `gate.resolve` → `document.finalize.soap`) on approved gate paths
- [x] Swift XCTest boundary coverage now also verifies that active GOS does not bypass core habilitation/consent checks (inactive professional/patient still fail before runtime mediation)
- [x] Swift app-boundary contract now marks GOS runtime state as explicitly non-authorizing (`legalAuthorizing = false`) in both active and inactive bridge surfaces
- [x] AACI activation now maps loader/registry failures to a typed loader error contract (`GOSLoadTypedError`) with explicit `GOSLoaderFailure` category and preserved underlying registry error

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
- `schemas/governed-operational-spec-review-record.schema.json`
- `schemas/governed-operational-spec-lifecycle-audit.schema.json`
- `gos/specs/aaci.first-slice.gos.yaml`
- `ts/packages/healthos-gos-tooling/`
- `swift/Sources/HealthOSCore/GovernedOperationalSpec.swift`
- `swift/Sources/HealthOSCore/GOSFileBackedRegistry.swift`
- `swift/Sources/HealthOSAACI/GOSBindings.swift`
- `swift/Sources/HealthOSAACI/GOSRuntimeActivation.swift`
- `swift/Sources/HealthOSFirstSliceSupport/FirstSliceRunner.swift`
- `bootstrap/gos/system/gos/`

## GOS definition of done ladder

Use this ladder when updating status/tracking for GOS tasks:

- `doctrine-only`: architecture/doctrine text exists, but no executable contract or tests.
- `scaffolded contract`: typed/schema contract exists and builds, but implementation is stub/minimal and test depth is limited.
- `implemented seam`: seam is executable in runtime/tooling paths and wired to real code paths, but coverage may still be narrow.
- `tested operational path`: executable seam has automated tests that exercise success + key typed-failure paths and verify boundary invariants.
- `production-hardened`: adds stronger policy controls (for example multi-review/separation-of-duties/version pinning) plus operational runbooks beyond scaffold baseline.
