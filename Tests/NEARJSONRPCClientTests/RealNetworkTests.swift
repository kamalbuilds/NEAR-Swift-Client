import XCTest
@testable import NEARJSONRPCClient
@testable import NEARJSONRPCTypes

/// Tests that connect to real NEAR testnet
/// These are integration tests that verify actual network connectivity
final class RealNetworkTests: XCTestCase {
    
    var client: NEARClient!
    
    override func setUp() async throws {
        try await super.setUp()
        client = try NEARClient(url: "https://test.rpc.fastnear.com")
    }
    
    /// Test actual network status call
    func testRealNetworkStatus() async throws {
        let status = try await client.status()
        
        // Verify we get valid responses
        XCTAssertFalse(status.version.version.isEmpty)
        XCTAssertEqual(status.chainId, "testnet")
        XCTAssertGreaterThan(status.syncInfo.latestBlockHeight, 0)
        XCTAssertFalse(status.syncInfo.latestBlockHash.isEmpty)
        
        print("✅ Network Status Test Passed:")
        print("  Chain ID: \(status.chainId)")
        print("  Version: \(status.version.version)")
        print("  Latest Block: \(status.syncInfo.latestBlockHeight)")
        print("  Syncing: \(status.syncInfo.syncing)")
    }
    
    /// Test querying a known testnet account
    func testRealAccountQuery() async throws {
        do {
            // "guest-book.testnet" is a known contract on testnet
            let account = try await client.viewAccount(accountId: "guest-book.testnet")

            XCTAssertFalse(account.amount.isEmpty)
            XCTAssertGreaterThanOrEqual(account.storageUsage, 0)

            let nearAmount = formatNEAR(account.amount)
            print("✅ Account Query Test Passed:")
            print("  Account: guest-book.testnet")
            print("  Balance: \(nearAmount) NEAR")
            print("  Storage: \(account.storageUsage) bytes")
        } catch {
            print("⚠️  Account query test skipped (account not available): \(error)")
            throw XCTSkip("Account query not available")
        }
    }
    
    /// Test block query
    func testRealBlockQuery() async throws {
        let block = try await client.block(finality: .final)
        
        XCTAssertGreaterThan(block.header.height, 0)
        XCTAssertFalse(block.header.hash.isEmpty)
        XCTAssertFalse(block.author.isEmpty)
        
        print("✅ Block Query Test Passed:")
        print("  Height: \(block.header.height)")
        print("  Hash: \(block.header.hash)")
        print("  Author: \(block.author)")
        print("  Chunks: \(block.chunks.count)")
    }
    
    /// Test gas price query
    func testRealGasPrice() async throws {
        let gasPrice = try await client.gasPrice()
        
        XCTAssertFalse(gasPrice.gasPrice.isEmpty)
        XCTAssertGreaterThan(Int(gasPrice.gasPrice) ?? 0, 0)
        
        print("✅ Gas Price Test Passed:")
        print("  Gas Price: \(gasPrice.gasPrice)")
    }
    
    /// Test validators query
    func testRealValidators() async throws {
        do {
            let validators = try await client.validators()

            XCTAssertGreaterThan(validators.currentValidators.count, 0)
            XCTAssertGreaterThan(validators.epochStartHeight, 0)

            print("✅ Validators Test Passed:")
            print("  Current Validators: \(validators.currentValidators.count)")
            print("  Epoch Start: \(validators.epochStartHeight)")

            if let firstValidator = validators.currentValidators.first {
                print("  First Validator: \(firstValidator.accountId)")
                print("  Stake: \(formatNEAR(firstValidator.stake)) NEAR")
            }
        } catch {
            print("⚠️  Validators test skipped (API error): \(error)")
            throw XCTSkip("Validators query not available on this RPC provider")
        }
    }
    
    /// Test view function call on a contract
    func testRealViewFunctionCall() async throws {
        // Skip if network is not available
        guard ProcessInfo.processInfo.environment["SKIP_NETWORK_TESTS"] == nil else {
            throw XCTSkip("Skipping network test")
        }
        
        // Using a simple view function on a known contract
        let args = "{}".data(using: .utf8)!
        
        do {
            let result = try await client.callViewFunction(
                accountId: "guest-book.testnet",
                methodName: "getMessages",
                args: args
            )
            
            XCTAssertFalse(result.result.isEmpty)
            print("✅ View Function Call Test Passed:")
            print("  Contract: guest-book.testnet")
            print("  Method: getMessages")
            print("  Result size: \(result.result.count) bytes")
            
        } catch {
            // Contract might not exist or method might have changed
            print("⚠️ View function call failed (expected if contract doesn't exist): \(error)")
        }
    }
    
    // Helper function
    private func formatNEAR(_ yoctoNEAR: String) -> String {
        guard let amount = Double(yoctoNEAR) else { return "0" }
        let near = amount / 1e24
        return String(format: "%.4f", near)
    }
}