# Skill: SwiftUI View Refactor

## Overview
Refactor SwiftUI views toward small, explicit, stable view types. Default to vanilla SwiftUI: local state in the view, shared dependencies in the environment, business logic in services/models.

## Core Guidelines
1. **View Ordering (top-to-bottom)**: Environment, private/public let, @State, computed properties, init, body, helper functions.
2. **Default to MV, not MVVM**: Avoid ViewModels unless explicitly needed. Use @State, @Environment, .task.
3. **Subviews**: Extract dedicated View types for non-trivial sections.
4. **Stable Tree**: Avoid top-level conditional view swapping (`if/else` root branches).
5. **Observation**: Use `@Observable` with `@State` for reference types (iOS 17+), fallback to `@StateObject`/`@ObservedObject` for older targets.
