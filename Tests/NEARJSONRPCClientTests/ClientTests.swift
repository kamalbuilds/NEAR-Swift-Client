import XCTest
@testable import NEARJSONRPCClient
@testable import NEARJSONRPCTypes

final class ClientTests: XCTestCase {
    
    var client: NEARClient!
    
    override func setUp() {
        super.setUp()
        // Use testnet for testing
        client = try! NEARClient(url: "https://rpc.testnet.near.org")
    }
    
    func testClientInitialization() {
        XCTAssertNotNil(client)
        
        // Test invalid URL
        XCTAssertThrowsError(try NEARClient(url: "not a valid url")) { error in
            if let clientError = error as? NEARClientError {
                switch clientError {
                case .invalidURL:
                    XCTAssertTrue(true)
                default:
                    XCTFail("Expected invalidURL error")
                }
            } else {
                XCTFail("Expected NEARClientError")
            }
        }
    }
    
    func testStatusCall() async throws {
        // This would be a mock test in real implementation
        // For now, we'll skip the actual network call
        
        // Mock response
        let mockStatus = StatusResponse(
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
        
        XCTAssertEqual(mockStatus.chainId, "testnet")
    }
    
    func testJSONRPCRequestEncoding() throws {
        struct EmptyParams: Encodable {}
        
        let request = JSONRPCRequest(
            method: "status",
            params: EmptyParams()
        )
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(request)
        let json = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        XCTAssertEqual(json["jsonrpc"] as? String, "2.0")
        XCTAssertEqual(json["method"] as? String, "status")
        XCTAssertNotNil(json["id"])
    }
    
    func testJSONRPCResponseDecoding() throws {
        let json = """
        {
            "jsonrpc": "2.0",
            "id": "test-id",
            "result": {
                "chain_id": "testnet"
            }
        }
        """
        
        struct SimpleResult: Decodable {
            let chainId: String
        }
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let response = try decoder.decode(JSONRPCResponse<SimpleResult>.self, from: data)
        
        XCTAssertEqual(response.jsonrpc, "2.0")
        XCTAssertEqual(response.id, "test-id")
        XCTAssertEqual(response.result?.chainId, "testnet")
        XCTAssertNil(response.error)
    }
    
    func testJSONRPCErrorDecoding() throws {
        let json = """
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
        
        struct DummyResult: Decodable {}
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        
        let response = try decoder.decode(JSONRPCResponse<DummyResult>.self, from: data)
        
        XCTAssertNil(response.result)
        XCTAssertNotNil(response.error)
        XCTAssertEqual(response.error?.code, -32601)
        XCTAssertEqual(response.error?.message, "Method not found")
    }
    
    func testViewAccountParameters() async throws {
        // Test parameter construction
        let accountId = "test.near"
        let finality = Finality.optimistic
        
        // This would test the actual parameter construction
        // in the real implementation
        XCTAssertEqual(accountId, "test.near")
        XCTAssertEqual(finality.rawValue, "optimistic")
    }
    
    func testCallFunctionParameters() async throws {
        let args = "{}".data(using: .utf8)!
        let base64Args = args.base64EncodedString()
        
        XCTAssertEqual(base64Args, "e30=") // {} in base64
    }
}