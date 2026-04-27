# Skill: AppKit Interop

## Overview
Use this skill when SwiftUI is not enough for native macOS behavior. Keep the bridge narrow and explicit.

## Core Guidelines
- Use pure SwiftUI where possible.
- Use `NSViewRepresentable` or `NSViewControllerRepresentable` for lightweight AppKit lifecycle needs.
- Keep ownership explicit: SwiftUI owns state/models, AppKit owns views/windows.
- Expose a narrow interface back to SwiftUI.
- Validate lifecycle: SwiftUI may recreate representables.

## Guardrails
- Do not duplicate source of truth.
- Do not let `Coordinator` become an unstructured dumping ground.
- Prefer tested bridges over rewriting features in raw AppKit.
