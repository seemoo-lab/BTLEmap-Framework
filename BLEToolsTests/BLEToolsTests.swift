//
//  BLEToolsTests.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
@testable import BLETools

class BLEToolsTests: XCTestCase, BLEScannerDelegate {

    

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testAttributedStringForAdvertisement() throws {
        let manufData = "4c000c0e 00d46fd6 c0971400 ee2b84bb 72f31006 7b1ea9ed 12c1".hexadecimal!
        
        let adv = try BLEAdvertisment(manufacturerData: manufData, id: 0)
        let attributedString = adv.dataAttributedString
        
        print(attributedString)
        
        
    }
    
    

    func testScanningForDevices() throws {
        let expect = expectation(description: "BLE Scanner")
        let scanner = BLEScanner(delegate: self)
        scanner.scanForAppleAdvertisements()
        DispatchQueue.main.asyncAfter(deadline: .now() + 10) {
            expect.fulfill()
        }
        wait(for: [expect], timeout: 60.0)
    }
    
    func testConnectingToExternalscanner() {
        let expect = expectation(description: "BLE Scanner")
        
        let scanner = BLEScanner(delegate: self)
        scanner.scanForAppleAdvertisements()
        scanner.receiverType = .external
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 15.0) {
            if scanner.connectedToReceiver {
                expect.fulfill()
            }
        }

        
        scanner.scanForAppleAdvertisements()
        
        wait(for: [expect], timeout: 60.0)
    }
    
    func scanner(_ scanner: BLEScanner, didReceiveNewAdvertisement advertisement: BLEAdvertisment, forDevice device: BLEDevice) {
        print("Received advertisement")
        print(advertisement)
    }
    
    func scanner(_ scanner: BLEScanner, didDiscoverNewDevice device: BLEDevice) {
        print("Discovered device")
        print(device)
    }
    
}

