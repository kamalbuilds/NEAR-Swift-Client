import Foundation
import NEARJSONRPCClient

// Example application demonstrating NEAR Swift Client usage

@main
struct NEARExample {
    static func main() async {
        do {
            // Initialize client for testnet
            let client = try NEARClient(url: "https://rpc.testnet.near.org")
            
            print("🚀 NEAR Swift Client Example")
            print("============================\n")
            
            // Get network status
            print("📊 Network Status:")
            let status = try await client.status()
            print("  Chain ID: \(status.chainId)")
            print("  Latest Block: \(status.syncInfo.latestBlockHeight)")
            print("  Syncing: \(status.syncInfo.syncing)")
            print("")
            
            // Get latest block
            print("📦 Latest Block:")
            let block = try await client.block(finality: .final)
            print("  Height: \(block.header.height)")
            print("  Hash: \(block.header.hash)")
            print("  Author: \(block.author)")
            print("")
            
            // Query an account (example.testnet is a well-known test account)
            print("👤 Account Info (example.testnet):")
            let account = try await client.viewAccount(
                accountId: "example.testnet",
                finality: .final
            )
            print("  Balance: \(formatNEAR(account.amount)) NEAR")
            print("  Storage Used: \(account.storageUsage) bytes")
            print("")
            
            // Example of calling a view function on a contract
            print("📞 Contract View Call:")
            let contractId = "guest-book.testnet"
            let methodName = "getMessages"
            let args = "{}".data(using: .utf8)!
            
            let functionResult = try await client.callFunction(
                accountId: contractId,
                methodName: methodName,
                args: args,
                finality: .optimistic
            )
            
            if let resultString = String(data: Data(functionResult.result), encoding: .utf8) {
                print("  Contract: \(contractId)")
                print("  Method: \(methodName)")
                print("  Result: \(resultString.prefix(100))...")
            }
            
            print("\n✅ Example completed successfully!")
            
        } catch NEARClientError.invalidURL {
            print("❌ Error: Invalid RPC URL")
        } catch let error as JSONRPCError {
            print("❌ RPC Error: \(error.message) (code: \(error.code))")
            if let data = error.data {
                print("  Details: \(data)")
            }
        } catch {
            print("❌ Unexpected error: \(error)")
        }
    }
    
    // Helper function to format NEAR amounts
    static func formatNEAR(_ yoctoNEAR: String) -> String {
        guard let amount = Double(yoctoNEAR) else { return "0" }
        let near = amount / 1e24
        return String(format: "%.4f", near)
    }
}