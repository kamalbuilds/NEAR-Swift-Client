# NEARJSONRPCTypes

Type definitions for the NEAR Protocol JSON-RPC API, automatically generated from the official OpenAPI specification.

## Features

- ✅ **Automated Code Generation** - Types generated from NEAR's official OpenAPI spec
- ✅ **Type Safety** - Full Swift type checking for all RPC requests and responses
- ✅ **Up-to-Date** - Automatically synchronized with NEAR Protocol updates
- ✅ **Comprehensive** - Covers all 31+ JSON-RPC methods
- ✅ **Well-Tested** - Extensive test suite with real API response validation

## Installation

### Swift Package Manager

```swift
dependencies: [
    .package(url: "https://github.com/yourusername/near-swift-client", from: "2.0.0")
]
```

Then add to your target:
```swift
.target(
    name: "YourTarget",
    dependencies: [
        .product(name: "NEARJSONRPCTypes", package: "near-swift-client")
    ]
)
```

## Usage

### Generated Types

All types are automatically generated from the OpenAPI specification:

```swift
import NEARJSONRPCTypes

// Use generated types directly
let status: Components.Schemas.RpcStatusResponse = ...
let block: Components.Schemas.RpcBlockResponse = ...
let account: Components.Schemas.QueryResponseKind.ViewAccount = ...
```

### Convenience Wrappers

The package also provides hand-crafted convenience types in `Models.swift`:

```swift
import NEARJSONRPCTypes

// Convenient pre-defined types
let statusResponse: StatusResponse = ...
let blockView: BlockView = ...
let accountView: AccountView = ...
```

### JSON Encoding/Decoding

All types support Codable with automatic snake_case ↔ camelCase conversion:

```swift
let decoder = JSONDecoder()
decoder.keyDecodingStrategy = .convertFromSnakeCase

let encoder = JSONEncoder()
encoder.keyEncodingStrategy = .convertToSnakeCase
```

## Code Generation

This package uses **real automated code generation** powered by Apple's [swift-openapi-generator](https://github.com/apple/swift-openapi-generator).

### How It Works

1. **OpenAPI Spec** (`openapi.yaml`) - Official NEAR Protocol API specification
2. **Generator Config** (`openapi-generator-config.yaml`) - Generation settings
3. **Build Plugin** - Automatically runs during `swift build`
4. **Generated Code** - Creates `Types.swift` (1.7MB) with all type definitions

### Updating Generated Code

The code is automatically regenerated during build if the OpenAPI spec changes:

```bash
swift build
```

To manually update from the latest NEAR spec:

```bash
# From the root of near-swift-client
swift run generate
```

This will:
1. Download the latest OpenAPI spec from NEAR
2. Patch it for JSON-RPC compatibility
3. Convert to YAML format
4. Trigger regeneration

## Development

### Building

```bash
cd NEARJSONRPCTypes
swift build
```

### Testing

```bash
swift test
```

Test coverage includes:
- Generated type validation
- JSON encoding/decoding round-trips
- Real API response parsing
- Snake case conversion
- Type signature stability

### Project Structure

```
NEARJSONRPCTypes/
├── Package.swift                          # Package definition with OpenAPI plugin
├── Sources/NEARJSONRPCTypes/
│   ├── openapi.yaml                       # OpenAPI specification
│   ├── openapi-generator-config.yaml      # Generator configuration
│   └── Models.swift                       # Hand-written convenience types
├── Tests/NEARJSONRPCTypesTests/
│   ├── CodeGenerationTests.swift          # Generation validation tests
│   └── GeneratedCodeSnapshotTests.swift   # Stability tests
└── .build/plugins/outputs/
    └── .../Types.swift                    # Generated types (1.7MB, not committed)
```

## Architecture

### Hybrid Approach

This package combines:

1. **Generated Code** (automatic from OpenAPI)
   - All Components.Schemas types
   - All Operations types
   - Fully type-safe from spec

2. **Manual Code** (Models.swift)
   - Convenience type aliases
   - Complex enum handling
   - Custom JSON-RPC wrappers

### Why This Approach?

- ✅ Always up-to-date with NEAR Protocol
- ✅ Zero manual maintenance for type updates
- ✅ Compile-time safety
- ✅ Convenience for common operations
- ✅ Flexibility for custom logic

## Generated Types Overview

The OpenAPI specification generates types for all NEAR RPC methods:

### Status & Network
- `status` - Node status and version
- `network_info` - Network information
- `validators` - Current and next validators

### Blocks
- `block` - Query block by height or hash
- `chunk` - Query chunk information
- `EXPERIMENTAL_changes_in_block` - State changes in block

### Accounts & Access Keys
- `query` (view_account) - Account details
- `query` (view_access_key) - Access key information
- `query` (view_access_key_list) - All access keys

### Contracts
- `query` (call_function) - Call view function
- `query` (view_state) - Contract state
- `query` (view_code) - Contract code

### Transactions
- `send_tx` - Send signed transaction
- `tx` - Query transaction status
- `EXPERIMENTAL_tx_status` - Enhanced transaction status
- `receipt` - Query receipt information

### Protocol
- `gas_price` - Current gas price
- `EXPERIMENTAL_genesis_config` - Genesis configuration
- `EXPERIMENTAL_protocol_config` - Protocol configuration

And many more! See the [NEAR RPC API Documentation](https://docs.near.org/api/rpc/introduction) for details.

## CI/CD

The package includes GitHub Actions workflows that:

1. **Daily Sync** - Checks for NEAR spec updates
2. **Auto-Generate** - Regenerates code when spec changes
3. **Test** - Validates all generated types
4. **PR Creation** - Automatically creates PRs with updates

## Documentation

For more details, see:

- [CODE_GENERATION.md](../docs/CODE_GENERATION.md) - Complete generation guide
- [NEAR RPC Docs](https://docs.near.org/api/rpc/introduction) - API reference
- [swift-openapi-generator](https://github.com/apple/swift-openapi-generator) - Generator docs

## Requirements

- Swift 5.9+
- macOS 13.0+ / iOS 16.0+ / tvOS 16.0+ / watchOS 9.0+ / visionOS 1.0+

## License

MIT License - see [LICENSE](../LICENSE) for details

## Contributing

Contributions welcome! Please:

1. Check if types exist in OpenAPI spec before adding manually
2. Add tests for new functionality
3. Follow Swift API design guidelines
4. Update documentation

## Related Packages

- [NEARJSONRPCClient](../NEARJSONRPCClient) - Client implementation using these types
- [near-swift-client](../) - Root package with examples

## Support

- Issues: [GitHub Issues](https://github.com/yourusername/near-swift-client/issues)
- Discussions: [GitHub Discussions](https://github.com/yourusername/near-swift-client/discussions)
- Documentation: [docs/](../docs/)

---

**Note**: This package uses automated code generation. Generated files are NOT committed to git - they are created during build. This ensures the types are always synchronized with the OpenAPI specification.
