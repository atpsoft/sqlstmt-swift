import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
  func testSelect() throws {
    let sqlt = SqlStmt()
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.select().table("source").get("blah")
    XCTAssertEqual(["source"], sqlt.data.table_ids)
    XCTAssertEqual("SELECT blah FROM source", try sqlt.to_s())
  }

  static var allTests = [
    ("testSelect", testSelect),
  ]
}
