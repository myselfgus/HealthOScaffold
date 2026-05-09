import XCTest

final class StagePackageStructureTests: XCTestCase {
    func testStageCustomDefinitionsExist() throws {
        let testFile = URL(fileURLWithPath: #filePath)
        let tierRoot = testFile
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()

        for stage in ["Scribe", "Veridia", "CloudClinic"] {
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
}
