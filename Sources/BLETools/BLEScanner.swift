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
    func scanner(_ scanner: BLEScanner, didDiscoverNewDevice device: AppleBLEDevice)
    
    /// Scanner did receive a new advertisement
    /// - Parameters:
    ///   - scanner: Current BLE Scanner
    ///   - advertisement: Advertisement that has been received
    ///   - device: Device that sent the advertisement
    func scanner(_ scanner: BLEScanner, didReceiveNewAdvertisement advertisement: AppleBLEAdvertisment, forDevice device: AppleBLEDevice)
}

/// BLE Scanner can be used to discover BLE devices sending advertisements over one of the advertisement channels
public class BLEScanner: BLEReceiverDelegate {
    let receiver = BLEReceiver()
    public var devices = [UUID: AppleBLEDevice]()
    public var deviceList = Array<AppleBLEDevice>()
    public let delegate: BLEScannerDelegate?
    
    /// Set to true to start scanning for advertisements
    public var scanning: Bool = false {
        didSet {
            guard oldValue != scanning else {return}
            
            if scanning {
                self.scanForAppleAdvertisements()
            }else {
                self.receiver.stopScanningForAdvertisements()
            }
        }
    }
    
    public init(delegate: BLEScannerDelegate? = nil) {
        self.delegate = delegate
        receiver.delegate = self
    }
    
    
    /// Start scanning for Apple advertisements
    func scanForAppleAdvertisements() {
        receiver.scanForAdvertisements()
    }
    
    func didReceive(appleAdvertisement: Data, fromDevice device: CBPeripheral) {
        do {
            let advertisement = try AppleBLEAdvertisment(manufacturerData: appleAdvertisement)
            
            if devices[device.identifier] != nil {
                devices[device.identifier]?.add(advertisement: advertisement)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: devices[device.identifier]!)
                if let name = device.name {
                    devices[device.identifier]?.name = name 
                }
            }else {
                //Add a new device
                var bleDevice = AppleBLEDevice(peripheral: device)
                bleDevice.add(advertisement: advertisement)
                self.devices[device.identifier] = bleDevice
                delegate?.scanner(self, didDiscoverNewDevice: bleDevice)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
                self.deviceList = Array(devices.values)
            }
        }catch {
            return
        }
    }
    
}
