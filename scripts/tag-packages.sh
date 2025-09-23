#!/bin/bash
set -e

# Script to create package-specific git tags
# Usage: ./scripts/tag-packages.sh <version>
# Example: ./scripts/tag-packages.sh 1.2.3

VERSION=$1

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

print_error() {
    echo -e "${RED}❌ $1${NC}"
}

print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# Validate input
if [ -z "$VERSION" ]; then
    print_error "Version not specified"
    echo "Usage: $0 <version>"
    echo "Example: $0 1.2.3"
    exit 1
fi

# Validate version format (semantic versioning)
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+$ ]]; then
    print_error "Invalid version format: $VERSION"
    echo "Version must follow semantic versioning (e.g., 1.2.3)"
    exit 1
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    print_error "Not a git repository"
    exit 1
fi

# Check if working directory is clean
if [ -n "$(git status --porcelain)" ]; then
    print_warning "Working directory has uncommitted changes"
    read -p "Continue anyway? (y/N) " -n 1 -r
    echo
    if [[ ! $REPLY =~ ^[Yy]$ ]]; then
        exit 1
    fi
fi

print_info "Creating tags for version $VERSION"

# Tag names
MAIN_TAG="v${VERSION}"
TYPES_TAG="types-v${VERSION}"
CLIENT_TAG="client-v${VERSION}"

# Check if tags already exist
if git tag -l | grep -q "^${MAIN_TAG}$"; then
    print_error "Tag ${MAIN_TAG} already exists"
    exit 1
fi

if git tag -l | grep -q "^${TYPES_TAG}$"; then
    print_error "Tag ${TYPES_TAG} already exists"
    exit 1
fi

if git tag -l | grep -q "^${CLIENT_TAG}$"; then
    print_error "Tag ${CLIENT_TAG} already exists"
    exit 1
fi

# Get current commit
COMMIT=$(git rev-parse HEAD)
print_info "Current commit: ${COMMIT:0:8}"

# Create main version tag
print_info "Creating main version tag: $MAIN_TAG"
git tag -a "$MAIN_TAG" -m "Release version $VERSION"
print_success "Created tag: $MAIN_TAG"

# Create NEARJSONRPCTypes tag
print_info "Creating NEARJSONRPCTypes tag: $TYPES_TAG"
git tag -a "$TYPES_TAG" -m "NEARJSONRPCTypes version $VERSION"
print_success "Created tag: $TYPES_TAG"

# Create NEARJSONRPCClient tag
print_info "Creating NEARJSONRPCClient tag: $CLIENT_TAG"
git tag -a "$CLIENT_TAG" -m "NEARJSONRPCClient version $VERSION"
print_success "Created tag: $CLIENT_TAG"

# Summary
echo ""
print_success "All tags created successfully!"
echo ""
echo "Tags created:"
echo "  - $MAIN_TAG"
echo "  - $TYPES_TAG"
echo "  - $CLIENT_TAG"
echo ""

# Ask to push tags
read -p "Push tags to origin? (Y/n) " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Nn]$ ]]; then
    print_info "Pushing tags to origin..."

    git push origin "$MAIN_TAG"
    print_success "Pushed $MAIN_TAG"

    git push origin "$TYPES_TAG"
    print_success "Pushed $TYPES_TAG"

    git push origin "$CLIENT_TAG"
    print_success "Pushed $CLIENT_TAG"

    echo ""
    print_success "All tags pushed successfully!"
    echo ""
    print_info "View tags on GitHub:"

    # Try to get repository URL
    REPO_URL=$(git config --get remote.origin.url | sed 's/\.git$//')
    if [[ $REPO_URL == git@github.com:* ]]; then
        REPO_URL=$(echo "$REPO_URL" | sed 's/git@github.com:/https:\/\/github.com\//')
    fi

    if [ -n "$REPO_URL" ]; then
        echo "  $REPO_URL/releases/tag/$MAIN_TAG"
    fi
else
    echo ""
    print_info "Tags created locally but not pushed"
    echo "To push later, run:"
    echo "  git push origin $MAIN_TAG $TYPES_TAG $CLIENT_TAG"
fi

echo ""
print_info "Next steps:"
echo "  1. Create GitHub release at: ${REPO_URL}/releases/new"
echo "  2. Wait for Swift Package Index to index the release"
echo "  3. Verify packages at: https://swiftpackageindex.com"
