import XCTest
import Foundation
@testable import NEARJSONRPCTypes

/// Tests to verify correct JSON decoding of NEAR RPC responses
final class TypeDecodingTests: XCTestCase {

    func testAccountViewDecoding() throws {
        // Actual response from NEAR RPC for view_account query
        let jsonString = """
        {
            "amount": "4478626803896425265317954846",
            "block_hash": "Gap9aCBQQNb7aJ29VnD5Hbxwf7ky7zNcQQaEL7rBykTX",
            "block_height": 220893920,
            "code_hash": "9UnkWSYw6Bj9qkyV5jqtMBYYi7aHTaDUMaoU6dtJQRvy",
            "locked": "0",
            "storage_paid_at": 0,
            "storage_usage": 6779445
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let accountView = try decoder.decode(AccountView.self, from: jsonData)

        XCTAssertEqual(accountView.amount, "4478626803896425265317954846")
        XCTAssertEqual(accountView.blockHash, "Gap9aCBQQNb7aJ29VnD5Hbxwf7ky7zNcQQaEL7rBykTX")
        XCTAssertEqual(accountView.blockHeight, 220893920)
        XCTAssertEqual(accountView.storageUsage, 6779445)
    }

    func testFunctionCallResultDecoding() throws {
        // Actual response from NEAR RPC for call_function query
        let jsonString = """
        {
            "block_hash": "JBSUFdqTd4zXjVGGS8aFmSa2GkUAWBex6SKsftHwXYE6",
            "block_height": 220893933,
            "logs": [],
            "result": [123,34,115,112,101,99,34,58,34,102,116,45,49,46,48,46,48,34,44,34,110,97,109,101,34,58,34,87,114,97,112,112,101,100,32,78,69,65,82,32,102,117,110,103,105,98,108,101,32,116,111,107,101,110,34,44,34,115,121,109,98,111,108,34,58,34,119,78,69,65,82,34,44,34,105,99,111,110,34,58,110,117,108,108,44,34,114,101,102,101,114,101,110,99,101,34,58,110,117,108,108,44,34,114,101,102,101,114,101,110,99,101,95,104,97,115,104,34,58,110,117,108,108,44,34,100,101,99,105,109,97,108,115,34,58,50,52,125]
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let functionResult = try decoder.decode(FunctionCallResult.self, from: jsonData)

        XCTAssertEqual(functionResult.blockHash, "JBSUFdqTd4zXjVGGS8aFmSa2GkUAWBex6SKsftHwXYE6")
        XCTAssertEqual(functionResult.blockHeight, 220893933)
        XCTAssertEqual(functionResult.logs, [])
        XCTAssertGreaterThan(functionResult.result.count, 0)

        // Test result decoding helper
        if let jsonStr = functionResult.decodeResultAsString() {
            XCTAssertTrue(jsonStr.contains("wNEAR"))
            print("Decoded result: \(jsonStr)")
        }
    }

    func testAccessKeyQueryResponseDecoding() throws {
        // Simulated response structure for view_access_key
        let jsonString = """
        {
            "nonce": 123456,
            "permission": "FullAccess",
            "block_hash": "ABC123",
            "block_height": 1000
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let response = try decoder.decode(AccessKeyQueryResponse.self, from: jsonData)

        XCTAssertEqual(response.nonce, 123456)
        XCTAssertEqual(response.blockHash, "ABC123")
        XCTAssertEqual(response.blockHeight, 1000)
    }

    func testNEARErrorDecoding() throws {
        // Actual error response from NEAR RPC
        let jsonString = """
        {
            "code": -32000,
            "message": "Server error",
            "data": {
                "name": "UNKNOWN_ACCOUNT",
                "cause": {
                    "name": "AccountDoesNotExist",
                    "info": "Account this-account-definitely-does-not-exist-12345.near does not exist"
                }
            }
        }
        """

        let jsonData = jsonString.data(using: .utf8)!
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase

        let error = try decoder.decode(NEARRPCError.self, from: jsonData)

        XCTAssertEqual(error.code, -32000)
        XCTAssertEqual(error.message, "Server error")
        XCTAssertEqual(error.errorCode, .handlerError)
        XCTAssertNotNil(error.data)
        XCTAssertEqual(error.data?.name, "UNKNOWN_ACCOUNT")
    }
}
