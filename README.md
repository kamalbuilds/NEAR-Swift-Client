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

### Swift Package Manager (Recommended)

The NEAR Swift Client is distributed via Swift Package Manager. Add it to your project using one of these methods:

#### Option 1: Package.swift

Add to your `Package.swift` dependencies:

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "1.0.0")
]
```

Then add the specific products you need to your target:

```swift
targets: [
    .target(
        name: "YourApp",
        dependencies: [
            // Option A: Use types only (lightweight)
            .product(name: "NEARJSONRPCTypes", package: "near-swift-client"),

            // Option B: Use full client (recommended)
            .product(name: "NEARJSONRPCClient", package: "near-swift-client")
        ]
    )
]
```

#### Option 2: Xcode

1. In Xcode, select **File → Add Package Dependencies**
2. Enter the repository URL: `https://github.com/yourusername/near-swift-client`
3. Choose version: "Up to Next Major Version" with `1.0.0`
4. Select products:
   - `NEARJSONRPCTypes` - Type definitions only
   - `NEARJSONRPCClient` - Full RPC client implementation

### Version Compatibility

| Package Version | Swift Version | Platforms |
|----------------|---------------|-----------|
| 1.0.0+ | 5.9+ | macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+ |

### Package Products

**NEARJSONRPCTypes**
- Lightweight type definitions and serialization
- Minimal dependencies (OpenAPIRuntime only)
- Perfect for when you only need NEAR data types

**NEARJSONRPCClient**
- Full RPC client implementation
- Includes NEARJSONRPCTypes
- Type-safe method calls for all NEAR RPC endpoints

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
├── docs/
│   ├── DEPLOYMENT_WORKFLOW.md # Deployment visualization
│   ├── RELEASE_PROCESS.md     # Release procedures
│   └── VERSIONING.md          # Version strategy
├── .github/
│   └── workflows/
│       ├── generate.yml       # Code generation automation
│       └── test.yml           # Testing automation
├── PUBLISHING.md              # Publishing guide
└── CONTRIBUTING.md            # Contribution guidelines
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

### Running Tests

```bash
# Run all tests
swift test

# Run with coverage
swift test --enable-code-coverage
```

## Documentation

- **[PUBLISHING.md](PUBLISHING.md)** - Complete guide to publishing packages
- **[CONTRIBUTING.md](CONTRIBUTING.md)** - Development and contribution guidelines
- **[docs/RELEASE_PROCESS.md](docs/RELEASE_PROCESS.md)** - Step-by-step release procedures
- **[docs/VERSIONING.md](docs/VERSIONING.md)** - Semantic versioning strategy
- **[docs/DEPLOYMENT_WORKFLOW.md](docs/DEPLOYMENT_WORKFLOW.md)** - Visual deployment workflow

## Deployment Workflow

The NEAR Swift Client uses a fully automated deployment workflow:

```
Code → PR → Merge → Generate → Test → Release → Publish
```

See [docs/DEPLOYMENT_WORKFLOW.md](docs/DEPLOYMENT_WORKFLOW.md) for detailed workflow visualization and explanation.

## Contributing

We welcome contributions! Please see [CONTRIBUTING.md](CONTRIBUTING.md) for:
- Development workflow
- Code generation process
- Testing requirements (80% coverage minimum)
- Pull request checklist
- Commit message conventions

## Versioning

This project follows [Semantic Versioning 2.0.0](https://semver.org/):
- **MAJOR** version for incompatible API changes
- **MINOR** version for backwards-compatible functionality
- **PATCH** version for backwards-compatible bug fixes

See [docs/VERSIONING.md](docs/VERSIONING.md) for detailed versioning strategy.

## Publishing

Releases are automated using:
- **Conventional Commits** for automatic version bumping
- **release-please** for changelog generation
- **GitHub Actions** for CI/CD automation

See [PUBLISHING.md](PUBLISHING.md) for complete publishing documentation.

## License

MIT License - See [LICENSE](LICENSE) for details.

## Support

- **Issues**: [GitHub Issues](https://github.com/yourusername/near-swift-client/issues)
- **Discussions**: [GitHub Discussions](https://github.com/yourusername/near-swift-client/discussions)
- **NEAR Community**: https://t.me/NEARDev
- **Tools Community**: https://t.me/NEAR_Tools_Community_Group

## Acknowledgments

This project is part of the NEAR Protocol ecosystem and follows patterns established by:
- [near-openapi-client](https://github.com/PolyProgrammist/near-openapi-client) (Rust)
- [near-jsonrpc-client-ts](https://github.com/near/near-jsonrpc-client-ts) (TypeScript)
