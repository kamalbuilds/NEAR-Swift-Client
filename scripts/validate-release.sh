#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_header() {
    echo -e "\n${BLUE}========================================${NC}"
    echo -e "${BLUE}$1${NC}"
    echo -e "${BLUE}========================================${NC}\n"
}

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Track validation status
VALIDATION_FAILED=0

# Main validation script
print_header "NEAR Swift Client - Release Validation"

# 1. Check Swift version
print_info "Checking Swift version..."
SWIFT_VERSION=$(swift --version | head -n 1)
print_success "Swift version: $SWIFT_VERSION"

# 2. Clean build directory
print_header "Cleaning build directory"
if [ -d ".build" ]; then
    rm -rf .build
    print_success "Build directory cleaned"
else
    print_info "Build directory doesn't exist, skipping clean"
fi

# 3. Build the project
print_header "Building project"
if swift build; then
    print_success "Build successful"
else
    print_error "Build failed"
    VALIDATION_FAILED=1
fi

# 4. Run tests
print_header "Running tests"
if swift test --enable-code-coverage; then
    print_success "All tests passed"
else
    print_error "Tests failed"
    VALIDATION_FAILED=1
fi

# 5. Check code coverage
print_header "Checking code coverage"

# Find the test binary
TEST_BINARY=$(find .build/debug -name "*PackageTests.xctest" -type d | head -n 1)

if [ -z "$TEST_BINARY" ]; then
    print_warning "Could not find test binary, skipping coverage check"
else
    # Generate coverage report
    COVERAGE_FILE=".build/debug/codecov/default.profdata"

    if [ -f "$COVERAGE_FILE" ]; then
        # Export coverage
        xcrun llvm-cov export \
            "$TEST_BINARY/Contents/MacOS/near-swift-clientPackageTests" \
            -instr-profile "$COVERAGE_FILE" \
            -format="lcov" > coverage.lcov 2>/dev/null || true

        # Calculate coverage percentage
        if [ -f "coverage.lcov" ]; then
            # Use lcov if available, otherwise parse manually
            if command -v lcov &> /dev/null; then
                COVERAGE=$(lcov --summary coverage.lcov 2>&1 | grep lines | awk '{print $2}' | sed 's/%//')
            else
                # Fallback: basic parsing
                LINES_FOUND=$(grep -E "^LF:" coverage.lcov | awk -F: '{s+=$2} END {print s}')
                LINES_HIT=$(grep -E "^LH:" coverage.lcov | awk -F: '{s+=$2} END {print s}')
                if [ "$LINES_FOUND" -gt 0 ]; then
                    COVERAGE=$(awk "BEGIN {printf \"%.2f\", ($LINES_HIT / $LINES_FOUND) * 100}")
                else
                    COVERAGE="0"
                fi
            fi

            print_info "Code coverage: ${COVERAGE}%"

            # Check if coverage meets threshold
            THRESHOLD=80
            if (( $(echo "$COVERAGE >= $THRESHOLD" | bc -l) )); then
                print_success "Coverage ${COVERAGE}% meets threshold (>=${THRESHOLD}%)"
            else
                print_error "Coverage ${COVERAGE}% is below threshold (${THRESHOLD}%)"
                VALIDATION_FAILED=1
            fi
        else
            print_warning "Could not generate coverage report"
        fi
    else
        print_warning "Coverage profile not found at $COVERAGE_FILE"
    fi
fi

# 6. Validate package structure
print_header "Validating package structure"

# Check if Package.swift exists
if [ ! -f "Package.swift" ]; then
    print_error "Package.swift not found"
    VALIDATION_FAILED=1
else
    print_success "Package.swift found"
fi

# Validate package manifest
if swift package dump-package > /dev/null 2>&1; then
    print_success "Package manifest is valid"

    # Check for required products
    PACKAGE_JSON=$(swift package dump-package)

    if echo "$PACKAGE_JSON" | grep -q "NEARJSONRPCTypes"; then
        print_success "NEARJSONRPCTypes product found"
    else
        print_error "NEARJSONRPCTypes product not found"
        VALIDATION_FAILED=1
    fi

    if echo "$PACKAGE_JSON" | grep -q "NEARJSONRPCClient"; then
        print_success "NEARJSONRPCClient product found"
    else
        print_error "NEARJSONRPCClient product not found"
        VALIDATION_FAILED=1
    fi
else
    print_error "Invalid package manifest"
    VALIDATION_FAILED=1
fi

# 7. Check documentation files
print_header "Checking documentation"

REQUIRED_DOCS=("README.md" "LICENSE" "CHANGELOG.md")
for doc in "${REQUIRED_DOCS[@]}"; do
    if [ -f "$doc" ]; then
        print_success "$doc found"
    else
        print_error "$doc not found"
        VALIDATION_FAILED=1
    fi
done

# Check for RELEASING.md in docs
if [ -f "docs/RELEASING.md" ] || [ -f "../docs/RELEASING.md" ]; then
    print_success "RELEASING.md found"
else
    print_warning "RELEASING.md not found (recommended for contributors)"
fi

# 8. Run SwiftLint (if available)
print_header "Running SwiftLint"

if command -v swiftlint &> /dev/null; then
    if swiftlint; then
        print_success "SwiftLint passed with no warnings"
    else
        print_error "SwiftLint found issues"
        VALIDATION_FAILED=1
    fi
else
    print_warning "SwiftLint not installed, skipping"
    print_info "Install with: brew install swiftlint"
fi

# 9. Check .spi.yml configuration
print_header "Checking Swift Package Index configuration"

if [ -f ".spi.yml" ]; then
    print_success ".spi.yml found"

    # Basic validation
    if grep -q "NEARJSONRPCTypes" .spi.yml && grep -q "NEARJSONRPCClient" .spi.yml; then
        print_success ".spi.yml includes both packages"
    else
        print_warning ".spi.yml might be missing package configurations"
    fi
else
    print_warning ".spi.yml not found"
    print_info "Create .spi.yml for Swift Package Index compatibility"
fi

# 10. Check GitHub workflows
print_header "Checking GitHub workflows"

WORKFLOWS_DIR=".github/workflows"
if [ -d "$WORKFLOWS_DIR" ]; then
    WORKFLOW_COUNT=$(find "$WORKFLOWS_DIR" -name "*.yml" -o -name "*.yaml" | wc -l | tr -d ' ')
    print_success "Found $WORKFLOW_COUNT workflow(s)"

    # Check for specific workflows
    if [ -f "$WORKFLOWS_DIR/test.yml" ]; then
        print_success "Test workflow found"
    else
        print_warning "Test workflow not found"
    fi

    if [ -f "$WORKFLOWS_DIR/release.yml" ]; then
        print_success "Release workflow found"
    else
        print_warning "Release workflow not found"
    fi
else
    print_warning "No GitHub workflows found"
fi

# 11. Verify git status
print_header "Checking git status"

if git rev-parse --git-dir > /dev/null 2>&1; then
    # Check for uncommitted changes
    if [ -z "$(git status --porcelain)" ]; then
        print_success "Working directory is clean"
    else
        print_warning "Uncommitted changes detected"
        git status --short
    fi

    # Check current branch
    CURRENT_BRANCH=$(git rev-parse --abbrev-ref HEAD)
    print_info "Current branch: $CURRENT_BRANCH"

    # Check for main/master branch
    if [ "$CURRENT_BRANCH" = "main" ] || [ "$CURRENT_BRANCH" = "master" ]; then
        print_success "On main branch"
    else
        print_info "Not on main branch (current: $CURRENT_BRANCH)"
    fi
else
    print_warning "Not a git repository"
fi

# 12. Check for release configuration
print_header "Checking release configuration"

if [ -f ".release-please-manifest.json" ]; then
    print_success "Release Please manifest found"
else
    print_warning "Release Please manifest not found"
fi

if [ -f "release-please-config.json" ]; then
    print_success "Release Please config found"
else
    print_warning "Release Please config not found"
fi

# 13. Performance check (optional)
print_header "Performance validation"
print_info "Checking build time..."

BUILD_START=$(date +%s)
swift build -c release > /dev/null 2>&1
BUILD_END=$(date +%s)
BUILD_TIME=$((BUILD_END - BUILD_START))

print_success "Release build completed in ${BUILD_TIME}s"

if [ $BUILD_TIME -gt 60 ]; then
    print_warning "Build time is quite long (${BUILD_TIME}s)"
fi

# Final summary
print_header "Validation Summary"

if [ $VALIDATION_FAILED -eq 0 ]; then
    echo -e "${GREEN}"
    echo "╔═══════════════════════════════════════╗"
    echo "║                                       ║"
    echo "║   ✅ ALL VALIDATIONS PASSED! ✅       ║"
    echo "║                                       ║"
    echo "║   Ready for release!                  ║"
    echo "║                                       ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    exit 0
else
    echo -e "${RED}"
    echo "╔═══════════════════════════════════════╗"
    echo "║                                       ║"
    echo "║   ❌ VALIDATION FAILED! ❌            ║"
    echo "║                                       ║"
    echo "║   Please fix the issues above         ║"
    echo "║   before proceeding with release      ║"
    echo "║                                       ║"
    echo "╚═══════════════════════════════════════╝"
    echo -e "${NC}"
    exit 1
fi
