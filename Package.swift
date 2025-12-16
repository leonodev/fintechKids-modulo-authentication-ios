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
        
        .package(url: "https://github.com/leonodev/fintechKids-modulo-utils-ios.git",
                .upToNextMajor(from: "1.0.2")),
        
        .package(url: "https://github.com/leonodev/fintechKids-modulo-core-ios.git", branch: "main"),
        
        .package(url: "https://github.com/leonodev/fintechKids-modulo-config-ios.git", branch: "main"),
        
        .package(url: "https://github.com/leonodev/fintechKids-modulo-storage-ios.git", branch: "main")
    ],
    targets: [
        .target(
            name: "FHKAuth",
            dependencies: [
                // Modules
                .product(name: "Supabase", package: "supabase-swift"),
                .product(name: "FHKUtils", package: "fintechKids-modulo-utils-ios"),
                .product(name: "FHKCore", package: "fintechKids-modulo-core-ios"),
                .product(name: "FHKConfig", package: "fintechKids-modulo-config-ios"),
                .product(name: "FHKStorage", package: "fintechKids-modulo-storage-ios")
            ],
            resources: [.process("Resources")]
        ),
        .testTarget(
            name: "FHKAuthTests",
            dependencies: ["FHKAuth"]
        ),
    ]
)
