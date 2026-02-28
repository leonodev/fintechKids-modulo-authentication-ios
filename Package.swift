// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "FHKAuth",
    defaultLocalization: "en",
    platforms: [
        .iOS(.v17)
    ],
    products: [
        .library(
            name: "FHKAuth",
            targets: ["FHKAuth"]),
        
        
    ],
    dependencies: [
        .package(url: "https://github.com/supabase/supabase-swift.git",
                .upToNextMajor(from: "2.5.1")),
        
        // Modules Allow Layers Inferior
        .package(url: "https://github.com/leonodev/fintechKids-modulo-utils-ios.git",
                .upToNextMajor(from: "1.0.2")),
        
        .package(url: "https://github.com/leonodev/fintechKids-modulo-domain-ios.git", branch: "main")
    ],
    targets: [
        .target(
            name: "FHKAuth",
            dependencies: [
                //  Modules Allow Layers Inferior
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "FHKDomain", package: "fintechKids-modulo-domain-ios")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FHKAuthTests",
            dependencies: ["FHKAuth"]
        ),
    ]
)
