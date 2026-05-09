// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v26)],
    products: [
        // ── Tier 1 — Mestral Core ───────────────────────────────────────────
        .library(name: "HealthOSCore",            targets: ["HealthOSCore"]),

        // ── Tier 2 — GOS / Runtimes ────────────────────────────────────────
        .library(name: "HealthOSProviders",        targets: ["HealthOSProviders"]),
        .library(name: "HealthOSGOS",              targets: ["HealthOSGOS"]),
        .library(name: "HealthOSAACI",             targets: ["HealthOSAACI"]),
        .library(name: "HealthOSMSR",              targets: ["HealthOSMSR"]),
        .library(name: "HealthOSAsyncRuntime",     targets: ["HealthOSAsyncRuntime"]),
        .library(name: "HealthOSUserAgentRuntime", targets: ["HealthOSUserAgentRuntime"]),
        .library(name: "HealthOSServiceRuntime",   targets: ["HealthOSServiceRuntime"]),
        .library(name: "HealthOSSessionRuntime",   targets: ["HealthOSSessionRuntime"]),

        // ── Tier 3 — Custom Boundary ───────────────────────────────────────
        .library(name: "HealthOSBoundary",         targets: ["HealthOSBoundary"]),

        // ── Operator CLI (not a Stage) ─────────────────────────────────────
        .executable(name: "HealthOSCLI",           targets: ["HealthOSCLI"]),

        // ── Tier 4 — Stages Cast ───────────────────────────────────────────
        .executable(name: "HealthOSScribeStage",      targets: ["HealthOSScribeStage"]),
        .executable(name: "HealthOSVeridiaStage",     targets: ["HealthOSVeridiaStage"]),
        .executable(name: "HealthOSCloudClinicStage", targets: ["HealthOSCloudClinicStage"]),
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
                dependencies: ["HealthOSCore"],
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
        // Stages must only import HealthOSBoundary, never Tier 2 modules directly.
        .target(name: "HealthOSBoundary",
                dependencies: [
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

        // ── Tier 4 — Stages Cast ───────────────────────────────────────────
        // HealthOSBoundary is the primary Stage surface.
        // TODO: remove direct Tier 1/2 dependencies once the Scribe session facade is complete in Boundary.
        .executableTarget(name: "HealthOSScribeStage",
                          dependencies: ["HealthOSBoundary", "HealthOSCore", "HealthOSSessionRuntime"],
                          path: "Tier4-Stages-Cast/Scribe/Sources/HealthOSScribeStage",
                          exclude: ["README.md"],
                          resources: [.process("Resources")]),
        // HealthOSBoundary is the primary Stage surface.
        // TODO: remove HealthOSCore once VeridiaSession types migrate into HealthOSBoundary.
        .executableTarget(name: "HealthOSVeridiaStage",
                          dependencies: ["HealthOSBoundary", "HealthOSCore"],
                          path: "Tier4-Stages-Cast/Veridia/Sources/HealthOSVeridiaStage",
                          resources: [.process("Resources")]),
        .executableTarget(name: "HealthOSCloudClinicStage",
                          dependencies: ["HealthOSBoundary"],
                          path: "Tier4-Stages-Cast/CloudClinic/Sources/HealthOSCloudClinicStage",
                          resources: [.process("Resources")]),

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
                    dependencies: ["HealthOSBoundary"],
                    path: "Tier3-Custom-Boundary/Tests/HealthOSBoundaryTests"),
        .testTarget(name: "HealthOSStageSmokeTests",
                    path: "Tier4-Stages-Cast/Tests/HealthOSStageSmokeTests"),
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
