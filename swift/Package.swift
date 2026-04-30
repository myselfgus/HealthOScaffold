// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "HealthOS",
    platforms: [.macOS(.v26)],
    products: [
        .library(name: "HealthOSCore", targets: ["HealthOSCore"]),
        .library(name: "HealthOSAACI", targets: ["HealthOSAACI"]),
        .library(name: "HealthOSProviders", targets: ["HealthOSProviders"]),
        .library(name: "HealthOSMentalSpace", targets: ["HealthOSMentalSpace"]),
        .library(name: "HealthOSSessionRuntime", targets: ["HealthOSSessionRuntime"]),
        .executable(name: "HealthOSCLI", targets: ["HealthOSCLI"]),
        .executable(name: "HealthOSScribeApp", targets: ["HealthOSScribeApp"]),
        .executable(name: "HealthOSSortioApp", targets: ["HealthOSSortioApp"]),
        .executable(name: "HealthOSCloudClinicApp", targets: ["HealthOSCloudClinicApp"])
    ],
    targets: [
        .target(name: "HealthOSCore"),
        .target(name: "HealthOSProviders", dependencies: ["HealthOSCore"]),
        .target(name: "HealthOSAACI", dependencies: ["HealthOSCore", "HealthOSProviders"]),
        .target(name: "HealthOSMentalSpace", dependencies: ["HealthOSCore", "HealthOSProviders"],
                resources: [.copy("Prompts")]),
        .target(name: "HealthOSSessionRuntime", dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders"]),
        .executableTarget(name: "HealthOSCLI", dependencies: ["HealthOSCore", "HealthOSSessionRuntime"]),
        .executableTarget(name: "HealthOSScribeApp", dependencies: ["HealthOSCore", "HealthOSSessionRuntime"]),
        .executableTarget(name: "HealthOSSortioApp", dependencies: ["HealthOSCore"]),
        .executableTarget(name: "HealthOSCloudClinicApp", dependencies: ["HealthOSCore"]),
        .testTarget(
            name: "HealthOSTests",
            dependencies: ["HealthOSCore", "HealthOSAACI", "HealthOSProviders", "HealthOSMentalSpace", "HealthOSSessionRuntime"]
        )
    ]
)
