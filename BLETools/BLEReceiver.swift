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
    
    /// Called if the `BLEReceiver` has received an advertisement sent by an Apple device
    /// - Parameters:
    ///   - appleAdvertisement: manufacturer data of the advertisement
    ///   - device: CBPeripheral device that has sent it
    func didReceive(appleAdvertisement: Data, fromDevice device: CBPeripheral)
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

        guard let manufacturerData = advertisementData[CBAdvertisementDataManufacturerDataKey] as? Data,
            self.isAppleAdvertisement(data: manufacturerData) else { return }
        
        self.delegate?.didReceive(appleAdvertisement: manufacturerData, fromDevice: peripheral)
    }
    
    
}
