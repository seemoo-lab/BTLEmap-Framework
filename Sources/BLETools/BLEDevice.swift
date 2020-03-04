//
//  AppleBLEDevice.swift
//  BLETools
//
//  Created by Alex - SEEMOO on 17.02.20.
//  Copyright © 2020 SEEMOO - TU Darmstadt. All rights reserved.
//

import Foundation
import CoreBluetooth
import Combine

public class BLEDevice: Equatable, CustomDebugStringConvertible, Hashable, Identifiable, ObservableObject {
    public var id: String
    public internal(set) var name: String?
    @Published public internal(set) var deviceType: String?
    @Published public private (set) var advertisements = [BLEAdvertisment]()
    public internal(set) var peripheral: CBPeripheral
    
    public var uuid: UUID {return peripheral.identifier}
    
    public private(set) var manufacturer: BLEManufacturer
    
    public var lastRSSI: NSNumber {
        return self.advertisements.first?.rssi.last ?? NSNumber(value: -100)
    }
    
    init(peripheral: CBPeripheral, and advertisement: BLEAdvertisment) {
        self.peripheral = peripheral
        self.name = peripheral.name
        self.id = peripheral.identifier.uuidString
        self.manufacturer = advertisement.manufacturer
        self.advertisements.append(advertisement)
    }
    
    public static func == (lhs: BLEDevice, rhs: BLEDevice) -> Bool {
        lhs.peripheral.identifier == rhs.peripheral.identifier
    }
    
    /// Add a received advertisement to the device
    /// - Parameter advertisement: received BLE advertisement
    func add(advertisement: BLEAdvertisment) {
        // Check if that advertisement has been received before
        if let matching = self.advertisements.first(where: {$0.manufacturerData == advertisement.manufacturerData}) {
            matching.update(with: advertisement)
        }else {
            self.advertisements.append(advertisement)
        }
    }
    
    public var debugDescription: String {
        return(
        """
        \(self.uuid.uuidString)
        \t \(String(describing: self.name))
        \t \(self.advertisements.count) advertisements
        """)
    }
    
    public func hash(into hasher: inout Hasher) {
        return hasher.combine(id)
    }
}
