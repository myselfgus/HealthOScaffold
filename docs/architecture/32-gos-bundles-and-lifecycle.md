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

## Storage posture

Recommended canonical storage posture for compiled GOS bundles:

```text
/system/gos/
  registry/
  bundles/
    <bundle-id>/
      manifest.json
      spec.json
      compiler-report.json
      source-provenance.json
```

This is a storage recommendation for future implementation.
It does not require immediate runtime adoption.

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

## Non-goals

This doc does not yet implement:
- runtime bundle loader
- registry service
- approval workflow UI
- distributed replication logic

It only sets the architectural posture so future implementation does not invent lifecycle rules ad hoc.
