import Foundation
import NEARJSONRPCTypes

/// High-level NEAR RPC client with convenience methods
public class NEARClient {
    private let client: Client
    private let serverURL: URL
    
    public init(url: String = "https://rpc.testnet.near.org") throws {
        guard let serverURL = URL(string: url) else {
            throw NEARClientError.invalidURL
        }
        self.serverURL = serverURL
        self.client = Client(
            serverURL: serverURL,
            transport: URLSessionTransport()
        )
    }
    
    // Status
    public func status() async throws -> StatusResponse {
        return try await client.callJSONRPC(
            method: "status",
            params: [],
            resultType: StatusResponse.self
        )
    }
    
    // Block
    public func block(finality: Finality = .final) async throws -> BlockResponse {
        return try await client.callJSONRPC(
            method: "block",
            params: ["finality": finality.rawValue],
            resultType: BlockResponse.self
        )
    }
    
    // Account
    public func viewAccount(
        accountId: String,
        finality: Finality = .final
    ) async throws -> AccountView {
        return try await client.callJSONRPC(
            method: "query",
            params: [
                "request_type": "view_account",
                "account_id": accountId,
                "finality": finality.rawValue
            ],
            resultType: AccountView.self
        )
    }
    
    // Access Key
    public func viewAccessKey(
        accountId: String,
        publicKey: String,
        finality: Finality = .final
    ) async throws -> AccessKeyView {
        return try await client.callJSONRPC(
            method: "query",
            params: [
                "request_type": "view_access_key",
                "account_id": accountId,
                "public_key": publicKey,
                "finality": finality.rawValue
            ],
            resultType: AccessKeyView.self
        )
    }
    
    // Contract State
    public func viewContractState(
        accountId: String,
        prefix: String = "",
        finality: Finality = .final
    ) async throws -> ContractStateView {
        return try await client.callJSONRPC(
            method: "query",
            params: [
                "request_type": "view_state",
                "account_id": accountId,
                "prefix_base64": prefix,
                "finality": finality.rawValue
            ],
            resultType: ContractStateView.self
        )
    }
    
    // Call Function
    public func callFunction(
        accountId: String,
        methodName: String,
        args: Data,
        finality: Finality = .final
    ) async throws -> FunctionCallResponse {
        return try await client.callJSONRPC(
            method: "query",
            params: [
                "request_type": "call_function",
                "account_id": accountId,
                "method_name": methodName,
                "args_base64": args.base64EncodedString(),
                "finality": finality.rawValue
            ],
            resultType: FunctionCallResponse.self
        )
    }
}

public enum NEARClientError: Error {
    case invalidURL
    case invalidResponse
    case rpcError(JSONRPCError)
}

public enum Finality: String {
    case final = "final"
    case optimistic = "optimistic"
}