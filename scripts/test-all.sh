#!/bin/bash

# Comprehensive test script for NEAR Swift Client

set -e

echo "🧪 Running NEAR Swift Client Test Suite"
echo "======================================"

# Colors for output
GREEN='\033[0;32m'
RED='\033[0;31m'
NC='\033[0m' # No Color

# Test counter
TESTS_PASSED=0
TESTS_FAILED=0

# Function to run a test
run_test() {
    local test_name=$1
    local test_command=$2
    
    echo -n "Running $test_name... "
    
    if eval "$test_command" > /dev/null 2>&1; then
        echo -e "${GREEN}✓${NC}"
        ((TESTS_PASSED++))
    else
        echo -e "${RED}✗${NC}"
        ((TESTS_FAILED++))
    fi
}

# Clean build
echo "🧹 Cleaning build..."
swift package clean

# Build packages
echo "🏗️  Building packages..."
run_test "Build NEARJSONRPCTypes" "swift build --product NEARJSONRPCTypes"
run_test "Build NEARJSONRPCClient" "swift build --product NEARJSONRPCClient"
run_test "Build Generate tool" "swift build --product generate"

# Run unit tests
echo ""
echo "🧪 Running unit tests..."
run_test "NEARJSONRPCTypes tests" "swift test --filter NEARJSONRPCTypesTests"
run_test "NEARJSONRPCClient tests" "swift test --filter NEARJSONRPCClientTests"

# Check code coverage
echo ""
echo "📊 Generating code coverage..."
swift test --enable-code-coverage

# Generate coverage report if llvm-cov is available
if command -v xcrun &> /dev/null; then
    echo "📈 Coverage report:"
    xcrun llvm-cov report \
        .build/debug/near-swift-clientPackageTests.xctest/Contents/MacOS/near-swift-clientPackageTests \
        -instr-profile .build/debug/codecov/default.profdata \
        -ignore-filename-regex="\.build|Tests" || true
fi

# Lint code if SwiftLint is installed
if command -v swiftlint &> /dev/null; then
    echo ""
    echo "🎨 Running SwiftLint..."
    run_test "SwiftLint" "swiftlint lint --quiet"
fi

# Test examples build
echo ""
echo "📚 Testing examples..."
run_test "Command line example" "cd Examples/NEARExample && swift build"

# Summary
echo ""
echo "======================================="
echo "Test Summary:"
echo "  Passed: ${GREEN}$TESTS_PASSED${NC}"
echo "  Failed: ${RED}$TESTS_FAILED${NC}"
echo ""

if [ $TESTS_FAILED -eq 0 ]; then
    echo -e "${GREEN}✅ All tests passed!${NC}"
    exit 0
else
    echo -e "${RED}❌ Some tests failed${NC}"
    exit 1
fi