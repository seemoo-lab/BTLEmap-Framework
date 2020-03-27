//
//  BLEScanner.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine



public protocol BLEScannerDelegate {
    
    /// Scanner did discover a new device
    /// - Parameters:
    ///   - scanner: Current BLE Scanner
    ///   - device: Device that has been discovered
    func scanner(_ scanner: BLEScanner, didDiscoverNewDevice device: BLEDevice)
    
    /// Scanner did receive a new advertisement
    /// - Parameters: 
    ///   - scanner: Current BLE Scanner
    ///   - advertisement: Advertisement that has been received
    ///   - device: Device that sent the advertisement
    func scanner(_ scanner: BLEScanner, didReceiveNewAdvertisement advertisement: BLEAdvertisment, forDevice device: BLEDevice)
}

/// BLE Scanner can be used to discover BLE devices sending advertisements over one of the advertisement channels
public class BLEScanner: BLEReceiverDelegate, ObservableObject {
    var receiver: BLEReceiverProtocol!
    
    public var receiverType: Receiver = .coreBluetooth {
        didSet {
            if oldValue != receiverType {
                self.changeReceiver(to: receiverType)
            }
        }
    }
    
    @Published public var connectedToReceiver: Bool = true
    
    @Published public var devices = [String: BLEDevice]()
    @Published public var deviceList = Array<BLEDevice>()
    public var delegate: BLEScannerDelegate?
    
    /// If set to false no timeouts will happen
    public var devicesCanTimeout = true
    
    /// Devices time out after 5 minuites without an update. Therefore, they will disappear afterwards
    public var timeoutInterval: TimeInterval = 5.0 * 60.0
    
    /// Set to true to start scanning for advertisements
    @Published public var scanning: Bool = false {
        didSet {
            guard oldValue != scanning else {return}
            
            if scanning {
                self.scanForAppleAdvertisements()
            }else {
                self.receiver.stopScanningForAdvertisements()
            }
        }
    }
    
    
    /// If set to false much more advertisements will be received, this might block parts of the UI thread
    @Published public var filterDuplicates: Bool = true {
        didSet {
            guard self.scanning else {return}
            //Restart the scan with the new setting
            self.receiver.stopScanningForAdvertisements()
            self.receiver.scanForAdvertisements(filterDuplicates: self.filterDuplicates)
        }
    }
    
    public let newAdvertisementSubject = PassthroughSubject<BLE_Event,Never>()
    public let newDeviceSubject = PassthroughSubject<BLEDevice,Never>()
    
    public init(delegate: BLEScannerDelegate? = nil, devicesCanTimeout:Bool = false, timeoutInterval: TimeInterval = 5.0 * 60.0, filterDuplicates: Bool=false, receiverType: Receiver) {
        self.delegate = delegate
        self.receiverType = receiverType
        self.devicesCanTimeout = devicesCanTimeout
        self.timeoutInterval = timeoutInterval
        self.filterDuplicates = filterDuplicates
        self.changeReceiver(to: self.receiverType)
    }
    
    
    //MARK:- Implementation
    
    /// Start scanning for Apple advertisements
    func scanForAppleAdvertisements() {
        receiver.scanForAdvertisements(filterDuplicates: self.filterDuplicates)
    }
    
    
    /// Switch the BLE Receiver
    /// - Parameter receiver: the selected receiver type
    func changeReceiver(to receiver: Receiver) {
        //Remove old receiver's delegate
        self.receiver.delegate = nil
        self.receiver.stopScanningForAdvertisements()
        self.connectedToReceiver = false
        
        switch receiver {
        case .coreBluetooth:
            self.receiver = BLEReceiver()
            self.connectedToReceiver = true
        case .external:
            let relayReceiver = BLERelayReceiver()
            self.receiver = relayReceiver
        }
        
        self.receiver.delegate = self
        if self.scanning {
            self.receiver.scanForAdvertisements(filterDuplicates: filterDuplicates)
        }
        
        self.devices.removeAll()
        self.deviceList.removeAll()
    }
    
    //MARK:- BLE Receiver Delegate
    
    func didStartScanning() {
        self.connectedToReceiver = true
        self.scanning = true
    }
    
    func didReceive(advertisementData: [String : Any], rssi: NSNumber, from device: CBPeripheral) {
        do {
            
            if let bleDevice = devices[device.identifier.uuidString] {
                let advertisement = try BLEAdvertisment(advertisementData: advertisementData, rssi: rssi)
                bleDevice.add(advertisement: advertisement)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
                if let recv = self.receiver as? BLEReceiver, bleDevice.deviceType == nil {
                    recv.detectDeviceType(for: bleDevice)
                }
                self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
                
            }else {
                //Add a new device
                let advertisement = try BLEAdvertisment(advertisementData: advertisementData, rssi: rssi)
                let bleDevice = BLEDevice(peripheral: device, and: advertisement)
                self.devices[device.identifier.uuidString] = bleDevice
                delegate?.scanner(self, didDiscoverNewDevice: bleDevice)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
                self.deviceList = Array(devices.values)
                if let recv = self.receiver as? BLEReceiver {
                    recv.detectDeviceType(for: bleDevice)
                }
                self.newDeviceSubject.send(bleDevice)
                self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
            }
        }catch {
            return
        }
        
        if self.devicesCanTimeout {
            checkForTimeouts()
        }
    }
    
    func didReceive(advertisement: BLEAdvertisment) {
        guard let macAddress = advertisement.macAddress?.addressString else {
            Log.error(system: .BLERelay, message: "Received corrupted advertisement without mac address")
            return
        }
        
        
        if let bleDevice = devices[macAddress] {
            bleDevice.add(advertisement: advertisement)
            delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
            self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
        }else {
            do {
                //Add new device
                let bleDevice = try BLEDevice(with: advertisement)
                self.devices[macAddress] = bleDevice
                delegate?.scanner(self, didDiscoverNewDevice: bleDevice)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
                self.deviceList = Array(devices.values)
                self.newDeviceSubject.send(bleDevice)
                self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
            }catch {
                Log.error(system: .ble, message: "Failed setting up device %@", String(describing: error))
            }
        }
    }
    
    func didUpdateModelNumber(_ modelNumber: String, for peripheral: CBPeripheral) {
        guard let device = self.devices[peripheral.identifier.uuidString] else {return}
        device.modelNumber = modelNumber
    }
    
    func didUpdateServices(services: [CBService], for peripheral: CBPeripheral) {
        guard let device = self.devices[peripheral.identifier.uuidString] else {return}
        device.services = services.map{BLEService(with: $0)}
    }
    
    func checkForTimeouts() {
        let timedOutDevices = self.deviceList.filter {$0.lastUpdate.timeIntervalSinceNow < -self.timeoutInterval}
        timedOutDevices.forEach { (d) in
            self.devices[d.uuid.uuidString] = nil
        }
        self.deviceList = Array(self.devices.values)
    }
    
    //MARK: - Structs
    
    public struct BLE_Event {
        public let advertisement: BLEAdvertisment
        public let device: BLEDevice
    }
    
    public enum Receiver: Int, CaseIterable {
        case coreBluetooth = 0
        case external = 1
        
        public var name: String {
            switch self {
            case .coreBluetooth:
                return "CoreBluetooth"
            case .external:
                return "External - Raspberry Pi"
            }
        }
    }
}
