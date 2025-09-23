// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NEARJSONRPCTypes",
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
        )
    ],
    dependencies: [
        .package(url: "https://github.com/apple/swift-openapi-generator", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-openapi-runtime", from: "1.0.0"),
        .package(url: "https://github.com/apple/swift-docc-plugin", from: "1.3.0")
    ],
    targets: [
        .target(
            name: "NEARJSONRPCTypes",
            dependencies: [
                .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
            ],
            path: "Sources/NEARJSONRPCTypes",
            plugins: [
                .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
            ]
        ),
        .testTarget(
            name: "NEARJSONRPCTypesTests",
            dependencies: ["NEARJSONRPCTypes"],
            path: "Tests/NEARJSONRPCTypesTests"
        )
    ]
)
