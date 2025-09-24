# OpenAPI Code Generation

This document describes the OpenAPI-based code generation system for the NEAR Swift Client.

## Overview

The NEAR Swift Client uses **real** automated code generation powered by Apple's `swift-openapi-generator`. The generated types are automatically created from the official NEAR Protocol OpenAPI specification.

## How It Works

### 1. OpenAPI Specification

The OpenAPI spec is located at:
```
NEARJSONRPCTypes/Sources/NEARJSONRPCTypes/openapi.yaml
```

This YAML file defines all NEAR JSON-RPC methods, request parameters, and response types.

### 2. Generator Configuration

The generator configuration is at:
```
NEARJSONRPCTypes/Sources/NEARJSONRPCTypes/openapi-generator-config.yaml
```

Configuration options:
- **generate**: `types` - Only generates type definitions (not client code)
- **accessModifier**: `public` - Makes all types public for library use
- **additionalImports**: `Foundation` - Includes Foundation framework

### 3. Build Plugin Integration

The `swift-openapi-generator` runs automatically during build via Swift Package Manager plugin:

```swift
// In NEARJSONRPCTypes/Package.swift
.target(
    name: "NEARJSONRPCTypes",
    dependencies: [
        .product(name: "OpenAPIRuntime", package: "swift-openapi-runtime")
    ],
    plugins: [
        .plugin(name: "OpenAPIGenerator", package: "swift-openapi-generator")
    ]
)
```

### 4. Automatic Generation During Build

When you run:
```bash
cd NEARJSONRPCTypes
swift build
```

The generator:
1. Reads `openapi.yaml` and `openapi-generator-config.yaml`
2. Parses the OpenAPI specification
3. Generates Swift types in `.build/plugins/outputs/`
4. Compiles the generated code along with your manual code

## Generated Files

The generator creates three files:

1. **Types.swift** - All type definitions (structs, enums)
2. **Client.swift** - Client-side protocol definitions (generated but not used directly)
3. **Server.swift** - Server-side protocol definitions (generated but not used directly)

### Generated Types Structure

The generated types include:

```swift
// Components namespace containing all schemas
public enum Components {
    public enum Schemas {
        // All request/response types
        public struct JsonRpcRequest_for_status: Codable { ... }
        public struct RpcStatusResponse: Codable { ... }
        // ... hundreds more types
    }
}

// Input/Output types for each operation
public enum Operations {
    public enum status {
        public enum Input { ... }
        public enum Output { ... }
    }
    // ... for each RPC method
}
```

## Manual Code Integration

The package combines:

1. **Generated code** (automatic from OpenAPI spec)
2. **Manual Models.swift** (hand-written convenience wrappers)

This hybrid approach provides:
- ✅ Type safety from OpenAPI spec
- ✅ Convenience methods for common operations
- ✅ Custom JSON-RPC wrapper logic

## Updating the Generated Code

### From Latest NEAR Spec

```bash
# Run the generation tool
swift run generate

# This will:
# 1. Download latest OpenAPI spec from NEAR
# 2. Patch for JSON-RPC compatibility
# 3. Convert to YAML
# 4. Trigger regeneration via swift build
```

### Manual Update

```bash
# 1. Update the OpenAPI spec
curl -o NEARJSONRPCTypes/Sources/NEARJSONRPCTypes/openapi.yaml \
  https://raw.githubusercontent.com/near/nearcore/master/chain/jsonrpc/openapi/openapi.json

# 2. Rebuild
cd NEARJSONRPCTypes
swift build
```

## Testing Generated Code

### Run Tests

```bash
cd NEARJSONRPCTypes
swift test
```

### Test Coverage

The test suite includes:

1. **CodeGenerationTests** - Validates types match API responses
2. **GeneratedCodeSnapshotTests** - Ensures code stability across regenerations

Key test scenarios:
- JSON encoding/decoding round-trips
- snake_case to camelCase conversion
- Real API response parsing
- Type signature validation

## CI/CD Integration

### GitHub Actions Workflow

The `.github/workflows/generate.yml` workflow:

1. Downloads latest OpenAPI spec daily
2. Checks for changes
3. Regenerates code if changed
4. Verifies compilation
5. Runs tests
6. Creates PR with updates

### Manual Trigger

You can trigger regeneration manually:
```bash
# In GitHub Actions
Workflow: "Generate and Update Client" → Run workflow
```

## Troubleshooting

### Build Errors

If you see generator errors:

```bash
# Check config syntax
cat NEARJSONRPCTypes/Sources/NEARJSONRPCTypes/openapi-generator-config.yaml

# Validate OpenAPI spec
swift package plugin --allow-writing-to-directory /tmp generate-code-from-openapi \
  --input NEARJSONRPCTypes/Sources/NEARJSONRPCTypes/openapi.yaml \
  --output-directory /tmp
```

### Missing Types

If types are missing after generation:

1. Check the OpenAPI spec includes the schema
2. Verify generator mode is set to `types`
3. Ensure `accessModifier: public` in config
4. Clean and rebuild: `swift package clean && swift build`

### Compilation Failures

If generated code doesn't compile:

1. Check for OpenAPI spec validation errors
2. Update `swift-openapi-generator` dependency
3. Review generator compatibility with Swift version
4. Check for naming conflicts with manual code

## Best Practices

### DO:
- ✅ Keep generator config minimal
- ✅ Use generated types directly when possible
- ✅ Add convenience wrappers in Models.swift for complex cases
- ✅ Test generated code with real API responses
- ✅ Update regularly from NEAR spec

### DON'T:
- ❌ Manually edit generated files (they get overwritten)
- ❌ Commit generated files to git (they're build artifacts)
- ❌ Duplicate type definitions between manual and generated code
- ❌ Ignore generator warnings

## Architecture

```
┌─────────────────────────────────────────┐
│  NEAR Protocol OpenAPI Spec (YAML)      │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  swift-openapi-generator (Build Plugin) │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Generated Swift Types                  │
│  - Components.Schemas.*                 │
│  - Operations.*                         │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  Manual Code (Models.swift)             │
│  - Convenience wrappers                 │
│  - Custom JSON-RPC logic                │
└──────────────┬──────────────────────────┘
               │
               ▼
┌─────────────────────────────────────────┐
│  NEARJSONRPCTypes Library               │
│  (Combined Generated + Manual)          │
└─────────────────────────────────────────┘
```

## References

- [swift-openapi-generator Documentation](https://github.com/apple/swift-openapi-generator)
- [NEAR Protocol JSON-RPC API](https://docs.near.org/api/rpc/introduction)
- [OpenAPI 3.0 Specification](https://swagger.io/specification/)

## Contributing

When adding new types:

1. Check if they exist in the OpenAPI spec
2. If yes: Use the generated type
3. If no: Request addition to NEAR's OpenAPI spec OR add to Models.swift with clear comments

## Version History

- **v1.0.0** - Initial manual types
- **v2.0.0** - Implemented OpenAPI code generation
  - Added swift-openapi-generator integration
  - Converted spec to YAML
  - Added automated tests
  - CI/CD for automatic updates
