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
        // Code generation executable
        .executableTarget(
            name: "Generate",
            dependencies: [
                .product(name: "ArgumentParser", package: "swift-argument-parser")
            ]
        )
    ]
)