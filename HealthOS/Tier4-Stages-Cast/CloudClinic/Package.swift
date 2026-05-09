// swift-tools-version: 6.2
import PackageDescription

let package = Package(
    name: "CloudClinic",
    platforms: [.macOS(.v26)],
    products: [
        .executable(name: "CloudClinic", targets: ["CloudClinic"])
    ],
    dependencies: [
        .package(path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "CloudClinic",
            dependencies: [
                .product(name: "HealthOSBoundary", package: "HealthOS"),
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Sources/CloudClinic",
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "CloudClinicTests",
            dependencies: [
                .product(name: "CustomSDK", package: "HealthOS")
            ],
            path: "Tests/CloudClinicTests"
        )
    ]
)
