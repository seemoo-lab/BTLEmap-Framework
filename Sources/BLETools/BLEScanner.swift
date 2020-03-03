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
public class BLEScanner: BLEReceiverDelegate {
    let receiver = BLEReceiver()
    public var devices = [UUID: BLEDevice]()
    public var deviceList = Array<BLEDevice>()
    public var delegate: BLEScannerDelegate?
    
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
    
    func didReceive(advertisementData: [String : Any], rssi: NSNumber, from device: CBPeripheral) {
        do {
            
            if let bleDevice = devices[device.identifier] {
                let advertisement = try BLEAdvertisment(advertisementData: advertisementData, rssi: rssi)
                bleDevice.add(advertisement: advertisement)
                delegate?.scanner(self, didReceiveNewAdvertisement: advertisement, forDevice: bleDevice)
            }else {
                //Add a new device
                let advertisement = try BLEAdvertisment(advertisementData: advertisementData, rssi: rssi)
                let bleDevice = BLEDevice(peripheral: device, and: advertisement)
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
