# ADR 0006: Initial local seam between Swift and TypeScript

Status: Accepted

## Decision

The initial local seam between Swift and TypeScript is:
- loopback HTTP for service calls and runtime coordination
- PostgreSQL for canonical shared metadata/state
- filesystem/object paths for large artifact payloads

## Why

- Swift remains the best fit for local/native integration on macOS and Apple Silicon
- TypeScript remains the best fit for async orchestration and service-style tooling
- loopback HTTP keeps the boundary explicit and inspectable
- PostgreSQL remains the source of truth for governance and metadata
- filesystem/object references avoid forcing large artifacts through RPC payloads

## Non-goals

- not a public network boundary
- not a replacement for governance checks
- not a commitment against future IPC/XPC optimization where justified

## Consequences

- app and runtime integrations can target explicit local service endpoints
- schemas/contracts should be written as boundary-safe payloads
- artifact payloads should generally move by reference, not by large inline transport
