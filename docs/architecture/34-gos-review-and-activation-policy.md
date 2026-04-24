# GOS review and activation policy

## Purpose

Define the minimum policy that governs when a compiled GOS bundle may become active in HealthOS.

## Core rule

Compile success is not activation.
A bundle becomes loadable by default AACI runtime paths only when it is explicitly active.

## Minimum lifecycle discipline

Recommended states remain:
- draft
- reviewed
- active
- deprecated
- superseded
- revoked

In the current scaffold, the hard minimum policy is:
- bundles should move from `draft` to `reviewed` before explicit activation
- reviewed-state promotion should persist an explicit approval record
- reviewed-state promotion should append a lifecycle audit record with actor identity and rationale
- runtime loaders should only accept `active` bundles for normal execution paths
- revocation must make a bundle unloadable
- deprecation/revocation should clear active-registry pointers when the affected bundle was the current active bundle

## Current scaffold enforcement

Current code-level enforcement now includes:
- loader default request path expects `active` lifecycle state
- `FileBackedGOSBundleRegistry.review(...)` persists `review-approval.json`, keeps bundle identity stable, and records a `reviewed` lifecycle audit entry
- `FileBackedGOSBundleRegistry.activate(...)` only promotes bundles already marked `reviewed` or `active`
- reviewed bundles require a persisted approval record before activation succeeds
- `FileBackedGOSBundleRegistry.promoteReviewedBundle(...)` and `swift run HealthOSCLI --gos-promote-bundle ...` provide the minimal operator-facing promotion path
- `swift run HealthOSCLI --gos-review-bundle ...` provides the minimal operator-facing draft review path
- `deprecate(...)` and `revoke(...)` clear active registry pointers when the targeted bundle was active
- lifecycle artifacts persisted by the file-backed registry remain schema-aligned in `snake_case` across manifest, registry entry, review record, and audit records

## Bootstrap exception

The repository currently ships one bootstrap exemplar bundle for `aaci.first-slice` already marked active.

This is intentional.
It exists to let the runtime exercise a real GOS-mediated path without waiting for a full review UI or promotion workflow.

This exception is acceptable for scaffold bootstrap, but should not be treated as the final production promotion model.

## Still missing for a stronger production policy

Not yet implemented:
- multi-bundle conflict resolution policy beyond one active pointer per spec
- multi-review / separation-of-duties policy
- stronger approval-envelope semantics beyond one review record per bundle
- operator/admin UI for lifecycle transitions

## Operator reading

For now, the safe interpretation is:
- compile to draft bundle
- review bundle and persist approval record
- activate deliberately with explicit operator identity and rationale
- treat revoke as immediate stop

The scaffold now has enough structure that future hardening can extend this policy without refactoring the ontology.
