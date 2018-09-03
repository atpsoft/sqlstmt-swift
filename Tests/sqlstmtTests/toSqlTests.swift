import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
  func testToSql() {
    // TODO; test nil or document why we can't

    XCTAssertEqual("'blah'", "blah".toSql())
    XCTAssertEqual("'b\\\\lah'", "b\\lah".toSql())
    XCTAssertEqual("'b\\'lah'", "b'lah".toSql())
    XCTAssertEqual("'b\\\"lah'", "b\"lah".toSql())

    // TODO: test numbers

    XCTAssertEqual("1", true.toSql())
    XCTAssertEqual("0", false.toSql())

    // TODO: test date, datetime
    // TODO: test array
  }

  static var allTests = [
    ("testToSql", testToSql),
  ]
}
