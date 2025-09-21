import ArgumentParser
import Foundation

@main
struct Generate: AsyncParsableCommand {
    static let configuration = CommandConfiguration(
        abstract: "Generate NEAR Swift client from OpenAPI specification",
        discussion: "Downloads the latest NEAR OpenAPI spec and generates Swift code with proper JSON-RPC handling"
    )
    
    @Option(help: "URL of the OpenAPI specification")
    var specURL = "https://raw.githubusercontent.com/near/nearcore/master/chain/jsonrpc/openapi/openapi.json"
    
    @Option(help: "Output directory for generated code")
    var outputDir = "./Sources"
    
    @Flag(help: "Skip downloading and use local spec file")
    var useLocal = false
    
    @Option(help: "Local spec file path")
    var localSpecPath = "./openapi.json"
    
    func run() async throws {
        print("🚀 Starting NEAR Swift client generation...")
        
        // Step 1: Download or load OpenAPI spec
        let specData = try await loadOpenAPISpec()
        
        // Step 2: Parse and patch the spec
        let patchedSpec = try patchOpenAPISpec(specData)
        
        // Step 3: Generate Swift code
        try await generateSwiftCode(from: patchedSpec)
        
        // Step 4: Apply post-processing
        try postProcessGeneratedCode()
        
        print("✅ Generation complete!")
    }
    
    private func loadOpenAPISpec() async throws -> Data {
        if useLocal {
            print("📄 Loading local OpenAPI spec from: \(localSpecPath)")
            return try Data(contentsOf: URL(fileURLWithPath: localSpecPath))
        } else {
            print("⬇️  Downloading OpenAPI spec from: \(specURL)")
            let url = URL(string: specURL)!
            let (data, _) = try await URLSession.shared.data(from: url)
            
            // Save for future reference
            try data.write(to: URL(fileURLWithPath: localSpecPath))
            
            return data
        }
    }
    
    private func patchOpenAPISpec(_ data: Data) throws -> Data {
        print("🔧 Patching OpenAPI spec for JSON-RPC compatibility...")
        
        var spec = try JSONSerialization.jsonObject(with: data) as! [String: Any]
        
        // Patch: All operations should use the same path "/"
        if var paths = spec["paths"] as? [String: Any] {
            var newPaths: [String: Any] = [:]
            var rootPath: [String: Any] = [:]
            
            for (path, operations) in paths {
                if let ops = operations as? [String: Any] {
                    for (method, operation) in ops {
                        if var op = operation as? [String: Any] {
                            // Extract the method name from the path
                            let methodName = path.replacingOccurrences(of: "/", with: "")
                            
                            // Add JSON-RPC method parameter
                            op["x-jsonrpc-method"] = methodName
                            
                            // Move all operations to root path
                            rootPath[method] = op
                        }
                    }
                }
            }
            
            newPaths["/"] = rootPath
            spec["paths"] = newPaths
        }
        
        // Add JSON-RPC specific server configuration
        spec["servers"] = [[
            "url": "https://rpc.testnet.near.org",
            "description": "NEAR Testnet RPC"
        ], [
            "url": "https://rpc.mainnet.near.org",
            "description": "NEAR Mainnet RPC"
        ]]
        
        return try JSONSerialization.data(withJSONObject: spec, options: .prettyPrinted)
    }
    
    private func generateSwiftCode(from spec: Data) async throws {
        print("🏗️  Generating Swift code...")

        // Save patched spec in YAML format (required by swift-openapi-generator)
        let patchedSpecPath = "./Sources/NEARJSONRPCTypes/openapi-patched.yaml"

        // Convert JSON spec to YAML
        let jsonObject = try JSONSerialization.jsonObject(with: spec)
        let yamlData = try convertToYAML(jsonObject)
        try yamlData.write(to: URL(fileURLWithPath: patchedSpecPath))

        print("📝 Saved patched spec to: \(patchedSpecPath)")
        print("⚙️  Running swift build to trigger OpenAPI generator plugin...")

        // The swift-openapi-generator plugin runs automatically during build
        // when it finds openapi.yaml and openapi-generator-config.yaml in the target directory
        let process = Process()
        process.executableURL = URL(fileURLWithPath: "/usr/bin/swift")
        process.arguments = ["build", "--target", "NEARJSONRPCTypes"]

        let pipe = Pipe()
        process.standardOutput = pipe
        process.standardError = pipe

        try process.run()
        process.waitUntilExit()

        let output = pipe.fileHandleForReading.readDataToEndOfFile()
        if let outputString = String(data: output, encoding: .utf8) {
            print(outputString)
        }

        if process.terminationStatus != 0 {
            throw GenerationError.codeGenerationFailed
        }

        print("✅ Code generation completed successfully")
    }

    private func convertToYAML(_ jsonObject: Any) throws -> Data {
        // Use PyYAML for conversion (requires Python)
        let jsonData = try JSONSerialization.data(withJSONObject: jsonObject, options: .prettyPrinted)
        let tempJSONPath = "/tmp/temp_openapi.json"
        let tempYAMLPath = "/tmp/temp_openapi.yaml"

        try jsonData.write(to: URL(fileURLWithPath: tempJSONPath))

        let convertProcess = Process()
        convertProcess.executableURL = URL(fileURLWithPath: "/usr/bin/python3")
        convertProcess.arguments = [
            "-c",
            """
            import json
            import yaml
            with open('\(tempJSONPath)', 'r') as f:
                data = json.load(f)
            with open('\(tempYAMLPath)', 'w') as f:
                yaml.dump(data, f, default_flow_style=False, sort_keys=False, allow_unicode=True)
            """
        ]

        try convertProcess.run()
        convertProcess.waitUntilExit()

        if convertProcess.terminationStatus != 0 {
            throw GenerationError.yamlConversionFailed
        }

        return try Data(contentsOf: URL(fileURLWithPath: tempYAMLPath))
    }
    
    private func postProcessGeneratedCode() throws {
        print("🎨 Post-processing generated code...")
        
        // Apply snake_case to camelCase conversion
        try applyNamingConventions()
        
        // Add JSON-RPC wrapper
        try addJSONRPCWrapper()
        
        // Add convenience methods
        try addConvenienceMethods()
    }
    
    private func applyNamingConventions() throws {
        let fileManager = FileManager.default
        let generatedFiles = try fileManager.contentsOfDirectory(atPath: outputDir)
            .filter { $0.hasSuffix(".swift") }
        
        for file in generatedFiles {
            let filePath = "\(outputDir)/\(file)"
            var content = try String(contentsOfFile: filePath)
            
            // Convert snake_case to camelCase
            let snakeCasePattern = #"(\w+)_(\w)"#
            let regex = try NSRegularExpression(pattern: snakeCasePattern)
            
            content = regex.stringByReplacingMatches(
                in: content,
                range: NSRange(content.startIndex..., in: content),
                withTemplate: "$1\\U$2"
            )
            
            try content.write(toFile: filePath, atomically: true, encoding: .utf8)
        }
    }
    
    private func addJSONRPCWrapper() throws {
        let wrapperContent = """
        import Foundation
        import OpenAPIRuntime
        import OpenAPIURLSession
        
        /// JSON-RPC wrapper for NEAR Protocol
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
        
        public struct JSONRPCError: Decodable, Error {
            public let code: Int
            public let message: String
            public let data: String?
        }
        
        /// Extension to handle JSON-RPC wrapping/unwrapping
        public extension Client {
            func callJSONRPC<Params: Encodable, Result: Decodable>(
                method: String,
                params: Params,
                resultType: Result.Type
            ) async throws -> Result {
                let request = JSONRPCRequest(method: method, params: params)
                let requestData = try JSONEncoder().encode(request)
                
                // Call the generated client method
                let response = try await self.post(
                    path: "/",
                    body: .json(requestData)
                )
                
                let responseData = try response.body.data
                let jsonResponse = try JSONDecoder().decode(
                    JSONRPCResponse<Result>.self,
                    from: responseData
                )
                
                if let error = jsonResponse.error {
                    throw error
                }
                
                guard let result = jsonResponse.result else {
                    throw JSONRPCError(code: -32603, message: "Internal error", data: nil)
                }
                
                return result
            }
        }
        """
        
        try wrapperContent.write(
            toFile: "\(outputDir)/NEARJSONRPCClient/JSONRPCWrapper.swift",
            atomically: true,
            encoding: .utf8
        )
    }
    
    private func addConvenienceMethods() throws {
        let convenienceContent = """
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
        """
        
        try convenienceContent.write(
            toFile: "\(outputDir)/NEARJSONRPCClient/NEARClient.swift",
            atomically: true,
            encoding: .utf8
        )
    }
}

enum GenerationError: Error {
    case codeGenerationFailed
    case invalidSpec
    case yamlConversionFailed
}