//
//  TLVTests.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 02.03.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
import BLETools

class TLVTests: XCTestCase {
    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testTLV8Parsing() {
        var box = TLV.TLVBox()
        box.addValue(withType: 0x0c, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a]))
        
        box.addValue(withType: 0x0d, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0b]))
        
        box.addValue(withType: 0x0e, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0c]))
        
        let serialized = try! box.serialize()
        
        let parsed = try! TLV.TLVBox.deserialize(fromData: serialized, withSize: .tlv8)
        
        XCTAssertEqual(box.getValue(forType:  0x0c), parsed.getValue(forType: 0x0c))
        XCTAssertEqual(box.getValue(forType:  0x0d), parsed.getValue(forType: 0x0d))
        XCTAssertEqual(box.getValue(forType:  0x0e), parsed.getValue(forType: 0x0e))
    }
    
    func testTLV16Parsing() {
        var box = TLV.TLVBox(size: .tlv16)
        
        box.addValue(withType: 0x0c, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a]))
        
        box.addValue(withType: 0x0d, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0b]))
        
        box.addValue(withType: 0x0e, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0c]))
        
        let serialized = try! box.serialize()
        
        let parsed = try! TLV.TLVBox.deserialize(fromData: serialized, withSize: .tlv16)
        
        XCTAssertEqual(box.getValue(forType:  0x0c), parsed.getValue(forType: 0x0c))
        XCTAssertEqual(box.getValue(forType:  0x0d), parsed.getValue(forType: 0x0d))
        XCTAssertEqual(box.getValue(forType:  0x0e), parsed.getValue(forType: 0x0e))
    }

    func testTLV32Parsing() {
        var box = TLV.TLVBox(size: .tlv32)
        
        box.addValue(withType: 0x0c, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a]))
        
        box.addValue(withType: 0x0d, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0b]))
        
        box.addValue(withType: 0x0e, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0c]))
        
        let serialized = try! box.serialize()
        
        let parsed = try! TLV.TLVBox.deserialize(fromData: serialized, withSize: .tlv32)
        
        XCTAssertEqual(box.getValue(forType:  0x0c), parsed.getValue(forType: 0x0c))
        XCTAssertEqual(box.getValue(forType:  0x0d), parsed.getValue(forType: 0x0d))
        XCTAssertEqual(box.getValue(forType:  0x0e), parsed.getValue(forType: 0x0e))
    }
    
    func testTLV64Parsing() {
        var box = TLV.TLVBox(size: .tlv64)
        
        box.addValue(withType: 0x0c, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0a]))
        
        box.addValue(withType: 0x0d, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0b]))
        
        box.addValue(withType: 0x0e, andLength: 10, andValue: Data([0x01,0x02,0x03,0x04,0x05,0x06,0x07,0x08,0x09,0x0c]))
        
        let serialized = try! box.serialize()
        
        let parsed = try! TLV.TLVBox.deserialize(fromData: serialized, withSize: .tlv64)
        
        XCTAssertEqual(box.getValue(forType:  0x0c), parsed.getValue(forType: 0x0c))
        XCTAssertEqual(box.getValue(forType:  0x0d), parsed.getValue(forType: 0x0d))
        XCTAssertEqual(box.getValue(forType:  0x0e), parsed.getValue(forType: 0x0e))
    }
}
