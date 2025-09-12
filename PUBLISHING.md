# Publishing NEAR Swift Client

## Swift Package Distribution

Unlike NPM packages, Swift packages are distributed via Git repositories, not a central package registry. Here's how to publish the NEAR Swift Client packages:

## Prerequisites

- [ ] All tests passing
- [ ] Documentation complete
- [ ] Version number updated
- [ ] CHANGELOG updated
- [ ] LICENSE file present (MIT)

## Publishing Steps

### 1. Initialize Git Repository

```bash
cd near-swift-client
git init
git add .
git commit -m "Initial release of NEAR Swift Client"
```

### 2. Create GitHub Repository

Using GitHub CLI:
```bash
gh repo create near-swift-client --public \
  --description "Swift client for NEAR Protocol JSON-RPC API" \
  --homepage "https://near.org"
```

Or manually create at: https://github.com/new

### 3. Push to GitHub

```bash
git remote add origin https://github.com/YOUR_USERNAME/near-swift-client.git
git branch -M main
git push -u origin main
```

### 4. Create Release Tag

```bash
# Create annotated tag
git tag -a 1.0.0 -m "Version 1.0.0: Initial release"

# Push tag to GitHub
git push origin 1.0.0
```

### 5. Create GitHub Release

Using GitHub CLI:
```bash
gh release create 1.0.0 \
  --title "NEAR Swift Client v1.0.0" \
  --notes "Initial release of NEAR Swift Client with full JSON-RPC support"
```

Or manually at: https://github.com/YOUR_USERNAME/near-swift-client/releases/new

## Package Availability

Once published, the Swift packages will be available for use:

### In Package.swift:

```swift
dependencies: [
    .package(url: "https://github.com/YOUR_USERNAME/near-swift-client", from: "1.0.0")
],
targets: [
    .target(
        name: "MyApp",
        dependencies: [
            .product(name: "NEARJSONRPCTypes", package: "near-swift-client"),
            .product(name: "NEARJSONRPCClient", package: "near-swift-client")
        ]
    )
]
```

### In Xcode:

1. File → Add Package Dependencies
2. Enter: `https://github.com/YOUR_USERNAME/near-swift-client`
3. Select version: "Up to Next Major Version" → 1.0.0
4. Choose products: NEARJSONRPCTypes and/or NEARJSONRPCClient

## Version Management

Follow semantic versioning:
- MAJOR version for incompatible API changes
- MINOR version for backwards-compatible functionality
- PATCH version for backwards-compatible bug fixes

Example:
```bash
# Bug fix release
git tag -a 1.0.1 -m "Version 1.0.1: Fix validator decoding"

# New feature release  
git tag -a 1.1.0 -m "Version 1.1.0: Add transaction signing support"

# Breaking change
git tag -a 2.0.0 -m "Version 2.0.0: New API design"
```

## Swift Package Index

After publishing, submit to Swift Package Index for better discoverability:

1. Visit: https://swiftpackageindex.com/add-a-package
2. Enter your repository URL
3. Wait for indexing (usually within 24 hours)

## Package Naming Note

The packages in this project are named following Swift conventions:
- `NEARJSONRPCTypes` - Type definitions only
- `NEARJSONRPCClient` - Full client implementation

These are Swift packages, not NPM packages. The task.md incorrectly mentioned NPM packages, but this is a Swift/iOS project.

## Verification

After publishing, verify the packages work:

```bash
# Create test project
mkdir test-near-client && cd test-near-client
swift package init --type executable

# Add dependency and test
# ... edit Package.swift to add near-swift-client dependency
swift build
swift run
```

## Support

- Report issues: https://github.com/YOUR_USERNAME/near-swift-client/issues
- Discussions: https://github.com/YOUR_USERNAME/near-swift-client/discussions
- NEAR Community: https://t.me/NEARDev