import XCTest
import CustomSDK

final class CloudClinicTests: XCTestCase {
    func testCustomNeedsConsumedSurface() {
        let custom = StageCustom(
            stageId: "cloudclinic",
            displayName: "CloudClinic",
            role: "Service operations Stage",
            consumedSurfaces: [],
            capabilities: [],
            prohibitions: [.init(identifier: "no-core-law", description: "Does not define Core law")],
            degradationPolicy: .init(description: "Render unavailable state when Boundary is unavailable"),
            validationRequirements: [.init(command: "swift run CloudClinic --smoke-test", purpose: "smoke")],
            maturity: .needsReview
        )

        XCTAssertTrue(StageCustomCompliance.validate(custom).contains("at least one Boundary-consumed surface is required"))
    }
}
