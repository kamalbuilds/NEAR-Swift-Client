# NEAR Swift Client Examples

This directory contains examples demonstrating how to use the NEAR Swift Client.

## Running Examples

### Basic Example

```bash
cd Examples/NEARExample
swift run
```

This example demonstrates:
- Connecting to NEAR testnet
- Getting network status
- Querying blocks
- Viewing account information
- Calling contract view functions

## Creating Your Own Example

1. Create a new Swift executable package:
```bash
swift package init --type executable --name MyNEARApp
```

2. Add NEAR Swift Client as a dependency in `Package.swift`:
```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0")
],
targets: [
    .executableTarget(
        name: "MyNEARApp",
        dependencies: [
            .product(name: "NEARJSONRPCClient", package: "near-swift-client")
        ]
    )
]
```

3. Import and use the client:
```swift
import NEARJSONRPCClient

let client = try NEARClient()
let status = try await client.status()
```

## More Examples

- **iOS App Example**: See `Examples/iOSExample` for a SwiftUI app
- **Command Line Tool**: See `Examples/CLITool` for a full-featured CLI
- **Server Integration**: See `Examples/VaporIntegration` for server-side usage