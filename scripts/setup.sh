#!/bin/bash

# Setup script for NEAR Swift Client development

echo "🚀 Setting up NEAR Swift Client development environment..."

# Check Swift version
SWIFT_VERSION=$(swift --version | grep -o 'Swift version [0-9.]*' | cut -d' ' -f3)
REQUIRED_VERSION="5.9"

if [ "$(printf '%s\n' "$REQUIRED_VERSION" "$SWIFT_VERSION" | sort -V | head -n1)" != "$REQUIRED_VERSION" ]; then
    echo "❌ Swift $REQUIRED_VERSION or later is required. Current version: $SWIFT_VERSION"
    exit 1
fi

echo "✅ Swift version: $SWIFT_VERSION"

# Install SwiftLint if on macOS
if [[ "$OSTYPE" == "darwin"* ]]; then
    if ! command -v swiftlint &> /dev/null; then
        echo "📦 Installing SwiftLint..."
        brew install swiftlint
    else
        echo "✅ SwiftLint is installed"
    fi
fi

# Download OpenAPI spec
echo "⬇️  Downloading NEAR OpenAPI specification..."
curl -o openapi.json https://raw.githubusercontent.com/near/nearcore/master/chain/jsonrpc/openapi/openapi.json

# Build the project
echo "🏗️  Building project..."
swift build

# Run tests
echo "🧪 Running tests..."
swift test

echo "✨ Setup complete! You can now run:"
echo "  - swift run generate    # Generate Swift client"
echo "  - swift test           # Run tests"
echo "  - swift build          # Build packages"