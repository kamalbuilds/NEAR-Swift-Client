# NEAR Swift Client

Automated Swift client generator for NEAR Protocol's JSON-RPC API, based on the official OpenAPI specification.

## Overview

This project provides:
- **NEARJSONRPCTypes**: Type definitions and serialization/deserialization
- **NEARJSONRPCClient**: Full RPC client implementation with type-safe methods

## Features

- 🚀 Fully automated code generation from OpenAPI spec
- 🔒 Type-safe Swift client with compile-time safety
- 🐍 Automatic snake_case to camelCase conversion
- 📦 Two separate Swift packages for flexibility
- ✅ 80%+ test coverage
- 🤖 GitHub Actions automation for continuous updates
- 📚 Comprehensive documentation

## Installation

### Swift Package Manager

Add to your `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0")
]
```

## Quick Start

```swift
import NEARJSONRPCClient

// Initialize client
let client = NEARClient(url: "https://rpc.testnet.near.org")

// Make type-safe RPC calls
let status = try await client.status()
print("Chain ID: \(status.chainId)")
```

## Project Structure

```
near-swift-client/
├── Sources/
│   ├── NEARJSONRPCTypes/      # Type definitions
│   └── NEARJSONRPCClient/     # Client implementation
├── Tests/
├── Scripts/
│   └── generate.swift         # Code generation script
└── .github/
    └── workflows/
        └── generate.yml       # Automation workflow
```

## Development

### Prerequisites

- Swift 5.9+
- Xcode 15+
- [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)

### Regenerating Code

```bash
swift run generate
```

## License

MIT License - See [LICENSE](LICENSE) for details.