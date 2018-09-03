import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
  func testToSql() {
    XCTAssertEqual("'blah'", "blah".toSql())
    XCTAssertEqual("'b\\\\lah'", "b\\lah".toSql())
    XCTAssertEqual("'b\\'lah'", "b'lah".toSql())
    XCTAssertEqual("'b\\\"lah'", "b\"lah".toSql())

    XCTAssertEqual("1", true.toSql())
    XCTAssertEqual("0", false.toSql())
  }

  static var allTests = [
    ("testToSql", testToSql),
  ]
}
