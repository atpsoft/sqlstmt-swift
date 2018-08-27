import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
  func testExample() throws {
    var sqlt = SqlStmt()
    XCTAssertThrowsError(try sqlt.to_s())

    sqlt.select()
    sqlt.table("source")
    sqlt.get("blah")
    sqlt.no_where()

    // need to get this working, but for the moment the chaining doesn't work right
    // sqlt = SqlStmt()
    // sqlt.select().table("source").get("blah").no_where()

    XCTAssertEqual("SELECT blah FROM source", try sqlt.to_s())
  }

  static var allTests = [
    ("testExample", testExample),
  ]
}
