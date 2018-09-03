import XCTest

#if !os(macOS)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(toSqlTests.allTests),
        testCase(selectTests.allTests),
    ]
}
#endif
