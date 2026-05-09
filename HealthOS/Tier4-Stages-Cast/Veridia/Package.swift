// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "Veridia",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "Veridia", targets: ["Veridia"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "Veridia",
            dependencies: [
                .product(name: "HealthOSBoundary", package: "HealthOS"),
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Sources/Veridia",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "VeridiaTests",
            dependencies: [
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Tests/VeridiaTests"
        )
    ]
)
