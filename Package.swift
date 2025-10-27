// swift-tools-version: 5.9
import PackageDescription

// Root package for development workspace
// This allows convenient development of both packages together
// Individual packages are in NEARJSONRPCTypes/ and NEARJSONRPCClient/
let package = Package(
    name: "near-swift-client",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "NEARJSONRPCTypes",
            targets: ["NEARJSONRPCTypesPublic"]
        ),
        .library(
            name: "NEARJSONRPCClient",
            targets: ["NEARJSONRPCClientPublic"]
        ),
        .executable(
            name: "generate",
            targets: ["Generate"]
        )
    ],
    dependencies: [
        // Local packages for development
        .package(path: "./NEARJSONRPCTypes"),
        .package(path: "./NEARJSONRPCClient"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        // Re-export targets for library products
        .target(
            name: "NEARJSONRPCTypesPublic",
            dependencies: [
                .product(name: "NEARJSONRPCTypes", package: "NEARJSONRPCTypes")
            ],
            path: "Sources/NEARJSONRPCTypesPublic"
        ),
        .target(
            name: "NEARJSONRPCClientPublic",
            dependencies: [
                .product(name: "NEARJSONRPCClient", package: "NEARJSONRPCClient")
            ],
            path: "Sources/NEARJSONRPCClientPublic"
        ),
        // Code generation executable
        .executableTarget(
            name: "Generate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        ),
        // Tests
        .testTarget(
            name: "NEARJSONRPCTypesTests",
            dependencies: [
                .product(name: "NEARJSONRPCTypes", package: "NEARJSONRPCTypes")
            ]
        ),
        .testTarget(
            name: "NEARJSONRPCClientTests",
            dependencies: [
                .product(name: "NEARJSONRPCClient", package: "NEARJSONRPCClient")
            ]
        ),
        .testTarget(
            name: "GenerateTests",
            dependencies: ["Generate"]
        )
    ]
)