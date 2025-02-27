import XCTest
@testable import FidesmoSupport

final class FidesmoSupportTests: XCTestCase {
    func testExample() throws {
        // This is an example of a functional test case.
        XCTAssertNotNil(FidesmoSupport.clientInfo)
        XCTAssertNotNil(FidesmoSupport.apiDispatcher)
    }
} 