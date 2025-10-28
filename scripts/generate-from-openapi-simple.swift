#!/usr/bin/env swift

import Foundation

// Simplified script to download NEAR OpenAPI spec for type generation
// NO SPEC PATCHING NEEDED - The JSONRPCWrapper handles path routing

let fileManager = FileManager.default
let currentPath = fileManager.currentDirectoryPath

print("📥 NEAR Swift Client - OpenAPI Type Generator")
print("============================================")
print("")

// Download OpenAPI spec
print("📥 Downloading NEAR OpenAPI spec...")

let specURL = URL(string: "https://raw.githubusercontent.com/near/nearcore/master/chain/jsonrpc/openapi/openapi.json")!

do {
    let specData = try Data(contentsOf: specURL)

    // Save spec as-is (NO PATCHING!)
    let outputURL = URL(fileURLWithPath: "\(currentPath)/openapi.json")
    try specData.write(to: outputURL)

    print("✅ OpenAPI spec downloaded successfully")
    print("📁 Saved to: \(outputURL.path)")
    print("")

    // Verify spec is valid JSON
    let spec = try JSONSerialization.jsonObject(with: specData) as? [String: Any]

    if let info = spec?["info"] as? [String: Any],
       let version = info["version"] as? String,
       let title = info["title"] as? String {
        print("📋 Spec Info:")
        print("   Title: \(title)")
        print("   Version: \(version)")
    }

    if let paths = spec?["paths"] as? [String: Any] {
        print("   Methods: \(paths.keys.count)")
        print("")
        print("📝 Available endpoints:")
        for path in paths.keys.sorted() {
            print("   - \(path)")
        }
    }

    print("")
    print("🎯 ARCHITECTURE NOTE:")
    print("   ✓ OpenAPI spec is used ONLY for type generation")
    print("   ✓ Path information (/block, /status, etc.) is IGNORED")
    print("   ✓ JSONRPCWrapper routes all requests to '/' endpoint")
    print("   ✓ Method routing happens via JSON-RPC 'method' field")
    print("")
    print("✅ Ready for type generation!")
    print("")
    print("Next steps:")
    print("1. Run: swift-openapi-generator generate openapi.json")
    print("2. Generated types will be in Sources/NEARJSONRPCTypes/")
    print("3. JSONRPCWrapper will handle protocol translation")
    print("")
    print("For more details, see: docs/JSON-RPC-ARCHITECTURE.md")
} catch {
    print("❌ Error: \(error.localizedDescription)")
    exit(1)
}
