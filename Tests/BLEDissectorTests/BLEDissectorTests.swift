import XCTest
@testable import BLEDissector

final class Apple_BLE_DecoderTests: XCTestCase {
    func testDecodeAirpods() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
//        // results.
//
//        let airPodsAdvData = "010e2074fab711000010e4ff477405392c2016000016bb66eb".hexadecimal!
//
//        let decoder = AirPodsBLEDecoder()
//        let decoded = decoder.decode(airPodsAdvData)
//
//        print(decoded)
    }
    
    func testIPConversion() {
        let hex = "c0a8026d".hexadecimal!
        var ipArray = Array<UInt8>(hex)
        var ipString : [CChar] = Array<CChar>(repeating: 0x00, count: 32)
        if  inet_ntop(AF_INET, &ipArray, &ipString, 32) != nil {
            print(String(cString: &ipString))
            XCTAssertEqual(String(cString: &ipString), "192.168.2.109")
        }
        
    }
    
    func testHomeKitDissector() {
        let hex = "063100DEAF93CD7E420900523B0202C642F3A9".hexadecimal!
        
        let decoder = AppleBLEDecoding.HomeKitDecoder()
        do {
            let decoded = try decoder.decode(hex)
            XCTAssertNotNil(decoded["status"])
            XCTAssertNotNil(decoded["deviceId"])
            XCTAssertNotNil(decoded["category"])
            XCTAssertNotNil(decoded["globalStateNumber"])
            XCTAssertNotNil(decoded["configNumber"])
            XCTAssertNotNil(decoded["compatibleVersion"])
        }catch {
            XCTFail()
        }
        
    }

    static var allTests = [
        ("testDecodeAirpods", testDecodeAirpods),
    ]
}
