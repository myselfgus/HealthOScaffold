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
- review submission should capture reviewer identity + rationale and fail closed when policy-required rationale is missing
- review policy should reject bundles whose compiler report does not pass (`parse_ok`, `structural_ok`, `cross_reference_ok`)
- reviewed-state promotion should append a lifecycle audit record with actor identity and rationale
- reviewed-state activation should evaluate a minimum independent review threshold before promotion
- activation policy may enforce reviewer/activator separation of duties for the same bundle
- activation policy may require deterministic pin checks (`spec_id`, `spec_version`, `bundle_version`, `compiler_version`, `source_sha256`, `compiled_spec_hash`) before promotion
- runtime loaders should only accept `active` bundles for normal execution paths
- revocation must make a bundle unloadable
- deprecation/revocation should clear active-registry pointers when the affected bundle was the current active bundle

## Current scaffold enforcement

Current code-level enforcement now includes:
- loader default request path expects `active` lifecycle state
- `GOSLifecyclePolicy` + `GOSReviewPolicy` + `GOSVersionPinningPolicy` provide the pragmatic policy contract for review/activation checks
- `FileBackedGOSBundleRegistry.review(...)` persists `review-approval.json`, keeps bundle identity stable, and records a `reviewed` lifecycle audit entry
- `FileBackedGOSBundleRegistry.review(...)` also appends review history (`review-approvals.jsonl`) so multiple review records are preserved append-only
- review and activation operations now append explicit lifecycle policy checkpoints (`review_submitted`, `review_denied_policy`, `activation_requested`, `activation_denied_policy`, `activated`)
- `FileBackedGOSBundleRegistry.activate(...)` only promotes bundles already marked `reviewed` or `active`
- reviewed bundles require policy-satisfying review records before activation succeeds (minimum approvals and optional separation-of-duties)
- activation pin mismatches fail with typed policy errors before lifecycle mutation
- `FileBackedGOSBundleRegistry.promoteReviewedBundle(...)` and `swift run HealthOSCLI --gos-promote-bundle ...` provide the minimal operator-facing promotion path
- `swift run HealthOSCLI --gos-review-bundle ...` provides the minimal operator-facing draft review path
- CLI promotion path now accepts minimal pinning/activator inputs (`--activator-id`, `--pin-spec-version`, `--pin-bundle-version`, `--pin-source-sha256`, `--pin-compiler-version`, `--pin-compiled-spec-hash`)
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
- reviewer authorization model beyond identity strings (no full RBAC/policy profile system yet)
- policy profile management for different services/runtimes
- operator/admin UI for lifecycle transitions

## Operator reading

For now, the safe interpretation is:
- compile to draft bundle
- review bundle and persist approval record
- activate deliberately with explicit operator identity and rationale
- treat revoke as immediate stop

The scaffold now has enough structure that future hardening can extend this policy without refactoring the ontology.
