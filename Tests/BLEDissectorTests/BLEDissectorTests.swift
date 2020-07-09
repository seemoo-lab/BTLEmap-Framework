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
    
    func testManufacturerData() {
        
        let hexData = "4C00100504982E25F0".hexadecimal!
        
        let dissected = ManufacturerDataDissector.dissect(data: hexData)
        
        XCTAssertEqual(dissected.name, "Manufacturer Data")
        XCTAssertEqual(dissected.byteRange.lowerBound, 0)
        XCTAssertEqual(dissected.subEntries.count, 1)
        XCTAssertEqual(dissected.subEntries[0].name, "Nearby Info")
        XCTAssertEqual(dissected.subEntries[0].byteRange.lowerBound, 4)
    }
    
    func testOfflineFindingMfD() {
        let hexData = "4C00121900EA53A04FD71ED534080DE2F409310C64AACABCEC8ED70100".hexadecimal!
        
        let dissected = ManufacturerDataDissector.dissect(data: hexData)
        
        XCTAssertEqual(dissected.name, "Manufacturer Data")
        XCTAssertEqual(dissected.subEntries.count, 1)
        XCTAssertEqual(dissected.subEntries[0].name, "Offline Finding")
    }
    
    func testMultipleAdvertisements() {
        let hexData = "4C 00 0C 0E 00 31 2A 3A 3C 7D FA 7F C8 E7 C8 63 9B FC 10 05 01 18 10 96 B1".hexadecimal!
        
        let dissected = ManufacturerDataDissector.dissect(data: hexData)
        XCTAssertEqual(dissected.name, "Manufacturer Data")
        XCTAssertEqual(dissected.byteRange.lowerBound, 0)
        XCTAssertEqual(dissected.subEntries.count, 2)
        XCTAssertEqual(dissected.subEntries[0].name, "Handoff / UC")
        XCTAssertEqual(dissected.subEntries[1].name, "Nearby Info")
    }
    
    func testNearbyActionDecoder() {
        let actionAdvData = "4c000f05a0336f0c56".hexadecimal!
        let dissected = ManufacturerDataDissector.dissect(data: actionAdvData)
        
        XCTAssertEqual(dissected.name, "Manufacturer Data")
        XCTAssertEqual(dissected.byteRange.lowerBound, 0)
        XCTAssertEqual(dissected.subEntries.count, 1)
        XCTAssertEqual(dissected.subEntries[0].name, "Nearby Action")
    }

    static var allTests = [
        ("testDecodeAirpods", testDecodeAirpods),
    ]
}
