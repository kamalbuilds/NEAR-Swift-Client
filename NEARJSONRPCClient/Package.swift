// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NEARJSONRPCClient",
    platforms: [
        .macOS(.v13),
        .iOS(.v16),
        .tvOS(.v16),
        .watchOS(.v9),
        .visionOS(.v1)
    ],
    products: [
        .library(
            name: "NEARJSONRPCClient",
            targets: ["NEARJSONRPCClient"]
        )
    ],
    dependencies: [
        // For production use, specify the GitHub URL:
        // .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0"),
        // For local development, use relative path:
        .package(path: "../NEARJSONRPCTypes"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-urlsession", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "NEARJSONRPCClient",
            dependencies: [
                .product(name: "NEARJSONRPCTypes", package: "NEARJSONRPCTypes"),
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime"),
                .product(name: "OpenAPIURLSession", package: "swift-openapi-urlsession")
            ],
            path: "Sources/NEARJSONRPCClient"
        ),
        .testTarget(
            name: "NEARJSONRPCClientTests",
            dependencies: ["NEARJSONRPCClient"],
            path: "Tests/NEARJSONRPCClientTests"
        )
    ]
)
