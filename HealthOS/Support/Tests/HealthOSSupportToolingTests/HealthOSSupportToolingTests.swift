import XCTest

final class HealthOSSupportToolingTests: XCTestCase {
    func testSupportRootKeepsOpsPythonAndMLToolingVisible() throws {
        let root = try repositoryRoot()
        let requiredPaths = [
            "HealthOS/Support/README.md",
            "HealthOS/Support/ops/backup/README.md",
            "HealthOS/Support/ops/network/ports.md",
            "HealthOS/Support/ops/network/tailscale-acl.example.json",
            "HealthOS/Support/python/README.md",
            "HealthOS/Support/python/pyproject.toml",
            "HealthOS/Support/python/healthos_ml/fine_tuning.py",
            "HealthOS/Support/ML/README.md",
            "HealthOS/Support/ML/transcript-normalizer/TrainTranscriptNormalizer.swift",
        ]

        for relativePath in requiredPaths {
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: root.appending(path: relativePath).path),
                "Missing support path: \(relativePath)"
            )
        }
    }

    func testSupportReadmeKeepsModelToolingGoverned() throws {
        let root = try repositoryRoot()
        let readme = root.appending(path: "HealthOS/Support/README.md")
        let contents = try String(contentsOf: readme, encoding: .utf8)

        XCTAssertTrue(contents.contains("Create ML"))
        XCTAssertTrue(contents.contains("Core ML"))
        XCTAssertTrue(contents.contains("MLX"))
        XCTAssertTrue(contents.contains("ModelGovernance"))
        XCTAssertTrue(contents.contains("not commit local secrets"))
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
