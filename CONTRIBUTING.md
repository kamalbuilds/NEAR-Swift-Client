# Contributing to NEAR Swift Client

Thank you for your interest in contributing to the NEAR Swift Client! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

1. [Code of Conduct](#code-of-conduct)
2. [Getting Started](#getting-started)
3. [Development Workflow](#development-workflow)
4. [Code Generation](#code-generation)
5. [Testing Requirements](#testing-requirements)
6. [Code Style Guidelines](#code-style-guidelines)
7. [Pull Request Process](#pull-request-process)
8. [Commit Messages](#commit-messages)
9. [Issue Reporting](#issue-reporting)

## Code of Conduct

### Our Pledge

We are committed to providing a welcoming and inclusive environment for all contributors, regardless of experience level, gender, gender identity and expression, sexual orientation, disability, personal appearance, body size, race, ethnicity, age, religion, or nationality.

### Expected Behavior

- Be respectful and inclusive
- Provide constructive feedback
- Focus on what is best for the community
- Show empathy towards others

### Unacceptable Behavior

- Harassment, intimidation, or discrimination
- Offensive comments or personal attacks
- Publishing private information
- Trolling or insulting comments

## Getting Started

### Prerequisites

- **Swift 5.9+** installed
- **Xcode 15+** (for macOS development)
- **Git** for version control
- **GitHub account** for pull requests

### Fork and Clone

```bash
# Fork the repository on GitHub
# Then clone your fork
git clone https://github.com/YOUR_USERNAME/near-swift-client.git
cd near-swift-client

# Add upstream remote
git remote add upstream https://github.com/ORIGINAL_OWNER/near-swift-client.git
```

### Install Dependencies

```bash
# Resolve Swift package dependencies
swift package resolve

# Verify build works
swift build

# Run tests to ensure everything is working
swift test
```

## Development Workflow

### 1. Create a Branch

```bash
# Update your fork
git checkout main
git pull upstream main

# Create a feature branch
git checkout -b feature/your-feature-name

# Or for bug fixes
git checkout -b fix/bug-description
```

### 2. Make Changes

Follow these guidelines:
- Write clear, self-documenting code
- Add comments for complex logic
- Update documentation as needed
- Follow Swift API design guidelines

### 3. Test Your Changes

```bash
# Run all tests
swift test

# Run with coverage
swift test --enable-code-coverage

# Run specific test
swift test --filter NEARJSONRPCClientTests
```

### 4. Commit Changes

Use conventional commit messages (see [Commit Messages](#commit-messages)):

```bash
git add .
git commit -m "feat: add transaction signing support"
```

### 5. Push and Create PR

```bash
# Push to your fork
git push origin feature/your-feature-name

# Create pull request on GitHub
gh pr create --title "feat: add transaction signing support" --body "Description of changes"
```

## Code Generation

The NEAR Swift Client uses automated code generation from the NEAR OpenAPI specification.

### Understanding Code Generation

**Source:** NEAR Protocol OpenAPI specification
- Location: https://github.com/near/nearcore/blob/master/chain/jsonrpc/openapi/openapi.json
- Format: OpenAPI 3.0
- Updated: Automatically by nearcore team

**Generator:** Swift OpenAPI Generator
- Tool: https://github.com/apple/swift-openapi-generator
- Input: openapi.json
- Output: Swift types and client code

### Running Code Generation

```bash
# Generate code from current OpenAPI spec
swift run generate

# This will:
# 1. Download latest openapi.json from nearcore
# 2. Generate Swift types in Sources/NEARJSONRPCTypes/
# 3. Generate client code in Sources/NEARJSONRPCClient/
# 4. Apply snake_case to camelCase transformations
```

### Code Generation Workflow

```
┌──────────────────┐
│  OpenAPI Spec    │
│  (nearcore)      │
└────────┬─────────┘
         │
         │ Download
         ▼
┌──────────────────┐
│  openapi.json    │
└────────┬─────────┘
         │
         │ swift-openapi-generator
         ▼
┌──────────────────┐
│  Generated Code  │
│  - Types         │
│  - Client        │
└────────┬─────────┘
         │
         │ Transformations
         │ - snake_case → camelCase
         │ - Path normalization
         ▼
┌──────────────────┐
│  Final Code      │
│  (committed)     │
└──────────────────┘
```

### Customizing Generated Code

**DO NOT edit generated files directly.** Instead:

1. **Modify the generator script:**
   - Edit `Sources/Generate/main.swift`
   - Add custom transformations
   - Update naming conventions

2. **Use extensions:**
   - Create `Extensions/` directory
   - Add helper methods via extensions
   - Keep extensions separate from generated code

3. **Update generator config:**
   - Edit `openapi-generator-config.yaml`
   - Adjust generator settings
   - Configure output options

### Testing Generated Code

```bash
# After generation, always run tests
swift run generate
swift test --enable-code-coverage

# Verify no regressions
git diff Sources/NEARJSONRPCTypes/
git diff Sources/NEARJSONRPCClient/
```

## Testing Requirements

### Coverage Requirements

**Minimum test coverage: 80%**

All pull requests must maintain or improve test coverage:

```bash
# Check current coverage
swift test --enable-code-coverage

# Generate detailed coverage report
xcrun llvm-cov report \
  .build/debug/near-swift-clientPackageTests.xctest/Contents/MacOS/near-swift-clientPackageTests \
  -instr-profile .build/debug/codecov/default.profdata
```

### Testing Guidelines

#### Unit Tests

Test individual components in isolation:

```swift
import XCTest
@testable import NEARJSONRPCTypes

final class BlockTests: XCTestCase {
    func testBlockDecoding() async throws {
        // Arrange
        let json = """
        {
            "header": {
                "height": 12345,
                "hash": "abc123..."
            }
        }
        """

        // Act
        let block = try JSONDecoder().decode(Block.self, from: json.data(using: .utf8)!)

        // Assert
        XCTAssertEqual(block.header.height, 12345)
    }
}
```

#### Integration Tests

Test interaction between components:

```swift
import XCTest
@testable import NEARJSONRPCClient

final class ClientIntegrationTests: XCTestCase {
    func testGetBlockQuery() async throws {
        // Use testnet endpoint
        let config = NEARClientConfiguration(
            endpoint: "https://rpc.testnet.near.org"
        )
        let client = NEARClient(configuration: config)

        // Query latest block
        let block = try await client.getBlock(finality: .final)

        // Verify response
        XCTAssertGreaterThan(block.header.height, 0)
    }
}
```

#### Mock Testing

Use mocks for external dependencies:

```swift
class MockURLSession: URLSessionProtocol {
    var mockResponse: (Data, URLResponse)?
    var mockError: Error?

    func data(for request: URLRequest) async throws -> (Data, URLResponse) {
        if let error = mockError {
            throw error
        }
        return mockResponse!
    }
}

func testClientWithMock() async throws {
    let mockSession = MockURLSession()
    mockSession.mockResponse = (mockData, mockURLResponse)

    let client = NEARClient(session: mockSession)
    let result = try await client.getStatus()

    XCTAssertEqual(result.chainId, "testnet")
}
```

### Running Tests Locally

```bash
# Run all tests
swift test

# Run specific test file
swift test --filter NEARJSONRPCClientTests

# Run specific test case
swift test --filter BlockTests.testBlockDecoding

# Run with coverage
swift test --enable-code-coverage

# Run in parallel (faster)
swift test --parallel
```

### Test Organization

```
Tests/
├── NEARJSONRPCTypesTests/
│   ├── BlockTests.swift
│   ├── TransactionTests.swift
│   └── AccountTests.swift
└── NEARJSONRPCClientTests/
    ├── ClientTests.swift
    ├── QueryTests.swift
    └── IntegrationTests.swift
```

### Coverage Report

View detailed coverage:

```bash
# Generate LCOV format
xcrun llvm-cov export \
  .build/debug/near-swift-clientPackageTests.xctest/Contents/MacOS/near-swift-clientPackageTests \
  -instr-profile .build/debug/codecov/default.profdata \
  -format="lcov" > coverage.lcov

# View in browser (requires lcov tool)
genhtml coverage.lcov -o coverage_html
open coverage_html/index.html
```

## Code Style Guidelines

### Swift Style Guide

Follow the [Swift API Design Guidelines](https://swift.org/documentation/api-design-guidelines/):

**Naming:**
```swift
// ✅ Clear, descriptive names
func fetchBlock(byId blockId: String) async throws -> Block

// ❌ Unclear abbreviations
func getBlk(id: String) async throws -> Block
```

**Formatting:**
```swift
// ✅ Proper spacing and indentation
struct BlockHeader {
    let height: UInt64
    let hash: String
    let timestamp: Date
}

// ❌ Inconsistent formatting
struct BlockHeader{
  let height:UInt64
  let hash:String
  let timestamp:Date
}
```

### SwiftLint

This project uses SwiftLint for code style enforcement:

```bash
# Install SwiftLint
brew install swiftlint

# Run SwiftLint
swiftlint

# Auto-fix issues
swiftlint --fix

# Configuration file: .swiftlint.yml
```

### Documentation

Document public APIs using Swift's documentation comments:

```swift
/// Fetches a block by its identifier.
///
/// - Parameters:
///   - blockId: The block hash or height
///   - finality: The finality level for the query
/// - Returns: The requested block
/// - Throws: `NEARClientError` if the request fails
public func getBlock(
    blockId: String,
    finality: Finality = .final
) async throws -> Block {
    // Implementation
}
```

## Pull Request Process

### PR Checklist

Before submitting a pull request, ensure:

- [ ] Code follows Swift style guidelines
- [ ] SwiftLint passes (`swiftlint`)
- [ ] All tests pass (`swift test`)
- [ ] Test coverage ≥ 80%
- [ ] Documentation updated (if adding features)
- [ ] CHANGELOG.md updated (for significant changes)
- [ ] Commit messages follow conventional format
- [ ] No merge conflicts with main
- [ ] PR description explains the changes

### PR Template

Use this template for your PR description:

```markdown
## Description
Brief description of changes

## Type of Change
- [ ] Bug fix (non-breaking change which fixes an issue)
- [ ] New feature (non-breaking change which adds functionality)
- [ ] Breaking change (fix or feature that would cause existing functionality to not work as expected)
- [ ] Documentation update

## Testing
- [ ] Unit tests added/updated
- [ ] Integration tests added/updated
- [ ] All tests passing
- [ ] Coverage ≥ 80%

## Checklist
- [ ] Code follows style guidelines
- [ ] SwiftLint passing
- [ ] Documentation updated
- [ ] CHANGELOG.md updated
- [ ] Conventional commit messages used

## Related Issues
Closes #123
```

### Review Process

1. **Automated Checks:**
   - GitHub Actions runs tests
   - Coverage report generated
   - SwiftLint validation

2. **Code Review:**
   - At least one maintainer review required
   - Address feedback and comments
   - Update PR based on suggestions

3. **Approval and Merge:**
   - Approved by maintainer
   - Squash and merge to main
   - Branch automatically deleted

### CI/CD Pipeline

GitHub Actions automatically:

```
┌──────────────┐
│  Push to PR  │
└──────┬───────┘
       │
       ├──→ Build (macOS)
       ├──→ Build (Linux)
       ├──→ Run Tests
       ├──→ Generate Coverage
       ├──→ SwiftLint Check
       │
       ▼
┌──────────────┐
│  All Pass?   │
└──────┬───────┘
       │
       ├──→ ✅ Ready for Review
       └──→ ❌ Needs Fixes
```

## Commit Messages

### Conventional Commits

Use [Conventional Commits](https://www.conventionalcommits.org/) format:

```
<type>[optional scope]: <description>

[optional body]

[optional footer(s)]
```

### Types

- `feat`: New feature (MINOR version bump)
- `fix`: Bug fix (PATCH version bump)
- `perf`: Performance improvement
- `docs`: Documentation changes
- `test`: Adding or updating tests
- `chore`: Maintenance tasks
- `refactor`: Code refactoring
- `style`: Code style changes
- `ci`: CI/CD changes

### Examples

```bash
# Feature
git commit -m "feat: add transaction signing support"

# Bug fix
git commit -m "fix: correct base64 encoding for public keys"

# Performance
git commit -m "perf: optimize JSON parsing for large responses"

# Breaking change
git commit -m "feat!: redesign client initialization

BREAKING CHANGE: Client now requires configuration object"

# With scope
git commit -m "fix(client): handle connection timeout errors"

# With body
git commit -m "feat: add block streaming

This commit adds support for streaming blocks in real-time
using AsyncStream API."
```

## Issue Reporting

### Bug Reports

Use the bug report template:

```markdown
**Describe the bug**
Clear description of the bug

**To Reproduce**
Steps to reproduce:
1. Initialize client with...
2. Call method...
3. See error

**Expected behavior**
What you expected to happen

**Actual behavior**
What actually happened

**Environment:**
- Swift version: 5.9
- Platform: macOS 14.0
- Package version: 1.0.0

**Additional context**
Any other relevant information
```

### Feature Requests

Use the feature request template:

```markdown
**Is your feature request related to a problem?**
Description of the problem

**Describe the solution you'd like**
Clear description of desired functionality

**Describe alternatives considered**
Other solutions you've considered

**Additional context**
Any other relevant information
```

### Questions

For questions:
- Check existing documentation
- Search GitHub Discussions
- Join NEAR community channels

## Development Tools

### Recommended Tools

- **Xcode**: Official Swift IDE
- **SwiftLint**: Code style checker
- **GitHub CLI**: Command-line GitHub interface
- **swift-format**: Code formatter

### Useful Commands

```bash
# Format code
swift-format -i Sources/**/*.swift

# Generate documentation
swift package generate-documentation

# Update dependencies
swift package update

# Show dependency tree
swift package show-dependencies
```

## Getting Help

- **Documentation**: Check README.md and docs/
- **Discussions**: https://github.com/YOUR_USERNAME/near-swift-client/discussions
- **NEAR Community**: https://t.me/NEARDev
- **Issues**: https://github.com/YOUR_USERNAME/near-swift-client/issues

## Recognition

Contributors are recognized in:
- CHANGELOG.md for significant contributions
- GitHub contributors page
- Release notes for major features

Thank you for contributing to the NEAR Swift Client! 🚀

---

Last Updated: 2024-10-26
