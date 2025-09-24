# Publishing NEAR Swift Client Packages

## Overview

This document describes the complete process for publishing and distributing the NEAR Swift Client packages. Unlike npm packages, Swift packages are distributed through Git repositories and accessed via Swift Package Manager (SPM).

## Table of Contents

1. [Prerequisites](#prerequisites)
2. [Package Structure](#package-structure)
3. [Publishing Process](#publishing-process)
4. [Swift Package Index Registration](#swift-package-index-registration)
5. [Version Management](#version-management)
6. [Installation Guide](#installation-guide)
7. [Troubleshooting](#troubleshooting)

## Prerequisites

Before publishing, ensure:

- ✅ All tests passing (minimum 80% coverage)
- ✅ SwiftLint validation passing
- ✅ Documentation complete and up-to-date
- ✅ CHANGELOG.md updated with changes
- ✅ LICENSE file present (MIT)
- ✅ GitHub repository created and accessible
- ✅ Git tags follow semantic versioning

## Package Structure

This project provides two distinct Swift packages:

### NEARJSONRPCTypes
- **Purpose**: Type definitions and serialization/deserialization
- **Dependencies**: OpenAPIRuntime only
- **Use Case**: Lightweight integration when you only need types

### NEARJSONRPCClient
- **Purpose**: Full RPC client implementation
- **Dependencies**: NEARJSONRPCTypes, OpenAPIRuntime, OpenAPIURLSession
- **Use Case**: Complete JSON-RPC client with typed methods

## Publishing Process

### 1. Automated Publishing (Recommended)

The repository uses GitHub Actions for automated publishing:

#### How It Works

1. **Code Generation Workflow** (`generate.yml`):
   - Runs daily or on push to main
   - Downloads latest OpenAPI spec from nearcore
   - Generates Swift code if spec changed
   - Runs tests and creates PR for review

2. **Release Workflow** (via release-please):
   - Analyzes conventional commits
   - Automatically creates release PR
   - Updates CHANGELOG.md
   - Bumps version numbers
   - Creates GitHub release when merged

#### Triggering a Release

```bash
# Make changes using conventional commits
git commit -m "feat: add transaction signing support"
git commit -m "fix: correct block hash encoding"

# Push to main (or merge PR)
git push origin main

# Release-please will:
# 1. Create a release PR with updated version
# 2. Update CHANGELOG.md
# 3. When you merge the release PR, create a GitHub release
```

### 2. Manual Publishing

If you need to publish manually:

#### Step 1: Prepare the Release

```bash
# Ensure all changes are committed
git status

# Run tests locally
swift test --enable-code-coverage

# Check coverage meets 80% threshold
swift test --enable-code-coverage | grep "test coverage"

# Run linting
swiftlint
```

#### Step 2: Update Version

```bash
# Update version in these files:
# - .release-please-manifest.json
# - CHANGELOG.md (add new section)

# Commit version changes
git add .
git commit -m "chore: prepare v1.1.0 release"
```

#### Step 3: Create Git Tag

```bash
# Create annotated tag with semantic version
git tag -a 1.1.0 -m "Release version 1.1.0

Features:
- Add transaction signing support
- Improve error handling

Bug Fixes:
- Fix block hash encoding issue
"

# Push tag to GitHub
git push origin 1.1.0
```

#### Step 4: Create GitHub Release

Using GitHub CLI (recommended):

```bash
gh release create 1.1.0 \
  --title "NEAR Swift Client v1.1.0" \
  --notes-file CHANGELOG.md \
  --latest
```

Or manually:
1. Go to https://github.com/YOUR_USERNAME/near-swift-client/releases/new
2. Select tag: `1.1.0`
3. Title: `NEAR Swift Client v1.1.0`
4. Description: Copy from CHANGELOG.md
5. Click "Publish release"

### 3. Verification

After publishing, verify the package works:

```bash
# Create test project
mkdir test-near-integration && cd test-near-integration

# Initialize Swift package
swift package init --type executable

# Edit Package.swift to add dependency
cat > Package.swift << 'EOF'
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "test-near-integration",
    platforms: [.macOS(.v13)],
    dependencies: [
        .package(url: "https://github.com/YOUR_USERNAME/near-swift-client", from: "1.1.0")
    ],
    targets: [
        .executableTarget(
            name: "test-near-integration",
            dependencies: [
                .product(name: "NEARJSONRPCClient", package: "near-swift-client")
            ]
        )
    ]
)
EOF

# Build and verify
swift build
```

## Swift Package Index Registration

The Swift Package Index (https://swiftpackageindex.com) provides better discoverability and documentation.

### Registration Steps

1. **Visit Swift Package Index**
   - Go to https://swiftpackageindex.com/add-a-package

2. **Submit Repository URL**
   - Enter: `https://github.com/YOUR_USERNAME/near-swift-client`
   - Click "Add Package"

3. **Wait for Indexing**
   - Usually completes within 24 hours
   - You'll receive an email confirmation

4. **Verify Indexing**
   - Check https://swiftpackageindex.com/YOUR_USERNAME/near-swift-client
   - Verify all platforms show as compatible
   - Check that documentation is generated

### Benefits of Swift Package Index

- ✅ Automatic documentation generation
- ✅ Platform compatibility badges
- ✅ License information
- ✅ Star history and statistics
- ✅ Better search visibility
- ✅ Build status indicators

## Version Management

This project follows [Semantic Versioning 2.0.0](https://semver.org/):

### Version Format: MAJOR.MINOR.PATCH

- **MAJOR**: Incompatible API changes (e.g., 1.0.0 → 2.0.0)
- **MINOR**: Backwards-compatible functionality (e.g., 1.0.0 → 1.1.0)
- **PATCH**: Backwards-compatible bug fixes (e.g., 1.0.0 → 1.0.1)

### Examples

```bash
# Bug fix: Correct encoding issue
git tag -a 1.0.1 -m "fix: correct base64 encoding for public keys"
# Version: 1.0.0 → 1.0.1

# New feature: Add transaction support
git tag -a 1.1.0 -m "feat: add transaction signing support"
# Version: 1.0.0 → 1.1.0

# Breaking change: New API design
git tag -a 2.0.0 -m "feat!: redesign client API for better ergonomics

BREAKING CHANGE: Client initialization now requires configuration object"
# Version: 1.x.x → 2.0.0
```

### Pre-release Versions

For beta or release candidate versions:

```bash
# Beta release
git tag -a 1.1.0-beta.1 -m "chore: beta release for v1.1.0"

# Release candidate
git tag -a 1.1.0-rc.1 -m "chore: release candidate for v1.1.0"
```

### Conventional Commits

Use conventional commits for automatic changelog generation:

```bash
# Features
git commit -m "feat: add block streaming support"

# Bug fixes
git commit -m "fix: handle null values in block data"

# Documentation
git commit -m "docs: update API examples"

# Performance
git commit -m "perf: optimize JSON parsing"

# Breaking changes
git commit -m "feat!: redesign error handling

BREAKING CHANGE: Errors now use Swift's Error protocol"
```

## Installation Guide

### For Swift Package Manager (Command Line)

Add to `Package.swift`:

```swift
// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "MyNearApp",
    platforms: [
        .macOS(.v13),
        .iOS(.v16)
    ],
    dependencies: [
        .package(url: "https://github.com/YOUR_USERNAME/near-swift-client", from: "1.0.0")
    ],
    targets: [
        .target(
            name: "MyNearApp",
            dependencies: [
                // Use types only
                .product(name: "NEARJSONRPCTypes", package: "near-swift-client"),

                // Or use full client
                .product(name: "NEARJSONRPCClient", package: "near-swift-client")
            ]
        )
    ]
)
```

### For Xcode Projects

1. **File → Add Package Dependencies**
2. Enter repository URL: `https://github.com/YOUR_USERNAME/near-swift-client`
3. **Dependency Rule**: "Up to Next Major Version" → `1.0.0`
4. Select products:
   - `NEARJSONRPCTypes` (types only)
   - `NEARJSONRPCClient` (full client)
5. Click **Add Package**

### Version Compatibility

| Package Version | Swift Version | Platforms |
|----------------|---------------|-----------|
| 1.0.0+         | 5.9+          | macOS 13+, iOS 16+, tvOS 16+, watchOS 9+, visionOS 1+ |

## Troubleshooting

### Issue: Package Resolution Fails

**Symptom**: `error: Dependencies could not be resolved`

**Solutions**:

```bash
# Clear package cache
rm -rf .build
rm Package.resolved

# Reset package cache globally
swift package reset

# Update dependencies
swift package update

# Resolve dependencies
swift package resolve
```

### Issue: Version Conflict

**Symptom**: `error: package 'near-swift-client' is required using two different revision-based requirements`

**Solution**:

```bash
# Update to specific version
.package(url: "https://github.com/YOUR_USERNAME/near-swift-client", exact: "1.0.0")

# Or use branch for development
.package(url: "https://github.com/YOUR_USERNAME/near-swift-client", branch: "main")
```

### Issue: GitHub Release Not Created

**Symptom**: Tag pushed but no GitHub release appears

**Solution**:

```bash
# Manually create release from tag
gh release create 1.0.0 --title "v1.0.0" --notes "Release notes"

# Or via web interface
# Go to: https://github.com/YOUR_USERNAME/near-swift-client/releases/new
```

### Issue: Swift Package Index Not Updating

**Symptom**: Package shows old version on swiftpackageindex.com

**Solutions**:

1. **Wait 24 hours** - Indexing can take time
2. **Check build logs** - Visit your package page and check build status
3. **Verify tag format** - Must be semantic version (1.0.0, not v1.0.0)
4. **Contact support** - Use GitHub issues on swiftpackageindex/SwiftPackageIndex-Server

### Issue: Tests Fail in CI but Pass Locally

**Symptom**: GitHub Actions tests fail but `swift test` passes locally

**Solutions**:

```bash
# Use same Swift version as CI
swift --version  # Should be 5.9+

# Run with same flags as CI
swift test --enable-code-coverage

# Check for platform-specific issues
swift test --filter NEARJSONRPCClientTests
```

### Issue: Coverage Below 80%

**Symptom**: PR blocked due to insufficient test coverage

**Solution**:

```bash
# Generate detailed coverage report
swift test --enable-code-coverage

# View coverage per file
xcrun llvm-cov report \
  .build/debug/near-swift-clientPackageTests.xctest/Contents/MacOS/near-swift-clientPackageTests \
  -instr-profile .build/debug/codecov/default.profdata

# Add tests for uncovered code
```

## Support and Resources

### Documentation
- **README**: General overview and quick start
- **CONTRIBUTING**: Development guidelines
- **RELEASE_PROCESS**: Detailed release procedures
- **VERSIONING**: Version management strategy

### Community
- **Issues**: https://github.com/YOUR_USERNAME/near-swift-client/issues
- **Discussions**: https://github.com/YOUR_USERNAME/near-swift-client/discussions
- **NEAR Community**: https://t.me/NEARDev
- **Tools Community**: https://t.me/NEAR_Tools_Community_Group

### External Resources
- [Swift Package Manager](https://swift.org/package-manager/)
- [Swift Package Index](https://swiftpackageindex.com)
- [Semantic Versioning](https://semver.org/)
- [Conventional Commits](https://www.conventionalcommits.org/)
- [NEAR Protocol](https://near.org)

## Continuous Improvement

This publishing process is continuously improved based on community feedback. If you encounter issues not covered here:

1. Check GitHub Issues for similar problems
2. Join NEAR Tools Community for real-time help
3. Submit a PR to improve this documentation
4. Report bugs or suggest enhancements

---

Last Updated: 2024-10-26
Version: 1.0.0
