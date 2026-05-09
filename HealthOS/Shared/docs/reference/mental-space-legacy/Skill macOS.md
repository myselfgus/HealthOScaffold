Skill macOS  
  
Overview  
Use this skill to build or review SwiftUI features that fully align with the iOS 26+ Liquid Glass API. Prioritize native APIs (glassEffect, GlassEffectContainer, glass button styles) and Apple design guidance. Keep usage consistent, interactive where needed, and performance aware.  
Workflow Decision Tree  
Choose the path that matches the request:  
## 1) Review an existing feature  
* Inspect where Liquid Glass should be used and where it should not.  
* Verify correct modifier order, shape usage, and container placement.  
* Check for iOS 26+ availability handling and sensible fallbacks.  
## 2) Improve a feature using Liquid Glass  
* Identify target components for glass treatment (surfaces, chips, buttons, cards).  
* Refactor to use GlassEffectContainer where multiple glass elements appear.  
* Introduce interactive glass only for tappable or focusable elements.  
## 3) Implement a new feature using Liquid Glass  
* Design the glass surfaces and interactions first (shape, prominence, grouping).  
* Add glass modifiers after layout/appearance modifiers.  
* Add morphing transitions only when the view hierarchy changes with animation.  
Core Guidelines  
* Prefer native Liquid Glass APIs over custom blurs.  
* Use GlassEffectContainer when multiple glass elements coexist.  
* Apply .glassEffect(...) after layout and visual modifiers.  
* Use .interactive() for elements that respond to touch/pointer.  
* Keep shapes consistent across related elements for a cohesive look.  
* Gate with #available(iOS 26, *) and provide a non-glass fallback.  
Review Checklist  
* Availability: #available(iOS 26, *) present with fallback UI.  
* Composition: Multiple glass views wrapped in GlassEffectContainer.  
* Modifier order: glassEffect applied after layout/appearance modifiers.  
* Interactivity: interactive() only where user interaction exists.  
* Transitions: glassEffectID used with @Namespace for morphing.  
* Consistency: Shapes, tinting, and spacing align across the feature.  
Implementation Checklist  
* Define target elements and desired glass prominence.  
* Wrap grouped glass elements in GlassEffectContainer and tune spacing.  
* Use .glassEffect(.regular.tint(...).interactive(), in: .rect(cornerRadius: ...)) as needed.  
* Use .buttonStyle(.glass) / .buttonStyle(.glassProminent) for actions.  
* Add morphing transitions with glassEffectID when hierarchy changes.  
* Provide fallback materials and visuals for earlier iOS versions.  
Quick Snippets  
Use these patterns directly and tailor shapes/tints/spacing.  
```
if #available(iOS 26, *) {
    Text("Hello")
        .padding()
        .glassEffect(.regular.interactive(), in: .rect(cornerRadius: 16))
} else {
    Text("Hello")
        .padding()
        .background(.ultraThinMaterial, in: RoundedRectangle(cornerRadius: 16))
}
GlassEffectContainer(spacing: 24) {
    HStack(spacing: 24) {
        Image(systemName: "scribble.variable")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
        Image(systemName: "eraser.fill")
            .frame(width: 72, height: 72)
            .font(.system(size: 32))
            .glassEffect()
    }
}
Button("Confirm") { }
    .buttonStyle(.glassProminent)

```
Resources  
* Reference guide: references/liquid-glass.md  
* Prefer Apple docs for up-to-date API details, and use web search to consult current Apple Developer documentation in addition to the references above.  
  
Quick start  
Choose a track based on your goal:  
## Existing project  
* Identify the feature or screen and the primary interaction model (list, detail, editor, settings, tabbed).  
* Find a nearby example in the repo with rg "TabView\(" or similar, then read the closest SwiftUI view.  
* Apply local conventions: prefer SwiftUI-native state, keep state local when possible, and use environment injection for shared dependencies.  
* Choose the relevant component reference from references/components-index.md and follow its guidance.  
* If the interaction reveals secondary content by dragging or scrolling the primary content away, read references/scroll-reveal.md before implementing gestures manually.  
* Build the view with small, focused subviews and SwiftUI-native data flow.  
## New project scaffolding  
* Start with references/app-wiring.md to wire TabView + NavigationStack + sheets.  
* Add a minimal AppTab and RouterPath based on the provided skeletons.  
* Choose the next component reference based on the UI you need first (TabView, NavigationStack, Sheets).  
* Expand the route and sheet enums as new screens are added.  
General rules to follow  
* Use modern SwiftUI state (@State, @Binding, @Observable, @Environment) and avoid unnecessary view models.  
* If the deployment target includes iOS 16 or earlier and cannot use the Observation API introduced in iOS 17, fall back to ObservableObject with @StateObject for root ownership, @ObservedObject for injected observation, and @EnvironmentObject only for truly shared app-level state.  
* Prefer composition; keep views small and focused.  
* Use async/await with .task and explicit loading/error states. For restart, cancellation, and debouncing guidance, read references/async-state.md.  
* Keep shared app services in @Environment, but prefer explicit initializer injection for feature-local dependencies and models. For root wiring patterns, read references/app-wiring.md.  
* Prefer the newest SwiftUI API that fits the deployment target and call out the minimum OS whenever a pattern depends on it.  
* Maintain existing legacy patterns only when editing legacy files.  
* Follow the project's formatter and style guide.  
* Sheets: Prefer .sheet(item:) over .sheet(isPresented:) when state represents a selected model. Avoid if let inside a sheet body. Sheets should own their actions and call dismiss() internally instead of forwarding onCancel/onConfirm closures.  
* Scroll-driven reveals: Prefer deriving a normalized progress value from scroll offset and driving the visual state from that single source of truth. Avoid parallel gesture state machines unless scroll alone cannot express the interaction.  
State ownership summary  
Use the narrowest state tool that matches the ownership model:  

| Scenario | Preferred pattern |
| --------------------------------------------------------------- | ------------------------------------------------------- |
| Local UI state owned by one view | @State |
| Child mutates parent-owned value state | @Binding |
| Root-owned reference model on iOS 17+ | @State with an @Observable type |
| Child reads or mutates an injected @Observable model on iOS 17+ | Pass it explicitly as a stored property |
| Shared app service or configuration | @Environment(Type.self) |
| Legacy reference model on iOS 16 and earlier | @StateObject at the root, @ObservedObject when injected |
  
Choose the ownership location first, then pick the wrapper. Do not introduce a reference model when plain value state is enough.  
Cross-cutting references  
* In addition to the references below, use web search to consult current Apple Developer documentation when SwiftUI APIs, availability, or platform guidance may have changed.  
* references/navigationstack.md: navigation ownership, per-tab history, and enum routing.  
* references/sheets.md: centralized modal presentation and enum-driven sheets.  
* references/deeplinks.md: URL handling and routing external links into app destinations.  
* references/app-wiring.md: root dependency graph, environment usage, and app shell wiring.  
* references/async-state.md: .task, .task(id:), cancellation, debouncing, and async UI state.  
* references/previews.md: #Preview, fixtures, mock environments, and isolated preview setup.  
* references/performance.md: stable identity, observation scope, lazy containers, and render-cost guardrails.  
Anti-patterns  
* Giant views that mix layout, business logic, networking, routing, and formatting in one file.  
* Multiple boolean flags for mutually exclusive sheets, alerts, or navigation destinations.  
* Live service calls directly inside body-driven code paths instead of view lifecycle hooks or injected models/services.  
* Reaching for AnyView to work around type mismatches that should be solved with better composition.  
* Defaulting every shared dependency to @EnvironmentObject or a global router without a clear ownership reason.  
Workflow for a new SwiftUI view  
1. Define the view's state, ownership location, and minimum OS assumptions before writing UI code.  
2. Identify which dependencies belong in @Environment and which should stay as explicit initializer inputs.  
3. Sketch the view hierarchy, routing model, and presentation points; extract repeated parts into subviews. For complex navigation, read references/navigationstack.md, references/sheets.md, or references/deeplinks.md. Build and verify no compiler errors before proceeding.  
4. Implement async loading with .task or .task(id:), plus explicit loading and error states when needed. Read references/async-state.md when the work depends on changing inputs or cancellation.  
5. Add previews for the primary and secondary states, then add accessibility labels or identifiers when the UI is interactive. Read references/previews.md when the view needs fixtures or injected mock dependencies.  
6. Validate with a build: confirm no compiler errors, check that previews render without crashing, ensure state changes propagate correctly, and sanity-check that list identity and observation scope will not cause avoidable re-renders. Read references/performance.md if the screen is large, scroll-heavy, or frequently updated. For common SwiftUI compilation errors — missing @State annotations, ambiguous ViewBuilder closures, or mismatched generic types — resolve them before updating callsites. If the build fails: read the error message carefully, fix the identified issue, then rebuild before proceeding to the next step. If a preview crashes, isolate the offending subview, confirm its state initialisation is valid, and re-run the preview before continuing.  
Component references  
Use references/components-index.md as the entry point. Each component reference should include:  
* Intent and best-fit scenarios.  
* Minimal usage pattern with local conventions.  
* Pitfalls and performance notes.  
* Paths to existing examples in the current repo.  
Adding a new component reference  
* Create references/<component>.md.  
* Keep it short and actionable; link to concrete files in the current repo.  
* Update references/components-index.md with the new entry.  
  
  
Quick start  
Use this skill to diagnose SwiftUI performance issues from code first, then request profiling evidence when code review alone cannot explain the symptoms.  
Workflow  
1. Classify the symptom: slow rendering, janky scrolling, high CPU, memory growth, hangs, or excessive view updates.  
2. If code is available, start with a code-first review using references/code-smells.md.  
3. If code is not available, ask for the smallest useful slice: target view, data flow, reproduction steps, and deployment target.  
4. If code review is inconclusive or runtime evidence is required, guide the user through profiling with references/profiling-intake.md.  
5. Summarize likely causes, evidence, remediation, and validation steps using references/report-template.md.  
1. Intake  
Collect:  
* Target view or feature code.  
* Symptoms and exact reproduction steps.  
* Data flow: @State, @Binding, environment dependencies, and observable models.  
* Whether the issue shows up on device or simulator, and whether it was observed in Debug or Release.  
Ask the user to classify the issue if possible:  
* CPU spike or battery drain  
* Janky scrolling or dropped frames  
* High memory or image pressure  
* Hangs or unresponsive interactions  
* Excessive or unexpectedly broad view updates  
For the full profiling intake checklist, read references/profiling-intake.md.  
2. Code-First Review  
Focus on:  
* Invalidation storms from broad observation or environment reads.  
* Unstable identity in lists and ForEach.  
* Heavy derived work in body or view builders.  
* Layout thrash from complex hierarchies, GeometryReader, or preference chains.  
* Large image decode or resize work on the main thread.  
* Animation or transition work applied too broadly.  
Use references/code-smells.md for the detailed smell catalog and fix guidance.  
Provide:  
* Likely root causes with code references.  
* Suggested fixes and refactors.  
* If needed, a minimal repro or instrumentation suggestion.  
3. Guide the User to Profile  
If code review does not explain the issue, ask for runtime evidence:  
* A trace export or screenshots of the SwiftUI timeline and Time Profiler call tree.  
* Device/OS/build configuration.  
* The exact interaction being profiled.  
* Before/after metrics if the user is comparing a change.  
Use references/profiling-intake.md for the exact checklist and collection steps.  
4. Analyze and Diagnose  
* Map the evidence to the most likely category: invalidation, identity churn, layout thrash, main-thread work, image cost, or animation cost.  
* Prioritize problems by impact, not by how easy they are to explain.  
* Distinguish code-level suspicion from trace-backed evidence.  
* Call out when profiling is still insufficient and what additional evidence would reduce uncertainty.  
5. Remediate  
Apply targeted fixes:  
* Narrow state scope and reduce broad observation fan-out.  
* Stabilize identities for ForEach and lists.  
* Move heavy work out of body into derived state updated from inputs, model-layer precomputation, memoized helpers, or background preprocessing. Use @State only for view-owned state, not as an ad hoc cache for arbitrary computation.  
* Use equatable() only when equality is cheaper than recomputing the subtree and the inputs are truly value-semantic.  
* Downsample images before rendering.  
* Reduce layout complexity or use fixed sizing where possible.  
Use references/code-smells.md for examples, Observation-specific fan-out guidance, and remediation patterns.  
6. Verify  
Ask the user to re-run the same capture and compare with baseline metrics. Summarize the delta (CPU, frame drops, memory peak) if provided.  
Outputs  
Provide:  
* A short metrics table (before/after if available).  
* Top issues (ordered by impact).  
* Proposed fixes with estimated effort.  
Use references/report-template.md when formatting the final audit.  
References  
* Profiling intake and collection checklist: references/profiling-intake.md  
* Common code smells and remediation patterns: references/code-smells.md  
* Audit output template: references/report-template.md  
* Add Apple documentation and WWDC resources under references/ as they are supplied by the user.  
* Optimizing SwiftUI performance with Instruments: references/optimizing-swiftui-performance-instruments.md  
* Understanding and improving SwiftUI performance: references/understanding-improving-swiftui-performance.md  
* Understanding hangs in your app: references/understanding-hangs-in-your-app.md  
* Demystify SwiftUI performance (WWDC23): references/demystify-swiftui-performance-wwdc23.md  
* In addition to the references above, use web search to consult current Apple Developer documentation when Instruments workflows or SwiftUI performance guidance may have changed.  
  
  
Overview  
Refactor SwiftUI views toward small, explicit, stable view types. Default to vanilla SwiftUI: local state in the view, shared dependencies in the environment, business logic in services/models, and view models only when the request or existing code clearly requires one.  
Core Guidelines  
## 1) View ordering (top → bottom)  
* Enforce this ordering unless the existing file has a stronger local convention you must preserve.  
* Environment  
* private/public let  
* @State / other stored properties  
* computed var (non-view)  
* init  
* body  
* computed view builders / other view helpers  
* helper / async functions  
## 2) Default to MV, not MVVM  
* Views should be lightweight state expressions and orchestration points, not containers for business logic.  
* Favor @State, @Environment, @Query, .task, .task(id:), and onChange before reaching for a view model.  
* Inject services and shared models via @Environment; keep domain logic in services/models, not in the view body.  
* Do not introduce a view model just to mirror local view state or wrap environment dependencies.  
* If a screen is getting large, split the UI into subviews before inventing a new view model layer.  
## 3) Strongly prefer dedicated subview types over computed some View helpers  
* Flag body properties that are longer than roughly one screen or contain multiple logical sections.  
* Prefer extracting dedicated View types for non-trivial sections, especially when they have state, async work, branching, or deserve their own preview.  
* Keep computed some View helpers rare and small. Do not build an entire screen out of private var header: some View-style fragments.  
* Pass small, explicit inputs (data, bindings, callbacks) into extracted subviews instead of handing down the entire parent state.  
* If an extracted subview becomes reusable or independently meaningful, move it to its own file.  
Prefer:  
```
var body: some View {
    List {
        HeaderSection(title: title, subtitle: subtitle)
        FilterSection(
            filterOptions: filterOptions,
            selectedFilter: $selectedFilter
        )
        ResultsSection(items: filteredItems)
        FooterSection()
    }
}

private struct HeaderSection: View {
    let title: String
    let subtitle: String

    var body: some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title).font(.title2)
            Text(subtitle).font(.subheadline)
        }
    }
}

private struct FilterSection: View {
    let filterOptions: [FilterOption]
    @Binding var selectedFilter: FilterOption

    var body: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack {
                ForEach(filterOptions, id: \.self) { option in
                    FilterChip(option: option, isSelected: option == selectedFilter)
                        .onTapGesture { selectedFilter = option }
                }
            }
        }
    }
}

```
Avoid:  
```
var body: some View {
    List {
        header
        filters
        results
        footer
    }
}

private var header: some View {
    VStack(alignment: .leading, spacing: 6) {
        Text(title).font(.title2)
        Text(subtitle).font(.subheadline)
    }
}

```
## 3b) Extract actions and side effects out of body  
* Do not keep non-trivial button actions inline in the view body.  
* Do not bury business logic inside .task, .onAppear, .onChange, or .refreshable.  
* Prefer calling small private methods from the view, and move real business logic into services/models.  
* The body should read like UI, not like a view controller.  
```
Button("Save", action: save)
    .disabled(isSaving)

.task(id: searchText) {
    await reload(for: searchText)
}

private func save() {
    Task { await saveAsync() }
}

private func reload(for searchText: String) async {
    guard !searchText.isEmpty else {
        results = []
        return
    }
    await searchService.search(searchText)
}

```
## 4) Keep a stable view tree (avoid top-level conditional view swapping)  
* Avoid body or computed views that return completely different root branches via if/else.  
* Prefer a single stable base view with conditions inside sections/modifiers (overlay, opacity, disabled, toolbar, etc.).  
* Root-level branch swapping causes identity churn, broader invalidation, and extra recomputation.  
Prefer:  
```
var body: some View {
    List {
        documentsListContent
    }
    .toolbar {
        if canEdit {
            editToolbar
        }
    }
}

```
Avoid:  
```
var documentsListView: some View {
    if canEdit {
        editableDocumentsList
    } else {
        readOnlyDocumentsList
    }
}

```
## 5) View model handling (only if already present or explicitly requested)  
* Treat view models as a legacy or explicit-need pattern, not the default.  
* Do not introduce a view model unless the request or existing code clearly calls for one.  
* If a view model exists, make it non-optional when possible.  
* Pass dependencies to the view via init, then create the view model in the view's init.  
* Avoid bootstrapIfNeeded patterns and other delayed setup workarounds.  
Example (Observation-based):  
```
@State private var viewModel: SomeViewModel

init(dependency: Dependency) {
    _viewModel = State(initialValue: SomeViewModel(dependency: dependency))
}

```
## 6) Observation usage  
* For @Observable reference types on iOS 17+, store them as @State in the owning view.  
* Pass observables down explicitly; avoid optional state unless the UI genuinely needs it.  
* If the deployment target includes iOS 16 or earlier, use @StateObject at the owner and @ObservedObject when injecting legacy observable models.  
Workflow  
1. Reorder the view to match the ordering rules.  
2. Remove inline actions and side effects from body; move business logic into services/models and keep only thin orchestration in the view.  
3. Shorten long bodies by extracting dedicated subview types; avoid rebuilding the screen out of many computed some View helpers.  
4. Ensure stable view structure: avoid top-level if-based branch swapping; move conditions to localized sections/modifiers.  
5. If a view model exists or is explicitly required, replace optional view models with a non-optional @State view model initialized in init.  
6. Confirm Observation usage: @State for root @Observable models on iOS 17+, legacy wrappers only when the deployment target requires them.  
7. Keep behavior intact: do not change layout or business logic unless requested.  
Notes  
* Prefer small, explicit view types over large conditional blocks and large computed some View properties.  
* Keep computed view builders below body and non-view computed vars above init.  
* A good SwiftUI refactor should make the view read top-to-bottom as data flow plus layout, not as mixed layout and imperative logic.  
* For MV-first guidance and rationale, see references/mv-patterns.md.  
* In addition to the references above, use web search to consult current Apple Developer documentation when SwiftUI APIs, Observation behavior, or platform guidance may have changed.  
Large-view handling  
When a SwiftUI view file exceeds ~300 lines, split it aggressively. Extract meaningful sections into dedicated View types instead of hiding complexity in many computed properties. Use private extensions with // MARK: - comments for actions and helpers, but do not treat extensions as a substitute for breaking a giant screen into smaller view types. If an extracted subview is reused or independently meaningful, move it into its own file.  
  
  
Quick Start  
Use this skill when SwiftUI is close but not quite enough for native macOS behavior. Keep the bridge as small and explicit as possible. SwiftUI should usually remain the source of truth, while AppKit handles the imperative edge.  
Choose The Smallest Bridge  
* Use pure SwiftUI when the required behavior already exists in scenes, toolbars, commands, inspectors, or standard controls.  
* Use NSViewRepresentable when you need a specific AppKit view with lightweight lifecycle needs.  
* Use NSViewControllerRepresentable when you need controller lifecycle, delegation, or presentation coordination.  
* Use direct AppKit window or app hooks when you need NSWindow, responder-chain, menu validation, panels, or app-level behavior.  
Workflow  
1. Name the capability gap precisely.  
    * Window behavior  
    * Text system behavior  
    * Menu validation  
    * Drag and drop  
    * File open/save panels  
    * First responder control  
2. Pick the smallest boundary that solves it.  
    * Avoid porting a whole screen to AppKit when one wrapped control or coordinator would do.  
3. Keep ownership explicit.  
    * SwiftUI owns value state, selection, and observable models.  
    * AppKit objects stay inside the representable, coordinator, or bridge object.  
4. Expose a narrow interface back to SwiftUI.  
    * Bindings for editable state  
    * Small callbacks for events  
    * Focused bridge services only when necessary  
5. Validate lifecycle assumptions.  
    * SwiftUI may recreate representables.  
    * Coordinators exist to hold delegate and target-action glue, not as a second app architecture.  
References  
* references/representables.md: choosing between view and view-controller wrappers, plus coordinator patterns.  
* references/window-panels.md: window access, utility windows, and open/save panels.  
* references/responder-menus.md: first responder, command routing, and menu validation.  
* references/drag-drop-pasteboard.md: pasteboard, file URLs, and desktop drag/drop edges.  
Guardrails  
* Do not duplicate the source of truth between SwiftUI and AppKit.  
* Do not let Coordinator become an unstructured dumping ground.  
* Do not store long-lived NSView or NSWindow instances globally without a strong ownership reason.  
* Prefer a tiny tested bridge over rewriting the feature in raw AppKit.  
* If a pattern can remain entirely in swiftui-patterns, keep it there.  
Output Expectations  
Provide:  
* the exact SwiftUI limitation being crossed  
* the smallest recommended bridge type  
* the data-flow boundary between SwiftUI and AppKit  
* the lifecycle or validation risks to watch  
  
  
Quick Start  
Use this skill to set up one project-local script/build_and_run.sh entrypoint, wire .codex/environments/environment.toml so the Codex app shows a Run button, then use that script as the default build/run path.  
Prefer shell-first workflows:  
* ./script/build_and_run.sh as the single kill + build + run entrypoint once it exists  
* xcodebuild for Xcode workspaces or projects  
* swift build plus raw executable launch inside that script for true SwiftPM command-line tools  
* swift build plus project-local .app bundle staging and /usr/bin/open -n launch for SwiftPM AppKit/SwiftUI GUI apps  
* optional script flags for lldb, log stream, telemetry verification, or post-launch process checks  
Do not assume simulators, touch interaction, or mobile-specific tooling.  
If an Xcode-aware MCP surface is already available and the user explicitly wants it, use it only where it fits. Keep that usage narrow and honest: prefer it for Xcode-oriented discovery, logging, or debugging support, and do not force simulator-specific workflows onto pure macOS tasks.  
Workflow  
1. Discover the project shape.  
    * Check whether the workspace is already inside a git repo with git rev-parse --is-inside-work-tree.  
    * If no git repo is present, run git init at the project/workspace root before building so Codex app git-backed features are available. Never run git init inside a nested subdirectory when the current workspace already belongs to a parent repo.  
    * Look for .xcworkspace, .xcodeproj, and Package.swift.  
    * If more than one candidate exists, explain the default choice and the ambiguity.  
2. Resolve the runnable target and process name.  
    * For Xcode, list schemes and prefer the app-producing scheme unless the user names another one.  
    * For SwiftPM, identify executable products when possible.  
    * Split SwiftPM launch handling by product type:  
        * use raw executable launch only for true command-line tools,  
        * use a generated project-local .app bundle for AppKit/SwiftUI GUI apps.  
    * Determine the app/process name to kill before relaunching.  
3. Create or update script/build_and_run.sh.  
    * Make the script project-specific and executable.  
    * It should always:  
        1. stop the existing running app/process if present,  
        2. build the macOS target,  
        3. launch the freshly built app or executable.  
    * Add optional flags for debugging/log inspection:  
        * --debug to launch under lldb or attach the debugger  
        * --logs to stream process logs after launch  
        * --telemetry to stream unified logs filtered to the app subsystem/category  
        * --verify to launch the app and confirm the process exists with pgrep -x <AppName>  
    * Keep the default no-flag path simple: kill, build, run.  
    * Prefer writing one script that owns this workflow instead of repeatedly asking the agent to manually run swift build, locate the artifact, then invoke an ad hoc run command.  
    * For SwiftPM GUI apps, make the script build the product, create dist/<AppName>.app, copy the binary to Contents/MacOS/<AppName>, generate a minimal Contents/Info.plist with CFBundlePackageType=APPL, CFBundleExecutable, CFBundleIdentifier, CFBundleName, LSMinimumSystemVersion, and NSPrincipalClass=NSApplication, then launch with /usr/bin/open -n <bundle>.  
    * For SwiftPM GUI --logs and --telemetry, launch the bundle with /usr/bin/open -n first, then stream unified logs with /usr/bin/log stream --info ....  
    * Do not recommend direct SwiftPM executable launch for AppKit/SwiftUI GUI apps.  
    * Use references/run-button-bootstrap.md as the canonical source for the script shape and exact environment file format. Do not fork a second authoritative snippet in another skill or command.  
    * Keep the run script outside app source. It belongs in script/build_and_run.sh, not in App/, Views/, Models/, Stores/, Services/, or Support/.  
4. Write .codex/environments/environment.toml at the project root once the script exists.  
    * Use this exact placement: .codex/environments/environment.toml.  
    * Use the exact action shape in references/run-button-bootstrap.md.  
    * This file is what gives the user a Codex app Run button wired to the script.  
    * If the project already has this file, update the Run action command to point at ./script/build_and_run.sh instead of creating a duplicate action.  
    * Keep this Codex environment config separate from Swift app source files.  
5. Build and run through the script.  
    * Default to ./script/build_and_run.sh.  
    * Use ./script/build_and_run.sh --debug, --logs, --telemetry, or --verify when the user asks for debugger/log/telemetry/process verification support.  
6. Summarize failures correctly.  
    * Classify the blocker as compiler, linker, signing, build settings, missing SDK/toolchain, script bug, or runtime launch.  
    * Quote the smallest useful error snippet and explain what it means.  
7. Debug the right way.  
    * Use the script's --logs or --telemetry mode for config, entitlement, sandbox, and action-event verification.  
    * For SwiftPM GUI apps, if the app bundle launches but its window still does not come forward, check whether the entrypoint needs NSApp.setActivationPolicy(.regular) and NSApp.activate(ignoringOtherApps: true).  
    * Use the script's --debug mode or direct lldb if symbolized crash debugging is needed.  
    * If the user needs to instrument and verify specific window, sidebar, menu, or menu bar actions, switch to telemetry.  
    * Keep evidence tight and user-facing.  
8. Use Xcode-aware MCP tooling only when it helps.  
    * If the user explicitly asks for XcodeBuildMCP and it is already available, prefer it over ad hoc setup.  
    * Use the MCP for Xcode-aware discovery or debug/logging workflows when the available tool surface clearly matches the task.  
    * Fall back to shell commands immediately when the MCP does not provide a clean macOS path.  
Preferred Commands  
* Project discovery:  
    * find . -name '*.xcworkspace' -o -name '*.xcodeproj' -o -name 'Package.swift'  
* Scheme discovery:  
    * xcodebuild -list -workspace <workspace>  
    * xcodebuild -list -project <project>  
* Build/run:  
    * ./script/build_and_run.sh  
    * ./script/build_and_run.sh --debug  
    * ./script/build_and_run.sh --logs  
    * ./script/build_and_run.sh --telemetry  
    * ./script/build_and_run.sh --verify  
References  
* references/run-button-bootstrap.md: canonical build_and_run.sh and .codex/environments/environment.toml contract.  
Guardrails  
* Prefer the narrowest command that proves or disproves the current theory.  
* Do not leave the user with a one-off manual command chain once a stable build_and_run.sh script can own the workflow.  
* Do not write .codex/environments/environment.toml before the run script exists, and do not point the Run action at a stale script path.  
* Do not launch a SwiftUI/AppKit SwiftPM GUI app as a raw executable unless the user explicitly wants to diagnose that failure mode: it can produce no Dock icon, no foreground activation, and missing bundle identifier warnings. Keep raw executable launch only for true command-line tools.  
* Do not claim UI state you cannot inspect directly.  
* Do not describe mobile or simulator workflows as if they apply to macOS.  
* If build output is huge, summarize the first real blocker and point to follow-up commands.  
Output Expectations  
Provide:  
* the detected project type  
* the script path and Codex environment action you configured, if applicable  
* the command you ran  
* whether build and launch succeeded  
* the top blocker if they failed  
* the smallest sensible next action  
  
  
Overview  
Use this skill to bring a macOS SwiftUI app into the modern macOS design system with the least custom chrome possible. Start with standard app structure, toolbars, search placement, sheets, and controls, then add custom Liquid Glass only where the app needs a distinctive surface.  
Prefer system-provided glass and adaptive materials over bespoke blur, opaque backgrounds, or custom toolbar/sidebar skins. Audit existing UI for extra fills, scrims, and clipping before adding more effects.  
Workflow  
1. Read the relevant scene or root view and identify the structural pattern: NavigationSplitView, TabView, sheet presentation, detail/inspector layout, toolbar, or custom floating controls.  
2. Remove custom backgrounds or darkening layers behind system sheets, sidebars, and toolbars unless the product explicitly needs them. These can obscure Liquid Glass and interfere with the automatic scroll-edge effect.  
3. Update standard SwiftUI structure and controls first.  
4. Add custom glassEffect surfaces only for app-specific UI that standard controls do not cover.  
5. Validate that glass grouping, transitions, icon treatment, and foreground activation are visually coherent and still usable with pointer and keyboard.  
6. If the UI change also affects launch behavior for a SwiftPM GUI app, use build-run-debug so the app runs as a foreground .app bundle rather than as a raw executable.  
App Structure  
* Prefer NavigationSplitView for hierarchy-driven macOS layouts. Let the sidebar use the system Liquid Glass material instead of painting over it.  
* For hero artwork or large media adjacent to a floating sidebar, use backgroundExtensionEffect so the visual can extend beyond the safe area without clipping the subject.  
* Keep inspectors visually associated with the current selection and avoid giving them a heavier custom background than the content they inspect.  
* If the app uses tabs, keep TabView for persistent top-level sections and preserve each tab's local navigation state.  
* Do not force iPhone-only tab bar minimize/accessory behavior onto a Mac app. On macOS, prefer a conventional top toolbar and native tab/search placement.  
* If a sheet already uses presentationBackground purely to imitate frosted material, consider removing it and letting the system's new material render.  
* For sheet transitions that should visually originate from a toolbar button, make the presenting item the source of a navigation zoom transition and mark the sheet content as the destination.  
Toolbars  
* Assume toolbar items are rendered on a floating Liquid Glass surface and are grouped automatically.  
* Use ToolbarSpacer to communicate grouping:  
    * fixed spacing to split related actions into a distinct group,  
    * flexible spacing to push a leading action away from a trailing group.  
* Use sharedBackgroundVisibility when an item should stand alone without the shared glass background, for example a profile/avatar item.  
* Add badge to toolbar item content for notification or status indicators.  
* Expect monochrome icon rendering in more toolbar contexts. Use tint only to convey semantic meaning such as a primary action or alert state, not as pure decoration.  
* If content underneath a toolbar has extra darkening, blur, or custom background layers, remove them before judging the new automatic scroll-edge effect.  
* For dense windows with many floating elements, tune the content's scroll-edge treatment with scrollEdgeEffectStyle instead of building a custom bar background.  
Search  
* For a search field that applies across a whole split-view hierarchy, attach searchable to the NavigationSplitView, not to just one column.  
* When search is secondary and a compact affordance is better, use searchToolbarBehavior instead of hand-rolling a toolbar button and a separate field.  
* For a dedicated search page in a multi-tab app, assign the search role to one tab and place searchable on the TabView.  
* Make most of the app's content discoverable from search when the field lives in the top-trailing toolbar location.  
* On iPad and Mac, expect the dedicated search tab to show a centered field above browsing suggestions rather than a bottom search bar.  
Controls  
* Prefer standard SwiftUI controls before creating custom glass components.  
* Expect bordered buttons to default to a capsule shape at larger sizes. On macOS, mini/small/medium controls preserve a rounded-rectangle shape for denser layouts.  
* Use buttonBorderShape when a button shape needs to be explicit.  
* Use controlSize to preserve density in inspectors and popovers, and reserve extra-large sizing for truly prominent actions.  
* Use the system glass and glass-prominent button styles for primary actions instead of recreating a translucent button background by hand.  
* For sliders with discrete values, pass step to get automatic tick marks or provide specific ticks in a ticks closure.  
* For sliders that should expand left and right around a baseline, set neutralValue.  
* Use Label or standard control initializers for menu items so icons are consistently placed on the leading edge across platforms.  
* For custom shapes that must align concentrically with a sheet, card, or window corner, use a concentric rectangle shape with the containerConcentric corner configuration instead of guessing a radius.  
Custom Liquid Glass  
* Use glassEffect for custom glass surfaces. The default shape is capsule-like and text foregrounds are automatically made vibrant and legible against changing content underneath.  
* Pass an explicit shape to glassEffect when a capsule is not the right fit.  
* Add tint only when color carries meaning, such as a status or call to action.  
* Use glassEffect(... .interactive()) for custom controls or containers with interactive elements so they scale, bounce, and shimmer like system glass.  
* Wrap nearby custom glass elements in one GlassEffectContainer. This is a visual correctness rule, not just organization: separate containers cannot sample each other's glass and can produce inconsistent refraction.  
* Use glassEffectID with a local @Namespace when matching glass elements should morph between collapsed and expanded states.  
Review Checklist  
* Standard structures and controls were updated first before adding custom glass.  
* Opaque backgrounds, dark scrims, and custom toolbar/sheet fills that fight the system material were removed unless intentionally required.  
* searchable is attached at the correct container level for the intended search scope.  
* Toolbar grouping uses ToolbarSpacer, sharedBackgroundVisibility, and badge instead of one-off hand-built chrome.  
* Icon tint is semantic, not decorative.  
* Custom glass elements that sit near each other share a GlassEffectContainer.  
* Morphing glass transitions use glassEffectID with a namespace and stable identity.  
* Any SwiftPM GUI app used to test the result is launched as a .app bundle, not as a raw executable.  
Guardrails  
* Do not rebuild system sidebars, toolbars, sheets, or controls from scratch if standard SwiftUI APIs already provide the modern macOS behavior.  
* Do not apply custom opaque backgrounds behind a NavigationSplitView sidebar, system toolbar, or sheet just because an older version needed one.  
* Do not scatter related glass elements across multiple GlassEffectContainers.  
* Do not tint every icon or glass surface for visual variety alone.  
* Do not assume an iPhone tab/search behavior is the right answer on macOS. Prefer desktop-native toolbar, split-view, and inspector placement.  
* Do not leave a GUI SwiftPM app launching as a bare executable when reviewing Liquid Glass behavior; missing foreground activation can make a design bug look like a rendering bug.  
When To Use Other Skills  
* Use swiftui-patterns when the main question is scene architecture, sidebar/detail layout, commands, or settings rather than Liquid Glass-specific treatment.  
* Use view-refactor when the main issue is file structure, state ownership, and extracting large views before design changes.  
* Use appkit-interop when the design requires window, panel, responder-chain, or AppKit-only control behavior.  
* Use build-run-debug when you need to launch, verify, or inspect logs for the app after the visual update.  
  
  
Quick Start  
Use this skill when the work is about shipping the app rather than merely running it locally: archives, exported app bundles, notarization readiness, hardened runtime, or distribution validation.  
Workflow  
1. Confirm the distribution goal.  
    * Local archive validation  
    * Signed distributable app  
    * Notarization troubleshooting  
2. Inspect the artifact.  
    * Validate app bundle structure.  
    * Check nested frameworks, helper tools, and entitlements.  
3. Inspect signing and runtime prerequisites.  
    * Hardened runtime  
    * Signing identity  
    * Nested code signatures  
    * Required entitlements  
4. Explain notarization readiness or failure.  
    * Separate packaging issues from trust-policy symptoms.  
    * Point to the minimum follow-up validation commands.  
Guardrails  
* Do not present notarization as required for ordinary local debug runs.  
* Call out when you lack the actual exported artifact and are inferring from project settings.  
* Keep advice concrete and verifiable.  
Output Expectations  
Provide:  
* what artifact or settings were inspected  
* whether the app looks distribution-ready  
* the top missing prerequisite or failure mode  
* the next validation or repair step  
  
  
Quick Start  
Use this skill when the failure smells like codesigning rather than compilation: launch refusal, missing entitlement, invalid signature, sandbox mismatch, hardened runtime confusion, or trust-policy rejection.  
Workflow  
1. Inspect the bundle or binary.  
    * Locate the .app or executable.  
    * Identify the main binary inside Contents/MacOS/.  
2. Read signing details.  
    * Use codesign -dvvv --entitlements :- <path>.  
    * Use spctl -a -vv <path> when Gatekeeper behavior matters.  
    * Use plutil -p for entitlements or Info.plist inspection.  
3. Classify the failure.  
    * Unsigned or ad hoc signed  
    * Wrong identity  
    * Entitlement mismatch  
    * Hardened runtime issue  
    * App Sandbox issue  
    * Nested code signing issue  
    * Distribution/notarization prerequisite issue  
4. Explain the minimum fix path.  
    * Say exactly what is wrong.  
    * Show the shortest set of validation or repair commands.  
    * Distinguish local development problems from distribution problems.  
Useful Commands  
* codesign -dvvv --entitlements :- <app-or-binary>  
* spctl -a -vv <app-or-binary>  
* security find-identity -p codesigning -v  
* plutil -p <path-to-entitlements-or-plist>  
Guardrails  
* Never invent missing entitlements.  
* Do not conflate notarization with local debug signing.  
* If the real issue is a build setting or provisioning profile, say so directly.  
Output Expectations  
Provide:  
* what artifact was inspected  
* what signing state it is in  
* the exact failure class  
* the minimum fix or validation sequence  
  
  
Quick Start  
Use this skill when Package.swift is the primary entrypoint or when SwiftPM is the fastest path to a reproducible result.  
Workflow  
1. Inspect the package.  
    * Read Package.swift.  
    * Identify executable, library, and test products.  
2. Build with SwiftPM.  
    * Use swift build by default.  
    * Use release mode only when the user explicitly needs it.  
3. Run the right product.  
    * Use swift run <product> when an executable exists.  
    * If multiple executables exist, explain the default choice.  
4. Test narrowly.  
    * Use swift test.  
    * Apply filters when a specific test target or case is known.  
5. Summarize failures.  
    * Module/import resolution  
    * Package graph or dependency issue  
    * Linker failure  
    * Runtime failure  
    * Test regression  
Guardrails  
* Prefer SwiftPM over Xcode when both exist and the package path is clearly simpler.  
* Do not assume an app bundle exists in a pure package workflow.  
* Explain when the package is library-only and therefore not directly runnable.  
Output Expectations  
Provide:  
* the package products you found  
* the command you ran  
* whether build, run, or test succeeded  
* the top blocker if not  
  
  
Quick Start  
Choose a track based on your goal:  
## Existing project  
* Identify the feature or scene and the primary interaction model: document, editor, sidebar-detail, utility window, settings, or menu bar extra.  
* Read the nearest existing scene or root view before inventing a new desktop structure.  
* Choose the relevant reference from references/components-index.md.  
* If SwiftUI cannot express the required platform behavior cleanly, use the appkit-interop skill rather than forcing a shaky workaround.  
## New app scaffolding  
* Choose the scene model first: WindowGroup, Window, Settings, MenuBarExtra, or DocumentGroup.  
* If the app combines a normal main window and a MenuBarExtra, use WindowGroup(..., id:) for the primary window when it should appear at launch. Treat Window(...) as a better fit for auxiliary/on-demand singleton windows; in menu-bar-heavy apps, a Window(...) scene may not present the main window automatically at launch.  
* Before creating the scaffold, check whether the workspace is already inside a git repo with git rev-parse --is-inside-work-tree. If not, run git init at the project root so Codex app git-backed features are available from the start. Do not initialize a nested repo inside an existing parent checkout.  
* For a new app scaffold, also create one project-local script/build_and_run.sh and .codex/environments/environment.toml so the Codex app Run button works immediately. Use the exact bootstrap contract from build-run-debug and its references/run-button-bootstrap.md file rather than inventing a second variant here.  
* Decide which state is app-wide, scene-scoped, or window-scoped before writing views.  
* Sketch file and module boundaries before writing the full UI. For any non-trivial app, create the folder structure first and split files by responsibility from the start.  
* Use a single Swift file only for tiny throwaway examples or snippets: roughly under 50 lines, one screen, no persistence, no networking/process client, and no reusable models. Anything beyond that should be multi-file immediately.  
* Use system-adaptive colors and materials by default (Color.primary, Color.secondary, semantic foreground styles, .regularMaterial, etc.) so the app follows Light/Dark mode automatically. Do not hardcode white or light backgrounds unless the user explicitly asks for a fixed theme, and do not reach for opaque windowBackgroundColor fills for root panes by default.  
* Pick the references for the first feature surface you need: windowing, commands, split layouts, or settings.  
New App File Structure  
For any non-trivial macOS app, start with this shape instead of putting the app, all views, models, stores, services, and helpers in one Swift file:  
* App/<AppName>App.swift: the @main app type and AppDelegate only.  
* Views/ContentView.swift: root layout and high-level composition only.  
* Views/SidebarView.swift, Views/DetailView.swift, Views/ComposerView.swift, etc.: feature views named after their primary type.  
* Models/*.swift: value models, identifiers, and selection enums.  
* Stores/*.swift: persistence and state stores.  
* Services/*.swift: app-server, network, process, or platform clients.  
* Support/*.swift: small formatters, resolvers, extensions, and glue helpers.  
Keep files small and named after the primary type they contain. If a file starts collecting unrelated views, models, stores, networking clients, and helper extensions, split it before adding more behavior.  
Pre-Edit Checklist For New App Scaffolds  
Before writing the full UI:  
1. Choose the scene model.  
2. Choose state ownership: app-wide, scene-scoped, window-scoped, or view-local.  
3. Sketch file and module boundaries.  
4. Create the folder structure before filling in the UI.  
5. Keep script/build_and_run.sh and .codex/environments/environment.toml separate from app source.  
General Rules To Follow  
* Design for pointer, keyboard, menus, and multiple windows.  
* Keep scenes explicit. A separate settings window, utility window, or menu bar extra should be modeled as its own scene, not hidden inside one monolithic ContentView.  
* Prefer system desktop affordances: commands, toolbars, sidebars, inspectors, contextual menus, and searchable.  
* For menu bar apps, keep MenuBarExtra item titles and action labels short and scannable. Cap visible menu item text at 30 characters; if source content is longer, truncate or summarize it before rendering and open the full content in a dedicated window or detail surface.  
* If a MenuBarExtra app should still behave like a regular Dock app with a visible main window/process, install an NSApplicationDelegate via @NSApplicationDelegateAdaptor, call NSApp.setActivationPolicy(.regular) during launch, and activate the app with NSApp.activate(ignoringOtherApps: true). If the app is intentionally menu-bar-only, document that .accessory / no-Dock behavior is a deliberate product choice.  
* Prefer system-adaptive colors, materials, and semantic foreground styles. Avoid fixed white/light backgrounds in scaffolding and examples unless the requested design explicitly calls for a custom non-adaptive theme.  
* Do not paint NavigationSplitView sidebars or root window panes with opaque custom Color(...) or Color(nsColor: .windowBackgroundColor) fills by default. Prefer native macOS sidebar/window materials and system-provided backgrounds unless the user explicitly asks for a custom opaque surface. In sidebar-detail-inspector layouts, let the sidebar keep the standard source-list/material appearance and reserve custom backgrounds for detail or inspector content cards where needed.  
* Use @SceneStorage for per-window ephemeral state and @AppStorage for durable user preferences.  
* Keep selection state explicit and stable. macOS layouts often pivot around sidebar selection rather than push navigation.  
* Prefer NavigationSplitView or a deliberate manual split layout over iOS-style stacked flows when the app benefits from always-visible structure.  
* For List(...).listStyle(.sidebar) and NavigationSplitView sidebars, prefer flat native rows with standard system selection/highlight behavior. Keep rows visually lightweight and Mail-like: at most one leading icon, one strong title line, and one optional secondary detail line in .secondary. Avoid stacked metadata rows, repeated inline utility icons, or dense multi-column status text in the sidebar. Reserve card-style and metadata-heavy surfaces for detail or inspector panes unless the user explicitly asks for a highly custom sidebar treatment.  
* Keep primary actions discoverable from both UI chrome and keyboard shortcuts when appropriate.  
* Use SwiftUI-native scenes and views first. If you need low-level window, responder-chain, text system, or panel control, switch to appkit-interop.  
Recommended Sidebar Row Pattern  
Prefer a native source-list row shape:  
```
List(selection: $selection) {
  ForEach(items) { item in
    HStack(spacing: 10) {
      Image(systemName: item.systemImage)
        .foregroundStyle(.secondary)
        .frame(width: 16)

      VStack(alignment: .leading, spacing: 2) {
        Text(item.title)
          .lineLimit(1)

        if let detail = item.detail {
          Text(detail)
            .font(.caption)
            .foregroundStyle(.secondary)
            .lineLimit(1)
        }
      }
    }
    .tag(item.id)
  }
}
.listStyle(.sidebar)

```
This keeps selection, highlight, spacing, and scanability aligned with standard macOS sidebars. Keep each row to one icon maximum and one or two text lines maximum, with the second line reserved for a short detail label. Use richer card treatments and denser metadata in the detail or inspector content, not in every sidebar row.  
Recommended Split-View Background Pattern  
Prefer letting the sidebar and split container use system backgrounds, while applying custom surfaces only to detail cards or inspector sections:  
```
NavigationSplitView {
  List(selection: $selection) {
    ForEach(items) { item in
      Label(item.title, systemImage: item.systemImage)
        .tag(item.id)
    }
  }
  .listStyle(.sidebar)
} detail: {
  ScrollView {
    VStack(alignment: .leading, spacing: 16) {
      DetailSummaryCard(item: selectedItem)
      DetailMetricsCard(item: selectedItem)
    }
    .padding()
  }
}

```
Avoid painting the sidebar and root split panes with opaque custom fills by default:  
```
NavigationSplitView {
  List(items) { item in
    SidebarCardRow(item: item)
  }
  .listStyle(.sidebar)
  .background(Color(nsColor: .windowBackgroundColor))
} detail: {
  DetailView(item: selectedItem)
    .background(Color(.white))
}

```
State Ownership Summary  
Use the narrowest state tool that matches the ownership model:  

| Scenario | Preferred pattern |
| ---------------------------------------------------- | ----------------------------------------------------------- |
| Local view or control state | @State |
| Child mutates parent-owned value state | @Binding |
| Root-owned reference model on macOS 14+ | @State with an @Observable type |
| Child reads or mutates an injected @Observable model | Pass it explicitly as a stored property |
| Window-scoped ephemeral selection or expansion state | @SceneStorage when practical, otherwise scene-owned @State |
| Shared user preference | @AppStorage |
| Shared app service or configuration | @Environment(Type.self) |
| Legacy reference model on older targets | @StateObject at the owner and @ObservedObject when injected |
  
Choose the ownership location first, then the wrapper. Do not turn simple desktop state into a view model by reflex.  
Cross-Cutting References  
* references/components-index.md: entry point for scene and component guidance.  
* references/windowing.md: choosing between WindowGroup, Window, DocumentGroup, and window-opening patterns.  
* references/settings.md: dedicated settings scenes, SettingsLink, and preference layouts.  
* references/commands-menus.md: command menus, keyboard shortcuts, focused values, and desktop action routing.  
* references/split-inspectors.md: sidebars, split views, selection-driven layout, and inspectors.  
* references/menu-bar-extra.md: menu bar extra structure and when it fits.  
Anti-Patterns  
* One huge ContentView pretending the whole app is a single screen.  
* A single Swift file containing the @main app, all views, models, stores, networking/process clients, formatters, and extensions. This is acceptable only for tiny throwaway snippets under the new-app threshold above.  
* Touch-first interaction models ported directly from iOS without desktop affordances.  
* Hiding core actions behind gestures with no menu, toolbar, or keyboard path.  
* Building a menu-bar-plus-window app around only a Window(...) scene and then expecting the main window to appear at launch. Use WindowGroup(..., id:) for the primary launch window and reserve Window(...) for auxiliary/on-demand windows.  
* Rendering full unbounded document titles, prompts, or message text directly inside a menu bar extra. Menu item labels should stay at or below 30 characters, with longer content moved into a dedicated window or detail view.  
* Treating settings as another navigation destination in the main content window.  
* Hardcoding .background(.white), Color.white, or a fixed light palette in a brand-new scaffold without an explicit design requirement.  
* Wrapping each sidebar item in large rounded custom cards inside a .sidebar list, which fights native source-list density, alignment, and selection behavior unless the user explicitly asked for a bespoke visual sidebar.  
* Building sidebar rows with multiple repeated icons, three or more text lines, or a dense strip of inline metadata counters/timestamps/models. Keep the sidebar row to one icon and one or two text lines, then move richer metadata into the detail pane.  
* Painting NavigationSplitView sidebars or root window panes with opaque custom color fills by default, instead of letting the sidebar use native source-list/material appearance and reserving custom backgrounds for actual content cards.  
* Using push navigation for layouts that want stable sidebar selection and detail panes.  
* Reaching for AppKit before the SwiftUI scene and command APIs have been used properly.  
Workflow For A New macOS Scene Or View  
1. Define the scene type and ownership model before writing child views.  
2. Decide which actions live in content, toolbars, commands, inspectors, or settings.  
3. Sketch the selection model and layout: sidebar-detail, editor-inspector, document window, or utility window.  
4. Create the file/folder structure for app entrypoint, root layout, feature views, models, stores, services, and support helpers.  
5. Build with small, focused subviews and explicit inputs rather than giant computed fragments.  
6. Add keyboard shortcuts and menu or toolbar exposure for actions that matter on desktop.  
7. Validate the flow with a build and a quick usability pass: multiwindow assumptions, settings entry points, and selection stability.  
Component References  
Use references/components-index.md as the entry point. Each component reference should include:  
* intent and best-fit scenarios  
* minimal usage pattern with desktop conventions  
* pitfalls and discoverability notes  
* when to fall back to appkit-interop  
  
  
Quick Start  
Use this skill to run the smallest meaningful test scope first, classify failures precisely, and avoid treating every test failure like a product bug.  
Workflow  
1. Detect the test harness.  
    * Use xcodebuild test for Xcode-based projects.  
    * Use swift test for SwiftPM packages.  
2. Narrow the scope.  
    * If the user gave a target, product, or test filter, use it.  
    * If not, prefer the smallest likely failing target before a full suite.  
3. Classify the result.  
    * Build failure  
    * Assertion failure  
    * Crash or signal  
    * Async timing or flake  
    * Environment or fixture setup issue  
    * Missing entitlement or host app issue  
4. Rerun intelligently.  
    * Use focused reruns when a specific case fails.  
    * Avoid burning time on full-suite reruns without new information.  
5. Summarize clearly.  
    * What command ran  
    * Which tests failed  
    * What kind of failure it was  
    * The best next proof step or fix path  
Guardrails  
* Distinguish compilation failures from test execution failures.  
* Call out when a test appears to assume iOS-only or simulator-only behavior.  
* Mark likely flakes as such instead of overstating confidence.  
Output Expectations  
Provide:  
* the command used  
* the smallest failing scope  
* the top failure category  
* a concise explanation of the likely cause  
* the next rerun or fix step  
  
  
Overview  
Refactor macOS views toward small, explicit, stable scene and view types. Default to native SwiftUI for layout, selection, commands, and settings. Reach for AppKit only at the narrow edges where desktop behavior truly requires it.  
Core Guidelines  
## 1) Model scenes explicitly  
* Break the app into meaningful scene roots: main window, settings, utility windows, inspectors, or menu bar extras.  
* Do not let one giant root view silently own every desktop surface.  
## 2) Keep a predictable file shape  
* Follow this ordering unless the file already has a stronger local convention:  
* Environment  
* private/public let  
* @State / other stored properties  
* computed var (non-view)  
* init  
* body  
* computed view builders / other view helpers  
* helper / async functions  
## 2b) Split files by responsibility  
* For non-trivial apps, do not keep the full app, all views, models, stores, networking clients, process clients, and helpers in one Swift file.  
* Accept a single Swift file only for tiny throwaway examples or snippets: roughly under 50 lines, one screen, no persistence, no networking/process client, and no reusable models.  
* Use App/<AppName>App.swift for the @main app and AppDelegate only.  
* Keep Views/ContentView.swift focused on root layout and composition; move feature UI into files such as Views/SidebarView.swift, Views/DetailView.swift, and Views/ComposerView.swift.  
* Move value types and selection enums into Models/*.swift, stores into Stores/*.swift, app-server/network/process clients into Services/*.swift, and small formatters/resolvers/extensions into Support/*.swift.  
* Keep files small and named after the primary type they contain.  
## 3) Prefer dedicated subview types over many computed some View fragments  
* Extract meaningful desktop sections like sidebar rows, detail panels, inspectors, or toolbar content into focused subviews.  
* Keep computed some View helpers small and rare.  
* Pass explicit data, bindings, and actions into subviews instead of handing down the whole scene model.  
## 4) Keep selection and layout stable  
* Prefer one stable split or window layout with local conditionals inside it.  
* Avoid top-level branch swapping between radically different roots when selection changes.  
* Let the layout be constant; let state drive the content inside it.  
## 5) Extract commands, toolbars, and actions out of body  
* Do not bury non-trivial button logic inline.  
* Do not mix command routing, menu state, and layout in the same block if they can be named clearly.  
* Keep body readable as UI, not as a desktop view controller.  
## 6) Use scene and app storage intentionally  
* Use @SceneStorage for per-window ephemeral state when it truly helps restore the scene.  
* Use @AppStorage for durable preferences, not transient UI toggles that only matter in one window.  
* Keep scene-owned state close to the scene root.  
## 7) Keep AppKit escape hatches narrow  
* If a representable or NSWindow bridge exists, isolate it behind a small wrapper or helper.  
* Do not let AppKit references spread through unrelated SwiftUI views.  
* If the bridge starts owning the feature, re-evaluate the architecture.  
## 8) Observation usage  
* For @Observable reference types on modern macOS targets, store them as @State in the owning view.  
* Pass observables explicitly to children.  
* On older deployment targets, fall back to @StateObject and @ObservedObject where needed.  
Workflow  
1. Identify the current scene boundary and whether the file is trying to do too much.  
2. Reorder the file into a predictable top-to-bottom structure.  
3. Extract desktop-specific sections into dedicated subview types.  
4. Stabilize the root layout around selection, scenes, and commands rather than top-level branching.  
5. Move action logic, command routing, and toolbar behavior into named helpers or separate types.  
6. Tighten any AppKit bridge so the imperative edge is small and explicit.  
7. Keep behavior intact unless the request explicitly asks for structural and behavioral changes together.  
Refactor Checklist  
* Split oversized view files before adding more UI.  
* Move pure models, identifiers, and selection enums out of view files.  
* Move Process, URLSession, app-server, and platform client code out of SwiftUI views into Services/.  
* Keep AppDelegate and the @main app entrypoint minimal.  
* Build after each major split so compile errors stay local.  
Common Smells  
* A root view that mixes window scaffolding, settings, toolbar code, command handling, and detail layout.  
* A single app file that mixes app entrypoint, root layout, feature views, models, stores, service clients, and support extensions.  
* iOS-style push navigation forced into a Mac sidebar-detail problem.  
* Several booleans for mutually exclusive inspectors, sheets, or utility windows.  
* AppKit objects passed through many SwiftUI layers without a clear ownership reason.  
* Large computed view fragments standing in for real subviews.  
Notes  
* A good macOS refactor should make scene structure, selection flow, and command ownership obvious.  
* When the problem is fundamentally a missing desktop pattern, use swiftui-patterns.  
* When the problem is fundamentally a boundary with AppKit, use appkit-interop.  
  
  
Overview  
Use this skill to tailor each SwiftUI window to its job. Start by identifying which scene owns the window (Window, WindowGroup, or a dedicated utility scene), then customize the toolbar/title area, background material, resize and restoration behavior, and initial or zoomed placement.  
Use this skill to tailor each SwiftUI window to its job. Start by identifying which scene owns the window (Window, WindowGroup, or a dedicated utility scene), then customize the toolbar/title area, background material, resize and restoration behavior, and initial or zoomed placement.  
Prefer scene and window modifiers over ad hoc AppKit bridges when SwiftUI offers the behavior directly. Keep each window purpose-built: a main browser window, an About window, and a media player window usually want different chrome, resizability, restoration, and placement rules.  
These APIs are macOS 15+ SwiftUI window/scene customizations. For older deployment targets, expect to use more AppKit bridging or availability guards.  
Workflow  
1. Inspect the relevant scene declaration and classify the window role: main app navigation, inspector/detail utility, About/support window, media playback window, welcome window, or a borderless custom surface.  
2. Adjust toolbar and title presentation to match the content.  
3. If the toolbar background or entire toolbar is hidden, make sure the window still has a usable drag region.  
4. Refine window behavior for that role: minimize availability, restoration, resize expectations, and whether the window should appear at launch.  
5. Set default placement for newly opened windows and ideal placement for zoom behavior when content and display size matter.  
6. Build and launch the app with build-run-debug to verify the result in a real foreground .app bundle.  
7. If SwiftUI scene/window modifiers are not enough, switch to appkit-interop for a narrow NSWindow bridge rather than spreading AppKit through the view tree.  
Toolbar And Title  
* Use .toolbar(removing: .title) when the window title should stay associated with the window for accessibility and menus, but not be visibly drawn in the title bar.  
* Use .toolbarBackgroundVisibility(.hidden, for: .windowToolbar) when large media or hero content should visually extend to the top edge of the window.  
* If the window still needs close/minimize/full-screen controls, remove only the title and toolbar background. If the toolbar should disappear entirely, use .toolbarVisibility(.hidden, for: .windowToolbar) instead.  
* Remove custom toolbar backgrounds and manually painted titlebar fills before layering new SwiftUI toolbar APIs on top.  
* Keep the window's logical title meaningful even if hidden; the system can still use it for accessibility and menu items. These are visual changes only.  
Drag Regions  
* If a toolbar background is hidden or the toolbar is removed entirely, use WindowDragGesture() to extend the draggable area into your content.  
* Attach the gesture to a transparent overlay or non-interactive header region that does not steal gestures from real controls.  
* For a media player with custom playback controls, insert the drag overlay between the video content and the controls so AVKit or transport controls keep receiving input.  
* Pair the drag gesture with .allowsWindowActivationEvents(true) so clicking and immediately dragging a background window still activates and moves it.  
Background And Materials  
* Use .containerBackground(.thickMaterial, for: .window) when a utility window or About window should replace the default window background with a subtle frosted material.  
* Prefer system materials for stylized windows instead of hardcoded translucent colors.  
* Use this especially for fixed-content utility windows where a softer backdrop is part of the design.  
Window Behavior  
* Use .windowMinimizeBehavior(.disabled) for always-reachable utility windows such as a custom About window where minimizing adds little value.  
* Disable the green zoom control through fixed sizing or window constraints when the window's content has one intended size.  
* Use .restorationBehavior(.disabled) for windows that should not reopen on next launch, such as About panels, transient support/info windows, or first-run welcome surfaces.  
* Keep state restoration enabled for primary document or navigation windows when reopening prior size and position is desirable.  
* By default, SwiftUI respects the user's system-wide macOS state restoration setting. Use restorationBehavior(...) only when a specific window should intentionally opt into or out of that system behavior.  
* Use .defaultLaunchBehavior(.presented) for windows that should appear first on launch, such as a welcome window, and choose that behavior intentionally rather than relying on side effects from scene creation order.  
Window Placement  
* Use .defaultWindowPlacement { content, context in ... } to control the initial size and optional position of newly opened windows.  
* Inside the placement closure, call content.sizeThatFits(.unspecified) to get the content's ideal size.  
* Read context.defaultDisplay.visibleRect to get the display's usable region after accounting for the menu bar and Dock.  
* Return WindowPlacement(size: size) with a size clamped to the visible rect when media or document content may be larger than the display. If no position is provided, the window is centered by default.  
* Use .windowIdealPlacement { content, context in ... } to control what happens when the user chooses Zoom from the Window menu or Option-clicks the green toolbar button. For media windows, preserve aspect ratio and grow to the largest size that fits the display.  
* Treat default placement and ideal placement as separate policies:  
    * default placement controls where a new window first appears,  
    * ideal placement controls how large a zoomed window should become.  
* Always consider external displays and rotated/narrow screens when sizing player windows or document windows from content dimensions.  
Borderless And Specialized Windows  
* Use .windowStyle(.plain) for borderless or highly custom chrome windows, but make sure the content still provides a clear drag/move affordance and visible context.  
* For a borderless player, HUD, or welcome window, decide upfront whether losing standard titlebar affordances is worth the custom presentation.  
* Keep one clear path back to regular window management if the plain style makes the window feel invisible or hard to move.  
API Snippets  
```
WindowGroup("Destination Video") {
  
```
```
CatalogView()

```
```
    .toolbar(removing: .title)
    .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
}
Window
```
```
("About", id: "about") {

```
```
  
```
```
AboutView()

```
```
    .toolbar(removing: .title)
    .toolbarBackgroundVisibility(.hidden, for: .windowToolbar)
    .containerBackground(.thickMaterial, for: .window)
}
.windowMinimizeBehavior(.disabled)
.restorationBehavior(.disabled)
WindowGroup
```
```
("Player", for: Video.self) { $video in

```
```
  
```
```
PlayerView(video: video)

```
```
}
.defaultWindowPlacement { content, context in
  
```
```
let idealSize = content.sizeThatFits(.unspecified)

```
```
  
```
```
let displayBounds = context.defaultDisplay.visibleRect

```
```
  let fittedSize = clampToDisplay(idealSize, displayBounds: displayBounds)
  return WindowPlacement(size: fittedSize)
}
.windowIdealPlacement { content, context in
  let idealSize = content.sizeThatFits(.unspecified)
  
```
```
let displayBounds = context.defaultDisplay.visibleRect

```
```
  
```
```
let zoomedSize = zoomToFit(idealSize, displayBounds: displayBounds)

```
```
  
```
```
let position = centeredPosition(for: zoomedSize, in: displayBounds)

```
```
  return WindowPlacement(position, size: zoomedSize)
}
PlayerView
```
```
(video: video)

```
```
  .overlay(alignment: .top) {
    
```
```
Color.clear

```
```
      .frame(height: 48)
      .contentShape(Rectangle())
      .gesture(
```
```
WindowDragGesture())

```
```
      .allowsWindowActivationEvents(true)
  }
Window
```
```
("Welcome", id: "welcome") {

```
```
  
```
```
WelcomeView()

```
```
}
.windowStyle(.plain)
.defaultLaunchBehavior(.presented)

```
Review Checklist  
* The scene type matches the window's role and lifecycle.  
* Hidden titles still leave a meaningful logical title for accessibility and menus.  
* Toolbar background removal is intentional and does not hurt titlebar legibility or window control placement.  
* Windows with hidden or removed toolbars still have a reliable drag region and support click-then-drag activation from the background.  
* Utility windows have restoration/minimize behavior that matches their purpose.  
* Restoration overrides are used only when a scene should intentionally differ from the user's system-wide setting.  
* Default and ideal placement use content.sizeThatFits(.unspecified) and context.defaultDisplay.visibleRect when content/display size matters.  
* Media windows preserve aspect ratio and fit on small or rotated displays.  
* Borderless windows still have a usable move/drag affordance.  
Guardrails  
* Do not use .toolbar(removing: .title) just to hide a title you forgot to set. Keep the underlying window title meaningful.  
* Do not hide the toolbar background or the whole toolbar without replacing the lost drag affordance.  
* Do not disable restoration on the main document/navigation window unless the user explicitly wants a fresh-start app every launch.  
* Do not hardcode one monitor size or assume a single-display setup when sizing player windows.  
* Do not reach for NSWindow mutation before checking whether .windowMinimizeBehavior, .restorationBehavior, .defaultWindowPlacement, .windowIdealPlacement, .windowStyle, or .defaultLaunchBehavior already solve the problem.  
* Do not leave a plain borderless window without any obvious drag or close path.  
When To Use Other Skills  
* Use swiftui-patterns for broader scene, commands, settings, sidebar, and inspector architecture.  
* Use liquid-glass when the main question is modern macOS visual treatment, Liquid Glass, or system material adoption.  
* Use appkit-interop if a custom window behavior truly requires NSWindow, NSPanel, or responder-chain control.  
* Use build-run-debug to launch and verify the resulting windows.  
