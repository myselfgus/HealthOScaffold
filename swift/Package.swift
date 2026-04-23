// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v14)],
    products: [
        .library(name: "HealthOSCore", targets: ["HealthOSCore"]),
        .library(name: "HealthOSAACI", targets: ["HealthOSAACI"]),
        .library(name: "HealthOSProviders", targets: ["HealthOSProviders"]),
        .executable(name: "HealthOSCLI", targets: ["HealthOSCLI"])
    ],
    targets: [
        .target(name: "HealthOSCore"),
        .target(name: "HealthOSProviders", dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSAACI", dependencies: ["HealthOSCore", "HealthOSProviders"]),
        .executableTarget(name: "HealthOSCLI", dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders"])
    ]
)
