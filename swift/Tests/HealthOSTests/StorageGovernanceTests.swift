import XCTest
@testable import HealthOSCore

final class StorageGovernanceTests: XCTestCase {
    func testSensitiveLayerRequiresLawfulContext() {
        let layer: StorageLayer = .directIdentifiers
        XCTAssertThrowsError(try StorageLayerValidator.validate(layer: layer, lawfulContext: nil)) { error in
            XCTAssertEqual(error as? StorageLayerFailure, .missingLawfulContext(layer))
        }
    }
}
