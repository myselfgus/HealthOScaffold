# HealthOSScribeStage

Minimal SwiftUI validation surface for the HealthOS Scribe professional workspace first slice.

`HealthOSScribeStage` is a macOS 26+ `@main` SwiftUI executable backed by `HealthOS/Package.swift`. It is the only current interactive Stage shell. Its purpose is to provide an honest, smoke-testable validation surface for the first-slice orchestration path — not to deliver a final product UI.

**This Stage is not:** a complete clinical workspace, a real EHR, a final UI delivery, or a production-ready surface. It consumes only mediated state through `ScribeFirstSliceBridge`. It never becomes a law engine.

## Architecture

```mermaid
%%{init: {'theme': 'base', 'themeVariables': {'primaryColor': '#f5f3ff', 'primaryBorderColor': '#a78bfa', 'primaryTextColor': '#3b0764', 'fontFamily': 'ui-rounded, -apple-system, BlinkMacSystemFont, sans-serif'}}}%%
graph TD
    classDef law    fill:#dcfce7,stroke:#22c55e,stroke-width:2px,color:#14532d
    classDef bridge fill:#dbeafe,stroke:#60a5fa,stroke-width:2px,color:#1e3a8a
    classDef vm     fill:#fef9c3,stroke:#f59e0b,stroke-width:2px,color:#78350f
    classDef view   fill:#ede9fe,stroke:#8b5cf6,stroke-width:2px,color:#3b0764
    classDef glass  fill:#fce7f3,stroke:#f472b6,stroke-width:2px,color:#831843

    subgraph SRT["  Session Runtime (HealthOSSessionRuntime)  "]
        SR[SessionRunner\nfirst-slice orchestration]:::law
        SA[ScribeSessionAdapter\nbridges facade to runner]:::law
        BR[ScribeFirstSliceBridge\nmediated state]:::bridge
    end

    subgraph DEMO["  Demo Bootstrap  "]
        DB[ScribeSessionDemoBootstrap\ntest environment factory]:::law
    end

    subgraph VM["  ViewModel (this module)  "]
        MVM[ScribeFirstSliceViewModel\n@Observable · @MainActor]:::vm
    end

    subgraph VIEWS["  SwiftUI Views (this module)  "]
        APP[HealthOSScribeStage\n@main · WindowGroup]:::glass
        ROOT[ScribeFirstSliceView\nScrollView root]:::view
        C1[SurfaceSummaryCard]:::glass
        C2[SessionSetupCard]:::glass
        C3[WorkspaceCard]:::glass
        C4[SliceOutputsCard · OutputBlock]:::glass
        C5[IssuesCard]:::glass
    end

    SR --> SA --> BR
    DB --> MVM
    BR --> MVM
    MVM --> APP --> ROOT
    ROOT --> C1 & C2 & C3 & C4 & C5
```

## File Map

| File | Purpose |
| :--- | :--- |
| `App/HealthOSScribeStage.swift` | `@main` entry point — `WindowGroup` + smoke test launcher |
| `Models/ScribeFirstSliceViewModel.swift` | `@Observable @MainActor` view model — all session state and actions |
| `Views/ScribeFirstSliceView.swift` | Root view + five card subviews + `OutputBlock` component |

## Session States

The view model drives a six-state session machine:

| State | Meaning |
| :--- | :--- |
| `idle` | Environment bootstrapped, no session open |
| `opening` | `startSession()` in flight |
| `active` | Session open; capture, patient, gate operations available |
| `degraded` | Session active but transcription or retrieval degraded |
| `closed` | Gate resolved; final artifact effectuated or withheld |
| `failed` | Bootstrap or operational failure — fail-closed |

## Liquid Glass — macOS 26+ Adoption Path

The current scaffold uses `GroupBox` + `.thinMaterial` + standard SwiftUI controls. The macOS 26+ Liquid Glass adoption plan per `HealthOS/Shared/docs/architecture/48-native-macos-ui-design-system-and-app-shells.md`:

```swift
// Current scaffold — GroupBox + thinMaterial
GroupBox("1. Session Start") {
    // ...
}

// macOS 26+ target — wrap HealthOS-specific custom surfaces
GlassEffectContainer {
    SessionSetupPanel()
    WorkspacePanel()
}

// OutputBlock: thinMaterial → glassEffect
Text(text)
    .padding(10)
    .background(
        .glassEffect,  // macOS 26+ — replaces .thinMaterial for custom surfaces
        in: RoundedRectangle(cornerRadius: 8, style: .continuous)
    )
```

Rules:
- Standard controls (`Button`, `Picker`, `TextEditor`, `Toolbar`) pick up system Liquid Glass automatically — no explicit modifier needed.
- Group nearby custom glass elements in **one** `GlassEffectContainer` per logical section.
- Gate approve/reject buttons → glass-prominent style with semantic tint.
- Degraded state banner → tinted glass warning surface.
- Keep tint semantic (status color), never decorative.

## Smoke Test Modes

```bash
# Interactive SwiftUI session (macOS 26+)
cd HealthOS && swift run HealthOSScribeStage

# Non-interactive smoke test (headless, CI-safe)
cd HealthOS && swift run HealthOSScribeStage --smoke-test

# Audio capture smoke test (requires system audio file)
cd HealthOS && swift run HealthOSScribeStage --smoke-test-audio
```

The `--smoke-test` and `--smoke-test-audio` flags run the full first-slice orchestration path headlessly (habilitation → consent → session → capture → transcription → GOS activation → retrieval → SOAP draft → gate resolve) and exit with status 0 on success.

## Key Constraints

- The view model reads only `ScribeSessionBridgeState` — never raw storage paths, GOS spec JSON, provider secrets, or clinical payload dumps.
- `ScribeFirstSliceViewModel` must never contain consent, habilitation, gate, finality, storage policy, or GOS logic.
- All async operations use `async/await`; no Combine.
- Do not introduce `NavigationSplitView` or sidebar structure until the Scribe screen contracts (`HealthOS/Shared/docs/architecture/23-scribe-screen-contracts.md`) require them.
