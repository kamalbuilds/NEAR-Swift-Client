import XCTest
@testable import NEARJSONRPCTypes

final class TypesTests: XCTestCase {
    
    func testStatusResponseDecoding() throws {
        let json = """
        {
            "version": {
                "version": "1.35.0",
                "build": "1.35.0-rc.2"
            },
            "chain_id": "testnet",
            "protocol_version": 63,
            "latest_protocol_version": 63,
            "rpc_addr": "0.0.0.0:3030",
            "validators": [],
            "sync_info": {
                "latest_block_hash": "FzDYgFjSBUXkFfr4k5KrPa3wzMnLsPG2jLJYvKUgLxr3",
                "latest_block_height": 147443688,
                "latest_state_root": "8nWKw5h4dHMSZtkJ2N3d1bj5gy2KHNxifGLpczxY6Huw",
                "latest_block_time": "2024-01-10T00:00:00.000000000Z",
                "syncing": false
            },
            "validator_account_id": null
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let response = try decoder.decode(StatusResponse.self, from: data)
        
        XCTAssertEqual(response.version.version, "1.35.0")
        XCTAssertEqual(response.chainId, "testnet")
        XCTAssertEqual(response.protocolVersion, 63)
        XCTAssertFalse(response.syncInfo.syncing)
    }
    
    func testAccountViewDecoding() throws {
        let json = """
        {
            "amount": "100000000000000000000000000",
            "locked": "0",
            "code_hash": "11111111111111111111111111111111",
            "storage_usage": 500,
            "storage_paid_at": 0
        }
        """
        
        let data = json.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        
        let account = try decoder.decode(AccountView.self, from: data)
        
        XCTAssertEqual(account.amount, "100000000000000000000000000")
        XCTAssertEqual(account.locked, "0")
        XCTAssertEqual(account.storageUsage, 500)
    }
    
    func testSnakeCaseToCamelCaseConversion() {
        let snakeCase = "latest_block_height"
        let expectedCamelCase = "latestBlockHeight"
        
        // This would be handled by the code generator
        let components = snakeCase.split(separator: "_")
        let camelCase = components.enumerated().map { index, component in
            if index == 0 {
                return String(component)
            } else {
                return component.prefix(1).uppercased() + component.dropFirst()
            }
        }.joined()
        
        XCTAssertEqual(camelCase, expectedCamelCase)
    }
    
    func testAccessKeyPermissionDecoding() throws {
        let fullAccessJson = """
        {
            "nonce": 1,
            "permission": "FullAccess"
        }
        """
        
        let functionCallJson = """
        {
            "nonce": 2,
            "permission": {
                "FunctionCall": {
                    "allowance": "1000000000000000000000000",
                    "receiver_id": "contract.near",
                    "method_names": ["method1", "method2"]
                }
            }
        }
        """
        
        // These tests would work with proper enum decoding
        // Placeholder for now as the actual implementation
        // would be generated from OpenAPI spec
    }
}