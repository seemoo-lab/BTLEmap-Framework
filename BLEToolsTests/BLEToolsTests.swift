//
//  BLEToolsTests.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
@testable import BLETools
import CoreBluetooth

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
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            if scanner.connectedToReceiver {
                expect.fulfill()
            }
        }

        scanner.scanForAppleAdvertisements()
        
        wait(for: [expect], timeout: 60.0)
    }
    
    func testGetCharacteristicsFromExternalSource() throws {
        let expect = expectation(description: "BLE Scanner")
        
        let scanner = BLEScanner(delegate: self,receiverType: .external)
        scanner.scanForAppleAdvertisements()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 20.0) {
            if let characteristics = scanner.deviceList.first(where: {$0.characteristics.count > 0}) {
                print("Received characteristics")
            }else {
                XCTFail()
            }
            
            expect.fulfill()
            scanner.scanning = false
        }
        
        scanner.scanForAppleAdvertisements()
        
        wait(for: [expect], timeout: 60.0)
    }
    
    static var raspiBooted = false
    static var bootExpect: XCTestExpectation!
    static var raspiConnected: (()->())!
    
    func testRaspiBootUpTime() {
        let start = Date() 
        let relayReceiver = BLERelayReceiver()
        let delegate = TestRelayDelegate()
        delegate.connectedExpect = self.expectation(description: "Raspi connection")
        delegate.connectedExpect.assertForOverFulfill = false
        relayReceiver.delegate = delegate
        BLEToolsTests.raspiConnected = {
            relayReceiver.stopScanningForAdvertisements()
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            relayReceiver.scanForAdvertisements(filterDuplicates: false)
        }
        
        self.waitForExpectations(timeout: 60.0) { (error) in
            XCTAssertNil(error)
            print(error)
            print("Execution took \(-start.timeIntervalSinceNow) seconds")
        }
    }
    
    func scanner(_ scanner: BLEScanner, didReceiveNewAdvertisement advertisement: BLEAdvertisment, forDevice device: BLEDevice) {
        print("Received advertisement")
        print(advertisement)
    }
    
    func scanner(_ scanner: BLEScanner, didDiscoverNewDevice device: BLEDevice) {
        print("Discovered device")
        print(device)
    }
    
    class TestRelayDelegate: BLEReceiverDelegate {
        
        var connected = false
        var connectedExpect: XCTestExpectation!
        
        func didStartScanning() {
            
        }
        
        func didReceive(advertisement: BLEAdvertisment) {
            
            self.connectedExpect.fulfill()
            print("Expectation fullfilled")
//            BLEToolsTests.raspiConnected()
            self.connected = true
        }
        
        func didReceive(advertisementData: [String : Any], rssi: NSNumber, from device: CBPeripheral) {
            
        }
        
        func didUpdateServices(services: [BLEService], forDevice id: String) {
            
        }
        
        func didUpdateCharacteristics(characteristics: [BLECharacteristic], andDevice id: String) {
            
        }
        
        
    }
}

