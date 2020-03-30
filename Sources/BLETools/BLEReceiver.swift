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
    
    /// Called when the service connected and started scanning
    func didStartScanning()
    
    /// Called when the advertisement has been received over a relayed service
    /// - Parameter advertisement:An advertisement that has been received over relay
    func didReceive(advertisement: BLEAdvertisment)
    
    /// Called when any advertisement has been received by the `BLEReceiver`
    /// - Parameters:
    ///   - advertisementData: Advertisement dictionary
    ///   - device: CoreBluetooth Peripheral device
    func didReceive(advertisementData: [String: Any], rssi: NSNumber, from device: CBPeripheral)
    
    
    /// The services for a device have been updated
    /// - Parameters:
    ///   - services: Array of services
    ///   - id: Device id (UUID for CBPeripheral, MAC address for external receivers)
    func didUpdateServices(services: [BLEService], forDevice id: String)
    
    /// Updated characteristics for service and device
    /// - Parameters:
    ///   - characteristics: Array of characteristics available for this service
    ///   - id: Device id (UUID for CBPeripheral, MAC address for external receivers)
    func didUpdateCharacteristics(characteristics: [BLECharacteristic], andDevice id: String)
}


protocol BLEReceiverProtocol {
    func scanForAdvertisements(filterDuplicates: Bool)
    func stopScanningForAdvertisements()
    
    var delegate: BLEReceiverDelegate? { get set }
}

/// Class used to scan for BLE Advertisements and receiving them. Uses delegate to inform about advertisements sent by Apple devices
class BLEReceiver: NSObject, BLEReceiverProtocol {
    var centralManager: CBCentralManager!
    var delegate: BLEReceiverDelegate?
    private var isScanning = false
    
    private var shouldScanForAdvertisements = false
    private var filterDuplicates = true
    
    override init() {
        super.init()
        self.centralManager = CBCentralManager(delegate: self, queue: nil)
    }
    
    
    /// Start scanning for advertisements
    func scanForAdvertisements(filterDuplicates: Bool) {
        self.filterDuplicates = filterDuplicates
        
        if self.centralManager.state == .poweredOn {
            var scanOptions = [String: Any]()
//            #if os(iOS)
//            scanOptions["CBCentralManagerScanOptionIsPrivilegedDaemonKey"] = NSNumber(booleanLiteral: true)
//            scanOptions["kCBScanOptionIsPrivilegedDaemon"] = NSNumber(booleanLiteral: true)
//            scanOptions["kCBMsgArgIsPrivilegedDaemon"] = NSNumber(booleanLiteral: true)
//            #endif
            if !filterDuplicates {
                scanOptions[CBCentralManagerScanOptionAllowDuplicatesKey] = NSNumber(booleanLiteral: true)
                
            }
            self.centralManager.scanForPeripherals(withServices: nil, options: scanOptions)
            self.isScanning = true
            self.delegate?.didStartScanning()
        }else {
            self.shouldScanForAdvertisements = true
        }
    }
    
    /// Stop scanning for advertisements
    func stopScanningForAdvertisements() {
        self.shouldScanForAdvertisements = false
        self.centralManager.stopScan()
        self.isScanning = false
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
        print("CBCentralManager did Update state \(central.state.description)")
        if central.state == .poweredOn && self.shouldScanForAdvertisements {
            self.scanForAdvertisements(filterDuplicates: self.filterDuplicates)
            self.shouldScanForAdvertisements = false
        }
        
        if central.state == .poweredOff {
            guard self.isScanning else {return}
            self.stopScanningForAdvertisements()
            self.shouldScanForAdvertisements = true
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
        guard let peripheral = device.peripheral else {return}
        
        //Set to other initially to prevent from multiple calls
        device.deviceType = .other
        
        
        //Make GATT connection
        peripheral.delegate = self
        
        // Embedded Apple devices don't offer GATT by default.
        // We can detect the device type from their advertisements
        if let advertisement = device.advertisements.first(where: {$0.advertisementTypes.contains(.proximityPairing)}),
            let advData = advertisement.advertisementTLV?.getValue(forType: BLEAdvertisment.AppleAdvertisementType.proximityPairing.rawValue),
        advData.count >= 1 {
            let deviceTypeByte = advData[advData.startIndex]
            
            if deviceTypeByte == 0x01 {
                //AirPods
                device.deviceType = .AirPods
            }else if deviceTypeByte == 0x03 {
                device.deviceType = .Pencil
            }
            
            return
        }
        
        guard device.connectable else {
            return
        }
        
        self.centralManager.connect(peripheral, options: nil)
    }
    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print(peripheral.services?.map{$0.uuid} ?? "None")
        
        guard let services = peripheral.services else {return}
        
        self.delegate?.didUpdateServices(services: services.map{BLEService(with: $0)}, forDevice: peripheral.identifier.uuidString)
        
        for s in services {
            peripheral.discoverCharacteristics(nil, for: s)
        }
            
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
//        guard characteristic.uuid == CBCharacteristicsUUIDs.modelNumber.uuid,
//            let modelNumber = characteristic.value?.stringUTF8 else {return}
        
        self.delegate?.didUpdateCharacteristics(characteristics: [BLECharacteristic(with: characteristic)], andDevice: peripheral.identifier.uuidString)
        
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
