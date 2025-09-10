# Architecture Overview

## Project Structure

The NEAR Swift Client is organized as a monorepo containing multiple Swift packages:

```
near-swift-client/
├── Sources/
│   ├── NEARJSONRPCTypes/       # Type definitions
│   ├── NEARJSONRPCClient/      # Client implementation
│   └── Generate/               # Code generation tool
├── Tests/
├── Examples/
├── Scripts/
└── .github/workflows/
```

## Code Generation Pipeline

### 1. OpenAPI Specification Processing

The pipeline starts by downloading the NEAR OpenAPI specification from the nearcore repository:

```
Download OpenAPI Spec → Parse JSON → Apply Patches → Generate Swift Code
```

### 2. Path Patching

The NEAR OpenAPI spec defines unique paths for each method (e.g., `/status`, `/block`), but the actual JSON-RPC implementation uses a single endpoint `/`. The generator patches this by:

1. Extracting all operations from various paths
2. Moving them to a single `/` path
3. Adding `x-jsonrpc-method` extension for method identification

### 3. Type Conversion

The generator automatically converts snake_case field names from the API to camelCase for Swift:

- `account_id` → `accountId`
- `block_height` → `blockHeight`
- `latest_block_hash` → `latestBlockHash`

### 4. Code Generation

Using Apple's swift-openapi-generator, the pipeline generates:

1. **Type Definitions** - All request/response types
2. **Client Protocol** - Generated client interface
3. **Client Implementation** - Concrete implementation

## Package Architecture

### NEARJSONRPCTypes

Pure Swift value types with no dependencies except Foundation:

- Codable structs for all RPC types
- Proper Swift naming conventions
- Minimal runtime overhead
- Zero external dependencies

### NEARJSONRPCClient

High-level client built on top of the types package:

- JSON-RPC wrapper for proper request/response handling
- Convenience methods for common operations
- URLSession-based networking
- Full async/await support

## JSON-RPC Implementation

The client wraps all calls in proper JSON-RPC format:

```swift
Request:
{
    "jsonrpc": "2.0",
    "id": "unique-id",
    "method": "status",
    "params": []
}

Response:
{
    "jsonrpc": "2.0",
    "id": "unique-id",
    "result": { ... }
}
```

## Error Handling

Three levels of error handling:

1. **Network Errors** - Connection failures, timeouts
2. **JSON-RPC Errors** - Protocol-level errors with codes
3. **Application Errors** - Invalid parameters, business logic errors

## Testing Strategy

### Unit Tests
- Type serialization/deserialization
- JSON-RPC wrapper functionality
- Error handling paths

### Integration Tests
- Mock server responses
- End-to-end client operations
- Network resilience

### Performance Tests
- Large response handling
- Concurrent request processing
- Memory usage

## Automation

### Continuous Integration
- Daily checks for OpenAPI spec updates
- Automated code regeneration
- Test execution on multiple platforms

### Release Process
1. Automated PR creation for spec changes
2. Human review required
3. release-please handles versioning
4. Automatic publishing after merge

## Security Considerations

- No credentials stored in code
- HTTPS-only connections
- Input validation on all methods
- Safe JSON parsing with Codable

## Performance Optimizations

- Lazy decoding where possible
- Efficient data structures
- Minimal allocations
- Connection pooling via URLSession

## Future Enhancements

1. WebSocket support for subscriptions
2. Request batching
3. Response caching
4. Offline mode with sync
5. SwiftUI property wrappers