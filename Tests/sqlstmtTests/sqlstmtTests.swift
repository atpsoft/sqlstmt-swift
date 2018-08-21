import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        // results.
        XCTAssertEqual(SqlStmt().build(), "Hello, World!")
    }


    static var allTests = [
        ("testExample", testExample),
    ]
}
