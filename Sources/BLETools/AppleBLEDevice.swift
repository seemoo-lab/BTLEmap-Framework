//
//  AppleBLEDevice.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth

public class AppleBLEDevice: Equatable, CustomDebugStringConvertible, Identifiable {
    public var id: String
    public internal(set) var name: String?
    public internal(set) var deviceType: String?
    private (set) var advertisements = [AppleBLEAdvertisment]()
    public internal(set) var peripheral: CBPeripheral
    
    public var uuid: UUID {return peripheral.identifier}
    
    
    init(peripheral: CBPeripheral) {
        self.peripheral = peripheral
        self.name = peripheral.name
        self.id = peripheral.identifier.uuidString
    }
    
    public static func == (lhs: AppleBLEDevice, rhs: AppleBLEDevice) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    func add(advertisement: AppleBLEAdvertisment) {
        self.advertisements.append(advertisement)
    }
    
    public var debugDescription: String {
        return(
        """
        \(self.uuid.uuidString)
        \t \(String(describing: self.name))
        \t \(self.advertisements.count) advertisements
        """)
    }
}
