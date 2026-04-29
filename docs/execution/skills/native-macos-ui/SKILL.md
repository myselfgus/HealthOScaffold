# Skill: Native macOS UI scaffold

## Overview

Use this skill when defining or changing HealthOS native macOS 26+ app shells, SwiftUI views, desktop interaction patterns, Liquid Glass treatment, or shared UI/design-system scope for Scribe, Sortio, CloudClinic, or the HealthOS control panel.

This skill is subordinate to HealthOS app-boundary doctrine. UI work consumes mediated Core/runtime contracts; it never owns consent, habilitation, gate, finality, storage law, or GOS policy.

## Required reading

Read in order:
1. `docs/architecture/19-interface-doctrine.md`
2. `docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`
3. the app-specific doc: `11-scribe.md`, `12-sortio.md`, or `13-cloudclinic.md`
4. the matching screen-contract doc: `23-scribe-screen-contracts.md`, `24-sortio-screen-contracts.md`, or `25-cloudclinic-screen-contracts.md`
5. `docs/execution/skills/app-boundary-skill.md`
6. the relevant macOS skill under `docs/execution/skills/` (`swiftpm`, `scaffolding`, `view-refactor`, `appkit-interop`, `build-run-debug`, or `testing`)
7. `docs/execution/skills/liquid-glass/SKILL.md` for macOS 26+ visual treatment or custom glass surfaces

## Guidelines

- Prefer SwiftPM as the canonical build graph while `swift/Package.swift` remains the package source of truth.
- Treat macOS 26+ as the native app target unless a later architecture decision explicitly documents another platform baseline.
- Prefer native SwiftUI scenes: `WindowGroup`, `Settings`, `NavigationSplitView`, commands, toolbars, keyboard shortcuts, and search.
- Use system-adaptive colors, semantic foreground styles, system materials, and standard Liquid Glass behavior.
- Prefer standard SwiftUI controls and system Liquid Glass surfaces before adding custom `glassEffect` treatment.
- Use `GlassEffectContainer` for grouped custom glass elements and keep tint semantic.
- Keep app targets split by responsibility: `App/`, `Views/`, `Models/`, `Stores/`, `Services/`, and `Support/`.
- Create shared UI components only when they accept already-mediated app-safe input.
- Treat Scribe as the only currently implemented native app validation surface.
- Treat Sortio, CloudClinic, and the HealthOS control panel as scope-defined until executable targets are intentionally introduced.

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
- `cd swift && swift build`
- `cd swift && swift test`
- relevant smoke path, usually `cd swift && swift run HealthOSScribeApp --smoke-test` for Scribe-facing behavior

## Definition of done

Every native UI work unit states:
- the mediated contracts consumed;
- the role/scope of the app or operator surface;
- which HealthOS law stays outside UI ownership;
- the validation commands run;
- any residual scaffold gap.
