import Foundation

// This file will be auto-generated from the OpenAPI spec
// Placeholder for manual development

/// NEAR Protocol types
public struct StatusResponse: Codable {
    public let version: Version
    public let chainId: String
    public let protocolVersion: Int
    public let latestProtocolVersion: Int
    public let rpcAddr: String?
    public let validators: [ValidatorInfo]
    public let syncInfo: SyncInfo
    public let validatorAccountId: String?
    
    public struct Version: Codable {
        public let version: String
        public let build: String
    }
    
    public struct ValidatorInfo: Codable {
        public let accountId: String
        public let isSlashed: Bool
    }
    
    public struct SyncInfo: Codable {
        public let latestBlockHash: String
        public let latestBlockHeight: Int
        public let latestStateRoot: String
        public let latestBlockTime: String
        public let syncing: Bool
    }
}

public struct BlockResponse: Codable {
    public let author: String
    public let header: BlockHeader
    public let chunks: [ChunkHeader]
    
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
    
    public struct ValidatorProposal: Codable {
        public let accountId: String
        public let stake: String
        public let publicKey: String
    }
    
    public struct ChallengeResult: Codable {
        public let accountId: String
        public let isDoubleSign: Bool
    }
}

public struct AccountView: Codable {
    public let amount: String
    public let locked: String
    public let codeHash: String
    public let storageUsage: Int
    public let storagePaidAt: Int
}

public struct AccessKeyView: Codable {
    public let nonce: Int
    public let permission: Permission
    
    public enum Permission: Codable {
        case fullAccess
        case functionCall(FunctionCallPermission)
        
        public struct FunctionCallPermission: Codable {
            public let allowance: String?
            public let receiverId: String
            public let methodNames: [String]
        }
    }
}

public struct ContractStateView: Codable {
    public let values: [StateItem]
    
    public struct StateItem: Codable {
        public let key: String
        public let value: String
    }
}

public struct FunctionCallResponse: Codable {
    public let result: [UInt8]
    public let logs: [String]
    public let blockHeight: Int
    public let blockHash: String
}