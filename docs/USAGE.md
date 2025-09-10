# NEAR Swift Client Usage Guide

This guide provides comprehensive examples of using the NEAR Swift Client.

## Installation

### Swift Package Manager

Add the following to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0")
],
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            .product(name: "NEARJSONRPCClient", package: "near-swift-client")
        ]
    )
]
```

## Basic Usage

### Initialize Client

```swift
import NEARJSONRPCClient

// Connect to testnet
let client = try NEARClient(url: "https://rpc.testnet.near.org")

// Connect to mainnet
let mainnetClient = try NEARClient(url: "https://rpc.mainnet.near.org")
```

### Get Network Status

```swift
let status = try await client.status()
print("Network: \(status.chainId)")
print("Latest block height: \(status.syncInfo.latestBlockHeight)")
```

### Query Account

```swift
let account = try await client.viewAccount(
    accountId: "example.testnet",
    finality: .final
)
print("Balance: \(account.amount)")
print("Storage used: \(account.storageUsage)")
```

### View Access Keys

```swift
let accessKey = try await client.viewAccessKey(
    accountId: "example.testnet",
    publicKey: "ed25519:...",
    finality: .final
)
print("Nonce: \(accessKey.nonce)")
```

### Call View Function

```swift
// Prepare function arguments
let args = try JSONEncoder().encode(["account_id": "user.testnet"])

let result = try await client.callFunction(
    accountId: "contract.testnet",
    methodName: "get_balance",
    args: args,
    finality: .optimistic
)

// Parse result
if let resultString = String(data: Data(result.result), encoding: .utf8) {
    print("Result: \(resultString)")
}
```

### Get Block Information

```swift
// Get latest final block
let block = try await client.block(finality: .final)
print("Block height: \(block.header.height)")
print("Block hash: \(block.header.hash)")

// Get specific block by height
let specificBlock = try await client.blockByHeight(height: 100000)
```

## Advanced Usage

### Custom RPC Calls

For RPC methods not covered by convenience methods:

```swift
// Use the low-level JSON-RPC interface
let customResult = try await client.callJSONRPC(
    method: "EXPERIMENTAL_changes",
    params: [
        "changes_type": "data_changes",
        "account_ids": ["contract.testnet"],
        "key_prefix_base64": ""
    ],
    resultType: CustomResultType.self
)
```

### Error Handling

```swift
do {
    let account = try await client.viewAccount(accountId: "nonexistent.testnet")
} catch let error as JSONRPCError {
    print("RPC Error: \(error.message)")
    print("Error code: \(error.code)")
} catch NEARClientError.invalidURL {
    print("Invalid RPC URL")
} catch {
    print("Unexpected error: \(error)")
}
```

### Batch Requests

```swift
// Execute multiple requests concurrently
async let status = client.status()
async let block = client.block()
async let account = client.viewAccount(accountId: "example.testnet")

let (statusResult, blockResult, accountResult) = try await (status, block, account)
```

### Working with Types

The `NEARJSONRPCTypes` package provides all the type definitions:

```swift
import NEARJSONRPCTypes

// All types follow Swift naming conventions
let validator: ValidatorInfo = ...
print("Account ID: \(validator.accountId)") // Note: camelCase, not snake_case
```

## Testing

### Mock Client for Testing

```swift
class MockNEARClient: NEARClientProtocol {
    func status() async throws -> StatusResponse {
        return StatusResponse(
            version: Version(version: "1.0.0", build: "test"),
            chainId: "test",
            // ... other fields
        )
    }
}

// Use in tests
let mockClient = MockNEARClient()
let status = try await mockClient.status()
```

## Best Practices

1. **Use appropriate finality**: Use `.optimistic` for faster responses when absolute finality isn't required
2. **Handle errors gracefully**: Always wrap RPC calls in do-catch blocks
3. **Reuse client instances**: Create one client instance and reuse it
4. **Validate account IDs**: Ensure account IDs follow NEAR naming rules before making calls
5. **Use type-safe methods**: Prefer the convenience methods over raw JSON-RPC calls

## Troubleshooting

### Common Issues

1. **SSL/TLS Errors**: Ensure your app has network permissions
2. **Timeout Errors**: Increase timeout or use a different RPC endpoint
3. **Parsing Errors**: Check that your result types match the actual RPC response

### Debug Logging

Enable debug logging to see raw requests/responses:

```swift
// Set log level in your app
NEARClient.logLevel = .debug
```

## Additional Resources

- [NEAR RPC API Documentation](https://docs.near.org/api/rpc/introduction)
- [NEAR Protocol Documentation](https://docs.near.org)
- [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)