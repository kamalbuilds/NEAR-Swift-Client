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

public struct AccountView: Codable {
    public let amount: String
    public let locked: String
    public let codeHash: String
    public let storageUsage: Int
    public let storagePaidAt: Int
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
        if let _ = try? container.decode(String.self) {
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

public struct FunctionCallResult: Codable {
    public let result: [UInt8]
    public let logs: [String]
    public let blockHeight: Int
    public let blockHash: String
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
