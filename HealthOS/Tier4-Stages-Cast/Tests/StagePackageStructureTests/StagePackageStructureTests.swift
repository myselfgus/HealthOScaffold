import XCTest

final class StagePackageStructureTests: XCTestCase {
    private let stageNames = ["Scribe", "Veridia", "CloudClinic"]

    private var tierRoot: URL {
        let testFile = URL(fileURLWithPath: #filePath)
        return testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
    }

    func testStageCustomDefinitionsExist() throws {
        for stage in stageNames {
            let custom = tierRoot
                .appending(path: stage)
                .appending(path: "Custom.md")
            let package = tierRoot
                .appending(path: stage)
                .appending(path: "Package.swift")
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: custom.path),
                "\(stage) must carry a Custom.md definition"
            )
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: package.path),
                "\(stage) must carry its own Swift package"
            )
        }
    }

    func testStagePackagesDependOnlyOnBoundaryAndCustomHealthOSProducts() throws {
        let forbiddenProducts = [
            "HealthOSCore",
            "HealthOSGOS",
            "HealthOSAACI",
            "HealthOSMSR",
            "HealthOSProviders",
            "HealthOSAsyncRuntime",
            "HealthOSUserAgentRuntime",
            "HealthOSServiceRuntime",
            "HealthOSSessionRuntime",
        ]

        for stage in stageNames {
            let package = tierRoot
                .appending(path: stage)
                .appending(path: "Package.swift")
            let contents = try String(contentsOf: package)

            XCTAssertTrue(
                contents.contains(#".product(name: "HealthOSBoundary""#),
                "\(stage) must consume HealthOS through the Boundary product"
            )
            XCTAssertTrue(
                contents.contains(#".product(name: "CustomSDK""#),
                "\(stage) must consume declared Custom capability contracts"
            )

            for product in forbiddenProducts {
                XCTAssertFalse(
                    contents.contains(#".product(name: "\#(product)""#),
                    "\(stage) must not depend directly on Tier 1/2 product \(product); add a Boundary/Custom facade instead"
                )
            }
        }
    }

    func testStageSourceDoesNotImportTier2OrAppleAuthorityFrameworksDirectly() throws {
        let forbiddenHealthOSImports = [
            "HealthOSCore",
            "HealthOSGOS",
            "HealthOSAACI",
            "HealthOSMSR",
            "HealthOSProviders",
            "HealthOSAsyncRuntime",
            "HealthOSUserAgentRuntime",
            "HealthOSServiceRuntime",
            "HealthOSSessionRuntime",
        ]
        let forbiddenAppleAuthorityImports = [
            "CloudKit",
            "FoundationModels",
            "CoreML",
            "NaturalLanguage",
            "Network",
            "ServiceManagement",
            "XPC",
        ]

        for stage in stageNames {
            let sourceRoot = tierRoot
                .appending(path: stage)
                .appending(path: "Sources")
            let swiftFiles = try swiftFiles(under: sourceRoot)

            for file in swiftFiles {
                let contents = try String(contentsOf: file)
                for module in forbiddenHealthOSImports {
                    assertDoesNotImport(module, in: contents, file: file)
                }
                for module in forbiddenAppleAuthorityImports {
                    assertDoesNotImport(
                        module,
                        in: contents,
                        file: file,
                        message: "Stage clinical execution must request Apple-backed capability through Custom/Boundary and Tier 2 adapters"
                    )
                }
            }
        }
    }

    func testStageSwiftDataImportsMustBeProjectionCacheOnlyAndDocumented() throws {
        for stage in stageNames {
            let stageRoot = tierRoot.appending(path: stage)
            let sourceRoot = stageRoot.appending(path: "Sources")
            let swiftFiles = try swiftFiles(under: sourceRoot)
            let filesImportingSwiftData = try swiftFiles.filter { file in
                try imports("SwiftData", in: String(contentsOf: file))
            }

            guard !filesImportingSwiftData.isEmpty else { continue }

            let custom = stageRoot.appending(path: "Custom.md")
            let readme = sourceRoot.appending(path: stage).appending(path: "README.md")
            let documentation = [custom, readme]
                .compactMap { try? String(contentsOf: $0).lowercased() }
                .joined(separator: "\n")

            XCTAssertTrue(
                documentation.contains("projection") || documentation.contains("cache"),
                "\(stage) imports SwiftData; its Custom or source README must state that SwiftData is projection/cache only, never canonical custody"
            )
            XCTAssertFalse(
                documentation.contains("canonical custody") && !documentation.contains("never canonical custody"),
                "\(stage) SwiftData documentation must not describe SwiftData as canonical custody"
            )
        }
    }

    private func swiftFiles(under root: URL) throws -> [URL] {
        guard FileManager.default.fileExists(atPath: root.path) else { return [] }
        let enumerator = FileManager.default.enumerator(
            at: root,
            includingPropertiesForKeys: [.isRegularFileKey],
            options: [.skipsHiddenFiles]
        )
        var files: [URL] = []
        while let file = enumerator?.nextObject() as? URL {
            guard file.pathExtension == "swift" else { continue }
            let values = try file.resourceValues(forKeys: [.isRegularFileKey])
            if values.isRegularFile == true {
                files.append(file)
            }
        }
        return files
    }

    private func assertDoesNotImport(
        _ module: String,
        in contents: String,
        file: URL,
        message: String? = nil,
        line: UInt = #line
    ) {
        XCTAssertFalse(
            imports(module, in: contents),
            "\(file.path) must not import \(module). \(message ?? "Stages consume HealthOS through CustomSDK and HealthOSBoundary only.")",
            line: line
        )
    }

    private func imports(_ module: String, in contents: String) -> Bool {
        contents.split(whereSeparator: \.isNewline).contains { rawLine in
            let line = rawLine.trimmingCharacters(in: .whitespaces)
            return line.range(of: "^(@testable\\s+)?import\\s+\(module)\\b", options: .regularExpression) != nil
        }
    }
}
