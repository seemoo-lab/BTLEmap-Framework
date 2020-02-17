//
//  BLEScanner.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

class BLEScanner: BLEReceiverDelegate {
    let receiver = BLEReceiver()
    var devices = [AppleBLEDevice]()
    
    init() {
        receiver.delegate = self
    }
    
    
    /// Start scanning for Apple advertisements
    func scanForAppleAdvertisements() {
        receiver.scanForAdvertisements()
    }
    
    func didReceive(appleAdvertisement: Data, fromDevice device: CBPeripheral) {
        let advertisement = AppleBLEAdvertisment(manufacturerData: appleAdvertisement)
        
        if let i = devices.firstIndex(of: AppleBLEDevice(peripheral: device)) {
            let d = devices[i]
            d.add(advertisement: advertisement)
        }else {
            //Add a new device
            let bleDevice = AppleBLEDevice(peripheral: device)
            bleDevice.add(advertisement: advertisement)
            self.devices.append(bleDevice)
        }
    }
}
