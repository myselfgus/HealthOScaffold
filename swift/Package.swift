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
        .library(name: "HealthOSBoundary",         targets: ["HealthOSBoundary"]),

        // ── Operator CLI (not a Stage) ─────────────────────────────────────
        .executable(name: "HealthOSCLI",           targets: ["HealthOSCLI"]),

        // ── Tier 4 — Stages ────────────────────────────────────────────────
        .executable(name: "HealthOSScribeStage",      targets: ["HealthOSScribeStage"]),
        .executable(name: "HealthOSVeridiaStage",     targets: ["HealthOSVeridiaStage"]),
        .executable(name: "HealthOSCloudClinicStage", targets: ["HealthOSCloudClinicStage"]),
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
                ]),

        // ── Operator CLI ─────────────────────────────────────────────────────
        .executableTarget(name: "HealthOSCLI",
                          dependencies: ["HealthOSCore", "HealthOSSessionRuntime"]),

        // ── Tier 4 — Stages ─────────────────────────────────────────────────
        // HealthOSBoundary is the primary Stage surface.
        // TODO: remove direct Tier 1/2 dependencies once the Scribe session facade is complete in Boundary.
        .executableTarget(name: "HealthOSScribeStage",
                          dependencies: ["HealthOSBoundary", "HealthOSCore", "HealthOSSessionRuntime"],
                          resources: [.process("Resources")]),
        // HealthOSBoundary is the primary Stage surface.
        // TODO: remove HealthOSCore once VeridiaSession types migrate into HealthOSBoundary.
        .executableTarget(name: "HealthOSVeridiaStage",
                          dependencies: ["HealthOSBoundary", "HealthOSCore"],
                          resources: [.process("Resources")]),
        .executableTarget(name: "HealthOSCloudClinicStage",
                          dependencies: ["HealthOSBoundary"],
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
        .testTarget(name: "HealthOSBoundaryTests",
                    dependencies: ["HealthOSBoundary"]),
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
