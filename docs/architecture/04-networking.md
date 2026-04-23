# Private networking

## Policy

HealthOS is online-only within a private mesh posture.
It is not an offline-first system.

## Modes
- loopback/private traffic for local core-runtime coordination inside a node
- private mesh/VPN for trusted device and operator access
- local LAN administrative access only if explicitly allowed
- no direct public exposure of data services
- optional reverse proxy for future remote interfaces after explicit hardening

## Never expose directly
- PostgreSQL
- raw object store
- re-identification mapping layer
- internal runtime control ports

## Candidate shape
- mesh provider abstraction
- Tailscale/Headscale-compatible ACL model
- internal names for node and services
- explicit port map under ops/network/ports.md
