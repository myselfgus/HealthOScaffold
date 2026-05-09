import XCTest

final class HealthOSConstructionSystemTests: XCTestCase {
    func testConstructorRootKeepsAIOrganizationVisible() throws {
        let root = try repositoryRoot()
        let requiredPaths = [
            "AGENTS.md",
            "CLAUDE.md",
            "HealthOS/Constructor/README.md",
            "HealthOS/Constructor/Steward/README.md",
            "HealthOS/Constructor/Settler/README.md",
            "HealthOS/Constructor/Settler/territories/territory.schema.json",
            "HealthOS/Constructor/ts/agent-infra/healthos-steward/package.json",
            "HealthOS/Constructor/ts/agent-infra/healthos-forge-mcp/package.json",
            "HealthOS/Xcode/PromptPacks/HealthOS-Agentic-Coding.md",
        ]

        for relativePath in requiredPaths {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appending(path: relativePath).path),
                "Missing construction-system path: \(relativePath)"
            )
        }
    }

    func testWorkspaceExposesConstructorAndSupportForXcodeNavigation() throws {
        let root = try repositoryRoot()
        let workspace = root.appending(path: "HealthOS.xcworkspace/contents.xcworkspacedata")
        let packageManifest = root.appending(path: "HealthOS/Package.swift")

        for file in [workspace, packageManifest] {
            let contents = try String(contentsOf: file, encoding: .utf8)
            XCTAssertTrue(contents.contains("Constructor"), "Workspace must expose Constructor")
            XCTAssertTrue(contents.contains("Support"), "Workspace must expose Support")
        }
    }
}

private func repositoryRoot() throws -> URL {
    var current = URL(fileURLWithPath: #filePath)
    current.deleteLastPathComponent()

    while current.path != "/" {
        if FileManager.default.fileExists(atPath: current.appending(path: "AGENTS.md").path),
           FileManager.default.fileExists(atPath: current.appending(path: "HealthOS/Package.swift").path) {
            return current
        }
        current.deleteLastPathComponent()
    }

    throw XCTSkip("Repository root not found")
}
