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
import Apple_BLE_Decoder

public class BLEDevice: NSObject, Identifiable, ObservableObject {
    public var id: String
    private var _name: String?
    public internal(set) var name: String? {
        get {
            if let n = _name {
                return n
            }
            
            return self.peripheral.name
        }
        set(v) {
            self._name = v
        }
    }
    @Published public private (set) var advertisements = [BLEAdvertisment]()
    public internal(set) var peripheral: CBPeripheral
    
    /// The UUID of the peripheral
    public var uuid: UUID {return peripheral.identifier}
    
    /// The manufacturer of this device. Mostly taken from advertisement
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
            
            if self.deviceType != .other && self.manufacturer == .unknown {
                self.manufacturer = .apple
            }
        }
    }
    
    
    /// Last RSSI value that has been received
    public var lastRSSI: NSNumber {
        return self.advertisements.first?.rssi.last ?? NSNumber(value: -100)
    }
    
    /// True if the device marks itself as connectable
    public var connectable: Bool {
        return self.advertisements.last(where: {$0.connectable}) != nil
    }
    
    /// The last time when this device has sent an advertisement
    public private(set) var lastUpdate: Date = Date()
    
    /// Subject to which can be subscribed to receive every new advertisement individually after it has been added to the device.
    public let newAdvertisementSubject = PassthroughSubject<BLEAdvertisment, Never>()
    
    /// If available the current os version will be set. Is a string like: iOS 13 or macOS
    @Published public private(set) var osVersion: String?
    
    /// If available the state of the wifi setting will be set
    @Published public private(set) var wiFiOn: Bool?
    
    init(peripheral: CBPeripheral, and advertisement: BLEAdvertisment) {
        
        self.peripheral = peripheral
        self._name = peripheral.name
        self.id = peripheral.identifier.uuidString
        self.manufacturer = advertisement.manufacturer
        super.init()
        self.advertisements.append(advertisement)
        self.detectOSVersion(from: advertisement)
        
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
        
        self.detectOSVersion(from: advertisement)
    }
    
    private func detectOSVersion(from advertisement: BLEAdvertisment) {
        let nearbyInt = BLEAdvertisment.AppleAdvertisementType.nearby.rawValue
        if let nearby = advertisement.advertisementTLV?.getValue(forType: nearbyInt),
            let description = try? AppleBLEDecoding.decoder(forType: UInt8(nearbyInt)).decode(nearby),
            let wifiState = description["wiFiState"] as? AppleBLEDecoding.NearbyDecoder.DeviceFlags {
            
            switch wifiState {
            case .iOS10:
                self.osVersion = "iOS 10"
            case .iOS11:
                self.osVersion = "iOS 11"
            case .iOS12OrIPadOS13WiFiOn:
                self.osVersion = "iOS 12 / iPadOS 13"
                self.wiFiOn = true
            case .iOS12WiFiOn:
                self.osVersion = "iOS 12"
                self.wiFiOn = true
            case .iOS12WiFiOff:
                self.osVersion = "iOS 12"
                self.wiFiOn = false
            case .iOS12OrMacOSWifiOn:
                self.osVersion = "iOS 12 / macOS"
                self.wiFiOn = true
            case .iOS13WiFiOn:
                self.osVersion = "iOS 13"
                self.wiFiOn = true
            case .iOS13WiFiOff:
                self.osVersion = "iOS 13"
                self.wiFiOn = false
            case .iOS13WifiOn2:
                self.osVersion = "iOS 13"
                self.wiFiOn = true
            case .macOSWiFiUnknown:
                self.osVersion = "macOS"
            case .macOSWiFiOn:
                self.osVersion = "macOS"
                self.wiFiOn = true
            case .watchWiFiUnknown:
                self.osVersion = "watchOS"
            case .unknown:
                break
            }
        }
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
