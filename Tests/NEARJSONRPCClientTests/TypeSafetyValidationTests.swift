import XCTest
@testable import NEARJSONRPCClient
@testable import NEARJSONRPCTypes

/// Comprehensive type safety validation tests
/// These tests MUST NOT swallow errors and MUST verify actual type correctness
final class TypeSafetyValidationTests: XCTestCase {

    // MARK: - Setup

    var client: NEARClient!

    override func setUp() async throws {
        try await super.setUp()
        // Use testnet RPC endpoint
        client = try NEARClient(url: "https://rpc.testnet.near.org")
    }

    // MARK: - Function Call Type Safety Tests

    func testFtMetadataTypeSafety() async throws {
        // This test MUST NOT use do-catch that swallows errors
        let result = try await client.callViewFunction(
            accountId: "wrap.testnet",
            methodName: "ft_metadata",
            args: "{}".data(using: .utf8)!
        )

        // Verify FunctionCallResult structure
        XCTAssertFalse(result.result.isEmpty, "Result bytes must not be empty")
        XCTAssertGreaterThan(result.blockHeight, 0, "Block height must be positive")
        XCTAssertEqual(result.blockHash.count, 44, "Block hash must be 44 chars (base58)")
        XCTAssertNotNil(result.logs, "Logs array must exist (may be empty)")

        // Verify the result can be decoded as FTMetadata
        struct FTMetadata: Codable {
            let spec: String
            let name: String
            let symbol: String
            let decimals: Int
            let icon: String?
            let reference: String?
            let referenceHash: String?

            enum CodingKeys: String, CodingKey {
                case spec, name, symbol, decimals, icon, reference
                case referenceHash = "reference_hash"
            }
        }

        let metadata = try result.decodeResult(as: FTMetadata.self)

        // Validate metadata structure
        XCTAssertTrue(metadata.spec.hasPrefix("ft-"), "Spec must start with 'ft-'")
        XCTAssertFalse(metadata.name.isEmpty, "Name must not be empty")
        XCTAssertFalse(metadata.symbol.isEmpty, "Symbol must not be empty")
        XCTAssertEqual(metadata.decimals, 24, "wNEAR has 24 decimals")

        print("✅ FT Metadata Type Safety Validated")
        print("  Name: \(metadata.name)")
        print("  Symbol: \(metadata.symbol)")
        print("  Decimals: \(metadata.decimals)")
    }

    func testViewAccountTypeSafety() async throws {
        // MUST NOT swallow errors
        let account = try await client.viewAccount(accountId: "wrap.testnet")

        // Validate ALL field types
        XCTAssertNotNil(UInt64(account.amount), "Amount must be valid numeric string")
        XCTAssertGreaterThan(UInt64(account.amount)!, 0, "Amount must be positive")

        XCTAssertNotNil(UInt64(account.locked), "Locked must be valid numeric string")
        XCTAssertGreaterThanOrEqual(UInt64(account.locked)!, 0, "Locked must be non-negative")

        XCTAssertEqual(account.codeHash.count, 44, "Code hash must be 44 chars (base58)")

        XCTAssertGreaterThan(account.storageUsage, 0, "Contract account must have storage usage")
        XCTAssertGreaterThanOrEqual(account.storagePaidAt, 0, "Storage paid at must be non-negative")

        XCTAssertGreaterThan(account.blockHeight, 0, "Block height must be positive")
        XCTAssertEqual(account.blockHash.count, 44, "Block hash must be 44 chars (base58)")

        print("✅ Account View Type Safety Validated")
        print("  Amount: \(account.amount) yoctoNEAR")
        print("  Storage: \(account.storageUsage) bytes")
        print("  Code Hash: \(account.codeHash)")
    }

    func testBlockQueryTypeSafety() async throws {
        let block = try await client.block(finality: .final)

        // Validate block structure
        XCTAssertFalse(block.author.isEmpty, "Author must not be empty")
        XCTAssertGreaterThan(block.header.height, 0, "Block height must be positive")
        XCTAssertEqual(block.header.hash.count, 44, "Hash must be 44 chars")
        XCTAssertEqual(block.header.prevHash.count, 44, "Previous hash must be 44 chars")

        // Validate numeric strings
        XCTAssertNotNil(UInt64(block.header.gasPrice), "Gas price must be numeric")
        XCTAssertNotNil(UInt64(block.header.totalSupply), "Total supply must be numeric")

        // Validate chunks
        XCTAssertGreaterThan(block.chunks.count, 0, "Block must have chunks")

        print("✅ Block Query Type Safety Validated")
        print("  Height: \(block.header.height)")
        print("  Chunks: \(block.chunks.count)")
    }

    // MARK: - Error Handling Type Safety Tests

    func testErrorHandlingReturnsTypedNEARError() async throws {
        do {
            // Try to query a definitely non-existent account
            _ = try await client.viewAccount(
                accountId: "this-account-definitely-does-not-exist-\(UUID().uuidString).testnet"
            )
            XCTFail("Should throw error for non-existent account")
        } catch let error as NEARRPCError {
            // SUCCESS: We got a typed NEAR error
            print("✅ Error Type Safety Validated")
            print("  Error Code: \(error.code)")
            print("  Error Type: \(error.errorCode)")
            print("  Message: \(error.message)")

            // Verify we got a valid NEAR error code (any error code is valid here)
            XCTAssert(error.code < 0, "Error code should be negative")
            XCTAssertNotEqual(error.errorCode, .unknown, "Should be a known error type")

            // Verify we have an error message
            XCTAssertFalse(error.message.isEmpty, "Error should have message")

            print("  Error Details: \(error.errorDescription ?? "none")")
        } catch {
            // FAILURE: We got a generic error instead of NEARRPCError
            XCTFail("Should throw NEARRPCError, got: \(type(of: error)) - \(error)")
        }
    }

    func testInvalidMethodReturnsTypedError() async throws {
        do {
            _ = try await client.callViewFunction(
                accountId: "wrap.testnet",
                methodName: "this_method_does_not_exist_\(UUID().uuidString)",
                args: "{}".data(using: .utf8)!
            )
            XCTFail("Should throw error for invalid method")
        } catch let error as NEARRPCError {
            // SUCCESS: Got typed error
            print("✅ Invalid Method Error Type Safety Validated")
            print("  Error Code: \(error.errorCode)")
            print("  Message: \(error.message)")

            // Should be handler or contract execution error
            XCTAssert(
                error.errorCode == .contractExecutionError || error.errorCode == .handlerError,
                "Should be contract execution or handler error"
            )
        } catch {
            XCTFail("Should throw NEARRPCError, got: \(type(of: error))")
        }
    }

    func testInvalidBlockHeightReturnsTypedError() async throws {
        do {
            _ = try await client.blockByHeight(999_999_999_999)
            XCTFail("Should throw error for invalid block height")
        } catch let error as NEARRPCError {
            // SUCCESS
            print("✅ Invalid Block Error Type Safety Validated")
            print("  Error Code: \(error.errorCode)")

            // Should be unknown block or handler error
            XCTAssert(
                error.errorCode == .unknownBlock || error.errorCode == .handlerError,
                "Should be unknown block or handler error"
            )
        } catch {
            XCTFail("Should throw NEARRPCError, got: \(type(of: error))")
        }
    }

    // MARK: - Status and Network Tests

    func testNetworkStatusTypeSafety() async throws {
        let status = try await client.status()

        // Validate Version type
        XCTAssertFalse(status.version.version.isEmpty, "Version string should not be empty")
        XCTAssertFalse(status.version.build.isEmpty, "Build string should not be empty")

        // Validate chain ID
        XCTAssertEqual(status.chainId, "testnet", "Chain ID must be 'testnet'")

        // Validate protocol versions
        XCTAssertGreaterThan(status.protocolVersion, 0, "Protocol version must be positive")
        XCTAssertGreaterThan(status.latestProtocolVersion, 0, "Latest protocol version must be positive")

        // Validate SyncInfo
        XCTAssertGreaterThan(status.syncInfo.latestBlockHeight, 0, "Block height must be positive")
        XCTAssertEqual(status.syncInfo.latestBlockHash.count, 44, "Block hash should be 44 chars")

        print("✅ Status Type Safety Validated")
        print("  Chain ID: \(status.chainId)")
        print("  Version: \(status.version.version)")
        print("  Latest Block: \(status.syncInfo.latestBlockHeight)")
    }

    // MARK: - Integration Tests

    func testFullWorkflow() async throws {
        // Test a complete workflow to ensure all types work together

        // 1. Get network status
        let status = try await client.status()
        XCTAssertEqual(status.chainId, "testnet")

        // 2. Get latest block
        let block = try await client.block(finality: .final)
        XCTAssertGreaterThan(block.header.height, 0)

        // 3. Query an account
        let account = try await client.viewAccount(accountId: "wrap.testnet")
        XCTAssertGreaterThan(account.storageUsage, 0)

        // 4. Call a view function
        let result = try await client.callViewFunction(
            accountId: "wrap.testnet",
            methodName: "ft_metadata",
            args: "{}".data(using: .utf8)!
        )
        XCTAssertFalse(result.result.isEmpty)

        // 5. Test error handling
        do {
            _ = try await client.viewAccount(accountId: "nonexistent-\(UUID().uuidString).testnet")
            XCTFail("Should throw error")
        } catch is NEARRPCError {
            // Expected - typed error
        } catch {
            XCTFail("Should throw NEARRPCError, got: \(type(of: error))")
        }

        print("✅ Full Workflow Type Safety Validated")
    }
}
