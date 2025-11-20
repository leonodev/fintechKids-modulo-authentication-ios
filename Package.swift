// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FHKAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v16)
    ],
    products: [
        .library(
            name: "FHKAuth",
            targets: ["FHKAuth"]),
    ],
    targets: [
        .target(
            name: "FHKAuth",
            dependencies: [],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FHKAuthTests",
            dependencies: ["FHKAuth"]
        ),
    ]
)
