// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NEARSwiftUIExample",
    platforms: [
        .iOS(.v16),
        .macOS(.v13)
    ],
    products: [
        .executable(
            name: "NEARSwiftUIExample",
            targets: ["NEARSwiftUIExample"]
        )
    ],
    dependencies: [
        .package(name: "near-swift-client", path: "../..")
    ],
    targets: [
        .executableTarget(
            name: "NEARSwiftUIExample",
            dependencies: [
                .product(name: "NEARJSONRPCClient", package: "near-swift-client")
            ],
            path: "."
        )
    ]
)