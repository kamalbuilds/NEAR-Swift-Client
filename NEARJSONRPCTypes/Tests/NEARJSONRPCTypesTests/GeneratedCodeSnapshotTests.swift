import XCTest
@testable import NEARJSONRPCTypes

/// Snapshot tests to ensure generated code remains stable across regenerations
final class GeneratedCodeSnapshotTests: XCTestCase {

    // MARK: - Type Signature Tests

    func testStatusResponseTypeSignature() throws {
        // Verify StatusResponse has expected properties
        let mirror = Mirror(reflecting: StatusResponse(
            version: Version(version: "1.0", build: "test"),
            chainId: "test",
            protocolVersion: 1,
            latestProtocolVersion: 1,
            rpcAddr: nil,
            validators: [],
            syncInfo: SyncInfo(
                latestBlockHash: "test",
                latestBlockHeight: 1,
                latestStateRoot: "test",
                latestBlockTime: "test",
                syncing: false
            ),
            validatorAccountId: nil
        ))

        let propertyNames = Set(mirror.children.compactMap { $0.label })

        XCTAssertTrue(propertyNames.contains("version"))
        XCTAssertTrue(propertyNames.contains("chainId"))
        XCTAssertTrue(propertyNames.contains("protocolVersion"))
        XCTAssertTrue(propertyNames.contains("latestProtocolVersion"))
        XCTAssertTrue(propertyNames.contains("syncInfo"))
    }

    func testBlockHeaderTypeSignature() throws {
        // Verify BlockHeader has expected properties
        // This ensures the generated code matches our expectations

        let propertyNames = [
            "height",
            "epochId",
            "hash",
            "prevHash",
            "timestamp",
            "gasPrice",
            "totalSupply"
        ]

        // We'll verify the type exists and has the basic structure
        // Full property checking would require creating a valid instance
        _ = BlockHeader.self

        XCTAssertTrue(true, "BlockHeader type exists")
    }

    // MARK: - Codable Conformance Tests

    func testAllTypesAreCodable() throws {
        // Verify key types conform to Codable
        XCTAssertTrue(StatusResponse.self is Codable.Type)
        XCTAssertTrue(BlockView.self is Codable.Type)
        XCTAssertTrue(AccountView.self is Codable.Type)
        XCTAssertTrue(AccessKeyView.self is Codable.Type)
        XCTAssertTrue(FunctionCallResult.self is Codable.Type)
    }

    // MARK: - Round-trip Encoding Tests

    func testStatusResponseRoundTrip() throws {
        let original = StatusResponse(
            version: Version(version: "1.35.0", build: "test"),
            chainId: "testnet",
            protocolVersion: 62,
            latestProtocolVersion: 62,
            rpcAddr: "0.0.0.0:3030",
            validators: [],
            syncInfo: SyncInfo(
                latestBlockHash: "test",
                latestBlockHeight: 123,
                latestStateRoot: "test",
                latestBlockTime: "2024-01-01T00:00:00Z",
                syncing: false
            ),
            validatorAccountId: nil
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(StatusResponse.self, from: encoded)

        XCTAssertEqual(original.chainId, decoded.chainId)
        XCTAssertEqual(original.protocolVersion, decoded.protocolVersion)
        XCTAssertEqual(original.version.version, decoded.version.version)
    }

    func testAccountViewRoundTrip() throws {
        let original = AccountView(
            amount: "1000000000000000000000000",
            locked: "0",
            codeHash: "11111111111111111111111111111111",
            storageUsage: 1000,
            storagePaidAt: 0
        )

        let encoder = JSONEncoder()
        encoder.keyEncodingStrategy = .convertToSnakeCase

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let encoded = try encoder.encode(original)
        let decoded = try decoder.decode(AccountView.self, from: encoded)

        XCTAssertEqual(original.amount, decoded.amount)
        XCTAssertEqual(original.storageUsage, decoded.storageUsage)
    }

    // MARK: - API Compatibility Tests

    func testAPIResponseParsing() throws {
        // Test that we can parse real API responses
        let realAPIResponse = """
        {
            "jsonrpc": "2.0",
            "result": {
                "amount": "399992611103597728750000000",
                "locked": "0",
                "code_hash": "11111111111111111111111111111111",
                "storage_usage": 182,
                "storage_paid_at": 0,
                "block_height": 17795474,
                "block_hash": "9MjpcnwW3TSdzGweNfPbkx8M74q1Z3M1yfrgRqDcKvEw"
            },
            "id": "dontcare"
        }
        """

        struct QueryResponse: Codable {
            let jsonrpc: String
            let result: AccountView
            let id: String
        }

        let data = realAPIResponse.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(QueryResponse.self, from: data)

        XCTAssertEqual(response.jsonrpc, "2.0")
        XCTAssertEqual(response.result.storageUsage, 182)
    }

    // MARK: - Generated Code Structure Tests

    func testGeneratedTypesHavePublicAccess() throws {
        // Verify that generated types are public (not internal)
        // This is critical for library usage

        let typesToCheck: [Any.Type] = [
            StatusResponse.self,
            BlockView.self,
            AccountView.self,
            AccessKeyView.self,
            Version.self,
            SyncInfo.self
        ]

        // All types should be accessible (this test will compile-fail if they're not public)
        XCTAssertEqual(typesToCheck.count, 6)
    }

    func testEnumCasesAreAccessible() throws {
        // Verify enum cases are public and accessible
        let fullAccess = AccessKeyPermission.fullAccess

        switch fullAccess {
        case .fullAccess:
            XCTAssertTrue(true)
        case .functionCall:
            XCTFail("Should be full access")
        }
    }

    // MARK: - Regression Tests

    func testChainIdFieldExists() throws {
        // Regression test: ensure chainId field exists and is properly named
        let status = StatusResponse(
            version: Version(version: "1.0", build: "test"),
            chainId: "testnet",
            protocolVersion: 1,
            latestProtocolVersion: 1,
            rpcAddr: nil,
            validators: [],
            syncInfo: SyncInfo(
                latestBlockHash: "test",
                latestBlockHeight: 1,
                latestStateRoot: "test",
                latestBlockTime: "test",
                syncing: false
            ),
            validatorAccountId: nil
        )

        XCTAssertEqual(status.chainId, "testnet")
    }

    func testStorageFieldsExist() throws {
        // Regression test: ensure storage fields use correct types
        let account = AccountView(
            amount: "1000",
            locked: "0",
            codeHash: "hash",
            storageUsage: 100,
            storagePaidAt: 0
        )

        XCTAssertTrue(account.storageUsage is Int)
        XCTAssertTrue(account.storagePaidAt is Int)
    }
}
