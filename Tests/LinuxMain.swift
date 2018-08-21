import XCTest

import sqlstmtTests

var tests = [XCTestCaseEntry]()
tests += sqlstmtTests.allTests()
XCTMain(tests)