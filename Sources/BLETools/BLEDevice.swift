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

public class BLEDevice: NSObject, Identifiable, ObservableObject {
    public var id: String
    public internal(set) var name: String?
    @Published public private (set) var advertisements = [BLEAdvertisment]()
    public internal(set) var peripheral: CBPeripheral
    
    public var uuid: UUID {return peripheral.identifier}
    
    public private(set) var manufacturer: BLEManufacturer
    
    /// Device type can be retrieved from device information or advertisement data
    @Published public internal(set) var deviceType: DeviceType?
    /// Model number string received from device information service
    @Published public internal(set) var modelNumber: String? {
        // Set the device type to the according model number
        didSet {
            guard let modelNumber = self.modelNumber else {return}
            
            switch modelNumber {
            case let s where s.lowercased().contains("macbook"):
                self.deviceType = .macBook
                
            case let s where s.lowercased().contains("imac"):
                self.deviceType = .iMac
                
            case let s where s.lowercased().contains("iphone"):
                self.deviceType = .iPhone
                
            case let s where s.lowercased().contains("ipad"):
                self.deviceType = .iPad
                
            case let s where s.lowercased().contains("ipod"):
                self.deviceType = .iPod
            
            case let s where s.lowercased().contains("airpods"):
                self.deviceType = .AirPods
                
            case let s where s.lowercased().contains("watch"):
                self.deviceType = .AppleWatch
                
            default:
                self.deviceType = .other
            }
        }
    }
    
    
    public var lastRSSI: NSNumber {
        return self.advertisements.first?.rssi.last ?? NSNumber(value: -100)
    }
    
    public var connectable: Bool {
        return self.advertisements.last(where: {$0.connectable}) != nil
    }
    
    public private(set) var lastUpdate: Date = Date()
    
    init(peripheral: CBPeripheral, and advertisement: BLEAdvertisment) {
        
        self.peripheral = peripheral
        self.name = peripheral.name
        self.id = peripheral.identifier.uuidString
        self.manufacturer = advertisement.manufacturer
        super.init()
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
        
        self.lastUpdate = advertisement.receptionDates.last!
    }

    
    public override var debugDescription: String {
        return(
        """
        \(self.uuid.uuidString)
        \t \(String(describing: self.name))
        \t \(self.advertisements.count) advertisements
        """)
    }
    
//    public override func hash(into hasher: inout Hasher) {
//        return hasher.combine(id)
//    }

    public enum DeviceType {
        case iPhone
        case macBook
        case iMac
        case iPad
        case iPod
        case AirPods
        case Pencil
        case AppleWatch
        case appleEmbedded
        case other
    }
}

extension BLEDevice: CBPeripheralDelegate {
    
}
