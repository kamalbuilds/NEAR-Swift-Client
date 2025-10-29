import Foundation
import NEARJSONRPCTypes

/// High-level NEAR RPC client with convenience methods
public class NEARClient {
    private let transport: JSONRPCTransport
    
    public init(url: String = "https://rpc.testnet.near.org") throws {
        guard let serverURL = URL(string: url) else {
            throw NEARClientError.invalidURL
        }
        self.transport = JSONRPCTransport(baseURL: serverURL)
    }
    
    // MARK: - Network Info
    
    /// Get current status of the network
    public func status() async throws -> StatusResponse {
        return try await transport.call(
            method: "status",
            params: [] as [String],
            resultType: StatusResponse.self
        )
    }
    
    // MARK: - Block Operations
    
    /// Get block by finality
    public func block(finality: Finality = .final) async throws -> BlockView {
        struct BlockParams: Encodable {
            let finality: String
        }
        
        return try await transport.call(
            method: "block",
            params: BlockParams(finality: finality.rawValue),
            resultType: BlockView.self
        )
    }
    
    /// Get block by height
    public func blockByHeight(_ height: Int) async throws -> BlockView {
        struct BlockParams: Encodable {
            let blockId: Int
        }
        
        return try await transport.call(
            method: "block",
            params: BlockParams(blockId: height),
            resultType: BlockView.self
        )
    }
    
    /// Get block by hash
    public func blockByHash(_ hash: String) async throws -> BlockView {
        struct BlockParams: Encodable {
            let blockId: String
        }
        
        return try await transport.call(
            method: "block",
            params: BlockParams(blockId: hash),
            resultType: BlockView.self
        )
    }
    
    // MARK: - Account Operations
    
    /// View account details
    /// Returns account with embedded block metadata (blockHash, blockHeight)
    public func viewAccount(
        accountId: String,
        finality: Finality = .final
    ) async throws -> AccountView {
        struct QueryParams: Encodable {
            let requestType = "view_account"
            let finality: String
            let accountId: String
        }

        // NEAR RPC returns account data with block_hash and block_height at the same level
        return try await transport.call(
            method: "query",
            params: QueryParams(finality: finality.rawValue, accountId: accountId),
            resultType: AccountView.self
        )
    }
    
    // MARK: - Access Key Operations
    
    /// View access key
    /// Returns access key with embedded block metadata
    public func viewAccessKey(
        accountId: String,
        publicKey: String,
        finality: Finality = .final
    ) async throws -> AccessKeyQueryResponse {
        struct QueryParams: Encodable {
            let requestType = "view_access_key"
            let finality: String
            let accountId: String
            let publicKey: String
        }

        // NEAR RPC returns nonce, permission, block_hash, block_height at the same level
        return try await transport.call(
            method: "query",
            params: QueryParams(
                finality: finality.rawValue,
                accountId: accountId,
                publicKey: publicKey
            ),
            resultType: AccessKeyQueryResponse.self
        )
    }
    
    /// List all access keys for an account
    /// Returns list of access keys with embedded block metadata
    public func viewAccessKeyList(
        accountId: String,
        finality: Finality = .final
    ) async throws -> AccessKeyListQueryResponse {
        struct QueryParams: Encodable {
            let requestType = "view_access_key_list"
            let finality: String
            let accountId: String
        }

        // NEAR RPC returns keys array with block_hash and block_height at the same level
        return try await transport.call(
            method: "query",
            params: QueryParams(finality: finality.rawValue, accountId: accountId),
            resultType: AccessKeyListQueryResponse.self
        )
    }
    
    // MARK: - Contract Operations
    
    /// View contract state
    /// Returns state values with embedded block metadata
    public func viewState(
        accountId: String,
        prefix: Data = Data(),
        finality: Finality = .final
    ) async throws -> StateQueryResponse {
        struct QueryParams: Encodable {
            let requestType = "view_state"
            let finality: String
            let accountId: String
            let prefixBase64: String
        }

        // NEAR RPC returns values, proof, block_hash, block_height at the same level
        return try await transport.call(
            method: "query",
            params: QueryParams(
                finality: finality.rawValue,
                accountId: accountId,
                prefixBase64: prefix.base64EncodedString()
            ),
            resultType: StateQueryResponse.self
        )
    }
    
    /// Call a contract view function
    /// Returns function result with logs and block metadata
    public func callViewFunction(
        accountId: String,
        methodName: String,
        args: Data = Data(),
        finality: Finality = .final
    ) async throws -> FunctionCallResult {
        struct QueryParams: Encodable {
            let requestType = "call_function"
            let finality: String
            let accountId: String
            let methodName: String
            let argsBase64: String
        }

        // NEAR RPC returns result, logs, block_hash, block_height at the same level
        return try await transport.call(
            method: "query",
            params: QueryParams(
                finality: finality.rawValue,
                accountId: accountId,
                methodName: methodName,
                argsBase64: args.base64EncodedString()
            ),
            resultType: FunctionCallResult.self
        )
    }
    
    // MARK: - Transaction Operations
    
    // Transaction methods would be implemented here when SignedTransaction is properly Codable
    
    // MARK: - Gas Price
    
    /// Get gas price for a specific block
    public func gasPrice(blockId: BlockReference? = nil) async throws -> GasPrice {
        struct GasPriceParams: Encodable {
            let blockId: String?
        }
        
        let params = GasPriceParams(
            blockId: blockId.map { ref in
                switch ref {
                case .height(let height): return String(height)
                case .hash(let hashValue): return hashValue
                case .finality(let finalityValue): return finalityValue.rawValue
                }
            }
        )
        
        return try await transport.call(
            method: "gas_price",
            params: params,
            resultType: GasPrice.self
        )
    }
    
    // MARK: - Validators
    
    /// Get current validators
    public func validators(blockId: BlockReference? = nil) async throws -> ValidatorStakeView {
        // NEAR validators endpoint expects either null or [blockId] format
        if let blockId = blockId {
            let blockIdString = convertBlockReferenceToString(blockId)

            return try await transport.call(
                method: "validators",
                params: [blockIdString],
                resultType: ValidatorStakeView.self
            )
        } else {
            // For null blockId, use [null]
            return try await transport.call(
                method: "validators",
                params: [String?](arrayLiteral: nil),
                resultType: ValidatorStakeView.self
            )
        }
    }

    // MARK: - Helper Methods

    private func convertBlockReferenceToString(_ ref: BlockReference) -> String {
        switch ref {
        case .height(let height): return String(height)
        case .hash(let hash): return hash
        case .finality(let finality): return finality.rawValue
        }
    }
}

// MARK: - Supporting Types

public enum Finality: String {
    case final
    case optimistic
}

public enum BlockReference {
    case height(Int)
    case hash(String)
    case finality(Finality)
}

public enum NEARClientError: LocalizedError {
    case invalidURL
    case invalidResponse
    case httpError(statusCode: Int)
    case emptyResult
    case encodingError

    public var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid RPC URL provided"
        case .invalidResponse:
            return "Invalid response from server"
        case .httpError(let code):
            return "HTTP error: \(code)"
        case .emptyResult:
            return "Empty result in JSON-RPC response"
        case .encodingError:
            return "Failed to encode request parameters"
        }
    }
}
