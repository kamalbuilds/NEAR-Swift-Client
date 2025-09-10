// swift-tools-version: 5.9
import PackageDescription

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
            targets: ["NEARJSONRPCTypes"]
        ),
        .library(
            name: "NEARJSONRPCClient",
            targets: ["NEARJSONRPCClient"]
        ),
        .executable(
            name: "generate",
            targets: ["Generate"]
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-argument-parser", from: "1.3.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        // Type definitions package
        .target(
            name: "NEARJSONRPCTypes",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
            ],
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        
        // Client implementation package
        .target(
            name: "NEARJSONRPCClient",
            dependencies: [
                "NEARJSONRPCTypes",
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ]
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
            dependencies: ["NEARJSONRPCTypes"]
        ),
        .testTarget(
            name: "NEARJSONRPCClientTests",
            dependencies: ["NEARJSONRPCClient"]
        )
    ]
)