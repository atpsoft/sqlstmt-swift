import XCTest
@testable import sqlstmt

final class selectTests: XCTestCase {
  func testSelect() throws {
    var sqlt = SqlStmt()
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.table("source")
    XCTAssertEqual(["source"], sqlt.data.table_ids)

    sqlt = SqlStmt()
    try sqlt.select().table("source s").get("blah").no_where()
    XCTAssertEqual(["source", "s"], sqlt.data.table_ids)
    XCTAssertEqual("SELECT blah FROM source s", try sqlt.to_s())

    sqlt.join("other o", "s.blah_id = o.blah_id")
    XCTAssertEqual("SELECT blah FROM source s JOIN other o ON s.blah_id = o.blah_id", try sqlt.to_s())

    // fail if we've already set the statement type to select
    XCTAssertThrowsError(try sqlt.update())
  }

  static var allTests = [
    ("testSelect", testSelect),
  ]
}
