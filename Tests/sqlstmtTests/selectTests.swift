import XCTest
@testable import sqlstmt

final class selectTests: XCTestCase {
  func testGradually() throws {
    let sqlt = SqlStmt()

    try sqlt.select()
    try sqlt.type(.select)
    XCTAssertThrowsError(try sqlt.update())

    sqlt.table("target")
    XCTAssertEqual(["target"], sqlt.data.table_ids)
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.get("blah")
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.no_where()
    XCTAssertEqual("SELECT blah FROM target", try sqlt.to_s())

    sqlt.where("frog = 1")
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.optional_where()
    XCTAssertEqual("SELECT blah FROM target WHERE frog = 1", try sqlt.to_s())

    sqlt.join("other o", "target.id = o.id")
    XCTAssertEqual(["target", "other", "o"], sqlt.data.table_ids)
    XCTAssertEqual("SELECT blah FROM target JOIN other o ON target.id = o.id WHERE frog = 1", try sqlt.to_s())
  }

  static var allTests = [
    ("testGradually", testGradually),
  ]
}
