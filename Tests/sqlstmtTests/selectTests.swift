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

    sqlt.require_where()
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.optional_where()
    XCTAssertEqual("SELECT blah FROM target", try sqlt.to_s())

    sqlt.where("frog = 1")
    XCTAssertEqual("SELECT blah FROM target WHERE frog = 1", try sqlt.to_s())

    sqlt.join("other o", "target.id = o.id")
    XCTAssertEqual(["target", "other", "o"], sqlt.data.table_ids)
    XCTAssertEqual("SELECT blah FROM target JOIN other o ON target.id = o.id WHERE frog = 1", try sqlt.to_s())
  }

  func testMisc() throws {
    let tmpl = SqlStmt()
    try tmpl.select().table("target t").get("blah").no_where()
    XCTAssertEqual(["target", "t"], tmpl.data.table_ids)

    var sqlt = tmpl.copy() as! SqlStmt
    sqlt.distinct()
    XCTAssertEqual("SELECT DISTINCT blah FROM target t", try sqlt.to_s())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.left_join("other o", "t.blah_id = o.blah_id")
    XCTAssertEqual("SELECT blah FROM target t LEFT JOIN other o ON t.blah_id = o.blah_id", try sqlt.to_s())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.get("blee", "bloo")
    XCTAssertEqual("SELECT blah,blee,bloo FROM target t", try sqlt.to_s())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.having("blah > 0")
    XCTAssertEqual("SELECT blah FROM target t HAVING blah > 0", try sqlt.to_s())
  }

  static var allTests = [
    ("testGradually", testGradually),
    ("testMisc", testMisc),
  ]
}
