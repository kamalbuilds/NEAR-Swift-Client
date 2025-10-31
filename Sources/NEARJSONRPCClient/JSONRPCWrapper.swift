import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// JSON-RPC wrapper for NEAR Protocol
public struct JSONRPCRequest<Params: Encodable>: Encodable {
    public let jsonrpc = "2.0"
    public let id: String
    public let method: String
    public let params: Params
    
    public init(method: String, params: Params, id: String = UUID().uuidString) {
        self.method = method
        self.params = params
        self.id = id
    }
}

public struct JSONRPCResponse<Result: Decodable>: Decodable {
    public let jsonrpc: String
    public let id: String
    public let result: Result?
    public let error: JSONRPCError?
}

public struct JSONRPCError: Decodable, Error {
    public let code: Int
    public let message: String
    public let data: String?
}

/// Extension to handle JSON-RPC wrapping/unwrapping
public extension Client {
    func callJSONRPC<Params: Encodable, Result: Decodable>(
        method: String,
        params: Params,
        resultType: Result.Type
    ) async throws -> Result {
        let request = JSONRPCRequest(method: method, params: params)
        let requestData = try JSONEncoder().encode(request)
        
        // Call the generated client method
        let response = try await self.post(
            path: "/",
            body: .json(requestData)
        )
        
        let responseData = try response.body.data
        let jsonResponse = try JSONDecoder().decode(
            JSONRPCResponse<Result>.self,
            from: responseData
        )
        
        if let error = jsonResponse.error {
            throw error
        }
        
        guard let result = jsonResponse.result else {
            throw JSONRPCError(code: -32603, message: "Internal error", data: nil)
        }
        
        return result
    }
}