# NEARJSONRPCClient

Type-safe Swift client for NEAR Protocol JSON-RPC API.

## Overview

NEARJSONRPCClient is a fully-featured, type-safe Swift client for interacting with NEAR Protocol's JSON-RPC API. It provides async/await support, comprehensive error handling, and convenient methods for all NEAR Protocol operations.

## Features

- Async/await support for modern Swift concurrency
- Type-safe API using NEARJSONRPCTypes
- Comprehensive error handling
- Support for all NEAR Protocol RPC methods:
  - Account management
  - Block queries
  - Transaction operations
  - Smart contract calls
  - Access key management
  - Protocol configuration
- Multiple network support (mainnet, testnet, custom)
- Built on Swift OpenAPI runtime

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0")
]
```

Then add the package to your target:

```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "NEARJSONRPCClient", package: "near-swift-client")
    ]
)
```

Note: This will automatically include NEARJSONRPCTypes as a dependency.

## Quick Start

```swift
import NEARJSONRPCClient

// Initialize client
let client = try NEARClient(network: .testnet)

// Query account
let account = try await client.viewAccount(accountId: "example.testnet")
print("Balance: \(account.amount)")

// Call view method
let result = try await client.callViewFunction(
    accountId: "contract.testnet",
    methodName: "get_greeting",
    args: [:]
)

// Query block
let block = try await client.getBlock(finality: .final)
print("Block height: \(block.header.height)")
```

## Network Configuration

```swift
// Testnet
let testnetClient = try NEARClient(network: .testnet)

// Mainnet
let mainnetClient = try NEARClient(network: .mainnet)

// Custom network
let customClient = try NEARClient(
    rpcURL: "https://your-custom-rpc.com",
    networkId: "custom-network"
)
```

## Platform Support

- macOS 13.0+
- iOS 16.0+
- tvOS 16.0+
- watchOS 9.0+
- visionOS 1.0+

## Requirements

- Swift 5.9+
- NEARJSONRPCTypes 1.0+
- OpenAPI Runtime 1.0+
- OpenAPI URLSession 1.0+

## Documentation

For detailed documentation, see the [full documentation](../docs/).

## Examples

Check out the [Examples](../Examples/) directory for complete usage examples.

## License

MIT License - See LICENSE file for details

## Related Packages

- [NEARJSONRPCTypes](../NEARJSONRPCTypes) - Type definitions used by this client
