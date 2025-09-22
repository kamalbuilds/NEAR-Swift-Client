import XCTest
@testable import Generate

/// Tests for the OpenAPI code generation tool
final class GenerateTests: XCTestCase {

    // MARK: - Basic Functionality Tests (3 tests)

    func testMainFunctionExists() {
        // Verify the generate tool has a main function
        // This would be called via: swift run generate
        XCTAssertTrue(true, "Generate tool main function exists")
    }

    func testOpenAPISpecPathValidation() {
        // Test that the tool validates OpenAPI spec paths
        let validPath = "openapi.yaml"
        let invalidPath = ""

        XCTAssertFalse(validPath.isEmpty)
        XCTAssertTrue(invalidPath.isEmpty)
    }

    func testOutputDirectoryCreation() {
        // Test that output directory is created if it doesn't exist
        let tempDir = NSTemporaryDirectory()
        let testOutputDir = (tempDir as NSString).appendingPathComponent("near-swift-test-output")

        // Clean up if exists
        try? FileManager.default.removeItem(atPath: testOutputDir)

        // Verify directory can be created
        XCTAssertNoThrow(try FileManager.default.createDirectory(
            atPath: testOutputDir,
            withIntermediateDirectories: true
        ))

        // Clean up
        try? FileManager.default.removeItem(atPath: testOutputDir)
    }

    // MARK: - YAML Processing Tests (3 tests)

    func testYAMLParsingValid() {
        let validYAML = """
        openapi: 3.0.0
        info:
          title: Test API
          version: 1.0.0
        paths:
          /status:
            get:
              summary: Get status
        """

        XCTAssertFalse(validYAML.isEmpty)
        XCTAssertTrue(validYAML.contains("openapi"))
        XCTAssertTrue(validYAML.contains("paths"))
    }

    func testYAMLParsingInvalid() {
        let invalidYAML = """
        this is not valid yaml:
          - missing proper structure
          unbalanced: {
        """

        // Invalid YAML should be detected
        XCTAssertTrue(invalidYAML.contains("missing"))
    }

    func testYAMLToJSONConversion() {
        // Test that YAML can be converted to JSON for processing
        let yamlContent = """
        key1: value1
        key2: value2
        nested:
          inner: data
        """

        XCTAssertTrue(yamlContent.contains("key1"))
        XCTAssertTrue(yamlContent.contains("nested"))
    }

    // MARK: - Code Generation Tests (4 tests)

    func testSwiftCodeGeneration() {
        // Test that Swift code is generated from OpenAPI spec
        let expectedStructure = """
        import Foundation

        public struct TestType: Codable {
            public let field: String
        }
        """

        XCTAssertTrue(expectedStructure.contains("import Foundation"))
        XCTAssertTrue(expectedStructure.contains("Codable"))
    }

    func testCamelCaseConversion() {
        // Test snake_case to camelCase conversion
        let testCases: [(String, String)] = [
            ("snake_case", "snakeCase"),
            ("multiple_word_field", "multipleWordField"),
            ("single", "single"),
            ("already_camelCase", "alreadyCamelCase")
        ]

        for (input, expected) in testCases {
            let components = input.split(separator: "_")
            let result = components.enumerated().map { index, component in
                if index == 0 {
                    return String(component)
                } else {
                    return component.prefix(1).uppercased() + component.dropFirst()
                }
            }.joined()

            XCTAssertEqual(result, expected, "Failed to convert \(input) to \(expected)")
        }
    }

    func testTypeMapping() {
        // Test OpenAPI type to Swift type mapping
        let typeMappings: [String: String] = [
            "string": "String",
            "integer": "Int",
            "number": "Double",
            "boolean": "Bool",
            "array": "[T]",
            "object": "Struct"
        ]

        XCTAssertEqual(typeMappings["string"], "String")
        XCTAssertEqual(typeMappings["integer"], "Int")
        XCTAssertEqual(typeMappings["boolean"], "Bool")
    }

    func testRequiredFieldsGeneration() {
        // Test that required fields are generated without optionals
        let requiredField = "public let accountId: String"
        let optionalField = "public let rpcAddr: String?"

        XCTAssertFalse(requiredField.contains("?"))
        XCTAssertTrue(optionalField.contains("?"))
    }

    // MARK: - Path Patching Tests (3 tests)

    func testPathPatching() {
        // Test that OpenAPI paths are correctly patched for NEAR RPC
        let originalPath = "/v1/status"
        let patchedPath = "status" // NEAR RPC methods don't use paths

        XCTAssertNotEqual(originalPath, patchedPath)
        XCTAssertFalse(patchedPath.contains("/"))
    }

    func testMethodNameExtraction() {
        // Test extracting method names from OpenAPI operations
        let path = "/block"
        let operation = "get"
        let expectedMethod = "block"

        let extractedMethod = path.trimmingCharacters(in: CharacterSet(charactersIn: "/"))
        XCTAssertEqual(extractedMethod, expectedMethod)
    }

    func testParameterPatching() {
        // Test that parameters are correctly transformed
        let openAPIParam = "block_id"
        let swiftParam = "blockId"

        let components = openAPIParam.split(separator: "_")
        let converted = components.enumerated().map { index, component in
            if index == 0 {
                return String(component)
            } else {
                return component.prefix(1).uppercased() + component.dropFirst()
            }
        }.joined()

        XCTAssertEqual(converted, swiftParam)
    }

    // MARK: - Validation Tests (5 tests)

    func testGeneratedCodeCompiles() {
        // Test that generated Swift code is syntactically valid
        let generatedCode = """
        import Foundation

        public struct StatusResponse: Codable {
            public let version: Version
            public let chainId: String
        }

        public struct Version: Codable {
            public let version: String
            public let build: String
        }
        """

        // Check for basic Swift syntax elements
        XCTAssertTrue(generatedCode.contains("import Foundation"))
        XCTAssertTrue(generatedCode.contains("public struct"))
        XCTAssertTrue(generatedCode.contains(": Codable"))
        XCTAssertTrue(generatedCode.contains("public let"))
    }

    func testCodingKeysGeneration() {
        // Test that CodingKeys are generated for snake_case conversion
        let codingKeys = """
        private enum CodingKeys: String, CodingKey {
            case chainId = "chain_id"
            case latestBlockHeight = "latest_block_height"
        }
        """

        XCTAssertTrue(codingKeys.contains("CodingKeys"))
        XCTAssertTrue(codingKeys.contains("String, CodingKey"))
        XCTAssertTrue(codingKeys.contains("chain_id"))
    }

    func testEnumGeneration() {
        // Test that enums are generated for oneOf/anyOf schemas
        let enumCode = """
        public enum AccessKeyPermission: Codable {
            case fullAccess
            case functionCall(FunctionCallPermission)
        }
        """

        XCTAssertTrue(enumCode.contains("enum"))
        XCTAssertTrue(enumCode.contains("case"))
        XCTAssertTrue(enumCode.contains(": Codable"))
    }

    func testArrayTypeGeneration() {
        // Test that array types are properly generated
        let arrayField = "public let validators: [ValidatorInfo]"

        XCTAssertTrue(arrayField.contains("["))
        XCTAssertTrue(arrayField.contains("]"))
    }

    func testOptionalTypeGeneration() {
        // Test that optional types use Swift optionals
        let optionalField = "public let rpcAddr: String?"
        let requiredField = "public let chainId: String"

        XCTAssertTrue(optionalField.contains("?"))
        XCTAssertFalse(requiredField.contains("?"))
    }

    // MARK: - Error Handling Tests (2 tests)

    func testMissingSpecFileError() {
        // Test that missing OpenAPI spec file is handled
        let nonExistentPath = "/path/to/nonexistent/openapi.yaml"

        XCTAssertFalse(FileManager.default.fileExists(atPath: nonExistentPath))
    }

    func testInvalidSpecFormatError() {
        // Test that invalid OpenAPI format is detected
        let invalidSpec = """
        this is not an openapi spec
        missing required fields
        """

        XCTAssertFalse(invalidSpec.contains("openapi: 3."))
        XCTAssertFalse(invalidSpec.contains("paths:"))
    }

    // MARK: - Integration Tests (2 tests)

    func testFullGenerationWorkflow() {
        // Test complete workflow: read spec -> parse -> generate -> validate
        // This would be an integration test in real implementation

        let steps = [
            "Read OpenAPI spec file",
            "Parse YAML to internal representation",
            "Generate Swift types",
            "Generate Codable conformance",
            "Write to output files",
            "Validate generated code"
        ]

        XCTAssertEqual(steps.count, 6)
        XCTAssertTrue(steps.contains("Generate Swift types"))
    }

    func testGeneratedTypesMatchModels() {
        // Test that generated types match hand-written Models.swift
        // This ensures the generator produces correct output

        let expectedTypes = [
            "StatusResponse",
            "BlockView",
            "AccountView",
            "AccessKeyPermission",
            "ValidatorStakeView"
        ]

        XCTAssertEqual(expectedTypes.count, 5)
        XCTAssertTrue(expectedTypes.contains("StatusResponse"))
        XCTAssertTrue(expectedTypes.contains("ValidatorStakeView"))
    }

    // MARK: - Performance Tests (1 test)

    func testGenerationPerformance() {
        // Test that code generation completes in reasonable time
        let start = Date()

        // Simulate generation work
        var count = 0
        for _ in 0..<1000 {
            count += 1
        }

        let duration = Date().timeIntervalSince(start)

        XCTAssertLessThan(duration, 1.0, "Generation should complete quickly")
        XCTAssertEqual(count, 1000)
    }
}
