import XCTest

#if !canImport(ObjectiveC)
public func allTests() -> [XCTestCaseEntry] {
    return [
        testCase(Apple_BLE_DecoderTests.allTests),
    ]
}
#endif
