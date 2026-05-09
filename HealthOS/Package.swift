// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v26)],
    products: [
        // ── Tier 1 — Mestral Core ───────────────────────────────────────────
        .library(name: "HealthOSCore",            targets: ["HealthOSCore"]),

        // ── Tier 2 — GOS / Runtimes ────────────────────────────────────────
        // HealthOSProviders is the runtime provider-adapter module.
        // HealthOS/Support holds governed ops/Python/ML tooling, not runtime imports.
        .library(name: "HealthOSProviders",        targets: ["HealthOSProviders"]),
        .library(name: "HealthOSGOS",              targets: ["HealthOSGOS"]),
        .library(name: "HealthOSAACI",             targets: ["HealthOSAACI"]),
        .library(name: "HealthOSMSR",              targets: ["HealthOSMSR"]),
        .library(name: "HealthOSAsyncRuntime",     targets: ["HealthOSAsyncRuntime"]),
        .library(name: "HealthOSUserAgentRuntime", targets: ["HealthOSUserAgentRuntime"]),
        .library(name: "HealthOSServiceRuntime",   targets: ["HealthOSServiceRuntime"]),
        .library(name: "HealthOSSessionRuntime",   targets: ["HealthOSSessionRuntime"]),

        // ── Tier 3 — Custom Boundary ───────────────────────────────────────
        .library(name: "CustomSDK",                targets: ["CustomSDK"]),
        .library(name: "HealthOSBoundary",         targets: ["HealthOSBoundary"]),

        // ── Operator CLI (not a Stage) ─────────────────────────────────────
        .executable(name: "HealthOSCLI",           targets: ["HealthOSCLI"]),

        // Tier 4 Stages are intentionally not products of this platform package.
        // Each Stage owns its package under Tier4-Stages-Cast/<Stage>/Package.swift.
    ],
    targets: [

        // ── Tier 1 — Mestral Core ───────────────────────────────────────────
        .target(name: "HealthOSCore",
                path: "Tier1-Mestral-Core/Sources/HealthOSCore",
                exclude: ["README.md"]),

        // ── Tier 2 — GOS / Runtimes ────────────────────────────────────────
        .target(name: "HealthOSProviders",
                dependencies: ["HealthOSCore"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSProviders",
                exclude: ["README.md"]),
        // GOS files currently live in HealthOSAACI; this is the canonical target for migration.
        .target(name: "HealthOSGOS",
                dependencies: ["HealthOSCore"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSGOS",
                exclude: ["README.md"]),
        .target(name: "HealthOSAACI",
                dependencies: ["HealthOSCore", "HealthOSGOS", "HealthOSProviders"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSAACI",
                exclude: ["README.md"]),
        .target(name: "HealthOSMSR",
                dependencies: ["HealthOSCore", "HealthOSProviders"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSMSR",
                exclude: ["README.md"],
                resources: [.copy("Prompts")]),
        .target(name: "HealthOSAsyncRuntime",
                dependencies: ["HealthOSCore"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSAsyncRuntime",
                exclude: ["README.md"]),
        .target(name: "HealthOSUserAgentRuntime",
                dependencies: ["HealthOSCore", "HealthOSProviders"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSUserAgentRuntime",
                exclude: ["README.md"]),
        .target(name: "HealthOSServiceRuntime",
                dependencies: ["HealthOSCore"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSServiceRuntime",
                exclude: ["README.md"]),
        .target(name: "HealthOSSessionRuntime",
                dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders", "HealthOSMSR"],
                path: "Tier2-GOS-Runtimes/Sources/HealthOSSessionRuntime"),

        // ── Tier 3 — Custom Boundary ───────────────────────────────────────
        .target(name: "CustomSDK",
                dependencies: ["HealthOSCore"],
                path: "Tier3-Custom-Boundary/Sources/CustomSDK",
                exclude: ["README.md"]),
        // Stages must only import HealthOSBoundary, never Tier 2 modules directly.
        .target(name: "HealthOSBoundary",
                dependencies: [
                    "CustomSDK",
                    "HealthOSCore",
                    "HealthOSGOS",
                    "HealthOSAACI",
                    "HealthOSMSR",
                    "HealthOSAsyncRuntime",
                    "HealthOSUserAgentRuntime",
                    "HealthOSServiceRuntime",
                    "HealthOSSessionRuntime",
                ],
                path: "Tier3-Custom-Boundary/Sources/HealthOSBoundary",
                exclude: ["README.md"]),

        // ── Operator CLI ─────────────────────────────────────────────────────
        .executableTarget(name: "HealthOSCLI",
                          dependencies: ["HealthOSCore", "HealthOSSessionRuntime"],
                          path: "Shared/Sources/HealthOSCLI"),

        // ── Tests ────────────────────────────────────────────────────────────
        .testTarget(name: "HealthOSCoreTests",
                    dependencies: ["HealthOSCore"],
                    path: "Tier1-Mestral-Core/Tests/HealthOSCoreTests"),
        .testTarget(name: "HealthOSRuntimeTests",
                    dependencies: [
                        "HealthOSCore",
                        "HealthOSGOS",
                        "HealthOSAACI",
                        "HealthOSProviders",
                        "HealthOSMSR",
                        "HealthOSAsyncRuntime",
                        "HealthOSUserAgentRuntime",
                        "HealthOSServiceRuntime",
                        "HealthOSSessionRuntime",
                    ],
                    path: "Tier2-GOS-Runtimes/Tests/HealthOSRuntimeTests"),
        .testTarget(name: "HealthOSBoundaryTests",
                    dependencies: ["HealthOSBoundary", "CustomSDK"],
                    path: "Tier3-Custom-Boundary/Tests/HealthOSBoundaryTests"),
        .testTarget(name: "StagePackageStructureTests",
                    path: "Tier4-Stages-Cast/Tests/StagePackageStructureTests"),
        .testTarget(name: "HealthOSConstructionSystemTests",
                    path: "Constructor/Tests/HealthOSConstructionSystemTests"),
        .testTarget(name: "HealthOSSupportToolingTests",
                    path: "Support/Tests/HealthOSSupportToolingTests"),
        // Existing integration tests — migrate to per-module targets incrementally.
        .testTarget(name: "HealthOSTests",
                    dependencies: [
                        "HealthOSCore",
                        "HealthOSAACI",
                        "HealthOSProviders",
                        "HealthOSMSR",
                        "HealthOSSessionRuntime",
                    ],
                    path: "Shared/Tests/HealthOSTests"),
    ]
)
