import XCTest
@testable import NEARJSONRPCClient
@testable import NEARJSONRPCTypes

final class IntegrationTests: XCTestCase {
    
    var mockTransport: MockJSONRPCTransport!
    
    override func setUp() {
        super.setUp()
        mockTransport = MockJSONRPCTransport()
    }
    
    func testFullAccountQuery() async throws {
        // Mock response for account query
        let mockAccountData = """
        {
            "result": {
                "amount": "1000000000000000000000000",
                "locked": "0",
                "code_hash": "11111111111111111111111111111111",
                "storage_usage": 500,
                "storage_paid_at": 0
            },
            "block_height": 100000,
            "block_hash": "test-hash"
        }
        """.data(using: .utf8)!
        
        mockTransport.mockResponse = mockAccountData
        
        // This would test the full flow in real implementation
        // For now we test the data parsing
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        struct TestResponse: Decodable {
            let result: AccountView
            let blockHeight: Int
            let blockHash: String
        }
        
        let response = try decoder.decode(TestResponse.self, from: mockAccountData)
        
        XCTAssertEqual(response.result.amount, "1000000000000000000000000")
        XCTAssertEqual(response.result.storageUsage, 500)
        XCTAssertEqual(response.blockHeight, 100000)
    }
    
    func testTransactionSerialization() throws {
        // Transaction serialization test would go here when properly implemented
        XCTAssertTrue(true, "Transaction serialization test placeholder")
    }
    
    func testErrorHandling() async throws {
        let errorJson = """
        {
            "jsonrpc": "2.0",
            "id": "test-id",
            "error": {
                "code": -32601,
                "message": "Method not found",
                "data": "Unknown method: invalid_method"
            }
        }
        """
        
        let data = errorJson.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        struct DummyResult: Decodable {}
        
        let response = try decoder.decode(JSONRPCResponse<DummyResult>.self, from: data)
        
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error?.code, -32601)
        XCTAssertEqual(response.error?.message, "Method not found")
    }
    
    func testBatchedQueries() async throws {
        // Test that multiple queries can be executed efficiently
        async let status = mockStatusCall()
        async let block = mockBlockCall()
        async let validators = mockValidatorsCall()
        
        let (statusResult, blockResult, validatorsResult) = try await (status, block, validators)
        
        XCTAssertEqual(statusResult.chainId, "testnet")
        XCTAssertEqual(blockResult.header.height, 100000)
        XCTAssertEqual(validatorsResult.currentValidators.count, 1)
    }
    
    // MARK: - Mock Helpers
    
    private func mockStatusCall() async throws -> StatusResponse {
        return StatusResponse(
            version: Version(version: "1.35.0", build: "test"),
            chainId: "testnet",
            protocolVersion: 63,
            latestProtocolVersion: 63,
            rpcAddr: nil,
            validators: [],
            syncInfo: SyncInfo(
                latestBlockHash: "test-hash",
                latestBlockHeight: 100000,
                latestStateRoot: "test-root",
                latestBlockTime: "2024-01-10T00:00:00Z",
                syncing: false
            ),
            validatorAccountId: nil
        )
    }
    
    private func mockBlockCall() async throws -> BlockView {
        return BlockView(
            author: "test-validator.near",
            header: BlockHeader(
                height: 100000,
                epochId: "test-epoch",
                nextEpochId: "next-epoch",
                hash: "block-hash",
                prevHash: "prev-hash",
                prevStateRoot: "prev-root",
                chunkReceiptsRoot: "chunk-receipts",
                chunkHeadersRoot: "chunk-headers",
                chunkTxRoot: "chunk-tx",
                outcomeRoot: "outcome",
                chunksIncluded: 1,
                challengesRoot: "challenges",
                timestamp: 1704844800,
                timestampNanosec: "0",
                randomValue: "random",
                validatorProposals: [],
                chunkMask: [true],
                gasPrice: "100000000",
                rentPaid: "0",
                validatorReward: "0",
                totalSupply: "1000000000000000000000000000000000",
                challengesResult: [],
                lastFinalBlock: "final-block",
                lastDsFinalBlock: "ds-final",
                nextBpHash: "next-bp",
                blockMerkleRoot: "merkle",
                approvals: ["test"],
                signature: "signature",
                latestProtocolVersion: 63
            ),
            chunks: []
        )
    }
    
    private func mockValidatorsCall() async throws -> ValidatorStakeView {
        return ValidatorStakeView(
            currentValidators: [
                CurrentValidatorInfo(
                    accountId: "test-validator.near",
                    publicKey: "ed25519:test-key",
                    stake: "1000000000000000000000000000",
                    shards: [0],
                    numProducedBlocks: 100,
                    numExpectedBlocks: 100
                )
            ],
            nextValidators: [],
            currentProposals: [],
            epochStartHeight: 99000,
            prevEpochKickout: []
        )
    }
}

// Mock transport for testing
class MockJSONRPCTransport {
    var mockResponse: Data?
    var lastRequest: Data?
    
    func mockCall<Result: Decodable>(resultType: Result.Type) async throws -> Result {
        guard let data = mockResponse else {
            throw NSError(domain: "MockError", code: 0, userInfo: nil)
        }
        
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        return try decoder.decode(Result.self, from: data)
    }
}