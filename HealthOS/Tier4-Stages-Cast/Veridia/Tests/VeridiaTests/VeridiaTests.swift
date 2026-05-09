import XCTest
import CustomSDK

final class VeridiaTests: XCTestCase {
    func testCustomHasRequiredSurface() {
        let custom = StageCustom(
            stageId: "veridia",
            displayName: "Veridia",
            role: "Patient identity Stage",
            consumedSurfaces: [.init(identifier: "veridia.session")],
            capabilities: [],
            prohibitions: [.init(identifier: "no-core-law", description: "Does not define Core law")],
            degradationPolicy: .init(description: "Render unavailable state when Boundary is unavailable"),
            validationRequirements: [.init(command: "swift run Veridia --smoke-test", purpose: "smoke")],
            maturity: .needsReview
        )

        XCTAssertTrue(StageCustomCompliance.validate(custom).isEmpty)
    }
}
