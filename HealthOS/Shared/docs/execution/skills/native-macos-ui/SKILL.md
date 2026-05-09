# Skill: Native macOS UI scaffold

## Overview

Use this skill when defining or changing HealthOS native macOS 26+ Stage shells, SwiftUI views, desktop interaction patterns, Liquid Glass treatment, or shared UI/design-system scope for Stages such as Scribe, Veridia, CloudClinic, future governed consumers, or the HealthOS control panel.

This skill is subordinate to HealthOS Boundary doctrine. UI work consumes mediated Core/runtime contracts; it never owns consent, habilitation, gate, finality, storage law, or GOS policy.

## Required reading

Read in order:
1. `HealthOS/Shared/docs/architecture/19-interface-doctrine.md`
2. `HealthOS/Shared/docs/architecture/50-app-layer-boundary-and-reference-apps.md`
3. `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
4. the app-specific doc: `11-scribe.md`, `12-veridia.md`, or `13-cloudclinic.md`
5. the matching screen-contract doc: `23-scribe-screen-contracts.md`, `24-veridia-screen-contracts.md`, or `25-cloudclinic-screen-contracts.md`
6. `HealthOS/Shared/docs/execution/skills/boundary-skill.md`
7. the relevant macOS skill under `HealthOS/Shared/docs/execution/skills/` (`swiftpm`, `scaffolding`, `view-refactor`, `appkit-interop`, `build-run-debug`, or `testing`)
8. `HealthOS/Shared/docs/execution/skills/liquid-glass/SKILL.md` for macOS 26+ visual treatment or custom glass surfaces

## Guidelines

- Prefer SwiftPM as the canonical build graph while `HealthOS/Package.swift` remains the package source of truth.
- Treat macOS 26+ as the native app target unless a later architecture decision explicitly documents another platform baseline.
- Prefer native SwiftUI scenes: `WindowGroup`, `Settings`, `NavigationSplitView`, commands, toolbars, keyboard shortcuts, and search.
- Use system-adaptive colors, semantic foreground styles, system materials, and standard Liquid Glass behavior.
- Prefer standard SwiftUI controls and system Liquid Glass surfaces before adding custom `glassEffect` treatment.
- Use `GlassEffectContainer` for grouped custom glass elements and keep tint semantic.
- Keep app targets split by responsibility: `App/`, `Views/`, `Models/`, `Stores/`, `Services/`, and `Support/`.
- Create shared UI components only when they accept already-mediated app-safe input.
- Treat Scribe as the only currently implemented native app validation surface.
- Treat Veridia as boundary-scaffolded but not final UI.
- Treat CloudClinic as placeholder-executable only; APP-012-style wiring remains blocked until Core/GOS/runtime surfaces, Boundary, and CloudClinic Custom readiness are satisfied.
- Treat the HealthOS control panel as scope-defined until an explicit operator contract and executable target are intentionally introduced.

## Absolute restrictions

- No app-owned consent, habilitation, gate, finality, storage, provider, or GOS policy.
- No raw direct identifiers, raw storage paths, reidentification mappings, raw GOS JSON, provider secrets, or unmediated clinical payload dumps.
- No final UI, production-ready, EHR, provider, signature, interoperability, semantic retrieval, or clinical automation claims.
- No custom macOS chrome before native SwiftUI structure has been used properly.
- No AppKit bridge unless SwiftUI cannot express the needed macOS behavior cleanly.
- No decorative Liquid Glass layer that obscures hierarchy, harms legibility, or duplicates system sidebar/toolbar/sheet material.

## Validation

For documentation-only scope changes:
- `make validate-docs`
- `git diff --check`

For SwiftUI/app target changes:
- `cd HealthOS && swift build`
- `cd HealthOS && swift test`
- relevant smoke path, usually `cd HealthOS/Tier4-Stages-Cast/Scribe && swift run Scribe --smoke-test` for Scribe-facing behavior

## Definition of done

Every native UI work unit states:
- the mediated contracts consumed;
- the role/scope of the Stage or operator surface;
- which HealthOS law stays outside UI ownership;
- the validation commands run;
- any residual scaffold gap.
