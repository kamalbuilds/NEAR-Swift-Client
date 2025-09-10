#!/bin/bash

# Script to prepare NEAR Swift Client for release

echo "🚀 Preparing NEAR Swift Client for Release"
echo "=========================================="

# Ensure we're in the right directory
cd "$(dirname "$0")/.."

# Check if git is initialized
if [ ! -d .git ]; then
    echo "❌ Git not initialized. Please run:"
    echo "   git init"
    echo "   git remote add origin https://github.com/yourusername/near-swift-client.git"
    exit 1
fi

# Verify Package.swift
echo "📦 Verifying Package.swift..."
if swift package describe > /dev/null 2>&1; then
    echo "✅ Package.swift is valid"
else
    echo "❌ Package.swift validation failed"
    exit 1
fi

# Run tests
echo "🧪 Running tests..."
if swift test; then
    echo "✅ All tests passed"
else
    echo "❌ Tests failed. Fix before releasing."
    exit 1
fi

# Build all products
echo "🏗️  Building all products..."
swift build --product NEARJSONRPCTypes
swift build --product NEARJSONRPCClient
swift build --product generate

echo ""
echo "✅ Release preparation complete!"
echo ""
echo "📋 Next steps to publish Swift packages:"
echo ""
echo "1. Create a GitHub repository:"
echo "   gh repo create near-swift-client --public --description 'Swift client for NEAR Protocol JSON-RPC API'"
echo ""
echo "2. Push code to GitHub:"
echo "   git add ."
echo "   git commit -m 'Initial release of NEAR Swift Client'"
echo "   git push -u origin main"
echo ""
echo "3. Create a release tag:"
echo "   git tag -a 1.0.0 -m 'Version 1.0.0: Initial release'"
echo "   git push origin 1.0.0"
echo ""
echo "4. The Swift packages will be available at:"
echo "   https://github.com/yourusername/near-swift-client"
echo ""
echo "5. Users can add to their Package.swift:"
echo "   .package(url: \"https://github.com/yourusername/near-swift-client\", from: \"1.0.0\")"
echo ""
echo "📝 Note: Swift packages are distributed via Git URLs, not a central registry like NPM"