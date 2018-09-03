import XCTest
@testable import sqlstmt

final class selectTests: XCTestCase {
  func testGradually() throws {
    let sqlt = SqlStmt()

    // keep these chained together, so we have at least one test of the return value of all the method calls
    // in swift in particular, it is important because of class vs. struct; see SqlStmt definition for more info
    try sqlt.select().type(.select)
    XCTAssertThrowsError(try sqlt.update())

    sqlt.table("target")
    XCTAssertEqual(["target"], sqlt.data.table_ids)
    XCTAssertThrowsError(try sqlt.to_sql())

    sqlt.get("blah")
    XCTAssertThrowsError(try sqlt.to_sql())

    sqlt.no_where()
    XCTAssertEqual("SELECT blah FROM target", try sqlt.to_sql())

    sqlt.require_where()
    XCTAssertThrowsError(try sqlt.to_sql())

    sqlt.optional_where()
    XCTAssertEqual("SELECT blah FROM target", try sqlt.to_sql())

    sqlt.where("frog = 1")
    XCTAssertEqual("SELECT blah FROM target WHERE frog = 1", try sqlt.to_sql())

    sqlt.join("other o", "target.id = o.id")
    XCTAssertEqual(["target", "other", "o"], sqlt.data.table_ids)
    XCTAssertEqual("SELECT blah FROM target JOIN other o ON target.id = o.id WHERE frog = 1", try sqlt.to_sql())
  }

  func testSimpleWithSmallVariations() throws {
    let tmpl = SqlStmt()
    try tmpl.select().table("target t").get("blah").no_where()
    XCTAssertEqual(["target", "t"], tmpl.data.table_ids)

    var sqlt = tmpl.copy() as! SqlStmt
    sqlt.distinct()
    XCTAssertEqual("SELECT DISTINCT blah FROM target t", try sqlt.to_sql())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.join("other o", "t.blah_id = o.blah_id", "t.blee_id = o.blee_id")
    XCTAssertEqual("SELECT blah FROM target t JOIN other o ON t.blah_id = o.blah_id AND t.blee_id = o.blee_id", try sqlt.to_sql())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.left_join("other o", "t.blah_id = o.blah_id")
    XCTAssertEqual("SELECT blah FROM target t LEFT JOIN other o ON t.blah_id = o.blah_id", try sqlt.to_sql())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.get("blee", "bloo")
    XCTAssertEqual("SELECT blah,blee,bloo FROM target t", try sqlt.to_sql())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.having("blah > 0")
    XCTAssertEqual("SELECT blah FROM target t HAVING blah > 0", try sqlt.to_sql())

    sqlt = tmpl.copy() as! SqlStmt
    sqlt.group_by("blah")
    XCTAssertEqual("SELECT blah FROM target t GROUP BY blah", try sqlt.to_sql())
    sqlt.with_rollup()
    XCTAssertEqual("SELECT blah FROM target t GROUP BY blah WITH ROLLUP", try sqlt.to_sql())
  }

  func testTables() throws {
    var sqlt = try SqlStmt().select().table("target t", use_index: "blee").no_where().get("t.blah")
    XCTAssertEqual("SELECT t.blah FROM target t USE INDEX (blee)", try sqlt.to_sql())

    sqlt = try SqlStmt().select().table("target")
    XCTAssert(sqlt.includes_table("target"))
    XCTAssert(!sqlt.includes_table("blah"))

    sqlt = try SqlStmt().select().table("target t")
    XCTAssert(sqlt.includes_table("target"))
    XCTAssert(sqlt.includes_table("t"))

    sqlt = try SqlStmt().select().table("target AS t")
    XCTAssert(sqlt.includes_table("target"))
    XCTAssert(sqlt.includes_table("t"))

    sqlt.join("other o", "t.blah_id = o.blah_id")
    XCTAssert(sqlt.includes_table("other"))
    XCTAssert(sqlt.includes_table("o"))
  }

  static var allTests = [
    ("testGradually", testGradually),
    ("testSimpleWithSmallVariations", testSimpleWithSmallVariations),
    ("testTables", testTables),
  ]
}
