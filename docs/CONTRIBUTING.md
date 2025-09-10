# Contributing to NEAR Swift Client

We welcome contributions to the NEAR Swift Client! This document provides guidelines for contributing to the project.

## Getting Started

1. Fork the repository
2. Clone your fork: `git clone https://github.com/yourusername/near-swift-client.git`
3. Create a feature branch: `git checkout -b feature/your-feature-name`
4. Make your changes
5. Run tests: `swift test`
6. Commit your changes: `git commit -am 'Add new feature'`
7. Push to the branch: `git push origin feature/your-feature-name`
8. Submit a pull request

## Development Setup

### Prerequisites

- Swift 5.9 or later
- Xcode 15 or later
- [Swift OpenAPI Generator](https://github.com/apple/swift-openapi-generator)

### Building the Project

```bash
swift build
```

### Running Tests

```bash
swift test
```

### Regenerating Code

The Swift client code is automatically generated from the NEAR OpenAPI specification. To manually regenerate:

```bash
swift run generate
```

This will:
1. Download the latest OpenAPI spec from nearcore
2. Apply necessary patches for JSON-RPC compatibility
3. Generate Swift code with proper naming conventions
4. Create type-safe client methods

## Code Style

- Follow Swift API Design Guidelines
- Use SwiftLint for code style enforcement
- Ensure all public APIs have documentation comments
- Write tests for new functionality

## Testing

- Maintain at least 80% code coverage
- Write unit tests for all new features
- Include integration tests where appropriate
- Mock network calls in tests

## Pull Request Process

1. Ensure all tests pass
2. Update documentation as needed
3. Add an entry to the CHANGELOG
4. Ensure your PR description clearly describes the changes
5. Request review from maintainers

## Reporting Issues

- Use GitHub Issues to report bugs
- Include Swift version, platform, and steps to reproduce
- Provide minimal code examples when possible

## Community

- Join the NEAR Developer community on [Telegram](https://t.me/NEARDev)
- Ask questions in the [NEAR Tools Community](https://t.me/NEAR_Tools_Community_Group)

## License

By contributing to this project, you agree that your contributions will be licensed under the MIT License.