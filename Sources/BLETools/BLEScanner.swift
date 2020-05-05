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
    /// The receiver that is used to scan for BLE advertisements
    var receiver: BLEReceiverProtocol! = BLEReceiver()
    public var delegate: BLEScannerDelegate?
    

    //MARK: State
    @Published public var connectedToReceiver: Bool = true
    @Published public var devices = [String: BLEDevice]()
    @Published public var deviceList = Array<BLEDevice>()
    @Published public var advertisements = Array<BLEAdvertisment>()
    
    @Published public var lastError: Error?
    
    @Published public var scanStartTime: Date = Date()
    
    //MARK: Settings
    
    /// Multiple receivers are supported. This type defines which one should be used
    public var receiverType: Receiver = .coreBluetooth {
        didSet {
            if oldValue != receiverType {
                self.changeReceiver(to: receiverType)
            }
        }
    }
    
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
                self.stopScanning()
            }
        }
    }
    
    /// Automatically connect to all discovered devices. Used to request services
    @Published public var autoconnect: Bool {
        didSet {
            self.receiver.autoconnectToDevices = autoconnect
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
    
    //MARK: Subjects
    
    public let newAdvertisementSubject = PassthroughSubject<BLE_Event,Never>()
    public let newDeviceSubject = PassthroughSubject<BLEDevice,Never>()
    
    
    //MARK:- Public
    
    public init(delegate: BLEScannerDelegate? = nil, devicesCanTimeout:Bool = false, timeoutInterval: TimeInterval = 5.0 * 60.0, filterDuplicates: Bool=false, receiverType: Receiver = .coreBluetooth, autoconnect: Bool = true) {
        self.delegate = delegate
        self.receiverType = receiverType
        self.devicesCanTimeout = devicesCanTimeout
        self.timeoutInterval = timeoutInterval
        self.filterDuplicates = filterDuplicates
        self.autoconnect = autoconnect
        self.changeReceiver(to: self.receiverType)
    }
    
    /// Clear all devices and advertisements received
    public func clear() {
        self.devices = [:]
        self.deviceList = []
        self.advertisements = []
    }
    
    
    //MARK:- Implementation
    
    /// Start scanning for Apple advertisements
    func scanForAppleAdvertisements() {
        //Clear all state variables
        self.clear()
        self.scanStartTime = Date()
        //Start scanning
        receiver.autoconnectToDevices = self.autoconnect
        receiver.scanForAdvertisements(filterDuplicates: self.filterDuplicates)
    }
    
    func stopScanning() {
        self.receiver.stopScanningForAdvertisements()
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
    
    func updateDeviceList() {
        self.deviceList = Array(self.devices.values).sorted(by: {$0.id < $1.id})
    }
    
    //MARK:- BLE Receiver Delegate
    
    func didStartScanning() {
        self.connectedToReceiver = true
        self.scanning = true
    }
    
    func didReceive(advertisementData: [String : Any], rssi: NSNumber, from device: CBPeripheral) {
        
        let receptionDate = Date()
        let advertisement = BLEAdvertisment(advertisementData: advertisementData, rssi: rssi)
        self.advertisements.append(advertisement)
        
        if let bleDevice = devices[device.identifier.uuidString] {
            //Add advertisement to device
            bleDevice.add(advertisement: advertisement, time: receptionDate.timeIntervalSince(self.scanStartTime))
            delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
            if let recv = self.receiver as? BLEReceiver, bleDevice.deviceModel == nil {
                recv.detectDeviceType(for: bleDevice)
            }
            self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
            
        }else {
            //Add a new device
            let bleDevice = BLEDevice(peripheral: device, and: advertisement, at: receptionDate.timeIntervalSince(self.scanStartTime))
            
            self.devices[device.identifier.uuidString] = bleDevice
            delegate?.scanner(self, didDiscoverNewDevice: bleDevice)
            delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
            
            
            if let recv = self.receiver as? BLEReceiver {
                recv.detectDeviceType(for: bleDevice)
            }
            self.newDeviceSubject.send(bleDevice)
            self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
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
        
        let receptionDate = advertisement.receptionDates.first!
        self.advertisements.append(advertisement)
        
        if let bleDevice = devices[macAddress] {
            // Add advertisement to device 
            bleDevice.add(advertisement: advertisement, time: receptionDate.timeIntervalSince(self.scanStartTime))
            delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
            self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
        }else {
            do {
                //Add new device
                let bleDevice = try BLEDevice(with: advertisement, at: receptionDate.timeIntervalSince(self.scanStartTime))
                self.devices[macAddress] = bleDevice
                delegate?.scanner(self, didDiscoverNewDevice: bleDevice)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
                self.updateDeviceList()
                self.newDeviceSubject.send(bleDevice)
                self.newAdvertisementSubject.send(BLE_Event(advertisement: advertisement, device: bleDevice))
            }catch {
                Log.error(system: .ble, message: "Failed setting up device %@", String(describing: error))
            }
        }
        
        if self.devicesCanTimeout {
            checkForTimeouts()
        }
    }
    
    func didUpdateServices(services: [BLEService], forDevice id: String) {
        guard let device = self.devices[id] else {return}
        device.addServices(services: services)
    }
    
    func didUpdateCharacteristics(characteristics: [BLECharacteristic],forService service: BLEService, andDevice id: String) {
        guard let device = self.devices[id], var service = device.services.first(where: {$0.uuid == service.uuid}) else {return}
        
        //Get characteristics for service
        let allChars = Set(characteristics).union(service.characteristics)
        service.characteristics = allChars
        
        device.updateService(service: service)
    }
    
    func didFail(with error: Error) {
        //TODO: Forward error
        Log.error(system: .ble, message: "Error occurred %@", String(describing: error))
        self.lastError = error
    }
    
    
    func didUpdateModelNumber(_ modelNumber: String, for peripheral: CBPeripheral) {
        guard let device = self.devices[peripheral.identifier.uuidString] else {return}
        device.deviceModel = BLEDeviceModel(modelNumber)
    }
    
    
    func checkForTimeouts() {
        let timedOutDevices = self.deviceList.filter {$0.lastUpdate.timeIntervalSinceNow < -self.timeoutInterval}
        timedOutDevices.forEach { (d) in
            self.devices[d.uuid.uuidString] = nil
        }
        self.updateDeviceList()
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
