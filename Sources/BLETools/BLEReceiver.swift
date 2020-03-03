//
//  BLEReceiver.swift
//  BLE-Viewer
//
//  Created by Alexander Heinrich on 25.09.19.
//  Copyright © 2019 Alexander Heinrich. All rights reserved.
//

import Foundation
import CoreBluetooth
import os


/// Delegate used for forwarding Apple advertisements to
protocol BLEReceiverDelegate {
    
    
    /// Called when any advertisement has been received by the `BLEReceiver`
    /// - Parameters:
    ///   - advertisementData: Advertisement dictionary
    ///   - device: CoreBluetooth Peripheral device
    func didReceive(advertisementData: [String: Any], rssi: NSNumber, from device: CBPeripheral)
}


/// Class used to scan for BLE Advertisements and receiving them. Uses delegate to inform about advertisements sent by Apple devices
class BLEReceiver: NSObject {
    var centralManager: CBCentralManager!
    var delegate: BLEReceiverDelegate?
    
    private var shouldScanForAdvertisements = false
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    /// Start scanning for advertisements
    func scanForAdvertisements() {
        if self.centralManager.state == .poweredOn {
            self.centralManager.scanForPeripherals(withServices: nil, options: nil)
        }else {
            self.shouldScanForAdvertisements = true
        }
    }
    
    /// Stop scanning for advertisements
    func stopScanningForAdvertisements() {
        self.shouldScanForAdvertisements = false
        self.centralManager.stopScan()
    }
    
    
    /// Checks if the manufacturer data matches for an Apple advertisement
    /// - Parameter data: manufacturer data of the received device
    func isAppleAdvertisement(data: Data) -> Bool {
        guard data.count >= 3 else {return false}
        let isAppleData = data[data.startIndex] == 0x4c
        return isAppleData
    }
}


extension BLEReceiver: CBCentralManagerDelegate {
    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        print("CBCentralManager did Update state \(central.state)")
        if central.state == .poweredOn && self.shouldScanForAdvertisements {
            self.scanForAdvertisements()
            self.shouldScanForAdvertisements = false
        }
    }
    
    func centralManager(_ central: CBCentralManager, didDiscover peripheral: CBPeripheral, advertisementData: [String : Any], rssi RSSI: NSNumber) {

//        if let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
//            self.isAppleAdvertisement(data: manufacturerData)  {
//            self.delegate?.didReceive(appleAdvertisement: manufacturerData, fromDevice: peripheral)
//        }
        
        self.delegate?.didReceive(advertisementData: advertisementData, rssi: RSSI, from: peripheral)
    }
    
    
}
