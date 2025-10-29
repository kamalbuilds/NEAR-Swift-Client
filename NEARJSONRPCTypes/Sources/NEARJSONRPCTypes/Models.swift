import Foundation

// MARK: - Core Response Types

public struct StatusResponse: Codable {
    public let version: Version
    public let chainId: String
    public let protocolVersion: Int
    public let latestProtocolVersion: Int
    public let rpcAddr: String?
    public let validators: [ValidatorInfo]
    public let syncInfo: SyncInfo
    public let validatorAccountId: String?
}

public struct Version: Codable {
    public let version: String
    public let build: String
}

public struct ValidatorInfo: Codable {
    public let accountId: String
    public let isSlashed: Bool?
}

public struct SyncInfo: Codable {
    public let latestBlockHash: String
    public let latestBlockHeight: Int
    public let latestStateRoot: String
    public let latestBlockTime: String
    public let syncing: Bool
}

// MARK: - Block Types

public struct BlockView: Codable {
    public let author: String
    public let header: BlockHeader
    public let chunks: [ChunkHeader]
}

public struct BlockHeader: Codable {
    public let height: Int
    public let epochId: String
    public let nextEpochId: String
    public let hash: String
    public let prevHash: String
    public let prevStateRoot: String
    public let chunkReceiptsRoot: String
    public let chunkHeadersRoot: String
    public let chunkTxRoot: String
    public let outcomeRoot: String
    public let chunksIncluded: Int
    public let challengesRoot: String
    public let timestamp: Int
    public let timestampNanosec: String
    public let randomValue: String
    public let validatorProposals: [ValidatorProposal]
    public let chunkMask: [Bool]
    public let gasPrice: String
    public let rentPaid: String
    public let validatorReward: String
    public let totalSupply: String
    public let challengesResult: [ChallengeResult]
    public let lastFinalBlock: String
    public let lastDsFinalBlock: String
    public let nextBpHash: String
    public let blockMerkleRoot: String
    public let approvals: [String?]
    public let signature: String
    public let latestProtocolVersion: Int
}

public struct ChunkHeader: Codable {
    public let chunkHash: String
    public let prevBlockHash: String
    public let outcomeRoot: String
    public let prevStateRoot: String
    public let encodedMerkleRoot: String
    public let encodedLength: Int
    public let heightCreated: Int
    public let heightIncluded: Int
    public let shardId: Int
    public let gasUsed: Int
    public let gasLimit: Int
    public let rentPaid: String
    public let validatorReward: String
    public let balanceBurnt: String
    public let outgoingReceiptsRoot: String
    public let txRoot: String
    public let validatorProposals: [ValidatorProposal]
    public let signature: String
}

// MARK: - Account Types

/// Base account data without query metadata
public struct AccountData: Codable {
    public let amount: String
    public let locked: String
    public let codeHash: String
    public let storageUsage: Int
    public let storagePaidAt: Int
}

/// Complete view_account response including block metadata
public struct AccountView: Codable {
    public let amount: String
    public let locked: String
    public let codeHash: String
    public let storageUsage: Int
    public let storagePaidAt: Int
    public let blockHash: String
    public let blockHeight: Int
}

public struct AccessKeyView: Codable {
    public let nonce: Int
    public let permission: AccessKeyPermission
}

public enum AccessKeyPermission: Codable {
    case fullAccess
    case functionCall(FunctionCallPermission)
    
    private enum CodingKeys: String, CodingKey {
        case fullAccess = "FullAccess"
        case functionCall = "FunctionCall"
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        if (try? container.decode(String.self)) != nil {
            self = .fullAccess
        } else {
            let functionCallContainer = try decoder.container(keyedBy: CodingKeys.self)
            let permission = try functionCallContainer.decode(FunctionCallPermission.self, forKey: .functionCall)
            self = .functionCall(permission)
        }
    }
    
    public func encode(to encoder: Encoder) throws {
        switch self {
        case .fullAccess:
            var container = encoder.singleValueContainer()
            try container.encode("FullAccess")
        case .functionCall(let permission):
            var container = encoder.container(keyedBy: CodingKeys.self)
            try container.encode(permission, forKey: .functionCall)
        }
    }
}

public struct FunctionCallPermission: Codable {
    public let allowance: String?
    public let receiverId: String
    public let methodNames: [String]
}

public struct AccessKeyList: Codable {
    public let keys: [AccessKeyInfo]
}

public struct AccessKeyInfo: Codable {
    public let publicKey: String
    public let accessKey: AccessKeyView
}

// MARK: - State Types

public struct StateResult: Codable {
    public let values: [StateItem]
    public let proof: [String]
}

public struct StateItem: Codable {
    public let key: String
    public let value: String
    public let proof: [String]
}

// MARK: - Function Call Types

/// Result from calling a view function
/// The RPC response structure is: result { result: [UInt8], logs: [String], block_hash, block_height }
public struct FunctionCallResult: Codable {
    public let result: [UInt8]
    public let logs: [String]
    public let blockHash: String
    public let blockHeight: Int

    /// Decode the result bytes as JSON
    public func decodeResult<T: Decodable>(as type: T.Type) throws -> T {
        let data = Data(result)
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

    /// Decode the result bytes as a UTF-8 string
    public func decodeResultAsString() -> String? {
        return String(data: Data(result), encoding: .utf8)
    }
}

// MARK: - Transaction Types

public struct SignedTransaction {
    public let transaction: Transaction
    public let signature: Signature
    
    public func toBase64() -> String {
        // Implementation would use proper encoding
        return ""
    }
}

public struct Transaction {
    public let signerId: String
    public let publicKey: String
    public let nonce: Int
    public let receiverId: String
    public let actions: [Action]
    public let blockHash: String
}

public struct Signature: Codable {
    public let keyType: Int
    public let data: String
}

public enum Action {
    case createAccount
    case deployContract(DeployContractAction)
    case functionCall(FunctionCallAction)
    case transfer(TransferAction)
    case stake(StakeAction)
    case addKey(AddKeyAction)
    case deleteKey(DeleteKeyAction)
    case deleteAccount(DeleteAccountAction)
}

public struct DeployContractAction: Codable {
    public let code: String
}

public struct FunctionCallAction: Codable {
    public let methodName: String
    public let args: String
    public let gas: Int
    public let deposit: String
}

public struct TransferAction: Codable {
    public let deposit: String
}

public struct StakeAction: Codable {
    public let stake: String
    public let publicKey: String
}

public struct AddKeyAction: Codable {
    public let publicKey: String
    public let accessKey: AccessKeyView
    
    public init(publicKey: String, accessKey: AccessKeyView) {
        self.publicKey = publicKey
        self.accessKey = accessKey
    }
}

public struct DeleteKeyAction: Codable {
    public let publicKey: String
}

public struct DeleteAccountAction: Codable {
    public let beneficiaryId: String
}

// MARK: - Execution Types

public struct FinalExecutionOutcome: Codable {
    public let status: ExecutionStatus
    // Transaction would be included here when properly Codable
    public let transactionOutcome: ExecutionOutcome
    public let receiptsOutcome: [ExecutionOutcome]
}

public enum ExecutionStatus: Codable {
    case successValue(String)
    case successReceiptId(String)
    case failure(ExecutionError)
    case unknown
}

public struct ExecutionOutcome: Codable {
    public let logs: [String]
    public let receiptIds: [String]
    public let gasBurnt: Int
    public let tokensBurnt: String
    public let executorId: String
    public let status: ExecutionStatus
}

public struct ExecutionError: Codable {
    public let errorMessage: String
    public let errorType: String
}

// MARK: - Validator Types

public struct ValidatorStakeView: Codable {
    public let currentValidators: [CurrentValidatorInfo]
    public let nextValidators: [NextValidatorInfo]
    public let currentProposals: [ValidatorProposal]
    public let epochStartHeight: Int
    public let prevEpochKickout: [ValidatorKickout]
}

public struct CurrentValidatorInfo: Codable {
    public let accountId: String
    public let publicKey: String
    public let stake: String
    public let shards: [Int]
    public let numProducedBlocks: Int
    public let numExpectedBlocks: Int
}

public struct NextValidatorInfo: Codable {
    public let accountId: String
    public let publicKey: String
    public let stake: String
    public let shards: [Int]
}

public struct ValidatorProposal: Codable {
    public let accountId: String
    public let stake: String
    public let publicKey: String
}

public struct ValidatorKickout: Codable {
    public let accountId: String
    public let reason: KickoutReason
}

public enum KickoutReason: Codable {
    case notEnoughBlocks(produced: Int, expected: Int)
    case notEnoughChunks(produced: Int, expected: Int)
    case notEnoughStake(stake: String, threshold: String)
    case unstaked
    case slashed
}

public struct ChallengeResult: Codable {
    public let accountId: String
    public let isDoubleSign: Bool
}

// MARK: - Gas Price Types

public struct GasPrice: Codable {
    public let gasPrice: String
}

// MARK: - Query Response Types

/// Generic wrapper for query responses that include block metadata
/// Note: Most query responses embed block_hash and block_height directly in the result
public struct QueryResponse<T: Decodable>: Decodable {
    // The actual result data
    private let rawResult: T

    // Block metadata (may not always be present, depends on query type)
    public let blockHash: String?
    public let blockHeight: Int?

    public var result: T {
        return rawResult
    }

    private enum CodingKeys: String, CodingKey {
        case blockHash = "block_hash"
        case blockHeight = "block_height"
    }

    public init(from decoder: Decoder) throws {
        // Try to decode block metadata at the top level
        let container = try? decoder.container(keyedBy: CodingKeys.self)
        self.blockHash = try? container?.decodeIfPresent(String.self, forKey: .blockHash)
        self.blockHeight = try? container?.decodeIfPresent(Int.self, forKey: .blockHeight)

        // Decode the actual result
        self.rawResult = try T(from: decoder)
    }
}

/// Response wrapper for queries that include nonce (like view_access_key)
public struct AccessKeyQueryResponse: Codable {
    public let nonce: Int
    public let permission: AccessKeyPermission
    public let blockHash: String
    public let blockHeight: Int
}

/// Response wrapper for view_access_key_list
public struct AccessKeyListQueryResponse: Codable {
    public let keys: [AccessKeyInfo]
    public let blockHash: String
    public let blockHeight: Int
}

/// Response wrapper for view_state
public struct StateQueryResponse: Codable {
    public let values: [StateItem]
    public let proof: [String]
    public let blockHash: String
    public let blockHeight: Int
}

// MARK: - NEAR-Specific RPC Error Types

/// NEAR-specific error codes beyond standard JSON-RPC errors
public enum NEARErrorCode: Int {
    // Standard JSON-RPC errors
    case parseError = -32700
    case invalidRequest = -32600
    case methodNotFound = -32601
    case invalidParams = -32602
    case internalError = -32603

    // NEAR-specific errors (range -32000 to -32099)
    case handlerError = -32000
    case requestValidationError = -32001
    case internalServerError = -32002
    case timeout = -32003

    // Block/Chunk errors
    case unknownBlock = -32100
    case unknownChunk = -32101

    // Account errors
    case unknownAccount = -32200
    case unknownAccessKey = -32201
    case invalidAccount = -32202

    // Transaction errors
    case unknownTransaction = -32300
    case invalidTransaction = -32301
    case timeoutError = -32302

    // Contract errors
    case contractExecutionError = -32400
    case compilationError = -32401

    // State/Storage errors
    case storageError = -32500

    case unknown = 0
}

/// Detailed NEAR RPC error with typed error codes
public struct NEARRPCError: Decodable, Error, LocalizedError {
    public let code: Int
    public let message: String
    public let data: NEARErrorData?

    public init(code: Int, message: String, data: NEARErrorData? = nil) {
        self.code = code
        self.message = message
        self.data = data
    }

    public var errorCode: NEARErrorCode {
        return NEARErrorCode(rawValue: code) ?? .unknown
    }

    public var errorDescription: String? {
        if let data = data {
            return "\(message) (code: \(code))\nDetails: \(data.description)"
        }
        return "\(message) (code: \(code))"
    }
}

/// Extended error data from NEAR RPC
public struct NEARErrorData: Decodable {
    public let name: String?
    public let cause: NEARErrorCause?

    public init(name: String?, cause: NEARErrorCause?) {
        self.name = name
        self.cause = cause
    }

    public var description: String {
        var desc = name ?? "Unknown error"
        if let cause = cause {
            desc += " - Cause: \(cause.name ?? "Unknown")"
            if let info = cause.info {
                desc += " (\(info))"
            }
        }
        return desc
    }
}

/// Detailed error cause information
public struct NEARErrorCause: Decodable {
    public let name: String?
    public let info: String?

    public init(name: String?, info: String?) {
        self.name = name
        self.info = info
    }
}
