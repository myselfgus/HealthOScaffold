import XCTest
import CustomSDK

final class ScribeTests: XCTestCase {
    func testCustomRejectsStubPersistence() {
        let custom = StageCustom(
            stageId: "scribe",
            displayName: "Scribe",
            role: "Professional documentation Stage",
            consumedSurfaces: [.init(identifier: "scribe.first-slice")],
            capabilities: [.init(identifier: "session.capture", description: "Capture governed session input")],
            prohibitions: [.init(identifier: "no-core-law", description: "Does not define Core law")],
            degradationPolicy: .init(mayPersistStubOutput: true, description: "invalid test policy"),
            validationRequirements: [.init(command: "swift run Scribe --smoke-test", purpose: "smoke")],
            maturity: .needsReview
        )

        XCTAssertTrue(StageCustomCompliance.validate(custom).contains("Stages must not persist stub output as real output"))
    }
}
