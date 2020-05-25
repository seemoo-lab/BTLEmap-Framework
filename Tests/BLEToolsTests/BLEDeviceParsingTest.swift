//
//  BLEDeviceParsingTest.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 23.04.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
@testable import BLETools

class BLEDeviceParsingTest: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testDeviceModelDescription() {
        let modelNames = ["iPhone12,3", "MacBookAir8,1", "iMac15,1", "MacBookPro15,1", "iPhone100"]
        let expectedDescriptions = ["iPhone 11 Pro", "MacBook retina 13-inch, Mid 2018", "iMac retina 5K 27-inch, Late 2014/Mid 2015", "MacBook retina 15-inch, Mid 2018/Mid 2019", "iPhone100"]
        
        let expectedDeviceTypes: [BLEDeviceModel.DeviceType] = [.iPhone, .macBook, .iMac, .macBook, .iPhone]
        
        let deviceModels = modelNames.map{ BLEDeviceModel($0) }
        
        for (idx, model) in deviceModels.enumerated() {
            XCTAssertEqual(model.modelDescription, expectedDescriptions[idx])
            XCTAssertEqual(model.deviceType, expectedDeviceTypes[idx])
        }
    }

}
