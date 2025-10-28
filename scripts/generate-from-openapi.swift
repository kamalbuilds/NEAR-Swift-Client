#!/usr/bin/env swift

import Foundation

// Script to generate Swift code from NEAR OpenAPI spec

let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath

// Download OpenAPI spec
print("📥 Downloading NEAR OpenAPI spec...")

let specURL = URL(string: "https://raw.githubusercontent.com/near/nearcore/master/chain/jsonrpc/openapi/openapi.json")!

let specData = try Data(contentsOf: specURL)

// Parse and patch the spec
print("🔧 Patching OpenAPI spec for JSON-RPC...")
guard var spec = try JSONSerialization.jsonObject(with: specData) as? [String: Any] else {
    fatalError("Invalid OpenAPI spec format")
}

// Patch: Convert all paths to use single "/" endpoint for JSON-RPC
if var paths = spec["paths"] as? [String: Any] {
    var rootPath: [String: Any] = [:]
    var allOperations: [[String: Any]] = []
    
    for (path, pathItem) in paths {
        if let pathDict = pathItem as? [String: Any],
           let post = pathDict["post"] as? [String: Any] {
            var operation = post
            
            // Extract method name from path
            let methodName = path.replacingOccurrences(of: "/", with: "")
            operation["x-jsonrpc-method"] = methodName
            operation["operationId"] = methodName
            
            // Store operation for later
            allOperations.append(operation)
        }
    }
    
    // Create a single endpoint with all operations
    rootPath["post"] = [
        "operationId": "jsonrpc",
        "description": "NEAR JSON-RPC endpoint",
        "requestBody": [
            "content": [
                "application/json": [
                    "schema": [
                        "oneOf": allOperations.compactMap { operation in
                            if let methodName = operation["x-jsonrpc-method"] as? String,
                               let requestBody = operation["requestBody"] as? [String: Any],
                               let content = requestBody["content"] as? [String: Any],
                               let appJson = content["application/json"] as? [String: Any],
                               let schema = appJson["schema"] as? [String: Any] {
                                return schema
                            }
                            return nil
                        }
                    ]
                ]
            ]
        ],
        "responses": [
            "200": [
                "description": "Success",
                "content": [
                    "application/json": [
                        "schema": [
                            "type": "object"
                        ]
                    ]
                ]
            ]
        ]
    ]
    
    spec["paths"] = ["/": rootPath]
}

// Save patched spec
print("💾 Saving patched spec...")

let patchedData = try JSONSerialization.data(withJSONObject: spec, options: .prettyPrinted)

try patchedData.write(to: URL(fileURLWithPath: "openapi-patched.json"))

// Generate type mappings for snake_case to camelCase
print("🐍 Creating field mappings...")

let fieldMappings: [String: String] = [
    "account_id": "accountId",
    "public_key": "publicKey",
    "block_hash": "blockHash",
    "block_height": "blockHeight",
    "access_key": "accessKey",
    "function_call": "functionCall",
    "method_name": "methodName",
    "args_base64": "argsBase64",
    "prefix_base64": "prefixBase64",
    "request_type": "requestType",
    "latest_block_hash": "latestBlockHash",
    "latest_block_height": "latestBlockHeight",
    "latest_state_root": "latestStateRoot",
    "latest_block_time": "latestBlockTime",
    "validator_account_id": "validatorAccountId",
    "is_slashed": "isSlashed",
    "chunk_hash": "chunkHash",
    "prev_block_hash": "prevBlockHash",
    "outcome_root": "outcomeRoot",
    "prev_state_root": "prevStateRoot",
    "encoded_merkle_root": "encodedMerkleRoot",
    "encoded_length": "encodedLength",
    "height_created": "heightCreated",
    "height_included": "heightIncluded",
    "shard_id": "shardId",
    "gas_used": "gasUsed",
    "gas_limit": "gasLimit",
    "rent_paid": "rentPaid",
    "validator_reward": "validatorReward",
    "balance_burnt": "balanceBurnt",
    "outgoing_receipts_root": "outgoingReceiptsRoot",
    "tx_root": "txRoot",
    "validator_proposals": "validatorProposals",
    "storage_usage": "storageUsage",
    "storage_paid_at": "storagePaidAt",
    "code_hash": "codeHash",
    "receiver_id": "receiverId",
    "method_names": "methodNames",
    "signer_id": "signerId",
    "beneficiary_id": "beneficiaryId",
    "key_type": "keyType",
    "success_value": "successValue",
    "success_receipt_id": "successReceiptId",
    "error_message": "errorMessage",
    "error_type": "errorType",
    "tokens_burnt": "tokensBurnt",
    "gas_burnt": "gasBurnt",
    "receipt_ids": "receiptIds",
    "executor_id": "executorId",
    "num_produced_blocks": "numProducedBlocks",
    "num_expected_blocks": "numExpectedBlocks",
    "epoch_start_height": "epochStartHeight",
    "prev_epoch_kickout": "prevEpochKickout",
    "is_double_sign": "isDoubleSign",
    "epoch_id": "epochId",
    "next_epoch_id": "nextEpochId",
    "prev_hash": "prevHash",
    "chunk_receipts_root": "chunkReceiptsRoot",
    "chunk_headers_root": "chunkHeadersRoot",
    "chunk_tx_root": "chunkTxRoot",
    "chunks_included": "chunksIncluded",
    "challenges_root": "challengesRoot",
    "timestamp_nanosec": "timestampNanosec",
    "random_value": "randomValue",
    "chunk_mask": "chunkMask",
    "gas_price": "gasPrice",
    "total_supply": "totalSupply",
    "challenges_result": "challengesResult",
    "last_final_block": "lastFinalBlock",
    "last_ds_final_block": "lastDsFinalBlock",
    "next_bp_hash": "nextBpHash",
    "block_merkle_root": "blockMerkleRoot",
    "latest_protocol_version": "latestProtocolVersion",
    "protocol_version": "protocolVersion",
    "rpc_addr": "rpcAddr",
    "sync_info": "syncInfo",
    "chain_id": "chainId",
    "current_validators": "currentValidators",
    "next_validators": "nextValidators",
    "current_proposals": "currentProposals"
]

// Create mapping configuration
let mappingConfig = """
// Field mapping configuration for code generation
let fieldMappings = \(fieldMappings)
"""

try mappingConfig.write(to: URL(fileURLWithPath: "field-mappings.swift"), atomically: true, encoding: .utf8)

print("✅ OpenAPI spec prepared for code generation!")
print("")
print("Next steps:")
print("1. Use swift-openapi-generator with the patched spec")
print("2. Apply field mappings to generated code")
print("3. Add JSON-RPC wrapper layer")
