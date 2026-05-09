// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Scribe",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "Scribe", targets: ["Scribe"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "Scribe",
            dependencies: [
                .product(name: "HealthOSBoundary", package: "HealthOS"),
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Sources/Scribe",
            exclude: ["README.md"],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "ScribeTests",
            dependencies: [
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Tests/ScribeTests"
        )
    ]
)
