# Changelog

All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.1](https://github.com/kamalbuilds/NEAR-Swift-Client/compare/v1.0.0...v1.0.1) (2025-10-31)


### Bug Fixes

* resolve Bundle.module fatalError blocking all CI workflows ([ccd68f3](https://github.com/kamalbuilds/NEAR-Swift-Client/commit/ccd68f3b4d8fd947612973b6135135bda8486d62))
* resolve PyYAML import error and all SwiftLint violations ([7a3b92d](https://github.com/kamalbuilds/NEAR-Swift-Client/commit/7a3b92da90895ff39f2ca13606b0edb7b0c0ad46))

## [Unreleased]

### Added
- Initial implementation of NEAR Swift client
- Automated code generation from OpenAPI specification
- Two separate packages: NEARJSONRPCTypes and NEARJSONRPCClient
- Automatic snake_case to camelCase conversion
- JSON-RPC path patching for correct NEAR implementation
- GitHub Actions automation for daily updates
- Comprehensive test suite with 80%+ coverage goal
- Full documentation and usage examples
- SwiftLint configuration for code quality
- Support for all major NEAR RPC methods

### Features
- Type-safe Swift client generation
- Automatic daily updates from NEAR OpenAPI spec
- Cross-platform support (iOS, macOS, tvOS, watchOS, visionOS)
- Minimal dependencies
- Full async/await support
- Comprehensive error handling
- Mock-friendly design for testing

## [1.0.0] - TBD

### Added
- First stable release
- Complete NEAR RPC API coverage
- Production-ready implementation
