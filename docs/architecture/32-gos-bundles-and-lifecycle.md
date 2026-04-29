# GOS bundles and lifecycle

## Purpose

Define how compiled Governed Operational Spec (GOS) artifacts should exist as versioned operational infrastructure inside HealthOS.

## Why this exists

A compiled GOS document should not be treated as loose JSON.
It should be treated as a governed operational bundle with:
- identity
- version
- compiler provenance
- activation state
- rollback semantics

## Canonical posture

A GOS bundle contains at least:
- compiled canonical JSON spec
- bundle manifest
- compiler report
- source provenance references

The current scaffold also persists:
- runtime binding plan when bundle-local bindings are present
- review approval record when a draft bundle is reviewed
- append-only lifecycle audit records for registry actions

## Bundle identity

Each bundle should have:
- `bundle_id`
- `spec_id`
- `spec_version`
- `bundle_version`
- `compiler_version`

This separation matters because the same logical spec may be recompiled under a newer compiler or normalization rule without changing the semantic intent of the original authoring document.

## Lifecycle states

Recommended lifecycle states:
- `draft`
- `reviewed`
- `active`
- `deprecated`
- `superseded`
- `revoked`

Meaning:
- `draft`: compiled but not reviewed for activation
- `reviewed`: structurally and semantically reviewed for possible activation
- `active`: permitted for runtime loading under local policy
- `deprecated`: still recognized but not preferred for new activation
- `superseded`: replaced by a newer active bundle for the same scope
- `revoked`: must not be loaded due to defect or governance withdrawal

## Activation rule

Compile success is not activation.
Review is not activation.
Only explicit activation policy should make a bundle active.
In the current scaffold, a reviewed bundle must also carry a recorded review approval before promotion to `active`.

## Storage posture

Recommended canonical storage posture for compiled GOS bundles:

```text
/system/gos/
  audit.jsonl
  registry/
  bundles/
    <bundle-id>/
      manifest.json
      spec.json
      compiler-report.json
      source-provenance.json
      runtime-binding-plan.json
      review-approval.json
```

This is no longer only a recommendation.
The current file-backed scaffold now persists bundle lifecycle state in this shape, with `review-approval.json` present when review occurs and `audit.jsonl` recording lifecycle transitions.

## Runtime loading rule

Runtimes should load only bundles that are:
- structurally valid
- not revoked
- allowed by local activation policy

Runtimes should not load:
- orphan spec.json files without manifest/context
- bundles in revoked state
- ambiguous competing bundles without explicit resolution policy

## Rollback rule

Rollback should operate at bundle level.
That means runtimes and operators should be able to move from one active bundle to another reviewed or previously active bundle without mutating the old bundle in place.

Preferred rule:
- append new bundle
- change activation status
- preserve old bundle for provenance

The current file-backed registry follows this posture by updating active pointers and appending lifecycle audit records instead of mutating old audit history away.

## Future multi-bundle posture

The current scaffold maintains one active bundle pointer per `spec_id`.

When multiple bundles become a requirement (for example: different active bundles per runtime,
per service class, or per jurisdiction), the intended posture is:

- bundle selection must remain explicit, never resolved by heuristic
- multiple active pointers per `spec_id` require explicit disambiguation keys
  (such as `runtime_id`, `service_class`, or `jurisdiction`) agreed on before implementation
- conflict between active bundles for the same scope must be resolved by explicit operator policy,
  not by runtime-level fallback logic
- promotion and revocation of individual bundles in a multi-bundle set must preserve
  append-only audit history for the full set, not only the affected bundle

This is not yet implemented.
Future work should extend the registry and loader contracts rather than inventing new conflict
semantics ad hoc. The disambiguation key model and conflict resolution policy must be documented
before any implementation begins.

## Non-goals

This doc does not yet implement:
- approval workflow UI
- distributed replication logic
- multi-review / multi-approver policy
- version-pinning and rollout policy beyond one active pointer per spec

It sets the posture and the minimum file-backed implementation shape so future hardening does not invent lifecycle rules ad hoc.
