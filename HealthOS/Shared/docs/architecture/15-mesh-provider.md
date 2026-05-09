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
- online-only operation through private mesh surfaces
- no offline mode doctrine
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
- mesh degradation is an operational incident that blocks governed online access until restored

## Failure posture
- mesh degradation is an operational condition
- mesh loss does not rewrite consent/habilitation law
- operations should fail closed with explicit operational status, not silently switch to offline behavior
