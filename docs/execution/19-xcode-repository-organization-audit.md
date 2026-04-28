# Xcode repository organization audit (2026-04-28)

## Decision

HealthOScaffold should **not** become a single `xcodeproj` for the entire repository.

It should be organized as:

1. one top-level `HealthOS.xcworkspace` as the Apple developer entrypoint
2. one canonical Swift package at `swift/Package.swift`
3. optional app-specific Apple targets/projects only for real Apple surfaces
4. all non-Apple parts (`ts/`, `python/`, `schemas/`, `docs/`, `gos/`, `sql/`, `scripts/`) kept as first-class monorepo folders, not forced into Xcode build ownership

## Why a single Xcode project is the wrong shape

This repository is a real multi-stack monorepo:

- Swift runtime and app surfaces
- TypeScript workspace/tooling
- Python governance scaffolds
- JSON Schema, SQL, GOS, operational scripts, and documentation

Xcode is an appropriate primary surface for the Apple/Swift layer, but it is not the correct build authority for the entire repository.

Forcing the whole monorepo into one `xcodeproj` would:

- blur ownership between Swift and non-Swift build systems
- create a misleading impression that TypeScript/Python/docs are Xcode-managed deliverables
- make repo maintenance harder without improving runtime truth

## Current audit findings

### Finding 1: no Xcode entrypoint exists

The repository currently exposes:

- no `.xcodeproj`
- no `.xcworkspace`
- no `swift/Package.swift`

So there is no real Xcode-native entrypoint today.

### Finding 2: the repository claims a Swift/Xcode layer that is not present in the current tree

Multiple canonical docs and the `Makefile` reference:

- `swift/Package.swift`
- `swift/Sources/HealthOSCore/`
- `swift/Sources/HealthOSFirstSliceSupport/`
- `swift/Sources/HealthOSCLI/`
- `swift/Sources/HealthOSScribeApp/`

But the current `swift/` directory is empty in the repository state available to this audit.

This is a repository-truth problem, not just an Xcode-setup problem.

### Finding 3: current tracking/history claims successful Swift validation that cannot be reproduced from the visible tree

`docs/execution/02-status-and-tracking.md` records prior successful runs such as:

- `cd swift && swift build && swift test`
- `swift run HealthOSCLI`
- `swift run HealthOSScribeApp --smoke-test`

Given the current visible tree, those claims are not presently reproducible.

This indicates one of:

1. the Swift layer exists elsewhere and is not in the current repository state
2. files were removed or not checked in
3. documentation/tracking drift has occurred

## Required target layout

The correct Apple-facing organization for this monorepo is:

```text
HealthOScaffold/
  HealthOS.xcworkspace
  swift/
    Package.swift
    Sources/
      HealthOSCore/
      HealthOSAACI/
      HealthOSProviders/
      HealthOSFirstSliceSupport/
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

## Xcode ownership rules

The future `HealthOS.xcworkspace` should:

- open the Swift package as the canonical buildable unit
- expose app and CLI schemes derived from that package
- optionally include supporting Apple-only projects if later needed
- avoid pretending that TypeScript, Python, or docs are built by Xcode

The workspace may show non-Swift folders for navigation convenience, but build/test authority for those layers must remain with their native tooling.

## Required next steps before creating the workspace

1. locate or restore the missing Swift package contents under `swift/`
2. confirm whether the current repository state is incomplete or the docs are stale
3. restore `swift/Package.swift` and the declared `Sources/` + `Tests/` layout
4. only then create `HealthOS.xcworkspace` as the canonical Xcode entrypoint

## Fail-closed conclusion

Creating an Xcode workspace right now would be cosmetic only, because the canonical Swift build graph is missing from the repository state visible to this audit.

The correct immediate action is to fix repository truth first, then add the workspace on top of the restored Swift package.
