import XCTest

final class HealthOSStageSmokeTests: XCTestCase {
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
            XCTAssertTrue(
                FileManager.default.fileExists(atPath: custom.path),
                "\(stage) must carry a Custom.md definition"
            )
        }
    }
}
