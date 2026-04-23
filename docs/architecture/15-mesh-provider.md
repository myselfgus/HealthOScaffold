# MeshProvider

## Purpose
Abstract private node/device connectivity without tying HealthOS ontology to one product.

## Responsibilities
- authenticate device/node into private network
- provide stable private addressing/naming
- apply ACL/policy model
- expose health/status for operations use
- expose device/node identity attributes needed for operator reasoning

## Non-responsibilities
- not a substitute for consent
- not a substitute for habilitation
- not a substitute for gate or audit logic
- not the source of truth for service/user authorization

## Baseline posture
- local-first
- mesh-only remote administration
- no direct public DB/object-store exposure

## Contract expectations
A MeshProvider should be able to describe:
- node identity
- device identity
- private addresses/names
- ACL/policy status
- connection health
- last-seen / liveness

## Operational rules
- database and object storage remain private surfaces
- admin exposure should remain limited to explicit operator endpoints
- app-facing UX should not depend on mesh semantics for core law
- loss of mesh connectivity should degrade remote operations, not rewrite local ontology

## Failure posture
- mesh degradation is an operational condition
- mesh loss does not imply consent or habilitation failure
- remote admin work may be blocked while local single-node operation continues
