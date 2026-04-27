# Skill: Liquid Glass

## Overview
Use this skill to build or review SwiftUI features that fully align with the iOS 26+ Liquid Glass API. Prioritize native APIs (glassEffect, GlassEffectContainer, glass button styles) and Apple design guidance. Keep usage consistent, interactive where needed, and performance aware.

## Workflow Decision Tree
1. **Review an existing feature**: Inspect where Liquid Glass should be used/not used. Verify modifier order, shape usage, and container placement. Check availability handling (iOS 26+).
2. **Improve a feature**: Identify target components, refactor to `GlassEffectContainer`, introduce interaction only where needed.
3. **Implement a new feature**: Design surfaces/interactions, apply glass modifiers after layout, use morphing transitions with `glassEffectID` + `@Namespace`.

## Core Guidelines
- Prefer native Liquid Glass APIs over custom blurs.
- Use `GlassEffectContainer` for coexisting glass elements.
- Apply `.glassEffect(...)` after layout/appearance modifiers.
- Use `.interactive()` only for interactive elements.
- Gate with `#available(iOS 26, *)` with non-glass fallbacks.

## Quick Snippets
```swift
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
```
