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
- runtime loaders should only accept `active` bundles for normal execution paths
- revocation must make a bundle unloadable
- deprecation/revocation should clear active-registry pointers when the affected bundle was the current active bundle

## Current scaffold enforcement

Current code-level enforcement now includes:
- loader default request path expects `active` lifecycle state
- `FileBackedGOSBundleRegistry.activate(...)` only promotes bundles already marked `reviewed` or `active`
- `deprecate(...)` and `revoke(...)` clear active registry pointers when the targeted bundle was active

## Bootstrap exception

The repository currently ships one bootstrap exemplar bundle for `aaci.first-slice` already marked active.

This is intentional.
It exists to let the runtime exercise a real GOS-mediated path without waiting for a full review UI or promotion workflow.

This exception is acceptable for scaffold bootstrap, but should not be treated as the final production promotion model.

## Still missing for a stronger production policy

Not yet implemented:
- reviewed-state promotion command/service
- explicit approval records for activation
- richer provenance around who promoted a bundle and why
- multi-bundle conflict resolution policy beyond one active pointer per spec
- operator/admin UI for lifecycle transitions

## Operator reading

For now, the safe interpretation is:
- compile to draft bundle
- review bundle
- mark reviewed
- activate deliberately
- treat revoke as immediate stop

The scaffold now has enough structure that future hardening can extend this policy without refactoring the ontology.
