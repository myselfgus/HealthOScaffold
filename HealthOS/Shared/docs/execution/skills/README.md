# AI skills index

This directory contains domain-specific execution skills for coding agents.

Treat HealthOScaffold as the HealthOS construction repository. Use scaffold terminology only for maturity or bootstrap/foundation phase, not project identity.

## How to use

Before editing a domain:
1. read execution status (`02`, `06`, `10`, `11`)
2. read relevant TODO
3. read architecture docs for the domain
4. open the matching skill below

## JAE Apple substrate rules

HealthOS is a Juridical Application Engine. Apple frameworks are substrate capabilities mediated by HealthOS, not direct Stage authority. Read `HealthOS/Shared/docs/architecture/51-apple-substrate-capabilities-for-jae.md` before Apple-native substrate work.

- Stages request capabilities through Custom/Boundary.
- Stages must not directly import Tier 2 runtime modules.
- SwiftData and CloudKit are projection/sync only, never canonical custody.
- FoundationModels/Core ML/NaturalLanguage must go through `HealthOSProviders` / `ProviderRouter`.
- XPC/ServiceManagement are isolated runtime infrastructure, not app-owned authority.
- Network is governed mesh transport, not arbitrary propagation.
- AppleArchive/CryptoKit create integrity/evidence, not legal finality.

## HealthOS domain skills (current)

Read when working on governance, runtimes, contracts, or cross-layer concerns:

- `core-law-skill.md`
- `gos-skill.md`
- `aaci-skill.md`
- `boundary-skill.md`
- `scribe-professional-workspace-skill.md`
- `user-agent-veridia-skill.md`
- `service-operations-cloudclinic-skill.md`
- `cross-stage-surfaces-skill.md`
- `storage-data-layer-skill.md`
- `provider-governance-skill.md`
- `async-runtime-skill.md`
- `mental-space-runtime-skill.md`
- `network-fabric-skill.md`
- `backup-restore-retention-export-skill.md`
- `regulatory-interoperability-skill.md`
- `documentation-drift-skill.md`
- `project-steward-skill.md`

## macOS / Apple platform skills

Read when working on Swift, SwiftUI, Xcode, or Apple platform concerns.
Each skill lives in its own subdirectory: `HealthOS/Shared/docs/execution/skills/<name>/SKILL.md`.

| Skill | When to read |
| :--- | :--- |
| `liquid-glass/SKILL.md` | Any SwiftUI work on iOS 26+ / macOS 26+ UI with Liquid Glass material |
| `swiftpm/SKILL.md` | Package.swift changes, new targets, dependencies |
| `build-run-debug/SKILL.md` | Build scripts, launch configuration, debug workflows |
| `testing/SKILL.md` | Swift Testing or XCTest additions/changes |
| `view-refactor/SKILL.md` | SwiftUI view restructuring or component extraction |
| `native-macos-ui/SKILL.md` | HealthOS native macOS 26+ Stage shell, Liquid Glass, and shared UI/design-system scope for Stages or the control panel |
| `performance/SKILL.md` | Profiling, rendering, memory, or latency work |
| `appkit-interop/SKILL.md` | AppKit/SwiftUI interop or macOS-specific platform code |
| `scaffolding/SKILL.md` | New Swift targets, modules, or directory scaffolding |
| `signing/SKILL.md` | Code signing, entitlements, provisioning |
| `shipping/SKILL.md` | Release, archiving, distribution |
| `xcode-toolchain/SKILL.md` | Instruments profiling, Simulator smoke runs, Accessibility Inspector, Create ML, Icon Composer |

## Legacy skills kept for compatibility

- `core-governance-skill.md`
- `storage-and-deidentification-skill.md`
- `aaci-runtime-skill.md`
- `ops-mesh-skill.md`
- `ml-governance-skill.md`
