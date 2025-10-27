import SwiftUI
import NEARJSONRPCClient

struct ContentView: View {
    @StateObject private var viewModel = NEARViewModel()
    @State private var accountId = "example.testnet"
    
    var body: some View {
        NavigationView {
            Form {
                Section("Network Status") {
                    if let status = viewModel.networkStatus {
                        LabeledContent("Chain ID", value: status.chainId)
                        LabeledContent("Latest Block", value: "\(status.syncInfo.latestBlockHeight)")
                        LabeledContent("Syncing", value: status.syncInfo.syncing ? "Yes" : "No")
                    } else {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                }
                
                Section("Account Query") {
                    TextField("Account ID", text: $accountId)
                        .textInputAutocapitalization(.never)
                        .disableAutocorrection(true)
                    
                    Button("Query Account") {
                        Task {
                            await viewModel.queryAccount(accountId)
                        }
                    }
                    .disabled(accountId.isEmpty)
                    
                    if viewModel.isLoading {
                        ProgressView()
                            .frame(maxWidth: .infinity)
                    }
                    
                    if let account = viewModel.accountInfo {
                        LabeledContent("Balance") {
                            Text(viewModel.formatNEAR(account.amount))
                                .font(.headline)
                        }
                        LabeledContent("Storage Used", value: "\(account.storageUsage) bytes")
                    }
                }
                
                if let error = viewModel.error {
                    Section("Error") {
                        Text(error.localizedDescription)
                            .foregroundColor(.red)
                    }
                }
            }
            .navigationTitle("NEAR Client")
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Refresh") {
                        Task {
                            await viewModel.refreshStatus()
                        }
                    }
                }
            }
        }
        .task {
            await viewModel.refreshStatus()
        }
    }
}

@MainActor
class NEARViewModel: ObservableObject {
    @Published var networkStatus: StatusResponse?
    @Published var accountInfo: AccountView?
    @Published var error: Error?
    @Published var isLoading = false
    
    private let client: NEARClient
    
    init() {
        do {
            self.client = try NEARClient(url: "https://rpc.testnet.near.org")
        } catch {
            // Default to testnet if custom URL fails
            do {
                self.client = try NEARClient()
            } catch {
                fatalError("Failed to initialize NEAR client: \(error)")
            }
        }
    }
    
    func refreshStatus() async {
        do {
            error = nil
            networkStatus = try await client.status()
        } catch {
            self.error = error
        }
    }
    
    func queryAccount(_ accountId: String) async {
        isLoading = true
        error = nil
        accountInfo = nil
        
        defer { isLoading = false }
        
        do {
            accountInfo = try await client.viewAccount(accountId: accountId)
        } catch {
            self.error = error
        }
    }
    
    func formatNEAR(_ yoctoNEAR: String) -> String {
        guard let amount = Double(yoctoNEAR) else { return "0 NEAR" }
        let near = amount / 1e24
        return String(format: "%.4f NEAR", near)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}