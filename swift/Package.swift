// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "HealthOSCore", targets: ["HealthOSCore"]),
        .library(name: "HealthOSAACI", targets: ["HealthOSAACI"]),
        .library(name: "HealthOSProviders", targets: ["HealthOSProviders"]),
        .library(name: "HealthOSFirstSliceSupport", targets: ["HealthOSFirstSliceSupport"]),
        .executable(name: "HealthOSCLI", targets: ["HealthOSCLI"]),
        .executable(name: "HealthOSScribeApp", targets: ["HealthOSScribeApp"])
    ],
    targets: [
        .target(name: "HealthOSCore"),
        .target(name: "HealthOSProviders", dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSAACI", dependencies: ["HealthOSCore", "HealthOSProviders"]),
        .target(name: "HealthOSFirstSliceSupport", dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders"]),
        .executableTarget(name: "HealthOSCLI", dependencies: ["HealthOSCore", "HealthOSFirstSliceSupport"]),
        .executableTarget(name: "HealthOSScribeApp", dependencies: ["HealthOSCore", "HealthOSFirstSliceSupport"])
    ]
)
