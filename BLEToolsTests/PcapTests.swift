//
//  PcapExportTests.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
import CoreBluetooth
@testable import BLETools

class PcapTests: XCTestCase {

    override func setUpWithError() throws {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }


    func testPcapExport() {
        let expect = expectation(description: "PCAP Export")
        
        let scanner = BLEScanner(filterDuplicates: false, receiverType: .coreBluetooth, autoconnect: false)
        scanner.scanForAppleAdvertisements()
        
        DispatchQueue.global(qos: .background).async {
            while true {
                if scanner.advertisements.count > 500 {
                    
                    DispatchQueue.main.async {
                        scanner.scanning = false
                        let advertisements = scanner.advertisements
                        // exported data
                        let exported = PcapExport.export(advertisements: Array(advertisements))
                        
                        //Store to file
                        let desktopUrl = FileManager.default.urls(for: .desktopDirectory, in: .userDomainMask).first!
                        let exportUrl = desktopUrl.appendingPathComponent("exported.pcap")
                        
                        try! exported.write(to: exportUrl)
                        expect.fulfill()
                        
                    }
                    break
                }
            }
        }
        
        self.wait(for: [expect], timeout: 30)
    }
    
    func testPcapImport() {
        let expect = expectation(description: "PCAP Import")
        
        let scanner = BLEScanner(filterDuplicates: false, receiverType: .coreBluetooth, autoconnect: false)
        scanner.scanForAppleAdvertisements()
        
        DispatchQueue.global(qos: .background).async {
            while true {
                let exportNum = 500
                if scanner.advertisements.count > exportNum {
                    
                    DispatchQueue.main.async {
                        scanner.scanning = false
                        let advertisements = scanner.advertisements
                        // exported data
                        let exported = PcapExport.export(advertisements: Array(advertisements))
                        
                        do {
                            let imported = try PcapImport.from(data: exported)
                            
                            XCTAssert(imported.count >= exportNum)
                            
                        }catch let error {
                            XCTFail(String(describing: error))
                        }
                        
                        expect.fulfill()
                        
                    }
                    break
                }
            }
        }
        
        self.wait(for: [expect], timeout: .infinity)
    }
    
    func testBLEScannerPcapImport() {
        
        let pcapURL = Bundle(for: PcapTests.self).url(forResource: "exported", withExtension: "pcap")!
        let pcapData = try! Data(contentsOf: pcapURL)
        
        let expect = expectation(description: "PCAP Import")
        let scanner = BLEScanner(filterDuplicates: false, receiverType: .coreBluetooth, autoconnect: false)
        scanner.scanning = false
        
        scanner.importPcap(from: pcapData) { (result) in
            switch result {
            case .success(_):
                break
            case .failure(let error):
                XCTFail(String(describing: error))
            }
            
            expect.fulfill()
            
            XCTAssert(scanner.advertisements.count > 0 )
            XCTAssert(scanner.deviceList.count > 0)
        }
        
        
        
        
        self.wait(for: [expect], timeout: .infinity)
    }
    
    func testServices() {
        let macAddress = BLEMACAddress(addressString: "00:00:00:00:00:00", addressType: .random)
        let bleAdvertisement = BLEAdvertisment(macAddress: macAddress, receptionDate: Date() , services: [CBUUID(string: "07FE")], serviceData: nil, txPowerLevel: nil, deviceName: nil, manufacturerData: nil, rssi: -56)
        
        do {
            
            let exported =  PcapExport.export(advertisements: [bleAdvertisement])
            let importedAdvertisement = try PcapImport.from(data: exported).first!
            XCTAssertEqual(bleAdvertisement.serviceUUIDs, importedAdvertisement.serviceUUIDs)
            
        }catch {
            XCTFail()
        }
        
        
    }

}
