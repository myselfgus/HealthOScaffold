# Xcode repository organization audit (2026-04-28)

## Decision

HealthOScaffold should not become a single `xcodeproj` for the entire repository.

The correct organization is:

1. a top-level `HealthOS.xcworkspace` as the Apple/Xcode entrypoint
2. the existing canonical Swift package at `swift/Package.swift`
3. optional future dedicated Apple projects only when an app surface outgrows SwiftPM packaging
4. all non-Apple parts (`ts/`, `python/`, `schemas/`, `docs/`, `gos/`, `sql/`, `scripts/`) kept as first-class monorepo folders with their own native tooling

## Audit findings

### Finding 1: the Swift package does exist

The repository contains the canonical Swift package at:

- `swift/Package.swift`

Its current products are:

- `HealthOSCore`
- `HealthOSAACI`
- `HealthOSProviders`
- `HealthOSSessionRuntime`
- `HealthOSCLI`
- `HealthOSScribeApp`

Its current structure includes:

- `swift/Sources/HealthOSCore/`
- `swift/Sources/HealthOSAACI/`
- `swift/Sources/HealthOSProviders/`
- `swift/Sources/HealthOSSessionRuntime/`
- `swift/Sources/HealthOSCLI/`
- `swift/Sources/HealthOSScribeApp/`
- `swift/Tests/HealthOSTests/`

### Finding 2: there was no top-level Xcode entrypoint

Before this work unit, the repository had the Swift package, but no root:

- `.xcodeproj`
- `.xcworkspace`

That meant the Apple layer was buildable through SwiftPM, but the monorepo did not yet expose an obvious Xcode-native entrypoint from repository root.

### Finding 3: a workspace is useful, but Xcode should not own the whole monorepo build

This repository is a multi-stack monorepo:

- Swift runtime and app surfaces
- TypeScript workspace/tooling
- Python governance scaffolds
- JSON Schema, SQL, GOS, scripts, and docs

Xcode is the right entry surface for the Swift/macOS layer, but it should not become the build authority for TypeScript, Python, schemas, or documentation.

## Required target layout

```text
HealthOScaffold/
  HealthOS.xcworkspace/
  swift/
    Package.swift
    Sources/
      HealthOSCore/
      HealthOSAACI/
      HealthOSProviders/
      HealthOSSessionRuntime/
      HealthOSCLI/
      HealthOSScribeApp/
    Tests/
      HealthOSTests/
  ts/
  python/
  schemas/
  docs/
  gos/
  sql/
  scripts/
```

## Workspace rule

The top-level workspace should:

- point to `swift/Package.swift`
- give Xcode users a stable repository entrypoint
- preserve SwiftPM as the canonical build graph for the Apple layer
- avoid pretending that non-Swift parts are Xcode-built products

## Conclusion

The repository should be treated as a monorepo with a SwiftPM-centered Apple layer.

The correct Xcode organization is now:

- root workspace for entry
- Swift package for implementation/build/test
- future dedicated app projects only if the Apple app surfaces later require packaging beyond SwiftPM
