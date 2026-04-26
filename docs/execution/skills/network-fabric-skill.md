# Skill: network and fabric

## When to use
Mesh/network exposure, ops topology, private connectivity, ACL posture.

## Required reading
`docs/architecture/04-networking.md`, `15-mesh-provider.md`, `14-operations-runbook.md`.

## Invariants
Single-node bootstrap is minimum; mesh transport is not clinical authorization.

## Main files
`ops/network/*`, `docs/architecture/04-networking.md`, `15-mesh-provider.md`.

## Expected tests
Policy/document consistency checks + impacted smoke commands.

## Absolute restrictions
No public data-plane exposure by default.

## Definition of done
Topology claims stay honest and security posture explicit.

## What not to do
Do not conflate transport with consent/habilitation authority.
