// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v26)],
    products: [
        // ── Tier 1 — Platform/Core ──────────────────────────────────────────
        .library(name: "HealthOSCore",            targets: ["HealthOSCore"]),

        // ── Tier 2 — Runtime/Mediation ─────────────────────────────────────
        .library(name: "HealthOSProviders",        targets: ["HealthOSProviders"]),
        .library(name: "HealthOSGOS",              targets: ["HealthOSGOS"]),
        .library(name: "HealthOSAACI",             targets: ["HealthOSAACI"]),
        .library(name: "HealthOSMSR",              targets: ["HealthOSMSR"]),
        .library(name: "HealthOSAsyncRuntime",     targets: ["HealthOSAsyncRuntime"]),
        .library(name: "HealthOSUserAgentRuntime", targets: ["HealthOSUserAgentRuntime"]),
        .library(name: "HealthOSServiceRuntime",   targets: ["HealthOSServiceRuntime"]),
        .library(name: "HealthOSSessionRuntime",   targets: ["HealthOSSessionRuntime"]),

        // ── Tier 3 — Boundary ──────────────────────────────────────────────
        .library(name: "HealthOSAppBoundary",      targets: ["HealthOSAppBoundary"]),

        // ── Operator CLI (not a Stage) ─────────────────────────────────────
        .executable(name: "HealthOSCLI",           targets: ["HealthOSCLI"]),

        // ── Tier 4 — Stages ────────────────────────────────────────────────
        .executable(name: "HealthOSScribeApp",      targets: ["HealthOSScribeApp"]),
        .executable(name: "HealthOSVeridiaApp",     targets: ["HealthOSVeridiaApp"]),
        .executable(name: "HealthOSCloudClinicApp", targets: ["HealthOSCloudClinicApp"]),
    ],
    targets: [

        // ── Tier 1 ──────────────────────────────────────────────────────────
        .target(name: "HealthOSCore"),

        // ── Tier 2 ──────────────────────────────────────────────────────────
        .target(name: "HealthOSProviders",
                dependencies: ["HealthOSCore"]),
        // GOS files currently live in HealthOSAACI; this is the canonical target for migration.
        .target(name: "HealthOSGOS",
                dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSAACI",
                dependencies: ["HealthOSCore", "HealthOSGOS", "HealthOSProviders"]),
        .target(name: "HealthOSMSR",
                dependencies: ["HealthOSCore", "HealthOSProviders"],
                resources: [.copy("Prompts")]),
        .target(name: "HealthOSAsyncRuntime",
                dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSUserAgentRuntime",
                dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSServiceRuntime",
                dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSSessionRuntime",
                dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders", "HealthOSMSR"]),

        // ── Tier 3 ──────────────────────────────────────────────────────────
        // Stages must only import HealthOSAppBoundary, never Tier 2 modules directly.
        .target(name: "HealthOSAppBoundary",
                dependencies: [
                    "HealthOSCore",
                    "HealthOSGOS",
                    "HealthOSAACI",
                    "HealthOSMSR",
                    "HealthOSAsyncRuntime",
                    "HealthOSUserAgentRuntime",
                    "HealthOSServiceRuntime",
                    "HealthOSSessionRuntime",
                ]),

        // ── Operator CLI ─────────────────────────────────────────────────────
        .executableTarget(name: "HealthOSCLI",
                          dependencies: ["HealthOSCore", "HealthOSSessionRuntime"]),

        // ── Tier 4 — Stages ─────────────────────────────────────────────────
        // TODO: depend solely on HealthOSAppBoundary once its session facade is complete.
        .executableTarget(name: "HealthOSScribeApp",
                          dependencies: ["HealthOSAppBoundary", "HealthOSSessionRuntime"],
                          resources: [.process("Resources")]),
        // TODO: remove HealthOSCore once VeridiaSession types migrate into HealthOSAppBoundary.
        .executableTarget(name: "HealthOSVeridiaApp",
                          dependencies: ["HealthOSAppBoundary", "HealthOSCore"],
                          resources: [.process("Resources")]),
        .executableTarget(name: "HealthOSCloudClinicApp",
                          dependencies: ["HealthOSAppBoundary"],
                          resources: [.process("Resources")]),

        // ── Tests ────────────────────────────────────────────────────────────
        .testTarget(name: "HealthOSCoreTests",
                    dependencies: ["HealthOSCore"]),
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
                    ]),
        .testTarget(name: "HealthOSAppBoundaryTests",
                    dependencies: ["HealthOSAppBoundary"]),
        // Existing integration tests — migrate to per-module targets incrementally.
        .testTarget(name: "HealthOSTests",
                    dependencies: [
                        "HealthOSCore",
                        "HealthOSAACI",
                        "HealthOSProviders",
                        "HealthOSMSR",
                        "HealthOSSessionRuntime",
                    ]),
    ]
)
