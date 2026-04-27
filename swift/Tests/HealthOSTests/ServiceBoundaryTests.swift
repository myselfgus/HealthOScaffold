import XCTest
@testable import HealthOSCore

final class ServiceBoundaryTests: XCTestCase {
    func testOutcomeSerialization() throws {
        let outcome: ServiceBoundaryOutcome<String> = .success("payload")
        let data = try JSONEncoder().encode(outcome)
        let decoded = try JSONDecoder().decode(ServiceBoundaryOutcome<String>.self, from: data)
        XCTAssertEqual(decoded.outcome, .success)
        XCTAssertEqual(decoded.payload, "payload")
    }
}
