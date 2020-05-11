//
//  PcapExportTests.swift
//  BLEToolsTests
//
//  Created by Alex - SEEMOO on 11.05.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import XCTest
@testable import BLETools

class PcapExportTests: XCTestCase {

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

}
