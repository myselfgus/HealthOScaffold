// PackageTargetsExplorer.swift
//
// Demonstrates and explores the `targets` array defined in HealthOS/Package.swift.
//
// Package.swift uses PackageDescription, which is only available during SPM
// manifest resolution and cannot be imported in regular Swift code. This
// playground reconstructs the target graph using plain Swift types so you can
// interactively inspect it.
//
// Run with: cd HealthOS/Xcode && swift PackageTargetsExplorer.swift

struct TargetSpec {
    enum Kind: Equatable { case library, executable, test }
    let name: String
    let kind: Kind
    let dependencies: [String]
    let resources: [String]
}

// Mirrors the target graph from HealthOS/Package.swift.
let targets: [TargetSpec] = [
    .init(name: "HealthOSCore",            kind: .library,     dependencies: [],                                                                    resources: []),
    .init(name: "HealthOSProviders",       kind: .library,     dependencies: ["HealthOSCore"],                                                      resources: []),
    .init(name: "HealthOSGOS",             kind: .library,     dependencies: ["HealthOSCore"],                                                      resources: []),
    .init(name: "HealthOSAACI",            kind: .library,     dependencies: ["HealthOSCore", "HealthOSGOS", "HealthOSProviders"],                 resources: []),
    .init(name: "HealthOSMSR",             kind: .library,     dependencies: ["HealthOSCore", "HealthOSProviders"],                                  resources: ["Prompts"]),
    .init(name: "HealthOSAsyncRuntime",    kind: .library,     dependencies: ["HealthOSCore"],                                                      resources: []),
    .init(name: "HealthOSUserAgentRuntime", kind: .library,    dependencies: ["HealthOSCore"],                                                      resources: []),
    .init(name: "HealthOSServiceRuntime",  kind: .library,     dependencies: ["HealthOSCore"],                                                      resources: []),
    .init(name: "HealthOSSessionRuntime",  kind: .library,     dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders", "HealthOSMSR"],  resources: []),
    .init(name: "HealthOSBoundary",        kind: .library,     dependencies: ["HealthOSCore", "HealthOSGOS", "HealthOSAACI", "HealthOSMSR", "HealthOSAsyncRuntime", "HealthOSUserAgentRuntime", "HealthOSServiceRuntime", "HealthOSSessionRuntime"], resources: []),
    .init(name: "HealthOSCLI",             kind: .executable,  dependencies: ["HealthOSCore", "HealthOSSessionRuntime"],                            resources: []),
    .init(name: "HealthOSScribeStage",     kind: .executable,  dependencies: ["HealthOSBoundary", "HealthOSCore", "HealthOSSessionRuntime"],        resources: ["Resources"]),
    .init(name: "HealthOSVeridiaStage",    kind: .executable,  dependencies: ["HealthOSBoundary", "HealthOSCore"],                                  resources: ["Resources"]),
    .init(name: "HealthOSCloudClinicStage", kind: .executable, dependencies: ["HealthOSBoundary"],                                                   resources: ["Resources"]),
    .init(name: "HealthOSCoreTests",       kind: .test,        dependencies: ["HealthOSCore"],                                                       resources: []),
    .init(name: "HealthOSRuntimeTests",    kind: .test,        dependencies: ["HealthOSCore", "HealthOSGOS", "HealthOSAACI", "HealthOSProviders", "HealthOSMSR", "HealthOSAsyncRuntime", "HealthOSUserAgentRuntime", "HealthOSServiceRuntime", "HealthOSSessionRuntime"], resources: []),
    .init(name: "HealthOSBoundaryTests",   kind: .test,        dependencies: ["HealthOSBoundary"],                                                   resources: []),
    .init(name: "HealthOSStageSmokeTests", kind: .test,        dependencies: [],                                                                     resources: []),
    .init(name: "HealthOSTests",           kind: .test,        dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders", "HealthOSMSR", "HealthOSSessionRuntime"], resources: []),
]

#Playground {
    // ── 1. List all targets by kind ──────────────────────────────────────────
    print("=== Targets by kind ===")
    for kind in [TargetSpec.Kind.library, .executable, .test] {
        let group = targets.filter { $0.kind == kind }
        let label = kind == .library ? "Library" : kind == .executable ? "Executable" : "Test"
        print("\n\(label) targets (\(group.count)):")
        group.forEach { print("  • \($0.name)") }
    }

    // ── 2. Dependency graph ───────────────────────────────────────────────────
    print("\n\n=== Dependency graph ===")
    for t in targets {
        if t.dependencies.isEmpty {
            print("\(t.name)  (no dependencies — root module)")
        } else {
            print("\(t.name)  →  \(t.dependencies.joined(separator: ", "))")
        }
    }

    // ── 3. Which targets depend on HealthOSCore? ─────────────────────────────
    let coreConsumers = targets.filter { $0.dependencies.contains("HealthOSCore") }
    print("\n\n=== Targets that depend on HealthOSCore (\(coreConsumers.count)) ===")
    coreConsumers.forEach { print("  • \($0.name)") }

    // ── 4. Reverse-lookup: what depends on HealthOSSessionRuntime? ────────────
    let runtimeConsumers = targets.filter { $0.dependencies.contains("HealthOSSessionRuntime") }
    print("\n\n=== Consumers of HealthOSSessionRuntime ===")
    if runtimeConsumers.isEmpty {
        print("  (none in the package graph — it is consumed at the Stage / test boundary)")
    } else {
        runtimeConsumers.forEach { print("  • \($0.name)") }
    }

    // ── 5. Targets with embedded resources ────────────────────────────────────
    let withResources = targets.filter { !$0.resources.isEmpty }
    print("\n\n=== Targets with resources ===")
    withResources.forEach { print("  • \($0.name): \($0.resources.joined(separator: ", "))") }

    // ── 6. Depth from HealthOSCore (manual BFS) ───────────────────────────────
    print("\n\n=== Dependency depth from HealthOSCore ===")
    func depth(of targetName: String, memo: inout [String: Int]) -> Int {
        if let cached = memo[targetName] { return cached }
        guard let t = targets.first(where: { $0.name == targetName }) else { return 0 }
        if t.dependencies.isEmpty { memo[targetName] = 0; return 0 }
        let d = 1 + (t.dependencies.map { depth(of: $0, memo: &memo) }.max() ?? 0)
        memo[targetName] = d
        return d
    }
    var memo: [String: Int] = [:]
    for t in targets.sorted(by: { $0.name < $1.name }) {
        print("  \(t.name): depth \(depth(of: t.name, memo: &memo))")
    }
}
