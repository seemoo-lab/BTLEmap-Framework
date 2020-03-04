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
    
    /// Did update the model number string for a peripheral
    /// - Parameters:
    ///   - modelNumber: The model number that has been received
    ///   - peripheral: The peripheral to which the model number belongs
    func didUpdateModelNumber(_ modelNumber: String, for peripheral: CBPeripheral)
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

        self.delegate?.didReceive(advertisementData: advertisementData, rssi: RSSI, from: peripheral)
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Connected to peripheral
        // Request device infos
        
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
}

extension BLEReceiver: CBPeripheralDelegate {
    func detectDeviceType(for device: BLEDevice) {
        //Set to other initially to prevent from multiple calls
        device.deviceType = .other
        
        let isAppleEmbedded = device.advertisements.contains(where: {$0.advertisementTypes.contains(.airpodsOrPencil)})
        
        guard !isAppleEmbedded else {
            device.deviceType = .appleEmbedded
            return
        }
        
        //Make GATT connection
        
        device.peripheral.delegate = self
        guard device.connectable else {return}
        
        self.centralManager.connect(device.peripheral, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print(peripheral.services ?? "None")
        
        guard let services = peripheral.services,
            let deviceInfoService = services.first(where: {$0.uuid == CBServiceUUIDs.deviceInformation.uuid}) else {return}
        
        peripheral.discoverCharacteristics(nil, for: deviceInfoService)
    }
    
    func peripheralDidUpdateName(_ peripheral: CBPeripheral) {
        //Name changed!
        print("Peripheral did update name to: \(String(describing: peripheral.name))")
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverCharacteristicsFor service: CBService, error: Error?) {
        
        guard service.uuid == CBServiceUUIDs.deviceInformation.uuid,
            let characteristics = service.characteristics,
            let modelNumberCharacteristic = characteristics.first(where: {$0.uuid == CBCharacteristicsUUIDs.modelNumber.uuid})  else {return}
        
        //Read model name
        print(characteristics)
        
        peripheral.readValue(for: modelNumberCharacteristic)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Updated the value for model number
        guard characteristic.uuid == CBCharacteristicsUUIDs.modelNumber.uuid,
            let modelNumber = characteristic.value?.stringUTF8 else {return}
        
        self.delegate?.didUpdateModelNumber(modelNumber, for: peripheral)
    }
}


enum CBServiceUUIDs {
    case deviceInformation
    
    var uuid: CBUUID {
        switch self {
        case .deviceInformation: return CBUUID(data: Data([0x18, 0x0A]))
        }
    }
}

enum CBCharacteristicsUUIDs {
    case modelNumber
    
    var uuid: CBUUID {
        switch self {
        case .modelNumber: return CBUUID(data: Data([0x2A,0x24]))
        }
    }
}
