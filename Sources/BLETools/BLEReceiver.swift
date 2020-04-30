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
    func didUpdateCharacteristics(characteristics: [BLECharacteristic], forService service: BLEService, andDevice id: String)
    
    /// Reports errors that occurred to the delegate
    /// - Parameter error: An error that occured. Might be during connections, scanning, etc
    func didFail(with error: Error)
    
}


protocol BLEReceiverProtocol {
    func scanForAdvertisements(filterDuplicates: Bool)
    func stopScanningForAdvertisements()
    
    var delegate: BLEReceiverDelegate? { get set }
    
    /// Defines if the Receiver should automatically connect to devices to get more information
    var autoconnectToDevices: Bool {get set}
}

/// Class used to scan for BLE Advertisements and receiving them. Uses delegate to inform about advertisements sent by Apple devices
class BLEReceiver: NSObject, BLEReceiverProtocol {
    var centralManager: CBCentralManager!
    var delegate: BLEReceiverDelegate?
    var autoconnectToDevices: Bool = true
    private var isScanning = false
    
    private var shouldScanForAdvertisements = false
    private var filterDuplicates = true
    
    private var connectedPeripherals = [CBPeripheral]()
    
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
        Log.default(system: .ble, message: "Advertisement data %@", String(describing: advertisementData))
    }
    
    func centralManager(_ central: CBCentralManager, didConnect peripheral: CBPeripheral) {
        //Connected to peripheral
        // Request device infos
        
        Log.default(system: .ble, message: "Connected to %@", String(describing: peripheral))
        peripheral.delegate = self
        peripheral.discoverServices(nil)
    }
    
    func centralManager(_ central: CBCentralManager, didFailToConnect peripheral: CBPeripheral, error: Error?) {
        Log.error(system: .ble, message: "Failed to connect to %@ with error :\n %@", String(describing: peripheral), String(describing: error))
    }
    
    func centralManager(_ central: CBCentralManager, didDisconnectPeripheral peripheral: CBPeripheral, error: Error?) {
        Log.debug(system: .ble, message: "Did disconnect from peripheral %@", String(describing: peripheral))
        if let error = error {
            Log.error(system: .ble, message: "Disconnecting error \n %@", String(describing: error))
        }
    }
    
}

extension BLEReceiver: CBPeripheralDelegate {
    func detectDeviceType(for device: BLEDevice) {
        guard let peripheral = device.peripheral else {return}

        
        
        // Embedded Apple devices don't offer GATT by default.
        // We can detect the device type from their advertisements
        if let advertisement = device.advertisements.first(where: {$0.advertisementTypes.contains(.proximityPairing)}),
            let advData = advertisement.advertisementTLV?.getValue(forType: BLEAdvertisment.AppleAdvertisementType.proximityPairing.rawValue),
        advData.count >= 1 {
            let deviceTypeByte = advData[advData.startIndex]
            
            if deviceTypeByte == 0x01 {
                //AirPods
                device.deviceModel = BLEDeviceModel("AirPods")
            }else if deviceTypeByte == 0x03 {
                device.deviceModel = BLEDeviceModel("Apple Pencil 2")
            }
            
            return
        }
        
        
        guard device.connectable && !self.connectedPeripherals.contains(peripheral) else {
            return
        }
        
        //Make GATT connection
        peripheral.delegate = self
        if autoconnectToDevices {
            self.centralManager.connect(peripheral, options: nil)
            self.connectedPeripherals.append(peripheral)
        }
    }
    

    
    func peripheral(_ peripheral: CBPeripheral, didDiscoverServices error: Error?) {
        
        print(peripheral.services?.map{$0.uuid} ?? "None")
        
        guard let services = peripheral.services else {return}
        
        self.delegate?.didUpdateServices(services: services.map{BLEService(with: $0)}, forDevice: peripheral.identifier.uuidString)
        
        Log.default(system: .ble, message: "Did discover services for %@\n %@", String(describing: peripheral), services)
        
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
            let characteristics = service.characteristics else {return}
        
        Log.default(system: .ble, message: "Did discover characteristics for %@\n in service: %@ \n %@", String(describing: peripheral), service, characteristics)
        
        //Read model name
        print(characteristics)
        characteristics.forEach { (c) in
            peripheral.readValue(for: c)
        }
        
    }
    
    func peripheral(_ peripheral: CBPeripheral, didUpdateValueFor characteristic: CBCharacteristic, error: Error?) {
        // Updated the value for model number
//        guard characteristic.uuid == CBCharacteristicsUUIDs.modelNumber.uuid,
//            let modelNumber = characteristic.value?.stringUTF8 else {return}
        if let error = error {
            //Error occurred
            Log.error(system: .ble, message: "Failed updating characteristic \n%@", String(describing: error))
            return
        }
        
        self.delegate?.didUpdateCharacteristics(characteristics: [BLECharacteristic(with: characteristic)],forService: BLEService(with: characteristic.service), andDevice: peripheral.identifier.uuidString)
    }

}


public enum CBServiceUUIDs {
    case deviceInformation
    
    public var uuid: CBUUID {
        switch self {
        case .deviceInformation: return CBUUID(data: Data([0x18, 0x0A]))
        }
    }
}

public enum CBCharacteristicsUUIDs {
    case modelNumber
    case deviceName
    case batteryLevel
    case appearance
    case serialNumberString
    case hardwareRevisionString
    
    public var uuid: CBUUID {
        switch self {
        case .modelNumber: return CBUUID(data: Data([0x2A,0x24]))
        case .deviceName: return CBUUID(data: "00002a0000001000800000805f9b34fb".hexadecimal!)
        case .batteryLevel: return CBUUID(data: "00002a1900001000800000805f9b34fb".hexadecimal!)
        case .appearance: return CBUUID(data: "00002a0100001000800000805f9b34fb".hexadecimal!)
        case .serialNumberString: return CBUUID(data: "00002a2500001000800000805f9b34fb".hexadecimal!)
        case .hardwareRevisionString: return CBUUID(data: "00002a2700001000800000805f9b34fb".hexadecimal!)
        }
    }
}
