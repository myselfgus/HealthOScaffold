# Private networking

## Policy

HealthOS is local-first. Remote access is private-first.

## Modes
- local loopback traffic for core and runtimes
- local LAN administrative access only if explicitly allowed
- mesh/VPN for trusted device access
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
