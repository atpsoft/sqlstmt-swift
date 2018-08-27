import XCTest
@testable import sqlstmt

final class sqlstmtTests: XCTestCase {
  func testNoCalls() throws {
    let sqlt = SqlStmt()
    XCTAssertThrowsError(try sqlt.to_s())
  }

  func testSimplestValidSelect() throws {
    let sqlt = SqlStmt()
    sqlt.select()
    sqlt.table("source")
    sqlt.get("blah")
    sqlt.no_where()
    XCTAssertEqual("SELECT blah FROM source", try sqlt.to_s())
  }

  func testMethodChaining() throws {
    let sqlt = SqlStmt()
    sqlt.select().table("source").get("blah").no_where()
    XCTAssertEqual("SELECT blah FROM source", try sqlt.to_s())
  }

  static var allTests = [
    ("testNoCalls", testNoCalls),
    ("testSimplestValidSelect", testSimplestValidSelect),
    ("testMethodChaining", testMethodChaining),
  ]
}
