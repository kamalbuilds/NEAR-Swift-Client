#!/bin/bash

# Script to publish Swift packages

echo "📦 Publishing NEAR Swift Client packages..."

# Ensure we're on main branch
CURRENT_BRANCH=$(git branch --show-current)
if [ "$CURRENT_BRANCH" != "main" ]; then
    echo "❌ Must be on main branch to publish. Current branch: $CURRENT_BRANCH"
    exit 1
fi

# Ensure working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    echo "❌ Working directory is not clean. Please commit or stash changes."
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
swift test
if [ $? -ne 0 ]; then
    echo "❌ Tests failed. Fix tests before publishing."
    exit 1
fi

# Check code coverage
echo "📊 Checking code coverage..."
swift test --enable-code-coverage
# This would normally include coverage checking logic

# Build for release
echo "🏗️  Building release..."
swift build -c release

# Tag the release
echo "🏷️  Creating release tag..."
VERSION=$(grep 'let version' Sources/NEARJSONRPCClient/Version.swift | cut -d'"' -f2)
git tag -a "v$VERSION" -m "Release version $VERSION"

echo "✅ Package ready for publishing!"
echo "Next steps:"
echo "1. Push tags: git push origin v$VERSION"
echo "2. Create GitHub release"
echo "3. Swift packages will be automatically available via the git URL"