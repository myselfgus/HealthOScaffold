# Native macOS UI design system and app shell scope

Date baseline: April 29, 2026.

This document defines the scaffold/foundation scope for native macOS 26+ UI work across HealthOS app interfaces and operator tooling.

It does not implement a final product UI. It does not move HealthOS law into SwiftUI, AppKit, Xcode, or any design system component.

## Position

HealthOS native macOS surfaces are human/operator interfaces over mediated HealthOS contracts.

The current repository state is:
- Scribe has a minimal SwiftPM-backed macOS SwiftUI validation surface in `swift/Sources/HealthOSScribeApp/`.
- Sortio has app-safe patient-sovereignty contracts and screen contracts, but no native app shell.
- CloudClinic has service-operations contracts and screen contracts, but no native app shell.
- A HealthOS control panel for macOS is a valid future operator surface, but no app shell or executable target exists yet.

All four surfaces must consume Core/runtime-mediated state. They must not become law engines.

## SwiftPM, Xcode, and platform posture

The canonical Apple build graph remains `swift/Package.swift`.

HealthOS native app work targets macOS 26+ unless a later architecture decision explicitly documents another target. The package manifest uses PackageDescription 6.2+ and `.macOS(.v26)` so new SwiftUI work can use the current macOS design system and Liquid Glass APIs without treating older deployment targets as the product baseline.

Current products:
- `HealthOSCore` library
- `HealthOSAACI` library
- `HealthOSProviders` library
- `HealthOSSessionRuntime` library
- `HealthOSCLI` executable
- `HealthOSScribeApp` executable

Xcode may open the repository through `HealthOS.xcworkspace`, but SwiftPM remains the source of package/product truth for current macOS validation. New app shells should be introduced as explicit SwiftPM executable targets unless a later, documented Xcode-project requirement exists.

For SwiftPM GUI app work:
- build with `cd swift && swift build`;
- run command-line tools with `swift run <product>`;
- keep interactive SwiftUI/AppKit app launch behavior honest, and use app-bundle staging only when that workflow is intentionally introduced;
- do not claim packaging, signing, notarization, or production distribution until those surfaces are built and verified.

## Shared native UI principles

Use native macOS conventions first:
- `WindowGroup` for primary app windows;
- `Window` only for deliberate auxiliary or singleton utility windows;
- `Settings` for preferences instead of hiding settings inside content navigation;
- `NavigationSplitView` for sidebar/detail or sidebar/detail/inspector layouts;
- toolbars, commands, keyboard shortcuts, context menus, and search where they match desktop workflows;
- system-adaptive colors, semantic foreground styles, and system materials.

Use Liquid Glass as the macOS 26+ design baseline:
- rely on standard SwiftUI/AppKit controls and navigation surfaces before adding custom glass;
- let sidebars, toolbars, sheets, controls, and navigation containers pick up system Liquid Glass behavior naturally;
- remove opaque root/sidebar/sheet backgrounds that fight system materials before layering new visual treatment;
- use `glassEffect`, `GlassEffectContainer`, and glass button styles only for custom app-specific surfaces that standard controls do not cover;
- group nearby custom glass elements in one `GlassEffectContainer`;
- keep tint semantic, not decorative;
- use standard toolbar grouping, search placement, badges, and command exposure before building custom chrome.

Avoid:
- app-owned consent, habilitation, gate, finality, storage, or GOS policy;
- touch-first navigation patterns that hide persistent desktop structure;
- monolithic SwiftUI view files for non-trivial surfaces;
- raw direct identifiers, reidentification mappings, raw storage paths, raw GOS spec JSON, provider secrets, or clinical payload dumps in UI state;
- custom chrome or visual styling that fights native macOS sidebars, toolbars, sheets, and controls;
- final UI, production readiness, EHR, provider, signature, interoperability, or semantic retrieval claims.

## Shared design system scope

The design system is a native macOS 26+ component contract, not a source of HealthOS law.

Allowed scaffold-level outputs:
- shared semantic layout vocabulary for app shells: sidebar, detail, inspector, queue, review, audit, degraded-state banner, issue list, and provenance summary;
- shared component naming for app-safe status surfaces: runtime health, degraded mode, disposition, gate state, draft state, final-document state, consent state, queue state, export state, and mediation marker;
- shared typography/spacing/material guidance using native macOS defaults and system-adaptive colors;
- Liquid Glass adoption guidance for custom HealthOS-specific surfaces, including when to use standard controls, glass-prominent buttons, grouped custom glass, and non-glass fallback notes only where explicitly needed;
- lightweight reusable SwiftUI components only after two or more app surfaces need the same component and the component accepts already-mediated, app-safe inputs.

Out of scope in this scaffold:
- brand/final visual language;
- production design system token package;
- custom theme engine;
- cross-platform UI framework;
- clinical decision widgets;
- provider credential or signature UI;
- user-facing claims that imply full regulatory completion.

## App shell boundaries

### Scribe

Scribe is the professional-facing workspace.

Current shell status: implemented seam / tested validation surface.

Allowed native shell evolution:
- preserve the existing first-slice bridge and view model boundary;
- split the current validation surface into desktop-native sidebar/detail/review sections only when it reduces complexity;
- expose mediated session, capture, retrieval, draft, gate, final-document, issue, and GOS runtime state;
- add commands, toolbar actions, and keyboard shortcuts that invoke existing bridge commands.

Still prohibited:
- Scribe-owned consent/habilitation/gate/finality logic;
- issuing referral/prescription outputs;
- claiming real transcription, semantic retrieval, provider integration, or final product UI.

### Sortio

Sortio is the patient/user-facing sovereignty interface.

Current shell status: contract-first; no native app shell.

Allowed native shell scaffold:
- introduce a dedicated SwiftPM executable target only after the Sortio adapter/runtime boundary is ready to supply mediated app-safe state;
- use a sidebar/detail shell for dashboard, data categories, consent center, access trail, exports, and user-agent panel;
- render only app-safe `PatientConsentView`, `PatientAccessAuditView`, `PatientExportRequestSurface`, data visibility summaries, and cross-app safe refs.

Still prohibited:
- raw CPF, reidentification mapping, raw storage paths, direct clinical payload access, or clinical/regulatory actions;
- treating the user-agent panel as diagnosis, prescribing, referral, finalization, signature, or interoperability authority.

### CloudClinic

CloudClinic is the service-operations interface.

Current shell status: contract-first; no native app shell.

Allowed native shell scaffold:
- introduce a dedicated SwiftPM executable target only after service-operation adapter/runtime state exists;
- use a service dashboard or queue-oriented `NavigationSplitView`;
- render mediated queue/worklist, patient-service relationship, gate backlog, draft/document metadata, administrative task, runtime health, and issue surfaces.

Still prohibited:
- queue-as-authorization;
- admin role as professional authority;
- direct clinical finalization from UI;
- raw sensitive payloads or service access law implemented in SwiftUI.

### HealthOS control panel for macOS

The control panel is an operator/admin tooling surface for repository/runtime visibility, not an app-facing clinical surface.

Current shell status: doctrine-only / scope-defined.

Allowed native shell scaffold:
- a separate SwiftPM executable target such as `HealthOSControlPanelApp` only when there is an explicit operator contract to consume;
- dashboard sections for validation status, runtime health, GOS bundle lifecycle, Steward deterministic baseline, local smoke commands, incident-response command references, and scaffold gap visibility;
- read-only or explicitly operator-gated actions that call deterministic repository/runtime operations.

Still prohibited:
- clinical automation;
- Core law decisions;
- hidden provider/network writes;
- posting PR reviews or using provider output without explicit operator flags;
- presenting `healthos-mcp` as clinical, AACI, GOS, or Core runtime infrastructure.

## File structure for future app shells

For non-trivial native app shells, use module-local structure:

```text
swift/Sources/<AppTarget>/
  App/
  Views/
  Models/
  Stores/
  Services/
  Support/
```

`App/` owns scenes and top-level app lifecycle. `Views/` owns SwiftUI layout only. `Models/` owns value types and selection state. `Stores/` owns app/scene state. `Services/` owns calls into already-mediated HealthOS contracts. `Support/` owns small formatters, resolvers, and glue.

Keep business/governance behavior in Core/runtime targets. App targets consume it.

## Existing Scribe surface audit

The current `HealthOSScribeApp` surface is a minimal validation app, not the final macOS 26 design.

Current observations:
- the SwiftPM executable target exists and consumes `ScribeFirstSliceFacade`;
- the root view is a single scroll surface with grouped sections, appropriate for validation but not a final desktop shell;
- it does not currently use `NavigationSplitView`, toolbar commands, search, settings, or custom Liquid Glass surfaces;
- its use of `GroupBox` and `.thinMaterial` is acceptable as scaffold validation, but future macOS 26 UI work should prefer standard split-view/sidebar/detail structure and system Liquid Glass behavior before adding custom glass effects.

Do not retrofit Liquid Glass decoration into this validation surface without first deciding whether the work is still validation UI or the first real Scribe app-shell pass.

## Definition of done for native macOS UI scaffold work

Any future native UI scaffold work must:
- state which mediated contracts it consumes;
- state the role/scope of the surface;
- identify which HealthOS law remains outside app ownership;
- update architecture and execution tracking;
- validate with SwiftPM;
- run app smoke paths when app-facing executable behavior changes;
- preserve scaffold maturity and non-production warnings.
