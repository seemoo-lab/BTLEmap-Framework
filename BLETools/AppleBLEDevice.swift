//
//  AppleBLEDevice.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

public class AppleBLEDevice: Equatable {

    public internal(set) var name: String?
    public internal(set) var deviceType: String?
    private (set) var advertisements = [AppleBLEAdvertisment]()
    public internal(set) var peripheral: CBPeripheral
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
    }
    
    public static func == (lhs: AppleBLEDevice, rhs: AppleBLEDevice) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    func add(advertisement: AppleBLEAdvertisment) {
        self.advertisements.append(advertisement)
    }
}
