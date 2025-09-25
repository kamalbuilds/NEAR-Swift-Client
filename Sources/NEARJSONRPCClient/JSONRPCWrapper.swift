import Foundation
import OpenAPIRuntime
import OpenAPIURLSession

/// JSON-RPC 2.0 protocol implementation for NEAR
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

public struct JSONRPCError: Decodable, Error, LocalizedError {
    public let code: Int
    public let message: String
    public let data: JSONValue?
    
    public var errorDescription: String? {
        if let data = data {
            return "\(message) (code: \(code), data: \(data))"
        }
        return "\(message) (code: \(code))"
    }
}

/// Dynamic JSON value for error data
public enum JSONValue: Decodable {
    case string(String)
    case number(Double)
    case bool(Bool)
    case object([String: JSONValue])
    case array([JSONValue])
    case null
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        
        if container.decodeNil() {
            self = .null
        } else if let bool = try? container.decode(Bool.self) {
            self = .bool(bool)
        } else if let double = try? container.decode(Double.self) {
            self = .number(double)
        } else if let string = try? container.decode(String.self) {
            self = .string(string)
        } else if let array = try? container.decode([JSONValue].self) {
            self = .array(array)
        } else if let object = try? container.decode([String: JSONValue].self) {
            self = .object(object)
        } else {
            throw DecodingError.dataCorruptedError(in: container, debugDescription: "Unable to decode JSONValue")
        }
    }
}

/// Base transport for JSON-RPC over HTTP
public class JSONRPCTransport {
    private let baseURL: URL
    private let session: URLSession
    private let encoder = JSONEncoder()
    private let decoder = JSONDecoder()
    
    public init(baseURL: URL, session: URLSession = .shared) {
        self.baseURL = baseURL
        self.session = session
        
        // Configure for NEAR's snake_case JSON
        encoder.keyEncodingStrategy = .convertToSnakeCase
        decoder.keyDecodingStrategy = .convertFromSnakeCase
    }
    
    public func call<Params: Encodable, Result: Decodable>(
        method: String,
        params: Params,
        resultType: Result.Type
    ) async throws -> Result {
        let request = JSONRPCRequest(method: method, params: params)
        let requestData = try encoder.encode(request)
        
        var httpRequest = URLRequest(url: baseURL)
        httpRequest.httpMethod = "POST"
        httpRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
        httpRequest.httpBody = requestData
        
        let (data, response) = try await session.data(for: httpRequest)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NEARClientError.invalidResponse
        }
        
        guard httpResponse.statusCode == 200 else {
            throw NEARClientError.httpError(statusCode: httpResponse.statusCode)
        }
        
        let jsonResponse = try decoder.decode(JSONRPCResponse<Result>.self, from: data)
        
        if let error = jsonResponse.error {
            throw error
        }
        
        guard let result = jsonResponse.result else {
            throw NEARClientError.emptyResult
        }
        
        return result
    }
}
